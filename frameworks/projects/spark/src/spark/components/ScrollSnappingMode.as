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

package spark.components
{
    
    /**
     *  The ScrollSnappingMode class defines the enumeration values for 
     *  the <code>scrollSnappingMode</code> property of the List and Scroller classes.
     *
     *  @see spark.components.List#scrollSnappingMode
     *  @see spark.components.Scroller#scrollSnappingMode
     *
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public final class ScrollSnappingMode
    {
        /**
         *  Scroll snapping is off.
         *
         *  @langversion 3.0
         *  @playerversion AIR 3
         *  @productversion Flex 4.6
         */
        public static const NONE:String = "none";
        
        /**
         *  Elements are snapped to the left (horizontal) or top (vertical)
         *  edge of the viewport.
         *
         *  @langversion 3.0
         *  @playerversion AIR 3
         *  @productversion Flex 4.6
         */
        public static const LEADING_EDGE:String = "leadingEdge";
        
        /**
         *  Elements are snapped to the center of the viewport.
         *
         *  @langversion 3.0
         *  @playerversion AIR 3
         *  @productversion Flex 4.6
         */
        public static const CENTER:String = "center";
        
        /**
         *  Elements are snapped to the right (horizontal) or bottom (vertical)
         *  edge of the viewport.
         *
         *  @langversion 3.0
         *  @playerversion AIR 3
         *  @productversion Flex 4.6
         */
        public static const TRAILING_EDGE:String = "trailingEdge";
        
    }
}