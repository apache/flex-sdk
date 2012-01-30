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
import flash.display.Graphics;
import flash.display.Sprite;

import mx.core.UIComponent;

import spark.components.ActionBar;
import spark.components.Group;
import spark.components.Label;
import spark.core.SpriteVisualElement;
import spark.layouts.HorizontalAlign;
import spark.layouts.HorizontalLayout;
import spark.layouts.VerticalAlign;
import spark.skins.mobile.assets.ActionBarBackground;
import spark.skins.mobile.supportClasses.MobileSkin;

/**
 *  FIXME (jasonsj)
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class ActionBarSkin extends MobileSkin
{
    public var hostComponent:ActionBar;
    
    public var navigationGroup:Group;
    public var titleGroup:Group;
    public var actionGroup:Group;
    public var titleDisplay:Label;
    private var border:SpriteVisualElement;
    
    public function ActionBarSkin()
    {
        super();
    }
    
    override protected function createChildren():void
    {
        border = new ActionBarBackground();
        addChild(border);
        
        navigationGroup = new Group();
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.horizontalAlign = HorizontalAlign.LEFT;
        hLayout.verticalAlign = VerticalAlign.JUSTIFY;
        hLayout.gap = 0;
        hLayout.paddingLeft = hLayout.paddingTop = hLayout.paddingRight = hLayout.paddingBottom = 0;
        navigationGroup.layout = hLayout;
        addChild(navigationGroup);
        
        titleGroup = new Group();
        hLayout = new HorizontalLayout();
        hLayout.horizontalAlign = HorizontalAlign.LEFT;
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 0;
        hLayout.paddingLeft = hLayout.paddingRight = 15;
        titleGroup.layout = hLayout;
        addChild(titleGroup);
        
        actionGroup = new Group();
        hLayout = new HorizontalLayout();
        hLayout.horizontalAlign = HorizontalAlign.RIGHT;
        hLayout.verticalAlign = VerticalAlign.JUSTIFY;
        hLayout.gap = 0;
        hLayout.paddingLeft = hLayout.paddingTop = hLayout.paddingRight = hLayout.paddingBottom = 0;
        actionGroup.layout = hLayout;
        addChild(actionGroup);
        
        // ID selectors to style contents of each group separately
        navigationGroup.id = "navigationGroup";
        titleGroup.id = "titleGroup";
        actionGroup.id = "actionGroup";
        
        // FIXME (jasonsj): drop shadow on text, MobileTextField
        titleDisplay = new Label();
        titleDisplay.maxDisplayedLines = 1;
        titleDisplay.percentWidth = 100;
        titleDisplay.setStyle("fontSize", "32");
        titleDisplay.setStyle("verticalAlign", "middle");
        titleDisplay.setStyle("color", "0xFFFFFF");
        titleDisplay.setStyle("fontWeight", "bold");
    }
    
    override protected function measure():void
    {
        var titleComponent:UIComponent = (titleGroup.numElements > 0) ? titleGroup : titleDisplay;
        measuredMinWidth = measuredWidth =
            navigationGroup.getPreferredBoundsWidth()
            + titleComponent.getPreferredBoundsWidth()
            + actionGroup.getPreferredBoundsWidth();
        
        measuredMinHeight = measuredHeight =
            Math.max(80, navigationGroup.getPreferredBoundsHeight(), 
                actionGroup.getPreferredBoundsHeight(),
                titleComponent.getPreferredBoundsHeight());
    }
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        border.width = unscaledWidth;
        border.height = unscaledHeight + 5; // +5 for FXG drop shadow
        
        var left:Number = 0;
        var right:Number = unscaledWidth;
        
        // FIXME (jasonsj): highlight border right/left on navigation/action groups
        
        // position groups, overlap of navigation and action groups is allowed
        // when overlap occurs, title group is not visible (width = 0)
        if (navigationGroup.numElements > 0 && navigationGroup.includeInLayout)
        {
            left += navigationGroup.getPreferredBoundsWidth();
            navigationGroup.setLayoutBoundsSize(left, unscaledHeight);
            navigationGroup.setLayoutBoundsPosition(0, 1);
        }
        
        if (actionGroup.numElements > 0 && actionGroup.includeInLayout)
        {
            var actionGroupWidth:Number = actionGroup.getPreferredBoundsWidth();
            right -= actionGroupWidth;
            actionGroup.setLayoutBoundsSize(actionGroupWidth, unscaledHeight);
            
            // actionGroup x position can be negative
            actionGroup.setLayoutBoundsPosition(right, 1);
        }
        
        var titleGroupWidth:Number = right - left;
        if (titleGroupWidth < 0)
            titleGroupWidth = 0;
        
        titleGroup.setLayoutBoundsSize(titleGroupWidth, unscaledHeight);
        titleGroup.setLayoutBoundsPosition(left, 1);
        
        // Draw background
        graphics.clear();
        graphics.beginFill(getStyle("chromeColor"), getStyle("backgroundAlpha"));
        graphics.drawRect(0, 1, unscaledWidth, unscaledHeight);
        graphics.endFill();
    }
    
}
}