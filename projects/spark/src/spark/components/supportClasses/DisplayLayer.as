////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.supportClasses
{
import flash.display.DisplayObject;
import flash.events.EventDispatcher;

import mx.resources.ResourceManager;

import spark.events.DisplayPlaneObjectExistenceEvent;

/**
 *  A DisplayPlane class maintains ordered list of DisplayObjects sorted on
 *  depth.
 *  Developers don't instantiate this class, but use the <code>overlay</code>
 *  property of <code>Group</code> and <code>DataGroup</code>.
 *
 *  @see spark.components.Group#overlay
 *  @see spark.components.DataGroup#overlay
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class DisplayPlane extends EventDispatcher
{
	/**
	 *  Constructor. 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function DisplayPlane()
	{
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	private var _depth:Vector.<Number>;
	private var _objects:Vector.<DisplayObject>;
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  Number of objects in the DisplayPlane. 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get numDisplayObjects():int
	{
		return _objects ? _objects.length : 0;
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  Returns the requested object with the specified index in the
	 *  ordered list. 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function getDisplayObjectAt(index:int):DisplayObject
	{
		if (!_objects || index < 0 || index >= _objects.length)
			throw new RangeError(ResourceManager.getInstance().getString("components", "indexOutOfRange", [index]));

		return _objects[index];
	}
	
	/**
	 *  Adds a <code>displayObject</code> with the specified depth to the ordered list.
	 *  The position of the <code>displayObject</code> in the sorted lists is based on
	 *  its depth, the object will be inserted after all objects with less than or equal
	 *  depth value.
	 * 
	 *  @return Returns the index of the object.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function addDisplayObject(displayObject:DisplayObject, depth:Number = OverlayDepth.TOPMOST):int
	{
		// Find index to insert
		var index:int = 0;
		if (!_depth)
		{
			_depth = new Vector.<Number>;
			_objects = new Vector.<DisplayObject>;
		}
		else
		{
			// Simple linear search
			var count:int = _depth.length;
			for (; index < count; index++)
				if (depth < _depth[index])
					break;
		}

		// Insert at index:
		_depth.splice(index, 0, depth);
		_objects.splice(index, 0, displayObject);

		// Notify that the object has been added
		dispatchEvent(new DisplayPlaneObjectExistenceEvent(DisplayPlaneObjectExistenceEvent.OBJECT_ADD,
   	                  false /*bubbles*/,
					  false /*cancelable*/,
					  displayObject,
					  index));

		return index;
	}

	/**
	 *  Removes the specified <code>displayObject</code> from the sorted list.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function removeDisplayObject(displayObject:DisplayObject):void
	{
		// FIXME (egeorgie): add null checks
		
		var index:int = _objects.indexOf(displayObject);
		// FIXME (egeorgie): add check for index

		// Notify that the object is to be deleted
		dispatchEvent(new DisplayPlaneObjectExistenceEvent(DisplayPlaneObjectExistenceEvent.OBJECT_REMOVE,
													       false /*bubbles*/,
													       false /*cancelable*/,
													       displayObject,
													       index));
		_depth.splice(index, 1);
		_objects.splice(index, 1);
	}
	
}
}