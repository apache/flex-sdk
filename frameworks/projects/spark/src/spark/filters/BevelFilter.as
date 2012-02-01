package mx.filters
{
import flash.events.IEventDispatcher;
import flash.filters.BevelFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterType;
import mx.filters.BaseDimensionFilter;
import mx.filters.IBitmapFilter;

public class BevelFilter extends BaseDimensionFilter implements IBitmapFilter
{
	public function BevelFilter(distance:Number = 4.0, angle:Number = 45, 
								highlightColor:uint = 0xFFFFFF, highlightAlpha:Number = 1.0, 
								shadowColor:uint = 0x000000, shadowAlpha:Number = 1.0, 
								blurX:Number = 4.0, blurY:Number = 4.0, strength:Number = 1, 
								quality:int = 1, type:String = "inner", 
								knockout:Boolean = false)
	{
		this.distance = distance;
		this.angle = angle;
		this.highlightColor = highlightColor;
		this.highlightAlpha = highlightAlpha;
		this.shadowColor = shadowColor;
		this.shadowAlpha = shadowAlpha;
		this.blurX = blurX;
		this.blurY = blurY;
		this.strength = strength;
		this.quality = quality;
		this.type = type;
		this.knockout = knockout;	
	}
	
	//----------------------------------
    //  angle
    //----------------------------------
	
	private var _angle:Number = 45;
	
	/**
	 *   The angle of the bevel. Valid values are from 0 to 360°. 
	 *   The angle value represents the angle of the theoretical light source falling on the 
	 *   object and determines the placement of the effect relative to the object. 
	 *   If the distance property is set to 0, the effect is not offset from the object and, 
	 *   therefore, the angle property has no effect.
	 * 
	 *   @default 45
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
    //  distance
    //----------------------------------
	
	private var _distance:Number = 4.0;
	
	/**
	 *  The offset distance of the bevel. Valid values are in pixels (floating point). 
	 * 	@default 4
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
    //  highlightAlpha
    //----------------------------------
	
	private var _highlightAlpha:Number = 1.0;
	
	/**
	 *  The alpha transparency value of the highlight color. The value is specified as a normalized 
	 *  value from 0 to 1. For example, .25 sets a transparency value of 25%. 
	 *  @default 1
	 */
	public function get highlightAlpha():Number
	{
		return _highlightAlpha;
	}
	
	public function set highlightAlpha(value:Number):void
	{
		if (value != _highlightAlpha)
		{
			_highlightAlpha = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
    //  highlightColor
    //----------------------------------
	
	private var _highlightColor:uint = 0xFFFFFF;
	
	/**
	 *  The highlight color of the bevel. Valid values are in hexadecimal format, 0xRRGGBB. 
	 *  @default 0xFFFFFF
	 */
	public function get highlightColor():uint
	{
		return _highlightColor;
	}
	
	public function set highlightColor(value:uint):void
	{
		if (value != _highlightColor)
		{
			_highlightColor = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
    //  shadowAlpha
    //----------------------------------
	
	private var _shadowAlpha:Number = 1.0;
	
	/**
	 *  The alpha transparency value of the shadow color. This value is specified as a 
	 *  normalized value from 0 to 1. For example, .25 sets a transparency value of 25%.
	 * 
	 *  @default 1
	 */
	public function get shadowAlpha():Number
	{
		return _shadowAlpha;
	}
	
	public function set shadowAlpha(value:Number):void
	{
		if (value != _shadowAlpha)
		{
			_shadowAlpha = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
    //  shadowColor
    //----------------------------------
	
	private var _shadowColor:uint = 0x000000;
	
	/**
	 *  The shadow color of the bevel. Valid values are in hexadecimal format, 0xRRGGBB. 
	 *  @default 0x000000
	 */
	public function get shadowColor():uint
	{
		return _shadowColor;
	}
	
	public function set shadowColor(value:uint):void
	{
		if (value != _shadowColor)
		{
			_shadowColor = value;
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
	
	public function clone():BitmapFilter 
	{
		return new flash.filters.BevelFilter(distance, angle, highlightColor, highlightAlpha,
											 shadowColor, shadowAlpha, blurX, blurY, strength,
											 quality, type, knockout);
	} 

}

}