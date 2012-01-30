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
public class MobileSkin extends UIComponent implements IHighlightBitmapCaptureClient
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Dark <code>chromeColor</code> used in ViewNavigator and
     *  TabbedViewNavigator "chrome" elements: ActionBar and
     *  TabbedViewNavigator#tabBar.
     */
    mx_internal static const MOBILE_THEME_DARK_COLOR:uint = 0x484848;
    
    /**
     *  @private
     *  Default <code>chromeColor</code> for the mobile theme.
     */
    mx_internal static const MOBILE_THEME_LIGHT_COLOR:uint = 0xCCCCCC;
    
    /**
     *  @private
     *  Default symbol color for <code>symbolColor</code> style.
     */
    mx_internal static const DEFAULT_SYMBOL_COLOR_VALUE:uint = 0x00;
    
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
    //  Variables
    //
    //--------------------------------------------------------------------------
    
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
    
    /**
     *  @private
     *  Toggles transparent, centered hit-area if the unscaled size is less
     *  than one-quarter inch square. Physical size is based on applicationDPI.
     */
    mx_internal var useMinimumHitArea:Boolean = true;
    
    /**
     *  Specifies a default width. <code>measuredWidth</code> returns this value
     *  when the computed <code>measuredWidth</code> is less than
     *  <code>measuredDefaultWidth</code>.
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var measuredDefaultWidth:Number = 0;
    
    /**
     *  Specifies a default height. <code>measuredHeight</code> returns this value
     *  when the computed <code>measuredHeight</code> is less than
     *  <code>measuredDefaultHeight</code>.
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var measuredDefaultHeight:Number = 0;
    
    //----------------------------------
    //  colorMatrix
    //----------------------------------
    
    private static var _colorMatrix:Matrix = new Matrix();
    
    /**
     *  @private
     */
    mx_internal static function get colorMatrix():Matrix
    {
        if (!_colorMatrix)
            _colorMatrix = new Matrix();
        
        return _colorMatrix;
    }
    
    //----------------------------------
    //  colorTransform
    //----------------------------------
    
    private static var _colorTransform:ColorTransform;
    
    /**
     *  @private
     */
    mx_internal static function get colorTransform():ColorTransform
    {
        if (!_colorTransform)
            _colorTransform = new ColorTransform();
        
        return _colorTransform;
    }
    
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
    protected function get applicationDPI():Number
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
    protected function get symbolItems():Array
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
     * @param stateName The state name.
     * 
     * @return false for states that are not implemented.
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
    override public function get measuredWidth():Number
    {
        return Math.max(super.measuredWidth, measuredDefaultWidth);
    }
    
    /**
     *  @private
     */ 
    override public function get measuredHeight():Number
    {
        return Math.max(super.measuredHeight, measuredDefaultHeight);
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        graphics.clear();
        
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        layoutContents(unscaledWidth, unscaledHeight);
        
        if (useSymbolColor)
            applySymbolColor();
        
        if (useMinimumHitArea)
            drawMinimumHitArea(unscaledWidth, unscaledHeight);
        
        drawBackground(unscaledWidth, unscaledHeight);
    }
    
    /**
     *  @private
     *  Make the component's explicitMinWidth property override its skin's.
     *  This is useful for cases where the skin's minWidth constrains
     *  the skin's measured size. In those cases the user could set
     *  explicit limits on the component itself thus relaxing the
     *  hard-coded limits in the skin. See SDK-24741.
     */
    override public function get explicitMinWidth():Number
    {
        if (parent is SkinnableComponent)
        {
            var parentExplicitMinWidth:Number = SkinnableComponent(parent).explicitMinWidth;
            if (!isNaN(parentExplicitMinWidth))
                return parentExplicitMinWidth;
        }
        return super.explicitMinWidth;
    }
    
    /**
     *  @private
     *  Make the component's explicitMinWidth property override its skin's.
     *  This is useful for cases where the skin's minWidth constrains
     *  the skin's measured size. In those cases the user could set
     *  explicit limits on the component itself thus relaxing the
     *  hard-coded limits in the skin. See SDK-24741.
     */
    override public function get explicitMinHeight():Number
    {
        if (parent is SkinnableComponent)
        {
            var parentExplicitMinHeight:Number = SkinnableComponent(parent).explicitMinHeight;
            if (!isNaN(parentExplicitMinHeight))
                return parentExplicitMinHeight;
        }
        return super.explicitMinHeight;
    }
    
    /**
     *  @private
     *  Make the component's explicitMinWidth property override its skin's.
     *  This is useful for cases where the skin's minWidth constrains
     *  the skin's measured size. In those cases the user could set
     *  explicit limits on the component itself thus relaxing the
     *  hard-coded limits in the skin. See SDK-24741.
     */
    override public function get explicitMaxWidth():Number
    {
        if (parent is SkinnableComponent)
        {
            var parentExplicitMaxWidth:Number = SkinnableComponent(parent).explicitMaxWidth;
            if (!isNaN(parentExplicitMaxWidth))
                return parentExplicitMaxWidth;
        }
        return super.explicitMaxWidth;
    }
    
    /**
     *  @private
     *  Make the component's explicitMinWidth property override its skin's.
     *  This is useful for cases where the skin's minWidth constrains
     *  the skin's measured size. In those cases the user could set
     *  explicit limits on the component itself thus relaxing the
     *  hard-coded limits in the skin. See SDK-24741.
     */
    override public function get explicitMaxHeight():Number
    {
        if (parent is SkinnableComponent)
        {
            var parentExplicitMaxHeight:Number = SkinnableComponent(parent).explicitMaxHeight;
            if (!isNaN(parentExplicitMaxHeight))
                return parentExplicitMaxHeight;
        }
        return super.explicitMaxHeight;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------
    
    mx_internal function drawMinimumHitArea(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // minimum hit area is 0.25 inches square
        var minSize:Number = applicationDPI / 4;
        
        // skip if skin size is larger than minimum
        if ((unscaledWidth > minSize) && (unscaledHeight > minSize))
            return;
        
        // center a transparent hit area larger than the skin
        var hitAreaWidth:Number = Math.max(minSize, unscaledWidth);
        var hitAreaHeight:Number = Math.max(minSize, unscaledHeight);
        var hitAreaX:Number = (unscaledWidth - hitAreaWidth) / 2;
        var hitAreaY:Number = (unscaledHeight - hitAreaHeight) / 2;
        
        graphics.beginFill(0, 0);
        graphics.drawRect(hitAreaX, hitAreaY, hitAreaWidth, hitAreaHeight);
        graphics.endFill();
    }
    
    /**
     *  Positions the children for this skin.
     * 
     *  <p>This method, along with <code>colorizeContents()</code>, is called 
     *  by the <code>updateDisplayList()</code> method.</p>
     * 
     *  <p>This method positions skin parts and graphic children of the skin.  
     *  Subclasses should override this to position their children.</p>
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
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        
    }
    
    /**
     *  A helper method to set a color transform on a DisplayObject.
     * 
     *  @param displayObject The display object to transform
     *  @param originalColor The original color
     *  @param tintColor The desired color
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected function applyColorTransform(displayObject:DisplayObject, originalColor:uint, tintColor:uint):void
    {
        colorTransform.redOffset = ((tintColor & (0xFF << 16)) >> 16) - ((originalColor & (0xFF << 16)) >> 16);
        colorTransform.greenOffset = ((tintColor & (0xFF << 8)) >> 8) - ((originalColor & (0xFF << 8)) >> 8);
        colorTransform.blueOffset = (tintColor & 0xFF) - (originalColor & 0xFF);
        colorTransform.alphaMultiplier = alpha;
        
        displayObject.transform.colorTransform = colorTransform;
    }
    
    /**
     *  Renders a background for the skin.
     * 
     *  <p>This method, along with <code>layoutContents()</code>, is called 
     *  by the <code>updateDisplayList()</code>.</p>
     * 
     *  <p>This method draws the background chromeColor.
     *  Override this method to change the appearance of the chromeColor.</p>
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
    protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        
    }
    
    /**
     *  @private
     */
    mx_internal function applySymbolColor():void
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
    protected function get focusSkinExclusions():Array 
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