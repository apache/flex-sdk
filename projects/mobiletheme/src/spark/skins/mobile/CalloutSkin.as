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
import flash.display.GraphicsPathCommand;

import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.utils.ColorUtil;

import spark.components.ArrowDirection;
import spark.components.Callout;
import spark.components.Group;
import spark.core.SpriteVisualElement;
import spark.skins.mobile.supportClasses.MobileSkin;

use namespace mx_internal;

/**
 *  The default skin class for the Spark Callout component in mobile
 *  applications.
 *  
 *  @see spark.components.Callout
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
public class CalloutSkin extends MobileSkin
{
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
        
        // TODO (jasonsj): DPI-specific arrow size, padding
        padding = 9;
        cornerRadius = 9;
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
    
    private var padding:uint;
    
    private var cornerRadius:uint;
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts
    //
    //--------------------------------------------------------------------------
    
    public var contentGroup:Group;
    
    public var arrow:SpriteVisualElement;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    override protected function createChildren():void
    {
        super.createChildren();
        
        contentGroup = new Group();
        contentGroup.id = "contentGroup";
        addChild(contentGroup);
        
        // TODO (jasonsj): FXG
        arrow = new SpriteVisualElement();
        arrow.id = "arrow";
        addChild(arrow);
        
        // TODO (jasonsj): RectangularDropShadow
    }
    
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        // TODO (jasonsj): FXG
        if (isArrowHorizontal)
        {
            arrow.width = 26;
            arrow.height = 52 + (cornerRadius * 2);
        }
        else if (isArrowVertical)
        {
            arrow.width = 52 + (cornerRadius * 2);
            arrow.height = 26;
        }
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    override protected function measure():void
    {
        super.measure();
        
        var backgroundWidth:Number = contentGroup.getPreferredBoundsWidth() + (padding * 4);
        var backgroundHeight:Number = contentGroup.getPreferredBoundsHeight() + (padding * 4);
        var arrowWidth:Number = arrow.getPreferredBoundsWidth();
        var arrowHeight:Number = arrow.getPreferredBoundsHeight();
        
        measuredMinWidth = arrowWidth;
        measuredMinHeight = arrowHeight;
        measuredWidth = backgroundWidth;
        measuredHeight = backgroundHeight;
        
        if (isArrowHorizontal)
        {
            measuredWidth += arrowWidth;
        }
        else if (isArrowVertical)
        {
            measuredHeight += arrowHeight;
        }
    }
    
    override protected function commitCurrentState():void
    {
        super.commitCurrentState();
        
        // FIXME (jasonsj): SkinnablePopUpContainer relies on state changes
        //                  for open and close
        dispatchEvent(new FlexEvent(FlexEvent.STATE_CHANGE_COMPLETE));
    }
    
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        var ellipseSize:Number = cornerRadius * 2;
        var contentPadding:Number = padding * 2;
        var backgroundColor:Number = getStyle("backgroundColor");
        var backgroundColorTop:Number = ColorUtil.adjustBrightness2(backgroundColor, 20);
        
        // FIXME (jasonsj): fixed gradient height?
        colorMatrix.createGradientBox(unscaledWidth, 40, Math.PI / 2, 0, 0);
        
        var backgroundX:Number = Math.floor(contentGroup.getLayoutBoundsX() - contentPadding);
        var backgroundY:Number = Math.floor(contentGroup.getLayoutBoundsY() - contentPadding);
        
        // TODO (jasonsj): FXG
        graphics.beginGradientFill(GradientType.LINEAR,
            [backgroundColorTop, backgroundColor],
            [1, 1],
            [0, 255],
            colorMatrix);
        graphics.drawRoundRect(backgroundX,
            backgroundY,
            contentGroup.getLayoutBoundsWidth() + (contentPadding * 2),
            contentGroup.getLayoutBoundsHeight() + (contentPadding * 2),
            ellipseSize,
            ellipseSize);
        graphics.endFill();
        
        graphics.beginFill(getStyle("contentBackgroundColor"), getStyle("contentBackgroundAlpha"));
        graphics.drawRoundRect(contentGroup.getLayoutBoundsX() - padding,
            contentGroup.getLayoutBoundsY() - padding,
            contentGroup.getLayoutBoundsWidth() + contentPadding,
            contentGroup.getLayoutBoundsHeight() + contentPadding,
            ellipseSize,
            ellipseSize);
        graphics.endFill();
        
        arrow.graphics.clear();
        
        if (isArrowHorizontal || isArrowVertical)
        {
            // when drawing the arrow, compensate for cornerRadius
            var arrowWidth:Number = getElementPreferredWidth(arrow);
            var arrowHeight:Number = getElementPreferredHeight(arrow);
            var arrowX:Number = 0;
            var arrowY:Number = 0;
            var arrowTipX:Number = 0;
            var arrowTipY:Number = 0;
            var arrowEndX:Number = 0;
            var arrowEndY:Number = 0;
            
            if (isArrowHorizontal)
            {
                arrowY = cornerRadius;
                arrowHeight = arrowHeight - (cornerRadius * 2);
                
                arrowTipX = arrowWidth;
                arrowTipY = arrowY + (arrowHeight / 2);
                
                arrowEndX = arrowX;
                arrowEndY = arrowY + arrowHeight;
                
                // flip coordinates to point left
                if (hostComponent.arrowDirection == ArrowDirection.LEFT)
                {
                    arrowX = arrowWidth - arrowX;
                    arrowTipX = arrowWidth - arrowTipX;
                    arrowEndX = arrowWidth - arrowEndX;
                }
            }
            else if (isArrowVertical)
            {
                arrowX = cornerRadius;
                arrowWidth = arrowWidth - (cornerRadius * 2);
                
                arrowTipX = arrowX + (arrowWidth / 2);
                arrowTipY = arrowHeight;
                
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
            
            // TODO (jasonsj): swap FXG for each arrow direction? mask for gradient fill?
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
            
            colorMatrix.createGradientBox(unscaledWidth, 40, Math.PI / 2, 0, -arrow.getLayoutBoundsY());
            
            arrow.graphics.beginGradientFill(GradientType.LINEAR,
                [backgroundColorTop, backgroundColor],
                [1, 1],
                [0, 255],
                colorMatrix);
            arrow.graphics.drawPath(commands, coords);
            arrow.graphics.endFill();
        }
    }
    
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        // 1x padding of backgroundColor, 1x padding of contentBackgroundColor
        var contentX:Number = padding * 2;
        var contentY:Number = padding * 2;
        var contentWidth:Number = unscaledWidth - (padding * 4);
        var contentHeight:Number = unscaledHeight - (padding * 4);
        
        // TODO (jasonsj): Arrow FXG
        var arrowWidth:Number = arrow.getPreferredBoundsWidth();
        var arrowHeight:Number = arrow.getPreferredBoundsHeight();
        
        switch (hostComponent.arrowDirection)
        {
            case ArrowDirection.UP:
                contentY += arrowHeight;
                contentHeight -= arrowHeight;
                break;
            case ArrowDirection.DOWN:
                contentHeight -= arrowHeight;
                break;
            case ArrowDirection.LEFT:
                contentX += arrowWidth;
                contentWidth -= arrowWidth;
                break;
            case ArrowDirection.RIGHT:
                contentWidth -= arrowWidth;
                break;
            default:
                // no arrow, content takes all available space
                break;
        }
        
        setElementPosition(contentGroup, contentX, contentY);
        setElementSize(contentGroup, contentWidth, contentHeight);
    }
    
    private function get isArrowHorizontal():Boolean
    {
        return (hostComponent.arrowDirection == ArrowDirection.LEFT
            || hostComponent.arrowDirection == ArrowDirection.RIGHT);
    }
    
    private function get isArrowVertical():Boolean
    {
        return (hostComponent.arrowDirection == ArrowDirection.UP
            || hostComponent.arrowDirection == ArrowDirection.DOWN);
    }
}
}