package flex.filters
{
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.BlurFilter;

public class BlurFilter extends BaseFilter implements IBitmapFilter
{
	public function BlurFilter(blurX:Number = 4.0, blurY:Number = 4.0, quality:int = 1)
	{
		this.blurX = blurX;
		this.blurY = blurY;
		this.quality = quality;
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
		
	public function clone():BitmapFilter
	{
		return new flash.filters.BlurFilter(blurX, blurY, quality);
	}
	
}
}