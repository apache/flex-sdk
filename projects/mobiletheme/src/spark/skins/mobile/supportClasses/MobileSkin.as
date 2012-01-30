////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.mobile.supportClasses
{
import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.geom.ColorTransform;
import flash.geom.Matrix;

import mx.core.FlexGlobals;
import mx.core.IFlexDisplayObject;
import mx.core.ILayoutElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.utils.ColorUtil;

import spark.components.supportClasses.SkinnableComponent;
import spark.components.supportClasses.StyleableTextField;
import spark.core.DisplayObjectSharingMode;
import spark.core.IGraphicElement;
import spark.skins.IHighlightBitmapCaptureClient;

use namespace mx_internal;

// FIXME (jasonsj): do we need blendMode handling like Group?
// FIXME (jasonsj): B-feature for IFocusColorSkin may be removed
/**
 *  ActionScript-based skin for mobile applications. This skin is the 
 *  base class for all of the ActionScript mobile skins. As an optimization, 
 *  it removes state transition support.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class MobileSkin extends UIComponent implements IHighlightBitmapCaptureClient /*, IFocusColorSkin*/
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    // Used for gradient background
    protected static var matrix:Matrix = new Matrix();
    
    protected static const MOBILE_THEME_DARK_COLOR:uint = 0x484848;
    
    protected static const MOBILE_THEME_LIGHT_COLOR:uint = 0xCCCCCC;
    
    /**
     * An array of color distribution ratios.
     * This is used in the chrome color fill.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected static const CHROME_COLOR_RATIOS:Array = [0, 127.5];
    
    /**
     * An array of alpha values for the corresponding colors in the colors array. 
     * This is used in the chrome color fill.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected static const CHROME_COLOR_ALPHAS:Array = [1, 1];
    
    private static const DEFAULT_SYMBOL_COLOR_VALUE:uint = 0x00;
    
    private static var colorTransform:ColorTransform = new ColorTransform();
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     * 
     */
    public function MobileSkin()
    {
    }
    
    //--------------------------------------------------------------------------
    //
    //  Layout variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The default width of the skin.
     */
    protected var layoutMeasuredWidth:uint = 0;
    
    /**
     *  The default height of the skin.
     */
    protected var layoutMeasuredHeight:uint = 0;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Specifies whether or not this skin should be affected by the <code>chromeColor</code> style.
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var useChromeColor:Boolean = false;
    
    /**
     *  Specifies whether or not this skin should be affected by the <code>symbolColor</code> style.
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var useSymbolColor:Boolean = false;
    
    private var _focus:Boolean = false;
    
    //----------------------------------
    //  applicationDPI
    //----------------------------------
    
    /**
     *  Returns the DPI of the application. This property can only be set in MXML on the root application.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get applicationDPI():int
    {
        return FlexGlobals.topLevelApplication.applicationDPI;
    }
    
    //----------------------------------
    //  symbolItems
    //----------------------------------
    
    /**
     * Names of items that should have their <code>color</code> property defined by 
     * the <code>symbolColor</code> style.
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
    
    //----------------------------------
    //  currentState
    //----------------------------------
    
    private var _currentState:String;
    
    /**
     *  @private 
     */ 
    override public function get currentState():String
    {
        return _currentState;
    }
    
    /**
     *  @private 
     */ 
    override public function set currentState(value:String):void
    {
        if (value != _currentState)
        {
            _currentState = value;
            commitCurrentState();
        }
    }
    
    // FIXME (jasonsj): B-feature for IFocusColorSkin may be removed    
    public function get isFocusColorSupported():Boolean
    {
        return true;
    }
    
    // FIXME (jasonsj): B-feature for IFocusColorSkin may be removed
    public function get useFocusColor():Boolean
    {
        return _focus;
    }
    
    // FIXME (jasonsj): B-feature for IFocusColorSkin may be removed
    public function set useFocusColor(value:Boolean):void
    {
        if (_focus != value)
        {
            _focus = value;
            invalidateDisplayList();
        }
    }
    
    
    /**
     *  Called whenever the currentState changes. Skins should override
     *  this function if they make any appearance changes during 
     *  a state change.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */ 
    protected function commitCurrentState():void
    {
    }
    
    /**
     *  MobileSkin does not use states. Skins should override this function
     *  to return false for states that are not implemented.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */ 
    override public function hasState(stateName:String):Boolean
    {
        return true;
    }
    
    /**
     *  @private
     */ 
    override public function setCurrentState(stateName:String,
                                             playTransition:Boolean = true):void
    {
        currentState = stateName;
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        if (useChromeColor || _focus)
        {
            graphics.clear();
            
            // create gradient
            beginChromeColorFill(graphics);
            
            // draw gradient shape
            drawChromeColor(graphics, unscaledWidth, unscaledHeight);
            
            graphics.endFill();
        }
        
        // symbol color
        if (useSymbolColor)
        {
            var symbols:Array = symbolItems;
            var len:uint = (symbols) ? symbols.length : 0;
            
            if (len > 0)
            {
                var symbolColor:uint = getStyle("symbolColor");
                var symbolObj:Object;
                var transformInitialized:Boolean = false;
                
                for (var i:uint = 0; i < len; i++)
                {
                    symbolObj = this[symbols[i]];
                    
                    // SparkSkin assumed symbols were IFill objects
                    // with a color property. MobileSkin instead assumes symbols
                    // are DisplayObjects.
                    if (symbolObj is DisplayObject)
                    {
                        if (!transformInitialized)
                        {
                            colorTransform.redOffset = ((symbolColor & (0xFF << 16)) >> 16) - DEFAULT_SYMBOL_COLOR_VALUE;
                            colorTransform.greenOffset = ((symbolColor & (0xFF << 8)) >> 8) - DEFAULT_SYMBOL_COLOR_VALUE;
                            colorTransform.blueOffset = (symbolColor & 0xFF) - DEFAULT_SYMBOL_COLOR_VALUE;
                            colorTransform.alphaMultiplier = alpha;
                            
                            transformInitialized = true;
                        }
                        
                        DisplayObject(symbolObj).transform.colorTransform = colorTransform;
                    }
                }
            }
        }
    }
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Apply a color transform on a DisplayObject
     * 
     *  @param displayObject
     *  @param tintColor
     *  @param originalColor
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected function applyColorTransform(displayObject:DisplayObject, originalColor:uint, tintColor:uint):void
    {
        // FIXME (jasonsj): track what's already been tinted
        // FIXME (jasonsj): track previous color transform to bypass initialization
        if (originalColor == tintColor)
            return;
        
        colorTransform.redOffset = ((tintColor & (0xFF << 16)) >> 16) - ((originalColor & (0xFF << 16)) >> 16);
        colorTransform.greenOffset = ((tintColor & (0xFF << 8)) >> 8) - ((originalColor & (0xFF << 8)) >> 8);
        colorTransform.blueOffset = (tintColor & 0xFF) - (originalColor & 0xFF);
        colorTransform.alphaMultiplier = alpha;
        
        displayObject.transform.colorTransform = colorTransform;
    }
    
    /**
     *  Use <code>beginFill</code> or <code>beginGradientFill</code> to specify
     *  the <code>chromeColor</code> drawn by <code>drawChromeColor</code>.
     * 
     *  The default implementation uses a linear gradient fill.
     * 
     *  @param chromeColorGraphics The Graphics object to fill.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function beginChromeColorFill(chromeColorGraphics:Graphics):void
    {
        var colors:Array = [];
        matrix.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0);
        var chromeColor:uint = getChromeColor();
        colors[0] = ColorUtil.adjustBrightness2(chromeColor, 70);
        colors[1] = chromeColor;
        
        chromeColorGraphics.beginGradientFill(GradientType.LINEAR, colors, CHROME_COLOR_ALPHAS, CHROME_COLOR_RATIOS, matrix);
    }
    
    /**
     * Gets the value of the <code>chromeColor</code> style property. If the skin has focus, then this method gets
     * the value of the <code>focusColor</code> style property.
     * 
     *  @return The value of the <code>chromeColor</code> or <code>focusColor</code> style property. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function getChromeColor():uint
    {
        var chromeColorStyle:String = (_focus) ? "focusColor" : "chromeColor";
        return getStyle(chromeColorStyle);
    }
    
    /**
     *  Uses the skin's Graphics object to draw a shape containing the
     *  <code>chromeColor</code>. Fill parameters are defined by
     *  <code>beginChromeColorFill</code>.
     * 
     *  @param chromeColorGraphics The Graphics object on which to draw.
     * 
     *  @param unscaledWidth Specifies the width of the component, in pixels,
     *  in the component's coordinates, regardless of the value of the
     *  <code>scaleX</code> property of the component.
     *
     *  @param unscaledHeight Specifies the height of the component, in pixels,
     *  in the component's coordinates, regardless of the value of the
     *  <code>scaleY</code> property of the component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function drawChromeColor(chromeColorGraphics:Graphics, unscaledWidth:Number, unscaledHeight:Number):void
    {
        chromeColorGraphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
    }
    
    /**
     *  A helper method to position children elements of this component.
     * 
     *  <p>This method is the recommended way to position children elements.  You can 
     *  use this method instead of checking for and using
     *  various interfaces/classes such as ILayoutElement, IFlexDisplayObject, 
     *  or StyleableTextField.</p>
     * 
     *  <p>Call this method after calling <code>setElementSize()</code></p>
     *
     *  @param element The child element to position.  The element could be an 
     *  ILayoutElement, IFlexDisplayObject, StyleableTextField, or a generic 
     *  DisplayObject.
     *
     *  @param x The x-coordinate of the child.
     *
     *  @param y The y-coordinate of the child.
     *
     *  @see #setElementSize  
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected function setElementPosition(element:Object, x:Number, y:Number):void
    {
        if (element is ILayoutElement)
        {
            ILayoutElement(element).setLayoutBoundsPosition(x, y, false);
        }
        else if (element is IFlexDisplayObject)
        {
            IFlexDisplayObject(element).move(x, y);   
        }
        else
        {
            element.x = x;
            element.y = y;
        }
    }
    
    /**
     *  A helper method to size children elements of this component.
     * 
     *  <p>This method is the recommended way to size children elements. You can 
     *  use this method instead of checking for and using
     *  interfaces/classes such as ILayoutElement, IFlexDisplayObject, 
     *  or StyleableTextField.</p>
     *
     *  <p>Call this method before calling the <code>setElementPosition()</code> method.</p>
     * 
     *  @param element The child element to size. The element could be an 
     *  ILayoutElement, IFlexDisplayObject, StyleableTextField, or a generic 
     *  DisplayObject.
     *
     *  @param width The width of the child.
     *
     *  @param height The height of the child.
     *
     *  @see #setElementPosition  
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected function setElementSize(element:Object, width:Number, height:Number):void
    {
        if (element is ILayoutElement)
        {
            ILayoutElement(element).setLayoutBoundsSize(width, height, false);
        }
        else if (element is IFlexDisplayObject)
        {
            IFlexDisplayObject(element).setActualSize(width, height);
        }
        else
        {
            element.width = width;
            element.height = height;
        }
    }
    
    /**
     *  A helper method to retrieve the preferred width of a child element.
     * 
     *  <p>This method is the recommended way to get a child element's preferred 
     *  width. You can use this method instead of checking for and using
     *  various interfaces/classes such as ILayoutElement, IFlexDisplayObject, 
     *  or StyleableTextField.</p>
     *
     *  @param element The child element to retrieve the width for. The element could  
     *  be an ILayoutElement, IFlexDisplayObject, StyleableTextField, or a generic 
     *  DisplayObject.
     * 
     *  @return The child element's preferred width.
     *
     *  @see #sizeElement
     *  @see #getElementPreferredHeight  
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected function getElementPreferredWidth(element:Object):Number
    {
        if (element is ILayoutElement)
        {
            return ILayoutElement(element).getPreferredBoundsWidth();
        }
        else if (element is IFlexDisplayObject)
        {
            return IFlexDisplayObject(element).measuredWidth;
        }
        else if (element is StyleableTextField)
        {
            return StyleableTextField(element).measuredTextSize.x;
        }
        else
        {
            return element.width;
        }
    }
    
    /**
     *  A helper method to retrieve the preferred height of a child element.
     * 
     *  <p>This method is the recommended way to get a child element's preferred 
     *  height. You can use this method instead of checking for and using
     *  various interfaces/classes such as ILayoutElement, IFlexDisplayObject, 
     *  or StyleableTextField.</p>
     *
     *  @param element The child element to retrieve the height for. The element could  
     *  be an ILayoutElement, IFlexDisplayObject, StyleableTextField, or a generic 
     *  DisplayObject.
     *
     *  @return The child element's preferred height.
     *
     *  @see #sizeElement
     *  @see #getElementPreferredWidth 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected function getElementPreferredHeight(element:Object):Number
    {
        if (element is ILayoutElement)
        {
            return ILayoutElement(element).getPreferredBoundsHeight();
        }
        else if (element is IFlexDisplayObject)
        {
            return IFlexDisplayObject(element).measuredHeight;
        }
        else if (element is StyleableTextField)
        {
            return StyleableTextField(element).measuredTextSize.y;
        }
        else
        {
            return element.height;
        }
    }
    
    /**
     *  List of IDs of items that should be excluded when rendering the focus ring.
     *  Only items of type DisplayObject or GraphicElement should be excluded. Items
     *  of other types are ignored.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get focusSkinExclusions():Array 
    {
        return null;
    }
    
    private static var exclusionAlphaValues:Array;
    
    private static var oldContentBackgroundAlpha:Number;
    
    private static var contentBackgroundAlphaSetLocally:Boolean;
    
    /**
     *  Called before a bitmap capture is made for this skin. The default implementation
     *  excludes items in the focusSkinExclusions array.
     * 
     * @return <code>true</code> if the component needs to be redrawn; otherwise <code>false</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function beginHighlightBitmapCapture():Boolean
    {
        var exclusions:Array = focusSkinExclusions;
        if (!exclusions)
        {
            if (("hostComponent" in this) && this["hostComponent"] is SkinnableComponent)
                exclusions = SkinnableComponent(this["hostComponent"]).suggestedFocusSkinExclusions;
        }
        var exclusionCount:Number = (exclusions == null) ? 0 : exclusions.length;
        
        /* we'll store off the previous alpha of the exclusions so we
        can restore them when we're done
        */
        exclusionAlphaValues = [];
        var needRedraw:Boolean = false;
        
        for (var i:int = 0; i < exclusionCount; i++)        
        {
            // skip if the part isn't there
            if (!(exclusions[i] in this))
                continue;
            
            var ex:Object = this[exclusions[i]];
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
                if (ge.displayObjectSharingMode == DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT)
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
        return needRedraw;
    }
    
    /**
     *  Called after a bitmap capture is made for this skin. The default implementation 
     *  restores the items in the focusSkinExclusions array.
     * 
     * @return <code>true</code> if the component needs to be redrawn; otherwise <code>false</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function endHighlightBitmapCapture():Boolean
    {
        var exclusions:Array = focusSkinExclusions;
        if (!exclusions)
        {
            if (this["hostComponent"] is SkinnableComponent)
                exclusions = SkinnableComponent(this["hostComponent"]).suggestedFocusSkinExclusions;
        }
        var exclusionCount:Number = (exclusions == null) ? 0 : exclusions.length;
        var needRedraw:Boolean = false;
        
        for (var i:int=0; i < exclusionCount; i++)      
        {
            // skip if the part isn't there
            if (!(exclusions[i] in this))
                continue;
            
            var ex:Object = this[exclusions[i]];
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
        
        return needRedraw;
    }
}
}