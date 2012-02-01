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

import mx.core.UIComponent;
import mx.core.mx_internal;

import spark.components.supportClasses.Skin;
import spark.core.DisplayObjectSharingMode;
import spark.core.IGraphicElement;
import spark.primitives.supportClasses.GraphicElement;

use namespace mx_internal;

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
     *  Flag that specified whether or not this skin should be affected by baseColor.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected var useBaseColor:Boolean = true;
    
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
     *  Names of items that should not be colorized by the <code>baseColor</code> style.
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
     *  items that should be included when rendering the focus ring.
     *  Only items of type DisplayObject or GraphicElement should be excluded. Items
     *  of other types will be ignored.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get focusSkinExclusions():Array 
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
        
        // base color
        var baseColor:uint = getStyle("baseColor");
        
        if ((baseColor != DEFAULT_COLOR  || colorized) && useBaseColor)
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
    
    private static var exclusionAlphaValues:Array;
    private static var oldContentBackgroundAlpha:Number;
    private static var contentBackgroundAlphaSetLocally:Boolean;
    
    /**
     *  Called before a bitmap capture is made for this skin. The default implementation
     *  excludes items in the focusSkinExclusions array.
     */
    public function beginHighlightBitmapCapture():void
    {
		var exclusions:Array = focusSkinExclusions;
		var exclusionCount:Number = (exclusions == null) ? 0 : exclusions.length;
        
		/* we'll store off the previous alpha of the exclusions so we
		can restore them when we're done
		*/
		exclusionAlphaValues = [];
		var needRedraw:Boolean = false;
        
		for (var i:int = 0; i < exclusionCount; i++)		
		{
			var ex:Object = exclusions[i];
			/* we're going to go under the covers here to try and modify alpha with the least
			amount of disruption to the component.  For UIComponents, we go to Sprite's alpha property;
			*/
			if (ex is UIComponent)
			{
                exclusionAlphaValues[i] = (ex as UIComponent).$alpha; 
				(ex as UIComponent).$alpha = 0;
			} 
			else if (ex is DisplayObject)
			{
                exclusionAlphaValues[i] = (ex as DisplayObject).alpha; 
				(ex as DisplayObject).alpha = 0;
			}
			else if (ex is IGraphicElement) 
			{
				/* if we're lucky, the IGE has its own DisplayObject, and we can just trip its alpha.
				If not, we're going to have to set it to 0, and force a redraw of the whole component */
				var ge:IGraphicElement = ex as IGraphicElement;
				if(ge.displayObjectSharingMode == DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT)
				{
                    exclusionAlphaValues[i] = ge.displayObject.alpha;
					ge.displayObject.alpha = 0;
				}
				else
				{
                    exclusionAlphaValues[i] = ge.alpha;
					ge.alpha = 0;
					needRedraw = true;
				}
			}
        }	
        
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
        
		/* if we excluded an IGE without its own DO, we need to update the component before grabbing the bitmap */
		if (needRedraw)
			validateNow();
    }
    
    /**
     *  Called after a bitmap capture is made for this skin. The default implementation 
     *  restores the items in the focusSkinExclusions array.
     */
    public function endHighlightBitmapCapture():void
    {
        var exclusions:Array = focusSkinExclusions;
        var exclusionCount:Number = (exclusions == null) ? 0 : exclusions.length;
        var needRedraw:Boolean = false;
        
        for (var i:int=0; i < exclusionCount; i++)		
		{
			var ex:Object = exclusions[i];
			if (ex is UIComponent)
			{
				(ex as UIComponent).$alpha = exclusionAlphaValues[i];
			} 
			else if (ex is DisplayObject)
			{
				(ex as DisplayObject).alpha = exclusionAlphaValues[i];
			}
			else if (ex is IGraphicElement) 
			{
				var ge:IGraphicElement = ex as IGraphicElement;
				if (ge.displayObjectSharingMode == DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT)
				{
					ge.displayObject.alpha = exclusionAlphaValues[i];
				}
				else
				{
					ge.alpha = exclusionAlphaValues[i];			
                    needRedraw = true;
				}
			}
		}
        
        exclusionAlphaValues = null;
        
        if (!isNaN(oldContentBackgroundAlpha))
        {
            if (contentBackgroundAlphaSetLocally)
                setStyle("contentBackgroundAlpha", oldContentBackgroundAlpha);
            else
                clearStyle("contentBackgroundAlpha");
            needRedraw = true;
            oldContentBackgroundAlpha = NaN;
        }
        
        if (needRedraw)
            validateNow();
    }
}
}
