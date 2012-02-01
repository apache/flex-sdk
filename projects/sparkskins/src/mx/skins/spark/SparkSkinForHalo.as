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

import mx.core.UIComponent;

import spark.skins.SparkSkin;

[ExcludeClass]

/** 
 *  Base class for Spark skins for Halo components. This class
 *  adds support for colorizing the border with errorColor.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */    
public class SparkSkinForHalo extends SparkSkin
{   
    /**
     * Constructor.
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
     * Names of items that should have their <code>color</code> property set to the <code>errorColor</code> style
     * if the component has an errorString.
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
     * Default border item color.
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
     *  @private.
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        var borderItems:Array = this.borderItems;
        
        if (borderItems && borderItems.length > 0)
        {
            var isError:Boolean = false;
            var borderItemColor:uint;
            var errorColor:uint = getStyle("errorColor");
            
            if (getStyle("borderColor") == errorColor)
                borderItemColor = errorColor;
            else
                borderItemColor = defaultBorderItemColor;
            
            for (var i:int = 0; i < borderItems.length; i++)
            {
                if (this[borderItems[i]])
                    this[borderItems[i]].color = borderItemColor;
            }
        }

        super.updateDisplayList(unscaledWidth, unscaledHeight);
    }
}
}