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
	
	private static const RADIANS_PER_DEGREES:Number = Math.PI / 180;
	
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
	[Deprecated(replacement="transformX", since="4.0")]
	
	/**
	 *  The horizontal origin for the bitmap fill.
	 *  The bitmap fill is offset so that this point appears at the origin.
	 *  Scaling and rotation of the bitmap are performed around this point.
	 *
	 *  @default 0 
	 */
	public function get originX():Number
	{
		return transformX;
	}
	
	public function set originX(value:Number):void
	{
		transformX = value;
	}
	
	//----------------------------------
	//  originY
	//----------------------------------

	private var _originY:Number = 0;

	[Bindable("propertyChange")]
	[Inspectable(category="General")]	
	[Deprecated(replacement="transformY", since="4.0")]
	
	/**
	 *  The vertical origin for the bitmap fill.
	 *  The bitmap fill is offset so that this point appears at the origin.
	 *  Scaling and rotation of the bitmap are performed around this point.
	 *
	 *  @default 0 
	 */
	public function get originY():Number
	{
		return transformY;
	}
	
	public function set originY(value:Number):void
	{
		transformY = value;
	}

	//----------------------------------
	//  offsetX
	//----------------------------------
	private var _offsetX:Number = 0;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]	
	[Deprecated(replacement="x", since="4.0")]
	
	/**
	 *  How far the bitmap is horizontally offset from the origin.
	 *  This adjustment is performed after rotation and scaling.
	 *
	 *  @default 0
	 */
	public function get offsetX():Number
	{
		return x;
	}
	
	public function set offsetX(value:Number):void
	{
		x = value;
	}

	//----------------------------------
	//  offsetY
	//----------------------------------
	private var _offsetY:Number = 0;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]	
	[Deprecated(replacement="y", since="4.0")]
	
	/**
	 *  How far the bitmap is vertically offset from the origin.
	 *  This adjustment is performed after rotation and scaling.
	 *
	 *  @default 0
	 */
	public function get offsetY():Number
	{
		return y;
	}
	
	public function set offsetY(value:Number):void
	{
		y = value;
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

	private var _source:Object;

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
		return _source;
	}
	
	/**
	 *  @private
	 */
	public function set source(value:Object):void
	{
		if (value != _source)
        {
			var tmpSprite:DisplayObject;
			var oldValue:Object = _source;
			
			var bitmapData:BitmapData;
			
			if (value is BitmapData)
			{
				bitmapData = BitmapData(value);
			}
			else if (value is Class)
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
			else if (value == null)
			{
				// This will set source to null
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
			
			_source = bitmapData;
			
			dispatchFillChangedEvent("source", oldValue, bitmapData);
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
	
	//----------------------------------
    //  transformX
    //----------------------------------
    
    private var _transformX:Number = 0;
    
    [Inspectable(category="General")]

    /**
     *  The x position transform point of the fill.
     */
    public function get transformX():Number
    {
        return _transformX;
    }

    /**
     *  @private
     */
    public function set transformX(value:Number):void
    {
        if (_transformX == value)
            return;
        
        var oldValue:Number = _transformX;    
        _transformX = value;
        dispatchFillChangedEvent("transformX", oldValue, value);
    }

    //----------------------------------
    //  transformY
    //----------------------------------
    
    private var _transformY:Number = 0;
    
    [Inspectable(category="General")]

    /**
     *  The y position transform point of the fill.
     */
    public function get transformY():Number
    {
        return _transformY;
    }

    /**
     *  @private
     */
    public function set transformY(value:Number):void
    {
        if (_transformY == value)
            return;
        
        var oldValue:Number = _transformY;    
        _transformY = value;
        dispatchFillChangedEvent("transformY", oldValue, value);
    }

	
	//----------------------------------
	//  x
	//----------------------------------
	
    private var _x:Number = 0;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  The distance by which to translate each point along the x axis.
     */
    public function get x():Number
    {
    	return _x;	
    }
    
	/**
	 *  @private
	 */
    public function set x(value:Number):void
    {
    	var oldValue:Number = _x;
    	if (value != oldValue)
    	{
    		_x = value;
    		dispatchFillChangedEvent("x", oldValue, value);
    	}
    }
    
    //----------------------------------
	//  y
	//----------------------------------
    
    private var _y:Number = 0;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
     /**
     *  The distance by which to translate each point along the y axis.
     */
    public function get y():Number
    {
    	return _y;	
    }
    
    /**
     *  @private
     */
    public function set y(value:Number):void
    {
    	var oldValue:Number = _y;
    	if (value != oldValue)
    	{
    		_y = value;
    		dispatchFillChangedEvent("y", oldValue, value);
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
		if (!source)
			return;
				
		var matrix:Matrix = new Matrix();
		matrix.translate(-transformX, -transformY);
		matrix.scale(scaleX, scaleY);
		matrix.rotate(rotation * RADIANS_PER_DEGREES);
		matrix.translate(x + rc.left + transformX, y + rc.top + transformY);
	
		target.beginBitmapFill(source as BitmapData, matrix, repeat, smooth);
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
	private function dispatchFillChangedEvent(prop:String, oldValue:*,
											  value:*):void
	{
        dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, prop,
															oldValue, value));
	}
}

}
