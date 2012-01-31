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
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.events.FlexEvent;
import mx.core.mx_internal;
import mx.events.DropdownEvent;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
import flash.events.FocusEvent;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
 
/**
 *  DropDownController handles the mouse, keyboard, and focus
 *  interactions for an anchor button and its dropDown. This helper class
 *  should be used by other dropDown components to handle the opening
 *  and closing of the dropDown due to user interactions.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class DropDownController extends EventDispatcher
{
	/**
	 *  Constructor
	 * 
	 *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
	 */
	public function DropDownController(target:IEventDispatcher=null)
	{
		super(target);
	}
	
	//--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
	
	//----------------------------------
    //  button
    //----------------------------------
	
	private var _button:ButtonBase;
	
	/**
     *  Reference to the button skin part of the dropDown component. 
     *         
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
	public function set button(value:ButtonBase):void
	{
		if (_button === value)
			return;
		
		if (_button)
			_button.removeEventListener(FlexEvent.BUTTON_DOWN, button_buttonDownHandler);
			
		_button = value;
		
    	// TODO (jszeto) Change this to be mouseDown. Figure out how to not 
    	// trigger systemManager_mouseDown.
    	if (_button)
			_button.addEventListener(FlexEvent.BUTTON_DOWN, button_buttonDownHandler);
		
	}
	
	/**
     *  @private 
     */
	public function get button():ButtonBase
	{
		return _button;
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
     *  Whether the dropDown is open or not.   
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
		
	//--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------   

	/**
     *  Opens the dropDown and dispatches a <code>DropdownEvent.OPEN</code> event. 
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
    		// TODO (jszeto) Change these to be marshall plan compliant
    		button.systemManager.addEventListener(MouseEvent.MOUSE_DOWN, systemManager_mouseDownHandler);
    		button.systemManager.addEventListener(Event.RESIZE, systemManager_resizeHandler, false, 0, true);
    		
    		_isOpen = true;
    		button.mx_internal::keepDown = true; // Force the button to stay in the down state
    		
    		dispatchEvent(new DropdownEvent(DropdownEvent.OPEN));
    	}
    }	
    
    /**
     *  Closes the dropDown and dispatches a <code>DropdownEvent.CLOSE</code> event.  
     *   
     *  @param commitData Flag indicating if the component should commit the selected
     *  data from the dropDown. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function closeDropDown(commitData:Boolean):void
    {
    	if (isOpen)
    	{	
			_isOpen = false;
			button.mx_internal::keepDown = false;
        	
        	var dde:DropdownEvent = new DropdownEvent(DropdownEvent.CLOSE, false, true);
        	
        	if (!commitData)
        		dde.preventDefault();
        	
        	dispatchEvent(dde);
        	
        	// TODO (jszeto) Change these to be marshall plan compliant
        	button.systemManager.removeEventListener(MouseEvent.MOUSE_DOWN, systemManager_mouseDownHandler);
        	button.systemManager.removeEventListener(Event.RESIZE, systemManager_resizeHandler);
    	}
    }	
		
    //--------------------------------------------------------------------------
    //
    //  Event handling
    //
    //--------------------------------------------------------------------------
    
	 /**
 	 *  Called when the buttonDown event is dispatched. This function opens or closes
 	 *  the dropDown depending upon the dropDown state. 
 	 *  
 	 *  @langversion 3.0
 	 *  @playerversion Flash 10
 	 *  @playerversion AIR 1.5
 	 *  @productversion Flex 4
 	 */ 
    protected function button_buttonDownHandler(event:Event):void
    {
        if (isOpen)
            closeDropDown(true);
        else
            openDropDown();
    }
			
	/**
     *  Called when the systemManager receives a mouseDown event. This closes
     *  the dropDown if the target is outside of the dropDown. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */     
    protected function systemManager_mouseDownHandler(event:MouseEvent):void
    {
    	// TODO (jszeto) Make marshall plan compliant
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
     *  Closes the dropDown if focus it is no longer in focus.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function focusOutHandler(event:FocusEvent):void
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
	 *  @return Returns true if the <code>keyCode</code> was 
	 *  recognized and handled.
	 * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4 
	 */
	public function keyDownHandler(event:KeyboardEvent):Boolean
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