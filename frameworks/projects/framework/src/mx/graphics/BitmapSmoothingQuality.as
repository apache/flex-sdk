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
 *  An enum of the smoothing quality modes that determine how a BitmapImage
 *  scales image content when fillMode is set to BitmapFillMode.SCALE and
 *  <code>smooth</code> is true.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
public final class BitmapSmoothingQuality
{
    /**
     *  Default smoothing algorithm is used when scaling,
     *  consistent with quality of the stage (stage.quality).
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public static const DEFAULT:String = "default";

    /**
     *  High quality smoothing algorithm is used when scaling. Used
     *  when a higher quality (down-sampled) scale is preferred. This option 
     *  yields the best results when the image is scaled to a size equal to the 
     *  aspect ratio of the original image and is useful for generating high 
     *  quality thumbnails. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public static const HIGH:String = "high";
}

}
