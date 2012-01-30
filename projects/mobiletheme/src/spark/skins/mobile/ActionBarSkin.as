package spark.skins.mobile
{
import flash.display.Graphics;
import flash.display.Sprite;

import spark.components.ActionBar;
import spark.components.Group;
import spark.components.Label;
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
    private var highlight:Sprite;
    private var border:Sprite;
    
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
        
        border = new ActionBarBorder();
        addChild(border);
        
        navigationGroup = new Group();
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.horizontalAlign = HorizontalAlign.LEFT;
        hLayout.verticalAlign = VerticalAlign.CONTENT_JUSTIFY;
        hLayout.gap = 0;
        navigationGroup.layout = hLayout;
        addChild(navigationGroup);
        
        titleGroup = new Group();
        hLayout = new HorizontalLayout();
        hLayout.horizontalAlign = HorizontalAlign.LEFT;
        hLayout.verticalAlign = VerticalAlign.CONTENT_JUSTIFY;
        hLayout.gap = 0;
        hLayout.paddingLeft = 10;
        titleGroup.layout = hLayout;
        titleGroup.clipAndEnableScrolling = true;
        addChild(titleGroup);
        
        actionGroup = new Group();
        hLayout = new HorizontalLayout();
        hLayout.horizontalAlign = HorizontalAlign.RIGHT;
        hLayout.verticalAlign = VerticalAlign.CONTENT_JUSTIFY;
        hLayout.gap = 0;
        actionGroup.layout = hLayout;
        addChild(actionGroup);
        
        titleDisplay = new Label();
        titleDisplay.setStyle("fontSize", "18");
        titleDisplay.setStyle("verticalAlign", "middle");
        titleDisplay.setStyle("color", "0xFFFFFF");
    }
    
    override protected function measure():void
    {
        measuredHeight = Math.max(Math.max(navigationGroup.getExplicitOrMeasuredHeight(), 
            titleGroup.getExplicitOrMeasuredHeight()),
            actionGroup.getExplicitOrMeasuredHeight());
    }
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        border.width = unscaledWidth;
        border.height = unscaledHeight;
        
        highlight.width = unscaledWidth;
        highlight.height = unscaledHeight;
        
        var left:Number = 0;
        var right:Number = unscaledWidth;
        
        // Position groups
        if (navigationGroup.includeInLayout)
        {
            left += navigationGroup.measuredWidth;
            navigationGroup.setLayoutBoundsSize(left, unscaledHeight);
        }
        
        if (actionGroup.includeInLayout)
        {
            right -= actionGroup.measuredWidth;
            actionGroup.setLayoutBoundsPosition(right, 0);
            actionGroup.setLayoutBoundsSize(unscaledWidth - right, unscaledHeight);
        }
        
        titleGroup.setLayoutBoundsPosition(left, 0);
        titleGroup.setLayoutBoundsSize(right - left, unscaledHeight);
        
        // Draw background
        var g:Graphics = backgroundFill.graphics;
        g.clear();
        g.beginFill(getStyle("chromeColor"), getStyle("backgroundAlpha"));
        g.drawRect(0, 0, unscaledWidth, unscaledHeight);
        g.endFill();
    }
    
}
}