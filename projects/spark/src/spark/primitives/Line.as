////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package flex.graphics
{

import flash.display.Graphics;
import flash.events.EventDispatcher;
import flash.geom.Rectangle;

/**
 *  The Line class is a graphic element that draws a line between two points.
 */
public class Line extends StrokedElement
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
	public function Line()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  xFrom
	//----------------------------------

	private var _xFrom:Number = 0;
	
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]

	/**
	*  The starting x position for the line.
	*
	*  @default 0
	*/
	
	public function get xFrom():Number 
	{
		return _xFrom;
	}
	
	public function set xFrom(value:Number):void
	{
		var oldValue:Number = _xFrom;
		
		if (value != oldValue)
		{
			_xFrom = value;
			dispatchPropertyChangeEvent("xFrom", oldValue, value);
			invalidateSize();
		}
	}
	
	//----------------------------------
	//  xTo
	//----------------------------------

	private var _xTo:Number = 0;
	
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]

	/**
	*  The ending x position for the line.
	*
	*  @default 0
	*/
	
	public function get xTo():Number 
	{
		return _xTo;
	}
	
	public function set xTo(value:Number):void
	{
		var oldValue:Number = _xTo;
		
		if (value != oldValue)
		{
			_xTo = value;
			dispatchPropertyChangeEvent("xTo", oldValue, value);
			invalidateSize();
		}
	}
	
	//----------------------------------
	//  yFrom
	//----------------------------------

	private var _yFrom:Number = 0;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]

	/**
	*  The starting y position for the line.
	*
	*  @default 0
	*/
	
	public function get yFrom():Number 
	{
		return _yFrom;
	}
	
	public function set yFrom(value:Number):void
	{
		var oldValue:Number = _yFrom;
		
		if (value != oldValue)
		{
			_yFrom = value;
			dispatchPropertyChangeEvent("yFrom", oldValue, value);
			invalidateSize();
		}
	}
	
	//----------------------------------
	//  yTo
	//----------------------------------

	private var _yTo:Number = 0;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]

	/**
	*  The ending y position for the line.
	*
	*  @default 0
	*/
	
	public function get yTo():Number 
	{
		return _yTo;
	}
	
	public function set yTo(value:Number):void
	{
		var oldValue:Number = _yTo;
		
		if (value != oldValue)
		{
			_yTo = value;
			dispatchPropertyChangeEvent("yTo", oldValue, value);
			invalidateSize();
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------
	
    override public function get bounds():Rectangle
	{
	    var w:Number = isNaN(explicitWidth) ? Math.abs(xFrom - xTo) : explicitWidth;
	    var h:Number = isNaN(explicitHeight) ? Math.abs(yFrom - yTo) : explicitHeight;
		return new Rectangle(Math.min(xTo, xFrom), Math.min(yTo, yFrom),
		                     w, h);
	}
	
	/**
	 * @inheritDoc
	 */
	override protected function drawElement(g:Graphics):void
	{
        var drawToX:Number = xFrom <= xTo ? width : -width;  
        var drawToY:Number = yFrom <= yTo ? height : -height;

        drawToX += xFrom;
        drawToY += yFrom;

		g.moveTo(xFrom, yFrom);
		g.lineTo(drawToX, drawToY);
	}
}

}
