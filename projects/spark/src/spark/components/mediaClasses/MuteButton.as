////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
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
 *  Dispatched when the video mutes or unmutes the volume
 *  from user-interaction.
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
 *  The MuteButton is a mute button. The VideoPlayer
 *  hooks it up so that when the button is clicked it'll 
 *  mute/unmute the volume.  This button has a volume property 
 *  and a mute property so that the visuals of the button can 
 *  change based on them.
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
     *  <code>true</code> if the volume of the video is muted; 
     *  <code>false</code> otherwise.
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
     *  The volume of the video player.
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
    
    override protected function clickHandler(event:MouseEvent):void
    {
        super.clickHandler(event);
        
        muted = !muted;
        
        dispatchEvent(new FlexEvent(FlexEvent.MUTED_CHANGE));
    }

}
}
