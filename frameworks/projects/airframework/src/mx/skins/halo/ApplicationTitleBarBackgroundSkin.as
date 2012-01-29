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
import mx.styles.StyleManager;

/**
 *  The skin for the TitleBar of a WindowedApplication or Window.
 * 
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class ApplicationTitleBarBackgroundSkin extends ProgrammaticSkin
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
    public function ApplicationTitleBarBackgroundSkin()
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
        
        var cornerRadius:Number = getStyle("cornerRadius");
        var titleBarColors:Array = getStyle("titleBarColors");
        styleManager.getColorNames(titleBarColors);
        graphics.clear();
        drawRoundRect(
            0, 0, unscaledWidth, unscaledHeight, {tl: cornerRadius, 
            tr: cornerRadius, bl: 0, br: 0},
            titleBarColors, [ 1.0, 1.0 ],
            verticalGradientMatrix(0, 0, unscaledWidth, unscaledHeight));
        graphics.lineStyle(1, 0xFFFFFF, 0.2);
        graphics.moveTo(0, unscaledHeight - 1);
        graphics.lineTo(0, cornerRadius);
        graphics.curveTo(0, 0, cornerRadius, 0);
        graphics.lineTo(unscaledWidth-1 - cornerRadius, 0);
        graphics.curveTo(unscaledWidth-1, 0, unscaledWidth - 1, cornerRadius);
        graphics.lineTo(unscaledWidth-1, unscaledHeight - 1);
        graphics.moveTo(0, unscaledHeight - 1);
        graphics.lineStyle(1, 0x000000, 0.35);
        graphics.lineTo(unscaledWidth, unscaledHeight - 1);
        
    }
}

}
