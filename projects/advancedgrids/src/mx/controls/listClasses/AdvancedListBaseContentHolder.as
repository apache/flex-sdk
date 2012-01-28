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
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import mx.core.FlexShape;
import mx.core.UIComponent;
import mx.core.mx_internal;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

include "../../styles/metadata/PaddingStyles.as"

/**
 *  Background color of the component.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="backgroundColor", type="uint", format="Color", inherit="no")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[ExcludeClass]

/**
 *  @private
 *  The AdvancedListBaseContentHolder is the container within a list component
 *  of all of the item renderers and editors.
 *  It is used to mask off areas of the renderers that extend outside
 *  the component and to block certain styles from propagating
 *  down into the renderers so that the renderers have no background
 *  so the highlights and alternating row colors can show through.
 */
public class AdvancedListBaseContentHolder extends UIComponent
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
	public function AdvancedListBaseContentHolder(parentList:AdvancedListBase)
	{
		super();

		this.parentList = parentList;

		setStyle("backgroundColor", "");
		setStyle("borderStyle", "none");
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private var parentList:AdvancedListBase;

	/**
	 *  @private
	 */
	private var maskShape:Shape;

	/**
	 *  @private
	 */
	mx_internal var allowItemSizeChangeNotification:Boolean = true;

	//--------------------------------------------------------------------------
	//
	//  Overridden properties: UIComponent
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  focusPane
	//----------------------------------

	/**
     *  @private
     */
    override public function set focusPane(value:Sprite):void
    {
		if (value)
		{
			// Something inside us is getting focus so apply a clip mask
			// if we don't already have one.
			if (!maskShape)
			{
				maskShape = new FlexShape();
				maskShape.name = "mask";

				var g:Graphics = maskShape.graphics;
				g.beginFill(0xFFFFFF);
				g.drawRect(-2, -2, width + 2, height + 2);
				g.endFill();

				addChild(maskShape);
			}

			maskShape.visible = false;

			value.mask = maskShape;
		}
		else
		{
			if (parentList.focusPane.mask == maskShape)
				parentList.focusPane.mask = null;
		}

		parentList.focusPane = value;
		value.x = x;
		value.y = y;
	}
	
	//--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------   
    
    //----------------------------------
    // leftOffset
    //----------------------------------
	
	/**
	 *  offset for the upper left corner of the listContent in the parent list
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var leftOffset:Number = 0;
	
	//----------------------------------
    // topOffset
    //----------------------------------
    
	/**
	 *  offset for the upper left corner of the listContent in the parent list
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var topOffset:Number = 0;
	
	//----------------------------------
    // rightOffset
    //----------------------------------

	/**
	 *  offset for the bottom right corner of the listContent in the parent list
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var rightOffset:Number = 0;
	
	//----------------------------------
    // bottomOffset
    //----------------------------------

	/**
	 *  offset for the bottom right corner of the listContent in the parent list
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var bottomOffset:Number = 0;
	
	//----------------------------------
    // heightExcludingOffsets
    //----------------------------------
	
	/**
	 *  The height of the central part of the listContent, excluding the top and
     *  bottom offsets.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get heightExcludingOffsets():Number
	{
		return height + topOffset - bottomOffset;
	}
	
	//----------------------------------
    // widthExcludingOffsets
    //----------------------------------
    
	/**
	 *  The width of the central part of the listContent, excluding the left and
     *  right offsets.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get widthExcludingOffsets():Number
	{
		return width + leftOffset - rightOffset;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: UIComponent
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override public function invalidateSize():void
	{
		if (allowItemSizeChangeNotification)
			parentList.invalidateList();
	}

	/**
	 *  Sets the position and size of the scroll bars and content
	 *  and adjusts the mask.
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);

		if (maskShape)
		{
			maskShape.width = unscaledWidth;
			maskShape.height = unscaledHeight;
		}
	}
	
	//--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
	/**
	 *  @private
	 */
    mx_internal function getParentList():AdvancedListBase
    {
        return parentList;
    }
}

}
