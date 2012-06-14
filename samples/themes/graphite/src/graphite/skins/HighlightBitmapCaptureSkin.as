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

package graphite.skins
{
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.IBitmapDrawable;
    import flash.events.Event;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Rectangle;
    
    import mx.core.UIComponent;
    import mx.core.mx_internal;
    import mx.events.FlexEvent;
    
    import spark.components.supportClasses.SkinnableComponent;
    import spark.components.supportClasses.Skin;
    
    use namespace mx_internal;
    
    /**
     *  Base class for skins that do a bitmap capture of a target components
     *  and apply a filter to the bitmap.
     *  This is the base class for FocusSkin and ErrorSkin.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public class HighlightBitmapCaptureSkin extends UIComponent
    {
        //--------------------------------------------------------------------------
        //
        //  Class constants
        //
        //--------------------------------------------------------------------------
        
        //--------------------------------------------------------------------------
        //
        //  Class variables
        //
        //--------------------------------------------------------------------------
        
        private static var capturingBitmap:Boolean = false;
        private static var colorTransform:ColorTransform = new ColorTransform(
            1.01, 1.01, 1.01, 2);
        private static var rect:Rectangle = new Rectangle();
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         * Constructor.
         */
        public function HighlightBitmapCaptureSkin()
        {
            super();
        }
        
        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------
         
        /**
         *  Bitmap capture of the target component. 
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        protected var bitmap:Bitmap;
        
        /**
         *  @private
         */
        private var _target:SkinnableComponent;
        
        /**
         *  Object to target.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function get target():SkinnableComponent
        {
            return _target;
        }
        
        public function set target(value:SkinnableComponent):void
        {
            _target = value;
            
            // Add an "updateComplete" listener to the skin so we can redraw
            // whenever the skin is drawn.
            if (_target.skin)
                _target.skin.addEventListener(FlexEvent.UPDATE_COMPLETE, 
                    skin_updateCompleteHandler, false, 0, true);
        }
        
        /**
         *  Number of padding pixels to put around the bitmap.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        protected function get borderWeight():Number
        {
            return 1;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Overridden methods
        //
        //--------------------------------------------------------------------------
        
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {   
            // if we weren't handed a targetObject then exit early
            if (!target)
                return;
            
            var bitmapData:BitmapData = new BitmapData(
                target.width + (borderWeight * 2), 
                target.height + (borderWeight * 2), true, 0);
            var m:Matrix = new Matrix();
            
            capturingBitmap = true;
            
            // Ensure no 3D transforms apply, as this skews our snapshot bitmap.
            var transform3D:Matrix3D = null;
            if (target.$transform.matrix3D)
            {
                transform3D = target.$transform.matrix3D;  
                target.$transform.matrix3D = null;
            }
            
            // If the target object already has a focus skin, make sure it is hidden.
            if (target.focusObj)
                target.focusObj.visible = false;
            
            
            var skin:Skin = target.skin as Skin;
            if (skin)
                skin.beginHighlightBitmapCapture();
            
            m.tx = borderWeight;
            m.ty = borderWeight;
            bitmapData.draw(target as IBitmapDrawable, m);
            
            if (skin)
                skin.endHighlightBitmapCapture();
            
            
            // Show the focus skin, if needed.
            if (target.focusObj)
                target.focusObj.visible = true;
            
            // Transform the color to remove the transparency. The GlowFilter has the "knockout" property
            // set to true, which removes this image from the final display, leaving only the outer glow.
            rect.x = rect.y = borderWeight;
            rect.width = target.width;
            rect.height = target.height;
            bitmapData.colorTransform(rect, colorTransform);
            
            if (!bitmap)
            {
                bitmap = new Bitmap();
                addChild(bitmap);
            }
            
            bitmap.x = bitmap.y = -borderWeight;
            bitmap.bitmapData = bitmapData;
            
            processBitmap();
            
            // Restore original 3D matrix if applicable.
            if (transform3D)
                target.$transform.matrix3D = transform3D;
            
            capturingBitmap = false;
        }
        
        /**
         *  Apply any post-processing to the captured bitmap.
         */
        protected function processBitmap():void
        {          
        }
        
        /**
         *  @private
         */
        private function skin_updateCompleteHandler(event:Event):void
        {
            // We need to redraw whenever the target object skin redraws.
            if (!capturingBitmap)
                invalidateDisplayList();
        }
    }
}        
