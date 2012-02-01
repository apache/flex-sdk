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
import flash.filters.BitmapFilterType;
import flash.filters.GradientGlowFilter;

import mx.events.PropertyChangeEvent;
import mx.filters.IFlexBitmapFilter;
import mx.graphics.GradientEntry;

/**
 *  @review 
 *  Dispatched when a property value has changed. 
 */ 
[Event(name="change", type="flash.events.Event")]

[DefaultProperty("entries")]

/**
 *  @review 
 * 
 * 	The mx.filters.GradientGlowFilter class is based on 
 *  flash.filters.GradientGlowFilter but adds support for dynamically updating 
 *  property values. 
 *  When a property changes, it dispatches an event that tells the filter owner to
 *  reapply the filter. Use this class instead of flash.filters.GradientGlowFilter if you plan
 *  to dynamically change the filter property values.  
 * 
 *  @see flash.filters.GradientGlowFilter
 */	
public class GradientGlowFilter extends EventDispatcher implements IFlexBitmapFilter
{
	include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    	
	/**
	 * @copy flash.filters.GradientGlowFilter
	 */ 		
	public function GradientGlowFilter(distance:Number = 4.0, angle:Number = 45, 
									   colors:Array = null, alphas:Array = null, 
									   ratios:Array = null, blurX:Number = 4.0, 
									   blurY:Number = 4.0, strength:Number = 1, 
									   quality:int = 1, type:String = "inner", 
									   knockout:Boolean = false)
	{
		super();
		
		this.distance = distance;
		this.angle = angle;
		this.blurX = blurX;
		this.blurY = blurY;
		this.strength = strength;
		this.quality = quality;
		this.type = type;
		this.knockout = knockout;
		
				
		var newEntries:Array = [];
		var colorsLen:int = colors ? colors.length : 0;
		var alphasLen:int = alphas ? alphas.length : 0;
		var ratiosLen:int = ratios ? ratios.length : 0;
		var maxLen:int = Math.max(colorsLen, alphasLen, ratiosLen);
		
		for (var i:int = 0; i < maxLen; i++)
		{
			var newEntry:GradientEntry = new GradientEntry();
			if (colorsLen > i)
				newEntry.color = colors[i];
			if (alphasLen > i)
				newEntry.alpha = alphas[i];
			if (ratiosLen > i)
				newEntry.ratio = ratios[i];
			
			newEntries.push(newEntry);
		}
		
		entries = newEntries;	
	}
		
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

 	/**
	 *  @private
	 */
	private var colors:Array /* of uint */ = [];

 	/**
	 *  @private
	 */
	private var ratios:Array /* of Number */ = [];

 	/**
	 *  @private
	 */
	private var alphas:Array /* of Number */ = [];
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
    //  angle
    //----------------------------------
	
	private var _angle:Number = 45;
	
	/**
	 *  The angle, in degrees. Valid values are 0 to 360. The default is 45.
	 *  The angle value represents the angle of the theoretical light source
	 *  falling on the object and determines the placement of the effect 
	 *  relative to the object. If distance is set to 0, the effect is not 
	 *  offset from the object, and therefore the angle property has no effect.
	 */
	public function get angle():Number
	{
		return _angle;
	}
	
	public function set angle(value:Number):void
	{
		if (value != _angle)
		{
			_angle = value;
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
    //  distance
    //----------------------------------
	
	private var _distance:Number = 4.0;
	
	/**
	 *  The offset distance of the glow. The default value is 4.
	 */
	public function get distance():Number
	{
		return _distance;
	}
	
	public function set distance(value:Number):void
	{
		if (value != _distance)
		{
			_distance = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
	//  entries
	//----------------------------------

 	/**
	 *  @private
	 *  Storage for the entries property.
	 */
	private var _entries:Array = [];
	
	[Bindable("propertyChange")]
    [Inspectable(category="General", arrayType="mx.graphics.GradientEntry")]

	/**
	 *  An Array of GradientEntry objects
	 *  defining the fill patterns for the gradient fill.
	 *
	 *  @default []
	 */
	public function get entries():Array
	{
		return _entries;
	}

 	/**
	 *  @private
	 */
	public function set entries(value:Array):void
	{
		var oldValue:Array = _entries;
		_entries = value;
		
		processEntries();
		notifyFilterChanged();
		//dispatchGradientChangedEvent("entries", oldValue, value);
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
		
	//----------------------------------
    //  type
    //----------------------------------
	
	private var _type:String = BitmapFilterType.INNER;
	
	/**
	 *  The placement of the filter effect. Possible values are 
	 *  flash.filters.BitmapFilterType constants:
 	 *  BitmapFilterType.OUTER — Glow on the outer edge of the object
	 *  BitmapFilterType.INNER — Glow on the inner edge of the object; the default.
	 *  BitmapFilterType.FULL — Glow on top of the object
	 */
	public function get type():String
	{
		return _type;
	}
	
	public function set type(value:String):void
	{
		if (value != _type)
		{
			_type = value;
			notifyFilterChanged();
		}
	}
		
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Extract the gradient information in the public <code>entries</code>
	 *  Array into the internal <code>colors</code>, <code>ratios</code>,
	 *  and <code>alphas</code> arrays.
	 */
	private function processEntries():void
	{
		colors = [];
		ratios = [];
		alphas = [];

		if (!_entries || _entries.length == 0)
			return;

		var ratioConvert:Number = 255;

		var i:int;
		
		var n:int = _entries.length;
		for (i = 0; i < n; i++)
		{
			var e:GradientEntry = _entries[i];
			e.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, 
							   entry_propertyChangeHandler, false, 0, true);
			colors.push(e.color);
			alphas.push(e.alpha);
			ratios.push(e.ratio * ratioConvert);
		}
		
		if (isNaN(ratios[0]))
			ratios[0] = 0;
			
		if (isNaN(ratios[n - 1]))
			ratios[n - 1] = 255;
		
		i = 1;

		while (true)
		{
			while (i < n && !isNaN(ratios[i]))
			{
				i++;
			}

			if (i == n)
				break;
				
			var start:int = i - 1;
			
			while (i < n && isNaN(ratios[i]))
			{
				i++;
			}
			
			var br:Number = ratios[start];
			var tr:Number = ratios[i];
			
			for (var j:int = 1; j < i - start; j++)
			{
				ratios[j] = br + j * (tr - br) / (i - start);
			}
		}
	}
	
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
	//  Event handlers
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private function entry_propertyChangeHandler(event:Event):void
	{
		processEntries();
	}
	
	//--------------------------------------------------------------------------
	//
	//  IFlexBitmapFilter 
	//
	//--------------------------------------------------------------------------	
	
	/**
	 *  Creates a flash.filters.GradientGlowFilter instance using the current 
	 *  property values. 
	 * 
	 *  @return flash.filters.GradientGlowFilter instance
	 */
	public function createBitmapFilter():BitmapFilter 
	{
		return new flash.filters.GradientGlowFilter(distance, angle, colors, alphas, ratios, 
										blurX, blurY, strength, quality, type,
										knockout); 
	} 
		
}
}