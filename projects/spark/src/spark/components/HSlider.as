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

package mx.components
{
    
import flash.geom.Point;

import mx.layout.ILayoutItem;
import mx.layout.LayoutItemFactory;
import mx.components.baseClasses.FxSlider;

[IconFile("FxHSlider.png")]

/**
 *  The FxHSlider class defines a horizontal slider component.
 *
 *  @includeExample examples/FxHSliderExample.mxml
 */
public class FxHSlider extends FxSlider
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
    public function FxHSlider()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties: Slider
    //
    //--------------------------------------------------------------------------

    /**
     *  The size of the track, which equals the width of the track.
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
     *  The size of the thumb button, which equals the height of the thumb button.
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
     *  Position the thumb button based on the specified thumb position,
     *  relative to the current X location of the track
     *  in the control.
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
     *  Return the position of the thumb button on a FxHSlider component.
     *  The position of the thumb on an HSlider is equal to the
     *  given localX parameter.
     * 
     *  @param localX The x position relative to the track.
     * 
     *  @param localY The y position relative to the track.
     *
     *  @return The position of the thumb button.
     */
    override protected function pointToPosition(localX:Number, 
                                                localY:Number):Number
    {
        return localX;
    }

    /**
     *  @inheritDoc
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