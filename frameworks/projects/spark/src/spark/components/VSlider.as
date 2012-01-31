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
     *  The size of the track on an VSlider equals the height 
     *  of the track.
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
     *  The size of the thumb is equal to the height of the thumb.
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
     *  Position the thumb button according to the given thumbPos
     *  parameter, relative to the current y location of the track
     *  in the VSlider control.
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
                                         trackPos + trackLen - thumbPos
                                         - thumbLItem.actualSize.y); 
        }
    }
    
    /**
     *  The position of the thumb on a VSlider is equal to the
     *  track height subtracted by the y position of the thumb
     *  (relative to the track) and the height of the thumb.
     *  This is because we want the thumb to start at the 
     *  bottom by default.
     * 
     *  @param localX The x position relative to the track
     *  @param localY The y position relative to the track
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
     *  We adjust the position to center the thumb when clicking
     *  on the track.
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