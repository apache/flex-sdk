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
import flash.events.EventDispatcher;
import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.mx_internal;

/**
 *  The Rect class is a filled graphic element that draws a rectangle.
 *  The corners of the rectangle can be rounded.
 */
public class Rect extends FilledElement
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
	public function Rect()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
			
	//----------------------------------
	//  radiusX
	//----------------------------------

	private var _radiusX:Number = 0;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	
	/**
	 *  The corner radius to use along the x axis.
	 */
	public function get radiusX():Number 
	{
		return _radiusX;
	}
	
	public function set radiusX(value:Number):void
	{
		var oldValue:Number = _radiusX;
		
		if (value != oldValue)
		{
			_radiusX = value;
			dispatchPropertyChangeEvent("radiusX", oldValue, value);
			invalidateDisplayList();
			// No need to invalidateSize() since we don't use radiusX to compute size 
		}
	}
	
	//----------------------------------
	//  radiusY
	//----------------------------------

	private var _radiusY:Number = 0;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	
	/**
	 *  The corner radius to use along the y axis.
	 */
	public function get radiusY():Number 
	{
		return _radiusY;
	}

	public function set radiusY(value:Number):void
	{
		var oldValue:Number = _radiusY;
		
		if (value != oldValue)
		{
			_radiusY = value;
			dispatchPropertyChangeEvent("radiusY", oldValue, value);
			invalidateDisplayList();
			// No need to invalidateSize() since we don't use radiusY to compute size 
		}
	}
		
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------
	
	override public function get bounds():Rectangle
	{
		return new Rectangle(0, 0,
		                     isNaN(explicitWidth) ? 0 : explicitWidth,
		                     isNaN(explicitHeight) ? 0 : explicitHeight);
	}
	
	/**
	 *  @inheritDoc
	 */
	override protected function drawElement(g:Graphics):void
	{
		if (radiusX != 0 || radiusY != 0)
			g.drawRoundRect(0, 0, width, height, radiusX * 2, radiusY * 2);
		else
			g.drawRect(0, 0, width, height);
	}

}

}
