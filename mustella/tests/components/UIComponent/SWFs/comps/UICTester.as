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
package comps{

    import flash.events.Event;
    import flash.geom.Rectangle;
    //import mx.core.VisualPrimitive;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;

    /**
    * This class is used to test the VisualPrimitive base class.
    * Extend UIComponent until VisualPrimitive can be used.
    */

    public class UICTester extends UIComponent{
        
        /**
        * Hard code width and height for testing.
        **/
        public const DEFAULT_WIDTH:int = 100;
        public const DEFAULT_HEIGHT:int = 100;
        
        /**
        * An entry is made in this array every time one of the
        * events or methods being tested occurs.  Afterwards, we can then
        * figure out if everything was called, and in the right
        * order.
        */
        public var sequenceArray:Array = new Array();

        /**
        * We make a rectangle in this object so that there is
        * something to do a baseline compare with.  This is
        * so we can test properties such as width, height, and 
        * visible.
        **/
        public var theRect:TestShape;
        
        /**
        * Methods
        **/
        public function UICTester():void{
            super();
            sequenceArray.push("method-constructor");
            
            this.width = DEFAULT_WIDTH;
            this.height = DEFAULT_HEIGHT;
            
            addEventListener(FlexEvent.CREATION_COMPLETE, testCreationComplete);
            addEventListener(FlexEvent.UPDATE_COMPLETE, testUpdateComplete);
            addEventListener(FlexEvent.INITIALIZE, testInitialize);
            addEventListener(FlexEvent.PREINITIALIZE, testPreinitialize);

        }
        
        override protected function commitProperties():void{
            super.commitProperties();
            sequenceArray.push("method-commitProperties");
        }
        
        override protected function createChildren():void{
            super.createChildren();
            
            // Set up the test shape.
            theRect = new TestShape();
            theRect.theWidth = this.width;
            theRect.theHeight = this.height;
            addChild(theRect);
            
            sequenceArray.push("method-createChildren");
        }
        
        override protected function initializationComplete():void{
            super.initializationComplete();
            sequenceArray.push("method-initializationComplete");
        }
        
        override public function initialize():void{
            super.initialize();
            sequenceArray.push("method-initialize");
        }
        
        override public function invalidateDisplayList():void{
            super.invalidateDisplayList();
            sequenceArray.push("method-invalidateDisplayList");
        }
        
        override public function invalidateProperties():void{
            super.invalidateProperties();
            sequenceArray.push("method-invalidateProperties");
        }
        
        override public function invalidateSize():void{
            super.invalidateSize();
            sequenceArray.push("method-invalidateSize");
        }
        
        override protected function measure():void{
            super.measure();
            sequenceArray.push("method-measure");
        }
        
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
            super.updateDisplayList(unscaledWidth, unscaledHeight)
            sequenceArray.push("method-updateDisplayList");

            if(theRect){
                theRect.height = unscaledHeight;
                theRect.width = unscaledWidth;
            }           
        }

        /**
        * Events
        **/
        private function testCreationComplete(e:FlexEvent):void{
            sequenceArray.push("event-creationComplete");
        }        
        
        private function testUpdateComplete(e:FlexEvent):void{
            sequenceArray.push("event-updateComplete");
        }
        
        private function testInitialize(e:FlexEvent):void{
            sequenceArray.push("event-initialize");
        }

        private function testPreinitialize(e:FlexEvent):void{
            sequenceArray.push("event-preinitialize");
        }

    }
}
