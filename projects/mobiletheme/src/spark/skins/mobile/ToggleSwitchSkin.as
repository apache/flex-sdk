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
                layoutOuterStrokeWeight = 2;
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
                layoutOuterStrokeWeight = 1;
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
                layoutOuterStrokeWeight = 1;
                layoutTextShadowOffset = -1;
                layoutInnerPadding = 7;
                layoutOuterPadding = 11;
                slidingContentOverlayClass = spark.skins.mobile160.assets.ToggleSwitch_contentShadow;
                break;
            }
        }
        
        layoutCornerRadius = layoutThumbHeight / 2;
        selectedLabelText = resourceManager.getString("components","toggleSwitchSelectedLabel");
        unselectedLabelText =  resourceManager.getString("components","toggleSwitchUnselectedLabel");
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
     *  The stroke weight outlining the component
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected var layoutOuterStrokeWeight:Number;
    
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
     *  The sliding content is stacked, from back to front, as background,
     *  shadow, foreground.
     */
    private var slidingContentBackground:SpriteVisualElement;
    private var slidingContentForeground:SpriteVisualElement;
    private var slidingContentOverlayClass:Class;
    private var slidingContentOverlay:DisplayObject;
    
	/**
	 *  The contents inside the skin, not including the outline
	 *  stroke
	 */
	private var contents:SpriteVisualElement;
	
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
    
    private var _selectedLabelText:String;
    /**
     *  The text of the label showing when the component is selected.
     *  Subclasses can override this to customize the selected label.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected function get selectedLabelText():String 
    {
        return _selectedLabelText;
    }
    
    protected function set selectedLabelText(value:String):void
    {
        _selectedLabelText = value;
    }
    
    //----------------------------------
    //  unselectedLabelText
    //----------------------------------

    private var _unselectedLabelText:String;
    /**
     *  The text of the label showing when the component is not selected.
     *  Subclasses can override this to customize the unselected label.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected function get unselectedLabelText():String 
    {
        return _unselectedLabelText;
    }
    
    protected function set unselectedLabelText(value:String):void
    {
        _unselectedLabelText = value;
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
        var calculatedContentWidth:Number = Math.max(unscaledWidth - 2 * layoutOuterStrokeWeight, 
            getElementPreferredWidth(thumb));
        var calculatedContentHeight:Number = Math.max(unscaledHeight - 2 * layoutOuterStrokeWeight, 
            getElementPreferredHeight(thumb));

        drawSlidingContent(calculatedContentWidth, calculatedContentHeight);
        drawTrack(calculatedContentWidth, calculatedContentHeight);
        drawThumb(calculatedContentWidth, calculatedContentHeight);
        drawMask(calculatedContentWidth, calculatedContentHeight);
		
		// simulate outer stroke using a larger filled rounded rect
        graphics.clear();
        graphics.beginFill(0xffffff, 0.3);
		graphics.drawRoundRect(0, (calculatedContentHeight - layoutThumbHeight) / 2, 
            calculatedContentWidth + 2 * layoutOuterStrokeWeight, 
            layoutThumbHeight + 2 * layoutOuterStrokeWeight, 
            2 * layoutCornerRadius + layoutOuterStrokeWeight);
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
        var calculatedContentWidth:Number = Math.max(unscaledWidth - 2 * layoutOuterStrokeWeight, 
            getElementPreferredWidth(thumb));
        var calculatedContentHeight:Number = Math.max(unscaledHeight - 2 * layoutOuterStrokeWeight, 
            getElementPreferredHeight(thumb));

		setElementSize(contents, calculatedContentWidth, layoutThumbHeight);
		setElementPosition(contents, layoutOuterStrokeWeight, 
            layoutOuterStrokeWeight + (calculatedContentHeight - layoutThumbHeight) / 2);
        
        layoutTrack(calculatedContentWidth, layoutThumbHeight);
        // Sliding content must be positioned after the track has been sized
        layoutSlidingContent(calculatedContentWidth, layoutThumbHeight);
        layoutThumb(calculatedContentWidth, layoutThumbHeight);
        layoutMask(calculatedContentWidth, layoutThumbHeight);
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
        
        // The skin must be at least as large as the thumb + outer stroke
        measuredMinWidth = layoutThumbWidth + 2 * layoutOuterStrokeWeight;
        measuredMinHeight = layoutThumbWidth + 2 * layoutOuterStrokeWeight;
        
        // The preferred size will display all label text
        var labelWidth:Number = Math.max(getElementPreferredWidth(selectedLabel), 
            getElementPreferredWidth(unselectedLabel));
        
        measuredWidth = layoutThumbWidth + labelWidth + layoutInnerPadding + 
            layoutOuterPadding + 2 * layoutOuterStrokeWeight;
        measuredHeight = layoutThumbHeight + 2 * layoutOuterStrokeWeight;
    }
    
    /**
     *  @private
     */
    override protected function commitCurrentState():void 
    {
        if (currentState && currentState.indexOf("disabled") >= 0) 
        { 
            alpha = 0.5;
            selectedLabelShadow.visible = false;
            unselectedLabelShadow.visible = false;
        }
        else
        {
            alpha = 1.0;
            selectedLabelShadow.visible = true;
            unselectedLabelShadow.visible = true;
        }
    }

    /**
     *  @private
     */
    override protected function createChildren():void 
    {
        super.createChildren();
        
		contents = new SpriteVisualElement();
		addChild(contents);
		
		// SlidingContent: background, overlay, labels
        slidingContentBackground = new SpriteVisualElement();
        contents.addChild(slidingContentBackground);

        slidingContentOverlay = new slidingContentOverlayClass();
        contents.addChild(slidingContentOverlay);
        
        slidingContentForeground = new SpriteVisualElement();
        contents.addChild(slidingContentForeground);
        
        selectedLabelShadow = StyleableTextField(createInFontContext(StyleableTextField));
        selectedLabelShadow.styleName = this;
        selectedLabelShadow.colorName = "textShadowColor";
        selectedLabelShadow.text = selectedLabelText;
        slidingContentForeground.addChild(selectedLabelShadow);
        
        selectedLabel = StyleableTextField(createInFontContext(StyleableTextField));
        selectedLabel.styleName = this;
        selectedLabel.text = selectedLabelText;
        slidingContentForeground.addChild(selectedLabel);			
        
        unselectedLabelShadow = StyleableTextField(createInFontContext(StyleableTextField));
        unselectedLabelShadow.styleName = this;
        unselectedLabelShadow.colorName = "textShadowColor";
        unselectedLabelShadow.text = unselectedLabelText;
        slidingContentForeground.addChild(unselectedLabelShadow);
        
        unselectedLabel = StyleableTextField(createInFontContext(StyleableTextField));
        unselectedLabel.styleName = this;
        unselectedLabel.text = unselectedLabelText;
        slidingContentForeground.addChild(unselectedLabel);

        // Track
        track = new SpriteVisualElement();
        contents.addChild(SpriteVisualElement(track));
        
        // Thumb
        thumb = new SpriteVisualElement();
        contents.addChild(SpriteVisualElement(thumb));
        
        // Thumb clipping mask
        var thumbMask:Sprite = new Sprite();
        SpriteVisualElement(thumb).mask = thumbMask;
        SpriteVisualElement(thumb).addChild(thumbMask);
        
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
        var visibleTrackArea:Number = skinWidth - layoutThumbWidth;
        
        layoutLabels(selectedLabel, selectedLabelShadow, (-visibleTrackArea + layoutOuterPadding), 0, 
            (visibleTrackArea - layoutInnerPadding - layoutOuterPadding), layoutThumbHeight, 
            layoutTextShadowOffset);
        layoutLabels(unselectedLabel, unselectedLabelShadow, (layoutThumbWidth + layoutInnerPadding), 0, 
            (visibleTrackArea - layoutInnerPadding - layoutOuterPadding), layoutThumbHeight, 
            layoutTextShadowOffset);
        
        setElementSize(slidingContentOverlay, skinWidth, layoutThumbHeight);
        setElementPosition(slidingContentOverlay, 0, (skinHeight - layoutThumbHeight) / 2);
        
        moveSlidingContent();
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
    private function drawTrack(skinWidth:Number, skinHeight:Number):void 
    {
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
    private function drawThumb(skinWidth:Number, skinHeight:Number):void 
    {
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
            layoutCornerRadius * 2 - layoutStrokeWeight * 3);
        graphics.lineStyle();
        
        // When alpha is set, we do not want the thumb to show through to the track 
        var thumbMask:Sprite = Sprite(SpriteVisualElement(thumb).mask);
        thumbMask.graphics.clear();
        thumbMask.graphics.beginFill(0xffffff);
        thumbMask.graphics.drawRoundRect(0, 0, layoutThumbWidth, layoutThumbHeight, 2 * layoutCornerRadius);
        thumbMask.graphics.endFill();
        SpriteVisualElement(thumb).opaqueBackground = baseColor;
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
        graphics.drawRoundRect(0, 0, skinWidth, layoutThumbHeight, layoutCornerRadius * 2);
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