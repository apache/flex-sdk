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
package spark.skins
{
import spark.components.ButtonBarButton;
import spark.components.DataGroup;
import spark.layouts.HorizontalLayout;
import spark.layouts.VerticalAlign;
import spark.skins.mobile.ButtonBarSkin;
import spark.skins.mobile.supportClasses.ButtonBarButtonClassFactory;

public class MobileGridHeaderButtonBarSkin extends ButtonBarSkin
{

    public function MobileGridHeaderButtonBarSkin()
    {
        super();
    }

    override protected function createChildren():void
    {
        if (!firstButton)
        {
            firstButton = new ButtonBarButtonClassFactory(ButtonBarButton);
            ButtonBarButtonClassFactory(firstButton).skinClass = MobileGridHeaderFirstButtonSkin;
        }

        if (!lastButton)
        {
            lastButton = new ButtonBarButtonClassFactory(ButtonBarButton);
            ButtonBarButtonClassFactory(lastButton).skinClass = MobileGridHeaderButtonSkin;
        }

        if (!middleButton)
        {
            middleButton = new ButtonBarButtonClassFactory(ButtonBarButton);
            ButtonBarButtonClassFactory(middleButton).skinClass = MobileGridHeaderButtonSkin;
        }

        // create the data group to house the buttons
        if (!dataGroup)
        {
            dataGroup = new DataGroup();
            var hLayout:HorizontalLayout = new HorizontalLayout();
            hLayout.gap = 0;
            hLayout.verticalAlign = VerticalAlign.CONTENT_JUSTIFY;
            hLayout.useVirtualLayout = false;

            dataGroup.layout = hLayout;
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
