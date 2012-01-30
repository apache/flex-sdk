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
import flash.text.TextLineMetrics;

import mx.core.ILayoutElement;
import mx.core.UIComponent;
import mx.core.UITextField;
import mx.core.mx_internal;
import mx.utils.ColorUtil;

import spark.components.ActionBar;
import spark.components.Group;
import spark.components.supportClasses.MobileTextField;
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
    
    public var hostComponent:ActionBar;
    
    public var navigationGroup:Group;
    
    public var titleGroup:Group;
    
    public var actionGroup:Group;
    
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
        hLayout.paddingLeft = hLayout.paddingRight = 25; 
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
        titleDisplay.percentWidth = 100;
        
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
        
        if (titleGroup && hostComponent.titleContent)
        {
            titleWidth = titleGroup.getPreferredBoundsWidth();
            titleHeight = titleGroup.getPreferredBoundsHeight();
        }
        else if (titleDisplay)
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
        
        // min height is 82 (80px content height, 1px borders on top and bottom)
        // Math.max.apply optimization used instead of "..." rest parameter
        measuredMinHeight = measuredHeight =
            Math.max.apply(null, [80, navigationGroup.getPreferredBoundsHeight(), 
                actionGroup.getPreferredBoundsHeight(),
                titleHeight]) + 2;
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
        var contentGroupsHeight:Number = unscaledHeight - 2;
        
        // FXG uses scale-9, 3 px drop shadow is drawn outside the bounds
        border.width = unscaledWidth;
        border.height = unscaledHeight + 3;
        
        // position groups, overlap of navigation and action groups is allowed
        // when overlap occurs, titleDisplay/titleGroup is not visible
        if (navigationGroup.numElements > 0
            && navigationGroup.includeInLayout)
        {
            navigationGroupWidth = navigationGroup.getPreferredBoundsWidth();
            titleCompX += navigationGroupWidth;
            
            navigationGroup.setLayoutBoundsSize(navigationGroupWidth, contentGroupsHeight);
            navigationGroup.setLayoutBoundsPosition(0, 1); // top border
        }
        
        if (actionGroup.numElements > 0 && actionGroup.includeInLayout)
        {
            // actionGroup x position can be negative
            actionGroupWidth = actionGroup.getPreferredBoundsWidth();
            actionGroupX = unscaledWidth - actionGroupWidth;
            
            actionGroup.setLayoutBoundsSize(actionGroupWidth, contentGroupsHeight);
            actionGroup.setLayoutBoundsPosition(actionGroupX, 1); // top border
        }
        
        titleCompWidth = unscaledWidth - navigationGroupWidth - actionGroupWidth;
        if (titleCompWidth <= 0)
        {
            titleDisplay.visible = false;
            titleGroup.visible = false;
        }
        else if (hostComponent.titleContent != null && titleGroup.includeInLayout)
        {
            titleDisplay.visible = false;
            titleGroup.visible = true;
            
            // use titleGroup for titleContent
            titleGroup.setLayoutBoundsSize(titleCompWidth, contentGroupsHeight);
            titleGroup.setLayoutBoundsPosition(titleCompX, 1); // top border
        }
        else
        {
            // use titleDisplay for title text label
            titleGroup.visible = false;
            
            // use titleLayout for paddingLeft and paddingRight
            var layoutObject:Object = hostComponent.titleLayout;
            var titlePaddingLeft:Number = (layoutObject.paddingLeft) ? Number(layoutObject.paddingLeft) : 0;
            var titlePaddingRight:Number = (layoutObject.paddingRight) ? Number(layoutObject.paddingRight) : 0;
            
            // implement padding by adjusting width and position
            titleCompX += titlePaddingLeft;
            titleCompWidth = titleCompWidth - (titlePaddingLeft + titlePaddingRight);
            
            // align titleDisplay to the absolute center
            if (hostComponent.getStyle("titleAlign") == "center")
            {
                titleCompWidth = titleDisplay.getExplicitOrMeasuredWidth();
                titleCompX = Math.floor((unscaledWidth - titleCompWidth)/ 2);
            }
                
            // shrink and/or move titleDisplay width if there is any overlap after padding
            if ((titleCompX < navigationGroupWidth)
                || ((titleCompX + titleCompWidth) > (actionGroupX - titlePaddingRight)))
            {
                titleCompX = navigationGroupWidth + titlePaddingLeft;
                titleCompWidth = actionGroupX - titleCompX - titlePaddingRight;
            }
            
            // vertical align center by subtracting the descent and top gutter
            titleHeight = titleDisplay.getExplicitOrMeasuredHeight();
            titleCompY = Math.floor((contentGroupsHeight - titleHeight + titleDisplay.descent) / 2);
            titleCompY -= (UITextField.TEXT_HEIGHT_PADDING / 2);
            
            titleDisplay.setLayoutBoundsSize(titleCompWidth, titleHeight);
            titleDisplay.setLayoutBoundsPosition(titleCompX, titleCompY);
            
            titleDisplay.visible = true;
        }
        
        // Draw the gradient background
        var chromeColor:uint = getStyle("chromeColor");
        var alpha:Number = getStyle("backgroundAlpha");
        var alphas:Array = [alpha, alpha, alpha];
        var colors:Array = [];
        
        // exclude top and bottom 1px borders
        matrix.createGradientBox(unscaledWidth, contentGroupsHeight, Math.PI / 2, 0, 0);
        
        colors[0] = ColorUtil.adjustBrightness2(chromeColor, 20);
        colors[1] = chromeColor;
        colors[2] = ColorUtil.adjustBrightness2(chromeColor, -20);
        
        graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
        graphics.drawRect(0, 1, unscaledWidth, contentGroupsHeight);
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

import spark.components.supportClasses.MobileTextField;
import spark.core.IDisplayText;

use namespace mx_internal;

/**
 *  @private
 *  Component that holds MobileTextFields to produce a drop shadow effect.
 */
class TitleDisplayComponent extends UIComponent implements IDisplayText
{
    private static var TEXT_WIDTH_PADDING:Number =
        UITextField.TEXT_WIDTH_PADDING + 1;
    
    private var titleDisplay:MobileTextField;
    private var titleDisplayShadow:MobileTextField;
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
        
        titleDisplay = MobileTextField(createInFontContext(MobileTextField));
        titleDisplay.styleProvider = this;
        titleDisplay.editable = false;
        titleDisplay.selectable = false;
        titleDisplay.multiline = false;
        titleDisplay.wordWrap = false;
        titleDisplay.addEventListener(FlexEvent.VALUE_COMMIT,
            titleDisplay_valueCommitHandler);
        
        titleDisplayShadow =
            MobileTextField(createInFontContext(MobileTextField));
        titleDisplayShadow.styleProvider = this;
        titleDisplayShadow.colorName = "textShadowColor";
        titleDisplayShadow.editable = false;
        titleDisplayShadow.selectable = false;
        titleDisplayShadow.multiline = false;
        titleDisplayShadow.wordWrap = false;
        
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
        titleDisplayShadow.y = titleDisplay.y + 1; // 90 degree drop shadow
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