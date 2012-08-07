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

package assets
{

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.IBitmapDrawable;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import spark.components.supportClasses.SkinnableComponent;
import mx.core.UIComponent;
import mx.core.mx_internal;
import flash.utils.Dictionary;

/**
 *  Focus skins for Fx components.
 */
public class MyFocusSkin extends UIComponent
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    // TODO: Make this a style property?
    private const FOCUS_THICKNESS:int = 10;    
    
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
    
    public function MyFocusSkin()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Bitmap capture of the focused component. This bitmap includes a glow
     *  filter that shows the focus glow.
     */
    private var bitmap:Bitmap;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // Grab a bitmap of the focused object
        var focusObject:Object = focusManager.getFocus();
        var bitmapData:BitmapData = new BitmapData(
                    focusObject.width + (FOCUS_THICKNESS * 2), 
                    focusObject.height + (FOCUS_THICKNESS * 2), true, 0);
        var m:Matrix = new Matrix();
        
        // If the focus object already has a focus skin, make sure it is hidden.
        if (focusObject is SkinnableComponent && focusObject.mx_internal::focusObj)
            focusObject.mx_internal::focusObj.visible = false;
       
        // Temporary solution for focus drawing on CheckBox and RadioButton components.
        // Hide the label before drawing the focus. 
        // TODO: Figure out a better solution.
        var hidlabelElement:Boolean = false;
        if ((weakIsCheck(focusObject, "mx.components::FxCheckBox") ||
             weakIsCheck(focusObject, "mx.components::FxRadioButton"))
             && focusObject.labelElement)
        {
            focusObject.labelElement.displayObject.visible = false;
            hidlabelElement = true;
        }
            
        m.tx = FOCUS_THICKNESS;
        m.ty = FOCUS_THICKNESS;
        bitmapData.draw(focusObject as IBitmapDrawable, m);
        
        // Show the focus skin, if needed.
        if (focusObject is SkinnableComponent && focusObject.mx_internal::focusObj)
            focusObject.mx_internal::focusObj.visible = true;
        
        // Show the label, if needed.
        if (hidlabelElement)
            focusObject.labelElement.displayObject.visible = true;
        
        // Special case for Scroller - fill the entire rect.
        // TODO: Figure out a better solution.
        if (weakIsCheck(focusObject, "mx.components::FxScroller"))
        {
            rect.x = rect.y = FOCUS_THICKNESS;
            rect.width = focusObject.width;
            rect.height = focusObject.height;
            bitmapData.fillRect(rect, 0xFFFFFFFF);
        }
        
        // Transform the color to remove the transparency. The GlowFilter has the "knockout" property
        // set to true, which removes this image from the final display, leaving only the outer glow.
        rect.x = rect.y = FOCUS_THICKNESS;
        rect.width = focusObject.width;
        rect.height = focusObject.height;
        bitmapData.colorTransform(rect, colorTransform);
        
        // Apply the glow filter
        rect.x = rect.y = 0;
        rect.width = bitmapData.width;
        rect.height = bitmapData.height;
        glowFilter.color = 0xFF0000;
        bitmapData.applyFilter(bitmapData, rect, filterPt, glowFilter); 
               
        if (!bitmap)
        {
            bitmap = new Bitmap();
            addChild(bitmap);
            bitmap.x = bitmap.y = -FOCUS_THICKNESS;
        }
        
        bitmap.bitmapData = bitmapData;
    }
    
    private static var classDefCache:Object = {};
    
    /**
     *  @private
     */
    private function weakIsCheck(obj:Object, className:String):Boolean
    {
        if (!(className in classDefCache))
        {            
            var classObj:Class = Class(systemManager.getDefinitionByName(className));
            
            classDefCache[className] = classObj;
        }
        
        if (!classDefCache[className])
            return false;
            
        return obj is classDefCache[className];
    }
}
}        
