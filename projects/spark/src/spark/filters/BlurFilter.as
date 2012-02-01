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
import flash.filters.BlurFilter;
import mx.filters.IFlexBitmapFilter;

/**
 *  @review 
 *  Dispatched when a property value has changed. 
 */ 
[Event(name="change", type="flash.events.Event")]

/**
 *  @review 
 * 
 * 	The mx.filters.BlurFilter class is based on flash.filters.BlurFilter but adds 
 *  support for dynamically updating property values. 
 *  When a property changes, it dispatches an event that tells the filter owner to
 *  reapply the filter. Use this class instead of flash.filters.BlurFilter if you plan
 *  to dynamically change the filter property values.  
 * 
 *  @see flash.filters.BlurFilter
 */
public class BlurFilter extends EventDispatcher implements IFlexBitmapFilter
{
	include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    	
	/**
	 * @copy flash.filters.BlurFilter
	 */ 
	public function BlurFilter(blurX:Number = 4.0, blurY:Number = 4.0, quality:int = 1)
	{
		super();
		
		this.blurX = blurX;
		this.blurY = blurY;
		this.quality = quality;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
		
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
	 *  Creates a flash.filters.BlurFilter instance using the current 
	 *  property values. 
	 * 
	 *  @return flash.filters.BlurFilter instance
	 */
	public function createBitmapFilter():BitmapFilter 
	{
		return new flash.filters.BlurFilter(blurX, blurY, quality);
	}
}
}