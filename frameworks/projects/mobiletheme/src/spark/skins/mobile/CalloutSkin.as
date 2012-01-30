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
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.GraphicsPathCommand;
import flash.display.Sprite;
import flash.events.Event;

import mx.core.DPIClassification;
import mx.core.mx_internal;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.utils.ColorUtil;

import spark.components.ArrowDirection;
import spark.components.Callout;
import spark.components.Group;
import spark.core.SpriteVisualElement;
import spark.effects.Fade;
import spark.primitives.RectangularDropShadow;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile160.assets.CalloutContentBackground;
import spark.skins.mobile240.assets.CalloutContentBackground;
import spark.skins.mobile320.assets.CalloutContentBackground;

use namespace mx_internal;

/**
 *  The default skin class for the Spark Callout component in mobile
 *  applications.
 *  
 *  @see spark.components.Callout
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
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
     *  @productversion Flex 4.5.2
     */
    public function CalloutSkin()
    {
        super();
        
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                backgroundCornerRadius = 16;
                contentBackgroundClass = spark.skins.mobile320.assets.CalloutContentBackground;
                backgroundGradientHeight = 220;
                frameSize = 20;
                arrowWidth = 88;
                arrowHeight = 52;
                contentCornerRadius = 10;
                dropShadowBlur = 80;
                dropShadowDistance = 8;
                highlightWeight = 2;
                
                break;
            }
            case DPIClassification.DPI_240:
            {
                backgroundCornerRadius = 12;
                contentBackgroundClass = spark.skins.mobile240.assets.CalloutContentBackground;
                backgroundGradientHeight = 165;
                frameSize = 15;
                arrowWidth = 66;
                arrowHeight = 39;
                contentCornerRadius = 7;
                dropShadowBlur = 60;
                dropShadowDistance = 6;
                highlightWeight = 1;
                
                break;
            }
            default:
            {
                // default DPI_160
                backgroundCornerRadius = 8;
                contentBackgroundClass = spark.skins.mobile160.assets.CalloutContentBackground;
                backgroundGradientHeight = 110;
                frameSize = 10;
                arrowWidth = 44;
                arrowHeight = 26;
                contentCornerRadius = 5;
                dropShadowBlur = 40;
                dropShadowDistance = 4;
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
    
    // TODO (jasonsj): PARB these properties as protected?
    
    mx_internal var contentCornerRadius:uint;
    
    mx_internal var contentBackgroundClass:Class;
    
    mx_internal var backgroundCornerRadius:Number;
    
    mx_internal var backgroundGradientHeight:Number;
    
    mx_internal var contentBackgroundGraphic:SpriteVisualElement;
    
//    mx_internal var contentMask:Sprite;
    
    mx_internal var frameSize:Number;
    
    mx_internal var arrowWidth:Number;
    
    mx_internal var arrowHeight:Number;
    
    mx_internal var backgroundFill:SpriteVisualElement;
    
    mx_internal var dropShadow:RectangularDropShadow;
    
    mx_internal var dropShadowBlur:Number;
    
    mx_internal var dropShadowDistance:Number;
    
    mx_internal var fade:Fade;
    
    mx_internal var isOpen:Boolean;
    
    mx_internal var highlightWeight:Number;
    
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
    public var arrow:Arrow;
    
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
        
        // FIXME (jasonsj): clicking on drop shadow should dismiss the callout
        dropShadow = new RectangularDropShadow();
        dropShadow.angle = 90;
        dropShadow.distance = dropShadowDistance;
        dropShadow.blurX = dropShadow.blurY = dropShadowBlur;
        dropShadow.tlRadius = dropShadow.trRadius = dropShadow.blRadius = 
            dropShadow.brRadius = backgroundCornerRadius;
        addChild(dropShadow);
        
        // background fill placed above the drop shadow
        backgroundFill = new SpriteVisualElement();
        addChild(backgroundFill);
        
        arrow = new Arrow(this);
        arrow.id = "arrow";
        addChild(arrow);
        
        contentBackgroundGraphic = new contentBackgroundClass() as SpriteVisualElement;
        addChild(contentBackgroundGraphic);
        
        contentGroup = new Group();
        contentGroup.id = "contentGroup";
        addChild(contentGroup);
        
        // TODO (jasonsj): add mask
//        contentMask = new Sprite();
//        contentGroup.mask = contentMask;
    }
    
    /**
     * @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
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
        
        var backgroundPadding:Number = (Math.max(backgroundCornerRadius, frameSize) * 2);
        
        var backgroundWidth:Number = contentGroup.getPreferredBoundsWidth()
            + backgroundPadding;
        var backgroundHeight:Number = contentGroup.getPreferredBoundsHeight()
            + backgroundPadding;
        
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
        
        measuredMinWidth = Math.max(arrowMeasuredWidth, contentGroup.measuredMinWidth);
        measuredMinHeight = Math.max(arrowMeasuredHeight, contentGroup.measuredMinHeight);
        measuredWidth = backgroundWidth;
        measuredHeight = backgroundHeight;
        
        if (isArrowHorizontal)
        {
            measuredWidth += arrowMeasuredWidth;
            measuredHeight = Math.max(measuredHeight, arrowMeasuredHeight);
        }
        else if (isArrowVertical)
        {
            measuredWidth = Math.max(measuredWidth, arrowMeasuredWidth);
            measuredHeight += arrowMeasuredHeight;
        }
    }
    
    /**
     * @private
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
                fade.duration = 250;
                fade.alphaTo = 0;
            }
            
            // play a short fade effect
            fade.addEventListener(EffectEvent.EFFECT_END, stateChangeComplete);
            fade.play();
            
            isOpen = false;
        }
        else
        {
            isOpen = isNormal || isDisabled;
            
            if (isNormal)
                alpha = 1;
            else if (isDisabled)
                alpha = 0.5;
            else
                alpha = 0;
            
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
        
        // contentBackgroundGraphic already accounts for the arrow position
        // use it's positioning instead of recalculating based on unscaledWidth
        // and unscaledHeight
        var frameX:Number = Math.floor(contentBackgroundGraphic.getLayoutBoundsX() - frameSize);
        var frameY:Number = Math.floor(contentBackgroundGraphic.getLayoutBoundsY() - frameSize);
        var frameWidth:Number = contentBackgroundGraphic.getLayoutBoundsWidth() + (frameSize * 2);
        var frameHeight:Number = contentBackgroundGraphic.getLayoutBoundsHeight() + (frameSize * 2) ;
        
        var backgroundColor:Number = getStyle("backgroundColor");
        var backgroundAlpha:Number = getStyle("backgroundAlpha");
        
        // top color is brighter if arrowDirection == ArrowDirection.UP
        var backgroundColorTop:Number = ColorUtil.adjustBrightness2(backgroundColor, 
            BACKGROUND_GRADIENT_BRIGHTNESS_TOP);
        var backgroundColorBottom:Number = ColorUtil.adjustBrightness2(backgroundColor, 
            BACKGROUND_GRADIENT_BRIGHTNESS_BOTTOM);
        
        // max gradient height = backgroundGradientHeight
        colorMatrix.createGradientBox(unscaledWidth, backgroundGradientHeight,
            Math.PI / 2, 0, 0);
        
        var bgFill:Graphics = backgroundFill.graphics;
        bgFill.clear();
        
        bgFill.beginGradientFill(GradientType.LINEAR,
            [backgroundColorTop, backgroundColorBottom],
            [backgroundAlpha, backgroundAlpha],
            [0, 255],
            colorMatrix);
        bgFill.drawRoundRect(frameX, frameY, frameWidth,
            frameHeight, frameEllipseSize, frameEllipseSize);
        bgFill.endFill();
        
        // draw the contentBackgroundColor
        // the shading and highlight are drawn in FXG
        var contentEllipseSize:Number = contentCornerRadius * 2;
        var contentBackgroundAlpha:Number = getStyle("contentBackgroundAlpha");
        var contentWidth:Number = contentBackgroundGraphic.getLayoutBoundsWidth();
        var contentHeight:Number = contentBackgroundGraphic.getLayoutBoundsHeight();
        
        bgFill.beginFill(getStyle("contentBackgroundColor"),
            contentBackgroundAlpha);
        bgFill.drawRoundRect(contentBackgroundGraphic.getLayoutBoundsX(),
            contentBackgroundGraphic.getLayoutBoundsY(),
            contentWidth, contentHeight, contentEllipseSize, contentEllipseSize);
        bgFill.endFill();
        
        // content mask in contentGroup coordinate space
//        var maskGraphics:Graphics = contentMask.graphics;
//        maskGraphics.clear();
//        maskGraphics.beginFill(0, 1);
//        maskGraphics.drawRoundRect(0, 0, contentWidth, contentHeight,
//            contentEllipseSize, contentEllipseSize);
//        maskGraphics.endFill();
        
        contentBackgroundGraphic.alpha = contentBackgroundAlpha;
        
        // draw highlight in the callout when the arrow is hidden
        if (!isArrowHorizontal && !isArrowVertical)
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
        
        // 1x padding of backgroundColor, 1x padding of contentBackgroundColor
        var frameX:Number = 0;
        var frameY:Number = 0;
        var frameWidth:Number = unscaledWidth;
        var frameHeight:Number = unscaledHeight;
        
        switch (hostComponent.arrowDirection)
        {
            case ArrowDirection.UP:
                frameY += arrow.height;
                frameHeight -= arrow.height;
                break;
            case ArrowDirection.DOWN:
                frameHeight -= arrow.height;
                break;
            case ArrowDirection.LEFT:
                frameX += arrow.width;
                frameWidth -= arrow.width;
                break;
            case ArrowDirection.RIGHT:
                frameWidth -= arrow.width;
                break;
            default:
                // no arrow, content takes all available space
                break;
        }
        
        setElementSize(dropShadow, frameWidth, frameHeight);
        setElementPosition(dropShadow, frameX, frameY);
        
        // the inset from the bounds of the callout to the contentGroup
        // visually represented by the backgroundColor "border"
        var contentBackgroundAdjustment:Number = (frameSize * 2);
        
        var contentBackgroundX:Number = frameX + frameSize;
        var contentBackgroundY:Number = frameY + frameSize;
        var contentBackgroundWidth:Number = frameWidth - contentBackgroundAdjustment;
        var contentBackgroundHeight:Number = frameHeight - contentBackgroundAdjustment;
        
        setElementSize(contentBackgroundGraphic, contentBackgroundWidth, contentBackgroundHeight);
        setElementPosition(contentBackgroundGraphic, contentBackgroundX, contentBackgroundY);
        
        setElementSize(contentGroup, contentBackgroundWidth, contentBackgroundHeight);
        setElementPosition(contentGroup, contentBackgroundX, contentBackgroundY);
        
        // mask position is in the contentGroup coordinate space
//        setElementSize(contentMask, contentBackgroundWidth, contentBackgroundHeight);
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
    
    private function stateChangeComplete(event:Event=null):void
    {
        if (fade && event)
            fade.removeEventListener(EffectEvent.EFFECT_END, stateChangeComplete);
        
        // SkinnablePopUpContainer relies on state changes for open and close
        dispatchEvent(new FlexEvent(FlexEvent.STATE_CHANGE_COMPLETE));
    }
}
}
import flash.display.GradientType;
import flash.display.GraphicsPathCommand;

import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.utils.ColorUtil;

import spark.components.ArrowDirection;
import spark.skins.mobile.CalloutSkin;
import spark.skins.mobile.supportClasses.MobileSkin;

use namespace mx_internal;

class Arrow extends UIComponent
{
    public function Arrow(calloutSkin:CalloutSkin)
    {
        super();
        
        _calloutSkin = calloutSkin;
    }
    
    private var _calloutSkin:CalloutSkin;
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        graphics.clear();
        
        if (!_calloutSkin.isArrowHorizontal && !_calloutSkin.isArrowVertical)
            return;
        
        // when drawing the arrow, compensate for cornerRadius
        var arrowDirection:String = _calloutSkin.hostComponent.arrowDirection;
        var arrowWidth:Number = unscaledWidth;
        var arrowHeight:Number = unscaledHeight;
        var arrowX:Number = 0;
        var arrowY:Number = 0;
        var arrowTipX:Number = 0;
        var arrowTipY:Number = 0;
        var arrowEndX:Number = 0;
        var arrowEndY:Number = 0;
        
        if (_calloutSkin.isArrowHorizontal)
        {
            arrowY = _calloutSkin.backgroundCornerRadius;
            arrowHeight = arrowHeight - (_calloutSkin.backgroundCornerRadius * 2);
            
            arrowTipX = arrowWidth;
            arrowTipY = arrowY + (arrowHeight / 2);
            
            arrowEndX = arrowX;
            arrowEndY = arrowY + arrowHeight;
            
            // flip coordinates to point left
            if (arrowDirection == ArrowDirection.LEFT)
            {
                arrowX = arrowWidth - arrowX;
                arrowTipX = arrowWidth - arrowTipX;
                arrowEndX = arrowWidth - arrowEndX;
            }
        }
        else if (_calloutSkin.isArrowVertical)
        {
            arrowX = _calloutSkin.backgroundCornerRadius;
            arrowWidth = arrowWidth - (_calloutSkin.backgroundCornerRadius * 2);
            
            arrowTipX = arrowX + (arrowWidth / 2);
            arrowTipY = arrowHeight;
            
            arrowEndX = arrowX + arrowWidth;
            arrowEndY = arrowY;
            
            // flip coordinates to point up
            if (_calloutSkin.hostComponent.arrowDirection == ArrowDirection.UP)
            {
                arrowY = arrowHeight - arrowY;
                arrowTipY = arrowHeight - arrowTipY;
                arrowEndY = arrowHeight - arrowEndY;
            }
        }
        
        var commands:Vector.<int> = new Vector.<int>(3, true);
        commands[0] = GraphicsPathCommand.MOVE_TO;
        commands[1] = GraphicsPathCommand.LINE_TO;
        commands[2] = GraphicsPathCommand.LINE_TO;
        
        var coords:Vector.<Number> = new Vector.<Number>(6, true);
        coords[0] = arrowX;
        coords[1] = arrowY;
        coords[2] = arrowTipX
        coords[3] = arrowTipY;
        coords[4] = arrowEndX
        coords[5] = arrowEndY;
        
        var backgroundColor:Number = _calloutSkin.getStyle("backgroundColor");
        var backgroundAlpha:Number = _calloutSkin.getStyle("backgroundAlpha");
        
        var backgroundColorTop:Number = ColorUtil.adjustBrightness2(backgroundColor, 
            CalloutSkin.BACKGROUND_GRADIENT_BRIGHTNESS_TOP);
        var backgroundColorBottom:Number = ColorUtil.adjustBrightness2(backgroundColor, 
            CalloutSkin.BACKGROUND_GRADIENT_BRIGHTNESS_BOTTOM);
        
        // translate the gradient based on the arrow position
        MobileSkin.colorMatrix.createGradientBox(unscaledWidth, 
            _calloutSkin.backgroundGradientHeight, Math.PI / 2, 0, -getLayoutBoundsY());
        
        graphics.beginGradientFill(GradientType.LINEAR,
            [backgroundColorTop, backgroundColorBottom],
            [backgroundAlpha, backgroundAlpha],
            [0, 255],
            MobileSkin.colorMatrix);
        graphics.drawPath(commands, coords);
        graphics.endFill();
        
        // adjust the highlight position to the origin of the callout
        var isArrowUp:Boolean = (arrowDirection == ArrowDirection.UP);
        var offsetY:Number = (isArrowUp) ? unscaledHeight : -getLayoutBoundsY();
        
        // highlight starts after the backgroundCornerRadius
        var highlightX:Number = _calloutSkin.backgroundCornerRadius - getLayoutBoundsX();
        
        // highlight Y position is based on the stroke weight 
        var highlightOffset:Number = (_calloutSkin.highlightWeight * 1.5);
        var highlightY:Number = highlightOffset + offsetY;
        
        // highlight width spans the callout width minus the corner radius
        var highlightWidth:Number = _calloutSkin.getLayoutBoundsWidth() - (_calloutSkin.backgroundCornerRadius * 2);
        
        if (_calloutSkin.isArrowHorizontal)
        {
            highlightWidth -= arrowWidth;
            
            if (arrowDirection == ArrowDirection.LEFT)
                highlightX += arrowWidth;
        }
        
        // highlight on the top edge is drawn in the arrow only in the UP direction
        if (isArrowUp)
        {
            // highlight follows the top edge, including the arrow
            var rightWidth:Number = highlightWidth - arrowWidth;
            
            // highlight style
            graphics.lineStyle(_calloutSkin.highlightWeight, 0xFFFFFF, 0.2 * backgroundAlpha);
            
            // in the arrow coordinate space, the highlightX must be less than 0
            if (highlightX < 0)
            {
                graphics.moveTo(highlightX, highlightY);
                graphics.lineTo(arrowX, highlightY);
                
                // compute the remaining highlight
                rightWidth -= (arrowX - highlightX);
            }
            
            // arrow highlight (adjust Y downward)
            coords[1] = arrowY + highlightOffset;
            coords[3] = arrowTipY + highlightOffset;
            coords[5] = arrowEndY + highlightOffset;
            graphics.drawPath(commands, coords);
            
            // right side
            if (rightWidth > 0)
            {
                graphics.moveTo(arrowEndX, highlightY);
                graphics.lineTo(arrowEndX + rightWidth, highlightY);
            }
        }
        else
        {
            // straight line across the top
            graphics.lineStyle(_calloutSkin.highlightWeight, 0xFFFFFF, 0.2 * backgroundAlpha);
            graphics.moveTo(highlightX, highlightY);
            graphics.lineTo(highlightX + highlightWidth, highlightY);
        }
    }
}