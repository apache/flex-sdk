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
import flash.display.BlendMode;

import mx.core.BitmapAsset;
import mx.core.ClassFactory;
import mx.core.DPIClassification;
import mx.core.mx_internal;

import spark.components.DataGroup;
import spark.components.LabelItemRenderer;
import spark.components.MobileGrid;
import spark.components.Scroller;
import spark.components.supportClasses.MobileGridHeader;
import spark.layouts.HorizontalAlign;
import spark.layouts.VerticalLayout;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.utils.MultiDPIBitmapSource;

use namespace mx_internal;

public class MobileGridSkin extends MobileSkin
{

    [Embed(source="../../../assets/images/mobile320/dg_header_shadow.png")]
    private var headerShadowCls320:Class;

    [Embed(source="../../../assets/images/mobile160/dg_header_shadow.png")]
    private var headerShadowCls160:Class;

    public var hostComponent:MobileGrid;
    // skin parts
    public var headerGroup:MobileGridHeader;
    public var scroller:Scroller;
    public var dataGroup:DataGroup;
    private var headerShadowCls:Class;
    private var headerShadow:BitmapAsset;


    public function MobileGridSkin()
    {
        super();
        minWidth = 112;
        blendMode = BlendMode.NORMAL;
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            case DPIClassification.DPI_480:
                minWidth = 200;
                break;
            case DPIClassification.DPI_160:
            case DPIClassification.DPI_240:
            default:
                minWidth = 100;
                break;
        }
        var headerShadowSrc:MultiDPIBitmapSource = new MultiDPIBitmapSource();
        headerShadowSrc.source320dpi = headerShadowCls320;
        headerShadowSrc.source160dpi = headerShadowCls160;
        headerShadowCls = Class(headerShadowSrc.getMultiSource());
    }

    override protected function commitCurrentState():void
    {
        super.commitCurrentState();
        alpha = currentState.indexOf("disabled") == -1 ? 1 : 0.5;
    }


    /**
     *  @private
     */
    override protected function createChildren():void
    {

        if (!dataGroup)
        {
            // Create data group layout
            var layout:VerticalLayout = new VerticalLayout();
            layout.requestedMinRowCount = 5;
            layout.horizontalAlign = HorizontalAlign.JUSTIFY;
            layout.gap = 0;

            // Create data group
            dataGroup = new DataGroup();
            dataGroup.layout = layout;
            dataGroup.itemRenderer = new ClassFactory(LabelItemRenderer);
        }
        if (!scroller)
        {
            // Create scroller
            scroller = new Scroller();
            scroller.minViewportInset = 1;
            scroller.hasFocusableChildren = false;
            scroller.ensureElementIsVisibleForSoftKeyboard = false;
            addChild(scroller);
        }

        // Associate scroller with data group
        if (!scroller.viewport)
        {
            scroller.viewport = dataGroup;
        }

        headerShadow = new headerShadowCls();
        addChild(headerShadow);

        /* add after, for the drop shadow*/

        headerGroup = new MobileGridHeader();
        headerGroup.id = "hg";
        addChild(headerGroup);
    }

    /**
     *  @private
     */
    override protected function measure():void
    {
        measuredWidth = scroller.getPreferredBoundsWidth();
        measuredHeight = scroller.getPreferredBoundsHeight() + headerGroup.getPreferredBoundsHeight();
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        var borderWidth:int = getStyle("borderVisible") ? 1 : 0;
        var headerHeight:Number = headerGroup.getPreferredBoundsHeight();

        // Background
        graphics.beginFill(getStyle("contentBackgroundColor"), getStyle("contentBackgroundAlpha"));
        graphics.drawRect(borderWidth, borderWidth, unscaledWidth - 2 * borderWidth, unscaledHeight - 2 * borderWidth);
        graphics.endFill();

        // Border
        if (getStyle("borderVisible"))
        {
            graphics.lineStyle(1, getStyle("borderColor"), getStyle("borderAlpha"), true);
            graphics.drawRect(0, 0, unscaledWidth - 1, unscaledHeight - 1);
        }

        // Header
        setElementSize(headerGroup, unscaledWidth, headerHeight);
        setElementPosition(headerGroup, 0, 0);

        //Shadow
        setElementSize(headerShadow, unscaledWidth, headerShadow.height);
        setElementPosition(headerShadow, 0, headerHeight);
        // Scroller
        scroller.minViewportInset = borderWidth;
        setElementSize(scroller, unscaledWidth, unscaledHeight - headerHeight);
        setElementPosition(scroller, 0, headerHeight);
    }
}
}
