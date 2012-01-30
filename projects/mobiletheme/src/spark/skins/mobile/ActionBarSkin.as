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
import flash.display.DisplayObject;
import flash.events.Event;
import flash.text.TextLineMetrics;

import mx.core.FlexGlobals;
import mx.core.ILayoutElement;
import mx.core.UIComponent;
import mx.core.UITextField;
import mx.core.mx_internal;
import mx.styles.ISimpleStyleClient;

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
    
    // FIXME (jasonsj): pending mobile styling spec
    private static const TITLE_PADDING:Number = 25;
    
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
        hLayout.verticalAlign = VerticalAlign.JUSTIFY;
        hLayout.gap = 0;
        hLayout.paddingLeft = hLayout.paddingTop = hLayout.paddingRight = 
            hLayout.paddingBottom = 0;
        navigationGroup.layout = hLayout;
        addChild(navigationGroup);
        
        titleGroup = new Group();
        hLayout = new HorizontalLayout();
        hLayout.horizontalAlign = HorizontalAlign.LEFT;
        hLayout.verticalAlign = VerticalAlign.JUSTIFY;
        hLayout.gap = 0;
        hLayout.paddingLeft = hLayout.paddingTop = hLayout.paddingRight = 
            hLayout.paddingBottom = 0;
        titleGroup.layout = hLayout;
        addChild(titleGroup);
        
        actionGroup = new Group();
        hLayout = new HorizontalLayout();
        hLayout.horizontalAlign = HorizontalAlign.RIGHT;
        hLayout.verticalAlign = VerticalAlign.JUSTIFY;
        hLayout.gap = 0;
        hLayout.paddingLeft = hLayout.paddingTop = hLayout.paddingRight = 
            hLayout.paddingBottom = 0;
        actionGroup.layout = hLayout;
        addChild(actionGroup);
        
        var titleDisplayComp:TitleDisplayComponent = new TitleDisplayComponent();
        titleDisplayComp.percentWidth = 100;
        titleDisplayComp.styleName = this;
        titleDisplay = titleDisplayComp;
        addChild(titleDisplayComp);
        
        initializeStyles();
    }
    
    protected function initializeStyles():void
    {
        // ID selectors to style contents of each group separately
        navigationGroup.id = "navigationGroup";
        titleGroup.id = "titleGroup";
        actionGroup.id = "actionGroup";
    }
    
    override protected function measure():void
    {
        var titleComponent:ILayoutElement = (titleGroup.numElements > 0) ? titleGroup : null;
        var titleWidth:Number = 0;
        var titleHeight:Number = 0;
        
        if (!titleComponent && (titleDisplay is ILayoutElement))
            titleComponent = ILayoutElement(titleDisplay);
        
        if (titleComponent)
        {
            titleWidth = titleComponent.getPreferredBoundsWidth();
            titleHeight = titleComponent.getPreferredBoundsHeight();
        }
        
        measuredMinWidth = measuredWidth =
            navigationGroup.getPreferredBoundsWidth()
            + actionGroup.getPreferredBoundsWidth()
            + titleWidth;
        
        measuredMinHeight = measuredHeight =
            Math.max(80, navigationGroup.getPreferredBoundsHeight(), 
                actionGroup.getPreferredBoundsHeight(),
                titleHeight);
    }
    
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        // FXG contains a top border, bottom border, and 3 px drop shadow
        border.width = unscaledWidth;
        border.height = unscaledHeight + 5;
        
        var navigationGroupWidth:Number = 0;
        
        var titleCompX:Number = 0;
        var titleCompWidth:Number = 0;
        
        var actionGroupX:Number = unscaledWidth;
        var actionGroupWidth:Number = 0;
        
        // position groups, overlap of navigation and action groups is allowed
        // when overlap occurs, titleDisplay/titleGroup is not visible
        if (navigationGroup.numElements > 0
            && navigationGroup.includeInLayout)
        {
            navigationGroupWidth = navigationGroup.getPreferredBoundsWidth();
            titleCompX += navigationGroupWidth;
            navigationGroup.setLayoutBoundsSize(titleCompX, unscaledHeight);
            navigationGroup.setLayoutBoundsPosition(0, 1); // top border
        }
        
        if (actionGroup.numElements > 0 && actionGroup.includeInLayout)
        {
            actionGroupWidth = actionGroup.getPreferredBoundsWidth();
            actionGroupX = unscaledWidth - actionGroupWidth;
            actionGroup.setLayoutBoundsSize(actionGroupWidth, unscaledHeight);
            
            // actionGroup x position can be negative
            actionGroup.setLayoutBoundsPosition(actionGroupX, 1); // top border
        }
        
        titleCompWidth = unscaledWidth - navigationGroupWidth - actionGroupWidth;
        if (titleCompWidth <= 0)
        {
            titleDisplay.visible = false;
            titleGroup.visible = false;
        }
        else if (titleGroup.getMXMLContent() != null && titleGroup.includeInLayout)
        {
            titleGroup.setLayoutBoundsSize(titleCompWidth, unscaledHeight);
            titleGroup.setLayoutBoundsPosition(titleCompX, 1);
            
            titleDisplay.visible = false;
            titleGroup.visible = true;
        }
        else
        {
            // FIXME (jasonsj): pending mobile styling spec
            // paddingLeft
            titleCompX = titleCompX + TITLE_PADDING;
            
            // FIXME (jasonsj): pending mobile styling spec
            // paddingRight
            titleCompWidth -= TITLE_PADDING * 2;
            
            if (hostComponent.getStyle("titleAlign") == "center")
            {
                // horizontalAlign=center
                titleCompWidth = titleDisplay.getExplicitOrMeasuredWidth();
                titleCompX = Math.floor((unscaledWidth / 2) - (titleCompWidth / 2));
            }
                
            // hide titleDisplay if there is any overlap after padding
            if ((titleCompX < navigationGroupWidth)
                || ((titleCompX + titleCompWidth) > actionGroupX))
            {
                titleDisplay.visible = false;
                titleGroup.visible = false;
            }
            else
            {
                // verticalAlign=center
                var titleHeight:Number = titleDisplay.getExplicitOrMeasuredHeight();
                var titleCompY:Number = Math.floor((unscaledHeight / 2) - (titleHeight / 2));
                
                titleDisplay.setLayoutBoundsSize(titleCompWidth, titleHeight);
                titleDisplay.setLayoutBoundsPosition(titleCompX, titleCompY + 1); // +1 FXG border
                
                titleDisplay.visible = true;
                titleGroup.visible = false;
            }
        }
        
        // Draw background
        graphics.clear();
        graphics.beginFill(getStyle("chromeColor"),
            getStyle("backgroundAlpha"));
        graphics.drawRect(0, 1, unscaledWidth, unscaledHeight);
        graphics.endFill();
    }
}
}
import flash.events.Event;
import flash.text.TextFormatAlign;
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
    
    public function TitleDisplayComponent()
    {
        super();
        title = "";
    }
    
    override protected function createChildren():void
    {
        super.createChildren();
        
        // FIXME (jasonsj): pending mobile styling spec:
        //                  drop shadow style
        //                  textAlign
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
        
        measuredWidth = textWidth;
        measuredHeight = textHeight;
    }
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        var textHeight:Number = 0;
        var lineMetrics:TextLineMetrics;
        
        if (title != "")
            lineMetrics = measureText(title);
        else
            lineMetrics = measureText("Wj");
        
        textHeight = lineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;
        
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