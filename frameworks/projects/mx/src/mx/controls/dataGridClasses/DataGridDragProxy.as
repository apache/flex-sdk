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

package mx.controls.dataGridClasses
{

import flash.display.DisplayObject;
import flash.geom.Point;
import mx.controls.DataGrid;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.core.UIComponent;
import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  The DataGridDragProxy class defines the default drag proxy 
 *  used when dragging data from a DataGrid control.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class DataGridDragProxy extends UIComponent
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
        
        var items:Array /* of unit */ = DataGridBase(owner).selectedItems;

        var n:int = items.length;
        for (var i:int = 0; i < n; i++)
        {
            var src:IListItemRenderer = DataGridBase(owner).itemToItemRenderer(items[i]);
            if (!src)
                continue;

            var o:UIComponent;
            
            var data:Object = items[i];

            o = new UIComponent();
            addChild(DisplayObject(o));

            // The drag proxy should have the same layoutDirection as the 
            // DataGrid.
            o.layoutDirection = DataGridBase(owner).layoutDirection;
            
            var ww:Number = 0;
            var m:int;
            var j:int;
            var col:DataGridColumn;
            var c:IListItemRenderer;
            var rowData:DataGridListData;

            if (DataGridBase(owner).visibleLockedColumns)
            {
                m = DataGridBase(owner).visibleLockedColumns.length;
                for (j = 0; j < m; j++)
                {
                    col = DataGridBase(owner).visibleLockedColumns[j];
                    
                    c = DataGridBase(owner).createColumnItemRenderer(col, false, data);
                    
                    rowData = new DataGridListData(
                        col.itemToLabel(data), col.dataField,
                        col.colNum, "", DataGridBase(owner));
                    
                    c.styleName = DataGridBase(owner);                    
                    o.addChild(DisplayObject(c));
					
					if (c is IDropInListItemRenderer)
					{
						IDropInListItemRenderer(c).listData =
							data ? rowData : null;
					}
					
					c.data = data;
					c.visible = true;
                    
                    c.setActualSize(col.width, src.height);
                    c.move(ww, 0);
                    
                    ww += col.width;
                }
            }
            m = DataGridBase(owner).visibleColumns.length;
            for (j = 0; j < m; j++)
            {
                col = DataGridBase(owner).visibleColumns[j];
                
                c = DataGridBase(owner).createColumnItemRenderer(col, false, data);
                
                rowData = new DataGridListData(
                    col.itemToLabel(data), col.dataField,
                    col.colNum, "", DataGridBase(owner));
                
                c.styleName = DataGridBase(owner);
                o.addChild(DisplayObject(c));
				
				if (c is IDropInListItemRenderer)
				{
					IDropInListItemRenderer(c).listData =
						data ? rowData : null;
				}
				
				c.data = data;
				c.visible = true;				
                
                c.setActualSize(col.width, src.height);
                c.move(ww, 0);
                
                ww += col.width;
            }


            o.setActualSize(ww, src.height);
            var pt:Point = new Point(0, 0);
            pt = DisplayObject(src).localToGlobal(pt);
            pt = DataGridBase(owner).globalToLocal(pt);
            o.y = pt.y;

            measuredHeight = o.y + o.height;
            measuredWidth = ww;
        }

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
