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
import mx.utils.BitFlagUtil;

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
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    mx_internal static const HORIZONTAL_POSITION_PROPERTY_FLAG:uint = 1 << 0;
    
    /**
     *  @private
     */
    mx_internal static const VERTICAL_POSITION_PROPERTY_FLAG:uint = 1 << 1;
    
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
    
    /**
     *  @private
     *  Several properties are proxied to callout.  However, when callout
     *  is not around, we need to store values set on CalloutButton.  This object 
     *  stores those values.  If callout is around, the values are stored 
     *  on the callout directly.  However, we need to know what values 
     *  have been set by the developer on the CalloutButton (versus set on 
     *  the controlBarGroup or defaults of the controlBarGroup) as those are values 
     *  we want to carry around if the controlBarGroup changes (via a new skin). 
     *  In order to store this info effeciently, calloutProperties becomes 
     *  a uint to store a series of BitFlags.  These bits represent whether a 
     *  property has been explicitely set on this CalloutButton.  When the 
     *  callout is not around, calloutProperties is a typeless 
     *  object to store these proxied properties.  When callout is around,
     *  calloutProperties stores booleans as to whether these properties 
     *  have been explicitely set or not.
     */
    mx_internal var calloutProperties:Object = {};
    
    //--------------------------------------------------------------------------
    //
    //  Properties proxied to callout
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  horizontalPosition
    //----------------------------------
    
    [Inspectable(category="General", enumeration="before,start,middle,end,after,auto", defaultValue="auto")]
    
    /**
     *  @copy spark.components.Callout#horizontalPosition
     */
    public function get horizontalPosition():String
    {
        if (callout)
            return callout.horizontalPosition;
        
        return calloutProperties.horizontalPosition;
    }
    
    /**
     *  @private
     */
    public function set horizontalPosition(value:String):void
    {
        if (callout)
        {
            callout.horizontalPosition = value;
            calloutProperties = BitFlagUtil.update(calloutProperties as uint, 
                HORIZONTAL_POSITION_PROPERTY_FLAG, value != null);
        }
        else
            calloutProperties.horizontalPosition = value;
    }
    
    //----------------------------------
    //  verticalPosition
    //----------------------------------
    
    [Inspectable(category="General", enumeration="before,start,middle,end,after,auto", defaultValue="auto")]
    
    /**
     *  @copy spark.components.Callout#verticalPosition
     */
    public function get verticalPosition():String
    {
        if (callout)
            return callout.verticalPosition;
        
        return calloutProperties.verticalPosition;
    }
    
    /**
     *  @private
     */
    public function set verticalPosition(value:String):void
    {
        if (callout)
        {
            callout.verticalPosition = value;
            calloutProperties = BitFlagUtil.update(calloutProperties as uint, 
                VERTICAL_POSITION_PROPERTY_FLAG, value != null);
        }
        else
            calloutProperties.verticalPosition = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  callout
    //----------------------------------
    
    /**
     *  @private
     */
    private var _callout:Callout;
    
    /**
     *  TODO (jasonsj): PARB
     */
    mx_internal function get callout():Callout
    {
        return _callout;
    }
    
    /**
     *  TODO (jasonsj): PARB
     * 
     *  Allow users to set their own Callout instead of the one defined by the
     *  skin. This allows properties and styles to be set in MXML instead of
     *  either passthrough styles in CalloutButton or CSS styles. 
     * 
     *  The getter allows direct access to the callout. Unlike DropDownList,
     *  CalloutButton's dropDown skin part is a class factory and not the
     *  Callout instance.
     */
    mx_internal function set callout(value:Callout):void
    {
        if (_callout == value)
            return;
        
        if (_callout && _callout.isOpen)
        {
            // TODO (jasonsj): cleanup?
            _callout.close();
        }
        
        // FIXME (jasonsj): re-init
        _callout = value;
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
        if (callout)
            _dropDownController.dropDown = callout;    
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
    
    //----------------------------------
    //  label
    //----------------------------------
    
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
        else if (partName == "dropDown")
        {
            // copy proxied values from calloutProperties (if set) to callout
            var newCalloutProperties:uint = 0;
            var calloutInstance:Callout = instance as Callout;
            
            if (calloutInstance && dropDownController)
            {
                calloutInstance.id = "callout";
                dropDownController.dropDown = calloutInstance;
                
//                calloutInstance.addEventListener(FlexEvent.CREATION_COMPLETE, callout_creationCompleteHandler);
                calloutInstance.addEventListener(PopUpEvent.OPEN, callout_openHandler);
                calloutInstance.addEventListener(PopUpEvent.CLOSE, callout_closeHandler);
                
                if (calloutProperties.horizontalPosition !== undefined)
                {
                    calloutInstance.horizontalPosition = calloutProperties.horizontalPosition;
                    newCalloutProperties = BitFlagUtil.update(newCalloutProperties, 
                        HORIZONTAL_POSITION_PROPERTY_FLAG, true);
                }
                
                if (calloutProperties.verticalPosition !== undefined)
                {
                    calloutInstance.verticalPosition = calloutProperties.verticalPosition;
                    newCalloutProperties = BitFlagUtil.update(newCalloutProperties, 
                        VERTICAL_POSITION_PROPERTY_FLAG, true);
                }
                
                calloutProperties = newCalloutProperties;
                
                // FIXME (jasonsj): find a correct way to initialize the contentGroup
                if (layout)
                    calloutInstance.layout = layout;
                
                calloutInstance.mxmlContent = currentContentGroup.getMXMLContent();
            }
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
            
            if (instance == callout)
                dropDownController.dropDown = null;
        }
        
        // TODO (jasonsj): destroy option?
//        if (instance == callout)
//        {
//            callout.removeEventListener(FlexEvent.CREATION_COMPLETE, callout_creationCompleteHandler);
//            callout.removeEventListener(PopUpEvent.OPEN, callout_openHandler);
//            callout.removeEventListener(PopUpEvent.CLOSE, callout_closeHandler);
//            
//            // copy proxied values from callout (if explicitely set) to calloutProperties
//            var newCalloutProperties:Object = {};
//            
//            if (BitFlagUtil.isSet(calloutProperties as uint, HORIZONTAL_POSITION_PROPERTY_FLAG))
//                newCalloutProperties.calloutProperties = callout.horizontalPosition;
//            
//            if (BitFlagUtil.isSet(calloutProperties as uint, VERTICAL_POSITION_PROPERTY_FLAG))
//                newCalloutProperties.verticalPosition = callout.verticalPosition;
//            
//            calloutProperties = newCalloutProperties;
//            
//            super.partRemoved("contentGroup", callout.contentGroup);
//            contentGroup = null;
//        }
        
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
        // TODO (jasonsj): destroy?
        if (!callout)
            callout = createDynamicPartInstance("dropDown") as Callout;
        
        if (callout)
            callout.open(this, false);
    }
    
    /**
     *  @private
     *  Event handler for the <code>dropDownController</code> 
     *  <code>DropDownEvent.CLOSE</code> event. Updates the skin's state.
     */
    mx_internal function dropDownController_closeHandler(event:DropDownEvent):void
    {
        // TODO (jasonsj): close params?
        // dispatch the close event after the callout's PopUpEvent.CLOSE fires
        callout.close();
        
        // TODO (jasonsj): destroy option?
//        removeDynamicPartInstance("dropDown", callout);
//        callout = null;
    }
    
//    private function callout_creationCompleteHandler(event:FlexEvent):void
//    {
//        // initialize contentGroup skin part
//        contentGroup = callout.contentGroup;
//        partAdded("contentGroup", callout.contentGroup);
//    }
    
    /**
     *  @private
     */
    private function callout_openHandler(event:PopUpEvent):void
    {
        dispatchEvent(new DropDownEvent(DropDownEvent.OPEN));
    }
    
    /**
     *  @private
     */
    private function callout_closeHandler(event:PopUpEvent):void
    {   
        dispatchEvent(new DropDownEvent(DropDownEvent.CLOSE));
    }
}
}