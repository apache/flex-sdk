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
package comps {
    
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.JointStyle;
    import flash.display.LineScaleMode;
    import flash.display.Shape;
    import flash.display.Sprite;

    
    /**
    * This is a basic shape used for testing.
    * This is mostly just a copy from the ASDoc for
    * flash.display.Shape.
    **/
    
    public class TestShape extends Sprite {
        private var bgColor:uint      = 0xFFCC00;
        private var borderColor:uint  = 0xFFCC00;
        private var borderSize:uint   = 0;
        private var cornerRadius:uint = 0;
        private var gutter:uint       = 0;

        private var _theHeight:int    = 100;
        private var _theWidth:int     = 100;
        private var theShape:Shape;
                
        public function TestShape() {
            doDrawRect();
            refreshLayout();
        }

        private function refreshLayout():void {
            var ln:uint = numChildren;
            var child:DisplayObject;
            var lastChild:DisplayObject = getChildAt(0);
            lastChild.x = gutter;
            lastChild.y = gutter;
            for (var i:uint = 1; i < ln; i++) {
                child = getChildAt(i);
                child.x = gutter + lastChild.x + lastChild.width;
                child.y = gutter;
                lastChild = child;
            }
        }

            
        /**
        * I suspect there's a better way to resize a shape,
        * but we'll just remove it and create a new one.
        **/
        private function doRedrawRect():void {

            removeChild(theShape);
            theShape = new Shape();
            theShape.graphics.beginFill(bgColor);
            theShape.graphics.lineStyle(borderSize, borderColor);
            theShape.graphics.drawRect(0, 0, _theWidth, _theHeight);
            theShape.graphics.endFill();
            addChild(theShape);
        }

        private function doDrawRect():void {
            theShape = new Shape();
            theShape.graphics.beginFill(bgColor);
            theShape.graphics.lineStyle(borderSize, borderColor);
            theShape.graphics.drawRect(0, 0, _theWidth, _theHeight);
            theShape.graphics.endFill();
            addChild(theShape);
        }
        
        public function set theHeight(value:int):void{
            _theHeight = value;
            doRedrawRect();
        }
        
        public function get theHeight():int{
            return _theHeight;
        }


        public function set theWidth(value:int):void{
            _theWidth = value;
            doRedrawRect();
        }
        
        public function get theWidth():int{
            return _theWidth;
        }
        
    }
}
