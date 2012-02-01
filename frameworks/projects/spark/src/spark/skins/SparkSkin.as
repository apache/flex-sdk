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
import spark.components.supportClasses.Skin;
import flash.geom.ColorTransform;
import flash.display.DisplayObject;
import spark.primitives.supportClasses.StrokedElement;
import mx.graphics.SolidColor;
import flash.events.Event;

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
    
    public var colorized:Boolean = false;
    
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
     * Names of items that should not be colorized by the <code>baseColor</code> style.
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
            
            for (i = 0; i < content.length; i++)
            {
                if (this[content[i]])
                    this[content[i]].color = contentBackgroundColor;
            }
        }
        
        // base color
        var baseColor:uint = getStyle("baseColor");
        
        if (baseColor != DEFAULT_COLOR  || colorized)
        {          
            colorTransform.redOffset = ((baseColor & (0xFF << 16)) >> 16) - DEFAULT_COLOR_VALUE;
            colorTransform.greenOffset = ((baseColor & (0xFF << 8)) >> 8) - DEFAULT_COLOR_VALUE;
            colorTransform.blueOffset = (baseColor & 0xFF) - DEFAULT_COLOR_VALUE;
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
                    
                    if (exclusionObject)
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
}
}
