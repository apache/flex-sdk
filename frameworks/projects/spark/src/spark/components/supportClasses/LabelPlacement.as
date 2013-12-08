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

package spark.components.supportClasses
{
    /**
     *  The LabelPlacement class defines the valid constant values for the 
     *  <code>labelPlacement</code> property of the Spark <code>CheckBox</code>.
     *
     *  @see spark.components.CheckBox#labelPlacement
     *
     *  @langversion 3.0
     *  @playerversion Flash 11.8
     *  @playerversion AIR 3.8
     *  @productversion Flex 4.12
     */
    public final class LabelPlacement
    {
        /**
         *  Constructor.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11.8
         *  @playerversion AIR 3.8
         *  @productversion Flex 4.12
        */
        public function LabelPlacement()
        {
        }


        //--------------------------------------------------------------------------
        //
        //  Class constants
        //
        //--------------------------------------------------------------------------

        /**
         *  Specifies that the <code>label</code> appears below the <code>CheckBox</code>.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 11.8
         *  @playerversion AIR 3.8
         *  @productversion Flex 4.12
         */
        public static const BOTTOM:String = "bottom";

        /**
         *  Specifies that the <code>Label</code> appears to the left of the <code>CheckBox</code>.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 11.8
         *  @playerversion AIR 3.8
         *  @productversion Flex 4.12
         */
        public static const LEFT:String = "left";

        /**
         *  Specifies that the <code>Label</code> appears to the right of the <code>CheckBox</code>.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 11.8
         *  @playerversion AIR 3.8
         *  @productversion Flex 4.12
         */
        public static const RIGHT:String = "right";

        /**
         *  Specifies that the <code>Label</code> appears above the <code>CheckBox</code>.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 11.8
         *  @playerversion AIR 3.8
         *  @productversion Flex 4.12
         */
        public static const TOP:String = "top";
    }

}
