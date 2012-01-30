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
import spark.primitives.Graphic;

public class ActionBarSkin extends SliderSkin
{
    public var hostComponent:ActionBar;
    
    public var backgroundFill:Sprite;
    public var navigationGroup:Group;
    public var titleGroup:Group;
    public var actionGroup:Group;
    public var titleDisplay:Label;
    private var highlight:SpriteVisualElement;
    
    public function ActionBarSkin()
    {
        super();
    }
    
    override protected function createChildren():void
    {
        backgroundFill = new Sprite();
        addChild(backgroundFill);
        
        highlight = new ActionBarHighlight();
        addChild(highlight);
        
        navigationGroup = new Group();
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.horizontalAlign = HorizontalAlign.LEFT;
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 0;
        hLayout.paddingLeft = hLayout.paddingTop = hLayout.paddingRight = hLayout.paddingBottom = 10; // TODO (jasonsj): 15 for 240dpi
        navigationGroup.layout = hLayout;
        addChild(navigationGroup);
        
        titleGroup = new Group();
        hLayout = new HorizontalLayout();
        hLayout.horizontalAlign = HorizontalAlign.LEFT;
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 0;
        hLayout.paddingLeft = hLayout.paddingTop = hLayout.paddingRight = hLayout.paddingBottom = 10; // TODO (jasonsj): 15 for 240dpi
        titleGroup.layout = hLayout;
        addChild(titleGroup);
        
        actionGroup = new Group();
        hLayout = new HorizontalLayout();
        hLayout.horizontalAlign = HorizontalAlign.RIGHT;
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 0;
        hLayout.paddingLeft = hLayout.paddingTop = hLayout.paddingRight = hLayout.paddingBottom = 10; // TODO (jasonsj): 15 for 240dpi
        actionGroup.layout = hLayout;
        addChild(actionGroup);
        
        titleDisplay = new Label();
		titleDisplay.maxDisplayedLines = 1;
		titleDisplay.percentWidth = 100;
        titleDisplay.setStyle("fontSize", "18"); // TODO (jasonsj): 27 for 240dpi
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
            Math.max(navigationGroup.getPreferredBoundsHeight(), 
                actionGroup.getPreferredBoundsHeight(),
                titleComponent.getPreferredBoundsHeight());
    }
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        highlight.setLayoutBoundsSize(unscaledWidth, unscaledHeight);
        highlight.setLayoutBoundsPosition(0, 0);
        
        var left:Number = 0;
        var right:Number = unscaledWidth;
        
        // position groups, overlap of navigation and action groups is allowed
        // when overlap occurs, title group is not visible (width = 0)
        if (navigationGroup.numElements > 0 && navigationGroup.includeInLayout)
        {
            left += navigationGroup.getPreferredBoundsWidth();
            navigationGroup.setLayoutBoundsSize(left, unscaledHeight);
        }
        
        if (actionGroup.numElements > 0 && actionGroup.includeInLayout)
        {
            var actionGroupWidth:Number = actionGroup.getPreferredBoundsWidth();
            right -= actionGroupWidth;
            actionGroup.setLayoutBoundsSize(actionGroupWidth, unscaledHeight);
            
            // actionGroup x position can be negative
            actionGroup.setLayoutBoundsPosition(right, 0);
        }
        
        var titleGroupWidth:Number = right - left;
        if (titleGroupWidth < 0)
            titleGroupWidth = 0;
        
        titleGroup.setLayoutBoundsSize(titleGroupWidth, unscaledHeight);
        titleGroup.setLayoutBoundsPosition(left, 0);
        
        // Draw background
        var g:Graphics = backgroundFill.graphics;
        g.clear();
        g.beginFill(getStyle("chromeColor"), getStyle("backgroundAlpha"));
        g.drawRect(0, 0, unscaledWidth, unscaledHeight);
        g.endFill();
    }
    
}
}