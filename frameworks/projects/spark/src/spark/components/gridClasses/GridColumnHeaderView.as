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
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.core.LayoutDirection;
import mx.core.mx_internal;

import spark.components.GridColumnHeaderGroup;
import spark.components.Group;

use namespace mx_internal;

/**
 *  This class is internal to the DataGrid implementation.
 *  
 *  GridColumnHeaderViews are created automatically by the GridColumnHeaderGroup class, based on the values of 
 *  the lockedColumnCount Grid properties.
 */
public class GridColumnHeaderView extends Group
{
    private static const zeroPoint:Point = new Point(0, 0);
    
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
    /**
     *  Creates a GridColumnHeaderView group with its layout set to a private GridColumnHeaderView specific value.
     */
    public function GridColumnHeaderView()
    {
        super();
        layout = new GridHeaderViewLayout();
		layout.clipAndEnableScrolling = true;
    }
   
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  gridColumnHeaderGroup
	//----------------------------------
	
	/**
	 *  The GridColumnHeaderGroup whose columns this header view is associated with.
	 * 
	 *  This property is set by GridColumnHeaderGroup.
	 */
	public function get gridColumnHeaderGroup():GridColumnHeaderGroup
	{
		return gridHeaderViewLayout.gridColumnHeaderGroup;
	}
	
	/**
	 *  @private
	 */
	public function set gridColumnHeaderGroup(value:GridColumnHeaderGroup):void
	{
		gridHeaderViewLayout.gridColumnHeaderGroup = value;
	}

    /**
     *  Return this GridColumnHeaderGroup's GridColumnHeaderGroupLayout.
     */
    public function get gridHeaderViewLayout():GridHeaderViewLayout
    {
        return layout as GridHeaderViewLayout;
    }    
    
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
    /**
     *  True if this GridColumnHeaderView's bounds contain the event.
     * 
     *  Currently this method does not account for the possibility that this GridColumnHeaderView has been
     *  rotated or scaled.
     */
    public function containsMouseEvent(event:MouseEvent):Boolean
    {
        return containsGlobalPoint(new Point(event.stageX, event.stageY));
    }

    public function containsGlobalPoint(globalCoordinates:Point):Boolean
    {
        const stageX:Number = globalCoordinates.x;
        const stageY:Number = globalCoordinates.y;
        const origin:Point = localToGlobal(zeroPoint);

        origin.x += horizontalScrollPosition;
        if (layoutDirection == LayoutDirection.RTL)
            origin.x -= width;

        origin.y += verticalScrollPosition;

        var headerViewContainsGlobalCoordinates:Boolean = (stageX >= origin.x) && (stageY >= origin.y) &&
                (stageX < (origin.x + width)) && (stageY < (origin.y + height));

        return headerViewContainsGlobalCoordinates;
    }   
}
}