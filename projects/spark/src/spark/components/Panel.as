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

import flash.display.Graphics;
import mx.core.mx_internal;
import mx.utils.BitFlagUtil;

import spark.components.supportClasses.TextBase;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  The alpha of the border for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderAlpha", type="Number", inherit="no", theme="spark")]

/**
 *  The color of the border for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderColor", type="uint", format="Color", inherit="no", theme="spark")]

/**
 *  Controls the visibility of the border for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderVisible", type="Boolean", inherit="no", theme="spark")]

/**
 *  The radius of the corners for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="cornerRadius", type="Number", format="Length", inherit="no", theme="spark")]

/**
 *  Controls the visibility of the drop shadow for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="dropShadowVisible", type="Boolean", inherit="no", theme="spark")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[AccessibilityClass(implementation="spark.accessibility.PanelAccImpl")]

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
 *    controlBarContent="null"
 *    controlBarLayout="HorizontalLayout"
 *    controlBarVisible="true"
 *    title=""
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
    mx_internal static const CONTROLBAR_PROPERTY_FLAG:uint = 1 << 0;

    /**
     *  @private
     */
    mx_internal static const LAYOUT_PROPERTY_FLAG:uint = 1 << 1;

    /**
     *  @private
     */
    mx_internal static const VISIBLE_PROPERTY_FLAG:uint = 1 << 2;

    //--------------------------------------------------------------------------
    //
    //  Class mixins
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Placeholder for mixin by PanelAccImpl.
     */
    mx_internal static var createAccessibilityImplementation:Function;

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

        // default skin uses graphical dropshadow which 
        // we don't want to be hittable
        mouseEnabled=false;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables 
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
    mx_internal var controlBarGroupProperties:Object = { visible: true };

    //--------------------------------------------------------------------------
    //
    //  Skin parts 
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  controlBarGroup
    //---------------------------------- 
    
    [SkinPart(required="false")]

    /**
     *  The skin part that defines the appearance of the 
     *  control bar area of the container.
     *  By default, the PanelSkin class defines the control bar area to appear at the bottom 
     *  of the content area of the Panel container with a grey background. 
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
    public var titleDisplay:TextBase;

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
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  controlBarContent
    //---------------------------------- 
    
    [ArrayElementType("mx.core.IVisualElement")]
    
    /**
     *  The set of components to include in the control bar area of the 
     *  Panel container. 
     *  The location and appearance of the control bar area of the Panel container 
     *  is determined by the spark.skins.spark.PanelSkin class. 
     *  By default, the PanelSkin class defines the control bar area to appear at the bottom 
     *  of the content area of the Panel container with a grey background. 
     *  Create a custom skin to change the default appearance of the control bar.
     *
     *  @default null
     *
     *  @see spark.skins.spark.PanelSkin
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get controlBarContent():Array
    {
        if (controlBarGroup)
            return controlBarGroup.getMXMLContent();
        else
            return controlBarGroupProperties.controlBarContent;
    }

    /**
     *  @private
     */
    public function set controlBarContent(value:Array):void
    {
        if (controlBarGroup)
        {
            controlBarGroup.mxmlContent = value;
            controlBarGroupProperties = BitFlagUtil.update(controlBarGroupProperties as uint, 
                                                        CONTROLBAR_PROPERTY_FLAG, value != null);
        }
        else
            controlBarGroupProperties.controlBarContent = value;

        invalidateSkinState();
    }

    //----------------------------------
    //  controlBarLayout
    //---------------------------------- 
    
    /**
     *  Defines the layout of the control bar area of the container.
     *
     *  @default HorizontalLayout
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

    /**
     *  @private
     */
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
    //  controlBarVisible
    //---------------------------------- 
    
    /**
     *  A flag that controls whether the controlBar is visible.
     *  The flag has no meaning if there is no controlBarContent.
     *  The Panel does not monitor the controlBarGroup so if some
     *  other code makes it invisible, the Panel may not update
     *  correctly
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get controlBarVisible():Boolean
    {
        return (controlBarGroup) 
            ? controlBarGroup.visible 
            : controlBarGroupProperties.visible;
    }

    /**
     *  @private
     */
    public function set controlBarVisible(value:Boolean):void
    {
        if (controlBarGroup)
        {
            controlBarGroup.visible = value;
            controlBarGroupProperties = BitFlagUtil.update(controlBarGroupProperties as uint, 
                                                        VISIBLE_PROPERTY_FLAG, value);
        }
        else
            controlBarGroupProperties.visible = value;

        invalidateSkinState();
        if (skin)
            skin.invalidateSize();
    }

    //----------------------------------
    //  title
    //----------------------------------

    /**
     *  @private
     */
    private var _title:String = "";
    
    /**
     *  @private
     */
    private var titleChanged:Boolean;

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
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function initializeAccessibility():void
    {
        if (Panel.createAccessibilityImplementation != null)
            Panel.createAccessibilityImplementation(this);
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // fixme (gosmith): this is not working to extend the height of the the titleDisplay
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        if (titleDisplay)
        {
            var g:Graphics = titleDisplay.graphics;
            g.clear();
            // Also draw an invisible unfilled rect whose height
            // is the height of the entire Panel, not just the headerHeight.
            // This is for accessibility; the titlebar of the Panel
            // has an AccessibilityImplementation (see PanelAccImpl)
            // which makes it act like a grouping (ROLE_SYSTEM_GROUPING)
            // for the controls inside the panel.
            // Drawing this rect makes the accLocation rect of the grouping
            // enclose the controls inside the grouping,
            // even though it is a sibling of them, not their parent.
            // (This is because the Player doesn't support Sprites
            // with AccessibilityImplementations inside other Sprites
            // with AccessibilityImplementations; the accessible objects
            // in a Flash SWF are a flat list, not a hierarchy.)
            // This rectangle must be unfilled because the titleBar is
            // actually on top of the content area and would otherwise
            // block mouse events to the controls in the Panel.
            g.lineStyle(0, 0x000000, 0);
            g.drawRect(0, 0, unscaledWidth, unscaledHeight);
        }
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

            if (controlBarGroupProperties.visible !== undefined)
            {
                controlBarGroup.visible = controlBarGroupProperties.visible;
                newControlBarGroupProperties = BitFlagUtil.update(newControlBarGroupProperties, 
                                                               VISIBLE_PROPERTY_FLAG, true);
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
            
            if (BitFlagUtil.isSet(controlBarGroupProperties as uint, VISIBLE_PROPERTY_FLAG))
                newControlBarGroupProperties.visible = controlBarGroup.visible;
            
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
            if (BitFlagUtil.isSet(controlBarGroupProperties as uint, CONTROLBAR_PROPERTY_FLAG) &&
                BitFlagUtil.isSet(controlBarGroupProperties as uint, VISIBLE_PROPERTY_FLAG))
                state += "WithControlBar";
        }
        else
        {
            if (controlBarGroupProperties.controlBarContent &&
                controlBarGroupProperties.visible)
                state += "WithControlBar";
        }

        return state;
    }
}

}
