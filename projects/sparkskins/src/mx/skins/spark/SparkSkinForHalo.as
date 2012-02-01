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

package mx.skins.spark {

import spark.skins.SparkSkin;

/** 
 *  The SparkSkinForHalo class is the base class for Spark skins for MX components. 
 *  This class adds support for setting the color of the border with the 
 *  value of the <code>errorColor</code> style when a validation error occurs.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */    
public class SparkSkinForHalo extends SparkSkin
{   
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function SparkSkinForHalo()
    {
        super();
    }
      
    /**
     *  If the <code>errorString</code> property of the component contains text, 
     *  this property contains the names of the items that should have their 
     *  <code>color</code> property set to the value of the <code>errorColor</code> style.
     *  The text in the <code>errorString</code> property is displayed by a component's 
     *  error tip when the component is monitored by a Validator and validation fails.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function get borderItems():Array
    {
        return null;
    }
      
    /**
     *  Default border item color.
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function get defaultBorderItemColor():uint
    {
        return 0;
    }
    
    /**
     *  Default border alpha. If NaN, don't change alpha value.
     * 
     *  @default NaN 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function get defaultBorderAlpha():Number
    {
        return NaN;
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        var borderItems:Array = this.borderItems;
        
        if (borderItems && borderItems.length > 0)
        {
            var isError:Boolean = false;
            var borderItemColor:uint;
            var errorColor:uint = getStyle("errorColor");
            var borderAlpha:Number = defaultBorderAlpha;
            
            if (getStyle("borderColor") == errorColor)
                borderItemColor = errorColor;
            else
                borderItemColor = defaultBorderItemColor;
            
            for (var i:int = 0; i < borderItems.length; i++)
            {
                if (this[borderItems[i]])
                {
                    this[borderItems[i]].color = borderItemColor;
                    if (!isNaN(borderAlpha))
                        this[borderItems[i]].alpha = borderAlpha;
                }
            }
        }

        super.updateDisplayList(unscaledWidth, unscaledHeight);
    }
}
}