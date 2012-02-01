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

/**
 *  Defines the border and background for the MX Container class's Spark skin.
 *  
 *  @see mx.core.Container
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */     
public class ContainerBorderSkin extends BorderSkin
{
    /**
     *  Constructor.
     */
    public function ContainerBorderSkin()
    {
        super();
    }
    
    /**
     *  @private
     *  ContainerBorderSkin uses backgroundColor and backgroundAlpha
     *  instead of contentBackgroundColor and contentBackgroundAlpha.
     *  Override the contentItems getter here to return null. This
     *  removes the contentBackgroundColor/Alpha functionality.
     *  The backgroundColor/backgroundAlpha functionality is handled
     *  below in updateDisplayList.
     */
    override public function get contentItems():Array
    {
        return null;
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number) : void
    {
        var cr:Number = getStyle("cornerRadius");
        
        if (cornerRadius != cr)
            cornerRadius = cr;
        
        // Push backgroundColor and backgroundAlpha directly.
        // Handle undefined backgroundColor by hiding the background object.
        if (isNaN(getStyle("backgroundColor")))
        {
            background.visible = false;
        }
        else
        {
            background.visible = true;
            bgFill.color = getStyle("backgroundColor");
            bgFill.alpha = getStyle("backgroundAlpha");
        }
        
        super.updateDisplayList(unscaledWidth, unscaledHeight);
    }

}
}
