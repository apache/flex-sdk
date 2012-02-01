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
import flash.filters.GradientBevelFilter;

import mx.core.mx_internal;
import mx.filters.BaseFilter;
import mx.filters.IBitmapFilter;

use namespace mx_internal;

[DefaultProperty("entries")]
    

/**
 * The GradientBevelFilter class lets you apply a gradient bevel effect to 
 * display objects. A gradient bevel is a beveled edge, enhanced with gradient color, 
 * on the outside, inside, or top of an object. Beveled edges make objects look
 * three-dimensional.
 * You can apply the filter to any display object (that is, objects that inherit from the DisplayObject class), 
 * such as MovieClip, SimpleButton, TextField, and Video objects, as well as to BitmapData objects.
 *
 * <p>The use of filters depends on the object to which you apply the filter:</p>
 * <ul><li>To apply filters to display objects, use the
 * <code>filters</code> property. Setting the <code>filters</code> 
 * property of an object does not modify the object, and you can remove the filter by clearing the
 * <code>filters</code> property. </li>
 * 
 * <li>To apply filters to BitmapData objects, use the <code>BitmapData.applyFilter()</code> method.
 * Calling <code>applyFilter()</code> on a BitmapData object takes the source BitmapData object 
 * and the filter object and generates a filtered image as a result.</li>
 * </ul>
 * 
 * <p>If you apply a filter to a display object, the <code>cacheAsBitmap</code> property of the 
 * display object is set to <code>true</code>. If you clear all filters, the original value of 
 * <code>cacheAsBitmap</code> is restored.</p> 
 *
 * <p>This filter supports Stage scaling. However, it does not support general scaling, rotation,
 * and skewing; if the object itself is scaled (if <code>scaleX</code> and <code>scaleY</code> are set
 * to a value other than 1.0), the 
 * filter effect is not scaled. It is scaled only when the user zooms in on the Stage.</p>
 * 
 * <p>A filter is not applied if the resulting image exceeds the maximum dimensions.
 * In  AIR 1.5 and Flash Player 10, the maximum is 8,191 pixels in width or height, 
 * and the total number of pixels cannot exceed 16,777,215 pixels. (So, if an image is 8,191 pixels 
 * wide, it can only be 2,048 pixels high.) 
 * For example, if you zoom in on a large movie clip with a filter applied, the filter is 
 * turned off if the resulting image exceeds the maximum dimensions.</p>
 * 
 *  @mxml 
 *  <p>The <code>&lt;s:GradientBevelFilter&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds no tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:GradientBevelFilter/&gt;
 *  </pre>
 * 
 * @langversion 3.0
 * @playerversion Flash 10
 * @playerversion AIR 1.5
 * @productversion Flex 4
 * 
 * @see #ratios GradientBevelFilter.ratios
 * @see flash.display.BitmapData#applyFilter() 
 * @see flash.filters.BevelFilter BevelFilter
 * @see flash.display.DisplayObject#filters 
 * @see flash.display.DisplayObject#cacheAsBitmap
 */
public class GradientBevelFilter extends GradientFilter implements IBitmapFilter
{
    /**
     * Constructor.
     *
     * @param distance The offset distance. Valid values are 0 to 8. 
     * @param angle The angle, in degrees. Valid values are 0 to 360. 
     * @param colors An array of RGB hexadecimal color values to use in the gradient.
     * For example, red is 0xFF0000, blue is 0x0000FF, and so on.
     * @param alphas An array of alpha transparency values for the corresponding colors in
     * the <code>colors</code> array. Valid values for each element in the array are 0 to 1.
     * For example, .25 sets a transparency value of 25%.
     * @param ratios An array of color distribution ratios; valid values are
     * 0 to 255.
     * @param blurX The amount of horizontal blur. Valid values are 0 to 255. A blur of 1 or 
     * less means that the original image is copied as is. The default value
     * is 4. Values that are a power of 2 (such as 2, 4, 8, 16 and 32) are optimized 
     * to render more quickly than other values.
     * @param blurY The amount of vertical blur. Valid values are 0 to 255. A blur of 1 or less
     * means that the original image is copied as is. Values that are a power of 2 
     * (such as 2, 4, 8, 16 and 32) are optimized 
     * to render more quickly than other values.
     * @param strength The strength of the imprint or spread. The higher the value, the more color 
     * is imprinted and the stronger the contrast between the bevel and the background. 
     * Valid values are 0 to 255. A value of 0 means that the filter is not applied. 
     * 
     * @param quality The quality of the filter. Use BitmapFilterQuality constants:
     * <ul>
     * <li><code>BitmapFilterQuality.LOW</code></li>
     * <li><code>BitmapFilterQuality.MEDIUM</code></li>
     * <li><code>BitmapFilterQuality.HIGH</code></li>
     * </ul>
     * <p>For more information, see the description of the <code>quality</code> property.</p>
     *
     * @param type The placement of the bevel effect. Possible values are BitmapFilterType constants:
     * <ul><li><code>BitmapFilterType.OUTER</code> &#x2014; Bevel on the outer edge of the object</li>
     * <li><code>BitmapFilterType.INNER</code> &#x2014; Bevel on the inner edge of the object</li>
     * <li><code>BitmapFilterType.FULL</code> &#x2014; Bevel on top of the object</li>
     * </ul>
     * @param knockout Specifies whether a knockout effect is applied. The value <code>true</code>
     * makes the object's fill transparent and reveals the background color of the document.
     *
     * @langversion 3.0
         * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @productversion Flex 4
     *
     */
    public function GradientBevelFilter(distance:Number = 4.0, angle:Number = 45, 
                                        colors:Array = null, alphas:Array = null, 
                                        ratios:Array = null, blurX:Number = 4.0, 
                                        blurY:Number = 4.0, strength:Number = 1, 
                                        quality:int = 1, type:String = "inner", 
                                        knockout:Boolean = false)
    {
        super(colors, alphas, ratios);
        
        this.distance = distance;
        this.angle = angle;
        this.blurX =blurX ;
        this.blurY = blurY;
        this.strength = strength;
        this.quality = quality;
        this.type = type;
        this.knockout = knockout;
    }
    
    /**
     * Returns a copy of this filter object.
     * @return A new GradientBevelFilter instance with all the
     * same properties as the original GradientBevelFilter instance.
     *
     * @langversion 3.0
         * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @productversion Flex 4
     */
    public function clone():BitmapFilter 
    {
        return new flash.filters.GradientBevelFilter(distance, angle, colors, alphas, ratios, 
                                        blurX, blurY, strength, quality, type,
                                        knockout); 
    } 
        
}
}
