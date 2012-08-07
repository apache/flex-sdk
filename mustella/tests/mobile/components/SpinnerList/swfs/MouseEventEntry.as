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
package
{
    /**
    * Represents a single mouse event entry in a sequence of events.
    */
    public class MouseEventEntry extends Object
    {
        /** The type of the mouse event, for example mouseMove or mouseDown */
        public var type:String;
        
        /** The x position of this mouse event relative to the target */
        public var localX:Number;
        
        /** The y position of this mouse event relative to the target */
        public var localY:Number;
        
        /** The "fake" time value that this event corresponds to */
        public var fakeTimeValue:Number;
        
        /** The target the mouse event will be fired against */
        public var target:Object;
        
        /** Constructor */
        public function MouseEventEntry(type:String = '', 
                                        localX:Number = NaN, 
                                        localY:Number = NaN, 
                                        fakeTimeValue:Number = NaN)
        {
            this.type = type;
            this.localX = localX;
            this.localY = localY;
            this.fakeTimeValue = fakeTimeValue;
        }
        
        /** Customize the string represntation of this object */
        public function toString():String
        {
            return '<MouseEventEntry type="' + type + '"' +
                    ' localX="' + localX + '"' +
                    ' localY="' + localY + '"' +
                    ' fakeTimeValue="' + fakeTimeValue + '" />';
        }
    }
}