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
package
{
import flash.utils.*;
import mx.controls.Image;
import mx.preloaders.*;
import flash.events.*;
import flash.net.URLRequest;
public class SparkRedProgressBar extends mx.preloaders.SparkDownloadProgressBar
{
    public function SparkRedProgressBar()
    {
        super();
    }
    
    private var displayTime:int;
    
    override public function initialize():void
    {
        super.initialize();
        backgroundColor= 0xFF0000;
    }
    
    override protected function setInitProgress(completed:Number, total:Number):void
    {
        super.setInitProgress(completed, total);
        
        displayTime = getTimer();
    }
    
    override protected function showDisplayForDownloading(elapsedTime:int,
                                              event:ProgressEvent):Boolean
    {
        return true;
    }
    
    override protected function initCompleteHandler(event:Event):void
    {
        //This makes the DownloadProgressBar stay up for at least 1 second for testing purposes
        
        var minDisplayTime:Number = 1500;
        
        var elapsedTime:int = getTimer() - displayTime;
        
        if (elapsedTime < minDisplayTime)
        {
            var timer:Timer = new Timer(minDisplayTime - elapsedTime, 1);
            timer.addEventListener(TimerEvent.TIMER, timerHandler);
            timer.start();
        }
        else
        {
            timerHandler();
        }
    }
    
    private function timerHandler(event:Event = null):void
    {
        dispatchEvent(new Event(Event.COMPLETE)); 
    }
}          
}