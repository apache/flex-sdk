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
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.GlowFilter;
import mx.filters.IFlexBitmapFilter;

/**
 *  @review 
 *  Dispatched when a property value has changed. 
 */ 
[Event(name="change", type="flash.events.Event")]

/**
 *  @review 
 * 
 * 	The mx.filters.GlowFilter class is based on flash.filters.GlowFilter but adds 
 *  support for dynamically updating property values. 
 *  When a property changes, it dispatches an event that tells the filter owner to
 *  reapply the filter. Use this class instead of flash.filters.GlowFilter if you plan
 *  to dynamically change the filter property values.  
 * 
 *  @see flash.filters.GlowFilter
 */
public class GlowFilter extends EventDispatcher implements IFlexBitmapFilter
{
	include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    	
	/**
	 * @copy flash.filters.GlowFilter
	 */ 	
	public function GlowFilter(color:uint = 0xFF0000, alpha:Number = 1.0, 
							   blurX:Number = 6.0, blurY:Number = 6.0, 
							   strength:Number = 2, quality:int = 1, 
							   inner:Boolean = false, knockout:Boolean = false)
	{
		super();
		
		this.color = color;
		this.alpha = alpha;
		this.blurX = blurX;
		this.blurY = blurY;
		this.strength = strength;
		this.quality = quality;
		this.inner = inner;
		this.knockout = knockout;
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
	
	/**
	 *  The alpha transparency value for the color. Valid values are 0 to 1. 
	 *  For example, .25 sets a transparency value of 25%.
	 * 
	 *  @default 1
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
    //  blurX
    //----------------------------------
	
	private var _blurX:Number = 4.0;
	
	/**
	 *  The amount of horizontal blur. Valid values are 0 to 255. A blur of 1
	 *  or less means that the original image is copied as is. The default 
	 *  value is 4. Values that are a power of 2 (such as 2, 4, 8, 16, and 32) 
	 *  are optimized to render more quickly than other values.
	 */
	public function get blurX():Number
	{
		return _blurX;
	}
	
	public function set blurX(value:Number):void
	{
		if (value != _blurX)
		{
			_blurX = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
    //  blurY
    //----------------------------------
    
	private var _blurY:Number = 4.0;
	
	/**
	 *  The amount of vertical blur. Valid values are 0 to 255. A blur of 1 
	 *  or less means that the original image is copied as is. The default 
	 *  value is 4. Values that are a power of 2 (such as 2, 4, 8, 16, and 32)
	 *  are optimized to render more quickly than other values.
	 */
	public function get blurY():Number
	{
		return _blurY;
	}
	
	public function set blurY(value:Number):void
	{
		if (value != _blurY)
		{
			_blurY = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
    //  color
    //----------------------------------
	
	private var _color:uint = 0xFF0000;
	
	/**
	 *  The color of the glow. Valid values are in the hexadecimal format 
	 * 	0xRRGGBB. 
	 *  @default 0xFF0000
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
    //  inner
    //----------------------------------
	
	private var _inner:Boolean = false;
	
	/**
	 *  Specifies whether the glow is an inner glow. The value true indicates an inner glow. 
	 *  The default is false, an outer glow (a glow around the outer edges of the object).
	 */
	public function get inner():Boolean
	{
		return _inner;
	}
	
	public function set inner(value:Boolean):void
	{
		if (value != _inner)
		{
			_inner = value;
			notifyFilterChanged();
		}
	}
			
	//----------------------------------
    //  knockout
    //----------------------------------
	
	private var _knockout:Boolean = false;
	
	/**
	 *  Specifies whether the object has a knockout effect. A knockout effect
	 *  makes the object's fill transparent and reveals the background color 
	 *  of the document. The value true specifies a knockout effect; the 
	 *  default value is false (no knockout effect).
	 */
	public function get knockout():Boolean
	{
		return _knockout;
	}
	
	public function set knockout(value:Boolean):void
	{
		if (value != _knockout)
		{
			_knockout = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
    //  quality
    //----------------------------------
	
	private var _quality:int = BitmapFilterQuality.LOW;
	
	/**
	 *  The number of times to apply the filter. The default value is 
	 *  BitmapFilterQuality.LOW, which is equivalent to applying the filter 
	 *  once. The value BitmapFilterQuality.MEDIUM  applies the filter twice; 
	 *  the value BitmapFilterQuality.HIGH applies it three times. Filters 
	 *  with lower values are rendered more quickly. 
	 * 
	 *  For most applications, a quality value of low, medium, or high is 
	 *  sufficient. Although you can use additional numeric values up to 15 
	 *  to achieve different effects, higher values are rendered more slowly. 
	 *  Instead of increasing the value of quality, you can often get a similar 
	 *  effect, and with faster rendering, by simply increasing the values of 
	 *  the blurX and blurY properties.
	 */
	public function get quality():int
	{
		return _quality;
	}
	
	public function set quality(value:int):void
	{
		if (value != _quality)
		{
			_quality = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
    //  strength
    //----------------------------------
	
	private var _strength:Number = 1;
	
	/**
	 *  The strength of the imprint or spread. The higher the value, the more 
	 *  color is imprinted and the stronger the contrast between the glow and 
	 *  the background. Valid values are 0 to 255. A value of 0 means that the 
	 *  filter is not applied. The default value is 1. 
	 */
	public function get strength():Number
	{
		return _strength;
	}
	
	public function set strength(value:Number):void
	{
		if (value != _strength)
		{
			_strength = value;
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
	 *  Creates a flash.filters.GlowFilter instance using the current 
	 *  property values. 
	 * 
	 *  @return flash.filters.GlowFilter instance
	 */	
	public function createBitmapFilter():BitmapFilter 
	{
		return new flash.filters.GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout);
	}
}

}
