////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{

import mx.core.mx_internal;
import mx.utils.BitFlagUtil;

import spark.primitives.supportClasses.TextGraphicElement;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

[IconFile("Panel.png")]

/**
 *  The Panel class defines a container that includes a title bar, 
 *  a caption, a border, and a content area for its children.
 *
 *  @mxml
 *  
 *  <p>The <code>&lt;s:Panel&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;s:Panel
 *   <strong>Properties</strong>
 *   title=""
 *   &gt;
 *      ...
 *      <i>child tags</i>
 *      ...
 *  &lt;/mx:Panel&gt;
 *  </pre>
 *
 *  @includeExample examples/PanelExample.mxml
 *
 *  @see SkinnableContainer
 *  @see spark.skins.spark.PanelSkin
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Panel extends SkinnableContainer
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private static const CONTROLS_PROPERTY_FLAG:uint = 1 << 0;

    /**
     *  @private
     */
    private static const LAYOUT_PROPERTY_FLAG:uint = 1 << 1;

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function Panel()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Several properties are proxied to controlGroup.  However, when controlGroup
     *  is not around, we need to store values set on SkinnableContainer.  This object 
     *  stores those values.  If controlGroup is around, the values are stored 
     *  on the controlGroup directly.  However, we need to know what values 
     *  have been set by the developer on the SkinnableContainer (versus set on 
     *  the controlGroup or defaults of the controlGroup) as those are values 
     *  we want to carry around if the controlGroup changes (via a new skin). 
     *  In order to store this info effeciently, controlGroupProperties becomes 
     *  a uint to store a series of BitFlags.  These bits represent whether a 
     *  property has been explicitely set on this SkinnableContainer.  When the 
     *  controlGroup is not around, controlGroupProperties is a typeless 
     *  object to store these proxied properties.  When controlGroup is around,
     *  controlGroupProperties stores booleans as to whether these properties 
     *  have been explicitely set or not.
     */
    private var controlGroupProperties:Object = {};

    //----------------------------------
    //  controlGroup
    //---------------------------------- 
    
    [SkinPart(required="false")]

    /**
     *  The skin part that defines the appearance of the 
     *  control bar in the container.
     *
     *  @see spark.skins.spark.PanelSkin
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var controlGroup:Group;

    //----------------------------------
    //  controls
    //---------------------------------- 
    
    [ArrayElementType("mx.core.IVisualElement")]
    
    /**
     *  The set of items that become the content of
     *  the controlGroup
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function set controls(value:Array):void
    {
        if (controlGroup)
        {
            controlGroup.mxmlContent = value;
            controlGroupProperties = BitFlagUtil.update(controlGroupProperties as uint, 
                                                        CONTROLS_PROPERTY_FLAG, true);
        }
        else
            controlGroupProperties.controls = value;
    }

    //----------------------------------
    //  controlLayout
    //---------------------------------- 
    
    /**
     *  An optional Layout assigned to the control bar.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get controlLayout():LayoutBase
    {
        return (controlGroup) 
            ? controlGroup.layout 
            : controlGroupProperties.layout;
    }

    public function set controlLayout(value:LayoutBase):void
    {
        if (controlGroup)
        {
            controlGroup.layout = value;
            controlGroupProperties = BitFlagUtil.update(controlGroupProperties as uint, 
                                                        LAYOUT_PROPERTY_FLAG, true);
        }
        else
            controlGroupProperties.layout = value;
    }

    //----------------------------------
    //  titleField
    //---------------------------------- 
    
    [SkinPart(required="false")]

    /**
     *  The skin part that defines the appearance of the 
     *  title text in the container.
     *
     *  @see spark.skins.spark.PanelSkin
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var titleDisplay:TextGraphicElement;

    //----------------------------------
    //  title
    //----------------------------------

    private var titleChanged:Boolean;

    private var _title:String = "";
    
    [Bindable]
    /**
     *  Title or caption displayed in the title bar. 
     *
     *  @default ""
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get title():String 
    {
        return _title;
    }

    /**
     *  @private
     */
    public function set title(value:String):void 
    {
        _title = value;

        if (titleDisplay)
            titleDisplay.text = title;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
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
        return getBaselinePositionForPart(titleDisplay);
    } 
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == titleDisplay)
        {
            titleDisplay.text = title;
        }
        else if (instance == controlGroup)
        {
            // copy proxied values from controlGroupProperties (if set) to contentGroup
            var newControlGroupProperties:uint = 0;
            
            if (controlGroupProperties.controls !== undefined)
            {
                controlGroup.mxmlContent = controlGroupProperties.controls;
                newControlGroupProperties = BitFlagUtil.update(newControlGroupProperties, 
                                                               CONTROLS_PROPERTY_FLAG, true);
            }

            if (controlGroupProperties.layout !== undefined)
            {
                controlGroup.layout = controlGroupProperties.layout;
                newControlGroupProperties = BitFlagUtil.update(newControlGroupProperties, 
                                                               LAYOUT_PROPERTY_FLAG, true);
            }

            controlGroupProperties = newControlGroupProperties;
        }
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);

        if (instance == controlGroup)
        {
            // copy proxied values from contentGroup (if explicitely set) to contentGroupProperties
            
            var newControlGroupProperties:Object = {};
            
            if (BitFlagUtil.isSet(controlGroupProperties as uint, CONTROLS_PROPERTY_FLAG))
                newControlGroupProperties.controls = controlGroup.getMXMLContent();
            
            if (BitFlagUtil.isSet(controlGroupProperties as uint, LAYOUT_PROPERTY_FLAG))
                newControlGroupProperties.layout = controlGroup.layout;
            
            controlGroupProperties = newControlGroupProperties;

            controlGroup.mxmlContent = null;
            controlGroup.layout = null;
        }
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function getCurrentSkinState():String
    {
        var state:String = enabled ? "normal" : "disabled";
        if (controlGroup)
        {
            if (BitFlagUtil.isSet(controlGroupProperties as uint, CONTROLS_PROPERTY_FLAG))
                state += "WithControls";
        }
        else
        {
            if (controlGroupProperties.controls)
                state += "WithControls";
        }

        return state;
    }
}

}
