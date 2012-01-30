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

include "../styles/metadata/StyleableTextFieldTextStyles.as"

/**
 *  Alignment of the title relative to the ActionBar dimensions.
 *  Possible values are <code>"left"</code>, <code>"right"</code>,
 *  and <code>"center"</code>.
 * 
 *  @default "center"
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="titleAlign", type="String", enumeration="left,right,center", inherit="no", theme="mobile")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:accentColor
 * 
 *  @default 0x0099FF
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="accentColor", type="uint", format="Color", inherit="yes", theme="mobile")]

/**
 *  @copy spark.components.SkinnableContainer#style:backgroundAlpha
 *  
 *  @default 1.0
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="backgroundAlpha", type="Number", inherit="no", theme="mobile", minValue="0.0", maxValue="1.0")]

/**
 *  @copy spark.components.SkinnableContainer#style:contentBackgroundAlpha
 *
 *  @default 1.0
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="contentBackgroundAlpha", type="Number", inherit="yes", theme="mobile")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:contentBackgroundColor
 *
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes", theme="mobile")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:focusColor
 *
 *  @default 0x70B2EE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="mobile")]

/**
 *  Number of pixels between the bottom border and all content groups.
 * 
 *  @default 0
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]

/**
 *  Number of pixels between the left border and the navigationGroup.
 * 
 *  @default 0
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="paddingLeft", type="Number", format="Length", inherit="no")]

/**
 *  Number of pixels between the left border and the actionGroup.
 * 
 *  @default 0
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="paddingRight", type="Number", format="Length", inherit="no")]

/**
 *  Number of pixels between the top border and all content groups.
 * 
 *  @default 0
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="paddingTop", type="Number", format="Length", inherit="no")]

/**
 *  Color of text shadows.
 * 
 *  @default 0xFFFFFF
 * 
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="textShadowColor", type="uint", format="Color", inherit="yes", theme="mobile")]

/**
 *  Alpha of text shadows.
 * 
 *  @default 0.55
 * 
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="textShadowAlpha", type="Number",inherit="yes", minValue="0.0", maxValue="1.0", theme="mobile")]

/**
 *  Appearance of buttons in navigation and action groups.
 *  Valid MXML values are <code>normal</code> and <code>beveled</code>
 *
 *  <p>In ActionScript, you can use the following constants
 *  to set this property:
 *  <code>ActionBarDefaultButtonAppearance.NORMAL</code> and
 *  <code>ActionBarDefaultButtonAppearance.BEVELED</code>.</p>
 *
 *  @default ActionBarDefaultButtonAppearance.NORMAL
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="defaultButtonAppearance", type="String", enumeration="normal,beveled", inherit="no", theme="mobile")]

//--------------------------------------
//  Skin states
//--------------------------------------

/**
 *  Base state of ActionBar with the <code>titleDisplay</code> 
 *  skin part and no content
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[SkinState("title")]

/**
 *  ActionBar with content defined for the <code>titleDisplay</code> 
 *  skin part, and components defined in the <code>actionContent</code> 
 *  property for display in the <code>actionGroup</code> skin part.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[SkinState("titleWithAction")]

/**
 *  ActionBar with content defined for the <code>titleDisplay</code> 
 *  skin part, and components defined in the <code>navigationContent</code> 
 *  property for display in the <code>navigationGroup</code> skin part.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[SkinState("titleWithNavigation")]

/**
 *  ActionBar with content defined for the <code>titleDisplay</code> 
 *  skin part, and components for display in 
 *  the <code>actionGroup</code> skin part and in 
 *  the <code>navigationGroup</code> skin part.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[SkinState("titleWithActionAndNavigation")]

/**
 *  ActionBar with content in the <code>titleContent</code>
 *  skin part, but not in the <code>titleDisplay</code> skin part.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[SkinState("titleContent")]

/**
 *  ActionBar with content in the <code>titleContent</code>
 *  skin part, and components defined in the <code>actionContent</code> 
 *  property for display in the <code>actionGroup</code> skin part.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[SkinState("titleContentWithAction")]


/**
 *  ActionBar with content in the <code>titleContent</code>
 *  skin part, and components defined in the <code>navigationContent</code> 
 *  property for display in the <code>navigationGroup</code> skin part.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[SkinState("titleContentWithNavigation")]

/**
 *  ActionBar with content defined for the <code>titleContent</code> 
 *  skin part, and components for display in 
 *  the <code>actionGroup</code> skin part and in 
 *  the <code>navigationGroup</code> skin part.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[SkinState("titleContentWithActionAndNavigation")]

/**
 *  The ActionBar class defines a component that includes title, navigation, 
 *  and action content groups. 
 *  The ActionBar control provides a standard area for navigation and action controls. 
 *  It lets you define global controls that can be used from anywhere in the application, 
 *  or controls specific to a view. 
 *
 *  <p>The ActionBar control defines three distinct areas: </p>
 *
 *  <ul>
 *    <li>Navigation area
 *        <p>Contains components that let the user navigate the section. 
 *         For example, you can define a home button in the navigation area. 
 *         Use the <code>navigationContent</code> property to define 
 *         the components that appear in the navigation area. 
 *         Use the <code>navigationLayout</code> property to define 
 *         the layout of the navigation area. </p></li>
 *     <li>Title area
 *         <p>Contains either a String containing title text, or components. 
 *         If you specify components, you cannot specify a title String. 
 *         Use the <code>title</code> property to specify the String to appear in 
 *         the title area. 
 *         Use the <code>titleContent</code> property to define the 
 *         components that appear in the title area. 
 *         Use the <code>titleLayout</code> property to define the 
 *         layout of the title area. 
 *         If you specify a value for the <code>titleContent</code> property, 
 *         the ActionBar skin ignores the <code>title</code> property.</p></li> 
 *      <li>Action area 
 *         <p>Contains components that define actions the user can take in a view. 
 *         For example, you might define a search or refresh button as part of 
 *         the action area. 
 *         Use the <code>actionContent</code> property to define the components 
 *         that appear in the action area. 
 *         Use the <code>actionLayout</code> property to define the layout 
 *         of the action area.</p></li>
 *  </ul>
 *
 *  <p>The following image shows the ActionBar with a home button in the navigation area, 
 *  a text input control in the title area, and a search button in the action area:</p>
 *
 * <p>
 *  <img src="../../images/ab_search_override_ab.png" alt="Action Bar" />
 * </p>
 *
 *  <p>For a mobile application with a single section, meaning a single  
 *  ViewNavigator container, all views share the same action bar. 
 *  For a mobile application with multiple sections, meaning one with multiple 
 *  ViewNavigator containers, each section defines its own action bar.</p>
 *
 *  @mxml
 *  
 *  <p>The <code>&lt;s:ActionBar&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;s:ActionBar
 *   <strong>Properties</strong>
 *    actionContent="null"
 *    actionLayout="HorizontalLayout"
 *    navigationContent="null"
 *    navigationLayout="HorizontalLayout"
 *    title=""
 *    titleContent="null"
 *    titleLayout="HorizontalLayout"
 * 
 *   <strong>Common Styles</strong>
 *    color="<i>Theme dependent</i>"
 *    fontFamily="<i>Theme dependent</i>"
 *    fontSize="<i>Theme dependent</i>"
 *    fontStyle="normal"
 *    fontWeight="normal"
 *    leading="0"
 *    letterSpacing="0"
 *    textAlign="center"
 *    textDecoration="none"
 *    textIndent="0"
 * 
 *   <strong>Mobile Styles</strong>
 *    accentColor="0x0099FF"
 *    backgroundAlpha="1.0"
 *    color="<i>Theme dependent</i>"
 *    contentBackgroundAlpha="1.0"
 *    contentBackgroundColor="0xFFFFFF"
 *    focusColor="0x70B2EE"
 *    textShadowAlpha="0.55"
 *    textShadowColor="0xFFFFFF"
 *    titleAlign="center"
 * 
 *  &gt;
 *  </pre>
 *
 *  @see spark.components.SkinnableContainer    
 *  @see ViewNavigator
 *  @see View
 *  @see ViewNavigatorApplication
 *  @see spark.skins.mobile.ActionBarSkin
 *
 *  @includeExample examples/ActionBarExample2.mxml -noswf
 *  @includeExample examples/ActionBarExample3.mxml -noswf
 *  @includeExample examples/ActionBarExampleHomeView.mxml -noswf
 *  
 *  @langversion 3.0
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
     *  Constructor.
     *  
     *  @langversion 3.0
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
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var actionGroup:Group;
    
    [SkinPart(required="false")]
    
    /**
     *  The skin part that defines the appearance of the 
     *  title text in the component.
     * 
     *  You can use CSS to declare styles on the ActionBar's titleDisplay skin part, as the following example shows:
     *  
     *  <pre>
     *  &#64;namespace s "library://ns.adobe.com/flex/spark"; 
     *  s|ActionBar #titleDisplay { 
     *     color:red; 
     *  }
     * </pre>
     * 
     *  @see spark.skins.mobile.ActionBarSkin
     *  
     *  @langversion 3.0
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
     *  <p>Use the <code>titleContent</code> property to define 
     *  the components that appear in the title area. 
     *  If you specify a value for the <code>titleContent</code> property, 
     *  the ActionBar skin ignores the <code>title</code> property.</p>
     *
     *  @default ""
     *
     *  @see #titleContent
     * 
     *  @langversion 3.0
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
        
        invalidateSkinState();
    }
    
    
    //----------------------------------
    //  navigationContent
    //---------------------------------- 
    
    [ArrayElementType("mx.core.IVisualElement")]
    
    /**
     *  The components that define navigation for the user. 
     *  These components appear in the navigation area of the control,  
     *  in the <code>navigationGroup</code> skin part. 
     *
     *  <p>The location and appearance of the <code>navigationGroup</code> 
     *  skin part is determined by the ActionBarSkin class.
     *  The default ActionBarSkin class defines the <code>navigationGroup</code>
     *  to appear to the left of the <code>titleGroup</code> area of the ActionBar.</p>
     * 
     *  <p>Create a custom ActionBarSkin skin class to change the default location 
     *  and appearance of the <code>navigationGroup</code> skin part.</p>
     *  
     *  @default null
     *
     *  @see spark.skins.mobile.ActionBarSkin
     *  @see #navigationLayout
     *  
     *  @langversion 3.0
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
     *  Defines the layout of the components contained in 
     *  the <code>navigationGroup</code> skin part.
     *
     *  @default HorizontalLayout
     *
     *  @see #navigationContent
     *  
     *  @langversion 3.0
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
     *  The components that appear in the title area of the control. 
     *  These components appear in the <code>titleGroup</code> 
     *  skin part of the ActionBar control.
     *
     *  <p>The location and appearance of the <code>titleGroup</code> 
     *  skin part is determined by the ActionBarSkin class.
     *  The default ActionBarSkin class defines the <code>titleGroup</code>
     *  to appear in the center of the ActionBar,
     *  using the space remaining between <code>navigationGroup</code> 
     *  and <code>actionGroup</code> skin parts.</p>
     * 
     *  <p>If <code>titleContent</code> is null, the
     *  <code>titleDisplay</code> skin part, if present, is displayed 
     *  in place of the <code>titleGroup</code> skin part.</p> 
     * 
     *  <p>Create a custom ActionBarSkin skin class to change the default 
     *  location and appearance of the <code>titleGroup</code> skin part.</p>
     *  
     *  @default null
     *
     *  @see spark.skins.mobile.ActionBarSkin
     *  @see #title
     *  @see #titleLayout
     * 
     *  @langversion 3.0
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
     *  Defines the layout of the <code>titleGroup</code> 
     *  and <code>titleDisplay</code> skin parts.
     * 
     *  <p>If the <code>titleContent</code> property is null, 
     *  the <code>titleDisplay</code> skin part is displayed  
     *  in place of the <code>titleGroup</code> skin part. 
     *  The <code>titleDisplay</code> skin part is positioned 
     *  in the center of the ActionBar control
     *  by using the <code>paddingLeft</code> and 
     *  <code>paddingRight</code> properties  of the layout 
     *  class specified by the <code>titleLayout</code> property.</p>
     *
     *  @default HorizontalLayout
     *  @see #titleContent
     *  
     *  @langversion 3.0
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
     *  The components that define actions the user can take in a view. 
     *  These components appear in the action area of the control,
     *  using the <code>actionGroup</code> skin part. 
     * 
     *  <p>The location and appearance of the <code>actionGroup</code> 
     *  skin part is determined by the ActionBarSkin class.
     *  The default ActionBarSkin class defines the <code>actionGroup</code>
     *  to appear to the right of the title display area of the ActionBar.</p>
     * 
     *  <p>Create a custom ActionBarSkin skin class to change the default location 
     *  and appearance of the <code>actionGroup</code> skin part.</p>
     *  
     *  @default null
     *
     *  @see spark.skins.mobile.ActionBarSkin
     *  @see #actionLayout
     *
     *  @langversion 3.0
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
     *  Defines the layout of the components defined in the 
     *  action area by the <code>actionGroup</code> property.
     *
     *  @default HorizontalLayout
     *
     *  @see #actionContent
     *  
     *  @langversion 3.0
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
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        if (!styleProp ||
            styleProp == "styleName" ||
            styleProp == "defaultButtonAppearance")
        {
            // prepend defaultButtonAppearance style name
            var otherStyleNames:String = (styleName as String) ? String(styleName) : "";
            var whitespace:int = otherStyleNames.indexOf(" ");
            var firstStyleName:String = (whitespace > 0) ? otherStyleNames.substring(0, whitespace) : otherStyleNames;
            var defaultButtonAppearance:String = getStyle("defaultButtonAppearance");
            
            // only change styleName if necessary
            if (firstStyleName != defaultButtonAppearance)
            {
                // remove previous defaultButtonAppearance value
                if (firstStyleName == ActionBarDefaultButtonAppearance.BEVELED
                    || firstStyleName == ActionBarDefaultButtonAppearance.NORMAL)
                {
                    if (whitespace < 0)
                        otherStyleNames = "";
                    else
                        otherStyleNames = " " + otherStyleNames.substr(whitespace + 1);
                }
                
                styleName = defaultButtonAppearance + otherStyleNames;
            }
        }
        
        super.styleChanged(styleProp);
    }
    
    //----------------------------------
    //  baselinePosition
    //----------------------------------
    
    /**
     *  @private
     */
    override public function get baselinePosition():Number
    {
        return getBaselinePositionForPart(titleDisplay as IVisualElement);
    }
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function getCurrentSkinState():String
    {
        var state:String = (titleContent) ? "titleContent" : "title";
        
        if (actionContent && navigationContent)
        {
            state += "WithActionAndNavigation";
        }
        else if (actionContent)
        {
            state += "WithAction";
        }
        else if (navigationContent)
        {
            state += "WithNavigation";
        }
        
        return state;
    }
    
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
            
            if (contentGroupProperties[index].content != null)
            {
                group.mxmlContent = contentGroupProperties[index].content;
                newContentGroupProperties = BitFlagUtil.update(newContentGroupProperties, 
                    CONTENT_PROPERTY_FLAG, true);
            }
            
            if (contentGroupProperties[index].layout != null)
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