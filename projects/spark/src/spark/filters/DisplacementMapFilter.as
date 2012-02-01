package spark.filters
{
	

import flash.filters.BitmapFilter;
import flash.filters.DisplacementMapFilterMode;
import flash.display.BitmapData;
import flash.geom.Point;
import mx.filters.BaseFilter;
import mx.filters.IBitmapFilter;

public class DisplacementMapFilter extends BaseFilter implements IBitmapFilter
{
	public function DisplacementMapFilter(mapBitmap:BitmapData = null, 
										  mapPoint:Point = null, componentX:uint = 0, 
										  componentY:uint = 0, scaleX:Number = 0.0, 
										  scaleY:Number = 0.0, mode:String = "wrap", 
										  color:uint = 0, alpha:Number = 0.0)
	{
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
	
	private var _color:uint = 0x000000;
	
	/**
	 *  Specifies what color to use for out-of-bounds displacements. The valid range of 
	 *  displacements is 0.0 to 1.0. Values are in hexadecimal format. The default value 
	 *  for color is 0. Use this property if the mode property is set to 
	 *  DisplacementMapFilterMode.COLOR. 
	 *  @default 0x000000
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
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
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
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
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
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
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
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
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
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
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
	
	public function clone():BitmapFilter
	{
		return null;
	}
	
}
}