////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2004-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.graphics
{

import flash.display.Graphics;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.events.PropertyChangeEvent;

[DefaultProperty("color")]

/** 
 *  Defines a representation for a color,
 *  including a color and an alpha value. 
 *  
 *  @see mx.graphics.IFill
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class SolidColor extends EventDispatcher implements IFill
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
	 *  @param color Specifies the color.
	 *  The default value is 0x000000 (black).
	 *
	 *  @param alpha Specifies the level of transparency.
	 *  Valid values range from 0.0 (completely transparent)
	 *  to 1.0 (completely opaque).
	 *  The default value is 1.0.
 	 *  
 	 *  @langversion 3.0
 	 *  @playerversion Flash 9
 	 *  @playerversion AIR 1.1
 	 *  @productversion Flex 3
 	 */
	public function SolidColor(color:uint = 0x000000, alpha:Number = 1.0)
 	{
		super();

		this.color = color;
		this.alpha = alpha;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  alpha
	//----------------------------------

	private var _alpha:Number = 1.0;
	
	[Bindable("propertyChange")]
    [Inspectable(category="General", minValue="0.0", maxValue="1.0")]

	/**
	 *  The transparency of a color.
	 *  Possible values are 0.0 (invisible) through 1.0 (opaque). 
	 *  
	 *  @default 1.0
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get alpha():Number
	{
		return _alpha;
	}
	
	public function set alpha(value:Number):void
	{
		var oldValue:Number = _alpha;
		if (value != oldValue)
		{
			_alpha = value;
			dispatchFillChangedEvent("alpha", oldValue, value);
		}
	}
	
	//----------------------------------
	//  color
	//----------------------------------

	private var _color:uint = 0x000000;
	
	[Bindable("propertyChange")]
    [Inspectable(category="General", format="Color")]

	/**
	 *  A color value. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get color():uint
	{
		return _color;
	}
	
	public function set color(value:uint):void
	{
		var oldValue:uint = _color;
		if (value != oldValue)
		{
			_color = value;
			dispatchFillChangedEvent("color", oldValue, value);
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @inheritDoc
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function begin(target:Graphics, targetBounds:Rectangle, targetOrigin:Point):void
	{
		target.beginFill(color, alpha);
	}
	
	/**
	 *  @inheritDoc
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
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
        if (hasEventListener("propertyChange")) 
            dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, prop,
			    oldValue, value));
	}
}

}
