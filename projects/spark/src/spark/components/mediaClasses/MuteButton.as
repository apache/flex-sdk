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

package spark.components
{

import flash.events.Event;

import mx.events.FlexEvent;

/**
 *  The VideoPlayerVolumeBarMuteButton is a mute button 
 *  to be used inside the VideoPlayerVolumeBar.  The VideoPlayer
 *  hooks it up so that when the button is clicked it'll 
 *  mute/unmute the volume.  This button has a volume property 
 *  so that the visuals of the button can change based on the 
 *  volume.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class VideoPlayerVolumeBarMuteButton extends Button
{   
    	
	/**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
	public function VideoPlayerVolumeBarMuteButton()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
	
    //----------------------------------
    //  value
    //----------------------------------
    
    // default to 1
    private var _value:Number = 1;
    
    [Bindable(event="valueCommit")]

    /**
     *  The volume of the video player.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get value():Number
    {
        return _value;
    }
    
    /**
     *  @private
     */
    public function set value(value:Number):void
    {
        if (_value == value)
            return;
            
        _value = value;
        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }

}
}
