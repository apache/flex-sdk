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
package Assets{
    import flash.events.Event;
    import spark.components.DataGroup;
    import spark.components.TabBar;
    import spark.events.RendererExistenceEvent;
    
    public class CustomTabBar2 extends TabBar{

        public function CustomTabBar2():void{}
        
        override protected function partAdded(partName:String, instance:Object):void{
            super.partAdded(partName, instance);       

            if (instance == dataGroup){
                dataGroup.addEventListener(RendererExistenceEvent.RENDERER_ADD, doCustomAddEvent);
            }
        }

        override protected function partRemoved(partName:String, instance:Object):void{
            dispatchEvent(new Event("customRemoveEvent"));            
            super.partRemoved(partName, instance);
        }        

        private function doCustomAddEvent(e:Event):void{
            dispatchEvent(new Event("customAddEvent"));
        }

    }
}
