package spark.components
{
import flash.events.Event;

import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.utils.BitFlagUtil;

import spark.components.supportClasses.ButtonBase;
import spark.components.supportClasses.SkinnableComponent;
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

//--------------------------------------
//  Skin states
//--------------------------------------

/*
* Skin states to support ViewNavigator
*/
[SkinState("portrait")]
[SkinState("landscape")]
[SkinState("portraitAndOverlay")]
[SkinState("landscapeAndOverlay")]

/**
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
        _titleChanged = false;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    private var _dataProvider:ViewNavigator;
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts 
    //
    //--------------------------------------------------------------------------
    
    [SkinPart(required="false")]
    
    /**
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var navigationGroup:Group;
    
    [SkinPart(required="false")]
    
    /**
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var titleGroup:Group;
    
    [SkinPart(required="false")]
    
    /**
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var actionGroup:Group;
    
    [SkinPart(required="false")]
    
    /**
     *  The skin part that defines the appearance of the 
     *  title text in the container.
     *
     *  @see spark.skins.mobile.ActionBarSkin
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4
     */
    public var titleDisplay:Label; // TODO fix after Text spec is drafted
    
    //----------------------------------
    //  title
    //----------------------------------
    
    private var _title:String;
    private var _titleChanged:Boolean;
    
    [Bindable]
    
    /**
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
        return (navigationGroup) ? navigationGroup.layout : contentGroupProperties[NAVIGATION_GROUP_PROPERTIES_INDEX].layout;
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
            contentGroupProperties.layout = value;
    }
    
    //----------------------------------
    //  titleContent
    //---------------------------------- 
    
    [ArrayElementType("mx.core.IVisualElement")]
    
    /**
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get titleContent():Array
    {
        if (titleGroup)
        {
            if (BitFlagUtil.isSet(contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX], CONTENT_PROPERTY_FLAG))
                return titleGroup.getMXMLContent();
            else
                return null;
        }
        else
        {
            return contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX].content;
        }
    }
    
    /**
     *  @private
     */
    public function set titleContent(value:Array):void
    {
        if (titleGroup)
        {
            _titleChanged = true;
            
            if (value)
            {
                titleGroup.mxmlContent = value;
            }
            else
            {
                titleGroup.mxmlContent = titleDisplay ? [titleDisplay] : null;
                invalidateProperties();
            }
            
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
        return (titleGroup) ? titleGroup.layout : contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX].layout;
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
            contentGroupProperties.layout = value;
    }
    
    //----------------------------------
    //  actionContent
    //---------------------------------- 
    
    [ArrayElementType("mx.core.IVisualElement")]
    
    /**
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
        return (actionGroup) ? actionGroup.layout : contentGroupProperties[ACTION_GROUP_PROPERTIES_INDEX].layout;
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
            contentGroupProperties.layout = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (titleDisplay && _titleChanged)
        {
            _titleChanged = false;
            
            titleDisplay.includeInLayout = (title != "" && title != null);
            if (!BitFlagUtil.isSet(contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX], CONTENT_PROPERTY_FLAG))
                titleDisplay.text = title;
        }
    }
    
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        var defaultContent:Array; /*IVisualElement*/
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
            
            // use titleContent if provided
            defaultContent = contentGroupProperties[TITLE_GROUP_PROPERTIES_INDEX].content;
            
            // if no titleContent, use titleDisplay
            if (defaultContent == null)
            {
                defaultContent = (titleDisplay) ? [titleDisplay] : null;
            }
            
            _titleChanged = true;
        }
        else if (instance == actionGroup)
        {
            group = actionGroup;
            index = ACTION_GROUP_PROPERTIES_INDEX;
        }
        else if (instance == titleDisplay)
        {
            titleDisplay.text = title;
			
			if (titleGroup && !titleContent)
			{
				titleGroup.mxmlContent = [titleDisplay];
			}
        }
        
        if (index > -1)
        {
            var newContentGroupProperties:uint = 0;
            
            if (contentGroupProperties[index].content != undefined)
            {
                group.mxmlContent = contentGroupProperties[index].content;
                newContentGroupProperties = BitFlagUtil.update(newContentGroupProperties, 
                    CONTENT_PROPERTY_FLAG, true);
            }
            
            if (contentGroupProperties[index].layout !== undefined)
            {
                group.layout = contentGroupProperties.layout;
                newContentGroupProperties = BitFlagUtil.update(newContentGroupProperties, 
                    LAYOUT_PROPERTY_FLAG, true);
            }
            
            if (defaultContent)
            {
                group.mxmlContent = defaultContent;	
            }
            
            contentGroupProperties[index] = newContentGroupProperties;
            contentGroupLayouts[index] = group.layout;
        }
    }
    
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
            
            contentGroupProperties[index] = newContentGroupProperties;
            group.mxmlContent = null;
        }
    }
}
}