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

package spark.automation.delegates.components
{
    import flash.display.DisplayObject;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    
    import mx.automation.Automation;
    import mx.automation.IAutomationObject;
    import mx.automation.IAutomationObjectHelper;
    import mx.core.mx_internal;
    
    import spark.automation.delegates.components.supportClasses.SparkSkinnableComponentAutomationImpl;
    import spark.components.VideoPlayer;
    
    use namespace mx_internal;
    
    [Mixin]
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  VideoPlayer control.
     * 
     *  @see spark.components.VideoPlayer 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     *
     */
    public class SparkVideoPlayerAutomationImpl extends SparkSkinnableComponentAutomationImpl
    {
        
        include "../../../core/Version.as";
        //--------------------------------------------------------------------------
        //
        //  Class methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Registers the delegate class for a component class with automation manager.
         *  
         *  @param root The SystemManger of the application.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public static function init(root:DisplayObject):void
        {
            Automation.registerDelegateClass(spark.components.VideoPlayer, SparkVideoPlayerAutomationImpl);
        }   
        
        /**
         *  Constructor.
         * @param obj VideoPlayer object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkVideoPlayerAutomationImpl(obj:spark.components.VideoPlayer)
        {
            super(obj);
        }
        
        /**
         *  @private
         */
        protected function get sparkVideoPlayer():spark.components.VideoPlayer
        {
            return uiComponent as spark.components.VideoPlayer;   
        }
        
        
        /**
         *  @private
         */
        override protected function keyDownHandler(event:KeyboardEvent):void
        {
            if(event.keyCode == Keyboard.ESCAPE)
                recordAutomatableEvent(event);
        }
        
        
        /**
         *  @private
         */
        override public function get numAutomationChildren():int
        { 
            
            var objArray:Array = getAutomationChildren();
            return (objArray?objArray.length:0);
        }
        
        
        /**
         *  @private
         */
        override public function getAutomationChildAt(index:int):IAutomationObject
        {
            var arr:Array = getAutomationChildren();
            if (arr && (arr.length < index))
                arr[index];
            
            return null;
        }
        
        
        /**
         *  @private
         */
        override public function getAutomationChildren():Array
        {
            
            var chilArray:Array = new Array();
			if(sparkVideoPlayer.videoDisplay)
				chilArray.push(sparkVideoPlayer.videoDisplay);
			
            if(sparkVideoPlayer.currentTimeDisplay)
                chilArray.push(sparkVideoPlayer.currentTimeDisplay);
            
            if(sparkVideoPlayer.fullScreenButton)
                chilArray.push(sparkVideoPlayer.fullScreenButton);
            
            if(sparkVideoPlayer.muteButton)
                chilArray.push(sparkVideoPlayer.muteButton);
            
            if(sparkVideoPlayer.pauseButton)
                chilArray.push(sparkVideoPlayer.pauseButton);
            
            if(sparkVideoPlayer.playButton)
                chilArray.push(sparkVideoPlayer.playButton);
            
            
            if(sparkVideoPlayer.playPauseButton)
                chilArray.push(sparkVideoPlayer.playPauseButton);
            
            if(sparkVideoPlayer.scrubBar)
                chilArray.push(sparkVideoPlayer.scrubBar);
            
            if(sparkVideoPlayer.stopButton)
                chilArray.push(sparkVideoPlayer.stopButton);
            
            if(sparkVideoPlayer.durationDisplay)
                chilArray.push(sparkVideoPlayer.durationDisplay);
            
            
            if(sparkVideoPlayer.volumeBar)
                chilArray.push(sparkVideoPlayer.volumeBar);
            
            return chilArray;
        }
        
        
        
        /**
         *  @private
         */
        override public function createAutomationIDPart(child:IAutomationObject):Object
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return help.helpCreateIDPart(uiAutomationObject, child);
        }
        
        
        /**
         *  @private
         */
        override public function resolveAutomationIDPart(part:Object):Array
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return help.helpResolveIDPart(uiAutomationObject, part);
        }
        
        
        /**
         *  @private
         */
        override public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, properties:Array):Object
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return help.helpCreateIDPartWithRequiredProperties(uiAutomationObject, child,properties);
            
        }
        
        
        
    }
    
}