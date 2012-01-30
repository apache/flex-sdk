////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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