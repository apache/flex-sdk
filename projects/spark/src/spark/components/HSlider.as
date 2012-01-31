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
import mx.core.ILayoutElement;
import mx.layout.LayoutElementFactory;

[IconFile("FxHSlider.png")]

/**
 *  The FxHSlider class defines a horizontal slider component.
 *
 *  @includeExample examples/FxHSliderExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function get trackSize():Number
    {
        return track ? LayoutElementFactory.getLayoutElementFor(track).getLayoutBoundsWidth() : 0;
    }

    /**
     *  The size of the thumb button, which equals the height of the thumb button.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function calculateThumbSize():Number
    {
        return LayoutElementFactory.getLayoutElementFor(thumb).getLayoutBoundsWidth();
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function positionThumb(thumbPos:Number):void
    {
        if (thumb)
        {
            var thumbLElement:ILayoutElement = 
                LayoutElementFactory.getLayoutElementFor(thumb);

            var trackLElement:ILayoutElement = 
                LayoutElementFactory.getLayoutElementFor(track);
            var trackPos:Number = trackLElement.getLayoutBoundsX();

            thumbLElement.setLayoutBoundsPosition(Math.round(trackPos + thumbPos),
                                                  thumbLElement.getLayoutBoundsY());
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function pointToPosition(localX:Number, 
                                                localY:Number):Number
    {
        return localX;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function pointClickToPosition(localX:Number,
                                                     localY:Number):Number
    {
        var thumbLElement:ILayoutElement = 
            LayoutElementFactory.getLayoutElementFor(thumb);
        return pointToPosition(localX, localY) - thumbLElement.getLayoutBoundsWidth() / 2;
    }
    
    /**
     *  @private
     */
    override protected function positionDataTip():void
    {
    	var tipAsDisplayObject:DisplayObject = dataTipInstance as DisplayObject;
    	
    	if (tipAsDisplayObject)
    	{
			var relX:Number = thumb.x - (tipAsDisplayObject.width - thumbSize) / 2;
	        var o:Point = new Point(relX, dataTipOriginalPosition.y);
	        var r:Point = localToGlobal(o);        
			r = tipAsDisplayObject.parent.globalToLocal(r);
			
			// TODO (jszeto) Change to use ILayoutElement.setLayoutBoundsPosition?
        	tipAsDisplayObject.x = Math.floor(r.x < 0 ? 0 : r.x);
        	tipAsDisplayObject.y = Math.floor(r.y < 0 ? 0 : r.y);
    	}
    }
}

}