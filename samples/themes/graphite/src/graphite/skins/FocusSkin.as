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

package graphite.skins
{

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.IBitmapDrawable;
import flash.events.Event;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.supportClasses.Skin;
import spark.components.supportClasses.SkinnableComponent;
import spark.core.DisplayObjectSharingMode;
import spark.core.IGraphicElement;

use namespace mx_internal;

/**
 *  Focus skins for Spark components.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class FocusSkin extends HighlightBitmapCaptureSkin
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
        
    // Number to multiply focusThickness by to determine the blur value
    private const BLUR_MULTIPLIER:Number = 2.5;
    
    // Number to multiply focusAlpha by to determine the filter alpha value
    private const ALPHA_MULTIPLIER:Number = 1.5454;
    
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
    private static var colorTransform:ColorTransform = new ColorTransform(
                1.01, 1.01, 1.01, 2);
    private static var glowFilter:GlowFilter = new GlowFilter(
                0x70B2EE, 0.85, 5, 5, 3, 1, false, true);
    private static var rect:Rectangle = new Rectangle();;
    private static var filterPt:Point = new Point();
                 
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     * Constructor.
     */
    public function FocusSkin()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    override protected function get borderWeight() : Number
    {
        return getStyle("focusThickness");
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {   
        super.updateDisplayList(unscaledWidth, unscaledHeight);
         
        blendMode = target.getStyle("focusBlendMode");
    }
    
    /**
     *  @private
     */
    override protected function processBitmap() : void
    {
        // Apply the glow filter
        rect.x = rect.y = 0;
        rect.width = bitmap.width;
        rect.height = bitmap.height;
        // If the focusObject has an errorString, use "errorColor" instead of "focusColor" 
        if (target.errorString != null && target.errorString != "") 
        {
            glowFilter.color = target.getStyle("errorColor");
        }
        else
        {
            glowFilter.color = target.getStyle("focusColor");
        }
        glowFilter.blurX = glowFilter.blurY = borderWeight * BLUR_MULTIPLIER;
        glowFilter.alpha = target.getStyle("focusAlpha") * ALPHA_MULTIPLIER;
        
        bitmap.bitmapData.applyFilter(bitmap.bitmapData, rect, filterPt, glowFilter);         
    }
}
}        
