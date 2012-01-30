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
     *  The ViewNavigatorAction class defines the constant values
     *  for the <code>action</code> property of ViewNavigatorEvent class.
     *
     *  @see spark.events.ViewNavigatorEvent
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public final class ViewNavigatorAction
    {
        //--------------------------------------------------------------------------
        //
        //  Class constants
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constant indicating that no action was performed by the navigator.
         *  
         *  @langversion 3.0
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const NONE:String = "none";
        
        /**
         *  Constant describing a navigation action where a new view is added
         *  to a navigator.
         * 
         *  @langversion 3.0
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const PUSH:String = "push";
        
        /**
         *  Constant describing a navigation action where the top most view is
         *  removed from the navigator.
         * 
         *  @langversion 3.0
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const POP:String = "pop";
        
        /**
         *  Constant describing a navigation action where all views
         *  were removed from the navigator.
         * 
         *  @langversion 3.0
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const POP_ALL:String = "popAll";
        
        /** 
         *  Constant describing a navigation action where all but the
         *  first view are removed from the navigator.
         * 
         *  @langversion 3.0
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const POP_TO_FIRST:String = "popToFirst";
        
        /**
         *  Constant describing a navigation action where the active view
         *  is replaced with another.
         *  
         *  @langversion 3.0
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const REPLACE:String = "replace";
    }
}