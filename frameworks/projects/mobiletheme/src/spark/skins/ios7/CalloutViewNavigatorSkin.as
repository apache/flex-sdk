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

package spark.skins.ios7
{

import flash.display.Graphics;

import mx.core.DPIClassification;
import mx.core.mx_internal;

import spark.core.SpriteVisualElement;
import spark.skins.mobile.ViewNavigatorSkin;

use namespace mx_internal;

/**
 *  The ActionScript-based skin for view navigators inside a callout.
 *  This skin lays out the action bar and content
 *  group in a vertical fashion, where the action bar is on top.
 *  Unlike the default skin, overlay modes are not supported. 
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3 
 *  @productversion Flex 4.6
 */
public class CalloutViewNavigatorSkin extends ViewNavigatorSkin
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
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function CalloutViewNavigatorSkin()
    {
        super();
        
        switch (applicationDPI)
        {
			case DPIClassification.DPI_640:
			{
				contentCornerRadius = 28;
				gap = 48;
				break;
			}	
			case DPIClassification.DPI_480:
			{
				contentCornerRadius = 14;
				gap = 24;
				break;
			}	
            case DPIClassification.DPI_320:
            {
                contentCornerRadius = 10;
                gap = 16;
                break;
            }
			case DPIClassification.DPI_240:
			{
				contentCornerRadius = 7;
				gap = 12;
				break;
			}
			case DPIClassification.DPI_240:
			{
				contentCornerRadius = 4;
				gap = 6;
				break;
			}
            default:
            {
                // default DPI_160
                contentCornerRadius = 5;
                gap = 8;
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Layout variables
    //
    //--------------------------------------------------------------------------
    
    mx_internal var gap:Number;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    mx_internal var contentCornerRadius:Number;
    
    private var contentMask:SpriteVisualElement;
    
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
        super.createChildren();
        
        // mask the ViewNavigator contentGroup
        contentMask = new SpriteVisualElement();
        contentGroup.mask = contentMask;
        
    }
    
    /**
     *  @private 
     */ 
    override protected function measure():void
    {
        super.measure();
        
        measuredWidth = Math.max(actionBar.getPreferredBoundsWidth(), 
            contentGroup.getPreferredBoundsWidth());
        measuredHeight = actionBar.getPreferredBoundsHeight()
            + contentGroup.getPreferredBoundsHeight()
            + gap;
    }
    
    /**
     *  @private
     */ 
    override protected function commitCurrentState():void
    {
        super.commitCurrentState();
        
        // Force a layout pass on the components
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // omit super call
        
        var actionBarHeight:Number = 0;
        
        // The action bar is always placed at 0,0 and stretches the entire
        // width of the navigator
        if (actionBar.includeInLayout)
        {
            actionBarHeight = Math.min(actionBar.getPreferredBoundsHeight(), unscaledHeight);
            setElementSize(actionBar, unscaledWidth, actionBarHeight);
            setElementPosition(actionBar, 0, 0);
            actionBarHeight = actionBar.getLayoutBoundsHeight();
        }
        
        // If the hostComponent is in overlay mode, the contentGroup extends
        // the entire bounds of the navigator and the alpha for the action 
        // bar changes
        // If this changes, also update validateEstimatedSizesOfChild
        var contentGroupHeight:Number = 0;
        
        if (contentGroup.includeInLayout)
        {
            contentGroupHeight = Math.max(unscaledHeight - actionBarHeight - gap, 0);
            
            setElementSize(contentGroup, unscaledWidth, contentGroupHeight);
            setElementPosition(contentGroup, 0, actionBarHeight + gap);
            
        }
        
        setElementSize(contentMask, unscaledWidth, contentGroupHeight);
    }
    
    /**
     *  @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.drawBackground(unscaledWidth, unscaledHeight);
        
        // draw the contentBackgroundColor
        // the shading and highlight are drawn in FXG
        var contentEllipseSize:Number = contentCornerRadius * 2;
        var contentBackgroundAlpha:Number = getStyle("contentBackgroundAlpha");
        var contentWidth:Number = contentGroup.getLayoutBoundsWidth();
        var contentHeight:Number = contentGroup.getLayoutBoundsHeight();
        
        graphics.beginFill(getStyle("contentBackgroundColor"),
            contentBackgroundAlpha);
        graphics.endFill();
        
        if (contentMask)
        {
            // content mask in contentGroup coordinate space
            var maskGraphics:Graphics = contentMask.graphics;
            maskGraphics.clear();
            maskGraphics.beginFill(0, 1);
            maskGraphics.drawRoundRect(0, 0, contentWidth, contentHeight,
                contentEllipseSize, contentEllipseSize);
            maskGraphics.endFill();
        }
        
    }
}
}