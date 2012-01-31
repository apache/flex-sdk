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

import flash.display.DisplayObject;
import flash.geom.Point;

import mx.components.baseClasses.FxSlider;
import mx.core.UIComponent;
import mx.core.ILayoutElement;
import mx.layout.LayoutElementFactory;

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
            var trackLElement:ILayoutElement = 
                LayoutElementFactory.getLayoutElementFor(track);
            return trackLElement.getLayoutBoundsHeight();
        }
        else
           return 0;
    }
    
    /**
     *  The size of the thumb button, which equals the height of the thumb button.
     */
    override protected function calculateThumbSize():Number
    {
        var thumbLElement:ILayoutElement = 
            LayoutElementFactory.getLayoutElementFor(thumb);
        return thumbLElement.getLayoutBoundsHeight();
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
            var thumbLElement:ILayoutElement = 
                LayoutElementFactory.getLayoutElementFor(thumb);

            var trackPos:Number = 0;
            var trackLen:Number = 0;
            
            if (track)
            {
                var trackLElement:ILayoutElement = 
                    LayoutElementFactory.getLayoutElementFor(track);
                    
                trackLen = trackLElement.getLayoutBoundsHeight();
                trackPos = trackLElement.getLayoutBoundsY();
            }
            
            thumbLElement.setLayoutBoundsPosition(thumbLElement.getLayoutBoundsX(), 
                                         Math.round(trackPos + trackLen - thumbPos
                                         - thumbLElement.getLayoutBoundsHeight())); 
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
        var trackLElement:ILayoutElement = 
            LayoutElementFactory.getLayoutElementFor(track);
        var trackLen:Number = trackLElement.getLayoutBoundsHeight();
        
        var thumbLElement:ILayoutElement = 
            LayoutElementFactory.getLayoutElementFor(thumb);
        var thumbH:Number = thumbLElement.getLayoutBoundsHeight();
    
        return trackLen - localY - thumbH; 
    }
    
    /**
     *  @inheritDoc
     */
    override protected function pointClickToPosition(localX:Number,
                                                     localY:Number):Number
    {
        var thumbLElement:ILayoutElement = 
            LayoutElementFactory.getLayoutElementFor(thumb);
        var thumbH:Number = thumbLElement.getLayoutBoundsHeight(); 
        
        return pointToPosition(localX, localY) + (thumbH / 2);
    }
    
    /**
     *  @private
     */
    override protected function positionDataTip():void
    {
    	var tipAsDisplayObject:DisplayObject = dataTipInstance as DisplayObject;
    	
    	if (tipAsDisplayObject)
    	{
			var relY:Number = thumb.y + (thumb.height - tipAsDisplayObject.height) / 2;
	        var o:Point = new Point(dataTipOriginalPosition.x, relY);
	        var r:Point = localToGlobal(o);        
			r = tipAsDisplayObject.parent.globalToLocal(r);
			
			// TODO (jszeto) Change to use ILayoutElement.setLayoutBoundsPosition?
        	tipAsDisplayObject.x = Math.floor(r.x < 0 ? 0 : r.x);
        	tipAsDisplayObject.y = Math.floor(r.y < 0 ? 0 : r.y);
    	}
    }
    
}

}