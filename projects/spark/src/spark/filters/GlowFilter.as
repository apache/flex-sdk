package mx.filters
{
import flash.filters.BitmapFilter;
import flash.filters.GlowFilter;
import mx.filters.BaseDimensionFilter;
import mx.filters.IBitmapFilter;

public class GlowFilter extends BaseDimensionFilter implements IBitmapFilter
{
	public function GlowFilter(color:uint = 0xFF0000, alpha:Number = 1.0, 
							   blurX:Number = 6.0, blurY:Number = 6.0, 
							   strength:Number = 2, quality:int = 1, 
							   inner:Boolean = false, knockout:Boolean = false)
	{
		this.color = color;
		this.alpha = alpha;
		this.blurX = blurX;
		this.blurY = blurY;
		this.strength = strength;
		this.quality = quality;
		this.inner = inner;
		this.knockout = knockout;
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
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
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
	
	private var _color:uint = 0xFF0000;
	
	/**
	 *  The color of the glow. Valid values are in the hexadecimal format 
	 * 	0xRRGGBB. 
	 *  @default 0xFF0000
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
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
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
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
		return new flash.filters.GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout);
	}



	
}

}
