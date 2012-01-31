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
import mx.components.baseClasses.FxTextBase;
import mx.components.baseClasses.FxScrollBar;
import mx.layout.ILayoutItem;
import mx.layout.LayoutItemFactory;
/**
 *  The FxHScrollBar (horizontal ScrollBar) control lets you control
 *  the portion of data that is displayed when there is too much data
 *  to fit horizontally in a display area.
 * 
 *  <p>This control extends the base ScrollBar control.</p> 
 *  
 *  <p>Although you can use the FxHScrollBar control as a stand-alone control,
 *  you usually combine it as part of another group of components to
 *  provide scrolling functionality.</p>
 */
public class FxHScrollBar extends FxScrollBar
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
    public function FxHScrollBar()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    /**
     *  The size of the track on an FxHScrollBar equals the width of the track.
     */
    override protected function get trackSize():Number
    {
        if (track)
            return track.width;
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
     *  relative to the current x location of the track in the scrollbar control.
     * 
     *  @param thumbPos A number representing the new position of the thumb
     *  button in the control.
     */
    override protected function positionThumb(thumbPos:Number):void
    {
        if (thumb)
        {
            var trackPos:Number = track ? track.x : 0;   
            var layoutItem:ILayoutItem = LayoutItemFactory.getLayoutItemFor(thumb);
            layoutItem.setActualPosition(Math.round(trackPos + thumbPos),
            					    	 layoutItem.actualPosition.y);
        }
    }
    
    /**
     *  @private
     */
    override protected function calculateThumbSize():Number
    {
        return Math.max(thumb.minWidth, super.calculateThumbSize());
    }

    /**
     *  @private
     */
    override protected function sizeThumb(thumbSize:Number):void
    {
        thumb.width = thumbSize;
    }
    
    /**
     *  The position of the thumb on an FxHScrollBar is equal to the given
     *  localX parameter.
     * 
     *  @param localX The x position relative to the scrollbar control
     *  @param localY The y position relative to the scrollbar control
     */
    override protected function pointToPosition(localX:Number, 
                                                localY:Number):Number
    {
        return localX;
    }
}

}