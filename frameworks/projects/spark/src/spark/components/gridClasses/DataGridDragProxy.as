////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.gridClasses
{
    
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.IDataRenderer;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.styles.IStyleClient;

import spark.components.DataGrid;
import spark.components.Grid;
import spark.components.Group;

use namespace mx_internal;

/**
 *  The DataGridDragProxy class defines the default drag proxy 
 *  used when dragging data from a DataGrid control.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
public class DataGridDragProxy extends Group
{
    include "../../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function DataGridDragProxy()
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
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function createChildren():void
    {
        super.createChildren();
        
        var dataGrid:DataGrid = DataGrid(owner);
        var grid:Grid = dataGrid.grid;
        
        // Make sure we inherit styles from the drag initiator, as those styles
        // may be affecting the appearance of the item renderers.
        this.styleName = dataGrid;
        
        width = grid.width
        height = grid.height;
        
        // Find all visible children within the selection:
        var selection:Vector.<int> = grid.selectedIndices;
        if (!selection || selection.length == 0)
            return;
        
        var offsetX:Number = 0;
        var offsetY:Number = 0;
        var scrollRect:Rectangle = dataGrid.scrollRect;
        if (scrollRect)
        {
            offsetX = scrollRect.x;
            offsetY = scrollRect.y;
        }
        
        var n:int = selection.length;
        for (var i:int = 0; i < n; i++)
        {
            
            var index:int = selection[i];
            if (!grid.isCellVisible(index, 0))
                continue;
            
            var data:Object = grid.getDataProviderItem(index);
            var element:IGridItemRenderer = grid.getItemRendererAt(index, 0);
            if (!element)
                continue;
            
            var o:Group = new Group();
            
            addElement(o);
            
            // The drag proxy should have the same layoutDirection as the 
            // DataGrid.
            o.layoutDirection = dataGrid.layoutDirection;
            
            var totalColumnWidth:Number = 0;
            var m:int;
            var j:int;
            var column:GridColumn;
            var clone:IGridItemRenderer;
            
            m = grid.getVisibleColumnIndices().length;
            for (j = 0; j < m; j++)
            {
                column = GridColumn(grid.columns.getItemAt(j));
                
                clone = column.itemToRenderer(data).newInstance();
                
                IStyleClient(clone).styleName = DataGrid(owner);
                
                IDataRenderer(clone).data = data;
                clone.visible = true;
                
                
                // Copy the dimensions
                clone.width = element.width;
                clone.height = element.height;
                
                // Copy the transform
                if (element.hasLayoutMatrix3D)
                    clone.setLayoutMatrix3D(element.getLayoutMatrix3D(), false);
                else
                    clone.setLayoutMatrix(element.getLayoutMatrix(), false);
                
                clone.x = totalColumnWidth + element.x + 5;
                //clone.y -= offsetY;
                
                // Copy other relevant properties
                clone.depth = element.depth;
                clone.visible = element.visible;
                if (element.postLayoutTransformOffsets)
                    clone.postLayoutTransformOffsets = element.postLayoutTransformOffsets;
                
                // Put it in a dragging state
                clone.dragging = true;
                
                // Add the clone as a child
                o.addElement(clone);
                clone.label = column.itemToLabel(data);
                clone.prepare(false);
                clone["validateNow"]();
                
                // FIXME (dloverin): 10 pixels of padding on each renderer.
                // The padding is hard-coded in the item renderer.
                totalColumnWidth += clone.width + 10;  
            }
            
            
            o.setLayoutBoundsSize(totalColumnWidth, element.height);
            o.width = totalColumnWidth;
            o.height = element.height;
            
            var pt:Point = new Point(0, 0);
            pt = DisplayObject(element).localToGlobal(pt);
            pt = DataGrid(owner).globalToLocal(pt);
            o.y = pt.y;
            o.visible = true;
            measuredHeight = o.y + o.height;
            measuredWidth = totalColumnWidth;
            
        }
        
        o.validateNow();
        invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        var w:Number = 0;
        var h:Number = 0;
        var child:UIComponent;
        
        for (var i:int = 0; i < numChildren; i++)
        {
            child = getChildAt(i) as UIComponent;
            
            if (child)
            {
                w = Math.max(w, child.x + child.width);
                h = Math.max(h, child.y + child.height);
            }
        }
        
        measuredWidth = measuredMinWidth = w;
        measuredHeight = measuredMinHeight = h; 
    }
}
    
}
