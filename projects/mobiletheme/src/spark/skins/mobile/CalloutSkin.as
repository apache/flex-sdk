////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.mobile
{
import flash.display.BlendMode;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;

import mx.core.DPIClassification;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.utils.ColorUtil;

import spark.components.ArrowDirection;
import spark.components.Callout;
import spark.components.ContentBackgroundAppearance;
import spark.components.Group;
import spark.core.SpriteVisualElement;
import spark.effects.Fade;
import spark.primitives.RectangularDropShadow;
import spark.skins.mobile.supportClasses.CalloutArrow;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile160.assets.CalloutContentBackground;
import spark.skins.mobile240.assets.CalloutContentBackground;
import spark.skins.mobile320.assets.CalloutContentBackground;

use namespace mx_internal;

/**
 *  The default skin class for the Spark Callout component in mobile
 *  applications.
 * 
 *  <p>The <code>contentGroup</code> lies above a <code>backgroundColor</code> fill
 *  which frames the <code>contentGroup</code>. The position and size of the frame 
 *  adjust based on the host component <code>arrowDirection</code>, leaving
 *  space for the <code>arrow</code> to appear on the outside edge of the
 *  frame.</p>
 * 
 *  <p>The <code>arrow</code> skin part is not positioned by the skin. Instead,
 *  the Callout component positions the arrow relative to the owner in
 *  <code>updateSkinDisplayList()</code>. This method assumes that Callout skin
 *  and the <code>arrow</code> use the same coordinate space.</p>
 *  
 *  @see spark.components.Callout
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */ 
public class CalloutSkin extends MobileSkin
{
    mx_internal static const BACKGROUND_GRADIENT_BRIGHTNESS_TOP:int = 15;
    
    mx_internal static const BACKGROUND_GRADIENT_BRIGHTNESS_BOTTOM:int = -60;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor. 
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function CalloutSkin()
    {
        super();
        
        dropShadowAlpha = 0.7;
        
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                backgroundCornerRadius = 16;
                contentBackgroundInsetClass = spark.skins.mobile320.assets.CalloutContentBackground;
                backgroundGradientHeight = 220;
                frameThickness = 16;
                arrowWidth = 104;
                arrowHeight = 52;
                contentCornerRadius = 10;
                dropShadowBlurX = 32;
                dropShadowBlurY = 32;
                dropShadowDistance = 6;
                highlightWeight = 2;
                
                break;
            }
            case DPIClassification.DPI_240:
            {
                backgroundCornerRadius = 12;
                contentBackgroundInsetClass = spark.skins.mobile240.assets.CalloutContentBackground;
                backgroundGradientHeight = 165;
                frameThickness = 12;
                arrowWidth = 78;
                arrowHeight = 39;
                contentCornerRadius = 7;
                dropShadowBlurX = 24;
                dropShadowBlurY = 24;
                dropShadowDistance = 4;
                highlightWeight = 1;
                
                break;
            }
            default:
            {
                // default DPI_160
                backgroundCornerRadius = 8;
                contentBackgroundInsetClass = spark.skins.mobile160.assets.CalloutContentBackground;
                backgroundGradientHeight = 110;
                frameThickness = 8;
                arrowWidth = 52;
                arrowHeight = 26;
                contentCornerRadius = 5;
                dropShadowBlurX = 16;
                dropShadowBlurY = 16;
                dropShadowDistance = 3;
                highlightWeight = 1;
                
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /** 
     *  @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
    public var hostComponent:Callout;
    
    /**
     *  Enables a RectangularDropShadow behind the <code>backgroundColor</code> frame.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var dropShadowVisible:Boolean = true;
    
    /**
     *  Enables a vertical linear gradient in the <code>backgroundColor</code> frame. This
     *  gradient fill is drawn across both the arrow and the frame. By default,
     *  the gradient brightens the background color by 15% and darkens it by 60%.
     * 
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var useBackgroundGradient:Boolean = true;
    
    /**
     *  Corner radius used for the <code>contentBackgroundColor</code> fill.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var contentCornerRadius:uint;
    
    /**
     *  A class reference to an FXG class that is layered underneath the
     *  <code>contentGroup</code>. The instance of this class is sized to match the
     *  <code>contentGroup</code>.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var contentBackgroundInsetClass:Class;
    
    /**
     *  Corner radius of the <code>backgroundColor</code> "frame".
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var backgroundCornerRadius:Number;
    
    /**
     *  The thickness of the <code>backgroundColor</code> "frame" that surrounds the
     *  <code>contentGroup</code>.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var frameThickness:Number;
    
    /**
     *  Color of the border stroke around the <code>backgroundColor</code> "frame".
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var borderColor:Number = 0;
    
    /**
     *  Thickness of the border stroke around the <code>backgroundColor</code>
     *  "frame".
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var borderThickness:Number = NaN;
    
    /**
     *  Width of the arrow in vertical directions. This property also controls
     *  the height of the arrow in horizontal directions.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var arrowWidth:Number;
    
    /**
     *  Height of the arrow in vertical directions. This property also controls
     *  the width of the arrow in horizontal directions.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var arrowHeight:Number;
    
    /**
     *  @private
     *  Instance of the contentBackgroundClass
     */
    mx_internal var contentBackgroundGraphic:SpriteVisualElement;
    
    /**
     *  @private
     *  Tracks changes to the skin state to support the fade out tranisition 
     *  when closed;
     */
    mx_internal var isOpen:Boolean;
    
    private var backgroundGradientHeight:Number;
    
    private var contentMask:Sprite;
    
    private var backgroundFill:SpriteVisualElement;
    
    private var dropShadow:RectangularDropShadow;
    
    private var dropShadowBlurX:Number;
    
    private var dropShadowBlurY:Number;
    
    private var dropShadowDistance:Number;
    
    private var dropShadowAlpha:Number;
    
    private var fade:Fade;
    
    private var highlightWeight:Number;
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @copy spark.components.SkinnableContainer#contentGroup
     */
    public var contentGroup:Group;
    
    /**
     * @copy spark.components.Callout#arrow
     */
    public var arrow:UIComponent;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     */
    override protected function createChildren():void
    {
        super.createChildren();
        
        if (dropShadowVisible)
        {
            dropShadow = new RectangularDropShadow();
            dropShadow.angle = 90;
            dropShadow.distance = dropShadowDistance;
            dropShadow.blurX = dropShadowBlurX;
            dropShadow.blurY = dropShadowBlurY;
            dropShadow.tlRadius = dropShadow.trRadius = dropShadow.blRadius = 
                dropShadow.brRadius = backgroundCornerRadius;
            dropShadow.mouseEnabled = false;
            dropShadow.alpha = dropShadowAlpha;
            addChild(dropShadow);
        }
        
        // background fill placed above the drop shadow
        backgroundFill = new SpriteVisualElement();
        addChild(backgroundFill);
        
        // arrow
        if (!arrow)
        {
            arrow = new CalloutArrow();
            arrow.id = "arrow";
            arrow.styleName = this;
            addChild(arrow);
        }
        
        // contentGroup
        if (!contentGroup)
        {
            contentGroup = new Group();
            contentGroup.id = "contentGroup";
            addChild(contentGroup);
        }
    }
    
    /**
     * @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        // add or remove the contentBackgroundGraphic
        var contentBackgroundAppearance:String = getStyle("contentBackgroundAppearance");
        
        if (contentBackgroundAppearance == ContentBackgroundAppearance.INSET)
        {
            // create the contentBackgroundGraphic
            if (!contentBackgroundGraphic && contentBackgroundInsetClass)
            {
                contentBackgroundGraphic = new contentBackgroundInsetClass() as SpriteVisualElement;
                
                // with the current skin structure, contentBackgroundGraphic is
                // always the last child
                addChild(contentBackgroundGraphic);
            }
        }
        else if (contentBackgroundGraphic)
        {
            // if already created, remove the graphic for "flat" and "none"
            removeChild(contentBackgroundGraphic);
            contentBackgroundGraphic = null;
        }
        
        // always invalidate to accomodate arrow direction changes
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     * @private
     */
    override protected function measure():void
    {
        super.measure();
        
        var borderWeight:Number = isNaN(borderThickness) ? 0 : borderThickness;
        var frameAdjustment:Number = (frameThickness + borderWeight) * 2;
        
        var arrowMeasuredWidth:Number;
        var arrowMeasuredHeight:Number;
        
        // pad the arrow so that the edges are within the background corner radius
        if (isArrowHorizontal)
        {
            arrowMeasuredWidth = arrowHeight;
            arrowMeasuredHeight = arrowWidth + (backgroundCornerRadius * 2);
        }
        else if (isArrowVertical)
        {
            arrowMeasuredWidth = arrowWidth + (backgroundCornerRadius * 2);
            arrowMeasuredHeight = arrowHeight;
        }
        
        // count the contentGroup size and frame size
        measuredMinWidth = contentGroup.measuredMinWidth + frameAdjustment;
        measuredMinHeight = contentGroup.measuredMinHeight + frameAdjustment;
        
        measuredWidth = contentGroup.getPreferredBoundsWidth() + frameAdjustment;
        measuredHeight = contentGroup.getPreferredBoundsHeight() + frameAdjustment;
        
        // add the arrow size based on the arrowDirection
        if (isArrowHorizontal)
        {
            measuredMinWidth += arrowMeasuredWidth;
            measuredMinHeight = Math.max(measuredMinHeight, arrowMeasuredHeight);
            
            measuredWidth += arrowMeasuredWidth;
            measuredHeight = Math.max(measuredHeight, arrowMeasuredHeight);
        }
        else if (isArrowVertical)
        {
            measuredMinWidth += Math.max(measuredMinWidth, arrowMeasuredWidth);
            measuredMinHeight += arrowMeasuredHeight;
            
            measuredWidth = Math.max(measuredWidth, arrowMeasuredWidth);
            measuredHeight += arrowMeasuredHeight;
        }
    }
    
    /**
     *  @private
     *  SkinnaablePopUpContainer skins must dispatch a 
     *  FlexEvent.STATE_CHANGE_COMPLETE event for the component to properly
     *  update the skin state.
     */
    override protected function commitCurrentState():void
    {
        super.commitCurrentState();
        
        var isNormal:Boolean = (currentState == "normal");
        var isDisabled:Boolean = (currentState == "disabled")
        
        // play a fade out if the callout was previously open
        if (!(isNormal || isDisabled) && isOpen)
        {
            if (!fade)
            {
                fade = new Fade();
                fade.target = this;
                fade.duration = 200;
                fade.alphaTo = 0;
            }
            
            // BlendMode.LAYER while fading out
            blendMode = BlendMode.LAYER;
            
            // play a short fade effect
            fade.addEventListener(EffectEvent.EFFECT_END, stateChangeComplete);
            fade.play();
            
            isOpen = false;
        }
        else
        {
            isOpen = isNormal || isDisabled;
            
            // handle re-opening the Callout while fading out
            if (fade && fade.isPlaying)
            {
                // Do not dispatch a state change complete.
                // SkinnablePopUpContainer handles state interruptions.
                fade.removeEventListener(EffectEvent.EFFECT_END, stateChangeComplete);
                fade.stop();
            }
            
            if (isDisabled)
            {
                // BlendMode.LAYER to allow CalloutArrow BlendMode.ERASE
                blendMode = BlendMode.LAYER;
                
                alpha = 0.5;
            }
            else
            {
                // BlendMode.NORMAL for non-animated state transitions
                blendMode = BlendMode.NORMAL;
                
                if (isNormal)
                    alpha = 1;
                else
                    alpha = 0;
            }
            
            stateChangeComplete();
        }
    }
    
    /**
     * @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.drawBackground(unscaledWidth, unscaledHeight);
        
        var frameEllipseSize:Number = backgroundCornerRadius * 2;
        
        // account for borderThickness center stroke alignment
        var showBorder:Boolean = !isNaN(borderThickness);
        var borderWeight:Number = showBorder ? borderThickness : 0;
        
        // contentBackgroundGraphic already accounts for the arrow position
        // use it's positioning instead of recalculating based on unscaledWidth
        // and unscaledHeight
        var frameX:Number = Math.floor(contentGroup.getLayoutBoundsX() - frameThickness) - (borderWeight / 2);
        var frameY:Number = Math.floor(contentGroup.getLayoutBoundsY() - frameThickness) - (borderWeight / 2);
        var frameWidth:Number = contentGroup.getLayoutBoundsWidth() + (frameThickness * 2) + borderWeight;
        var frameHeight:Number = contentGroup.getLayoutBoundsHeight() + (frameThickness * 2) + borderWeight;
        
        var backgroundColor:Number = getStyle("backgroundColor");
        var backgroundAlpha:Number = getStyle("backgroundAlpha");
        
        var bgFill:Graphics = backgroundFill.graphics;
        bgFill.clear();
        
        if (showBorder)
            bgFill.lineStyle(borderThickness, borderColor, 1, true);
        
        if (useBackgroundGradient)
        {
            // top color is brighter if arrowDirection == ArrowDirection.UP
            var backgroundColorTop:Number = ColorUtil.adjustBrightness2(backgroundColor, 
                BACKGROUND_GRADIENT_BRIGHTNESS_TOP);
            var backgroundColorBottom:Number = ColorUtil.adjustBrightness2(backgroundColor, 
                BACKGROUND_GRADIENT_BRIGHTNESS_BOTTOM);
            
            // max gradient height = backgroundGradientHeight
            colorMatrix.createGradientBox(unscaledWidth, backgroundGradientHeight,
                Math.PI / 2, 0, 0);
            
            bgFill.beginGradientFill(GradientType.LINEAR,
                [backgroundColorTop, backgroundColorBottom],
                [backgroundAlpha, backgroundAlpha],
                [0, 255],
                colorMatrix);
        }
        else
        {
            bgFill.beginFill(backgroundColor, backgroundAlpha);
        }
        
        bgFill.drawRoundRect(frameX, frameY, frameWidth,
            frameHeight, frameEllipseSize, frameEllipseSize);
        bgFill.endFill();
        
        // draw content background styles
        var contentBackgroundAppearance:String = getStyle("contentBackgroundAppearance");
        
        if (contentBackgroundAppearance != ContentBackgroundAppearance.NONE)
        {
            var contentEllipseSize:Number = contentCornerRadius * 2;
            var contentBackgroundAlpha:Number = getStyle("contentBackgroundAlpha");
            var contentWidth:Number = contentGroup.getLayoutBoundsWidth();
            var contentHeight:Number = contentGroup.getLayoutBoundsHeight();
            
            // all appearance values except for "none" use a mask
            if (!contentMask)
                contentMask = new SpriteVisualElement();
            
            contentGroup.mask = contentMask;
            
            // draw contentMask in contentGroup coordinate space
            var maskGraphics:Graphics = contentMask.graphics;
            maskGraphics.clear();
            maskGraphics.beginFill(0, 1);
            maskGraphics.drawRoundRect(0, 0, contentWidth, contentHeight,
                contentEllipseSize, contentEllipseSize);
            maskGraphics.endFill();
            
            // reset line style to none
            if (showBorder)
                bgFill.lineStyle(NaN);
            
            // draw the contentBackgroundColor
            bgFill.beginFill(getStyle("contentBackgroundColor"),
                contentBackgroundAlpha);
            bgFill.drawRoundRect(contentGroup.getLayoutBoundsX(),
                contentGroup.getLayoutBoundsY(),
                contentWidth, contentHeight, contentEllipseSize, contentEllipseSize);
            bgFill.endFill();
            
            if (contentBackgroundGraphic)
                contentBackgroundGraphic.alpha = contentBackgroundAlpha;
        }
        else // if (contentBackgroundAppearance == CalloutContentBackgroundAppearance.NONE))
        {
            // remove the mask
            if (contentMask)
            {
                contentGroup.mask = null;
                contentMask = null;
            }
        }
        
        // draw highlight in the callout when the arrow is hidden
        if (useBackgroundGradient && !isArrowHorizontal && !isArrowVertical)
        {
            // highlight width spans the callout width minus the corner radius
            var highlightWidth:Number = frameWidth - frameEllipseSize;
            var highlightX:Number = frameX + backgroundCornerRadius;
            var highlightOffset:Number = (highlightWeight * 1.5);
            
            // straight line across the top
            bgFill.lineStyle(highlightWeight, 0xFFFFFF, 0.2 * backgroundAlpha);
            bgFill.moveTo(highlightX, highlightOffset);
            bgFill.lineTo(highlightX + highlightWidth, highlightOffset);
        }
    }
    
    /**
     * @private
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        // pad the arrow so that the edges are within the background corner radius
        if (isArrowHorizontal)
        {
            arrow.width = arrowHeight;
            arrow.height = arrowWidth + (backgroundCornerRadius * 2);
        }
        else if (isArrowVertical)
        {
            arrow.width = arrowWidth + (backgroundCornerRadius * 2);
            arrow.height = arrowHeight;
        }
        
        setElementSize(backgroundFill, unscaledWidth, unscaledHeight);
        setElementPosition(backgroundFill, 0, 0);
        
        var frameX:Number = 0;
        var frameY:Number = 0;
        var frameWidth:Number = unscaledWidth;
        var frameHeight:Number = unscaledHeight;
        
        switch (hostComponent.arrowDirection)
        {
            case ArrowDirection.UP:
                frameY = arrow.height;
                frameHeight -= arrow.height;
                break;
            case ArrowDirection.DOWN:
                frameHeight -= arrow.height;
                break;
            case ArrowDirection.LEFT:
                frameX = arrow.width;
                frameWidth -= arrow.width;
                break;
            case ArrowDirection.RIGHT:
                frameWidth -= arrow.width;
                break;
            default:
                // no arrow, content takes all available space
                break;
        }
        
        if (dropShadow)
        {
            setElementSize(dropShadow, frameWidth, frameHeight);
            setElementPosition(dropShadow, frameX, frameY);
        }
        
        // Show frameThickness by inset of contentGroup
        var borderWeight:Number = isNaN(borderThickness) ? 0 : borderThickness;
        var contentBackgroundAdjustment:Number = frameThickness + borderWeight;
        
        var contentBackgroundX:Number = frameX + contentBackgroundAdjustment;
        var contentBackgroundY:Number = frameY + contentBackgroundAdjustment;
        
        contentBackgroundAdjustment = contentBackgroundAdjustment * 2;
        var contentBackgroundWidth:Number = frameWidth - contentBackgroundAdjustment;
        var contentBackgroundHeight:Number = frameHeight - contentBackgroundAdjustment;
        
        if (contentBackgroundGraphic)
        {
            setElementSize(contentBackgroundGraphic, contentBackgroundWidth, contentBackgroundHeight);
            setElementPosition(contentBackgroundGraphic, contentBackgroundX, contentBackgroundY);
        }
        
        setElementSize(contentGroup, contentBackgroundWidth, contentBackgroundHeight);
        setElementPosition(contentGroup, contentBackgroundX, contentBackgroundY);
        
        // mask position is in the contentGroup coordinate space
        if (contentMask)
            setElementSize(contentMask, contentBackgroundWidth, contentBackgroundHeight);
    }
    
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);
        
        var allStyles:Boolean = !styleProp || styleProp == "styleName";
        
        if (allStyles || (styleProp == "contentBackgroundAppearance"))
            invalidateProperties();
        
        if (allStyles || (styleProp == "backgroundAlpha"))
        {
            var backgroundAlpha:Number = getStyle("backgroundAlpha");
            
            // Use BlendMode.LAYER to allow CalloutArrow to erase the dropShadow
            // when the Callout background is transparent
            blendMode = (backgroundAlpha < 1) ? BlendMode.LAYER : BlendMode.NORMAL;
        }
    }
    
    /**
     * @private
     */
    mx_internal function get isArrowHorizontal():Boolean
    {
        return (hostComponent.arrowDirection == ArrowDirection.LEFT
            || hostComponent.arrowDirection == ArrowDirection.RIGHT);
    }
    
    /**
     * @private
     */
    mx_internal function get isArrowVertical():Boolean
    {
        return (hostComponent.arrowDirection == ArrowDirection.UP
            || hostComponent.arrowDirection == ArrowDirection.DOWN);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    private function stateChangeComplete(event:Event=null):void
    {
        if (fade && event)
            fade.removeEventListener(EffectEvent.EFFECT_END, stateChangeComplete);
        
        // SkinnablePopUpContainer relies on state changes for open and close
        dispatchEvent(new FlexEvent(FlexEvent.STATE_CHANGE_COMPLETE));
    }
}
}