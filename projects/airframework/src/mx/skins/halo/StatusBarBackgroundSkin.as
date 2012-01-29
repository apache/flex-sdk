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

package mx.skins.halo
{

import mx.skins.ProgrammaticSkin;

/**
 *  The skin for the StatusBar of a WindowedApplication or Window.
 * 
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class StatusBarBackgroundSkin extends ProgrammaticSkin
{
    include "../../core/Version.as";    
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function StatusBarBackgroundSkin()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: Programmatic Skin
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        graphics.clear();
        drawRoundRect(
            0, 0, unscaledWidth, unscaledHeight, null,
            getStyle("statusBarBackgroundColor"), 1.0);
        graphics.moveTo(0, 0);
        graphics.lineStyle(1, 0x000000, 0.35);
        graphics.lineTo(unscaledWidth, 0);
    }
}

}
