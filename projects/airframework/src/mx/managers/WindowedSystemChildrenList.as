////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.managers
{

import flash.display.DisplayObject;
import flash.geom.Point;
import mx.core.IChildList;
import mx.core.mx_internal;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 *  A SystemManager has various types of children,
 *  such as the Application, popups, tooltips, and custom cursors.
 *
 *  You can access all the children via the <code>rawChildren</code> property.
 *  You can access just the popups via <code>popUpChildren</code>,
 *  the tooltips via <code>toolTipChildren</code>,
 *  and the custom cursors via <code>cursorChildren</code>.
 *  Each of these returns a SystemChildrenList which implements IChildList.
 *
 *  The SystemChildrenList is given two indices that map
 *  to a subset of the indices of children within the entire
 *  set of child indices in the SystemManager.
 *  It manages the children within those two indices.
 */
public class WindowedSystemChildrenList implements IChildList
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 *  
	 *  @langversion 3.0
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function WindowedSystemChildrenList(owner:WindowedSystemManager,
									   lowerBoundReference:QName,
									   upperBoundReference:QName)
	{
		super();

		this.owner = owner;
		this.lowerBoundReference = lowerBoundReference;
		this.upperBoundReference = upperBoundReference;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private var owner:WindowedSystemManager;

	/**
	 *  @private
	 *  Either "noTopMostIndex", "topMostIndex", or "toolTipIndex".
	 *  The popUpChildren extends from noTopMostIndex to topMostIndex.
	 *  The toolTips extends from topMostIndex to toolTipIndex.
	 *  The cursors extends from toolTipIndex to cursorIndex.
	 */
	private var lowerBoundReference:QName;

	/**
	 *  @private
	 *  Either "topMostIndex", "toolTipIndex", or "cursorIndex".
	 *  The popUpChildren extends from noTopMostIndex to topMostIndex.
	 *  The toolTips extends from topMostIndex to toolTipIndex.
	 *  The cursors extends from toolTipIndex to cursorIndex.
	 */
	private var upperBoundReference:QName;

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @copy mx.core.IChildList#numChildren
	 *  
	 *  @langversion 3.0
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get numChildren():int
	{
		return owner[upperBoundReference] - owner[lowerBoundReference];
	}

	/**
	 *  @copy mx.core.IChildList#addChild
	 *  
	 *  @langversion 3.0
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function addChild(child:DisplayObject):DisplayObject
	{
		owner.rawChildren_addChildAt(
			child, owner[upperBoundReference]);
		owner[upperBoundReference]++;
		return child;
	}

	/**
	 *  @copy mx.core.IChildList#addChildAt
	 *  
	 *  @langversion 3.0
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function addChildAt(child:DisplayObject, index:int):DisplayObject
	{
		owner.rawChildren_addChildAt(
			child, owner[lowerBoundReference] + index);
		owner[upperBoundReference]++;
		return child;
	}

	/**
	 *  @copy mx.core.IChildList#removeChild
	 *  
	 *  @langversion 3.0
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function removeChild(child:DisplayObject):DisplayObject
	{
		var index:int = owner.rawChildren_getChildIndex(child);
		if (owner[lowerBoundReference] <= index &&
			index < owner[upperBoundReference])
		{
			owner.rawChildren_removeChild(child);
			owner[upperBoundReference]--;
		}
		return child;
	}

	/**
	 *  @copy mx.core.IChildList#removeChildAt
	 *  
	 *  @langversion 3.0
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function removeChildAt(index:int):DisplayObject
	{
		var child:DisplayObject = 
			owner.rawChildren_removeChildAt(
				index + owner[lowerBoundReference]);
		owner[upperBoundReference]--;
		return child;
	}

	/**
	 *  @copy mx.core.IChildList#getChildAt
	 *  
	 *  @langversion 3.0
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
  	public function getChildAt(index:int):DisplayObject
  	{
		var retval:DisplayObject =
			owner.rawChildren_getChildAt(
				owner[lowerBoundReference] + index);
		return retval;
  	}

	/**
	 *  @copy mx.core.IChildList#getChildByName
	 *  
	 *  @langversion 3.0
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
  	public function getChildByName(name:String):DisplayObject
  	{
		return owner.rawChildren_getChildByName(name);
  	}

	/**
	 *  @copy mx.core.IChildList#getChildIndex
	 *  
	 *  @langversion 3.0
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
  	public function getChildIndex(child:DisplayObject):int
  	{
		var retval:int = owner.rawChildren_getChildIndex(child);
		retval -= owner[lowerBoundReference];
		return retval;
	}

	/**
	 *  @copy mx.core.IChildList#setChildIndex
	 *  
	 *  @langversion 3.0
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function setChildIndex(child:DisplayObject, newIndex:int):void
	{		
		owner.rawChildren_setChildIndex(
			child, owner[lowerBoundReference] + newIndex);
	}

	/**
	 *  @copy mx.core.IChildList#getObjectsUnderPoint
	 *  
	 *  @langversion 3.0
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function getObjectsUnderPoint(point:Point):Array
	{
		return owner.rawChildren_getObjectsUnderPoint(point);
	}

	/**
	 *  @copy mx.core.IChildList#contains
	 *  
	 *  @langversion 3.0
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function contains(child:DisplayObject):Boolean
	{
		if (owner.rawChildren_contains(child))
		{
			while (child.parent != owner && child.parent != child.stage)
			{
				child = child.parent;
			}
			var childIndex:int = owner.rawChildren_getChildIndex(child);
			if (childIndex >= owner[lowerBoundReference] &&
				childIndex < owner[upperBoundReference])
			{
				return true;
			}
		}
		return false;
	}	
}

}
