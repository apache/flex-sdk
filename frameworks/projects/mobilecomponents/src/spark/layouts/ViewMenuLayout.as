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

package spark.layouts
{
import flash.display.DisplayObject;
import flash.display.Graphics;

import mx.core.IVisualElement;

import spark.components.ViewMenu;
import spark.components.Group;
import spark.components.supportClasses.GroupBase;
import spark.layouts.TileLayout;

/**
 *  ViewMenuLayout is a specialized TileLayout for ViewMenu. 
 */ 
public class ViewMenuLayout extends TileLayout
{
    /**
     *  Constructor 
     */ 
    public function ViewMenuLayout()
    {
        super();
    }
    
    private var _maxColumnCount:int = -1;
    
    /**
     *  @private 
     */         
    override public function set requestedColumnCount(value:int):void
    {
        _maxColumnCount = value;
        super.requestedColumnCount = value;
                
        if (target)
            target.invalidateDisplayList();
    }
    
    /**
     *  @private 
     */
    override public function measure():void
    {
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;
        
        var numItems:int = layoutTarget.numElements;
        
        var numRows:int = Math.ceil(numItems / _maxColumnCount);
        var numColumns:int = Math.ceil(numItems / numRows);
        
        requestedRowCount = numRows;
        super.requestedColumnCount = numColumns;
        
        super.measure();
    }
    
    /**
     *  @private 
     */
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        var newColumnWidth:Number = (unscaledWidth - (horizontalGap * (requestedColumnCount-1))) / requestedColumnCount;
        
        // If the column width has changed, make sure to clear the tile size cache
        if (newColumnWidth != columnWidth)
        {
            columnWidth = newColumnWidth;
            clearVirtualLayoutCache();
        }
        
        super.updateDisplayList(unscaledWidth, unscaledHeight);        
    }
}
}