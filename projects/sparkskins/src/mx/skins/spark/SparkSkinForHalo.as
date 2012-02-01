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

package mx.skins.spark {

import spark.skins.SparkSkin;

/** 
 *  The SparkSkinForHalo class is the base class for Spark skins for Halo components. 
 *  This class adds support for setting the color of the border with the 
 *  value of the <code>errorColor</code> style when a validation error occurs.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */    
public class SparkSkinForHalo extends SparkSkin
{   
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function SparkSkinForHalo()
    {
        super();
    }
      
    /**
     *  If the <code>errorString</code> property of the component contains text, 
     *  this property contains the names of the items that should have their 
     *  <code>color</code> property set to the value of the <code>errorColor</code> style.
     *  The text in the <code>errorString</code> property is displayed by a component's 
     *  error tip when the component is monitored by a Validator and validation fails.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function get borderItems():Array
    {
        return null;
    }
      
    /**
     *  Default border item color.
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function get defaultBorderItemColor():uint
    {
        return 0;
    }
    
    /**
     *  Default border alpha. If NaN, don't change alpha value.
     * 
     *  @default NaN 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function get defaultBorderAlpha():Number
    {
        return NaN;
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        var borderItems:Array = this.borderItems;
        
        if (borderItems && borderItems.length > 0)
        {
            var isError:Boolean = false;
            var borderItemColor:uint;
            var errorColor:uint = getStyle("errorColor");
            var borderAlpha:Number = defaultBorderAlpha;
            
            if (getStyle("borderColor") == errorColor)
                borderItemColor = errorColor;
            else
                borderItemColor = defaultBorderItemColor;
            
            for (var i:int = 0; i < borderItems.length; i++)
            {
                if (this[borderItems[i]])
                {
                    this[borderItems[i]].color = borderItemColor;
                    if (!isNaN(borderAlpha))
                        this[borderItems[i]].alpha = borderAlpha;
                }
            }
        }

        super.updateDisplayList(unscaledWidth, unscaledHeight);
    }
}
}