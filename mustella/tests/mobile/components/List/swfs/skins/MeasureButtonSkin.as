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
package skins
{
    import spark.skins.mobile.ButtonSkin;
    
    /**
    * A simple custom ButtonSkin that keeps track of how many times measure
    * and updateDisplayList was called on it. (SDK-27642)
    */
    public class MeasureButtonSkin extends ButtonSkin
    {
        /** Keeps track of the measure and updateDisplayList calls */
        public static var outputString:String = "";
        
        override protected function measure():void
        {
            super.measure();
            outputString += "measure|";
        }
        
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            outputString += "updateDisplayList|";
        }

    }
}