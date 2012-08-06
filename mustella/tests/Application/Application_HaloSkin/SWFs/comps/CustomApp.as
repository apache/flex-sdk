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

    import flash.events.ErrorEvent;
    import flash.events.Event;
    import mx.core.Application;
    import mx.events.FlexEvent;
    import mx.managers.SystemManager;

    public class CustomApp extends Application{
        
        public var eventArray:Array = new Array();
        public var inDisplayList:Boolean = false;
        
        override public function CustomApp():void{
            addEventListener(FlexEvent.INITIALIZE, handleInitialize);
            addEventListener(FlexEvent.APPLICATION_COMPLETE, handleApplicationComplete);
            addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
            addEventListener(ErrorEvent.ERROR, handleError);
        }
        
        // Add initialize to the array.
        private function handleInitialize(e:Event):void{
            eventArray.push("initialize");
        }
        
        // Add addedToStage to the array.
        private function handleAddedToStage(e:Event):void{
            eventArray.push("addedToStage");
        }
        
        // Add applicationComplete to the array.
        // Be sure we are in the display list.
        private function handleApplicationComplete(e:Event):void{
            var i:int;
            var j:int;
            var obj:Object;
            var sm:SystemManager;
            var app:Application;
            
            eventArray.push("applicationComplete");
            
            for(i = 0; i < stage.numChildren; ++i){
                if(stage.getChildAt(i) is SystemManager){
                    sm = SystemManager(stage.getChildAt(i));
                    for(j = 0; j < sm.numChildren; ++j){
                        if(sm.getChildAt(j) is Application){
                            app = Application(sm.getChildAt(j));
                            if(app.toString().indexOf("ApplicationApp4") > -1){
                                inDisplayList = true;
                            }
                        }
                    }
                }
            }  
        }
     
        private function handleError(e:Event):void{
            eventArray.push("error");
        }
     
        
    }
}