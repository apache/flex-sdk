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
import mx.core.ClassFactory;
import mx.core.DPIClassification;
import mx.core.mx_internal;

import spark.components.DataGroup;
import spark.components.Scroller;
import spark.components.SpinnerList;
import spark.components.SpinnerListItemRenderer;
import spark.layouts.VerticalSpinnerLayout;
import spark.skins.mobile.supportClasses.MobileSkin;

use namespace mx_internal;

/**
 *  ActionScript-based skin for the SpinnerList in mobile applications. 
 * 
 *  @see spark.components.SpinnerList
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
public class SpinnerListSkin extends MobileSkin
{
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function SpinnerListSkin()
    {
        super();
        
        switch (applicationDPI)
        {
			case DPIClassification.DPI_640:
			case DPIClassification.DPI_480:
			case DPIClassification.DPI_320:
            {
                borderThickness = 2;
                break;
            }
            default:
            {
                borderThickness = 1;
            }   
        }
        
        minWidth = 16;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts 
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Scroller skin part.
     *
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public var scroller:Scroller;
    
    /**
     *  DataGroup skin part.
     *
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public var dataGroup:DataGroup;
    
    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------
    /** 
     *  @copy spark.skins.spark.ApplicationSkin#hostComponent
     *
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public var hostComponent:SpinnerList;
    
    /**
     *  Pixel size of the border.
     *
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    protected var borderThickness:int;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods 
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
        super.createChildren();
        
        if (!dataGroup)
        {
            // Create data group layout
            var layout:VerticalSpinnerLayout = new VerticalSpinnerLayout();
            layout.requestedRowCount = 5;
            
            // Create data group
            dataGroup = new DataGroup();
            dataGroup.id = "dataGroup";
            dataGroup.layout = layout;
            dataGroup.itemRenderer = new ClassFactory(spark.components.SpinnerListItemRenderer);
        }
        if (!scroller)
        {
            // Create scroller
            scroller = new Scroller();
            scroller.id = "scroller";
            scroller.hasFocusableChildren = false;
            scroller.ensureElementIsVisibleForSoftKeyboard = false;
            
            // Only support vertical scrolling
            scroller.setStyle("verticalScrollPolicy","on");
            scroller.setStyle("horizontalScrollPolicy", "off");
            scroller.setStyle("skinClass", spark.skins.mobile.SpinnerListScrollerSkin);
                            
            addChild(scroller);
        }
        
        // Associate scroller with data group
        if (!scroller.viewport)
            scroller.viewport = dataGroup;  
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        measuredWidth = scroller.getPreferredBoundsWidth() + borderThickness * 2;
        measuredHeight = scroller.getPreferredBoundsHeight();
    }
    
    /**
     *  @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        graphics.clear();
        
        super.drawBackground(unscaledWidth, unscaledHeight);
        
        // Drawing the left and right borders
        graphics.beginFill(0xB3B3B3);
        graphics.drawRect(0,0, borderThickness, unscaledHeight);
        graphics.endFill();
        
        graphics.beginFill(0xFFFFFF);
        graphics.drawRect(unscaledWidth - borderThickness, 0, borderThickness, unscaledHeight);
        graphics.endFill();
    }
    
    /**
     *  @private
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {   
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        // Scroller
        setElementSize(scroller, unscaledWidth - borderThickness * 2, unscaledHeight);
        setElementPosition(scroller, borderThickness, 0);
    }
    
    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        // Reinitialize the typical element so it picks up the latest styles
        // Font styles might impact the size of the SpinnerList
        if (styleProp != "color" && styleProp != "accentColor")
        {
            if (dataGroup)
                dataGroup.invalidateTypicalItemRenderer();
        }
        
        super.styleChanged(styleProp);
    }
}
}