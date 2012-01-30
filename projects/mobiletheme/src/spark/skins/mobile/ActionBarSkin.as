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
import flash.display.Graphics;
import flash.events.Event;
import flash.text.TextFormatAlign;

import mx.core.DeviceDensity;
import mx.core.mx_internal;
import mx.utils.ColorUtil;

import spark.components.ActionBar;
import spark.components.Group;
import spark.components.supportClasses.StyleableTextField;
import spark.core.SpriteVisualElement;
import spark.layouts.HorizontalAlign;
import spark.layouts.HorizontalLayout;
import spark.layouts.VerticalAlign;
import spark.skins.mobile.assets.ActionBarBackground;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile320.assets.ActionBarBackground;

use namespace mx_internal;

/**
 *  The default skin class for the Spark ActionBar component in mobile applications.  
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
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    mx_internal static const ACTIONBAR_CHROME_COLOR_RATIOS:Array = [0, 80];
    
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
     */
    public function ActionBarSkin()
    {
        super();
        
        useChromeColor = true;
        
        switch (authorDensity)
        {
            case DeviceDensity.PPI_320:
            {
                layoutBorderHeight = 2;
                layoutShadowHeight = 6;
                layoutContentGroupHeight = 86;
                layoutTitleGroupHorizontalPadding = 26;
                
                borderClass = spark.skins.mobile320.assets.ActionBarBackground;
                
                break;
            }
            case DeviceDensity.PPI_240:
            {
                layoutBorderHeight = 1;
                layoutShadowHeight = 3;
                layoutContentGroupHeight = 65;
                layoutTitleGroupHorizontalPadding = 20;
                
                borderClass = spark.skins.mobile.assets.ActionBarBackground;
                
                break;
            }
            default:
            {
                // default PPI160
                layoutBorderHeight = 1;
                layoutShadowHeight = 3;
                layoutContentGroupHeight = 43;
                layoutTitleGroupHorizontalPadding = 13;
                
                borderClass = spark.skins.mobile.assets.ActionBarBackground;
                
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Graphics variables
    //
    //--------------------------------------------------------------------------
    
    protected var borderClass:Class;
    
    //--------------------------------------------------------------------------
    //
    //  Layout variables
    //
    //--------------------------------------------------------------------------
    
    protected var layoutBorderHeight:uint;
    
    protected var layoutShadowHeight:uint;
    
    protected var layoutContentGroupHeight:uint;
    
    protected var layoutTitleGroupHorizontalPadding:uint;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /** 
     *  @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
    public var hostComponent:ActionBar;
    
    private var _navigationVisible:Boolean = false;
    
    private var _titleContentVisible:Boolean = false;
    
    private var _actionVisible:Boolean = false;
    
    private var border:SpriteVisualElement;
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts
    //
    //--------------------------------------------------------------------------
    
    public var navigationGroup:Group;
    
    public var titleGroup:Group;
    
    public var actionGroup:Group;
    
    /**
     *  Wraps a StyleableTextField in a UIComponent to be compatible with
     *  ViewTransition effects.
     */
    public var titleDisplay:TitleDisplayComponent;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function createChildren():void
    {
        border = new borderClass();
        addChild(border);
        
        navigationGroup = new Group();
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.horizontalAlign = HorizontalAlign.LEFT;
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 0;
        hLayout.paddingLeft = hLayout.paddingTop = hLayout.paddingRight = 
            hLayout.paddingBottom = 0;
        navigationGroup.layout = hLayout;
        navigationGroup.id = "navigationGroup";
        
        titleGroup = new Group();
        hLayout = new HorizontalLayout();
        hLayout.horizontalAlign = HorizontalAlign.LEFT;
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 0;
        hLayout.paddingLeft = hLayout.paddingRight = layoutTitleGroupHorizontalPadding; 
        hLayout.paddingTop = hLayout.paddingBottom = 0;
        titleGroup.layout = hLayout;
        titleGroup.id = "titleGroup";
        
        actionGroup = new Group();
        hLayout = new HorizontalLayout();
        hLayout.horizontalAlign = HorizontalAlign.RIGHT;
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 0;
        hLayout.paddingLeft = hLayout.paddingTop = hLayout.paddingRight = 
            hLayout.paddingBottom = 0;
        actionGroup.layout = hLayout;
        actionGroup.id = "actionGroup";
        
        titleDisplay = new TitleDisplayComponent();
        titleDisplay.id = "titleDisplay";
        
        addChild(navigationGroup);
        addChild(titleGroup);
        addChild(actionGroup);
        addChild(titleDisplay);
    }
    
    /**
     *  @private
     */
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
        
        // min height is contentGroupHeight, 2x border on top and bottom
        // Math.max.apply optimization used instead of "..." rest parameter
        measuredMinHeight = measuredHeight =
            Math.max(layoutContentGroupHeight,
                navigationGroup.getPreferredBoundsHeight(), 
                actionGroup.getPreferredBoundsHeight(),
                titleHeight)
            + (layoutBorderHeight * 2);
    }
    
    /**
     *  @private
     */
    override protected function commitCurrentState():void
    {
        super.commitCurrentState();
        
        _titleContentVisible = currentState.indexOf("titleContent") >= 0;
        _navigationVisible = currentState.indexOf("Navigation") >= 0;
        _actionVisible = currentState.indexOf("Action") >= 0;
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        var navigationGroupWidth:Number = 0;
        
        var titleCompX:Number = 0;
        var titleCompWidth:Number = 0;
        var titleHeight:Number = 0;
        var titleCompY:Number = 0;
        
        var actionGroupX:Number = unscaledWidth;
        var actionGroupWidth:Number = 0;
        
        // remove top and bottom borders from content group height
        var contentGroupsHeight:Number = unscaledHeight - (layoutBorderHeight * 2);
        
        // FXG uses scale-9, drop shadow is drawn outside the bounds
        setElementSize(border, unscaledWidth, unscaledHeight + layoutShadowHeight);
        
        // position groups, overlap of navigation and action groups is allowed
        // when overlap occurs, titleDisplay/titleGroup is not visible
        if (_navigationVisible)
        {
            navigationGroupWidth = navigationGroup.getPreferredBoundsWidth();
            titleCompX += navigationGroupWidth;
            
            setElementSize(navigationGroup, navigationGroupWidth, contentGroupsHeight);
            setElementPosition(navigationGroup, 0, layoutBorderHeight);
        }
        
        if (_actionVisible)
        {
            // actionGroup x position can be negative
            actionGroupWidth = actionGroup.getPreferredBoundsWidth();
            actionGroupX = unscaledWidth - actionGroupWidth;
            
            setElementSize(actionGroup, actionGroupWidth, contentGroupsHeight);
            setElementPosition(actionGroup, actionGroupX, layoutBorderHeight);
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
            setElementSize(titleGroup, titleCompWidth, contentGroupsHeight);
            setElementPosition(titleGroup, titleCompX, layoutBorderHeight);
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
            titleCompY = Math.round((contentGroupsHeight - titleHeight + titleDisplay.descent - StyleableTextField.TEXT_HEIGHT_PADDING) / 2);
            
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
            
            setElementSize(titleDisplay, titleCompWidth, titleHeight);
            setElementPosition(titleDisplay, titleCompX, titleCompY);
            
            titleDisplay.visible = true;
        }
        
        // draw chromeColor inside titleContent only
        super.updateDisplayList(unscaledWidth, unscaledHeight);
    }
    
    override protected function beginChromeColorFill(chromeColorGraphics:Graphics):void
    {
        var chromeColor:uint = getStyle("chromeColor");
        var backgroundAlphaValue:Number = getStyle("backgroundAlpha");
        var colors:Array = [];
        
        // apply alpha to border and chromeColor
        border.alpha = backgroundAlphaValue;
        var backgroundAlphas:Array = [backgroundAlphaValue, backgroundAlphaValue];
        
        // exclude top and bottom 1px borders
        matrix.createGradientBox(unscaledWidth, unscaledHeight - (layoutBorderHeight * 2), Math.PI / 2, 0, 0);
        
        colors[0] = ColorUtil.adjustBrightness2(chromeColor, 20);
        colors[1] = chromeColor;
        
        chromeColorGraphics.beginGradientFill(GradientType.LINEAR, colors, backgroundAlphas, ACTIONBAR_CHROME_COLOR_RATIOS, matrix);
    }
    
    override protected function drawChromeColor(chromeColorGraphics:Graphics, unscaledWidth:Number, unscaledHeight:Number):void
    {
        chromeColorGraphics.drawRect(0, layoutBorderHeight, unscaledWidth, unscaledHeight - (layoutBorderHeight * 2));
    }
    
}
}
import flash.events.Event;
import flash.geom.Point;
import flash.text.TextLineMetrics;

import mx.core.UIComponent;
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
    
    /**
     *  @private
     */
    override protected function createChildren():void
    {
        super.createChildren();
        
        titleDisplay = StyleableTextField(createInFontContext(StyleableTextField));
        titleDisplay.styleName = this;
        titleDisplay.editable = false;
        titleDisplay.selectable = false;
        titleDisplay.multiline = false;
        titleDisplay.wordWrap = false;
        titleDisplay.addEventListener(FlexEvent.VALUE_COMMIT,
            titleDisplay_valueCommitHandler);
        
        titleDisplayShadow =
            StyleableTextField(createInFontContext(StyleableTextField));
        titleDisplayShadow.styleName = this;
        titleDisplayShadow.colorName = "textShadowColor";
        titleDisplayShadow.editable = false;
        titleDisplayShadow.selectable = false;
        titleDisplayShadow.multiline = false;
        titleDisplayShadow.wordWrap = false;
        
        addChild(titleDisplayShadow);
        addChild(titleDisplay);
    }
    
    /**
     *  @private
     */
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
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        var textWidth:Number = 0;
        var textHeight:Number = 0;
        
        // reset text if it was truncated before.
        if (titleDisplay.isTruncated)
            titleDisplay.text = title;
        titleDisplay.commitStyles();
        
        if (title != "")
        {
            // FIXME (jasonsj): was previously textWidth + UITextField.TEXT_WIDTH_PADDING + 1;
            //                  +1 originates from MX Button without explaination
            var textSize:Point = titleDisplay.measuredTextSize;
            textWidth = textSize.x + 1;
            textHeight = textSize.y;
            descent = titleDisplay.getLineMetrics(0).descent;
        }
        else
        {
            // ignore text width...we just need textHeight, but we need to use 
            // measureText("Wj") to figure this out
            var lineMetrics:TextLineMetrics = measureText("Wj");
            textHeight = lineMetrics.height + StyleableTextField.TEXT_HEIGHT_PADDING;
            descent = lineMetrics.descent;
        }
        
        measuredWidth = textWidth;
        measuredHeight = textHeight;
    }
    
     /**
     *  @private
     */
   override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        titleDisplay.width = unscaledWidth;
        titleDisplay.height = unscaledHeight;
        
        // reset text if it was truncated before.
        if (titleDisplay.isTruncated)
            titleDisplay.text = title;
        titleDisplay.commitStyles();
        
        // now truncate the text
        titleDisplay.truncateToFit();
        
        titleDisplayShadow.commitStyles();
        titleDisplayShadow.y = titleDisplay.y + 1; // degree shadow down
        titleDisplayShadow.width = unscaledWidth;
        titleDisplayShadow.height = unscaledHeight;
        titleDisplayShadow.alpha = getStyle("textShadowAlpha");
        
        // if labelDisplay is truncated, then push it down here as well.
        // otherwise, it would have gotten pushed in the labelDisplay_valueCommitHandler()
        if (titleDisplay.isTruncated)
            titleDisplayShadow.text = titleDisplay.text;
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