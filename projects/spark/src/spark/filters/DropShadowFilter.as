package mx.filters
{
import flash.filters.BitmapFilter;
import flash.filters.DropShadowFilter;
import mx.filters.BaseDimensionFilter;
import mx.filters.IBitmapFilter;

public class DropShadowFilter extends BaseDimensionFilter implements IBitmapFilter
{
	public function DropShadowFilter(distance:Number = 4.0, angle:Number = 45, 
									 color:uint = 0, alpha:Number = 1.0, 
									 blurX:Number = 4.0, blurY:Number = 4.0, 
									 strength:Number = 1.0, quality:int = 1, 
									 inner:Boolean = false, 
									 knockout:Boolean = false, 
									 hideObject:Boolean = false)
	 {
	 	this.distance = distance;
	 	this.angle = angle;
	 	this.color = color;
	 	this.alpha = alpha;
	 	this.blurX = blurX;
	 	this.blurY = blurY;
	 	this.strength = strength;
	 	this.quality = quality;
	 	this.inner = inner;
	 	this.knockout = knockout;
	 	this.hideObject = hideObject;
	 }
	
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
    //  color
    //----------------------------------
	
	private var _color:uint = 0x000000;
	
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
    //  hideObject
    //----------------------------------
	
	private var _hideObject:Boolean = false;
	
	/**
	 *  Indicates whether or not the object is hidden. The value true indicates that the 
	 *  object itself is not drawn; only the shadow is visible. 
	 *  The default is false (the object is shown).
	 */
	public function get hideObject():Boolean
	{
		return _hideObject;
	}
	
	public function set hideObject(value:Boolean):void
	{
		if (value != _hideObject)
		{
			_hideObject = value;
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
	
	public function clone():BitmapFilter
	{
		return new flash.filters.DropShadowFilter(distance, angle, color, alpha, blurX, 
												  blurY, strength, quality, inner, 
												  knockout, hideObject);
	}
		
}
	
}