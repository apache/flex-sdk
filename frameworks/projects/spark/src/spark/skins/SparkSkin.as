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

package spark.skins
{
import flash.display.DisplayObject;
import flash.geom.ColorTransform;

import spark.components.supportClasses.Skin;
import spark.primitives.supportClasses.GraphicElement;

/**
 *  Base class for Spark skins.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */    
public class SparkSkin extends Skin
{
    static private const DEFAULT_COLOR_VALUE:uint = 0xCC;
    static private const DEFAULT_COLOR:uint = 0xCCCCCC;
    static private const DEFAULT_SYMBOL_COLOR:uint = 0x000000;
    
    static private var colorTransform:ColorTransform = new ColorTransform();
    
    /**
     *  Flag that specified whether or not this skin should be affected by chromeColor.
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected var useChromeColor:Boolean = false;
    
    private var colorized:Boolean = false;
    
    /**
     * Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function SparkSkin()
    {
        super();
    }
    
    /**
     *  Names of items that should not be colorized by the <code>chromeColor</code> style.
     *  Only items of type DisplayObject or GraphicElement should be excluded. Items
     *  of other types will be ignored.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get colorizeExclusions():Array
    {
        return null;
    }
    
    /**
     * Names of items that should have their <code>color</code> property defined by the <code>symbolColor</code> style.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get symbolItems():Array
    {
        return null;
    }
    
    /*
     * Names of items that should have their <code>color</code> property defined by the <code>contentBackgroundColor</code> style.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get contentItems():Array
    {
        return null;
    }
    
    private static var oldContentBackgroundAlpha:Number;
    private static var contentBackgroundAlphaSetLocally:Boolean;

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // Do all colorizing here, before calling super.updateDisplayList(). This ensures that
        // graphic elements are drawn correctly the first time, and don't trigger a redraw for
        // any new colors.
        
        var i:int;
        
        // symbol color
        var symbols:Array = symbolItems;
        
        if (symbols && symbols.length > 0)
        {
            var symbolColor:uint = getStyle("symbolColor");
            
            for (i = 0; i < symbols.length; i++)
            {
                if (this[symbols[i]])
                    this[symbols[i]].color = symbolColor;
            }
        }
        
        // content color
        var content:Array = contentItems;
        
        if (content && content.length > 0)
        {
            var contentBackgroundColor:uint = getStyle("contentBackgroundColor");
            var contentBackgroundAlpha:Number = getStyle("contentBackgroundAlpha");
            
            for (i = 0; i < content.length; i++)
            {
                if (this[content[i]])
                {
                    this[content[i]].color = contentBackgroundColor;
                    this[content[i]].alpha = contentBackgroundAlpha;
                }
            }
        }
        
        // chrome color
        var chromeColor:uint = getStyle("chromeColor");
        
        if ((chromeColor != DEFAULT_COLOR  || colorized) && useChromeColor)
        {          
            colorTransform.redOffset = ((chromeColor & (0xFF << 16)) >> 16) - DEFAULT_COLOR_VALUE;
            colorTransform.greenOffset = ((chromeColor & (0xFF << 8)) >> 8) - DEFAULT_COLOR_VALUE;
            colorTransform.blueOffset = (chromeColor & 0xFF) - DEFAULT_COLOR_VALUE;
            colorTransform.alphaMultiplier = alpha;
            
            transform.colorTransform = colorTransform;
            
            // Apply inverse colorizing to exclusions
            var exclusions:Array = colorizeExclusions;
            
            if (exclusions && exclusions.length > 0)
            {
                colorTransform.redOffset = -colorTransform.redOffset;
                colorTransform.greenOffset = -colorTransform.greenOffset;
                colorTransform.blueOffset = -colorTransform.blueOffset;
                
                for (i = 0; i < exclusions.length; i++)
                {
                    var exclusionObject:Object = this[exclusions[i]];
                    
                    if (exclusionObject &&
                        (exclusionObject is DisplayObject ||
                         exclusionObject is GraphicElement))
                    {
                        colorTransform.alphaMultiplier = exclusionObject.alpha;
                        exclusionObject.transform.colorTransform = colorTransform;
                    }
                }
            }
    
            colorized = true;
        }
        
        // Finally, call super.updateDisplayList() after setting up the colors.
        super.updateDisplayList(unscaledWidth, unscaledHeight);
    }
    
    override public function beginHighlightBitmapCapture():Boolean
    {
        var needRedraw:Boolean = super.beginHighlightBitmapCapture();

        // If we have a mostly-transparent content background, temporarily bump
        // up the contentBackgroundAlpha so the captured bitmap includes an opaque
        // snapshot of the background.
        if (getStyle("contentBackgroundAlpha") < 0.5)
        {
            if (styleDeclaration && styleDeclaration.getStyle("contentBackgroundAlpha") !== null)
                contentBackgroundAlphaSetLocally = true;
            else
                contentBackgroundAlphaSetLocally = false;
            oldContentBackgroundAlpha = getStyle("contentBackgroundAlpha");
            setStyle("contentBackgroundAlpha", 0.5);
            needRedraw = true;
        }

        return needRedraw;
    }

    override public function endHighlightBitmapCapture():Boolean
    {
        var needRedraw:Boolean = super.endHighlightBitmapCapture();

        if (!isNaN(oldContentBackgroundAlpha))
        {
            if (contentBackgroundAlphaSetLocally)
                setStyle("contentBackgroundAlpha", oldContentBackgroundAlpha);
            else
                clearStyle("contentBackgroundAlpha");
            needRedraw = true;
            oldContentBackgroundAlpha = NaN;
        }
        
        return needRedraw;
    }
    
}
}
