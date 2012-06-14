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
import flash.display.IBitmapDrawable;
import flash.events.Event;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  The ErrorSkin class defines the error skin for Spark components.
 *  Flex displays the error skin when a validation error occurs.
 *
 *  @see mx.validators.Validator
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ErrorSkin extends HighlightBitmapCaptureSkin
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
     
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
    private static var glowFilter:GlowFilter = new GlowFilter(
                0xFF0000, 0.85, 2, 2, 3, 1, false, true);
    private static var rect:Rectangle = new Rectangle();;
    private static var filterPt:Point = new Point();
                 
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
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function ErrorSkin()
    {
        super();
        
        mouseEnabled = false;
        mouseChildren = false;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function processBitmap() : void
    {
        // Apply the glow filter
        rect.x = rect.y = 0;
        rect.width = bitmap.bitmapData.width;
        rect.height = bitmap.bitmapData.height;
        glowFilter.color = target.getStyle("errorColor");
        bitmap.bitmapData.applyFilter(bitmap.bitmapData, rect, filterPt, glowFilter);        
    }
    
    /**
     * @inheritDoc
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // Early exit if we don't have a target object
        if (!target)
            return;
        
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        // Set the size of the bitmap to be the size of the component. This has the effect
        // of overlaying the error skin on the border of the component.
        bitmap.x = bitmap.y = 0;
        bitmap.width = target.width;
        bitmap.height = target.height;
    }
}
}        
