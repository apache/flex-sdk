////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{
import mx.core.IFactory;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.supportClasses.ButtonBase;
import spark.components.supportClasses.DropDownController;
import spark.events.DropDownEvent;
import spark.events.PopUpEvent;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/StyleableTextFieldTextStyles.as"

/**
 *  Class or instance to use as the icon for the openButton skin part.
 *  The icon can render from various graphical sources, including the following:  
 *  <ul>
 *   <li>A Bitmap or BitmapData instance.</li>
 *   <li>A class representing a subclass of DisplayObject. The BitmapFill 
 *       instantiates the class and creates a bitmap rendering of it.</li>
 *   <li>An instance of a DisplayObject. The BitmapFill copies it into a 
 *       Bitmap for filling.</li>
 *   <li>The name of an external image file. </li>
 *  </ul>
 * 
 *  @default null
 */
[Style(name="icon", type="Object", inherit="no")]

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the drop-down closes for any reason, such when 
 *  the user:
 *  <ul>
 *      <li>The drop-down is programmatically closed.</li>
 *      <li>Clicks outside of the drop-down.</li>
 *      <li>Clicks the open button while the drop-down is 
 *  displayed.</li>
 *  </ul>
 *
 *  @eventType spark.events.DropDownEvent.CLOSE
 */
[Event(name="close", type="spark.events.DropDownEvent")]

/**
 *  Dispatched when the user clicks the open button
 *  to display the drop-down.  
 *
 *  @eventType spark.events.DropDownEvent.OPEN
 */
[Event(name="open", type="spark.events.DropDownEvent")]

/**
 *  TODO (jasonsj): write class description
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */
public class CalloutButton extends SkinnableContainer
{
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     */
    public function CalloutButton()
    {
        super();
        
        dropDownController = new DropDownController();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts
    //
    //--------------------------------------------------------------------------
    
    [SkinPart(required="false")]
    
    /**
     *  A skin part that defines the drop-down area. When the DropDownPopUpAnchorContainer is open,
     *  clicking anywhere outside of the dropDown skin part closes the   
     *  drop-down. 
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public var dropDown:IFactory;
    
    [SkinPart(required="true")]
    
    /**
     *  A skin part that defines the anchor button.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public var openButton:ButtonBase;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    // TODO (jasonsj): proxy for Callout properties
    mx_internal var calloutProperties:Object = {};
    
    /**
     *  @private
     *  TODO (jasonsj): write description
     */
    private var currentDropDown:Callout;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  horizontalPosition
    //----------------------------------
    
    private var _horizontalPosition:String = CalloutPosition.AUTO;
    
    [Inspectable(category="General", enumeration="before,start,middle,end,after,auto", defaultValue="auto")]
    
    /**
     *  @copy spark.components.Callout#horizontalPosition
     */
    public function get horizontalPosition():String
    {
        // TODO 
        if (currentDropDown)
            return currentDropDown.horizontalPosition;
        
        return _horizontalPosition;
    }
    
    /**
     *  @private
     */
    public function set horizontalPosition(value:String):void
    {
        if (value == _horizontalPosition)
            return;
        
        _horizontalPosition = value;
        
        if (currentDropDown)
            currentDropDown.horizontalPosition = horizontalPosition;
    }
    
    //----------------------------------
    //  verticalPosition
    //----------------------------------
    
    private var _verticalPosition:String = CalloutPosition.AUTO;
    
    [Inspectable(category="General", enumeration="before,start,middle,end,after,auto", defaultValue="auto")]
    
    /**
     *  @copy spark.components.Callout#verticalPosition
     */
    public function get verticalPosition():String
    {
        if (currentDropDown)
            return currentDropDown.verticalPosition;
        
        return _verticalPosition;
    }
    
    /**
     *  @private
     */
    public function set verticalPosition(value:String):void
    {
        if (value == _verticalPosition)
            return;
        
        _verticalPosition = value;
        
        if (currentDropDown)
            currentDropDown.verticalPosition = verticalPosition;
    }
    
    //----------------------------------
    //  dropDownController
    //----------------------------------
    
    /**
     *  @private
     */
    private var _dropDownController:DropDownController; 
    
    /**
     *  Instance of the DropDownController class that handles all of the mouse, keyboard 
     *  and focus user interactions. 
     * 
     *  Flex calls the <code>initializeDropDownController()</code> method after 
     *  the DropDownController instance is created in the constructor.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected function get dropDownController():DropDownController
    {
        return _dropDownController;
    }
    
    /**
     *  @private
     */
    protected function set dropDownController(value:DropDownController):void
    {
        if (_dropDownController == value)
            return;
        
        _dropDownController = value;
        
        _dropDownController.addEventListener(DropDownEvent.OPEN, dropDownController_openHandler);
        _dropDownController.addEventListener(DropDownEvent.CLOSE, dropDownController_closeHandler);
        
        if (openButton)
            _dropDownController.openButton = openButton;
        if (currentDropDown)
            _dropDownController.dropDown = currentDropDown;    
    }
    
    //----------------------------------
    //  isDropDownOpen
    //----------------------------------
    
    /**
     *  @copy spark.components.supportClasses.DropDownController#isOpen
     */
    public function get isDropDownOpen():Boolean
    {
        if (dropDownController)
            return dropDownController.isOpen;
        else
            return false;
    }
    
    private var _label:String = "";
    
    /**
     *  Text to appear on the openButton skin part.
     *
     *  @default ""
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public function get label():String
    {
        return _label;
    }
    
    /**
     *  @private
     */
    public function set label(value:String):void
    {
        _label = value;
        
        if (openButton)
            openButton.label = label;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == openButton)
        {
            openButton.label = label;
            
            if (dropDownController)
                dropDownController.openButton = openButton;
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (dropDownController)
        {
            if (instance == openButton)
                dropDownController.openButton = null;
            
            if (instance == dropDown)
                dropDownController.dropDown = null;
        }
        
        super.partRemoved(partName, instance);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Initializes the dropDown and changes the skin state to open. 
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */ 
    public function openDropDown():void
    {
        dropDownController.openDropDown();
    }
    
    /**
     *  Changes the skin state to normal.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public function closeDropDown():void
    {
        // TODO (jasonsj): add commit param?
        dropDownController.closeDropDown(false);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Event handler for the <code>dropDownController</code> 
     *  <code>DropDownEvent.OPEN</code> event. Updates the skin's state and 
     *  ensures that the selectedItem is visible. 
     */
    mx_internal function dropDownController_openHandler(event:DropDownEvent):void
    {
        if (!currentDropDown)
        {
            currentDropDown = Callout(dropDown.newInstance());
            dropDownController.dropDown = currentDropDown;
            
            currentDropDown.addEventListener(PopUpEvent.OPEN, open_updateCompleteHandler);
            currentDropDown.addEventListener(PopUpEvent.CLOSE, close_updateCompleteHandler);
            
            // TODO (jasonsj): read proxied properties
            if (layout)
                currentDropDown.layout = layout;
            
            currentDropDown.mxmlContent = currentContentGroup.getMXMLContent();
        }
        
        // TODO (jasonsj): read proxied properties
        currentDropDown.horizontalPosition = _horizontalPosition;
        currentDropDown.verticalPosition = _verticalPosition;
        
        currentDropDown.open(openButton, false);
    }
    
    /**
     *  @private
     *  Event handler for the <code>dropDownController</code> 
     *  <code>DropDownEvent.CLOSE</code> event. Updates the skin's state.
     */
    mx_internal function dropDownController_closeHandler(event:DropDownEvent):void
    {
        dispatchEvent(new DropDownEvent(DropDownEvent.CLOSE));
        
        // TODO (jasonsj): close params?
        currentDropDown.close();
        
        // TODO (jasonsj): destroy and save properties in proxy Object?
    }
    
    /**
     *  @private
     */
    private function open_updateCompleteHandler(event:PopUpEvent):void
    {   
        currentDropDown.removeEventListener(PopUpEvent.OPEN, open_updateCompleteHandler);
        
        // FIXME (jasonsj): how to initialze pop-up contentGroup as a skin part in partAdded()?
        contentGroup = currentDropDown.contentGroup;
        
        dispatchEvent(new DropDownEvent(DropDownEvent.OPEN));
    }
    
    /**
     *  @private
     */
    private function close_updateCompleteHandler(event:PopUpEvent):void
    {   
        currentDropDown.removeEventListener(PopUpEvent.CLOSE, open_updateCompleteHandler);
        
        dispatchEvent(new DropDownEvent(DropDownEvent.CLOSE));
    }
}
}