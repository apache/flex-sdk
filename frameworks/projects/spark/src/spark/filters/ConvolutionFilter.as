package flex.filters
{
import flash.filters.BitmapFilter;
import flash.filters.ConvolutionFilter;

public class ConvolutionFilter extends BaseFilter implements IBitmapFilter
{
	public function ConvolutionFilter(matrixX:Number = 0, matrixY:Number = 0, 
	                                  matrix:Array = null, divisor:Number = 1.0, 
	                                  bias:Number = 0.0, 
	                                  preserveAlpha:Boolean = true, 
	                                  clamp:Boolean = true, color:uint = 0, 
	                                  alpha:Number = 0.0)
	{
		this.matrixX = matrixX;
		this.matrixY = matrixY;
		this.matrix = matrix;
		this.divisor = divisor;
		this.bias = bias;
		this.preserveAlpha = preserveAlpha;
		this.clamp = clamp;
		this.color = color;
		this.alpha = alpha;
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
    //  bias
    //----------------------------------
	
	private var _bias:Number = 0;
	
	/**
	 *  The amount of bias to add to the result of the matrix transformation. 
	 *  The bias increases the color value of each channel, so that dark colors 
	 *  appear brighter. 
	 * 
	 *  @default 0
	 */
	public function get bias():Number
	{
		return _bias;
	}
	
	public function set bias(value:Number):void
	{
		if (value != _bias)
		{
			_bias = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
    //  clamp
    //----------------------------------
	
	private var _clamp:Boolean = true;
	
	/**
	 *  Indicates whether the image should be clamped. For pixels off the source image,
	 *  a value of true indicates that the input image is extended along each of its 
	 *  borders as necessary by duplicating the color values at each respective edge of 
	 *  the input image. A value of false indicates that another color should be used, 
	 *  as specified in the color and alpha properties.
	 * 
	 *  @default true
	 */
	public function get clamp():Boolean
	{
		return _clamp;
	}
	
	public function set clamp(value:Boolean):void
	{
		if (value != _clamp)
		{
			_clamp = value;
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
    //  divisor
    //----------------------------------
	
	private var _divisor:Number = 1.0;
	
	/**
	 * The divisor used during matrix transformation. The default value is 1. 
	 * A divisor that is the sum of all the matrix values smooths out the overall 
	 * color intensity of the result. A value of 0 is ignored and the default is 
	 * used instead.
	 */
	public function get divisor():Number
	{
		return _divisor;
	}
	
	public function set divisor(value:Number):void
	{
		if (value != _divisor)
		{
			_divisor = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
    //  matrix
    //----------------------------------
	
	private var _matrix:Array = [];
	
	/**
	 *  The amount of horizontal blur. Valid values are 0 to 255. A blur of 1
	 *  or less means that the original image is copied as is. The default 
	 *  value is 4. Values that are a power of 2 (such as 2, 4, 8, 16, and 32) 
	 *  are optimized to render more quickly than other values.
	 */
	public function get matrix():Array
	{
		return _matrix;
	}
	
	public function set matrix(value:Array):void
	{
		if (value != _matrix)
		{
			_matrix = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
    //  matrixX
    //----------------------------------
	
	private var _matrixX:Number = 0;
	
	/**
	 * The x dimension of the matrix (the number of columns in the matrix). 
	 * @default 0
	 */
	public function get matrixX():Number
	{
		return _matrixX;
	}
	
	public function set matrixX(value:Number):void
	{
		if (value != _matrixX)
		{
			_matrixX = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
    //  matrixY
    //----------------------------------
	
	private var _matrixY:Number = 0;
	
	/**
	 * The y dimension of the matrix (the number of columns in the matrix). 
	 * @default 0
	 */
	public function get matrixY():Number
	{
		return _matrixY;
	}
	
	public function set matrixY(value:Number):void
	{
		if (value != _matrixY)
		{
			_matrixY = value;
			notifyFilterChanged();
		}
	}
	
	//----------------------------------
    //  preserveAlpha
    //----------------------------------
	
	private var _preserveAlpha:Boolean = true;
	
	/**
	 *  Indicates if the alpha channel is preserved without the filter effect or 
	 *  if the convolution filter is applied to the alpha channel as well as the 
	 *  color channels. A value of false indicates that the convolution applies to 
	 *  all channels, including the alpha channel. A value of true indicates that 
	 *  the convolution applies only to the color channels.
	 * 
	 *  @default true
	 */
	public function get preserveAlpha():Boolean
	{
		return _preserveAlpha;
	}
	
	public function set preserveAlpha(value:Boolean):void
	{
		if (value != _preserveAlpha)
		{
			_preserveAlpha = value;
			notifyFilterChanged();
		}
	}
	
	public function clone():BitmapFilter
	{
		return new flash.filters.ConvolutionFilter(matrixX, matrixY, matrix, divisor, 
												   bias, preserveAlpha, clamp, color,
												   alpha);
	}
	
}
}