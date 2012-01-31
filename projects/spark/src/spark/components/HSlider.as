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

import flex.intf.ILayoutItem;
import flex.layout.LayoutItemFactory;

/**
 *  HSlider
 */
public class HSlider extends Slider
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
    public function HSlider()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties: Slider
    //
    //--------------------------------------------------------------------------

    /**
     *  The size of the track on an HSlider equals the width
     *  of the track.
     */
    override protected function get trackSize():Number
    {
        if (track)
        {
            var trackLItem:ILayoutItem = 
                LayoutItemFactory.getLayoutItemFor(track);
            return trackLItem.actualSize.x;
        }
        else
           return 0;
    }

    /**
     *  The size of the thumb is equal to the width of the thumb.
     */
    override protected function calculateThumbSize():Number
    {
        var thumbLItem:ILayoutItem = 
            LayoutItemFactory.getLayoutItemFor(thumb);
        return thumbLItem.actualSize.x;
    }

    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Position the thumb button according to the given thumbPos
     *  parameter, relative to the current x location of the track
     *  in the HSlider control.
     * 
     *  @param thumbPos A number representing the new position of
     *  the thumb button in the control.
     */
    override protected function positionThumb(thumbPos:Number):void
    {
        if (thumb)
        {
            var thumbLItem:ILayoutItem = 
                LayoutItemFactory.getLayoutItemFor(thumb);

            var trackLItem:ILayoutItem = 
                LayoutItemFactory.getLayoutItemFor(track);
            var trackPos:Number = trackLItem.actualPosition.x;

            thumbLItem.setActualPosition(Math.round(trackPos + thumbPos),
                                         thumbLItem.actualPosition.y);
        }
    }
    
    /**
     *  The position of the thumb on an HSlider is equal to the
     *  given localX parameter.
     * 
     *  @param localX The x position relative to the track
     *  @param localY The y position relative to the track
     */
    override protected function pointToPosition(localX:Number, 
                                                localY:Number):Number
    {
        return localX;
    }

    /**
     *  We adjust the position to center the thumb when clicking
     *  on the track.
     */
    override protected function pointClickToPosition(localX:Number,
                                                     localY:Number):Number
    {
        var thumbLItem:ILayoutItem = 
            LayoutItemFactory.getLayoutItemFor(thumb);
        return pointToPosition(localX, localY) - thumbLItem.actualSize.x / 2;
    }
}

}