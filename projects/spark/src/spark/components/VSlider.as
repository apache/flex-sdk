////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package flex.component
{

/**
 *  VSlider
 */
public class VSlider extends Slider
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */
    public function VSlider()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    /**
     * The size of the track on an VSlider equals the height of the track.
     */
    override protected function get trackSize():Number
    {
        if (track)
            return track.height;
        else
           return 0;
    }

    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Position the thumb button according to the given thumbPos parameter,
     *  relative to the current y location of the track in the VSlider control.
     * 
     *  @param thumbPos A number representing the new position of the thumb
     *  button in the control.
     */
    override protected function positionThumb(thumbPos:Number):void
    {
        if (thumb)
        {
            var trackPos:Number = track ? track.y : 0;   
            thumb.y = trackPos + track.height - thumbPos; 
        }
    }
    
    /**
     *  The position of the thumb on an HSlider is equal to the track
     *  height minus the difference between localY and the track
     *  position. This is because we want the thumb to start
     *  at the bottom by default.
     * 
     *  @param localX The x position relative to the HSlider control
     *  @param localY The y position relative to the HSlider control
     */
    override protected function pointToPosition(localX:Number, 
                                                localY:Number):Number
    {
        return track.height - (localY - track.y);
    }
}

}
