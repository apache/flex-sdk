////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.graphics
{

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.events.EventDispatcher;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.utils.getDefinitionByName;

import mx.events.PropertyChangeEvent;

/** 
 *  Defines a set of values used to fill an area on screen
 *  with a bitmap or other DisplayObject.
 *  
 *  @see mx.graphics.IFill
 *  @see flash.display.Bitmap
 *  @see flash.display.BitmapData
 *  @see flash.display.DisplayObject
 */
public class BitmapFill extends EventDispatcher implements IFill
{
	include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

 	/**
	 *  Constructor.
 	 */
	public function BitmapFill()
 	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private var bitmapData:BitmapData;

	/**
	 *  @private
	 */
	private var matrix:Matrix;	
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  originX
	//----------------------------------

	private var _originX:Number = 0;

	[Bindable("propertyChange")]
	[Inspectable(category="General")]	
	
	/**
	 *  The horizontal origin for the bitmap fill.
	 *  The bitmap fill is offset so that this point appears at the origin.
	 *  Scaling and rotation of the bitmap are performed around this point.
	 *
	 *  @default 0 
	 */
	public function get originX():Number
	{
		return _originX;
	}
	
	public function set originX(value:Number):void
	{
		var oldValue:Number = _originX;
		if (value != oldValue)
		{
			_originX = value;
			dispatchFillChangedEvent("originX", oldValue, value);
		}
	}
	
	//----------------------------------
	//  originY
	//----------------------------------

	private var _originY:Number = 0;

	[Bindable("propertyChange")]
	[Inspectable(category="General")]	
	
	/**
	 *  The vertical origin for the bitmap fill.
	 *  The bitmap fill is offset so that this point appears at the origin.
	 *  Scaling and rotation of the bitmap are performed around this point.
	 *
	 *  @default 0 
	 */
	public function get originY():Number
	{
		return _originY;
	}
	
	public function set originY(value:Number):void
	{
		var oldValue:Number = _originY;
		if (value != oldValue)
		{
			_originY = value;
			dispatchFillChangedEvent("originY", oldValue, value);
		}
	}

	//----------------------------------
	//  offsetX
	//----------------------------------
	private var _offsetX:Number = 0;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]	
	
	/**
	 *  How far the bitmap is horizontally offset from the origin.
	 *  This adjustment is performed after rotation and scaling.
	 *
	 *  @default 0
	 */
	public function get offsetX():Number
	{
		return _offsetX;
	}
	
	public function set offsetX(value:Number):void
	{
		var oldValue:Number = _offsetX;
		if (value != oldValue)
		{
			_offsetX = value;
			dispatchFillChangedEvent("offsetX", oldValue, value);
		}
	}

	//----------------------------------
	//  offsetY
	//----------------------------------
	private var _offsetY:Number = 0;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]	
	
	/**
	 *  How far the bitmap is vertically offset from the origin.
	 *  This adjustment is performed after rotation and scaling.
	 *
	 *  @default 0
	 */
	public function get offsetY():Number
	{
		return _offsetY;
	}
	
	public function set offsetY(value:Number):void
	{
		var oldValue:Number = _offsetY;
		if (value != oldValue)
		{
			_offsetY = value;
			dispatchFillChangedEvent("offsetY", oldValue, value);
		}
	}

	//----------------------------------
	//  repeat
	//----------------------------------

	private var _repeat:Boolean = true;
	
	[Bindable("propertyChange")]
    [Inspectable(category="General")]

	
	/**
	 *  Whether the bitmap is repeated to fill the area.
	 *  Set to <code>true</code> to cause the fill to tile outward
	 *  to the edges of the filled region.
	 *  Set to <code>false</code> to end the fill at the edge of the region.
	 *
	 *  @default true
	 */
	public function get repeat():Boolean
	{
		return _repeat;
	}
	
	public function set repeat(value:Boolean):void
	{
		var oldValue:Boolean = _repeat;
		if (value != oldValue)
		{
			_repeat = value;
			dispatchFillChangedEvent("repeat", oldValue, value);
		}
	}

	//----------------------------------
	//  rotation
	//----------------------------------
	
	private var _rotation:Number = 0;

	[Bindable("propertyChange")]
	[Inspectable(category="General")]	
	
	/**
	 *  The number of degrees to rotate the bitmap.
	 *  Valid values range from 0.0 to 360.0.
	 *  
	 *  @default 0
	 */
	public function get rotation():Number
	{
		return _rotation;
	}
	
	public function set rotation(value:Number):void
	{
		var oldValue:Number = _rotation;
		if (value != oldValue)
		{
			_rotation = value;
			dispatchFillChangedEvent("rotation", oldValue, value);
		}
	}

	//----------------------------------
	//  scaleX
	//----------------------------------
	
	private var _scaleX:Number = 1.0;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]	
	
	/**
	 *  The percent to horizontally scale the bitmap when filling,
	 *  from 0.0 to 1.0.
	 *  If 1.0, the bitmap is filled at its natural size.
	 *
	 *  @default 1.0
	 */
	public function get scaleX():Number
	{
		return _scaleX;
	}
	
	public function set scaleX(value:Number):void
	{
		var oldValue:Number = _scaleX;
		if (value != oldValue)
		{
			_scaleX = value;
			dispatchFillChangedEvent("scaleX", oldValue, value);
		}
	}

	//----------------------------------
	//  scaleY
	//----------------------------------
	
	private var _scaleY:Number = 1.0;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]	
	
	/**
	 *  The percent to vertically scale the bitmap when filling,
	 *  from 0.0 to 1.0.
	 *  If 1.0, the bitmap is filled at its natural size.
	 *
	 *  @default 1.0 
	 */
	public function get scaleY():Number
	{
		return _scaleY;
	}
	
	public function set scaleY(value:Number):void
	{
		var oldValue:Number = _scaleY;
		if (value != oldValue)
		{
			_scaleY = value;
			dispatchFillChangedEvent("scaleY", oldValue, value);
		}
	}

	//----------------------------------
	//  source
	//----------------------------------

    [Inspectable(category="General")]

	/**
	 *  The source used for the bitmap fill.
	 *  The fill can render from various graphical sources,
	 *  including the following: 
	 *  <ul>
	 *   <li>A Bitmap or BitmapData instance.</li>
	 *   <li>A class representing a subclass of DisplayObject.
	 *   The BitmapFill instantiates the class
	 *   and creates a bitmap rendering of it.</li>
	 *   <li>An instance of a DisplayObject.
	 *   The BitmapFill copies it into a Bitmap for filling.</li>
	 *   <li>The name of a subclass of DisplayObject.
	 *   The BitmapFill loads the class, instantiates it, 
	 *   and creates a bitmap rendering of it.</li>
	 *  </ul>
	 *
	 *  @default null
	 */
	public function get source():Object 
	{
		return bitmapData;
	}
	
	/**
	 *  @private
	 */
	public function set source(value:Object):void
	{
		var tmpSprite:DisplayObject;
		
		if (value is BitmapData)
		{
			bitmapData = BitmapData(value);
			return;
		}

		if (value is Class)
		{
			var cls:Class = Class(value);
			tmpSprite = new cls();
		}
		else if (value is Bitmap)
		{
			bitmapData = value.bitmapData;
		}
		else if (value is DisplayObject)
		{
			tmpSprite = value as DisplayObject;
		}
		else if (value is String)
		{
			var tmpClass:Class = Class(getDefinitionByName(String(value)));
			tmpSprite = new tmpClass();
		}
		else
		{
			return;
		}
			
		if (!bitmapData && tmpSprite)
		{
			bitmapData = new BitmapData(tmpSprite.width, tmpSprite.height);
			bitmapData.draw(tmpSprite, new Matrix());
		}
	}

	//----------------------------------
	//  smooth
	//----------------------------------

	private var _smooth:Boolean = false;
	
	[Inspectable(category="General")]
	[Bindable("propertyChange")]	
	
	/**
	 *  A flag indicating whether to smooth the bitmap data
	 *  when filling with it.
	 *
	 *  @default false
	 */
	public function get smooth():Boolean
	{
		return _smooth;
	}
	
	public function set smooth(value:Boolean):void
	{
		var oldValue:Boolean = _smooth;
		if (value != oldValue)
		{
			_smooth = value;
			dispatchFillChangedEvent("smooth", oldValue, value);
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
	public function begin(target:Graphics, rc:Rectangle):void
	{
		buildMatrix();
		
		if (!bitmapData)
			return;
		
		target.beginBitmapFill(bitmapData, matrix, repeat, smooth);
	}
	
	/**
	 *  @private
	 */
	public function end(target:Graphics):void
	{
		target.endFill();
	}

	/**
	 *  @private
	 */
	private function buildMatrix():void
	{
		matrix = new Matrix();

		matrix.translate(-originX, -originY);
		matrix.scale(scaleX, scaleY);
		matrix.rotate(rotation);
		matrix.translate(offsetX, offsetY);
	}
	
	/**
	 *  @private
	 */
	private function dispatchFillChangedEvent(prop:String, oldValue:*,
											  value:*):void
	{
        dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, prop,
															oldValue, value));
	}
}

}
