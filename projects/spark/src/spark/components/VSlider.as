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

[IconFile("FxVSlider.png")]

/**
 *  The FxVSlider class defines a vertical slider component.
 *
 *  @includeExample examples/FxVSliderExample.mxml
 */
public class FxVSlider extends FxSlider
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
    public function FxVSlider()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    /**
     *  The size of the track, which equals the height of the track.
     */
    override protected function get trackSize():Number
        {
        if (track)
        {
            var trackLItem:ILayoutItem = 
                LayoutItemFactory.getLayoutItemFor(track);
            return trackLItem.actualSize.y;
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
        return thumbLItem.actualSize.y;
    }

    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Position the thumb button based on the specified thumb position,
     *  relative to the current Y location of the track
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

            var trackPos:Number = 0;
            var trackLen:Number = 0;
            
            if (track)
            {
                var trackLItem:ILayoutItem = 
                    LayoutItemFactory.getLayoutItemFor(track);
                    
                trackLen = trackLItem.actualSize.y;
                trackPos = trackLItem.actualPosition.y;
            }
            
            thumbLItem.setActualPosition(thumbLItem.actualPosition.x, 
                                         Math.round(trackPos + trackLen - thumbPos
                                         - thumbLItem.actualSize.y)); 
        }
    }
    
    /**
     *  Return the position of the thumb button on a FxVSlider component.
     *  This value is equal to the
     *  track height subtracted by the Y position of the thumb button
     *  relative to the track, and subtracted by the height of the thumb button.
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
        var trackLItem:ILayoutItem = 
            LayoutItemFactory.getLayoutItemFor(track);
        var trackLen:Number = trackLItem.actualSize.y;
        
        var thumbLItem:ILayoutItem = 
            LayoutItemFactory.getLayoutItemFor(thumb);
        var thumbH:Number = thumbLItem.actualSize.y;
    
        return trackLen - localY - thumbH; 
    }
    
    /**
     *  @inheritDoc
     */
    override protected function pointClickToPosition(localX:Number,
                                                     localY:Number):Number
    {
        var thumbLItem:ILayoutItem = 
            LayoutItemFactory.getLayoutItemFor(thumb);
        var thumbH:Number = thumbLItem.actualSize.y; 
        
        return pointToPosition(localX, localY) + (thumbH / 2);
    }
    
}

}