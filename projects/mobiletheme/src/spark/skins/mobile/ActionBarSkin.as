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

package spark.skins.mobile
{
import flash.display.GradientType;
import flash.events.Event;
import flash.geom.Matrix;
import flash.text.TextFormatAlign;
import flash.text.TextLineMetrics;

import mx.core.UIComponent;
import mx.core.UITextField;
import mx.core.mx_internal;
import mx.events.ResizeEvent;
import mx.utils.ColorUtil;

import spark.components.ActionBar;
import spark.components.Group;
import spark.components.supportClasses.StyleableTextField;
import spark.core.IDisplayText;
import spark.core.SpriteVisualElement;
import spark.layouts.HorizontalAlign;
import spark.layouts.HorizontalLayout;
import spark.layouts.VerticalAlign;
import spark.skins.mobile.assets.ActionBarBackground;
import spark.skins.mobile.supportClasses.MobileSkin;

use namespace mx_internal;

/**
 *  The default skin class for the Spark ActionBar component.  
 *  
 *  @see spark.components.ActionBar
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class ActionBarSkin extends MobileSkin
{
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    public function ActionBarSkin()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    private static var BORDER_HEIGHT:uint = 1;
    
    private static var SHADOW_HEIGHT:uint = 3;
    
    private static var CONTENT_GROUP_HEIGHT:uint = 65;
    
    public var hostComponent:ActionBar;
    
    public var navigationGroup:Group;
    
    private var _navigationVisible:Boolean = false;
    
    public var titleGroup:Group;
    
    private var _titleContentVisible:Boolean = false;
    
    public var actionGroup:Group;
    
    private var _actionVisible:Boolean = false;
    
    public var titleDisplay:TitleDisplayComponent;
    
    private var border:SpriteVisualElement;
    
    private static var matrix:Matrix = new Matrix();
    
    private static const ratios:Array = [0, 127.5, 255];
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    override protected function createChildren():void
    {
        border = new ActionBarBackground();
        addChild(border);
        
        navigationGroup = new Group();
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.horizontalAlign = HorizontalAlign.LEFT;
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 0;
        hLayout.paddingLeft = hLayout.paddingTop = hLayout.paddingRight = 
            hLayout.paddingBottom = 0;
        navigationGroup.layout = hLayout;
        
        titleGroup = new Group();
        hLayout = new HorizontalLayout();
        hLayout.horizontalAlign = HorizontalAlign.LEFT;
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 0;
        hLayout.paddingLeft = hLayout.paddingRight = 20; 
        hLayout.paddingTop = hLayout.paddingBottom = 0;
        titleGroup.layout = hLayout;
        
        actionGroup = new Group();
        hLayout = new HorizontalLayout();
        hLayout.horizontalAlign = HorizontalAlign.RIGHT;
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 0;
        hLayout.paddingLeft = hLayout.paddingTop = hLayout.paddingRight = 
            hLayout.paddingBottom = 0;
        actionGroup.layout = hLayout;
        
        titleDisplay = new TitleDisplayComponent();
        
        initializeStyles();
        
        addChild(navigationGroup);
        addChild(titleGroup);
        addChild(actionGroup);
        addChild(titleDisplay);
    }
    
    protected function initializeStyles():void
    {
        // ID selectors to style contents of each group separately
        navigationGroup.id = "navigationGroup";
        titleGroup.id = "titleGroup";
        actionGroup.id = "actionGroup";
        titleDisplay.id = "titleDisplay";
    }
    
    override protected function measure():void
    {
        var titleWidth:Number = 0;
        var titleHeight:Number = 0;
        
        if (_titleContentVisible)
        {
            titleWidth = titleGroup.getPreferredBoundsWidth();
            titleHeight = titleGroup.getPreferredBoundsHeight();
        }
        else
        {
            // use titleLayout for paddingLeft and paddingRight
            var layoutObject:Object = hostComponent.titleLayout;
            titleWidth = ((layoutObject.paddingLeft) ? Number(layoutObject.paddingLeft) : 0)
                + ((layoutObject.paddingRight) ? Number(layoutObject.paddingRight) : 0)
                + titleDisplay.getPreferredBoundsWidth();
            
            titleHeight = titleDisplay.getPreferredBoundsHeight();
        }
        
        measuredMinWidth = measuredWidth =
            navigationGroup.getPreferredBoundsWidth()
            + actionGroup.getPreferredBoundsWidth()
            + titleWidth;
        
        // min height is 67 (65px content height, 1px borders on top and bottom)
        // Math.max.apply optimization used instead of "..." rest parameter
        measuredMinHeight = measuredHeight =
            Math.max(CONTENT_GROUP_HEIGHT,
                navigationGroup.getPreferredBoundsHeight(), 
                actionGroup.getPreferredBoundsHeight(),
                titleHeight)
            + (BORDER_HEIGHT * 2);
    }
    
    override protected function commitCurrentState():void
    {
        super.commitCurrentState();
        
        _titleContentVisible = currentState.indexOf("titleContent") >= 0;
        _navigationVisible = currentState.indexOf("Navigation") >= 0;
        _actionVisible = currentState.indexOf("Action") >= 0;
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        graphics.clear();
        
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        var navigationGroupWidth:Number = 0;
        
        var titleCompX:Number = 0;
        var titleCompWidth:Number = 0;
        var titleHeight:Number = 0;
        var titleCompY:Number = 0;
        
        var actionGroupX:Number = unscaledWidth;
        var actionGroupWidth:Number = 0;
        
        // remove top and bottom borders from content group height
        var contentGroupsHeight:Number = unscaledHeight - (BORDER_HEIGHT * 2);
        
        // FXG uses scale-9, 3 px drop shadow is drawn outside the bounds
        resizePart(border, unscaledWidth, unscaledHeight + SHADOW_HEIGHT);
        
        // position groups, overlap of navigation and action groups is allowed
        // when overlap occurs, titleDisplay/titleGroup is not visible
        if (_navigationVisible)
        {
            navigationGroupWidth = navigationGroup.getPreferredBoundsWidth();
            titleCompX += navigationGroupWidth;
            
            navigationGroup.setLayoutBoundsSize(navigationGroupWidth, contentGroupsHeight);
            navigationGroup.setLayoutBoundsPosition(0, BORDER_HEIGHT);
        }
        
        if (_actionVisible)
        {
            // actionGroup x position can be negative
            actionGroupWidth = actionGroup.getPreferredBoundsWidth();
            actionGroupX = unscaledWidth - actionGroupWidth;
            
            actionGroup.setLayoutBoundsSize(actionGroupWidth, contentGroupsHeight);
            actionGroup.setLayoutBoundsPosition(actionGroupX, BORDER_HEIGHT);
        }
        
        titleCompWidth = unscaledWidth - navigationGroupWidth - actionGroupWidth;
        if (titleCompWidth <= 0)
        {
            titleDisplay.visible = false;
            titleGroup.visible = false;
        }
        else if (_titleContentVisible)
        {
            titleDisplay.visible = false;
            titleGroup.visible = true;
            
            // use titleGroup for titleContent
            titleGroup.setLayoutBoundsSize(titleCompWidth, contentGroupsHeight);
            titleGroup.setLayoutBoundsPosition(titleCompX, BORDER_HEIGHT);
        }
        else
        {
            // use titleDisplay for title text label
            titleGroup.visible = false;
            
            // use titleLayout for paddingLeft and paddingRight
            var layoutObject:Object = hostComponent.titleLayout;
            var titlePaddingLeft:Number = (layoutObject.paddingLeft) ? Number(layoutObject.paddingLeft) : 0;
            var titlePaddingRight:Number = (layoutObject.paddingRight) ? Number(layoutObject.paddingRight) : 0;
            
            // vertical align center by subtracting the descent and top gutter
            titleHeight = titleDisplay.getExplicitOrMeasuredHeight();
            titleCompY = Math.round((contentGroupsHeight - titleHeight - UITextField.TEXT_HEIGHT_PADDING + titleDisplay.descent) / 2);
            
            // align titleDisplay to the absolute center
            var titleAlign:String = getStyle("titleAlign");
            
            // check for available width after padding
            if ((titleCompWidth - titlePaddingLeft - titlePaddingRight) <= 0)
            {
                titleCompX = 0;
                titleCompWidth = 0;
            }
            else if (titleAlign == "center")
            { 
                // use LEFT instead of CENTER
                titleDisplay.setStyle("textAlign", TextFormatAlign.LEFT);
                titleCompWidth = titleDisplay.getExplicitOrMeasuredWidth();
                
                // use x position of titleDisplay to implement CENTER
                titleCompX = Math.round((unscaledWidth - titleCompWidth) / 2); 
                
                var navigationOverlap:Number = navigationGroupWidth + titlePaddingLeft - titleCompX;
                var actionOverlap:Number = (titleCompX + titleCompWidth + titlePaddingRight) - actionGroupX;
                
                // shrink and/or move titleDisplay width if there is any
                // overlap after centering
                if ((navigationOverlap > 0) && (actionOverlap > 0))
                {
                    // remaining width
                    titleCompX = navigationGroupWidth + titlePaddingLeft;
                    titleCompWidth = unscaledWidth - navigationGroupWidth - actionGroupWidth - titlePaddingLeft - titlePaddingRight;
                }
                else if ((navigationOverlap > 0) || (actionOverlap > 0))
                {
                    if (navigationOverlap > 0)
                    {
                        // nudge to the right
                        titleCompX += navigationOverlap;
                    }
                    else if (actionOverlap > 0)
                    {
                        // nudge to the left
                        titleCompX -= actionOverlap;
                        
                        // force left padding
                        if (titleCompX < (navigationGroupWidth + titlePaddingLeft))
                            titleCompX = navigationGroupWidth + titlePaddingLeft;
                    }
                    
                    // recompute action overlap and force right padding
                    actionOverlap = (titleCompX + titleCompWidth + titlePaddingRight) - actionGroupX;
                    
                    if (actionOverlap > 0)
                        titleCompWidth -= actionOverlap;
                }
            }
            else
            {
                titleDisplay.setStyle("textAlign", titleAlign);
                
                // implement padding by adjusting width and position
                titleCompX += titlePaddingLeft;
                titleCompWidth -= titlePaddingLeft + titlePaddingRight;
            }
            
            // check for negative width
            titleCompWidth = (titleCompWidth < 0) ? 0 : titleCompWidth;
            
            titleDisplay.setLayoutBoundsSize(titleCompWidth, titleHeight);
            titleDisplay.setLayoutBoundsPosition(titleCompX, titleCompY);
            
            titleDisplay.visible = true;
        }
        
        // Draw the gradient background
        var chromeColor:uint = getStyle("chromeColor");
        var backgroundAlphaValue:Number = getStyle("backgroundAlpha");
        var colors:Array = [];
        
        // apply alpha to border and chromeColor
        border.alpha = backgroundAlphaValue;
        var backgroundAlphas:Array = [backgroundAlphaValue, backgroundAlphaValue, backgroundAlphaValue];
        
        // exclude top and bottom 1px borders
        matrix.createGradientBox(unscaledWidth, contentGroupsHeight, Math.PI / 2, 0, 0);
        
        colors[0] = ColorUtil.adjustBrightness2(chromeColor, 20);
        colors[1] = chromeColor;
        colors[2] = ColorUtil.adjustBrightness2(chromeColor, -20);
        
        graphics.beginGradientFill(GradientType.LINEAR, colors, backgroundAlphas, ratios, matrix);
        graphics.drawRect(0, BORDER_HEIGHT, unscaledWidth, contentGroupsHeight);
        graphics.endFill();
    }
}
}
import flash.events.Event;
import flash.text.TextLineMetrics;

import mx.core.UIComponent;
import mx.core.UITextField;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.supportClasses.StyleableTextField;
import spark.core.IDisplayText;

use namespace mx_internal;

/**
 *  @private
 *  Component that holds StyleableTextFields to produce a drop shadow effect.
 */
class TitleDisplayComponent extends UIComponent implements IDisplayText
{
    private static var TEXT_WIDTH_PADDING:Number =
        UITextField.TEXT_WIDTH_PADDING + 1;
    
    private var titleDisplay:StyleableTextField;
    private var titleDisplayShadow:StyleableTextField;
    private var title:String;
    private var titleChanged:Boolean;
    public var descent:Number;
    
    public function TitleDisplayComponent()
    {
        super();
        title = "";
    }
    
    override protected function createChildren():void
    {
        super.createChildren();
        
        titleDisplay = StyleableTextField(createInFontContext(StyleableTextField));
        titleDisplay.styleProvider = this;
        titleDisplay.editable = false;
        titleDisplay.selectable = false;
        titleDisplay.multiline = false;
        titleDisplay.wordWrap = false;
        titleDisplay.addEventListener(FlexEvent.VALUE_COMMIT,
            titleDisplay_valueCommitHandler);
        
        titleDisplayShadow =
            StyleableTextField(createInFontContext(StyleableTextField));
        titleDisplayShadow.styleProvider = this;
        titleDisplayShadow.colorName = "textShadowColor";
        titleDisplayShadow.editable = false;
        titleDisplayShadow.selectable = false;
        titleDisplayShadow.multiline = false;
        titleDisplayShadow.wordWrap = false;
        titleDisplayShadow.alpha = .45;
        
        addChild(titleDisplayShadow);
        addChild(titleDisplay);
    }
    
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (titleChanged)
        {
            if (titleDisplay)
            {
                titleDisplay.text = title;
                invalidateSize();
                
                invalidateDisplayList();
            }
            
            titleChanged = false;
        }
    }
    
    override protected function measure():void
    {
        var textWidth:Number = 0;
        var textHeight:Number = 0;
        var lineMetrics:TextLineMetrics;
        
        if (title != "")
        {
            lineMetrics = measureText(title);
            textWidth = lineMetrics.width + TEXT_WIDTH_PADDING;
        }
        else
        {
            lineMetrics = measureText("Wj");
        }
        
        textHeight = lineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;
        descent = lineMetrics.descent;
        
        measuredWidth = textWidth;
        measuredHeight = textHeight;
    }
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        titleDisplay.commitStyles();
        titleDisplay.width = unscaledWidth;
        titleDisplay.height = unscaledHeight;
        
        // before truncating text, we need to reset it to its original value
        if (titleDisplay.isTruncated)
            titleDisplay.text = title;
        titleDisplay.truncateToFit();
        
        titleDisplayShadow.commitStyles();
        titleDisplayShadow.y = titleDisplay.y - 1; // -90 degree shadow
        titleDisplayShadow.width = unscaledWidth;
        titleDisplayShadow.height = unscaledHeight;
        
        // if labelDisplay is truncated, then push it down here as well.
        // otherwise, it would have gotten pushed in the labelDisplay_valueCommitHandler()
        if (titleDisplay.isTruncated)
            titleDisplayShadow.text = titleDisplay.text;
    }
    
    override public function styleChanged(styleProp:String):void 
    {
        super.styleChanged(styleProp);
        
        if (titleDisplay)
            titleDisplay.styleChanged(styleProp);
        
        if (titleDisplayShadow)
            titleDisplayShadow.styleChanged(styleProp);
    }
    
    /**
     *  @private 
     */ 
    private function titleDisplay_valueCommitHandler(event:Event):void 
    {
        titleDisplayShadow.text = titleDisplay.text;
    }
    
    public function get text():String
    {
        return title;
    }
    
    public function set text(value:String):void
    {
        title = value;
        titleChanged = true;
        
        invalidateProperties();
    }
    
    public function get isTruncated():Boolean
    {
        if (titleDisplay)
            return titleDisplay.isTruncated;
        
        return false;
    }
}