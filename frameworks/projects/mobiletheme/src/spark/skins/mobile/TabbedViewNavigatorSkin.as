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
import spark.components.ButtonBar;
import spark.components.Group;
import spark.components.TabbedViewNavigator;
import spark.components.supportClasses.ButtonBarBase;
import spark.skins.mobile.supportClasses.MobileSkin;

/**
 *  The ActionScript-based skin used for TabbedViewNavigator components.
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 * 
 */
public class TabbedViewNavigatorSkin extends MobileSkin
{
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
     * 
     */
    public function TabbedViewNavigatorSkin()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    /** 
     *  @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
    public var hostComponent:TabbedViewNavigator;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @copy spark.components.SkinnableContainer#contentGroup
     */
    public var contentGroup:Group;
    
    /**
     *  @copy spark.components.TabbedViewNavigator#tabBar
     */
    public var tabBar:ButtonBarBase;
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    private var _isOverlay:Boolean;
    
    /**
     *  @private
     */
    override protected function createChildren():void
    {
        if (!contentGroup)
        {
            contentGroup = new Group();
            contentGroup.id = "contentGroup";
            addChild(contentGroup);
        }
        
        if (!tabBar)
        {
            tabBar = new ButtonBar();
            tabBar.id = "tabBar";
            tabBar.requireSelection = true;
            addChild(tabBar);
        }
    }
    
    /**
     *  @private
     */
    override protected function commitCurrentState():void
    {
        super.commitCurrentState();
        
        _isOverlay = (currentState.indexOf("Overlay") >= 1);
        
        // Force a layout pass on the components
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        measuredWidth = Math.max(tabBar.getPreferredBoundsWidth(), 
            contentGroup.getPreferredBoundsWidth());
        
        if (currentState == "portraitAndOverlay" || currentState == "landscapeAndOverlay")
        {
            measuredHeight = Math.max(tabBar.getPreferredBoundsHeight(), 
                contentGroup.getPreferredBoundsHeight());
        }
        else
        {
            measuredHeight = tabBar.getPreferredBoundsHeight() + 
                contentGroup.getPreferredBoundsHeight();
        }
    }
    
    /**
     *  @private
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        var tabBarHeight:Number = 0; 
        
        if (tabBar.includeInLayout)
        {
            tabBarHeight = Math.min(tabBar.getPreferredBoundsHeight(), unscaledHeight);
            tabBar.setLayoutBoundsSize(unscaledWidth, tabBarHeight);
            tabBar.setLayoutBoundsPosition(0, unscaledHeight - tabBarHeight);
            tabBarHeight = tabBar.getLayoutBoundsHeight(); 
            
            // backgroundAlpha is not a declared style on ButtonBar
            // TabbedViewNavigatorButtonBarSkin implements for overlay support
            var backgroundAlpha:Number = (_isOverlay) ? 0.75 : 1;
            tabBar.setStyle("backgroundAlpha", backgroundAlpha);
        }
        
        if (contentGroup.includeInLayout)
        {
            var contentGroupHeight:Number = (_isOverlay) ? unscaledHeight : Math.max(unscaledHeight - tabBarHeight, 0);
            contentGroup.setLayoutBoundsSize(unscaledWidth, contentGroupHeight);
            contentGroup.setLayoutBoundsPosition(0, 0);
        }
    }
}
}