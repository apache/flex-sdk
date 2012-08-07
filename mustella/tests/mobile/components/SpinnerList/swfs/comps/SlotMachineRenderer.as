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
    import spark.components.IconItemRenderer;
    
    public class SlotMachineRenderer extends IconItemRenderer
    {
        public function SlotMachineRenderer()
        {
            super();
            labelField = "";
            iconField = "image"; 
            iconWidth = 100;
            iconHeight = 100;
        }
        
        /** Draw an invisible background for hit testing */
        override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
        {
            graphics.beginFill(0x000000, 0);
            graphics.lineStyle();
            graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
            graphics.endFill();
        }
        
    }
}