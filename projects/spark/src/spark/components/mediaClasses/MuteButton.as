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

package spark.components.mediaClasses
{

import flash.events.Event;
import flash.events.MouseEvent;

import mx.events.FlexEvent;

import spark.components.Button;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the user mutes or unmutes the video.
 *
 *  @eventType mx.events.FlexEvent.MUTED_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="mutedChange", type="mx.events.FlexEvent")]

/**
 *  The MuteButton class defines the mute button used by the VideoPlayer control. 
 *  Clicking the button mutes or unmutes the volume.  
 * 
 *  @see spark.components.VideoPlayer 
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class MuteButton extends Button
{   
        
    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function MuteButton()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  muted
    //----------------------------------
    
    /**
     *  @private
     */
    private var _muted:Boolean = false;
    
    [Bindable("mutedChanged")]
    
    /**
     *  Contains <code>true</code> if the volume of the video is muted,  
     *  and <code>false</code> if not.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get muted():Boolean
    {
        return _muted;
    }
    
    /**
     *  @private
     */
    public function set muted(value:Boolean):void
    {
        if (_muted == value)
            return;
        
        _muted = value;
        dispatchEvent(new FlexEvent(FlexEvent.MUTED_CHANGE));
    }
    
    //----------------------------------
    //  volume
    //----------------------------------
    
    // default to 1
    private var _volume:Number = 1;
    
    [Bindable(event="valueCommit")]

    /**
     *  The volume of the video player, specified as a value between 0 and 1.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get volume():Number
    {
        return _volume;
    }
    
    /**
     *  @private
     */
    public function set volume(value:Number):void
    {
        if (_volume == value)
            return;
            
        _volume = value;
        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function clickHandler(event:MouseEvent):void
    {
        super.clickHandler(event);
        
        muted = !muted;
        
        dispatchEvent(new FlexEvent(FlexEvent.MUTED_CHANGE));
    }

}
}
