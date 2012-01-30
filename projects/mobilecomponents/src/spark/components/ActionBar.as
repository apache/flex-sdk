////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.utils.BitFlagUtil;

import spark.components.supportClasses.SkinnableComponent;
import spark.core.IDisplayText;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="backgroundAlpha", type="Number", inherit="no")]


/**
 *  The ActionBar class defines a component that includes title, navigation 
 *  and action content groups. In the context of a ViewNavigator and
 *  MobileApplication, the ActionBar is used as application chrome which
 *  is has content contributed by the active View. ActionBar has limited
 *  utility when used otherwise.
 *
 *  @mxml
 *  
 *  <p>The <code>&lt;s:ActionBar&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;s:ActionBar
 *   <strong>Properties</strong>
 *    title=""
 *    titleContent="null"
 *    titleLayout="HorizontalLayout"
 *    navigationContent="null"
 *    navigationLayout="HorizontalLayout"
 *    actionContent="null"
 *    actionLayout="HorizontalLayout"
 * 
 *   <strong>Styles</strong>
 *    backgroundAlpha="1.0"
 * 
 *  &lt;
 *  </pre>
 *
 *  @see SkinnableComponent
 *  @see ViewNavigator
 *  @see View
 *  @see MobileApplication
 *  @see spark.skins.mobile.ActionBarSkin
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class ActionBar extends SkinnableComponent
{
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    mx_internal static const CONTENT_PROPERTY_FLAG:uint = 1 << 0;
    
    /**
     *  @private
     */
    mx_internal static const LAYOUT_PROPERTY_FLAG:uint = 1 << 1;
    
    /**
     *  @private
     */
    mx_internal static const NAVIGATION_GROUP_PROPERTIES_INDEX:uint = 0;
    
    /**
     *  @private
     */
    mx_internal static const TITLE_GROUP_PROPERTIES_INDEX:uint = 1;
    
    /**
     *  @private
     */
    mx_internal static const ACTION_GROUP_PROPERTIES_INDEX:uint = 2
    
    /**
     *  @private
     */
    mx_internal var contentGroupProperties:Array = [{}, {}, {}];
    
    /**
     * Cache original skin layouts
     * @private
     */
    mx_internal var contentGroupLayouts:Array = [null, null, null];
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function ActionBar()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts 
    //
    //--------------------------------------------------------------------------
    
    [SkinPart(required="false")]
    
    /**
     *  The skin part that defines the appearance of the 
     *  navigation area of the component.
     *  By default, the ActionBarSkin class defines the navigation area to appear 
     *  to the left of the title area.
     *
     *  @see spark.skins.mobile.ActionBarSkin
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var navigationGroup:Group;
    
    [SkinPart(required="false")]
    
    /**
     *  The skin part that defines the appearance of the 
     *  title area of the component.
     *  By default, the ActionBarSkin class defines the title area to appear 
     *  between the navigation and action areas.
     *
     *  @see spark.skins.mobile.ActionBarSkin
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var titleGroup:Group;
    
    [SkinPart(required="false")]
    
    /**
     *  The skin part that defines the appearance of the 
     *  action area of the component.
     *  By default, the ActionBarSkin class defines the action area to appear 
     *  to the right of the title area.
     *
     *  @see spark.skins.mobile.ActionBarSkin
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var actionGroup:Group;
    
    [SkinPart(required="false")]
    
    /**
     *  The skin part that defines the appearance of the 
     *  title text in the component.
     *
     *  @see spark.skins.mobile.ActionBarSkin
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4
     */
    public var titleDisplay:IDisplayText;
    
    //----------------------------------
    //  title
    //----------------------------------
    
    private var _title:String = "";
    
    [Bindable]
    
    /**
     *  Title or caption displayed in the title area. 
     *
     *  @default ""
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
        if (value == _title)
            return;
        
        _title = value;
        
        if (titleDisplay)
            titleDisplay.text = title;
    }
    
    
    //----------------------------------
    //  navigationContent
    //---------------------------------- 
    
    [ArrayElementType("mx.core.IVisualElement")]
    
    /**
     *  The set of components to include in the navigationGroup of the
     *  ActionBar. The location and appearance of the navigationGroup of the
     *  ActionBar container is determined by the
     *  spark.skins.mobile.ActionBarSkin.
     *  The default ActionBarSkin class defines the navigationGroup to appear
     *  to the left of the title display area of the ActionBar.
     *  Create a custom skin to change the default location and appearance of
     *  the navigationGroup.
     *  
     *  @default null
     *
     *  @see spark.skins.mobile.ActionBarSkin
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get navigationContent():Array
    {
        if (navigationGroup)
            return navigationGroup.getMXMLContent();
        else
            return contentGroupProperties[NAVIGATION_GROUP_PROPERTIES_INDEX].content
    }
    
    /**
     *  @private
     */
    public function set navigationContent(value:Array):void
    {
        if (navigationGroup)
        {
            navigationGroup.mxmlContent = value;
            contentGroupProperties[NAVIGATION_GROUP_PROPERTIES_INDEX] = 
                BitFlagUtil.update(contentGroupProperties[NAVIGATION_GROUP_PROPERTIES_INDEX] as uint,
                    CONTENT_PROPERTY_FLAG, value != null);
        }
        else
            contentGroupProperties[NAVIGATION_GROUP_PROPERTIES_INDEX].content = value;
        
        invalidateSkinState();
    }
    
    //----------------------------------
    //  navigationLayout
    //---------------------------------- 
    
    /**
     *  Defines the layout of the navigationGroup.
     *
     *  @default HorizontalLayout
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get navigationLayout():LayoutBase
    {
        if (navigationGroup)
            return navigationGroup.layout;
        else
            return contentGroupProperties[NAVIGATION_GROUP_PROPERTIES_INDEX].layout;
    }
    
    /**
     *  @private
     */
    public function set navigationLayout(value:LayoutBase):void
    {
        if (navigationGroup)
        {
            navigationGroup.layout = (value) ? value : contentGroupLayouts[NAVIGATION_GROUP_PROPERTIES_INDEX];
            contentGroupProperties[NAVIGATION_GROUP_PROPERTIES_INDEX] =
                BitFlagUtil.update(contentGroupProperties[NAVIGATION_GROUP_PROPERTIES_INDEX] as uint, 
                    LAYOUT_PROPERTY_FLAG, true);
        }
        else
            contentGroupProperties[NAVIGATION_GROUP_PROPERTIES_INDEX].layout = value;
    }
    
    //----------------------------------
    //  titleContent
    //---------------------------------- 
    
    [ArrayElementType("mx.core.IVisualElement")]
    
    /**
     *  The set of components to include in the titleGroup of the
     *  ActionBar. If titleContent is not null, it's visual elements replace
     *  the mxmlContent of titleGroup. If titleContent is null, the
     *  titleDisplay skin part, if present, replaces the mxmlContent of
     *  titleGroup.
     *  The location and appearance of the titleGroup of the ActionBar
     *  container is determined by the spark.skins.mobile.ActionBarSkin class.
     *  By default, the ActionBarSkin class defines the titleGroup to appear in
     *  the center of the ActionBar.
     *  Create a custom skin to change the default location and appearance of the titleGroup.
     *  
     *  @default null
     *
     *  @see spark.skins.mobile.ActionBarSkin
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get titleContent():Array
    {
        if (titleGroup)
			return titleGroup.getMXMLContent();
        else
            return contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX].content;
    }
    
    /**
     *  @private
     */
    public function set titleContent(value:Array):void
    {
        if (titleGroup)
        {
            titleGroup.mxmlContent = value;
            contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX] = 
                BitFlagUtil.update(contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX] as uint,
                    CONTENT_PROPERTY_FLAG, value != null);
        }
        else
        {
            contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX].content = value;
        }
        
        invalidateSkinState();
    }
    
    //----------------------------------
    //  titleLayout
    //---------------------------------- 
    
    /**
     *  Defines the layout of the titleGroup.
     *
     *  @default HorizontalLayout
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get titleLayout():LayoutBase
    {
        if (titleGroup)
            return titleGroup.layout;
        else
            return contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX].layout;
    }
    
    /**
     *  @private
     */
    public function set titleLayout(value:LayoutBase):void
    {
        if (titleGroup)
        {
            titleGroup.layout = (value) ? value : contentGroupLayouts[TITLE_GROUP_PROPERTIES_INDEX];
            contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX] =
                BitFlagUtil.update(contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX] as uint, 
                    LAYOUT_PROPERTY_FLAG, true);
        }
        else
            contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX].layout = value;
    }
    
    //----------------------------------
    //  actionContent
    //---------------------------------- 
    
    [ArrayElementType("mx.core.IVisualElement")]
    
    /**
     *  The set of components to include in the actionGroup of the
     *  ActionBar. The location and appearance of the actionGroup of the
     *  ActionBar container is determined by the skin.
     *  The default ActionBarSkin class defines the actionGroup to appear
     *  to the right of the title display area of the ActionBar.
     *  Create a custom skin to change the default location and appearance of
     *  the actionGroup.
     *  
     *  @default null
     *
     *  @see spark.skins.mobile.ActionBarSkin
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get actionContent():Array
    {
        if (actionGroup)
            return actionGroup.getMXMLContent();
        else
            return contentGroupProperties[ACTION_GROUP_PROPERTIES_INDEX].content
    }
    
    /**
     *  @private
     */
    public function set actionContent(value:Array):void
    {
        if (actionGroup)
        {
            actionGroup.mxmlContent = value;
            contentGroupProperties[ACTION_GROUP_PROPERTIES_INDEX] = 
                BitFlagUtil.update(contentGroupProperties[ACTION_GROUP_PROPERTIES_INDEX] as uint,
                    CONTENT_PROPERTY_FLAG, value != null);
        }
        else
            contentGroupProperties[ACTION_GROUP_PROPERTIES_INDEX].content = value;
        
        invalidateSkinState();
    }
    
    //----------------------------------
    //  actionLayout
    //---------------------------------- 
    
    /**
     *  Defines the layout of the actionGroup.
     *
     *  @default HorizontalLayout
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get actionLayout():LayoutBase
    {
        if (actionGroup)
            return actionGroup.layout;
        else 
            return contentGroupProperties[ACTION_GROUP_PROPERTIES_INDEX].layout;
    }
    
    /**
     *  @private
     */
    public function set actionLayout(value:LayoutBase):void
    {
        if (actionGroup)
        {
            actionGroup.layout = (value) ? value : contentGroupLayouts[ACTION_GROUP_PROPERTIES_INDEX];
            contentGroupProperties[ACTION_GROUP_PROPERTIES_INDEX] =
                BitFlagUtil.update(contentGroupProperties[ACTION_GROUP_PROPERTIES_INDEX] as uint, 
                    LAYOUT_PROPERTY_FLAG, true);
        }
        else
            contentGroupProperties[ACTION_GROUP_PROPERTIES_INDEX].layout = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        var group:Group;
        var index:int = -1;
        
        // set ID for CSS selectors
        // (e.g. to style actionContent Buttons: s|ActionBar s|Group#actionGroup s|Button)
        if (instance == navigationGroup)
        {
            group = navigationGroup;
            index = NAVIGATION_GROUP_PROPERTIES_INDEX;
        }
        else if (instance == titleGroup)
        {
            group = titleGroup;
            index = TITLE_GROUP_PROPERTIES_INDEX;
        }
        else if (instance == actionGroup)
        {
            group = actionGroup;
            index = ACTION_GROUP_PROPERTIES_INDEX;
        }
        else if (instance == titleDisplay)
        {
            titleDisplay.text = title;
        }
        
        if (index > -1)
        {
            // cache original layout
            contentGroupLayouts[index] = group.layout;
            
            var newContentGroupProperties:uint = 0;
            
            if (contentGroupProperties[index].content !== undefined)
            {
                group.mxmlContent = contentGroupProperties[index].content;
                newContentGroupProperties = BitFlagUtil.update(newContentGroupProperties, 
                    CONTENT_PROPERTY_FLAG, true);
            }
            
            if (contentGroupProperties[index].layout !== undefined)
            {
                group.layout = contentGroupProperties[index].layout;
                newContentGroupProperties = BitFlagUtil.update(newContentGroupProperties, 
                    LAYOUT_PROPERTY_FLAG, true);
            }
            
            contentGroupProperties[index] = newContentGroupProperties;
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        var group:Group;
        var index:int = -1;
        
        if (instance == navigationGroup)
        {
            group = navigationGroup;
            index = NAVIGATION_GROUP_PROPERTIES_INDEX;
        }
        else if (instance == titleGroup)
        {
            group = titleGroup;
            index = TITLE_GROUP_PROPERTIES_INDEX;	
        }
        else if (instance == actionGroup)
        {
            group = actionGroup;
            index = ACTION_GROUP_PROPERTIES_INDEX;
        }
        
        if (index > -1)
        {
            var newContentGroupProperties:Object = {};
            
            if (BitFlagUtil.isSet(contentGroupProperties[index] as uint, CONTENT_PROPERTY_FLAG))
                newContentGroupProperties.content = group.getMXMLContent();
            
            if (BitFlagUtil.isSet(contentGroupProperties[index] as uint, LAYOUT_PROPERTY_FLAG))
                newContentGroupProperties.layout = group.layout;
            
            contentGroupProperties[index] = newContentGroupProperties;
            
            group.mxmlContent = null;
            group.layout = null;
        }
    }
}
}