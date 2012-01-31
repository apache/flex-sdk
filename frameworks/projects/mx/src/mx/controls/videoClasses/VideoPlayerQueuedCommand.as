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

package mx.controls.videoClasses 
{

[ExcludeClass]

/**
 *  @private
 */ 
public class VideoPlayerQueuedCommand 
{
	include "../../core/Version.as";

    public static const PLAY:uint = 0;
    public static const LOAD:uint = 1;
    public static const PAUSE:uint = 2;
    public static const STOP:uint = 3;
    public static const SEEK:uint = 4;
    
    public var type:uint;
    public var url:String;
    public var isLive:Boolean;
    public var time:Number;
    public var cuePoints:Array;
    
    public function VideoPlayerQueuedCommand(type:uint, url:String = null, isLive:Boolean = false,
                            time:Number = 0, cuePoints:Array = null) 
    {
		super();

        this.type = type;
        this.url = url;
        this.isLive = isLive;
        this.time = time;
        this.cuePoints = cuePoints;
    }
} // class QueuedCommand

}
