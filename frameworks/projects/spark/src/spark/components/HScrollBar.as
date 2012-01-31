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

import flash.geom.Point;

/**
 *  The HScrollBar (horizontal ScrollBar) control lets you control
 *  the portion of data that is displayed when there is too much data
 *  to fit horizontally in a display area.
 * 
 *  <p>This control extends the base ScrollBar control.</p> 
 *  
 *  <p>Although you can use the HScrollBar control as a stand-alone control,
 *  you usually combine it as part of another group of components to
 *  provide scrolling functionality.</p>
 */
public class HScrollBar extends ScrollBar
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
    public function HScrollBar()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    /**
     * The size of the track on an HScrollBar equals the width of the track.
     */
    override protected function get trackSize():Number
    {
        if (track)
            return track.width;
        else
           return 0;
    }
    
    /**
     * HScrollBar's thumbSize determines the width of the thumb button.
     * The button's minWidth property acts as a lower bound on this size.
     */
    override protected function set thumbSize(size:Number):void
    {
        super.thumbSize = Math.max(size, thumb.minWidth);
        thumb.width = thumbSize;
    }
    override protected function get thumbSize():Number
    {
        return super.thumbSize; 
    }

    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Position the thumb button according to the given thumbPos parameter,
     * relative to the current x location of the track in the scrollbar control.
     * 
     * @param thumbPos A number representing the new position of the thumb
     * button in the control.
     */
    override protected function positionThumb(thumbPos:Number):void
    {
        if (thumb)
        {
            var trackPos:Number = track ? track.x : 0;   
            thumb.x = trackPos + thumbPos;
        }
    }
    
    /**
     * The position of the thumb on an HScrollBar is equal to the given
     * localX parameter.
     * 
     * @param localX The x position relative to the scrollbar control
     * @param localY The y position relative to the scrollbar control
     */
    override protected function getScrollPosition(localX:Number, 
                                                  localY:Number):Number
    {
        return localX;
    }
}

}
