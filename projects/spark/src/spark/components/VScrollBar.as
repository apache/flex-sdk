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
import flex.intf.ILayoutItem;
import flex.layout.LayoutItemFactory;
	

/**
 *  The VScrollBar (vertical ScrollBar) control lets you control
 *  the portion of data that is displayed when there is too much data
 *  to fit vertically in a display area.
 * 
 *  <p>This control extends the base ScrollBar control.</p> 
 *  
 *  <p>Although you can use the VScrollBar control as a stand-alone control,
 *  you usually combine it as part of another group of components to
 *  provide scrolling functionality.</p>
 */
public class VScrollBar extends ScrollBar
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
    public function VScrollBar()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    /**
     *  The size of the track on a VScrollBar equals the height of the track.
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
     *  relative to the current y location of the track in the scrollbar control.
     * 
     *  @param thumbPos A number representing the new position of the thumb
     *  button in the control.
     */
    override protected function positionThumb(thumbPos:Number):void
    {
        if (thumb)
        {
            var trackPos:Number = track ? track.y : 0;
            var layoutItem:ILayoutItem = LayoutItemFactory.getLayoutItemFor(thumb);
            layoutItem.setActualPosition(layoutItem.actualPosition.x,
            					    	 Math.round(trackPos + thumbPos));
        }
    }

    /**
     *  @private
     */
    override protected function calculateThumbSize():Number
    {
        return Math.max(thumb.minHeight, super.calculateThumbSize());
    }

    /**
     *  @private
     */
    override protected function sizeThumb(thumbSize:Number):void
    {
        thumb.height = thumbSize;
    }
    
    /**
     *  The position of the thumb on a VScrollBar is equal to the given
     *  localY parameter.
     * 
     *  @param localX The x position relative to the scrollbar control
     *  @param localY The y position relative to the scrollbar control
     */
    override protected function pointToPosition(localX:Number, 
                                                localY:Number):Number
    {
        return localY;
    }
}

}