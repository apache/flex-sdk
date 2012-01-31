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

package mx.controls.menuClasses
{

import mx.controls.listClasses.ListData;
import mx.controls.listClasses.ListBase;
import mx.core.IUIComponent;

/**
 *  The MenuListData class defines the data type of the <code>listData</code> property 
 *  implemented by drop-in item renderers or drop-in item editors for the Menu and 
 *  MenuBar control.  All drop-in item renderers and drop-in item editors must implement the 
 *  IDropInListItemRenderer interface, which defines the <code>listData</code> property.
 *
 *  @see mx.controls.listClasses.IDropInListItemRenderer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class MenuListData extends ListData
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
	 *  @param text Text representation of the item data.
	 *
	 * 	@param icon A Class or String object representing the icon 
	 *  for the item in the List control.
	 *
	 *  @param labelField The name of the field of the data provider 
	 *  containing the label data of the List component.
	 * 
	 *  @param uid A unique identifier for the item.
	 *
	 *  @param owner A reference to the Menu control.
	 *
	 *  @param rowIndex The index of the item in the data provider for the Menu control.
	 * 
	 *  @param columnIndex The index of the column in the currently visible columns of the 
     *  control.
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function MenuListData(text:String, icon:Class, labelField:String,
								 uid:String, owner:IUIComponent, rowIndex:int = 0,
								 columnIndex:int = 0)
	{
		super(text, icon, labelField, uid, owner, rowIndex, columnIndex);
	}

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  maxMeasuredIconWidth
    //----------------------------------

	/**
	 *  The max icon width for all MenuItemListRenderers
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var maxMeasuredIconWidth:Number;
	
    //----------------------------------
    //  maxMeasuredTypeIconWidth
    //----------------------------------

	/**
	 *  The max type icon width for all MenuItemListRenderers
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var maxMeasuredTypeIconWidth:Number;
	
    //----------------------------------
    //  maxMeasuredBranchIconWidth
    //----------------------------------

	/**
	 *  The max branch icon width for all MenuItemListRenderers
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var maxMeasuredBranchIconWidth:Number;
	
	//----------------------------------
    //  useTwoColumns
    //----------------------------------

	/**
	 *  Whether the left icons should layout in two separate columns
	 *  (one for icons and one for type icons, like check and radio)
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var useTwoColumns:Boolean;

}

}
