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
package assets{

    import flash.events.*;
    import flash.geom.*;
    import spark.components.WindowedApplication;
    
    public class SubclassedWA extends WindowedApplication{

        /**
        * Constructor
        **/
        public function SubclassedWA():void{}
        
        /**
        * Test overriding mouseDownHandler.
        **/
        override protected function mouseDownHandler(e:MouseEvent):void{
            dispatchEvent(new MouseEvent("wa_subclassed_mouseDown_handled"));
        }

        /**
        * Test getting the skinParts property.
        **/    
        public function getSkinParts():Object{
            return this.skinParts;
        }
        
        /**
        * Get the bounds property.
        **/
        public function getTheBounds():Rectangle{
            return this.bounds;
        }

        /**
        * Set the bounds property.
        **/
        public function setTheBounds(val:Rectangle):void{
            this.bounds = val;
        }

    } // end class
} // end package