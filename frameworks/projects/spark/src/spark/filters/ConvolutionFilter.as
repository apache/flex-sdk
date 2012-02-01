////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.filters
{
import flash.filters.BitmapFilter;
import flash.filters.ConvolutionFilter;
import mx.filters.BaseFilter;
import mx.filters.IBitmapFilter;

/**
* The ConvolutionFilter class applies a matrix convolution filter effect. A convolution combines pixels
* in the input image with neighboring pixels to produce an image. A wide variety of image
* effects can be achieved through convolutions, including blurring, edge detection, sharpening,
* embossing, and beveling. You can apply the filter to any display object (that is, objects that
* inherit from the DisplayObject class), 
* such as MovieClip, SimpleButton, TextField, and Video objects, as well as to BitmapData objects.
*
* <p>To create a convolution filter, use the syntax <code>new ConvolutionFilter()</code>.
* The use of filters depends on the object to which you apply the filter:</p>
* <ul><li>To apply filters to movie clips, text fields, buttons, and video, use the
* <code>filters</code> property (inherited from DisplayObject). Setting the <code>filters</code> 
* property of an object does not modify the object, and you can remove the filter by clearing the
* <code>filters</code> property. </li>
* 
* <li>To apply filters to BitmapData objects, use the <code>BitmapData.applyFilter()</code> method.
* Calling <code>applyFilter()</code> on a BitmapData object takes the source BitmapData object 
* and the filter object and generates a filtered image as a result.</li>
* </ul>
* 
* <p>If you apply a filter to a display object, the value of the <code>cacheAsBitmap</code> property of the 
* object is set to <code>true</code>. If you clear all filters, the original value of 
* <code>cacheAsBitmap</code> is restored.</p>
*
* <p>A filter is not applied if the resulting image exceeds the maximum dimensions.
* In  AIR 1.5 and Flash Player 10, the maximum is 8,191 pixels in width or height, 
* and the total number of pixels cannot exceed 16,777,215 pixels. (So, if an image is 8,191 pixels 
* wide, it can only be 2,048 pixels high.) 
* For example, if you zoom in on a large movie clip with a filter applied, the filter is 
* turned off if the resulting image exceeds maximum dimensions.</p>
*
*  @mxml 
*  <p>The <code>&lt;s:ConvolutionFilter&gt;</code> tag inherits all of the tag 
*  attributes of its superclass and adds the following tag attributes:</p>
*
*  <pre>
*  &lt;s:ConvolutionFilter 
*    <strong>Properties</strong>
*    alpha="1"
*    clamp="true"
*    color="0xFF0000"
*    divisor="1.0"
*    matrix="[]"
*    matrixX="0"
*    matrixY="0"
*    preserveAlpha="true"
*  /&gt;
*  </pre>
*
* @langversion 3.0
* @playerversion Flash 10
* @playerversion AIR 1.5
* @productversion Flex 4
*/

public class ConvolutionFilter extends BaseFilter implements IBitmapFilter
{
    /**
     * Constructor.
     *
     * @param matrixX The <i>x</i> dimension of the matrix (the number of columns in the matrix). The 
     * default value is 0.
     * @param matrixY The <i>y</i> dimension of the matrix (the number of rows in the matrix). The 
     * default value is 0.
     * @param matrix The array of values used for matrix transformation. The number of 
     * items in the array must equal <code>matrixX ~~ matrixY</code>.
     * @param divisor The divisor used during matrix transformation. The default value is 1. 
     * A divisor that is the sum of all the matrix values evens out the overall color intensity of the
     * result. A value of 0 is ignored and the default is used instead. 
     * @param bias The bias to add to the result of the matrix transformation. The default value is 0.
     * @param preserveAlpha A value of <code>false</code> indicates that the alpha value is not
     * preserved and that the convolution applies to all
     * channels, including the alpha channel. A value of <code>true</code> indicates that 
     * the convolution applies only to the color channels. The default value is <code>true</code>.
     * @param clamp For pixels that are off the source image, a value of <code>true</code> indicates that the 
     * input image is extended along each of its borders as necessary by duplicating the color values 
     * at the given edge of the input image. A value of <code>false</code> indicates that another 
     * color should be used, as specified in the <code>color</code> and <code>alpha</code> properties. 
     * The default is <code>true</code>. 
     * @param color The hexadecimal color to substitute for pixels that are off the source image.
     * @param alpha The alpha of the substitute color.
     *
     * @langversion 3.0
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @productversion Flex 4
     */
    public function ConvolutionFilter(matrixX:Number = 0, matrixY:Number = 0, 
                                      matrix:Array = null, divisor:Number = 1.0, 
                                      bias:Number = 0.0, 
                                      preserveAlpha:Boolean = true, 
                                      clamp:Boolean = true, color:uint = 0, 
                                      alpha:Number = 0.0)
    {
        super();
        
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
    //  bias
    //----------------------------------
    
    private var _bias:Number = 0;
    
    /**
     *  The amount of bias to add to the result of the matrix transformation. 
     *  The bias increases the color value of each channel, so that dark colors 
     *  appear brighter. 
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  0xRRGGBB. 
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
    //  divisor
    //----------------------------------
    
    private var _divisor:Number = 1.0;
    
    /**
     *  The divisor used during matrix transformation. The default value is 1. 
     *  A divisor that is the sum of all the matrix values smooths out the overall 
     *  color intensity of the result. A value of 0 is ignored and the default is 
     *  used instead.
     * 
     *  @default 1.0
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @default []
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     * The x dimension of the matrix (the number of rows in the matrix). 
     * @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    
    /** 
     * Returns a copy of this filter object.
     * 
     * @return BitmapFilter A new ConvolutionFilter instance with all the same properties as the original
     * ConvolutionMatrixFilter instance.
     *
     * @langversion 3.0
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @productversion Flex 4
     */
    public function clone():BitmapFilter
    {
        return new flash.filters.ConvolutionFilter(matrixX, matrixY, matrix, divisor, 
                                                   bias, preserveAlpha, clamp, color,
                                                   alpha);
    }
    
}
}