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
    private static const CONTROLBAR_PROPERTY_FLAG:uint = 1 << 0;

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
     *  Several properties are proxied to controlBarGroup.  However, when controlBarGroup
     *  is not around, we need to store values set on SkinnableContainer.  This object 
     *  stores those values.  If controlBarGroup is around, the values are stored 
     *  on the controlBarGroup directly.  However, we need to know what values 
     *  have been set by the developer on the SkinnableContainer (versus set on 
     *  the controlBarGroup or defaults of the controlBarGroup) as those are values 
     *  we want to carry around if the controlBarGroup changes (via a new skin). 
     *  In order to store this info effeciently, controlBarGroupProperties becomes 
     *  a uint to store a series of BitFlags.  These bits represent whether a 
     *  property has been explicitely set on this SkinnableContainer.  When the 
     *  controlBarGroup is not around, controlBarGroupProperties is a typeless 
     *  object to store these proxied properties.  When controlBarGroup is around,
     *  controlBarGroupProperties stores booleans as to whether these properties 
     *  have been explicitely set or not.
     */
    private var controlBarGroupProperties:Object = {};

    //----------------------------------
    //  controlBarGroup
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
    public var controlBarGroup:Group;

    //----------------------------------
    //  controlBarContent
    //---------------------------------- 
    
    [ArrayElementType("mx.core.IVisualElement")]
    
    /**
     *  The set of items that become the content of
     *  the controlBarGroup
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function set controlBarContent(value:Array):void
    {
        if (controlBarGroup)
        {
            controlBarGroup.mxmlContent = value;
            controlBarGroupProperties = BitFlagUtil.update(controlBarGroupProperties as uint, 
                                                        CONTROLBAR_PROPERTY_FLAG, true);
        }
        else
            controlBarGroupProperties.controlBarContent = value;
    }

    //----------------------------------
    //  controlBarLayout
    //---------------------------------- 
    
    /**
     *  An optional Layout assigned to the control bar.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get controlBarLayout():LayoutBase
    {
        return (controlBarGroup) 
            ? controlBarGroup.layout 
            : controlBarGroupProperties.layout;
    }

    public function set controlBarLayout(value:LayoutBase):void
    {
        if (controlBarGroup)
        {
            controlBarGroup.layout = value;
            controlBarGroupProperties = BitFlagUtil.update(controlBarGroupProperties as uint, 
                                                        LAYOUT_PROPERTY_FLAG, true);
        }
        else
            controlBarGroupProperties.layout = value;
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
        else if (instance == controlBarGroup)
        {
            // copy proxied values from controlBarGroupProperties (if set) to contentGroup
            var newControlBarGroupProperties:uint = 0;
            
            if (controlBarGroupProperties.controlBarContent !== undefined)
            {
                controlBarGroup.mxmlContent = controlBarGroupProperties.controlBarContent;
                newControlBarGroupProperties = BitFlagUtil.update(newControlBarGroupProperties, 
                                                               CONTROLBAR_PROPERTY_FLAG, true);
            }

            if (controlBarGroupProperties.layout !== undefined)
            {
                controlBarGroup.layout = controlBarGroupProperties.layout;
                newControlBarGroupProperties = BitFlagUtil.update(newControlBarGroupProperties, 
                                                               LAYOUT_PROPERTY_FLAG, true);
            }

            controlBarGroupProperties = newControlBarGroupProperties;
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

        if (instance == controlBarGroup)
        {
            // copy proxied values from contentGroup (if explicitely set) to contentGroupProperties
            
            var newControlBarGroupProperties:Object = {};
            
            if (BitFlagUtil.isSet(controlBarGroupProperties as uint, CONTROLBAR_PROPERTY_FLAG))
                newControlBarGroupProperties.controlBarContent = controlBarGroup.getMXMLContent();
            
            if (BitFlagUtil.isSet(controlBarGroupProperties as uint, LAYOUT_PROPERTY_FLAG))
                newControlBarGroupProperties.layout = controlBarGroup.layout;
            
            controlBarGroupProperties = newControlBarGroupProperties;

            controlBarGroup.mxmlContent = null;
            controlBarGroup.layout = null;
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
        if (controlBarGroup)
        {
            if (BitFlagUtil.isSet(controlBarGroupProperties as uint, CONTROLBAR_PROPERTY_FLAG))
                state += "WithControlBar";
        }
        else
        {
            if (controlBarGroupProperties.controlBarContent)
                state += "WithControlBar";
        }

        return state;
    }
}

}
