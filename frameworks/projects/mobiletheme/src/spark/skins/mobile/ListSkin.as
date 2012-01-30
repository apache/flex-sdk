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
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.Sprite;

import mx.core.ClassFactory;
import mx.core.mx_internal;

import spark.components.DataGroup;
import spark.components.List;
import spark.components.Scroller;
import spark.layouts.HorizontalAlign;
import spark.layouts.VerticalLayout;
import spark.skins.mobile.supportClasses.MobileSkin;

use namespace mx_internal;

/**
 *  ActionScript-based skin for the List components in mobile applications. 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class ListSkin extends MobileSkin
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
    public function ListSkin()
    {
        super();
        
        minWidth = 112;
        blendMode = BlendMode.NORMAL;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    /** 
     *  @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
    public var hostComponent:List;

    
    //--------------------------------------------------------------------------
    //
    //  Skin parts 
    //
    //--------------------------------------------------------------------------
    /**
     *  Scroller skin part.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */ 
    public var scroller:Scroller;
    
    /**
     *  DataGroup skin part.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */ 
    public var dataGroup:DataGroup;
    
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    /**
     *  @private 
     */ 
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
            dataGroup.itemRenderer = new ClassFactory(spark.components.LabelItemRenderer);
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
    }
    
    /**
     *  @private 
     */
    override protected function measure():void
    {
        measuredWidth = scroller.getPreferredBoundsWidth();
        measuredHeight = scroller.getPreferredBoundsHeight();
    }
    
    /**
     *  @private 
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {   
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        var borderWidth:int = getStyle("borderVisible") ? 1 : 0;
                
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
        
        
        // Scroller
        scroller.minViewportInset = borderWidth;
        setElementSize(scroller, unscaledWidth, unscaledHeight);
        setElementPosition(scroller, 0, 0);
        
    }
}
}