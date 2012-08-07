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
    import mx.core.ILayoutElement;
    
    import spark.components.supportClasses.GroupBase;
    import spark.layouts.supportClasses.LayoutBase;
    
    public class EvenOddLayout extends LayoutBase
    {
        
        override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            if (!target)
                return;
            
            if (!typicalLayoutElement)
                return;
                
            if (target.numElements <= 0)
            	return;
            
            if (useVirtualLayout)
                updateDisplayListVirtual(unscaledWidth, unscaledHeight);
            else 
                updateDisplayListReal(unscaledWidth, unscaledHeight);
            
        }
        
        private function updateDisplayListVirtual(containerWidth:Number, containerHeight:Number):void {
            
            //
            // figure out what items are in view (very naively)
            //
            
            var firstIndexInView:int = 0;
            var lastIndexInView:int = 0;
            var numElementsInView:int = 0;
            
            var minVisibleX:Number = target.horizontalScrollPosition;
            var maxVisibleX:Number = minVisibleX + target.width;
            
            firstIndexInView = target.horizontalScrollPosition / typicalLayoutElement.getLayoutBoundsWidth();
            numElementsInView = target.width / typicalLayoutElement.getLayoutBoundsWidth();
            
            lastIndexInView = firstIndexInView + numElementsInView;
            
            // start drawing the first element at the horizontalScrollPosition (buggy)
            
            var x:Number = minVisibleX;
            var y:Number = 0;
            var count:int = target.numElements;
            
            // intersperse increasing even and decreasing odd items
            for (var k:int = firstIndexInView; k < lastIndexInView; k++)
            {
                var element:ILayoutElement;
                if(k % 2 == 0){
                    // even index
                    element = target.getVirtualElementAt(k)
                } else {
                    // odd index
                    element = target.getVirtualElementAt(count - k)
                }
                
                // Position the element
                element.setLayoutBoundsPosition(x, y);
                
                // Resize the element to its preferred size by passing
                // NaN for the width and height constraints
                element.setLayoutBoundsSize(NaN, NaN);
                
                var elementWidth:Number = element.getLayoutBoundsWidth();
                var elementHeight:Number = element.getLayoutBoundsHeight();
                
                // Update the layoutTarget's content width and height
                target.setContentSize(Math.ceil(typicalLayoutElement.getLayoutBoundsWidth() * target.numElements), 
                                      Math.ceil(Math.max(elementHeight, target.contentHeight)));
                
                // Update the current position
                x += elementWidth;
            }
            
            //trace('updateDisplayList - virtual, firstIndexInView =', firstIndexInView, " lastIndexInView = ", lastIndexInView);
        }
        
        private function updateDisplayListReal(containerWidth:Number, containerHeight:Number):void {
            var x:Number = 0;
            var y:Number = 0;
            
            // loop through the elements
            var count:int = target.numElements;
            
            // intersperse increasing even and decreasing odd
            for (var k:int = 0; k < count; k++)
            {
                var element:ILayoutElement;
                if(k % 2 == 0){
                    // even index
                    element = (useVirtualLayout) ? target.getVirtualElementAt(k) : target.getElementAt(k);
                } else {
                    // odd index
                    element = (useVirtualLayout) ? target.getVirtualElementAt(count - k) : target.getElementAt(count - k);
                }
                
                // Position the element
                element.setLayoutBoundsPosition(x, y);
                
                // Resize the element to its preferred size by passing
                // NaN for the width and height constraints
                element.setLayoutBoundsSize(NaN, NaN);
                
                var elementWidth:Number = element.getLayoutBoundsWidth();
                var elementHeight:Number = element.getLayoutBoundsHeight();
                
                // Update the layoutTarget's content width and height
                target.setContentSize(Math.ceil(x), Math.ceil(Math.max(elementHeight, target.contentHeight)));
                
                // Update the current position
                x += elementWidth;
            }
            
            //trace('updateDisplayList - real');
        }
        
        override protected function scrollPositionChanged():void
        {
            super.scrollPositionChanged();
            
            var g:GroupBase = target;
            if (!g)
                return;     
                        
            if (useVirtualLayout)
                g.invalidateDisplayList();
            
        }
    }
    
}