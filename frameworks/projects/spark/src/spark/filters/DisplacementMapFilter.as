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
import flash.filters.DisplacementMapFilterMode;
import flash.display.BitmapData;
import flash.geom.Point;
import mx.filters.BaseFilter;
import mx.filters.IBitmapFilter;

/**
* The DisplacementMapFilter class uses the pixel values from the specified BitmapData object 
* (called the <i>displacement map image</i>) to perform a displacement of an object.
* You can use this filter to apply a warped 
* or mottled effect to any object that inherits from the DisplayObject class, 
* such as MovieClip, SimpleButton, TextField, and Video objects, as well as to BitmapData objects.
* 
* <p>The use of filters depends on the object to which you apply the filter:</p>
* <ul><li>To apply filters to a display object, use the
* <code>filters</code> property of the display object. Setting the <code>filters</code> 
* property of an object does not modify the object, and you can remove the filter by clearing the
* <code>filters</code> property. </li>
* 
* <li>To apply filters to BitmapData objects, use the <code>BitmapData.applyFilter()</code> method.
* Calling <code>applyFilter()</code> on a BitmapData object takes the source BitmapData object 
* and the filter object and generates a filtered image.</li>
* </ul>
* 
* <p>If you apply a filter to a display object, the value of the <code>cacheAsBitmap</code> property of the 
* display object is set to <code>true</code>. If you clear all filters, the original value of 
* <code>cacheAsBitmap</code> is restored.</p>
*
* <p>The filter uses the following formula:</p>
* 
* <listing>
* dstPixel[x, y] = srcPixel[x + ((componentX(x, y) - 128) ~~ scaleX) / 256, y + ((componentY(x, y) - 128) ~~scaleY) / 256)
* </listing>
* 
* <p>where <code>componentX(x, y)</code> gets the <code>componentX</code> property color value 
* from the <code>mapBitmap</code> property at <code>(x - mapPoint.x ,y - mapPoint.y)</code>.</p>
*
* <p>The map image used by the filter is scaled to match the Stage scaling.
* It is not scaled when the object itself is scaled.</p>
* 
* <p>This filter supports Stage scaling. However, general scaling, rotation, and 
* skewing are not supported. If the object itself is scaled (if the <code>scaleX</code>
* and <code>scaleY</code> properties are set to a value other than 1.0),
* the filter effect is not scaled. It is scaled only when the user zooms in on the Stage.</p>
*
*  @mxml 
*  <p>The <code>&lt;s:DisplacementMapFilter&gt;</code> tag inherits all of the tag 
*  attributes of its superclass and adds the following tag attributes:</p>
*
*  <pre>
*  &lt;s:DisplacementMapFilter 
*    <strong>Properties</strong>
*    alpha="0"
*    color="0x000000"
*    componentX="0"
*    componentY="0"
*    mapBitmap="null"
*    mapPoint="null"
*    mode="wrap"
*    scaleX="0"
*    scaleY="0"
*  /&gt;
*  </pre>
* 
* @see flash.display.BitmapData#applyFilter()
* @see flash.display.DisplayObject#filters
* @see flash.display.DisplayObject#cacheAsBitmap
* 
* @langversion 3.0
* @playerversion Flash 10
* @playerversion AIR 1.5
* @productversion Flex 4
*/
public class DisplacementMapFilter extends BaseFilter implements IBitmapFilter
{
    /**
     * Constructor.
     * 
     * @param mapBitmap A BitmapData object containing the displacement map data.
     * @param mapPoint A value that contains the offset of the upper-left corner of the
     * target display object from the upper-left corner of the map image.
     * @param componentX Describes which color channel to use in the map image to displace the <i>x</i> result. 
     * Possible values are the BitmapDataChannel constants. 
     * @param componentY Describes which color channel to use in the map image to displace the <i>y</i> result. 
     * Possible values are the BitmapDataChannel constants. 
     * @param scaleX The multiplier to use to scale the <i>x</i> displacement result from the map calculation.
     * @param scaleY The multiplier to use to scale the <i>y</i> displacement result from the map calculation.
     * @param mode The mode of the filter. Possible values are the DisplacementMapFilterMode
     * constants.
     * @param color Specifies the color to use for out-of-bounds displacements. The valid range of 
     * displacements is 0.0 to 1.0. Use this parameter if <code>mode</code> is set to <code>DisplacementMapFilterMode.COLOR</code>.
     * @param alpha Specifies what alpha value to use for out-of-bounds displacements.
     * It is specified as a normalized value from 0.0 to 1.0. For example,
     * .25 sets a transparency value of 25%. 
     * Use this parameter if <code>mode</code> is set to <code>DisplacementMapFilterMode.COLOR</code>.
     * 
     * @see flash.display.BitmapDataChannel
     * @see flash.filters.DisplacementMapFilterMode
     * @langversion 3.0
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @productversion Flex 4
     */
    public function DisplacementMapFilter(mapBitmap:BitmapData = null, 
                                          mapPoint:Point = null, componentX:uint = 0, 
                                          componentY:uint = 0, scaleX:Number = 0.0, 
                                          scaleY:Number = 0.0, mode:String = "wrap", 
                                          color:uint = 0, alpha:Number = 0.0)
    {
        super();
        
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
    
    [Inspectable(minValue="0.0", maxValue="1.0")]    
    
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
     *  <ul>
     *    <li><code>BitmapDataChannel.ALPHA</code></li>
     *    <li><code>BitmapDataChannel.BLUE</code></li>
     *    <li><code>BitmapDataChannel.GREEN</code></li>
     *    <li><code>BitmapDataChannel.RED</code></li>
     *  </ul>
     *
     *  @default 0, meaning no channel.
     *
     *  @see flash.display.BitmapDataChannel
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
     *  <ul>
     *    <li><code>BitmapDataChannel.ALPHA</code></li>
     *    <li><code>BitmapDataChannel.BLUE</code></li>
     *    <li><code>BitmapDataChannel.GREEN</code></li>
     *    <li><code>BitmapDataChannel.RED</code></li>
     *  </ul>
     *
     *  @default 0, meaning no channel.
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
     *  @default null
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
     *  @default null
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
     *  <ul>
     *    <li><code>DisplacementMapFilterMode.WRAP</code> - Wraps the displacement value to the other side
     *      of the source image.</li>
     *    <li><code>DisplacementMapFilterMode.CLAMP</code> - Clamps the displacement value to the edge of 
     *    the source image.</li>
     *    <li><code>DisplacementMapFilterMode.IGNORE</code> - If the displacement value is out of range, 
     *      ignores the displacement and uses the source pixel.</li>
     *    <li><code>DisplacementMapFilterMode.COLOR</code> - If the displacement value is outside the image, 
     *      substitutes the values in the color and alpha properties.</li>
     *  </ul>
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
    
    /**
     * Returns a copy of this filter object.
     * @return A new DisplacementMapFilter instance with all the same properties as the
     * original one.
     * 
     * @langversion 3.0
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @productversion Flex 4
     */
    public function clone():BitmapFilter
    {
        return null;
    }
    
}
}