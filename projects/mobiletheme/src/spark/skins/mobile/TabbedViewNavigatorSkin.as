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
import mx.states.State;

import spark.components.ButtonBar;
import spark.components.Group;
import spark.components.TabbedViewNavigator;
import spark.components.supportClasses.ButtonBarBase;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.spark.ButtonBarSkin;

public class TabbedViewNavigatorSkin extends MobileSkin
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    public function TabbedViewNavigatorSkin()
    {
        super();
        
        states = [
            new State({name:"portrait"}),
            new State({name:"portraitAndOverlay"}),
            new State({name:"landscape"}),
            new State({name:"landscapeAndOverlay"})
        ];
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    public var hostComponent:TabbedViewNavigator;
    
    // Groups and UI Controls
    public var contentGroup:Group;
    public var tabBar:ButtonBarBase;
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function createChildren():void
    {
        contentGroup = new Group();
        contentGroup.id = "contentGroup";
        
        tabBar = new ButtonBar();
        tabBar.id = "tabBar";
        tabBar.requireSelection = true;
        tabBar.setStyle("skinClass", ButtonBarSkin);
        tabBar.height = 80;
            
        addChild(contentGroup);
        addChild(tabBar);
    }
    
    /**
     *  @private
     */
    override public function set currentState(value:String):void
    {
        if (super.currentState != value)
        {
            super.currentState = value;
            
            // Force a layout pass on the components
            invalidateSize();
            invalidateDisplayList();
        }
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
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        var tabBarHeight:Number; 
        
        if (tabBar.includeInLayout)
        {
            tabBarHeight = Math.min(tabBar.getPreferredBoundsHeight(), unscaledHeight);
            tabBar.setLayoutBoundsSize(unscaledWidth, tabBarHeight);
            tabBar.setLayoutBoundsPosition(0, 0);
            tabBarHeight = tabBar.getLayoutBoundsHeight(); 
        }
        
        if (currentState == "portraitAndOverlay" || currentState == "landscapeAndOverlay")
        {
            tabBar.alpha = .6;
            
            if (contentGroup.includeInLayout)
            {
                contentGroup.setLayoutBoundsSize(unscaledWidth, unscaledHeight);
                contentGroup.setLayoutBoundsPosition(0, 0);
            }
        }
        else
        {
            tabBar.alpha = 1.0;
            
            if (contentGroup.includeInLayout)
            {
                var contentGroupHeight:Number = Math.max(unscaledHeight - tabBarHeight, 0);
                
                contentGroup.setLayoutBoundsSize(unscaledWidth, contentGroupHeight);
                contentGroup.setLayoutBoundsPosition(0, tabBarHeight);
            }
        }
    }
}
}