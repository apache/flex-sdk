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
import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  Emphasized button uses accentColor instead of chromeColor. Replaces the
 *  TransparentActionButtonSkin.
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
public class DefaultTransparentActionButtonSkin extends TransparentActionButtonSkin
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
     * 
     */
    public function DefaultTransparentActionButtonSkin()
    {
        super();
        
        fillColorStyleName = "accentColor";
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // omit super.drawBackground() to drawRect instead
        // always draw accentColor regardless of skin state
        graphics.beginFill(getStyle(fillColorStyleName));
        graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
        graphics.endFill();
    }
}
}