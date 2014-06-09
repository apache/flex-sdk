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

package mx.core {
import flash.display.Sprite;
import flash.system.Capabilities;
import flash.utils.setInterval;

/**
 *  DebuggableWorker should be used as a base class
 *  for workers instead of Sprite.
 *  it allows the debugging of those workers using FDB.
 *
 *  @langversion 3.0
 *  @playerversion Flash 11.4
 *  @playerversion AIR 3.4
 *  @productversion Flex 4
 */
public class DebuggableWorker extends Sprite {

    include "../core/Version.as";

    public function DebuggableWorker() {

        // Stick a timer here so that we will execute script every 1.5s
        // no matter what.
        // This is strictly for the debugger to be able to halt.
        // Note: isDebugger is true only with a Debugger Player.
        if (Capabilities.isDebugger == true) {
            setInterval(debugTickler, 1500);
        }
    }

    /**
     *  @private
     *  This is here so we get the "this" pointer set to this worker instance.
     */
    private function debugTickler():void {
        // We need some bytes of code in order to have a place to break.
        var i:int = 0;
    }
}
}
