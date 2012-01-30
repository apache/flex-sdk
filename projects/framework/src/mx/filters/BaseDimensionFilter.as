package mx.filters
{
import flash.events.IEventDispatcher;
import flash.filters.BitmapFilterQuality;

/**
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class BaseDimensionFilter extends BaseFilter
{
    public function BaseDimensionFilter()
    {
        super();
    }
        
    //----------------------------------
    //  blurX
    //----------------------------------
    
    private var _blurX:Number = 4.0;
    
    [Inspectable(minValue="0.0", maxValue="255.0")]    
    
    /**
     *  The amount of horizontal blur. Valid values are 0 to 255. A blur of 1
     *  or less means that the original image is copied as is. The default 
     *  value is 4. Values that are a power of 2 (such as 2, 4, 8, 16, and 32) 
     *  are optimized to render more quickly than other values.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    
    [Inspectable(minValue="0.0", maxValue="255.0")]    
    
    /**
     *  The amount of vertical blur. Valid values are 0 to 255. A blur of 1 
     *  or less means that the original image is copied as is. The default 
     *  value is 4. Values that are a power of 2 (such as 2, 4, 8, 16, and 32)
     *  are optimized to render more quickly than other values.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    //  knockout
    //----------------------------------
    
    private var _knockout:Boolean = false;
    
    /**
     *  Specifies whether the object has a knockout effect. A knockout effect
     *  makes the object's fill transparent and reveals the background color 
     *  of the document. The value true specifies a knockout effect; the 
     *  default value is false (no knockout effect).
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    
    [Inspectable(minValue="1", maxValue="15")]        
    
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    
    [Inspectable(minValue="0.0", maxValue="255.0")]    
    
    /**
     *  The strength of the imprint or spread. The higher the value, the more 
     *  color is imprinted and the stronger the contrast between the glow and 
     *  the background. Valid values are 0 to 255. A value of 0 means that the 
     *  filter is not applied. The default value is 1. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
}
}