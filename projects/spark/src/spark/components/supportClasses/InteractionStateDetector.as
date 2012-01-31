////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.supportClasses
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.core.InteractionMode;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.SandboxMouseEvent;
import mx.events.TouchInteractionEvent;
import mx.managers.ISystemManager;

use namespace mx_internal;

/**
 *  Dispatched after the state has changed.
 *
 *  @eventType flash.events.Event.CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="change", type="flash.events.Event")]

/**
 *  A helper class for components to use to help them determine 
 *  if they should be in the up, over, or down states.
 * 
 *  <p>As the state changes, if the transition should play, the 
 *  playTransitions.</p>
 * 
 *  @see spark.components.supportClasses.InteractionState
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class InteractionStateDetector extends EventDispatcher
{
    
    /**
     *  Constructor
     *  
     *  @param components  The UIComponent to detect the up/over/down state on.
     *                     The event listeners are attached to this object.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function InteractionStateDetector(component:UIComponent)
    {
        super();
        this.component = component;
        
        addHandlers();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  The UIComponent to detect the hovered and down state for
     */
    private var component:UIComponent;
    
    /**
     *  @private
     *  Timer for putting the renderer in the down state on a delay
     *  timer because of touch input.
     */
    private var mouseDownSelectTimer:Timer;
    
    /**
     *  @private
     *  Timer for putting the renderer in the up state.  This makes sure 
     *  even when we have a delay to select an item and someone mouses up
     *  before that delay, the user still gets some visual feedback that 
     *  the renderer was actually selected.
     */
    private var mouseUpDeselectTimer:Timer;
	
	/**
	 *  @private
	 *  When faking a mouseDown after a mouse up has occurred, if we get a rollOut
	 *  event, we don't want to immediately set hovered = false so we can maintain 
	 *  the down state until the mouseUpDeselectTimer is finished.  So we keep track
	 *  that a rollOut event occurred and honor it later.
	 */
	private var rollOutWhileFakingDownState:Boolean = false;
	
    /**
     *  @private
     *  Whether the component using this InteractionStateDetector should 
     *  play transitions on a particular state change.
     * 
     *  <p>This could be moved to the CHANGE event itself, but 
     *  seeing as we don't have a formal mechanism for dealing with ItemRenderer
     *  transitions in the first place, this seems like an acceptable solution.<p>
     * 
     *  <p>Currently, InteractionStateDetector is the one who would know whether a 
     *  transition should play or not because it knows how it got in to a particular 
     *  state and that's what we use to determine whether transitions play or not.  
     *  For instance, if a scroll starts while you're in the down state, that should 
     *  cancel the down state and not play a transition.</p>
     */
    mx_internal var playTransitions:Boolean = true;
    
    /**
     *  @private
     *  Keeps track of whether the system mouse handlers are installed
     */
    private var systemMouseHandlersAdded:Boolean = false;
    
    
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  hovered
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the hovered property 
     */
    private var _hovered:Boolean = false; 
    
    /**
     *  @private
     */
    private function get hovered():Boolean
    {
        return _hovered;
    }
    
    /**
     *  @private
     */
    private function set hovered(value:Boolean):void
    {
        if (value == _hovered)
            return;
        
        _hovered = value;
        invalidateState();
    }
    
    //----------------------------------
    //  mouseCaptured
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the mouseCaptured property 
     */
    private var _mouseCaptured:Boolean = false;    
    
    /**
     *  @private 
     *  Indicates whether the mouse is down and the mouse pointer was
     *  over the renderer when <code>MouseEvent.MOUSE_DOWN</code> was first dispatched.
     *  Used to determine the skin state.
     */    
    private function get mouseCaptured():Boolean
    {
        return _mouseCaptured;
    }
    
    /**
     *  @private
     */
    private function set mouseCaptured(value:Boolean):void
    {
        // System mouse handlers are not needed when the renderer is not mouse captured
        // NOTE: do this before the short-circuit because setting false needs to remove 
        // the handlers even if the value is already false.
        if (!value)
            removeSystemMouseHandlers();

        if (value == _mouseCaptured)
            return;
        
        _mouseCaptured = value;        
        invalidateState();
        
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  state
    //----------------------------------  
    
    [Bindable("change")]
    /**
     *  Returns the state of the component
     * 
     *  <p>Possible values are:
     *    <ul>
     *      <li>InteractionState.UP</li>
     *      <li>InteractionState.DOWN</li>
     *      <li>InteractionState.OVER</li>
     *    </ul>
     *  </p>
     * 
     *  @see spark.components.supportClasses.InteractionState;
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get state():String
    {
        if (isDown())
            return InteractionState.DOWN;
        else if (hovered && component.getStyle("interactionMode") == InteractionMode.MOUSE)
            return InteractionState.OVER;
        else
            return InteractionState.UP;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Helper method to determine if someone has down down on 
     *  the display object.
     */
    private function isDown():Boolean
    {
        return (mouseCaptured && _hovered);
    }
    
    /**
     *  @private
     *  Called when the state becomes invalid.  This just
     *  in turn dispatches a CHANGE event.
     */ 
    private function invalidateState():void
    {
        dispatchEvent(new Event(Event.CHANGE));
    }
    
    /**
     *  @private
     */
    private function addHandlers():void
    {
        component.addEventListener(MouseEvent.ROLL_OVER, mouseEventHandler);
        component.addEventListener(MouseEvent.ROLL_OUT, mouseEventHandler);
        component.addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
        component.addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
        component.addEventListener(MouseEvent.CLICK, mouseEventHandler);
        component.addEventListener(TouchInteractionEvent.TOUCH_INTERACTION_START, touchInteractionStartHandler);
    }
    
    /**
     *  @private
     *  This method adds the systemManager_mouseUpHandler as an event listener to
     *  the stage and the systemManager so that it gets called even if mouse events
     *  are dispatched outside of the renderer. This is needed for example when the
     *  user presses the renderer, drags out and releases the renderer.
     */
    private function addSystemMouseHandlers():void
    {
        var systemManager:ISystemManager = component.systemManager;
        
        if (systemManager && !systemMouseHandlersAdded)
        {
            systemManager.getSandboxRoot().addEventListener(
                MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true /* useCapture */);
            
            systemManager.getSandboxRoot().addEventListener(
                SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemManager_mouseUpHandler);
            
            systemMouseHandlersAdded = true;
        }
    }
    
    /**
     *  @private
     *  This method removes the systemManager_mouseUpHandler as an event
     *  listener from the stage and the systemManager.
     */
    private function removeSystemMouseHandlers():void
    {
        var systemManager:ISystemManager = component.systemManager;
        
        if (systemManager && systemMouseHandlersAdded)
        {
            systemManager.getSandboxRoot().removeEventListener(
                MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true /* useCapture */);
            
            systemManager.getSandboxRoot().removeEventListener(
                SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemManager_mouseUpHandler);
            
            systemMouseHandlersAdded = false;
        }
    }
    
    /**
     *  @private
     *  Starts timer to select the renderer
     */
    private function startSelectRendererAfterDelayTimer():void
    {
        var touchDelay:Number = component.getStyle("touchDelay");
        
        if (touchDelay > 0)
        {
            mouseDownSelectTimer = new Timer(touchDelay, 1);
            mouseDownSelectTimer.addEventListener(TimerEvent.TIMER_COMPLETE, mouseDownSelectTimer_timerCompleteHandler);
            mouseDownSelectTimer.start();
        }
        else
        {
            mouseDownSelectTimer_timerCompleteHandler();
        }
    }
    
    /**
     *  @private
     */
    private function stopSelectRendererAfterDelayTimer():void
    {
        if (mouseDownSelectTimer)
        {
            mouseDownSelectTimer.stop();
            mouseDownSelectTimer = null;
        }
    }
    
    /**
     *  @private
     *  Starts timer to deselect the renderer if the mouseup happened too quickly 
     *  after the mousedown so that no mousedown state was entered in to.
     */
    private function startDeselectRendererAfterDelayTimer():void
    {
        var touchDelay:Number = component.getStyle("touchDelay");
        
        if (touchDelay > 0)
        {
            mouseUpDeselectTimer = new Timer(touchDelay, 1);
            mouseUpDeselectTimer.addEventListener(TimerEvent.TIMER_COMPLETE, mouseUpDeselectTimer_timerCompleteHandler);
            mouseUpDeselectTimer.start();
        }
        else
        {
            mouseUpDeselectTimer_timerCompleteHandler();
        }
    }
    
    /**
     *  @private
     */
    private function stopDeselectRendererAfterDelayTimer():void
    {
        if (mouseUpDeselectTimer)
        {
            mouseUpDeselectTimer.stop();
            mouseUpDeselectTimer = null;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  This method handles the mouse events, calls the <code>clickHandler</code> method 
     *  where appropriate and updates the <code>hovered</code> and
     *  <code>mouseCaptured</code> properties.
     *
     *  <p>This method gets called to handle <code>MouseEvent.ROLL_OVER</code>, 
     *  <code>MouseEvent.ROLL_OUT</code>, <code>MouseEvent.MOUSE_DOWN</code>, 
     *  <code>MouseEvent.MOUSE_UP</code>, and <code>MouseEvent.CLICK</code> events.</p>
     *
     *  @param event The Event object associated with the event.
     */
    private function mouseEventHandler(event:Event):void
    {
        var mouseEvent:MouseEvent = event as MouseEvent;
        switch (event.type)
        {
            case MouseEvent.ROLL_OVER:
            {
                // if the user rolls over while holding the mouse button
                if (mouseEvent.buttonDown && !mouseCaptured)
                    return;
				
                hovered = true;
				rollOutWhileFakingDownState = false;
                break;
            }
                
            case MouseEvent.ROLL_OUT:
            {
				if (mouseUpDeselectTimer && mouseUpDeselectTimer.running)
				{
					// We're trying to flash the down state for longer, 
					// so let's not leave the hovered state just yet
					rollOutWhileFakingDownState = true;
				}
				else
				{
					hovered = false;
				}
                break;
            }
                
            case MouseEvent.MOUSE_DOWN:
            {
                // since mouseDowns are cancellable, let's check to see 
                // if anyone's handled it already
                if (event.isDefaultPrevented())
                    break;
                
                // if we were going to unhighlight ourselves, don't do it as we 
                // are just going to highlight again
                stopDeselectRendererAfterDelayTimer();
                
                // When the button is down we need to listen for mouse events outside the renderer so that
                // we update the state appropriately on mouse up.  Whenever mouseCaptured changes to false,
                // it will take care to remove those handlers.
                addSystemMouseHandlers();
                
                // if we're in touchMode, let's delay our selection until later
                // otherwise, when touch scrolling, the renderer might flicker
                if (component.getStyle("interactionMode") == InteractionMode.TOUCH)
                {
                    startSelectRendererAfterDelayTimer();
                }
                else
                {
                    mouseCaptured = true;
                }
                
                // we don't call event.preventDefault() here since List.item_mouseDownHandler will call this anyways
                break;
            }
                
            case MouseEvent.MOUSE_UP:
            {
                // If someone mouses up on us, then they must be hovered over 
                // us now.
                hovered = true;
				
				if (mouseDownSelectTimer && mouseDownSelectTimer.running)
				{
					// We never even flashed the down state for this click operation.
					// There are two possibilities for being here:
					//    1) mouseCaptured wasn't set to true (meaning this is the first click)
					//    2) mouseCaptured was true (meaning a click operation hadn't finished 
					//       and we find ourselves in here again--perhaps it was a doublet tap).
					// In either case, let's make sure that down state shows up for a little bit
					// before going back to the up state.
					
					// stop the original timer, put it in mouse down state, then start a new 
					// timer to undo the mouse down state
					stopSelectRendererAfterDelayTimer();
					mouseCaptured = true;
					startDeselectRendererAfterDelayTimer();
				}
				else if (mouseCaptured)
                {
                    mouseCaptured = false;
                }
                
                break;
            }
                
            case MouseEvent.CLICK:
            {
                return;
            }
        }
    }
    
    /**
     *  @private
     */
    private function systemManager_mouseUpHandler(event:Event):void
    {
        // If the target is the renderer, do nothing because the
        // mouseEventHandler will be handle it.
        if (event.target == component || component.contains(event.target as DisplayObject))
        {
            return;
        }
        
		// If faking down state, let's not interrupt it because of a mouseUp somewhere 
		// else on the screen
		if (!(mouseUpDeselectTimer && mouseUpDeselectTimer.running))
			mouseCaptured = false;
        
        // If the mouseDownSelectTimer is still running, 
        // we don't want to ever go in to the down state in this case, so stop it
        if (mouseDownSelectTimer && mouseDownSelectTimer.running)
            stopSelectRendererAfterDelayTimer();
    }
    
    /**
     *  @private
     */
    private function touchInteractionStartHandler(event:TouchInteractionEvent):void
    {
        // if we have a timer going on, let's stop it to make sure we don't
        // select the renderer later
        stopSelectRendererAfterDelayTimer();
        
        // cancel the rollover/clickdown on and go back to a normal state
        
        // turn off transitions for this change because it's really cancelling the 
        // the down state
        playTransitions = false;
        hovered = false;
        mouseCaptured = false;
        playTransitions = true;
    }
    
    /**
     *  @private
     */
    private function mouseDownSelectTimer_timerCompleteHandler(event:TimerEvent = null):void
    {
        mouseCaptured = true;
    }
    
    /**
     *  @private
     */
    private function mouseUpDeselectTimer_timerCompleteHandler(event:TimerEvent = null):void
    {
        mouseCaptured = false;
		
		// if we got a rollout, we should honor it now
		if (rollOutWhileFakingDownState)
		{
			rollOutWhileFakingDownState = false;
			hovered = false;
		}
    }
    
    /**
     *  @private
     */
    private function anyButtonDown(event:MouseEvent):Boolean
    {
        var type:String = event.type;
        // TODO (rfrishbe): we should not code to literals here (and other places where this code is used)
        return event.buttonDown || (type == "middleMouseDown") || (type == "rightMouseDown"); 
    }
    
    
}
}
