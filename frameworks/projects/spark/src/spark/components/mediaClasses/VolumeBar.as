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

package spark.components.mediaClasses
{

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.ui.Mouse;

import mx.collections.IList;
import mx.core.IUIComponent;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.FlexEvent;
import mx.managers.LayoutManager;

import spark.components.VSlider;
import spark.components.supportClasses.ButtonBase;
import spark.components.supportClasses.DropDownController;
import spark.components.supportClasses.ListBase;
import spark.events.DropDownEvent;
import spark.utils.LabelUtil;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the dropDown is dismissed for any reason such when 
 *  the user:
 *  <ul>
 *      <li>selects an item in the dropDown</li>
 *      <li>mouses outside outside of the dropDown</li>
 *  </ul>
 *
 *  @eventType spark.events.DropDownEvent.CLOSE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="close", type="spark.events.DropDownEvent")]

/**
 *  Dispatched when the mouses over the dropDown button
 *  to display the dropDown.  It is also dispatched if the user
 *  uses the keyboard and types Ctrl-Down to open the dropDown.
 *
 *  @eventType spark.events.DropDownEvent.OPEN
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="open", type="spark.events.DropDownEvent")]

/**
 *  Dispatched when the video mutes or unmutes the volume
 *  from user-interaction.
 *
 *  @eventType mx.events.FlexEvent.MUTED_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="mutedChange", type="mx.events.FlexEvent")]

//--------------------------------------
//  Styles
//--------------------------------------
    
/**
 *  The delay, in milliseconds, to wait before opening the volume slider, 
 *  while the anchor button is hovered.
 *  
 *  @default 200
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="rollOverOpenDelay", type="Number", inherit="no")]

//--------------------------------------
//  SkinStates
//--------------------------------------

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
 *  The VolumeBar is a drop-down slider to control 
 *  the volume of the video player.  By default it pops up when the
 *  muteButton is rolled over (with a delay of 200 milliseconds).  The  
 *  muteButton functions as a mute/unmute button when clicked.
 *
 *  @see spark.components.VideoPlayer 
 *  @see spark.primitives.VideoElement
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class VolumeBar extends VSlider
{
 
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
    public var muteButton:MuteButton;
    
    
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
    public function VolumeBar()
    {
        super();
        
        dropDownController = new DropDownController();
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
     *  and focus user interactions.  
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
    
    protected function set dropDownController(value:DropDownController):void
    {
        if (_dropDownController == value)
            return;
            
        _dropDownController = value;
            
        _dropDownController.addEventListener(DropDownEvent.OPEN, dropDownController_openHandler);
        _dropDownController.addEventListener(DropDownEvent.CLOSE, dropDownController_closeHandler);
            
        _dropDownController.rollOverOpenDelay = getStyle("rollOverOpenDelay");
            
        if (muteButton)
            _dropDownController.openButton = muteButton;
        if (dropDown)
            _dropDownController.dropDown = dropDown;    
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
    //  isDropDownOpen
    //----------------------------------
    
    /**
     *  @copy spark.components.supportClasses.DropDownController#isOpen
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get isDropDownOpen():Boolean
    {
        if (dropDownController)
            return dropDownController.isOpen;
        else
            return false;
    }
    
    //----------------------------------
    //  muted
    //----------------------------------
    
    /**
     *  @private
     */
    private var _muted:Boolean = false;
    
    [Bindable("mutedChanged")]
    
    /**
     *  <code>true</code> if the volume of the video is muted; 
     *  <code>false</code> otherwise.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get muted():Boolean
    {
        return _muted;
    }
    
    /**
     *  @private
     */
    public function set muted(value:Boolean):void
    {
        if (_muted == value)
            return;
        
        _muted = value;
        
        if (muteButton)
            muteButton.muted = value;
        
        dispatchEvent(new Event("mutedChanged"));
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
            muteButton.volume = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------   
    
    /**
     *  @private
     */
     override public function styleChanged(styleProp:String):void
     {
         super.styleChanged(styleProp);
         var allStyles:Boolean = (styleProp == null || styleProp == "styleName");
         
         if (allStyles || styleProp == "rollOverOpenDelay")
         {
             if (dropDownController)
                dropDownController.rollOverOpenDelay = getStyle("rollOverOpenDelay");
         }
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
            muteButton.volume = value;
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
     *  @param commit Flag indicating if the component should commit the selected
     *  data from the dropDown. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function closeDropDown(commit:Boolean):void
    {
        dropDownController.closeDropDown(commit);
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
                dropDownController.openButton = muteButton;
            
            muteButton.addEventListener(FlexEvent.MUTED_CHANGE, muteButton_mutedChangeHandler);
            muteButton.volume = value;
            muteButton.muted = muted;
        }
        
        if (instance == dropDown && dropDownController)
            dropDownController.dropDown = dropDown;
    }
    
    private function muteButton_mutedChangeHandler(event:FlexEvent):void
    {
        muted = muteButton.muted;
        dispatchEvent(event);
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == muteButton)
        {
            muteButton.removeEventListener(FlexEvent.MUTED_CHANGE, muteButton_mutedChangeHandler);
        }
        
        if (instance == dropDownController)
        {
            if (instance == muteButton)
                dropDownController.openButton = null;
        
            if (instance == dropDown)
                dropDownController.dropDown = null;
        }
         
        super.partRemoved(partName, instance);
    }
    
    /**
     *  @private
     *  On focus, pop open the drop down and validate everything so 
     *  we can draw focus on one of the drop-down parts (the thumb)
     */
    override public function setFocus():void
    {
        openDropDown();
        LayoutManager.getInstance().validateNow();
        super.setFocus();
    }
    
    /**
     *  @private
     */
    override protected function focusOutHandler(event:FocusEvent):void
    {
        dropDownController.processFocusOut(event);

        super.focusOutHandler(event);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handling
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Event handler for the <code>dropDownController</code> 
     *  <code>DropDownEvent.OPEN</code> event. Updates the skin's state and 
     *  ensures that the selectedItem is visible. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    mx_internal function dropDownController_openHandler(event:DropDownEvent):void
    {
        invalidateSkinState();
        
        dispatchEvent(event);
    }
    
    /**
     *  Event handler for the <code>dropDownController</code> 
     *  <code>DropDownEvent.CLOSE</code> event. Updates the skin's state.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    mx_internal function dropDownController_closeHandler(event:DropDownEvent):void
    {
        invalidateSkinState();
        
        // FIXME (rfrishbe): Add logic to handle commitData
        //if (event.isDefaultPrevented())
        
        dispatchEvent(event);
    }

}
}
