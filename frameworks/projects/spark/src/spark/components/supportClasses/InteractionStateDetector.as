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
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.core.InteractionMode;
import mx.core.UIComponent;
import mx.events.FlexEvent;
import mx.events.SandboxMouseEvent;
import mx.events.TouchInteractionEvent;
import mx.managers.ISystemManager;

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
 *  A helper class for item renderers to use to help them determine 
 *  if they should be in the hovered or down states
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class ItemRendererInteractionStateDetector extends EventDispatcher
{
    
    /**
     *  Constructor
     *  
     *  @param components  The UIComponent to detect the hovered/down state on.
     *                     The event listeners are attached to this object 
     *                     to figure out if it should be in the hovered or down state.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function ItemRendererInteractionStateDetector(component:UIComponent)
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
    
    [Bindable("change")]
    /**
     *  Returns true if the item renderer should be put into 
     *  a hovered state.
     * 
     *  <p>If in mouse interactionMode, the item renderer is in the 
     *  hovered state if the mouse is over the item renderer.   
     *  In touch interaction mode, hovered does not apply.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get hovered():Boolean
    {
        var interactionMode:String = component.getStyle("interactionMode");
        
        if (interactionMode == InteractionMode.MOUSE && _hovered)
            return true;
        
        return false;
    }
    
    /**
     *  @private
     */
    private function setHovered(value:Boolean):void
    {
        if (value == _hovered)
            return;
        
        _hovered = value;
        invalidateState();
    }
    
    //----------------------------------
    //  down
    //----------------------------------
    
    [Bindable("change")]
    /**
     *  Returns true if the item renderer should be put into 
     *  a down state.
     * 
     *  <p>If in touch interactionMode, the item renderer is in the 
     *  down state if the user is pressing down on the item renderer.   
     *  In mouse interaction mode, down does not apply.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get down():Boolean
    {
        var interactionMode:String = component.getStyle("interactionMode");
        
        if (interactionMode == InteractionMode.TOUCH && isDown())
            return true;
        
        return false;
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
        if (value == _mouseCaptured)
            return;
        
        _mouseCaptured = value;        
        invalidateState();
        
        // System mouse handlers are not needed when the renderer is not mouse captured
        if (!value)
            removeSystemMouseHandlers();
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
        
        if (systemManager)
        {
            systemManager.getSandboxRoot().addEventListener(
                MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true /* useCapture */);
            
            systemManager.getSandboxRoot().addEventListener(
                SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemManager_mouseUpHandler);
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
        
        if (systemManager)
        {
            systemManager.getSandboxRoot().removeEventListener(
                MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true /* useCapture */);
            
            systemManager.getSandboxRoot().removeEventListener(
                SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemManager_mouseUpHandler);
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
            // just use touchDelay rather than have minimumDownStateTime like Button has
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
                setHovered(true);
                break;
            }
                
            case MouseEvent.ROLL_OUT:
            {
                setHovered(false);
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
				// FIXME (rfrishbe): we should be setting hovered=true here just like Button does.
                // we're only not doing it as a temporary thing so tests don't break.  The reason it should 
                // be true is because if someone hovers over us with the mousedown and then releases up,
                // the item they release up on should be hovered.
                //setHovered(true);
                
                if (mouseCaptured)
                {
                    mouseCaptured = false;
                }
                
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
        setHovered(false);
        mouseCaptured = false;
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
