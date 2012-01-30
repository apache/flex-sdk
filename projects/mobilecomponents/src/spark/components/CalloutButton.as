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
import mx.core.ClassFactory;
import mx.core.IFactory;
import mx.core.mx_internal;
import mx.utils.BitFlagUtil;

import spark.components.supportClasses.ButtonBase;
import spark.components.supportClasses.DropDownController;
import spark.core.ContainerDestructionPolicy;
import spark.events.DropDownEvent;
import spark.events.PopUpEvent;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

[Exclude(name="repeatDelay", kind="style")]
[Exclude(name="repeatInterval", kind="style")]

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
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */
[Event(name="close", type="spark.events.DropDownEvent")]

/**
 *  Dispatched when the user clicks the open button
 *  to display the drop-down.  
 *
 *  @eventType spark.events.DropDownEvent.OPEN
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */
[Event(name="open", type="spark.events.DropDownEvent")]

[DefaultProperty("calloutContent")]

/**
 *  The CalloutButton class is a drop down component that defines a button to
 *  open and close a pop-up Callout component. CalloutButton is a component
 *  whose layout and contents are proxied to the Callout when opened.
 *
 *  <p>When the callout list is open:</p>
 *  <ul>
 *    <li>Clicking the button closes the callout</li>
 *    <li>Clicking outside of the callout closes the callout.</li>
 *  </ul>
 *
 *  <p>The CalloutButton component has the following default characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>Wide enough to display the text label of the control</td>
 *        </tr>
 *        <tr>
 *           <td>Minimum size</td>
 *           <td>32 pixels wide and 43 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Maximum size</td>
 *           <td>10000 pixels wide and 10000 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Default skin class</td>
 *           <td>spark.skins.mobile.CalloutButtonSkin</td>
 *        </tr>
 *     </table>
 *
 *  @mxml
 *  
 *  <p>The <code>&lt;s:CalloutButton&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;s:CalloutButton
 *   <strong>Properties</strong>
 *    horizontalPosition="auto"
 *    verticalPosition="auto
 *    label=""
 *    calloutDestructionPolicy="auto"
 * 
 *   <strong>Events</strong>
 *    open="<i>No default</i>"
 *    close="<i>No default</i>"
 *      ...
 *      <i>child tags</i>
 *      ...
 *  &lt;/s:CalloutButton&gt;
 *  </pre>
 * 
 *  @see spark.components.Callout
 *  @see spark.components.Button
 *  @see spark.skins.mobile.CalloutButtonSkin
 *  @see spark.components.supportClasses.DropDownController
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */
public class CalloutButton extends Button
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    mx_internal static const CALLOUT_CONTENT_PROPERTY_FLAG:uint = 1 << 0;
    
    /**
     *  @private
     */
    mx_internal static const CALLOUT_LAYOUT_PROPERTY_FLAG:uint = 1 << 1;
    
    /**
     *  @private
     */
    mx_internal static const HORIZONTAL_POSITION_PROPERTY_FLAG:uint = 1 << 2;
    
    /**
     *  @private
     */
    mx_internal static const VERTICAL_POSITION_PROPERTY_FLAG:uint = 1 << 3;
    
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
     *  A skin part that defines the drop-down factory which creates a Callou
     *  instance.
     * 
     *  If <code>dropDown</code> is not defined on the skin, a  
     *  <code>ClassFactory</code> is created to generate a default Callout
     *  instance.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public var dropDown:IFactory;
    
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
     *  the callout or defaults of the callout) as those are values 
     *  we want to carry around if the callout changes (via a new skin). 
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
    //  calloutContent
    //---------------------------------- 
    
    [ArrayElementType("mx.core.IVisualElement")]
    
    /**
     *  The set of components to include in the Callout's content.
     *
     *  @default null
     *
     *  @see spark.components.Callout
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public function get calloutContent():Array
    {
        if (callout && callout.contentGroup)
            return callout.contentGroup.getMXMLContent();
        else
            return calloutProperties.calloutContent;
    }
    
    /**
     *  @private
     */
    public function set calloutContent(value:Array):void
    {
        if (callout)
        {
            callout.mxmlContent = value;
            calloutProperties = BitFlagUtil.update(calloutProperties as uint, 
                CALLOUT_CONTENT_PROPERTY_FLAG, value != null);
        }
        else
            calloutProperties.calloutContent = value;
    }
    
    //----------------------------------
    //  calloutLayout
    //---------------------------------- 
    
    /**
     *  Defines the layout of the Callout.
     *
     *  @default BasicLayout
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public function get calloutLayout():LayoutBase
    {
        return (callout)  ? callout.layout : calloutProperties.calloutLayout;
    }
    
    /**
     *  @private
     */
    public function set calloutLayout(value:LayoutBase):void
    {
        if (callout)
        {
            callout.layout = value;
            calloutProperties = BitFlagUtil.update(calloutProperties as uint, 
                CALLOUT_LAYOUT_PROPERTY_FLAG, true);
        }
        else
            calloutProperties.calloutLayout = value;
    }
    
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
     *  The Callout instance created after the <code>DropDownEvent.OPEN</code>
     *  is fired. The instance is created using the <code>dropDown</code>
     *  <code>IFactory</code> skin part.
     * 
     *  @see #calloutDestructionPolicy
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public function get callout():Callout
    {
        return _callout;
    }
    
    /**
     *  @private
     */
    mx_internal function setCallout(value:Callout):void
    {
        if (_callout == value)
            return;
        
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
        
        _dropDownController.closeOnResize = false;
        _dropDownController.addEventListener(DropDownEvent.OPEN, dropDownController_openHandler);
        _dropDownController.addEventListener(DropDownEvent.CLOSE, dropDownController_closeHandler);
        
        _dropDownController.openButton = this;
        
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
    //  calloutDestructionPolicy
    //----------------------------------
    
    private var _calloutDestructionPolicy:String = ContainerDestructionPolicy.AUTO;
    
    [Inspectable(category="General", enumeration="auto,never", defaultValue="auto")]
    
    /**
     *  Defines the destruction policy the callout button should use
     *  when the callout is closed. If set to "auto", the button will
     *  destroy the callout when it is closed.  If set to "never", the
     *  callout will be cached in memory.
     * 
     *  @default auto
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public function get calloutDestructionPolicy():String
    {
        return _calloutDestructionPolicy;
    }
    
    /**
     *  @private
     */
    public function set calloutDestructionPolicy(value:String):void
    {
        if (_calloutDestructionPolicy == value)
            return;
        
        _calloutDestructionPolicy = value;
        
        // destroy the callout immediately if currently closed
        if (!isDropDownOpen &&
            (calloutDestructionPolicy == ContainerDestructionPolicy.AUTO))
        {
            destroyCallout();
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    override protected function attachSkin():void
    {
        super.attachSkin();
        
        // create dropDown if it was not found in the skin
        if (!dropDown && !("dropDown" in skin))
            dropDown = new ClassFactory(Callout);
    }
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (partName == "dropDown")
        {
            // copy proxied values from calloutProperties (if set) to callout
            var newCalloutProperties:uint = 0;
            var calloutInstance:Callout = instance as Callout;
            
            if (calloutInstance && dropDownController)
            {
                calloutInstance.id = "callout";
                dropDownController.dropDown = calloutInstance;
                
                calloutInstance.addEventListener(PopUpEvent.OPEN, callout_openHandler);
                calloutInstance.addEventListener(PopUpEvent.CLOSE, callout_closeHandler);
                
                if (calloutProperties.calloutContent !== undefined)
                {
                    calloutInstance.mxmlContent = calloutProperties.calloutContent;
                    newCalloutProperties = BitFlagUtil.update(newCalloutProperties, 
                        CALLOUT_CONTENT_PROPERTY_FLAG, true);
                }
                
                if (calloutProperties.calloutLayout !== undefined)
                {
                    calloutInstance.layout = calloutProperties.calloutLayout;
                    newCalloutProperties = BitFlagUtil.update(newCalloutProperties, 
                        CALLOUT_LAYOUT_PROPERTY_FLAG, true);
                }
                
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
            }
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (dropDownController && (instance == callout))
        {
            dropDownController.dropDown = null;
        }
        
        if (partName == "dropDown")
        {
            callout.removeEventListener(PopUpEvent.OPEN, callout_openHandler);
            callout.removeEventListener(PopUpEvent.CLOSE, callout_closeHandler);
            
            // copy proxied values from callout (if explicitely set) to calloutProperties
            var newCalloutProperties:Object = {};
            
            if (BitFlagUtil.isSet(calloutProperties as uint, CALLOUT_CONTENT_PROPERTY_FLAG) &&
                (callout.contentGroup))
            {
                newCalloutProperties.calloutContent = callout.contentGroup.getMXMLContent();
                callout.contentGroup.mxmlContent = null;
            }
            
            if (BitFlagUtil.isSet(calloutProperties as uint, CALLOUT_LAYOUT_PROPERTY_FLAG))
            {
                newCalloutProperties.calloutLayout = callout.layout;
                callout.layout = null;
            }
            
            if (BitFlagUtil.isSet(calloutProperties as uint, HORIZONTAL_POSITION_PROPERTY_FLAG))
                newCalloutProperties.horizontalPosition = callout.horizontalPosition;
            
            if (BitFlagUtil.isSet(calloutProperties as uint, VERTICAL_POSITION_PROPERTY_FLAG))
                newCalloutProperties.verticalPosition = callout.verticalPosition;
            
            calloutProperties = newCalloutProperties;
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
    
    /**
     *  @private
     *  Destroys the callout 
     */
    private function destroyCallout():void
    {
        removeDynamicPartInstance("dropDown", callout);
        setCallout(null);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Event handler for the <code>dropDownController</code> 
     *  <code>DropDownEvent.OPEN</code> event. Creates and opens the Callout.
     */
    mx_internal function dropDownController_openHandler(event:DropDownEvent):void
    {
        if (!callout)
            setCallout(createDynamicPartInstance("dropDown") as Callout);
        
        if (callout)
            callout.open(this, false);
    }
    
    /**
     *  @private
     *  Event handler for the <code>dropDownController</code> 
     *  <code>DropDownEvent.CLOSE</code> event. Closes the Callout.
     */
    mx_internal function dropDownController_closeHandler(event:DropDownEvent):void
    {
        // If the callout was closed directly, then callout could already be
        // destroyed by calloutDestructionPolicy
        if (callout)
        {
            // TODO (jasonsj): close params?
            
            // Dispatch the close event after the callout's PopUpEvent.CLOSE fires
            callout.close();
        }
    }
    
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
        if (calloutDestructionPolicy == ContainerDestructionPolicy.AUTO)
            destroyCallout();
        
        dispatchEvent(new DropDownEvent(DropDownEvent.CLOSE));
    }
}
}