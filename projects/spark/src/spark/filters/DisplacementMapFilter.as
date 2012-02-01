////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.filters
{
	
import flash.display.BitmapData;	
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filters.BitmapFilter;
import flash.filters.DisplacementMapFilterMode;
import flash.geom.Point;

import mx.filters.IFlexBitmapFilter;

/**
 *  @review 
 *  Dispatched when a property value has changed. 
 */ 
[Event(name="change", type="flash.events.Event")]

/**
 *  @review 
 * 
 * 	The mx.filters.DisplacementMapFilter class is based on 
 *  flash.filters.DisplacementMapFilter but adds support for dynamically updating 
 *  property values. 
 *  When a property changes, it dispatches an event that tells the filter owner to
 *  reapply the filter. Use this class instead of flash.filters.DisplacementMapFilter
 *  if you plan to dynamically change the filter property values.  
 * 
 *  @see flash.filters.DisplacementMapFilter
 */
public class DisplacementMapFilter extends EventDispatcher implements IFlexBitmapFilter
{
	include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    	
	/**
	 * @copy flash.filters.DisplacementMapFilter
	 */ 	
	public function DisplacementMapFilter(mapBitmap:BitmapData = null, 
										  mapPoint:Point = null, componentX:uint = 0, 
										  componentY:uint = 0, scaleX:Number = 0.0, 
										  scaleY:Number = 0.0, mode:String = "wrap", 
										  color:uint = 0, alpha:Number = 0.0)
	{
		super();
		
		this.mapBitmap = mapBitmap;
		this.mapPoint = mapPoint;
		this.componentX = componentX;
		this.componentY = componentY;
		this.scaleX = scaleX;
		this.scaleY = scaleY;
		this.mode = mode;
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
	
	private var _alpha:Number = 0;
	
	/**
	 *  Specifies the alpha transparency value to use for out-of-bounds 
	 *  displacements. It is specified as a normalized value from 0.0 to 1.0. For 
	 *  example, .25 sets a transparency value of 25%. The default value is 0. 
	 *  Use this property if the mode property is set to DisplacementMapFilterMode.COLOR.
	 * 
	 *  @default 0
	 */
	public function get alpha():Number
	{
		return _alpha;
	}
	
	public function set alpha(value:Number):void
	{
		if (value != _alpha)
		{
			_alpha = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
    //  color
    //----------------------------------
	
	private var _color:uint = 0x000000;
	
	/**
	 *  Specifies what color to use for out-of-bounds displacements. The valid range of 
	 *  displacements is 0.0 to 1.0. Values are in hexadecimal format. The default value 
	 *  for color is 0. Use this property if the mode property is set to 
	 *  DisplacementMapFilterMode.COLOR. 
	 *  @default 0x000000
	 */
	public function get color():uint
	{
		return _color;
	}
	
	public function set color(value:uint):void
	{
		if (value != _color)
		{
			_color = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
    //  componentX
    //----------------------------------
	
	private var _componentX:uint = 0xFF0000;
	
	/**
	 *  Describes which color channel to use in the map image to displace the x result. 
	 *  Possible values are BitmapDataChannel constants:
     *  BitmapDataChannel.ALPHA
     *  BitmapDataChannel.BLUE
     *  BitmapDataChannel.GREEN
     *  BitmapDataChannel.RED
	 */
	public function get componentX():uint
	{
		return _componentX;
	}
	
	public function set componentX(value:uint):void
	{
		if (value != _componentX)
		{
			_componentX = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
    //  componentY
    //----------------------------------
	
	private var _componentY:uint = 0xFF0000;
	
	/**
	 *  Describes which color channel to use in the map image to displace the y result. 
	 *  Possible values are BitmapDataChannel constants:
     *  BitmapDataChannel.ALPHA
     *  BitmapDataChannel.BLUE
     *  BitmapDataChannel.GREEN
     *  BitmapDataChannel.RED
	 */
	public function get componentY():uint
	{
		return _componentY;
	}
	
	public function set componentY(value:uint):void
	{
		if (value != _componentY)
		{
			_componentY = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
    //  mapBitmap
    //----------------------------------
	
	private var _mapBitmap:BitmapData;
	
	/**
	 *  A BitmapData object containing the displacement map data.
	 */
	public function get mapBitmap():BitmapData
	{
		return _mapBitmap;
	}
	
	public function set mapBitmap(value:BitmapData):void
	{
		if (value != _mapBitmap)
		{
			_mapBitmap = value;
			notifyFilterChanged();
		}
	}
		
	//----------------------------------
    //  mapPoint
    //----------------------------------
	
	private var _mapPoint:Point;
	
	/**
	 *  A value that contains the offset of the upper-left corner of the target display 
	 *  object from the upper-left corner of the map image.
	 */
	public function get mapPoint():Point
	{
		return _mapPoint;
	}
	
	public function set mapPoint(value:Point):void
	{
		if (value != _mapPoint)
		{
			_mapPoint = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
    //  mode
    //----------------------------------
	
	private var _mode:String = DisplacementMapFilterMode.WRAP;
	
	/**
	 *  The mode for the filter. Possible values are DisplacementMapFilterMode constants:
     *  - DisplacementMapFilterMode.WRAP — Wraps the displacement value to the other side
     *    of the source image.
     *  - DisplacementMapFilterMode.CLAMP — Clamps the displacement value to the edge of 
     *    the source image.
     *  - DisplacementMapFilterMode.IGNORE — If the displacement value is out of range, 
     *    ignores the displacement and uses the source pixel.
     *  - DisplacementMapFilterMode.COLOR — If the displacement value is outside the image, 
     *    substitutes the values in the color and alpha properties.
     *  
     *  @default DisplacementMapFilterMode.WRAP
     */
	public function get mode():String
	{
		return _mode;
	}
	
	public function set mode(value:String):void
	{
		if (value != _mode)
		{
			_mode = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
    //  scaleX
    //----------------------------------
	
	private var _scaleX:Number = 0;
	
	/**
	 *  The multiplier to use to scale the x displacement result from the map calculation.
	 * 
	 *  @default 0
	 */
	public function get scaleX():Number
	{
		return _scaleX;
	}
	
	public function set scaleX(value:Number):void
	{
		if (value != _scaleX)
		{
			_scaleX = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
    //  scaleY
    //----------------------------------
	
	private var _scaleY:Number = 0;
	
	/**
	 *  The multiplier to use to scale the y displacement result from the map calculation.
	 * 
	 *  @default 0
	 */
	public function get scaleY():Number
	{
		return _scaleY;
	}
	
	public function set scaleY(value:Number):void
	{
		if (value != _scaleY)
		{
			_scaleY = value;
			notifyFilterChanged();
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
   	
   	/**
     * @private
     * Notify of a change to our filter, so that filter stack is ultimately 
     * re-applied by the framework.
     */ 
	private function notifyFilterChanged():void
	{
		dispatchEvent(new Event(Event.CHANGE));
	}

	//--------------------------------------------------------------------------
	//
	//  IFlexBitmapFilter 
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  Creates a flash.filters.DisplacementMapFilter instance using the current 
	 *  property values. 
	 * 
	 *  @return flash.filters.DisplacementMapFilter instance
	 */	
	public function createBitmapFilter():BitmapFilter 
	{
		return new flash.filters.DisplacementMapFilter(mapBitmap, mapPoint, componentX, 
													   componentY, scaleX, scaleY, mode,
													   color, alpha);
	}
	
}
}