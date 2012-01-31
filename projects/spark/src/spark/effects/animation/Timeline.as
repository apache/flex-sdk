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

package spark.effects.animation
{
import flash.utils.getTimer;

/**
 * The Timeline class is an internal utility used by Animation to
 * keep a single pulse for animations. This ensures that all animations
 * run off a single timer, rather than individually calling getTimer().
 * This approach means that effects that are set up to end/start at the same
 * time, through use of duration and startDelay properties, will be
 * synchronized.
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
internal class Timeline
{
    // TODO (chaase): This class is internal for now, but it may eventually
    // make sense to make it public and accessible outside of just the
    // Animation class. For example, effects may want to access the global
    // animation time. Also, we  may want to have child timelines, or expose
    // other capabilities such as speeding up and slowing down time.
    // Note that the static methods may instead become instance methods
    // on a singleton.

    private static var startTime:int = -1;
    private static var _currentTime:int = -1;

    public function Timeline()
    {
    }

    public static function pulse():int
    {
        if (startTime < 0)
        {
            startTime = getTimer();
            _currentTime = 0;
            return _currentTime;
        }
        _currentTime = getTimer() - startTime;
        return _currentTime;
    }

    public static function get currentTime():int
    {
        if (_currentTime < 0)
        {
            var retVal:int = pulse();
            return pulse();
        }
        return _currentTime;
    }

}
}
