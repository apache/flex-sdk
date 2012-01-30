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
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;

import mx.core.DPIClassification;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.utils.ColorUtil;

import spark.components.ToggleSwitch;
import spark.components.supportClasses.StyleableTextField;
import spark.core.SpriteVisualElement;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile160.assets.ToggleSwitch_contentShadow;
import spark.skins.mobile240.assets.ToggleSwitch_contentShadow;
import spark.skins.mobile320.assets.ToggleSwitch_contentShadow;

use namespace mx_internal;

/**
 *  ActionScript-based skin for the ToggleSwitch control. 
 *  The colors of the component can
 *  be customized using styles. This class is responsible for most of the
 *  graphics drawing, with some additional fxg assets.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 *
 *  @see spark.components.ToggleSwitch 
 */
public class ToggleSwitchSkin extends MobileSkin
{
    //----------------------------------------------------------------------------------------------
    //
    //  Constructor
    //
    //----------------------------------------------------------------------------------------------
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
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
                layoutBorderSize = 2;
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
                layoutBorderSize = 1;
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
                layoutBorderSize = 1;
                layoutTextShadowOffset = -1;
                layoutInnerPadding = 7;
                layoutOuterPadding = 11;
                slidingContentOverlayClass = spark.skins.mobile160.assets.ToggleSwitch_contentShadow;
                break;
            }
        }
        
        layoutCornerEllipseSize = layoutThumbHeight;
        selectedLabel = resourceManager.getString("components","toggleSwitchSelectedLabel");
        unselectedLabel =  resourceManager.getString("components","toggleSwitchUnselectedLabel");
    }
    
    //----------------------------------------------------------------------------------------------
    //
    //  Variables
    //
    //----------------------------------------------------------------------------------------------
    
    /**
     *  The width to draw the thumb skin part.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var layoutThumbWidth:Number;
    
    /**
     *  The height to draw the thumb skin part.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var layoutThumbHeight:Number;
    
    /**
     *  The corner radius of the thumb and track.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var layoutCornerEllipseSize:Number;
    
    /**
     *  The stroke weight outlining the graphics of the skin.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var layoutStrokeWeight:Number;
    
    /**
     *  The size of the border surrounding the component.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var layoutBorderSize:Number;
    
    /**
     *  The padding between the labels and the thumb.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var layoutInnerPadding:Number;
    
    /**
     *  The padding between the labels and the edge of the track.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var layoutOuterPadding:Number;
    
    /**
     *  The offset between a label and its shadow.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var layoutTextShadowOffset:Number;
    
    /**
     *  The label for the selected side of the component.
     *  Exposed for styling purposes only.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public var selectedLabelDisplay:LabelDisplayComponent;
    
    /**
     *  The label for the unselected side of the component.
     *  Exposed for styling purposes only.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public var unselectedLabelDisplay:LabelDisplayComponent;
    
    /**
     *  The content clipped by the track that slides to match the thumb's
     *  position. 
     *  Contents include a background and the (un)selected labels.
     *  The sliding content is stacked, from back to front, as background,
     *  shadow, foreground.
     */
    private var slidingContentBackground:SpriteVisualElement;
    private var slidingContentForeground:UIComponent;
    private var slidingContentOverlayClass:Class;
    private var slidingContentOverlay:DisplayObject;
    
    /**
     *  The contents inside the skin, not including the outline
     *  stroke
     */
    private var contents:UIComponent;
    
    /**
     *  The thumb erase overlay erases pixels behind the thumb. The thumb
     *  content contains the thumb graphics, and sits above the overlay.
     */
    private var thumbEraseOverlay:Sprite;
    private var thumbContent:Sprite;
    
    //----------------------------------------------------------------------------------------------
    //
    //  Skin parts
    //
    //----------------------------------------------------------------------------------------------
    
    /**
     *  The thumb skin part.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public var thumb:IVisualElement;
    
    /**
     *  The track skin part.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
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
    //  selectedLabel
    //----------------------------------
    
    private var _selectedLabel:String;
    /**
     *  The text of the label showing when the component is selected.
     *  Subclasses can set or override this property to customize the selected label.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected function get selectedLabel():String 
    {
        return _selectedLabel;
    }
    
    protected function set selectedLabel(value:String):void
    {
        _selectedLabel = value;
    }
    
    //----------------------------------
    //  unselectedLabel
    //----------------------------------
    
    private var _unselectedLabel:String;
    /**
     *  The text of the label showing when the component is not selected.
     *  Subclasses can set or override this property to customize the unselected label.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected function get unselectedLabel():String 
    {
        return _unselectedLabel;
    }
    
    protected function set unselectedLabel(value:String):void
    {
        _unselectedLabel = value;
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
        
        // calculate skin dimensions - outer stroke
        var calculatedContentWidth:Number = Math.max(unscaledWidth - 2 * layoutBorderSize, 
            getElementPreferredWidth(thumb));
        var calculatedContentHeight:Number = Math.max(unscaledHeight - 2 * layoutBorderSize, 
            getElementPreferredHeight(thumb));
        
        drawSlidingContent(calculatedContentWidth, calculatedContentHeight);
        drawTrack(calculatedContentWidth, calculatedContentHeight);
        drawThumb(calculatedContentWidth, calculatedContentHeight);
        drawMask(calculatedContentWidth, calculatedContentHeight);
        
        // simulate outer stroke using a larger filled rounded rect
        graphics.beginFill(0xffffff, 0.3);
        graphics.drawRoundRect(0, (calculatedContentHeight - layoutThumbHeight) / 2, 
            calculatedContentWidth + 2 * layoutBorderSize, 
            layoutThumbHeight + 2 * layoutBorderSize, 
            layoutCornerEllipseSize + layoutBorderSize);
        graphics.endFill();
    }
    
    /**
     *  @private
     *  Resize and reposition as necessary
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void 
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        // calculate skin dimensions - outer stroke
        var calculatedContentWidth:Number = Math.max(unscaledWidth - 2 * layoutBorderSize, 
            getElementPreferredWidth(thumb));
        var calculatedContentHeight:Number = Math.max(unscaledHeight - 2 * layoutBorderSize, 
            getElementPreferredHeight(thumb));
        
        setElementSize(contents, calculatedContentWidth, layoutThumbHeight);
        setElementPosition(contents, layoutBorderSize, 
            layoutBorderSize + (calculatedContentHeight - layoutThumbHeight) / 2);
        
        layoutTrack(calculatedContentWidth, layoutThumbHeight);
        layoutThumb(calculatedContentWidth, layoutThumbHeight);
        // Sliding content must be positioned after the track & thumb have been sized
        layoutSlidingContent(calculatedContentWidth, layoutThumbHeight);
        layoutMask(calculatedContentWidth, layoutThumbHeight);
    }
    
    /**
     *  @private
     */
    override protected function measure():void 
    {
        // The skin must be at least as large as the thumb + outer stroke
        measuredMinWidth = layoutThumbWidth + 2 * layoutBorderSize;
        measuredMinHeight = layoutThumbWidth + 2 * layoutBorderSize;
        
        // The preferred size will display all label text
        var labelWidth:Number = Math.max(getElementPreferredWidth(selectedLabelDisplay), 
            getElementPreferredWidth(unselectedLabelDisplay));
        
        measuredWidth = layoutThumbWidth + labelWidth + layoutInnerPadding + 
            layoutOuterPadding + 2 * layoutBorderSize;
        measuredHeight = layoutThumbHeight + 2 * layoutBorderSize;
    }
    
    /**
     *  @private
     */
    override protected function commitCurrentState():void 
    {
        if (currentState && currentState.indexOf("disabled") >= 0) 
        { 
            alpha = 0.5;
            selectedLabelDisplay.showShadow(false);
            unselectedLabelDisplay.showShadow(false);
        }
        else
        {
            alpha = 1.0;
            selectedLabelDisplay.showShadow(true);
            unselectedLabelDisplay.showShadow(true);
        }
    }
    
    /**
     *  @private
     */
    override protected function createChildren():void 
    {
        super.createChildren();
        
        contents = new UIComponent();
        contents.blendMode = BlendMode.LAYER;
        addChild(contents);
        
        // SlidingContent: background, overlay, labels
        slidingContentBackground = new SpriteVisualElement();
        contents.addChild(slidingContentBackground);
        
        slidingContentOverlay = new slidingContentOverlayClass();
        contents.addChild(slidingContentOverlay);
        
        slidingContentForeground = new UIComponent();
        contents.addChild(slidingContentForeground);
        
        selectedLabelDisplay = new LabelDisplayComponent();
        selectedLabelDisplay.id = "selectedLabelDisplay";
        selectedLabelDisplay.text = selectedLabel;
        selectedLabelDisplay.shadowYOffset = layoutTextShadowOffset;
        slidingContentForeground.addChild(selectedLabelDisplay);
        
        unselectedLabelDisplay = new LabelDisplayComponent();
        unselectedLabelDisplay.id = "unselectedLabelDisplay";
        unselectedLabelDisplay.text = unselectedLabel;
        unselectedLabelDisplay.shadowYOffset = layoutTextShadowOffset;
        slidingContentForeground.addChild(unselectedLabelDisplay);
        
        // Track
        track = new SpriteVisualElement();
        contents.addChild(SpriteVisualElement(track));
        
        // Thumb
        thumb = new SpriteVisualElement();
        contents.addChild(SpriteVisualElement(thumb));
        
        thumbEraseOverlay = new Sprite();
        thumbEraseOverlay.blendMode = BlendMode.ERASE;
        SpriteVisualElement(thumb).addChild(thumbEraseOverlay);
        thumbContent = new Sprite();
        SpriteVisualElement(thumb).addChild(thumbContent);
        
        // Content clipping mask
        var contentMask:Sprite = new SpriteVisualElement();
        contents.mask = contentMask;
        contents.addChild(contentMask);
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
        slidingContentBackground.graphics.clear();
        
        // selected side of the sliding content
        slidingContentBackground.graphics.beginFill(getStyle("accentColor"));
        slidingContentBackground.graphics.drawRect(layoutThumbWidth - skinWidth, 0, skinWidth - layoutThumbWidth / 2, 
            layoutThumbHeight);
        slidingContentBackground.graphics.endFill();
        
        // unselected side of the sliding content
        slidingContentBackground.graphics.beginFill(ColorUtil.adjustBrightness2(getStyle("chromeColor"), -25));
        slidingContentBackground.graphics.drawRect(layoutThumbWidth / 2, 0, skinWidth - layoutThumbWidth / 2, 
            layoutThumbHeight);
        slidingContentBackground.graphics.endFill();
    }
    
    /**
     *  Lay out SlidingContent and its children. Because we only need the x,y
     *  coordinate of SlidingContent, we can ignore its size.
     *  The origin of SlidingContent overlaps the origin of the thumb, and the
     *  positioning is handled by thumbPositionChanged_handler.
     */
    private function layoutSlidingContent(skinWidth:Number, skinHeight:Number):void 
    {
        var visibleTrackWidth:Number = skinWidth - layoutThumbWidth;
        var labelWidth:Number = visibleTrackWidth - layoutInnerPadding - layoutOuterPadding;
        
        setElementSize(selectedLabelDisplay, labelWidth, layoutThumbHeight);
        setElementPosition(selectedLabelDisplay, -visibleTrackWidth + layoutOuterPadding, 0);
        
        setElementSize(unselectedLabelDisplay, labelWidth, layoutThumbHeight);
        setElementPosition(unselectedLabelDisplay, layoutThumbWidth + layoutInnerPadding, 0);
        
        setElementSize(slidingContentOverlay, skinWidth, layoutThumbHeight);
        setElementPosition(slidingContentOverlay, 0, (skinHeight - layoutThumbHeight) / 2);
        
        moveSlidingContent();
    }
    
    /**
     *  Draw the track and its shadow
     */
    private function drawTrack(skinWidth:Number, skinHeight:Number):void 
    {
        var graphics:Graphics = SpriteVisualElement(track).graphics;
        graphics.clear();
        graphics.lineStyle(layoutStrokeWeight, 0, .3);
        graphics.drawRoundRect(layoutStrokeWeight / 2, layoutStrokeWeight / 2, 
            skinWidth - layoutStrokeWeight, 
            (layoutThumbHeight - layoutStrokeWeight), (layoutCornerEllipseSize - layoutStrokeWeight / 2));
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
    private function drawThumb(skinWidth:Number, skinHeight:Number):void 
    {
        var graphics:Graphics = thumbContent.graphics;
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
        graphics.drawRoundRect(0, 0, layoutThumbWidth, layoutThumbHeight, layoutCornerEllipseSize);
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
            layoutThumbHeight - layoutStrokeWeight * 2, layoutCornerEllipseSize - layoutStrokeWeight * 2);
        graphics.endFill();
        
        // Thumb highlight, one stroke weight inside outline
        colors[0] = 0xffffff;
        colors[1] = 0xffffff;
        colors[2] = 0x0;
        
        alphas[0] = .9;
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
            layoutCornerEllipseSize - layoutStrokeWeight * 3);
        graphics.lineStyle();

        // Redraw the erase overlay as a silhouette of the thumb
        thumbEraseOverlay.graphics.clear();
        thumbEraseOverlay.graphics.beginFill(0);
        thumbEraseOverlay.graphics.drawRoundRect(0, 0, layoutThumbWidth, layoutThumbHeight, layoutCornerEllipseSize);
        thumbEraseOverlay.graphics.endFill();
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
        var graphics:Graphics = SpriteVisualElement(contents.mask).graphics;
        graphics.clear();
        graphics.beginFill(0x0);
        graphics.drawRoundRect(0, 0, skinWidth, layoutThumbHeight, layoutCornerEllipseSize);
        graphics.endFill();
    }
    
    /**
     *  Resize and reposition the clipping mask
     */
    private function layoutMask(skinWidth:Number, skinHeight:Number):void 
    {
        setElementSize(contents.mask, skinWidth, layoutThumbHeight);
        setElementPosition(contents.mask, 0, (skinHeight - layoutThumbHeight) / 2);
    }
    
    /**
     *  Move the sliding content to line up with thumbPosition.
     *  This version assumes the thumb and track share the same coordinate system.
     */
    private function moveSlidingContent():void 
    {
        if (!hostComponent)
            return;
        var x:Number = (track.getLayoutBoundsWidth() - thumb.getLayoutBoundsWidth()) * 
            hostComponent.thumbPosition + track.getLayoutBoundsX();
        var y:Number = thumb.getLayoutBoundsY();
        setElementPosition(slidingContentBackground, x, y);
        setElementPosition(slidingContentForeground, x, y);
    }
    
    //----------------------------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //----------------------------------------------------------------------------------------------
    
    /**
     *  When the thumb position changes, reposition the sliding content. 
     */
    private function thumbPositionChanged_handler(event:Event):void 
    {
        moveSlidingContent();
    }
}
}

import flash.events.Event;

import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.supportClasses.StyleableTextField;
import spark.core.IDisplayText;

use namespace mx_internal;

/**
 *  @private
 *  Component combining two labels to create the effect of text and its drop
 *  shadow. The component can be used with advanced style selectors and the
 *  styles "color", "textShadowColor", and "textShadowAlpha". Based off of
 *  ActionBar.TitleDisplayComponent. These two should eventually be factored.
 */
class LabelDisplayComponent extends UIComponent implements IDisplayText
{
    public var shadowYOffset:Number = 0;
    private var labelChanged:Boolean = false;
    private var labelDisplay:StyleableTextField;
    private var labelDisplayShadow:StyleableTextField;
    private var _text:String;
    
    public function LabelDisplayComponent() 
    {
        super();
        _text = "";
    }
    
    override public function get baselinePosition():Number 
    {
        return labelDisplay.baselinePosition;
    }
    
    override protected function createChildren():void 
    {
        super.createChildren();
        
        labelDisplay = StyleableTextField(createInFontContext(StyleableTextField));
        labelDisplay.styleName = this;
        labelDisplay.editable = false;
        labelDisplay.selectable = false;
        labelDisplay.multiline = false;
        labelDisplay.wordWrap = false;
        labelDisplay.addEventListener(FlexEvent.VALUE_COMMIT,
            labelDisplay_valueCommitHandler);
        
        labelDisplayShadow = StyleableTextField(createInFontContext(StyleableTextField));
        labelDisplayShadow.styleName = this;
        labelDisplayShadow.colorName = "textShadowColor";
        labelDisplayShadow.editable = false;
        labelDisplayShadow.selectable = false;
        labelDisplayShadow.multiline = false;
        labelDisplayShadow.wordWrap = false;
        
        addChild(labelDisplayShadow);
        addChild(labelDisplay);
    }
    
    override protected function commitProperties():void 
    {
        super.commitProperties();
        
        if (labelChanged)
        {
            labelDisplay.text = text;
            invalidateSize();
            invalidateDisplayList();
            labelChanged = false;
        }
    }
    
    override protected function measure():void 
    {
        if (labelDisplay.isTruncated)
            labelDisplay.text = text;
        labelDisplay.commitStyles();
        measuredWidth = labelDisplay.getPreferredBoundsWidth();
        measuredHeight = labelDisplay.getPreferredBoundsHeight();
    }
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
    {
        if (labelDisplay.isTruncated)
            labelDisplay.text = text;
        labelDisplay.commitStyles();
        
        var labelHeight:Number = labelDisplay.getPreferredBoundsHeight();
        var labelY:Number = (unscaledHeight - labelHeight) / 2;
        
        var labelWidth:Number = Math.min(unscaledWidth, labelDisplay.getPreferredBoundsWidth());
        var labelX:Number = (unscaledWidth - labelWidth) / 2;
        
        labelDisplay.setLayoutBoundsSize(labelWidth, labelHeight);
        labelDisplay.setLayoutBoundsPosition(labelX, labelY);
        
        labelDisplay.truncateToFit();
        
        labelDisplayShadow.commitStyles();
        labelDisplayShadow.setLayoutBoundsSize(labelWidth, labelHeight);
        labelDisplayShadow.setLayoutBoundsPosition(labelX, labelY + shadowYOffset);
        
        labelDisplayShadow.alpha = getStyle("textShadowAlpha");
        
        // unless the label was truncated, labelDisplayShadow.text was set in
        // the value commit handler
        if (labelDisplay.isTruncated)
            labelDisplayShadow.text = labelDisplay.text;
    }
    
    private function labelDisplay_valueCommitHandler(event:Event):void 
    {
        labelDisplayShadow.text = labelDisplay.text;
    }
    
    public function get text():String 
    {
        return _text;
    }
    
    public function set text(value:String):void 
    {
        _text = value;
        labelChanged = true;
        invalidateProperties();
    }
    
    public function get isTruncated():Boolean 
    {
        return labelDisplay.isTruncated;
    }
    
    public function showShadow(value:Boolean):void 
    {
        labelDisplayShadow.visible = value;
    }
}