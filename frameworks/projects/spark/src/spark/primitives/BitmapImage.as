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
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.geom.Transform;
import flash.utils.getDefinitionByName;

import mx.core.mx_internal;
import mx.events.PropertyChangeEvent;
import mx.graphics.BitmapFill;


import flex.filters.BaseFilter;
import flex.filters.IBitmapFilter;
import flex.graphics.graphicsClasses.GraphicElement;

/**
 *  The BitmapGraphic class is a graphic element that draws a bitmap.
 */
public class BitmapGraphic extends GraphicElement implements IDisplayObjectElement
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
	public function BitmapGraphic()
	{
		super();
		
		_fill = new BitmapFill();
	}
	
	private var _fill:BitmapFill;
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  alwaysNeedsDisplayObject
	//----------------------------------
	
	private var _alwaysNeedsDisplayObject:Boolean = false;
	
	/*
	 *  Set this to true to force the Graphic Element to create an underlying Shape
	 */
	mx_internal function set alwaysNeedsDisplayObject(value:Boolean):void
	{
		if (value != _alwaysNeedsDisplayObject)
		{
			_alwaysNeedsDisplayObject = value;
			notifyElementLayerChanged();
		}
	}
	
	mx_internal function get alwaysNeedsDisplayObject():Boolean
	{
		return _alwaysNeedsDisplayObject;
	}
	
	//----------------------------------
	//  repeat
	//----------------------------------

	protected var _repeat:Boolean = true;
	
	[Bindable("propertyChange")]
	[Inspectable(category="General")]

	/**
	 *  Whether the bitmap is repeated to fill the area. Set to <code>true</code> to cause 
	 *  the fill to tile outward to the edges of the filled region. 
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
			invalidateDisplayList();
			//dispatchPropertyChangeEvent("repeat", oldValue, value);
		}
	}

	//----------------------------------
	//  source
	//----------------------------------

	[Bindable("propertyChange")]
	[Inspectable(category="General")]

	/**
	 *  The source used for the bitmap fill. The fill can render from various graphical 
	 *  sources, including the following: 
	 *  <ul>
	 *   <li>A Bitmap or BitmapData instance.</li>
	 *   <li>A class representing a subclass of DisplayObject. The BitmapFill instantiates 
	 *       the class and creates a bitmap rendering of it.</li>
	 *   <li>An instance of a DisplayObject. The BitmapFill copies it into a Bitmap for filling.</li>
	 *   <li>The name of a subclass of DisplayObject. The BitmapFill loads the class, instantiates it, 
	 *       and creates a bitmap rendering of it.</li>
	 *  </ul>
	 */
	public function get source():Object
	{
		return _fill.source;
	}
	
	public function set source(value:Object):void
	{
		var oldValue:Object = _fill.source;
		
		if (value != oldValue)
		{
			var bitmapData:BitmapData;
			var tmpSprite:DisplayObject;
			
			// This code stolen from BitmapFill. The only change is to make the BitmapData transparent.
			if (value is Class)
			{
				var cls:Class = Class(value);
				tmpSprite = new cls();
			}
			else if (value is BitmapData)
			{
				bitmapData = value as BitmapData;
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
				bitmapData = new BitmapData(tmpSprite.width, tmpSprite.height, true, 0);
				bitmapData.draw(tmpSprite, new Matrix());
			}		
			
			_fill.source = bitmapData;
			dispatchPropertyChangeEvent("source", oldValue, value);
			invalidateSize();
			invalidateDisplayList();
		}
	}
	
	//----------------------------------
	//  smooth
	//----------------------------------

	private var _smooth:Boolean = false;

	[Inspectable(category="General")]	
	
	/**
	 *  A flag indicating whether to smooth the bitmap data
	 *  when filling with it.
	 *
	 *  @default false
	 */
	public function set smooth(value:Boolean):void
	{
		if (value != _smooth)
		{
			_smooth = value;
			invalidateDisplayList();
		}
	}
	
	public function get  smooth():Boolean
	{
		return _smooth;
	}
	
	//--------------------------------------------------------------------------
	//
	//  IGraphicElement Implementation
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @inheritDoc
	 */
    override protected function measure():void
    {
        measuredWidth = source ? source.width : 0;
        measuredHeight = source ? source.height : 0;
    }
	
	/**
	 *  @inheritDoc
	 */
    override protected function updateDisplayList(unscaledWidth:Number, 
                                                  unscaledHeight:Number):void
	{
	    if (!displayObject || !(displayObject is Sprite))
	        return;
	    var g:Graphics = Sprite(displayObject).graphics;
	    
	    // TODO EGeorgie: clearing the graphics needs to be shared when
	    // the display objects are shared.
	    g.clear();
	    
		g.lineStyle(0,0,0);
		_fill.offsetX = 0;
		_fill.offsetY = 0;
		_fill.repeat = repeat;
		_fill.smooth = smooth;
		var w:Number = unscaledWidth;
		var h:Number = unscaledHeight;
		
		if (!repeat && source)
		{
			w = Math.min(w, source.width);
			h = Math.min(h, source.height);	
		}
		
		_fill.begin(g, new Rectangle(w, h));
		g.drawRect(0, 0, w, h);
		_fill.end(g);
	}
	
	//--------------------------------------------------------------------------
	//
	//  IAssignableDisplayObject Implementation
	//
	//--------------------------------------------------------------------------

}

}
