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
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.IFactory;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.managers.CursorManager;
import mx.managers.CursorManagerPriority;
import mx.managers.IFocusManagerComponent;

import spark.components.supportClasses.ColumnHeaderBarLayout;
import spark.components.supportClasses.GridColumn;
import spark.components.supportClasses.GridLayer;
import spark.events.GridEvent;
import spark.layouts.supportClasses.LayoutBase;
import spark.utils.MouseEventUtil;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  Bottom inset, in pixels, for all header renderers. 
 * 
 *  @default 0
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]

/**
 *  Left inset, in pixels, for the first header renderer. 
 * 
 *  @default 0
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="paddingLeft", type="Number", format="Length", inherit="no")]

/**
 *  Right inset, in pixels, for the last header renderer. 
 * 
 *  @default 0
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="paddingRight", type="Number", format="Length", inherit="no")]

/**
 *  Top inset, in pixels, for all header renderers. 
 * 
 *  @default 0
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="paddingTop", type="Number", format="Length", inherit="no")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("ColumnHeaderBar.png")]

/**
 *  The ColumnHeaderBar control defines
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
public class ColumnHeaderBar extends Group implements IFocusManagerComponent 
{
    include "../core/Version.as";
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function ColumnHeaderBar()
    {
        super();
        
        layout = new ColumnHeaderBarLayout();
        layout.clipAndEnableScrolling = true;
        
        overlayGroup = new Group();
        overlayGroup.layout = new LayoutBase(); // no layout
        overlay.addDisplayObject(overlayGroup);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function dispatchChangeEvent(type:String):void
    {
        if (hasEventListener(type))
            dispatchEvent(new Event(type));
    }    
    
    //----------------------------------
    //  headerRenderer
    //----------------------------------    
    
    [Bindable("headerRendererChanged")]
    
    private var _headerRenderer:IFactory = null;
    
    /**
     *  Returns the default header renderer
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get headerRenderer():IFactory
    {
        return _headerRenderer;
    }
    
    /**
     *  @private
     */
    public function set headerRenderer(value:IFactory):void
    {
        if (value == _headerRenderer)
            return;
        
        
        _headerRenderer = value;
        
        layout.clearVirtualLayoutCache();
        invalidateSize();
        invalidateDisplayList();
        
        dispatchChangeEvent("headerRendererChanged");
    }
    
    
    //----------------------------------
    //  columnSeparator
    //----------------------------------
    
    [Bindable("columnSeparatorChanged")]
    
    private var _columnSeparator:IFactory = null;
    
    /**
     *  A visual element that's displayed in between each column.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get columnSeparator():IFactory
    {
        return _columnSeparator;
    }
    
    /**
     *  @private
     */
    public function set columnSeparator(value:IFactory):void
    {
        if (_columnSeparator == value)
            return;
        
        _columnSeparator = value;
        invalidateDisplayList();
        dispatchChangeEvent("columnSeparatorChanged");
    }
    
    //----------------------------------
    //  overlayGroup
    //----------------------------------
    
    [Bindable("overlayGroupChanged")]
    
    private var _overlayGroup:Group = null;
    
    /**
     *  The container for columnSeparator visual elements.  By default it's an 
     *  element of the ColumnHeaderBar's overlay.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get overlayGroup():Group
    {
        return _overlayGroup;
    }
    
    /**
     *  @private
     */
    public function set overlayGroup(value:Group):void
    {
        if (_overlayGroup == value)
            return;
        
        _overlayGroup = value;
        invalidateDisplayList();
        dispatchChangeEvent("overlayGroupChanged");
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods 
    //
    //--------------------------------------------------------------------------

    /**
     *  @copy spark.components.supportClasses.ColumnHeaderBarLayout#getHeaderRendererAt()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getHeaderRendererAt(columnIndex:int):IGridItemRenderer
    {
        return ColumnHeaderBarLayout(layout).getHeaderRendererAt(columnIndex);
    }
    
}    
}
