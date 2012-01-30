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

package mx.graphics
{

/**
 *  The BitmapScaleMode class defines an enumeration for the scale modes 
 *  that determine how a BitmapImage scales image content when 
 *  <code>fillMode</code> is set to <code>mx.graphics.BitmapFillMode.SCALE</code>.
 *
 *  @see spark.components.Image#scaleMode
 *  @see spark.primitives.BitmapImage#scaleMode
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
public final class BitmapScaleMode
{
    /**
     *  The bitmap fill stretches to fill the region.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public static const STRETCH:String = "stretch";

    /**
     *  The bitmap fill is scaled while maintaining the aspect
     *  ratio of the original content.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public static const LETTERBOX:String = "letterbox";
    
    /**
     *  The bitmap fill is scaled and cropped such that the aspect
     *  ratio of the original content is maintained and no letterbox
     *  or pillar box is displayed.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const ZOOM:String = "zoom";
}

}
