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
import flash.text.TextFormatAlign;

import mx.core.DPIClassification;
import mx.core.mx_internal;
import mx.utils.ColorUtil;

import spark.components.ActionBar;
import spark.components.Group;
import spark.components.supportClasses.StyleableTextField;
import spark.core.SpriteVisualElement;
import spark.layouts.HorizontalAlign;
import spark.layouts.HorizontalLayout;
import spark.layouts.VerticalAlign;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile160.assets.ActionBarBackground;
import spark.skins.mobile240.assets.ActionBarBackground;
import spark.skins.mobile320.assets.ActionBarBackground;

use namespace mx_internal;

/**
 *  The default skin class for the Spark ActionBar component in mobile
 *  applications.
 *  
 *  @see spark.components.ActionBar
 *  @see spark.skins.mobile.TransparentNavigationButtonSkin
 *  @see spark.skins.mobile.BeveledBackButtonSkin
 *  @see spark.skins.mobile.TransparentActionButtonSkin
 *  @see spark.skins.mobile.BeveledActionButtonSkin
 *  
 *  @langversion 3.0
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
    
    /**
     *  @private
     */
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
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function ActionBarSkin()
    {
        super();
        
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                borderSize = 2;
                layoutShadowHeight = 6;
                layoutContentGroupHeight = 86;
                layoutTitleGroupHorizontalPadding = 26;
                
                borderClass = spark.skins.mobile320.assets.ActionBarBackground;
                
                break;
            }
            case DPIClassification.DPI_240:
            {
                borderSize = 1;
                layoutShadowHeight = 3;
                layoutContentGroupHeight = 65;
                layoutTitleGroupHorizontalPadding = 20;
                
                borderClass = spark.skins.mobile240.assets.ActionBarBackground;
                
                break;
            }
            default:
            {
                // default DPI_160
                borderSize = 1;
                layoutShadowHeight = 3;
                layoutContentGroupHeight = 43;
                layoutTitleGroupHorizontalPadding = 13;
                
                borderClass = spark.skins.mobile160.assets.ActionBarBackground;
                
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Graphics variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  FXG Class reference for the ActionBar background border graphic.
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var borderClass:Class;
    
    //--------------------------------------------------------------------------
    //
    //  Layout variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private var borderSize:uint;
    
    /**
     *  Height of shadow embedded in borderClass graphic.
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var layoutShadowHeight:uint;
    
    /**
     *  Default height for navigationGroup, titleGroup and actionGroup.
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var layoutContentGroupHeight:uint;
    
    /**
     *  Default horizontal padding for the titleGroup and titleDisplay.
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
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
    
    /**
     *  @private
     */
    private var _navigationVisible:Boolean = false;
    
    /**
     *  @private
     */
    private var _titleContentVisible:Boolean = false;
    
    /**
     *  @private
     */
    private var _actionVisible:Boolean = false;
    
    /**
     *  @private
     */
    private var border:SpriteVisualElement;
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @copy spark.components.ActionBar#navigationGroup
     */
    public var navigationGroup:Group;
    
    /**
     *  @copy spark.components.ActionBar#titleGroup
     */
    public var titleGroup:Group;
    
    /**
     *  @copy spark.components.ActionBar#actionGroup
     */
    public var actionGroup:Group;
    
    /**
     *  @copy spark.components.ActionBar#titleDisplay
     * 
     *  @private
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
        if (borderClass)
        {
            border = new borderClass();
            addChild(border);
        }
        
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
        
        // initialize titleAlign style (center is managed explicitly in layoutContents)
        var titleAlign:String = getStyle("titleAlign");
        titleAlign = (titleAlign == "center") ? TextFormatAlign.LEFT : titleAlign;
        titleDisplay.setStyle("textAlign", titleAlign);
        
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
        
        measuredWidth =
            getStyle("paddingLeft")
            + navigationGroup.getPreferredBoundsWidth()
            + titleWidth
            + actionGroup.getPreferredBoundsWidth()
            + getStyle("paddingRight");
        
        // measuredHeight is contentGroupHeight, 2x border on top and bottom
        measuredHeight =
            getStyle("paddingTop")
            + Math.max(layoutContentGroupHeight,
                navigationGroup.getPreferredBoundsHeight(), 
                actionGroup.getPreferredBoundsHeight(),
                titleHeight)
            + getStyle("paddingBottom");
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
    override public function styleChanged(styleProp:String):void
    {
        if (titleDisplay)
        {
            var allStyles:Boolean = !styleProp || styleProp == "styleName";
            
            if (allStyles || (styleProp == "titleAlign"))
            {
                var titleAlign:String = getStyle("titleAlign");
                
                if (titleAlign == "center")
                { 
                    // If the title align is set to center, the alignment is set to LEFT
                    // so that the skin can manually center the component in layoutContents
                    titleDisplay.setStyle("textAlign", TextFormatAlign.LEFT);
                }
                else
                {
                    titleDisplay.setStyle("textAlign", titleAlign);
                }
            }
        }
        
        super.styleChanged(styleProp);
    }
    
    /**
     *  @private
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        var navigationGroupWidth:Number = 0;
        
        var paddingLeft:Number   = getStyle("paddingLeft"); 
        var paddingRight:Number  = getStyle("paddingRight");
        var paddingTop:Number    = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");
        
        var titleCompX:Number = paddingLeft;
        var titleCompWidth:Number = 0;
        
        var actionGroupX:Number = unscaledWidth;
        var actionGroupWidth:Number = 0;
        
        // remove top and bottom padding from content group height
        var contentGroupsHeight:Number = Math.max(0, unscaledHeight - paddingTop - paddingBottom);
        
        if (border)
        {
            // FXG uses scale-9, drop shadow is drawn outside the bounds
            setElementSize(border, unscaledWidth, unscaledHeight + layoutShadowHeight);
        }
        
        // position groups, overlap of navigation and action groups is allowed
        // when overlap occurs, titleDisplay/titleGroup is not visible
        if (_navigationVisible)
        {
            navigationGroupWidth = navigationGroup.getPreferredBoundsWidth();
            titleCompX += navigationGroupWidth;
            
            setElementSize(navigationGroup, navigationGroupWidth, contentGroupsHeight);
            setElementPosition(navigationGroup, paddingLeft, paddingTop);
        }
        
        if (_actionVisible)
        {
            // actionGroup x position can be negative
            actionGroupWidth = actionGroup.getPreferredBoundsWidth();
            actionGroupX = unscaledWidth - actionGroupWidth - paddingRight;
            
            setElementSize(actionGroup, actionGroupWidth, contentGroupsHeight);
            setElementPosition(actionGroup, actionGroupX, paddingTop);
        }
        
        // titleGroup or titleDisplay is given remaining width after navigation
        // and action groups preferred widths
        titleCompWidth = unscaledWidth - navigationGroupWidth - actionGroupWidth
            - paddingLeft - paddingRight;
        
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
            setElementPosition(titleGroup, titleCompX, paddingTop);
        }
        else
        {
            // use titleDisplay for title text label
            titleGroup.visible = false;
            
            // use titleLayout for paddingLeft and paddingRight
            var layoutObject:Object = hostComponent.titleLayout;
            var titlePaddingLeft:Number = (layoutObject.paddingLeft) ? Number(layoutObject.paddingLeft) : 0;
            var titlePaddingRight:Number = (layoutObject.paddingRight) ? Number(layoutObject.paddingRight) : 0;
            
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
                // implement padding by adjusting width and position
                titleCompX += titlePaddingLeft;
                titleCompWidth = titleCompWidth - titlePaddingLeft - titlePaddingRight;
            }
            
            // check for negative width
            titleCompWidth = (titleCompWidth < 0) ? 0 : titleCompWidth;
            
            setElementSize(titleDisplay, titleCompWidth, contentGroupsHeight);
            setElementPosition(titleDisplay, titleCompX, paddingTop);
            
            titleDisplay.visible = true;
        }
    }
    
    /**
     *  @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.drawBackground(unscaledWidth, unscaledHeight);

        var chromeColor:uint = getStyle("chromeColor");
        var backgroundAlphaValue:Number = getStyle("backgroundAlpha");
        var colors:Array = [];
        
        // apply alpha to chromeColor fill only
        var backgroundAlphas:Array = [backgroundAlphaValue, backgroundAlphaValue];
        
        // exclude top and bottom 1px borders
        colorMatrix.createGradientBox(unscaledWidth, unscaledHeight - (borderSize * 2), Math.PI / 2, 0, 0);
        
        colors[0] = ColorUtil.adjustBrightness2(chromeColor, 20);
        colors[1] = chromeColor;
        
        graphics.beginGradientFill(GradientType.LINEAR, colors, backgroundAlphas, ACTIONBAR_CHROME_COLOR_RATIOS, colorMatrix);
        graphics.drawRect(0, borderSize, unscaledWidth, unscaledHeight - (borderSize * 2));
        graphics.endFill();
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
 *  Component that holds StyleableTextFields to produce a drop shadow effect.
 *  Combines label and shadow into a single component to allow transitions to
 *  target them both.
 */
class TitleDisplayComponent extends UIComponent implements IDisplayText
{
    private var titleDisplay:StyleableTextField;
    private var titleDisplayShadow:StyleableTextField;
    private var title:String;
    private var titleChanged:Boolean;
    
    public function TitleDisplayComponent()
    {
        super();
        title = "";
    }
    
    override public function get baselinePosition():Number
    {
        return titleDisplay.baselinePosition;
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
            titleDisplay.text = title;
            
            invalidateSize();
            invalidateDisplayList();
            
            titleChanged = false;
        }
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        // reset text if it was truncated before.
        if (titleDisplay.isTruncated)
            titleDisplay.text = title;
        
        measuredWidth = titleDisplay.getPreferredBoundsWidth();
        
        // tightTextHeight
        measuredHeight = titleDisplay.getPreferredBoundsHeight();
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        // reset text if it was truncated before.
        if (titleDisplay.isTruncated)
            titleDisplay.text = title;
        titleDisplay.commitStyles();
        
        // use preferred height, setLayoutBoundsSize will accommodate for tight
        // text adjustment
        var tightHeight:Number = titleDisplay.getPreferredBoundsHeight();
        var tightY:Number = (unscaledHeight - tightHeight) / 2;
        
        titleDisplay.setLayoutBoundsSize(unscaledWidth, tightHeight);
        titleDisplay.setLayoutBoundsPosition(0, (unscaledHeight - tightHeight) / 2);
        
        // now truncate the text
        titleDisplay.truncateToFit();
        
        titleDisplayShadow.commitStyles();
        titleDisplayShadow.setLayoutBoundsSize(unscaledWidth, tightHeight);
        titleDisplayShadow.setLayoutBoundsPosition(0, tightY + 1);
        
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
        return titleDisplay.isTruncated;
    }
}