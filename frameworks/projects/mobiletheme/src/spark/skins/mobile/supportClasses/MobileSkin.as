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

package spark.skins.mobile.supportClasses
{
import flash.geom.ColorTransform;
import flash.geom.Matrix;

import mx.core.mx_internal;

import spark.skins.ActionScriptSkinBase;

use namespace mx_internal;

/**
 *  ActionScript-based skin for mobile applications. This skin is the 
 *  base class for all of the ActionScript mobile skins. As an optimization, 
 *  it removes state transition support.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class MobileSkin extends ActionScriptSkinBase
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Dark <code>chromeColor</code> used in ViewNavigator and
     *  TabbedViewNavigator "chrome" elements: ActionBar and
     *  TabbedViewNavigator#tabBar.
     */
    mx_internal static const MOBILE_THEME_DARK_COLOR:uint = 0x484848;
    
    /**
     *  @private
     *  Default <code>chromeColor</code> for the mobile theme.
     */
    mx_internal static const MOBILE_THEME_LIGHT_COLOR:uint = 0xCCCCCC;
    
    /**
     *  @private
     *  Default symbol color for <code>symbolColor</code> style.
     */
    mx_internal static const DEFAULT_SYMBOL_COLOR_VALUE:uint = 0x00;
    
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
    public function MobileSkin()
    {
        useMinimumHitArea = true;
    }
    

    
    //----------------------------------
    //  colorMatrix
    //----------------------------------
    
    private static var _colorMatrix:Matrix = new Matrix();
    
    /**
     *  @private
     */
    mx_internal static function get colorMatrix():Matrix
    {
        if (!_colorMatrix)
            _colorMatrix = new Matrix();
        
        return _colorMatrix;
    }
    
    //----------------------------------
    //  colorTransform
    //----------------------------------
    
    private static var _colorTransform:ColorTransform;
    
    /**
     *  @private
     */
    mx_internal static function get colorTransform():ColorTransform
    {
        if (!_colorTransform)
            _colorTransform = new ColorTransform();
        
        return _colorTransform;
    }
    


}
}