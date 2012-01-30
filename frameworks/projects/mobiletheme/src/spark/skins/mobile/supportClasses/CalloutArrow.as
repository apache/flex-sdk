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

package spark.skins.mobile.supportClasses
{
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.GraphicsPathCommand;
import flash.display.Sprite;

import mx.core.DPIClassification;
import mx.core.FlexGlobals;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.utils.ColorUtil;

import spark.components.Application;
import spark.components.ArrowDirection;
import spark.components.Callout;
import spark.core.SpriteVisualElement;
import spark.skins.mobile.CalloutSkin;

use namespace mx_internal;

/**
 *  The arrow skin part for CalloutSkin. 
 *  
 *  @see spark.skin.mobile.CalloutSkin
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */ 
public class CalloutArrow extends UIComponent
{
    public function CalloutArrow()
    {
        super();
        
        useBackgroundGradient = true;
        
        var applicationDPI:Number = Application(FlexGlobals.topLevelApplication).applicationDPI;
        
        // Copy DPI-specific values from CalloutSkin
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                gap = 16;
                backgroundGradientHeight = 220;
                highlightWeight = 2;
                
                break;
            }
            case DPIClassification.DPI_240:
            {
                gap = 12;
                backgroundGradientHeight = 165;
                highlightWeight = 1;
                
                break;
            }
            default:
            {
                // default DPI_160
                gap = 8;
                backgroundGradientHeight = 110;
                highlightWeight = 1;
                
                break;
            }
        }
    }
    
    /**
     *  A gap on the frame-adjacent side of the arrow graphic to avoid
     *  drawing past the CalloutSkin backgroundCornerRadius.
     * 
     *  <p>The default implementation matches the gap value with the
     *  <code>backgroundCornerRadius</code> value in <code>CalloutSkin</code>.</p>
     * 
     *  @see spark.skins.mobile.CalloutSkin#backgroundCornerRadius
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var gap:Number;
    
    /**
     *  @copy spark.skins.mobile.CalloutSkin#backgroundGradientHeight
     */
    protected var backgroundGradientHeight:Number;
    
    /**
     *  @copy spark.skins.mobile.CalloutSkin#highlightWeight
     */
    private var highlightWeight:Number;
    
    /**
     *  @copy spark.skins.mobile.CalloutSkin#useBackgroundGradient
     */
    protected var useBackgroundGradient:Boolean;
    
    /**
     *  @copy spark.skins.mobile.CalloutSkin#borderColor
     */
    protected var borderColor:Number;
    
    /**
     *  @copy spark.skins.mobile.CalloutSkin#borderThickness
     */
    protected var borderThickness:Number = NaN;
    
    /**
     *  @private
     *  A sibling of the arrow used to erase the drop shadow in CalloutSkin
     */
    private var eraseFill:Sprite;
    
    /**
     * @private
     */
    override protected function createChildren():void
    {
        super.createChildren();
        
        // eraseFill has the same position and arrow shape in order to erase
        // the drop shadow under the arrow when backgroundAlpha < 1
        eraseFill = new Sprite();
        eraseFill.blendMode = BlendMode.ERASE;
        
        // layer eraseFill below the arrow 
        parent.addChildAt(eraseFill, parent.getChildIndex(this));
    }
    
    /**
     * @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        graphics.clear();
        eraseFill.graphics.clear();
        
        var calloutSkin:CalloutSkin = (parent as CalloutSkin);
        var hostComponent:Callout = calloutSkin.hostComponent;
        var arrowDirection:String = hostComponent.arrowDirection;
        
        if (arrowDirection == ArrowDirection.NONE)
            return;
        
        // when drawing the arrow, compensate for cornerRadius via padding
        var arrowGraphics:Graphics = this.graphics;
        var eraseGraphics:Graphics = eraseFill.graphics;
        var arrowWidth:Number = unscaledWidth;
        var arrowHeight:Number = unscaledHeight;
        var arrowX:Number = 0;
        var arrowY:Number = 0;
        var arrowTipX:Number = 0;
        var arrowTipY:Number = 0;
        var arrowEndX:Number = 0;
        var arrowEndY:Number = 0;
        
        var showBorder:Boolean = !isNaN(borderThickness);
        var borderWeight:Number = showBorder ? borderThickness : 0;
        var borderHalf:Number = borderWeight / 2;
        var isHorizontal:Boolean = false;
        
        if ((arrowDirection == ArrowDirection.LEFT) ||
            (arrowDirection == ArrowDirection.RIGHT))
        {
            isHorizontal = true;
            
            arrowX = -borderHalf;
            arrowY = gap;
            arrowHeight = arrowHeight - (gap * 2);
            
            arrowTipX = arrowWidth - borderHalf;
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
        else
        {
            arrowX = gap;
            arrowY = -borderHalf;
            arrowWidth = arrowWidth - (gap * 2);
            
            arrowTipX = arrowX + (arrowWidth / 2);
            arrowTipY = arrowHeight - borderHalf;
            
            arrowEndX = arrowX + arrowWidth;
            arrowEndY = arrowY;
            
            // flip coordinates to point up
            if (hostComponent.arrowDirection == ArrowDirection.UP)
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
        
        var backgroundColor:Number = getStyle("backgroundColor");
        var backgroundAlpha:Number = getStyle("backgroundAlpha");
        
        if (useBackgroundGradient)
        {
            var backgroundColorTop:Number = ColorUtil.adjustBrightness2(backgroundColor, 
                CalloutSkin.BACKGROUND_GRADIENT_BRIGHTNESS_TOP);
            var backgroundColorBottom:Number = ColorUtil.adjustBrightness2(backgroundColor, 
                CalloutSkin.BACKGROUND_GRADIENT_BRIGHTNESS_BOTTOM);
            
            // translate the gradient based on the arrow position
            MobileSkin.colorMatrix.createGradientBox(unscaledWidth, 
                backgroundGradientHeight, Math.PI / 2, 0, -getLayoutBoundsY());
            
            arrowGraphics.beginGradientFill(GradientType.LINEAR,
                [backgroundColorTop, backgroundColorBottom],
                [backgroundAlpha, backgroundAlpha],
                [0, 255],
                MobileSkin.colorMatrix);
        }
        else
        {
            arrowGraphics.beginFill(backgroundColor, backgroundAlpha);
        }
        
        // cover the adjacent border from the callout frame
        if (showBorder)
        {
            var coverX:Number = 0;
            var coverY:Number = 0;
            var coverWidth:Number = 0;
            var coverHeight:Number = 0;
            
            switch (arrowDirection)
            {
                case ArrowDirection.UP:
                {
                    coverX = arrowX;
                    coverY = arrowY;
                    coverWidth = arrowWidth;
                    coverHeight = borderWeight;
                    break;
                }
                case ArrowDirection.DOWN:
                {
                    coverX = arrowX;
                    coverY = -borderWeight;
                    coverWidth = arrowWidth;
                    coverHeight = borderWeight;
                    break;
                }
                case ArrowDirection.LEFT:
                {
                    coverX = arrowX;
                    coverY = arrowY;
                    coverWidth = borderWeight;
                    coverHeight = arrowHeight;
                    break;
                }
                case ArrowDirection.RIGHT:
                {
                    coverX = -borderWeight;
                    coverY = arrowY;
                    coverWidth = borderWeight;
                    coverHeight = arrowHeight;
                    break;
                }
            }
            
            arrowGraphics.drawRect(coverX, coverY, coverWidth, coverHeight);
        }
        
        // erase the drop shadow from the CalloutSkin
        if (backgroundAlpha < 1)
        {
            // move eraseFill to the same position as the arrow
            eraseFill.x = getLayoutBoundsX()
            eraseFill.y = getLayoutBoundsY();
            
            // draw the arrow shape
            eraseGraphics.beginFill(0, 1);
            eraseGraphics.drawPath(commands, coords);
            eraseGraphics.endFill();
        }
        
        // draw arrow path
        if (showBorder)
            arrowGraphics.lineStyle(borderThickness, borderColor, 1, true);
        
        arrowGraphics.drawPath(commands, coords);
        arrowGraphics.endFill();
        
        // adjust the highlight position to the origin of the callout
        var isArrowUp:Boolean = (arrowDirection == ArrowDirection.UP);
        var offsetY:Number = (isArrowUp) ? unscaledHeight : -getLayoutBoundsY();
        
        // highlight starts after the backgroundCornerRadius
        var highlightX:Number = gap - getLayoutBoundsX();
        
        // highlight Y position is based on the stroke weight 
        var highlightOffset:Number = (highlightWeight * 1.5);
        var highlightY:Number = highlightOffset + offsetY;
        
        // highlight width spans the callout width minus the corner radius
        var highlightWidth:Number = IVisualElement(calloutSkin).getLayoutBoundsWidth() - (gap * 2);
        
        if (isHorizontal)
        {
            highlightWidth -= arrowWidth;
            
            if (arrowDirection == ArrowDirection.LEFT)
                highlightX += arrowWidth;
        }
        
        // highlight on the top edge is drawn in the arrow only in the UP direction
        if (useBackgroundGradient)
        {
            if (isArrowUp)
            {
                // highlight follows the top edge, including the arrow
                var rightWidth:Number = highlightWidth - arrowWidth;
                
                // highlight style
                arrowGraphics.lineStyle(highlightWeight, 0xFFFFFF, 0.2 * backgroundAlpha);
                
                // in the arrow coordinate space, the highlightX must be less than 0
                if (highlightX < 0)
                {
                    arrowGraphics.moveTo(highlightX, highlightY);
                    arrowGraphics.lineTo(arrowX, highlightY);
                    
                    // compute the remaining highlight
                    rightWidth -= (arrowX - highlightX);
                }
                
                // arrow highlight (adjust Y downward)
                coords[1] = arrowY + highlightOffset;
                coords[3] = arrowTipY + highlightOffset;
                coords[5] = arrowEndY + highlightOffset;
                arrowGraphics.drawPath(commands, coords);
                
                // right side
                if (rightWidth > 0)
                {
                    arrowGraphics.moveTo(arrowEndX, highlightY);
                    arrowGraphics.lineTo(arrowEndX + rightWidth, highlightY);
                }
            }
            else
            {
                // straight line across the top
                arrowGraphics.lineStyle(highlightWeight, 0xFFFFFF, 0.2 * backgroundAlpha);
                arrowGraphics.moveTo(highlightX, highlightY);
                arrowGraphics.lineTo(highlightX + highlightWidth, highlightY);
            }
        }
    }
}
}