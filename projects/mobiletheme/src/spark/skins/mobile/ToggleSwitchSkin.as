////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

package spark.skins.mobile
{
import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;

import mx.core.DPIClassification;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.graphics.GradientEntry;
import mx.graphics.LinearGradient;
import mx.graphics.SolidColor;
import mx.utils.ColorUtil;

import spark.components.Group;
import spark.components.ToggleSwitch;
import spark.components.supportClasses.StyleableTextField;
import spark.core.IDisplayText;
import spark.core.SpriteVisualElement;
import spark.primitives.Rect;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile160.assets.ToggleSwitch_contentShadow;
import spark.skins.mobile240.assets.ToggleSwitch_contentShadow;
import spark.skins.mobile320.assets.ToggleSwitch_contentShadow;

use namespace mx_internal;

/**
 *  ActionScript-based skin for ToggleSwitch. The colors of the component can
 *  be customized using styles. This class is responsible for most of the
 *  graphics drawing, with some additional fxg assets.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */
public class ToggleSwitchSkin extends MobileSkin
{
    //----------------------------------------------------------------------------------------------
    //
    //  Constructor
    //
    //----------------------------------------------------------------------------------------------
    /**
     *  Constructor
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     **/
    public function ToggleSwitchSkin()
    {
        super();
        
        switch(applicationDPI) 
        {
            case DPIClassification.DPI_320:
            {
                layoutThumbWidth = 94;
                layoutThumbHeight = 56;
                layoutStrokeWeight = 2;
                layoutTextShadowOffset = -2;
                layoutInnerPadding = 14;
                layoutOuterPadding = 22;
                slidingContentOverlayClass = spark.skins.mobile320.assets.ToggleSwitch_contentShadow;
                break;
            }
            case DPIClassification.DPI_240:
            {
                layoutThumbWidth = 70;
                layoutThumbHeight = 42;
                layoutStrokeWeight = 2;
                layoutTextShadowOffset = -1;
                layoutInnerPadding = 10;
                layoutOuterPadding = 17;
                slidingContentOverlayClass = spark.skins.mobile240.assets.ToggleSwitch_contentShadow;
                break;
            }
            case DPIClassification.DPI_160:
            default:
            {
                layoutThumbWidth = 47;
                layoutThumbHeight = 28;
                layoutStrokeWeight = 1;
                layoutTextShadowOffset = -1;
                layoutInnerPadding = 7;
                layoutOuterPadding = 11;
                slidingContentOverlayClass = spark.skins.mobile160.assets.ToggleSwitch_contentShadow;
                break;
            }
        }
        
        layoutCornerRadius = layoutThumbHeight / 2;
    }
    
    //----------------------------------------------------------------------------------------------
    //
    //  Variables
    //
    //----------------------------------------------------------------------------------------------
    
    /**
     *  The width used to draw the thumb skin part
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected var layoutThumbWidth:Number;
    
    /**
     *  The height used to draw the thumb skin part
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected var layoutThumbHeight:Number;
    
    /**
     *  The corner radius of the thumb and track
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected var layoutCornerRadius:Number;
    
    /**
     * The stroke weight outlining the graphics of the skin
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected var layoutStrokeWeight:Number;
    
    /**
     * The padding between the labels and the thumb
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected var layoutInnerPadding:Number;
    
    /**
     * The padding between the labels and the edge of the track
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected var layoutOuterPadding:Number;
    
    /**
     * The offset between a label and its shadow
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected var layoutTextShadowOffset:Number;
    
    /**
     *  The label and its shadow for the selected side of the component
     */
    private var selectedLabel:StyleableTextField;
    private var selectedLabelShadow:StyleableTextField;
    
    /**
     *  The label and its shadow for the unselected side of the component
     */
    private var unselectedLabel:StyleableTextField;
    private var unselectedLabelShadow:StyleableTextField;

    /**
     *  The content clipped by the track that slides to match the thumb's
     *  position. Contents include a background and the (un)selected labels.
     */
    private var slidingContent:SpriteVisualElement;
    private var slidingContentOverlayClass:Class;
    private var slidingContentOverlay:DisplayObject;
    
    //----------------------------------------------------------------------------------------------
    //
    //  Skin parts
    //
    //----------------------------------------------------------------------------------------------
    
    /**
     *  The thumb skin part
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public var thumb:IVisualElement;
    
    /**
     *  The track skin part
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public var track:IVisualElement;
    
    //----------------------------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //----------------------------------------------------------------------------------------------
    
    //----------------------------------
    //  currentState
    //----------------------------------
    /**
     *  @private
     */
    override public function set currentState(value:String):void 
    {
        var isDown:Boolean = currentState && currentState.indexOf("down") >=0;
        
        super.currentState = value;
        
        if (isDown != currentState.indexOf("down") >= 0) 
        {
            invalidateDisplayList();
        }
    }
    
    //----------------------------------------------------------------------------------------------
    //
    //  Properties
    //
    //----------------------------------------------------------------------------------------------
    
    //----------------------------------
    //  hostComponent
    //----------------------------------
    
    private var _hostComponent:ToggleSwitch;
    
    /**
     * @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
    public function get hostComponent():ToggleSwitch 
    {
        return _hostComponent;
    }
    
    /**
     *  @private
     */
    public function set hostComponent(value:ToggleSwitch):void 
    {
        if (_hostComponent)
            _hostComponent.removeEventListener("thumbPositionChanged", thumbPositionChanged_handler);
        _hostComponent = value;
        if (_hostComponent)
            _hostComponent.addEventListener("thumbPositionChanged", thumbPositionChanged_handler);
    }
    
    //----------------------------------
    //  selectedLabelText
    //----------------------------------
    
    /**
     *  The text of the label showing when the component is selected
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    private function get selectedLabelText():String 
    {
        return resourceManager.getString("components","toggleSwitchSelectedLabel");
    }
    
    //----------------------------------
    //  unselectedLabelText
    //----------------------------------

    /**
     *  The text of the label showing when the component is not selected
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    private function get unselectedLabelText():String 
    {
        return resourceManager.getString("components", "toggleSwitchUnselectedLabel");
    }
    
    //----------------------------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //----------------------------------------------------------------------------------------------
    
    /**
     *  @private
     *  Redraw the graphics of the skin as necessary
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.drawBackground(unscaledWidth, unscaledHeight);
        
        // calculate skin dimensions
        var calculatedSkinWidth:Number = Math.max(unscaledWidth, getElementPreferredWidth(thumb));
        var calculatedSkinHeight:Number = Math.max(unscaledHeight, getElementPreferredHeight(thumb));

        drawSlidingContent(calculatedSkinWidth, calculatedSkinHeight);
        drawTrack(calculatedSkinWidth, calculatedSkinHeight);
        drawThumb(calculatedSkinWidth, calculatedSkinHeight);
        drawMask(calculatedSkinWidth, calculatedSkinHeight);
    }
    
    /**
     *  @private
     *  Resize and reposition as necessary
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void 
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        // calculate skin dimensions
        var calculatedSkinWidth:Number = Math.max(unscaledWidth, getElementPreferredWidth(thumb));
        var calculatedSkinHeight:Number = Math.max(unscaledHeight, getElementPreferredHeight(thumb));
        
        layoutSlidingContent(calculatedSkinWidth, calculatedSkinHeight);
        layoutTrack(calculatedSkinWidth, calculatedSkinHeight);
        layoutThumb(calculatedSkinWidth, calculatedSkinHeight);
        layoutMask(calculatedSkinWidth, calculatedSkinHeight);
    }
    
    /**
     *  @private
     */
    override protected function measure():void 
    {
        if (selectedLabel.isTruncated || unselectedLabel.isTruncated) 
        {
            selectedLabel.text = selectedLabelText;
            unselectedLabel.text = unselectedLabelText;
        }
        
        // The skin must be at least as large as the thumb
        measuredMinWidth = layoutThumbWidth;
        measuredMinHeight = layoutThumbWidth;
        
        // The preferred size will display all label text
        var labelWidth:Number = Math.max(getElementPreferredWidth(selectedLabel), 
            getElementPreferredWidth(unselectedLabel));
        
        measuredWidth = layoutThumbWidth + labelWidth + layoutInnerPadding + layoutOuterPadding;
        measuredHeight = layoutThumbHeight;
    }
    
    /**
     *  @private
     */
    override protected function commitCurrentState():void {
        if (currentState && currentState.indexOf("disabled") >= 0) 
            alpha = 0.5;
        else
            alpha = 1.0;
    }

    /**
     *  @private
     */
    override protected function createChildren():void 
    {
        super.createChildren();
        
        // SlidingContent: background, overlay, labels
        slidingContent = new SpriteVisualElement();
        slidingContentOverlay = new slidingContentOverlayClass();
        slidingContent.addChild(slidingContentOverlay);
        
        selectedLabelShadow = StyleableTextField(createInFontContext(StyleableTextField));
        selectedLabelShadow.styleName = this;
        selectedLabelShadow.colorName = "textShadowColor";
        selectedLabelShadow.text = selectedLabelText;
        slidingContent.addChild(selectedLabelShadow);
        
        selectedLabel = StyleableTextField(createInFontContext(StyleableTextField));
        selectedLabel.styleName = this;
        selectedLabel.text = selectedLabelText;
        slidingContent.addChild(selectedLabel);			
        
        unselectedLabelShadow = StyleableTextField(createInFontContext(StyleableTextField));
        unselectedLabelShadow.styleName = this;
        unselectedLabelShadow.colorName = "textShadowColor";
        unselectedLabelShadow.text = unselectedLabelText;
        slidingContent.addChild(unselectedLabelShadow);
        
        unselectedLabel = StyleableTextField(createInFontContext(StyleableTextField));
        unselectedLabel.styleName = this;
        unselectedLabel.text = unselectedLabelText;
        slidingContent.addChild(unselectedLabel);

        addChild(slidingContent);

        // Track
        track = new SpriteVisualElement();
        addChild(SpriteVisualElement(track));
        
        // Thumb
        thumb = new SpriteVisualElement();
        addChild(SpriteVisualElement(thumb));
        
        // Clipping Mask
        mask = new SpriteVisualElement();
        addChild(mask);
    }
    
    //----------------------------------------------------------------------------------------------
    //
    //  Methods
    //
    //----------------------------------------------------------------------------------------------
    
    /**
     *  Draw the sliding content background
     *  SlidingContent's x origin matches the thumb's x origin, meaning some of
     *  the background is drawn to the left, and some to the right.
     */
    private function drawSlidingContent(skinWidth:Number, skinHeight:Number):void 
    {
        slidingContent.graphics.clear();
        
        // selected side of the sliding content
        slidingContent.graphics.beginFill(getStyle("accentColor"));
        slidingContent.graphics.drawRect(layoutThumbWidth - skinWidth, 0, skinWidth - layoutThumbWidth / 2, 
            layoutThumbHeight);
        slidingContent.graphics.endFill();
        
        // unselected side of the sliding content
        slidingContent.graphics.beginFill(ColorUtil.adjustBrightness2(getStyle("chromeColor"), -25));
        slidingContent.graphics.drawRect(layoutThumbWidth / 2, 0, skinWidth - layoutThumbWidth / 2, 
            layoutThumbHeight);
        slidingContent.graphics.endFill();
        
        // clear the thumb area
        slidingContent.graphics.beginFill(getStyle("chromeColor"));
        slidingContent.graphics.drawRoundRect(0, 0, layoutThumbWidth, layoutThumbHeight, 
            layoutCornerRadius * 2);
        slidingContent.graphics.endFill();
    }
    
    /**
     *  Lay out SlidingContent and its children. Because we only need the x,y
     *  coordinate of SlidingContent, we can ignore its size.
     *  The origin of SlidingContent overlaps the origin of the thumb, and the
     *  positioning is handled by thumbPositionChanged_handler.
     */
    private function layoutSlidingContent(skinWidth:Number, skinHeight:Number):void {
        var visibleTrackArea:Number = skinWidth - layoutThumbWidth;
        
        layoutLabels(selectedLabel, selectedLabelShadow, (-visibleTrackArea + layoutOuterPadding), 0, 
            (visibleTrackArea - layoutInnerPadding - layoutOuterPadding), layoutThumbHeight, 
            layoutTextShadowOffset);
        layoutLabels(unselectedLabel, unselectedLabelShadow, (layoutThumbWidth + layoutInnerPadding), 0, 
            (visibleTrackArea - layoutInnerPadding - layoutOuterPadding), layoutThumbHeight, 
            layoutTextShadowOffset);
        
        setElementSize(slidingContentOverlay, 2 * skinWidth - layoutThumbWidth, layoutThumbHeight);
        setElementPosition(slidingContentOverlay, layoutThumbWidth - skinWidth, 
            (skinHeight - layoutThumbHeight) / 2);
    }
    
    /**
     *  Position a label and its shadow within the given rectangle
     */
    private function layoutLabels(label:StyleableTextField, labelShadow:StyleableTextField, 
                                  x:Number, y:Number, width:Number, height:Number, 
                                  shadowYOffset:Number):void 
    {
        var textWidth:Number = getElementPreferredWidth(label);
        var textHeight:Number = getElementPreferredHeight(label);
        
        var labelWidth:Number = Math.max(Math.min(textWidth, width), 0);
        var labelHeight:Number = textHeight;
        
        labelShadow.alpha = getStyle("textShadowAlpha");
        
        setElementSize(label, labelWidth, labelHeight);
        setElementSize(labelShadow, labelWidth, labelHeight);
        if (textWidth > labelWidth) {
            label.truncateToFit();
            labelShadow.truncateToFit();
        }
        
        var labelX:Number = x + (width - labelWidth) / 2;
        var labelY:Number = y + (height - labelHeight) / 2;
        
        setElementPosition(label, labelX, labelY);
        setElementPosition(labelShadow, labelX, labelY + shadowYOffset);
    }
    
    /**
     *  Draw the track and its shadow
     */
    private function drawTrack(skinWidth:Number, skinHeight:Number):void {
        var graphics:Graphics = SpriteVisualElement(track).graphics;
        graphics.clear();
        graphics.lineStyle(layoutStrokeWeight, 0, .3);
        graphics.drawRoundRect(layoutStrokeWeight / 2, layoutStrokeWeight / 2, 
            skinWidth - layoutStrokeWeight, 
            (layoutThumbHeight - layoutStrokeWeight), (layoutCornerRadius * 2 - layoutStrokeWeight / 2));
        graphics.lineStyle();
    }
    
    /**
     * Resize and reposition the track
     */
    private function layoutTrack(skinWidth:Number, skinHeight:Number):void 
    {
        setElementSize(track, skinWidth, layoutThumbHeight);
        setElementPosition(track, 0, (skinHeight - layoutThumbHeight) / 2);
    }
    
    /**
     * Draw the thumb. The thumb has an outer border, inner gradient, and
     * inner highlight stroke.
     */
    private function drawThumb(skinWidth:Number, skinHeight:Number):void {
        var graphics:Graphics = SpriteVisualElement(thumb).graphics;
        var colors:Array = [];
        var alphas:Array = [];
        var ratios:Array = [];
        var baseColor:Number = getStyle("chromeColor");
        
        if (currentState && currentState.indexOf("down") >= 0)
            baseColor = ColorUtil.adjustBrightness(baseColor, -60);
        
        graphics.clear();
        
        // Thumb outline
        colors[0] = ColorUtil.adjustBrightness2(baseColor, -70);
        colors[1] = ColorUtil.adjustBrightness2(baseColor, -55);
        
        alphas[0] = 1;
        alphas[1] = 1;
        
        ratios[0] = 0;
        ratios[1] = 255;
        
        colorMatrix.createGradientBox(layoutThumbWidth, layoutThumbHeight, Math.PI / 2);
        graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, colorMatrix);
        graphics.drawRoundRect(0, 0, layoutThumbWidth, layoutThumbHeight, layoutCornerRadius * 2);
        graphics.endFill();
        
        // Base gradient fill, one stroke weight inside outline
        colors[0] = ColorUtil.adjustBrightness2(baseColor, -30);
        colors[1] = baseColor;
        colors[2] = ColorUtil.adjustBrightness2(baseColor, 20);
        
        alphas[2] = 1;
        
        ratios[0] = 0;
        ratios[1] = .7 * 255;
        ratios[2] = 255;
        
        colorMatrix.createGradientBox(layoutThumbWidth - layoutStrokeWeight * 2, 
            layoutThumbHeight - layoutStrokeWeight * 2, Math.PI / 2);
        graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, colorMatrix);
        graphics.drawRoundRect(layoutStrokeWeight, layoutStrokeWeight, 
            layoutThumbWidth - layoutStrokeWeight * 2, 
            layoutThumbHeight - layoutStrokeWeight * 2, layoutCornerRadius * 2 - layoutStrokeWeight * 2);
        graphics.endFill();
        
        // Thumb highlight, one stroke weight inside outline
        colors[0] = 0xffffff;
        colors[1] = 0xffffff;
        colors[2] = 0x0;
        
        alphas[0] = 1;
        alphas[1] = 0;
        alphas[2] = .2;
        
        ratios[0] = .33 * 255;
        ratios[1] = .5 * 255;
        ratios[2] = 255;
        
        colorMatrix.createGradientBox(layoutThumbWidth - layoutStrokeWeight * 3, 
            layoutThumbHeight - layoutStrokeWeight * 3, Math.PI / 2);
        graphics.lineStyle(layoutStrokeWeight);
        graphics.lineGradientStyle(GradientType.LINEAR, colors, alphas, ratios, colorMatrix);
        graphics.drawRoundRect(layoutStrokeWeight * 1.5, layoutStrokeWeight * 1.5, 
            layoutThumbWidth - layoutStrokeWeight * 3, layoutThumbHeight - layoutStrokeWeight * 3, 
            layoutCornerRadius * 2 - layoutStrokeWeight * 3);
        graphics.lineStyle();
    }
    
    /**
     *  Resize the thumb. Its position is handled by the component.
     */
    private function layoutThumb(skinWidth:Number, skinHeight:Number):void 
    {
        setElementSize(thumb, layoutThumbWidth, layoutThumbHeight);
    }
    
    /**
     *  Draw the clipping mask for the component. This is roughly the
     *  same as the track area.
     */
    private function drawMask(skinWidth:Number, skinHeight:Number):void 
    {
            var graphics:Graphics = SpriteVisualElement(mask).graphics;
            graphics.clear();
            graphics.beginFill(0x0);
            graphics.drawRoundRect(0, 0, skinWidth, layoutThumbHeight, layoutCornerRadius * 2);
            graphics.endFill();
    }
    
    /**
     *  Resize and reposition the clipping mask
     */
    private function layoutMask(skinWidth:Number, skinHeight:Number):void 
    {
        setElementSize(mask, skinWidth, layoutThumbHeight);
        setElementPosition(mask, 0, (skinHeight - layoutThumbHeight) / 2);
    }
    
    //----------------------------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //----------------------------------------------------------------------------------------------
    
    /**
     *  When the thumb position changes, reposition the sliding content. The
     *  version here assumes the thumb and track share the same coordinate system.
     */
    private function thumbPositionChanged_handler(event:Event):void 
    {
        if (!hostComponent)
            return;
        var x:Number = (track.getLayoutBoundsWidth() - thumb.getLayoutBoundsWidth()) * 
            hostComponent.thumbPosition;
        setElementPosition(slidingContent, x, thumb.getLayoutBoundsY());
    }
}
}