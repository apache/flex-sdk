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
import spark.components.ButtonBarButton;
import spark.components.DataGroup;
import spark.skins.mobile.supportClasses.ButtonBarButtonClassFactory;
import spark.skins.mobile.supportClasses.TabbedViewNavigatorTabBarHorizontalLayout;

/**
 *  The default skin class for the Spark TabbedViewNavigator tabBar skin part.
 *  
 *  @see spark.components.TabbedViewNavigator#tabBar
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class TabbedViewNavigatorTabBarSkin extends ButtonBarSkin
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
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     * 
     */
    public function TabbedViewNavigatorTabBarSkin()
    {
        super();
    }
    
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
        if (!firstButton)
        {
            firstButton = new ButtonBarButtonClassFactory(ButtonBarButton);
            firstButton.skinClass = spark.skins.mobile.TabbedViewNavigatorTabBarFirstTabSkin;
        }
        
        if (!lastButton)
        {
            lastButton = new ButtonBarButtonClassFactory(ButtonBarButton);
            lastButton.skinClass = spark.skins.mobile.TabbedViewNavigatorTabBarLastTabSkin;
        }
        
        if (!middleButton)
        {
            middleButton = new ButtonBarButtonClassFactory(ButtonBarButton);
            middleButton.skinClass = spark.skins.mobile.TabbedViewNavigatorTabBarLastTabSkin;
        }
        
        if (!dataGroup)
        {
            // TabbedViewNavigatorButtonBarHorizontalLayout for even percent layout
            var tabLayout:TabbedViewNavigatorTabBarHorizontalLayout = 
                new TabbedViewNavigatorTabBarHorizontalLayout();
            tabLayout.useVirtualLayout = false;
            
            dataGroup = new DataGroup();
            dataGroup.layout = tabLayout;
            addChild(dataGroup);
        }
    }
    
    /**
     *  @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.drawBackground(unscaledWidth, unscaledHeight);

        // backgroundAlpha style is not supported by ButtonBar
        // TabbedViewNavigatorSkin sets a hard-coded value to support
        // overlayControls
        var backgroundAlphaValue:* = getStyle("backgroundAlpha");
        var backgroundAlpha:Number = (backgroundAlphaValue === undefined)
            ? 1 : getStyle("backgroundAlpha");
        
        graphics.beginFill(getStyle("chromeColor"), backgroundAlpha);
        graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
        graphics.endFill();
    }
}
}