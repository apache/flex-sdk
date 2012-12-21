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
import flash.events.Event;

import spark.components.Grid;
import spark.components.GridColumnHeaderGroup;
import spark.components.Group;
import spark.layouts.supportClasses.LayoutBase;

//[ExcludeClass]  TBD

/**
 *  @private
 *  The internal layout class used by GridColumnHeaderGroup.   Responsible for the 
 *  the layout the left and center column header views.   There is no gap between the
 *  two views however there are gaps between the overall left and right header view edges
 *  defined by leftPadding and rightPadding.
 * 
 *  This class is private to the DataGrid implementation.  It's only used by the 
 *  DataGrid's columnHeaderGroup skin part.
 * 
 *  This layout class is unusual because its updateDisplayList method depends on 
 *  the results of laying out the DataGrid grid's columns, i.e. it depends on the 
 *  the results of the Grid's layout.  The DataGrid forces the grid's nestLevel to 
 *  be less than the nestLevel of its columnHeaderGroup to ensure that the grid
 *  subtree is laid out first.
 * 
 *  This layout's measuredWidth is essentially zero because the DataGrid's grid
 *  dictates the overall measured width.  The columnHeaderGroup only contributes
 *  to the DataGrid's measured height.
 */
public class GridHeaderLayout extends LayoutBase
{
	public function GridHeaderLayout()
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
     */
    private function dispatchChangeEvent(type:String):void
    {
        if (hasEventListener(type))
            dispatchEvent(new Event(type));
    }
    
    //----------------------------------
    //  centerGridColumnHeaderView
    //----------------------------------
    
    private var _centerGridColumnHeaderView:Group = null; 
    
    [Bindable("centerGridColumnHeaderViewChanged")]
    
    /**
     *  Contains the column headers for the Grid's centerGridView, the unlocked columns. 
     * 
     *  @default null
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 5.0
     */
    public function get centerGridColumnHeaderView():Group
    {
        return _centerGridColumnHeaderView;
    }
    
    /**
     *  @private
     */
    public function set centerGridColumnHeaderView(value:Group):void
    {
        if (_centerGridColumnHeaderView == value)
            return;
        
        _centerGridColumnHeaderView = value;
        dispatchChangeEvent("centerGridColumnHeaderViewChanged");
    }

    //----------------------------------
    //  leftGridColumnHeaderView
    //----------------------------------
    
    private var _leftGridColumnHeaderView:Group = null; 
    
    [Bindable("leftGridColumnHeaderViewChanged")]
    
    /**
     *  Contains the column headers for the Grid's leftGridView lockedColumnCount columns. 
     * 
     *  @default null
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 5.0
     */
    public function get leftGridColumnHeaderView():Group
    {
        return _leftGridColumnHeaderView;
    }
    
    /**
     *  @private
     */
    public function set leftGridColumnHeaderView(value:Group):void
    {
        if (_leftGridColumnHeaderView == value)
            return;
        
        _leftGridColumnHeaderView = value;
        dispatchChangeEvent("leftGridColumnHeaderViewChanged");
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
	/**
	 *  @private
	 */
	override public function measure():void
	{
		const gridColumnHeaderGroup:GridColumnHeaderGroup = target as GridColumnHeaderGroup;
		if (!gridColumnHeaderGroup)
			return;
		
		const paddingLeft:Number = gridColumnHeaderGroup.getStyle("paddingLeft");
		const paddingRight:Number = gridColumnHeaderGroup.getStyle("paddingRight");
		const paddingTop:Number = gridColumnHeaderGroup.getStyle("paddingTop");
		const paddingBottom:Number = gridColumnHeaderGroup.getStyle("paddingBottom");
		
		const measuredWidth:Number = Math.max(0, target.getMinBoundsWidth()) + paddingLeft + paddingRight;
        const centerView:Group = centerGridColumnHeaderView;        
        const centerHeight:Number = (centerView) ? centerView.getPreferredBoundsHeight() : 0;
		const measuredHeight:Number = centerHeight + paddingTop + paddingBottom;
		
		target.measuredWidth = Math.ceil(measuredWidth); 
		target.measuredHeight = Math.ceil(measuredHeight);
		target.measuredMinWidth = Math.ceil(measuredWidth);    
		target.measuredMinHeight = Math.ceil(measuredHeight);
	}
	
	/**
	 *  @private
	 */
	override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		const gridColumnHeaderGroup:GridColumnHeaderGroup = target as GridColumnHeaderGroup;
		if (!gridColumnHeaderGroup || !centerGridColumnHeaderView)
			return;
		
        // Note that paddingLeft guarantees that the centerGridColumnHeaderView lines up 
        // with the Grid's centerGridView.
        
		const paddingLeft:Number = gridColumnHeaderGroup.getStyle("paddingLeft");
		const paddingRight:Number = gridColumnHeaderGroup.getStyle("paddingRight");
		const paddingTop:Number = gridColumnHeaderGroup.getStyle("paddingTop");
		const paddingBottom:Number = gridColumnHeaderGroup.getStyle("paddingBottom");		
		
		const grid:Grid = gridColumnHeaderGroup.dataGrid.grid;
		const gridLayout:GridLayout = gridColumnHeaderGroup.dataGrid.grid.layout as GridLayout;
		const lockedColumnCount:int = gridColumnHeaderGroup.dataGrid.lockedColumnCount;
		
		const centerView:Group = centerGridColumnHeaderView;
		const leftView:Group = leftGridColumnHeaderView;
		const headerHeight:Number = Math.max(0, unscaledHeight - (paddingTop + paddingBottom));
		
		var centerGridViewX:Number = gridLayout.centerGridView.getLayoutBoundsX();
		if (lockedColumnCount > 0)
		{
			leftView.setLayoutBoundsSize(centerGridViewX - paddingLeft, headerHeight);
			leftView.setLayoutBoundsPosition(paddingLeft, paddingTop);
		}
        else 
        {
            centerGridViewX += paddingLeft; 
        }
        
		centerView.setLayoutBoundsSize(unscaledWidth - centerGridViewX, headerHeight);
		centerView.setLayoutBoundsPosition(centerGridViewX, paddingTop);
        
        // The DataGrid invalidates this layout when the GridLayout's centerGridView is scrolled
        // horizontally.  It assumes that the header's centerView has the same contentWidth as
        // the centerGridView so it's not necessary to set the content size here.
	}
	
}
}