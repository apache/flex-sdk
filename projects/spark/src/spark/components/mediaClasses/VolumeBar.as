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

package spark.components
{

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.ui.Mouse;

import mx.collections.IList;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.DropdownEvent;
import mx.events.FlexEvent;

import spark.components.supportClasses.ButtonBase;
import spark.components.supportClasses.DropDownController;
import spark.components.supportClasses.ListBase;
import spark.primitives.supportClasses.TextGraphicElement;
import spark.utils.LabelUtil;

/**
 *  Dispatched when the dropDown is dismissed for any reason such when 
 *  the user:
 *  <ul>
 *      <li>selects an item in the dropDown</li>
 *      <li>mouses outside outside of the dropDown</li>
 *  </ul>
 *
 *  @eventType mx.events.DropdownEvent.CLOSE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="close", type="mx.events.DropdownEvent")]

/**
 *  Dispatched when the mouses over the dropDown button
 *  to display the dropDown.  It is also dispatched if the user
 *  uses the keyboard and types Ctrl-Down to open the dropDown.
 *
 *  @eventType mx.events.DropdownEvent.OPEN
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="open", type="mx.events.DropdownEvent")]

/**
 *  Dispatched when the user presses the mute button control.
 *
 *  @eventType mx.events.FlexEvent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="muteButtonClick", type="mx.events.MouseEvent")]

/**
 *  Open State of the DropDown component
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("open")]

/**
 *  The VideoPlayerVolumeBar is a drop-down button 
 *  that functions as a mute/unmute button and also has a 
 *  pop-up to control the volume.
 * 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class VideoPlayerVolumeBar extends VSlider
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  The default value for the rollover open delay of this component.
     * 
     *  <p>This is how long to wait while hovered over the button before the 
     *  pop up opens.</p>
     *
     *  @default 200
     */
    private static const ROLL_OVER_OPEN_DELAY:Number = 200;
 
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------	
	
	/**
     *  A skin part that defines the mute/unmute button.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart(required="false")]
    public var muteButton:VideoPlayerVolumeBarMuteButton;
	
	
	/**
     *  A skin part that defines the dropDown area. When the volume slider 
     *  dropdown is open, clicking anywhere outside of the dropDown skin 
     *  part will close the  video slider dropdown. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart(required="false")]
    public var dropDown:DisplayObject;
    	
	/**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
	public function VideoPlayerVolumeBar()
	{
		super();
		
		if (_dropDownControllerClass)
		{
			_dropDownController = new _dropDownControllerClass();
			initializeDropDownController();
		}
	}
	
	//--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
	
	//----------------------------------
    //  dropDownController
    //----------------------------------
	
	private var _dropDownController:DropDownController;	
	
	/**
     *  Instance of the helper class that handles all of the mouse, keyboard 
     *  and focus user interactions. The type of this class is determined by the
     *  <code>dropDownControllerClass</code> property. 
     * 
     *  The <code>initializeDropDownController()</code> function is called after 
     *  the dropDownController is created in the constructor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
	protected function get dropDownController():DropDownController
	{
		return _dropDownController;
	}

	//----------------------------------
    //  dropDownControllerClass
    //----------------------------------
	
	private var _dropDownControllerClass:Class = DropDownController;

	/**
     *  The class used to create an instance for the <code>dropDownController</code> 
     *  property. Set this property if you want to use a 
     *  <code>DropDownController</code> subclass to modify the default mouse, 
     *  keyboard and focus user interactions.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
	public function set dropDownControllerClass(value:Class):void
	{
		if (_dropDownControllerClass == value)
			return;
			
		_dropDownControllerClass = value;
		_dropDownController = new _dropDownControllerClass();
		initializeDropDownController();
	}
	
	/**
     *  @private
     */
	public function get dropDownControllerClass():Class
	{
		return _dropDownControllerClass;
	}

    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  baselinePosition
    //----------------------------------
    
    /**
     *  @private
     */
    override public function get baselinePosition():Number
    {
    	if (muteButton)
    		return muteButton.baselinePosition;
    	else
    		return NaN;
    }
    
    //----------------------------------
    //  enabled
    //----------------------------------
    
    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
    {
    	if (value == enabled)
    		return;
    	
    	super.enabled = value;
    	if (muteButton)
    		muteButton.enabled = value;
    }
    
    //----------------------------------
    //  value
    //----------------------------------
    
    /**
     *  @private
     */
    override public function set value(value:Number):void
    {
        if (super.value == value)
            return;
        
        super.value = value;
        
        if (muteButton)
            muteButton.value = value;
    }
    
 	//--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------   
    
    /**
     *  @private
     */
    override protected function setValue(value:Number):void
    {
        super.setValue(value);
        
        if (muteButton)
            muteButton.value = value;
    }

	/**
     *  Opens the dropDown. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function openDropDown():void
    {
    	dropDownController.openDropDown();
    }
	
	 /**
     *  Closes the dropDown. 
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
    	dropDownController.closeDropDown(commitData);
    }
	
	/**
     *  Initializes the <code>dropDownController</code> after it has been created. 
     *  Override this function if you create a <code>DropDownController</code> subclass 
     *  and need to perform additional initialization.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4 
     */
	protected function initializeDropDownController():void
	{		
		if (dropDownController)
		{
			dropDownController.addEventListener(DropdownEvent.OPEN, dropDownController_openHandler);
			dropDownController.addEventListener(DropdownEvent.CLOSE, dropDownController_closeHandler);
			
			dropDownController.rollOverOpenDelay = ROLL_OVER_OPEN_DELAY;
			
			if (muteButton)
				dropDownController.button = muteButton;
			if (dropDown)
				dropDownController.dropDown = dropDown;
		}
	}
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
 	 *  @private
 	 */ 
    override protected function getCurrentSkinState():String
    {
		return !enabled ? "disabled" : dropDownController.isOpen ? "open" : "normal";
    }   
       
    /**
	 *  @private
	 */ 
    override protected function partAdded(partName:String, instance:Object):void
    {
    	super.partAdded(partName, instance);
 
 		if (instance == muteButton)
    	{
    		if (dropDownController)
    			dropDownController.button = muteButton;
            
    	    muteButton.addEventListener(MouseEvent.CLICK, muteButton_clickHandler);
    		muteButton.enabled = enabled;
    		muteButton.value = value;
    	}
    	
    	if (instance == dropDown && dropDownController)
    		dropDownController.dropDown = dropDown;
    }
    
    private function muteButton_clickHandler(event:MouseEvent):void
    {
        // TODO (rfrishbe): Need this to be a real event
        var muteButtonClickEvent:MouseEvent = new MouseEvent("muteButtonClick");
        dispatchEvent(muteButtonClickEvent);
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == muteButton)
        {
            muteButton.removeEventListener(MouseEvent.CLICK, muteButton_clickHandler);
        }
        
    	if (instance == dropDownController)
    	{
    		if (instance == muteButton)
	    		dropDownController.button = null;
    	
    		if (instance == dropDown)
    			dropDownController.dropDown = null;
     	}
     	
        super.partRemoved(partName, instance);
    }
	
	/**
     *  @private
     */
    override protected function focusOutHandler(event:FocusEvent):void
    {
		dropDownController.focusOutHandler(event);

        super.focusOutHandler(event);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handling
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Event handler for the <code>dropDownController</code> 
     *  <code>DropdownEvent.OPEN</code> event. Updates the skin's state and 
     *  ensures that the selectedItem is visible. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function dropDownController_openHandler(event:DropdownEvent):void
    {
    	invalidateSkinState();
    	
    	dispatchEvent(event);
    }
    
    /**
     *  Event handler for the <code>dropDownController</code> 
     *  <code>DropdownEvent.CLOSE</code> event. Updates the skin's state.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function dropDownController_closeHandler(event:DropdownEvent):void
    {
    	invalidateSkinState();
    	
    	// TODO!! Add logic to handle commitData
    	//if (event.isDefaultPrevented())
    	
    	dispatchEvent(event);
    }

}
}
