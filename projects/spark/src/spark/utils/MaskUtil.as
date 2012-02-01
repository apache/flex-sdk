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

package spark.utils
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.filters.ShaderFilter;

import mx.core.UIComponent;
import mx.core.UIComponentGlobals;
import mx.core.mx_internal;
import mx.graphics.shaderClasses.LuminosityMaskShader;
import mx.graphics.shaderClasses.LuminosityShader;

import spark.core.MaskType;

use namespace mx_internal;

[ExcludeClass]

/**
 *  This class provides mask-related utility functions 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class MaskUtil
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Apply the luminosity settings to the mask.
     */    
       mx_internal static function applyLuminositySettings(
                        mask:DisplayObject, maskType:String, 
                        luminosityInvert:Boolean, luminosityClip:Boolean):void
    {
        if (!mask || maskType != MaskType.LUMINOSITY || mask.filters.length == 0)
            return;
        
        // Grab the shader filter 
        var shaderFilterIndex:int; 
        var shaderFilter:ShaderFilter; 
        var len:int = mask.filters.length; 
        for (shaderFilterIndex = 0; shaderFilterIndex < len; 
             shaderFilterIndex++)
        {
            if (mask.filters[shaderFilterIndex] is ShaderFilter && 
                ShaderFilter(mask.filters[shaderFilterIndex]).shader 
                    is LuminosityMaskShader)
            {
                shaderFilter = mask.filters[shaderFilterIndex];
                break; 
            }
        }
        
        if (shaderFilter)
        {
            // Reset the mode property  
            LuminosityMaskShader(shaderFilter.shader).mode = 
                calculateLuminositySettings(luminosityInvert, luminosityClip);
            
            // Re-apply the filter to the mask 
            mask.filters[shaderFilterIndex] = shaderFilter; 
            mask.filters = mask.filters; 
        }
    }
    
    /**
     *  @private
     *  Make sure the mask has a parent and force the mask to size itself.
     */
    mx_internal static function applyMask(mask:DisplayObject, 
                                          parent:DisplayObjectContainer):void
    {
        if (!mask)
            return;
        
        var maskComp:UIComponent = mask as UIComponent;            
        if (maskComp)
        {
            if (parent)
            {
                // Add the mask to the UIComponent document tree. 
                // This is required to properly render the mask.
                UIComponent(parent).addingChild(maskComp);
                UIComponent(parent).childAdded(maskComp);
            }
            
            // Size the mask including its children so that it actually 
            // renders.
            UIComponentGlobals.layoutManager.validateClient(maskComp, true);
            
            // Call this to force the mask to complete initialization
            maskComp.invalidateDisplayList();
            maskComp.setActualSize(maskComp.getExplicitOrMeasuredWidth(), 
                maskComp.getExplicitOrMeasuredHeight());                    
        }  
    }
    
    /**
     *  @private
     *  Enables clipping, alpha or luminosity, depending on the 
     *  type of mask being applied.
     */
    mx_internal static function applyMaskType(
                                    mask:DisplayObject, 
                                    maskType:String, 
                                    luminosityInvert:Boolean, 
                                    luminosityClip:Boolean,
                                    drawnDisplayObject:DisplayObject):void
    {
        if (!mask)
            return;
        
        if (maskType == MaskType.CLIP)
        {
            // Turn off caching on mask
            mask.cacheAsBitmap = false;
            mask.filters = [];
        }
        else if (maskType == MaskType.ALPHA)
        {
            mask.cacheAsBitmap = true;
            drawnDisplayObject.cacheAsBitmap = true;
        }
        else if (maskType == MaskType.LUMINOSITY)
        {
            mask.cacheAsBitmap = true;
            drawnDisplayObject.cacheAsBitmap = true;
            
            // Create the shader wrapper class which wraps the pixel bender 
            // filter. 
            var luminosityMaskShader:LuminosityMaskShader = 
                new LuminosityMaskShader();
            
            // Sets up the shader's mode property based on 
            // whether the luminosityClip and 
            // luminosityInvert properties are on or off. 
            luminosityMaskShader.mode = 
                calculateLuminositySettings(luminosityInvert, luminosityClip); 
            
            // Create the shader filter 
            var shaderFilter:ShaderFilter = 
                new ShaderFilter(luminosityMaskShader);
            
            // Apply the shader filter to the mask
            mask.filters = [shaderFilter];
        }
    }
    
    /**
     *  @private
     *  Calculates the luminosity mask shader's mode property which 
     *  determines how the shader is drawn. 
     */    
    private static function calculateLuminositySettings(
                                            luminosityInvert:Boolean, 
                                            luminosityClip:Boolean):int
    {
        var mode:int = 0;
        
        if (luminosityInvert)
            mode += 1; 
        
        if (luminosityClip) 
            mode += 2;
        
        return mode; 
    }        
}
}