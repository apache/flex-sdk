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
package comps
{
    /**
    *
    * A sample data item that might be used in a List.
    *  
    * This includes some bindable properties.
    * 
    * There is a built in concept of the visual size of this item
    * via majorAxis/majorSize/minorSize. This is useful for having
    * a single data type capable of being in any layout.
    * 
    * There are also properties available to stuff data into like
    * dataNumber where for example some renderers save a value for
    * virtual layout.
    * 
    */
    public class DataItem
    {
        [Bindable] public var myItemIndex:Number;
        [Bindable] public var majorAxis:String;
        [Bindable] public var minorSize:Number;
        [Bindable] public var majorSize:Number;
        
        // Extra fields that some renderers can store information in
        [Bindable] public var dataNumber:Number = 0;
        [Bindable] public var dataBoolean:Boolean = false;
        [Bindable] public var dataImage:String = "assets/flex_logo_128.png";
        [Bindable] public var dataArray:Array = new Array();
        
        // constructor
        public function DataItem(myItemIndex:Number = -1, 
                                 majorSize:Number = 100, 
                                 minorSize:Number = 100, 
                                 majorAxis:String = "vertical"):void 
        {
            this.myItemIndex = myItemIndex;
            this.majorSize = majorSize;
            this.minorSize = minorSize;
            this.majorAxis = majorAxis;
        }
        
    }
}