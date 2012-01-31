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
     *  Values for the <code>state</code> property
     *  of the InteractionStateDetector class.
     *
     *  @see spark.components.supportClasses.InteractionStateDetector
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public final class InteractionState
    {
        
        //--------------------------------------------------------------------------
        //
        //  Class constants
        //
        //--------------------------------------------------------------------------
        
        /**
         *  The component should be in the up state.
         *  
         *  <p>No interaction is occurring on this component.</p>
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const UP:String = "up";
        
        /**
         *  The component should be in the down state.
         *  
         *  <p>The user is currently pressing down on this component.</p>
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const DOWN:String = "down";
        
        /**
         *  The component should be in the over state.
         *  
         *  <p>The user is currently hovering over this component.</p>
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const OVER:String = "over";
    }
    
}
