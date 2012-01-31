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

package mx.controls.listClasses
{

import flash.display.DisplayObject;
import mx.core.mx_internal;
import mx.core.UIComponent;

use namespace mx_internal;

/**
 *  The default drag proxy used when dragging from an MX list-based control
 *  (except for the DataGrid class).
 *  A drag proxy is a component that parents the objects
 *  or copies of the objects being dragged
 *
 *  @see mx.controls.dataGridClasses.DataGridDragProxy
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class ListItemDragProxy extends UIComponent
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
    public function ListItemDragProxy()
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
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function createChildren():void
    {
        super.createChildren();

        var items:Array /* of unit */ = ListBase(owner).selectedItems;

        var n:int = items.length;
        for (var i:int = 0; i < n; i++)
        {
            var src:IListItemRenderer = ListBase(owner).itemToItemRenderer(items[i]);
            if (!src)
                continue;

            var o:IListItemRenderer = ListBase(owner).createItemRenderer(items[i]);
    
            o.styleName = ListBase(owner);
			addChild(DisplayObject(o));
			
            
            if (o is IDropInListItemRenderer)
            {
                var listData:BaseListData =
                    IDropInListItemRenderer(src).listData;
                
                IDropInListItemRenderer(o).listData = items[i] ?
                                                      listData :
                                                      null;
            }

			o.data = items[i];
			o.visible = true;
			

            var contentHolder:ListBaseContentHolder = src.parent as ListBaseContentHolder;
            
            o.setActualSize(src.width, src.height);
            o.x = src.x + contentHolder.leftOffset;
            o.y = src.y + contentHolder.topOffset;

            measuredHeight = Math.max(measuredHeight, o.y + o.height);
            measuredWidth = Math.max(measuredWidth, o.x + o.width);
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
        var child:IListItemRenderer;
        
        for (var i:int = 0; i < numChildren; i++)
        {
            child = getChildAt(i) as IListItemRenderer;
            
            if (child)
            {
                /*trace("ListItemDragProxy.measure x",child.x,"y",child.y,"h",child.getExplicitOrMeasuredHeight(),
                        "w",child.getExplicitOrMeasuredWidth(),"child",child);
                *  
                *  @langversion 3.0
                *  @playerversion Flash 9
                *  @playerversion AIR 1.1
                *  @productversion Flex 3
                */
                w = Math.max(w, child.x + child.width);
                h = Math.max(h, child.y + child.height);
            }
        }
        
        measuredWidth = measuredMinWidth = w;
        measuredHeight = measuredMinHeight = h;
    }
}

}
