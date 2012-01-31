////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
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
import flash.events.FocusEvent;
import flash.events.IEventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.ui.Keyboard;
import flash.utils.Timer;

import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.SandboxMouseEvent;

import spark.events.DropDownEvent; 

use namespace mx_internal;

/**
 *  The DropDownController class handles the mouse, keyboard, and focus
 *  interactions for an anchor button and its associated drop down. 
 *  This class is used by the drop-down components, such as DropDownList, 
 *  to handle the opening and closing of the drop down due to user interactions.
 * 
 *  @see spark.components.DropDownList
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class DropDownController extends EventDispatcher
{
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function DropDownController()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  openButton
    //----------------------------------
    
    private var _openButton:ButtonBase;
    
    /**
     *  A reference to the <code>openButton</code> skin part 
     *  of the drop-down component. 
     *         
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function set openButton(value:ButtonBase):void
    {
        if (_openButton === value)
            return;
        
        removeOpenTriggers();
            
        _openButton = value;
        
        addOpenTriggers();
        
    }
    
    /**
     *  @private 
     */
    public function get openButton():ButtonBase
    {
        return _openButton;
    }
    
    //----------------------------------
    //  dropDown
    //----------------------------------
    
    private var _dropDown:DisplayObject;
    
    /**
     *  @private 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function set dropDown(value:DisplayObject):void
    {
        if (_dropDown === value)
            return;
            
        _dropDown = value;
    }   
    
    /**
     *  @private 
     */
    public function get dropDown():DisplayObject
    {
        return _dropDown;
    }
        
    //----------------------------------
    //  isOpen
    //----------------------------------
    
    /**
     *  @private 
     */
    private var _isOpen:Boolean = false;
    
    /**
     *  Contains <code>true</code> if the drop down is open.   
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */  
    public function get isOpen():Boolean
    {
        return _isOpen;
    }
        
    //----------------------------------
    //  rolloverOpenDelay
    //----------------------------------
    
    private var _rollOverOpenDelay:Number = Number.NaN;
    private var rollOverOpenDelayTimer:Timer;
    
    /**
     *  Specifies the delay, in milliseconds, to wait for opening the drop down 
     *  when the anchor button is rolled over.  
     *  If set to <code>NaN</code>, then the drop down opens on a click, not a rollover.
     * 
     *  @default NaN
     *         
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get rollOverOpenDelay():Number
    {
        return _rollOverOpenDelay;
    }
    
    /**
     *  @private 
     */
    public function set rollOverOpenDelay(value:Number):void
    {
        if (_rollOverOpenDelay == value)
            return;
        
        removeOpenTriggers();
                    
        _rollOverOpenDelay = value;

        addOpenTriggers();
    }
        
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------   

    /**
     *  @private 
     *  Adds event triggers to the openButton to open the popup.
     * 
     *  <p>This is called from the openButton setter after the openButton has been set.</p>
     */ 
    private function addOpenTriggers():void
    {
        // FIXME (jszeto): Change this to be mouseDown. Figure out how to not 
        // trigger systemManager_mouseDown.
        if (openButton)
        {
            if (isNaN(rollOverOpenDelay))
                openButton.addEventListener(FlexEvent.BUTTON_DOWN, openButton_buttonDownHandler);
            else
                openButton.addEventListener(MouseEvent.ROLL_OVER, openButton_rollOverHandler);
        }
    }
    
    /**
     *  @private
     *  Removes event triggers from the openButton to open the popup.
     * 
     *  <p>This is called from the openButton setter after the openButton has been set.</p>
     */ 
    private function removeOpenTriggers():void
    {
        // FIXME (jszeto): Change this to be mouseDown. Figure out how to not 
        // trigger systemManager_mouseDown.
        if (openButton)
        {
            if (isNaN(rollOverOpenDelay))
                openButton.removeEventListener(FlexEvent.BUTTON_DOWN, openButton_buttonDownHandler);
            else
                openButton.removeEventListener(MouseEvent.ROLL_OVER, openButton_rollOverHandler);
        }
    }
    
    /**
     *  @private
     *  Adds event triggers close the popup.
     * 
     *  <p>This is called when the drop down is popped up.</p>
     */ 
    private function addCloseTriggers():void
    {
        // FIXME (jszeto): Change these to be marshall plan compliant
        if (openButton)
        {
            if (isNaN(rollOverOpenDelay))
            {
                openButton.systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_DOWN, systemManager_mouseDownHandler);
                openButton.systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE, systemManager_mouseDownHandler);
                openButton.systemManager.getSandboxRoot().addEventListener(Event.RESIZE, systemManager_resizeHandler, false, 0, true);
            }
            else
            {
                openButton.systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler);
                openButton.systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_MOVE_SOMEWHERE, systemManager_mouseMoveHandler);
                openButton.systemManager.getSandboxRoot().addEventListener(Event.RESIZE, systemManager_resizeHandler, false, 0, true);
            }
        }
    }
    
    /**
     *  @private
     *  Adds event triggers close the popup.
     * 
     *  <p>This is called when the drop down is closed.</p>
     */ 
    private function removeCloseTriggers():void
    {
        // FIXME (jszeto): Change these to be marshall plan compliant
        if (openButton)
        {
            if (isNaN(rollOverOpenDelay))
            {
                openButton.systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_DOWN, systemManager_mouseDownHandler);
                openButton.systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE, systemManager_mouseDownHandler);
                openButton.systemManager.getSandboxRoot().removeEventListener(Event.RESIZE, systemManager_resizeHandler, false);
            }
            else
            {
                openButton.systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler);
                openButton.systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_MOVE_SOMEWHERE, systemManager_mouseMoveHandler);
                openButton.systemManager.getSandboxRoot().removeEventListener(Event.RESIZE, systemManager_resizeHandler);
            }
        }
    } 

    /**
     *  Open the drop down and dispatch a <code>DropdownEvent.OPEN</code> event. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function openDropDown():void
    {
        if (!isOpen)
        {
            addCloseTriggers();
            
            _isOpen = true;
            openButton.keepDown = true; // Force the button to stay in the down state
            
            dispatchEvent(new DropDownEvent(DropDownEvent.OPEN));
        }
    }   
    
    /**
     *  Close the drop down and dispatch a <code>DropDownEvent.CLOSE</code> event.  
     *   
     *  @param commit If <code>true</code>, commit the selected
     *  data item. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function closeDropDown(commit:Boolean):void
    {
        if (isOpen)
        {   
            _isOpen = false;
            openButton.keepDown = false;
            
            var dde:DropDownEvent = new DropDownEvent(DropDownEvent.CLOSE, false, true);
            
            if (!commit)
                dde.preventDefault();
            
            dispatchEvent(dde);
            
            removeCloseTriggers();
        }
    }   
        
    //--------------------------------------------------------------------------
    //
    //  Event handling
    //
    //--------------------------------------------------------------------------
    
     /**
     *  @private
     *  Called when the buttonDown event is dispatched. This function opens or closes
     *  the dropDown depending upon the dropDown state. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    protected function openButton_buttonDownHandler(event:Event):void
    {
        if (isOpen)
            closeDropDown(true);
        else
            openDropDown();
    }
            
    /**
     *  @private
     *  Called when the openButton's <code>rollOver</code> event is dispatched. This function opens 
     *  the drop down, or opens the drop down after the length of time specified by the 
     *  <code>rollOverOpenDelay</code> property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    protected function openButton_rollOverHandler(event:MouseEvent):void
    {
        if (rollOverOpenDelay == 0)
            openDropDown();
        else
        {
            openButton.addEventListener(MouseEvent.ROLL_OUT, openButton_rollOutHandler);
            rollOverOpenDelayTimer = new Timer(rollOverOpenDelay, 1);
            rollOverOpenDelayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, rollOverDelay_timerCompleteHandler);
            rollOverOpenDelayTimer.start();
        }
    }
    
    /**
     *  @private 
     *  Called when the openButton's rollOut event is dispatched while waiting 
     *  for the rollOverOpenDelay. This will cancel the timer so we don't open
     *  any more.
     */ 
    private function openButton_rollOutHandler(event:MouseEvent):void
    {
        if (rollOverOpenDelayTimer && rollOverOpenDelayTimer.running)
        {
            rollOverOpenDelayTimer.stop();
            rollOverOpenDelayTimer = null;
        }
        
        openButton.removeEventListener(MouseEvent.ROLL_OUT, openButton_rollOutHandler);
    }
    
    /**
     *  @private
     *  Called when the rollOverDelay Timer is up and we should show the drop down.
     */ 
     private function rollOverDelay_timerCompleteHandler(event:TimerEvent):void
     {
         openButton.removeEventListener(MouseEvent.ROLL_OUT, openButton_rollOutHandler);
         rollOverOpenDelayTimer = null;
         
         openDropDown();
     }
            
    /**
     *  @private
     *  Called when the systemManager receives a mouseDown event. This closes
     *  the dropDown if the target is outside of the dropDown. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */     
    protected function systemManager_mouseDownHandler(event:Event):void
    {
        if (!dropDown || 
            (dropDown && 
             (event.target == dropDown 
             || (dropDown is DisplayObjectContainer && 
                 !DisplayObjectContainer(dropDown).contains(DisplayObject(event.target))))))
        {
            closeDropDown(true);
        } 
    }
    
    /**
     *  @private
     *  Called when the dropdown is popped up from a rollover and the mouse moves 
     *  anywhere on the screen.  If the mouse moves over the openButton or the dropdown, 
     *  the popup will stay open.  Otherwise, the popup will close.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    protected function systemManager_mouseMoveHandler(event:Event):void
    {
        var target:DisplayObject = event.target as DisplayObject;
        
        // if the mouse is down, wait until it's released
        // FIXME (rfrishbe): Need to do something when they mouse up in 
        // this case if they mouseup outside of the openButton/dropdown.
        if ((event is MouseEvent && MouseEvent(event).buttonDown) ||
            (event is SandboxMouseEvent && SandboxMouseEvent(event).buttonDown))
            return;
        
        if (target)
        {
            // check if the target is the openButton or contained within the openButton
            if (openButton.contains(target))
                return;
            
            // check if the target is the dropdown or contained within the dropdown
            if (dropDown is DisplayObjectContainer)
            {
                if (DisplayObjectContainer(dropDown).contains(target))
                    return;
            }
            else
            {
                if (target == dropDown)
                    return;
            }
        }
        
        closeDropDown(true);
    }
    
    /**
     *  @private
     *  Close the dropDown if the stage has been resized.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function systemManager_resizeHandler(event:Event):void
    {
        closeDropDown(true);
    }       
    
    /**
     *  Close the drop down if it is no longer in focus.
     *
     *  @param event The event object for the <code>FOCUS_OUT</code> event.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function processFocusOut(event:FocusEvent):void
    {
        // Note: event.relatedObject is the object getting focus.
        // It can be null in some cases, such as when you open
        // the dropdown and then click outside the application.

        // If the dropdown is open...
        if (isOpen)
        {
            // If focus is moving outside the dropdown...
            if (!event.relatedObject ||
                (!dropDown || 
                    (dropDown is DisplayObjectContainer &&
                     !DisplayObjectContainer(dropDown).contains(event.relatedObject))))
            {
                // Close the dropdown.
                closeDropDown(true);
            }
        }
    }
    
    /**
     *  Handles the keyboard user interactions.
     *
     *  @param event The event object from the keyboard event.
     * 
     *  @return Returns <code>true</code> if the <code>keyCode</code> was 
     *  recognized and handled.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4 
     */
    public function processKeyDown(event:KeyboardEvent):Boolean
    {
        
        if (event.ctrlKey && event.keyCode == Keyboard.DOWN)
        {
            openDropDown();
            event.stopPropagation();
        }
        else if (event.ctrlKey && event.keyCode == Keyboard.UP)
        {
            closeDropDown(true);
            event.stopPropagation();
        }    
        else if (event.keyCode == Keyboard.ENTER)
        {
            // Close the dropDown and eat the event if appropriate.
            if (isOpen)
            {
                closeDropDown(true);
                event.stopPropagation();
            }
        }
        else if (event.keyCode == Keyboard.ESCAPE)
        {
            // Close the dropDown and eat the event if appropriate.
            if (isOpen)
            {
                closeDropDown(false);
                event.stopPropagation();
            }
        }
        else
        {
            return false;
        }   
            
        return true;        
    }
                
}
}
