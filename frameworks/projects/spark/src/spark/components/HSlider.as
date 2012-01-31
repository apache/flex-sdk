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

package spark.components
{

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;

import spark.components.supportClasses.Slider;
import mx.core.ILayoutElement;

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("HSlider.png")]
[DefaultTriggerEvent("change")]

/**
 *  The HSlider class defines a horizontal slider component.
 *
 *  @includeExample examples/HSliderExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  The size of the track, which equals the width of the track.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function get trackSize():Number
    {
        return track ? track.getLayoutBoundsWidth() : 0;
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
        return thumb ? thumb.getLayoutBoundsWidth() : 0;
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
            var trackPos:Number = track.getLayoutBoundsX();
            thumb.setLayoutBoundsPosition(Math.round(trackPos + thumbPos),
                                          thumb.getLayoutBoundsY());
        }
    }
    
    /**
     *  Return the position of the thumb button on a HSlider component.
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
        return pointToPosition(localX, localY) - thumb.getLayoutBoundsWidth() / 2;
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
			
			// Get the screen bounds
			var screenBounds:Rectangle = systemManager.getVisibleApplicationRect();
			// Get the tips bounds. We only care about the dimensions.
			var tipBounds:Rectangle = tipAsDisplayObject.getBounds(tipAsDisplayObject.parent);
			
			// Make sure the tip doesn't exceed the bounds of the screen
			r.x = Math.floor( Math.max(screenBounds.left, 
							  	Math.min(screenBounds.right - tipBounds.width, r.x)));
			r.y = Math.floor( Math.max(screenBounds.top, 
								Math.min(screenBounds.bottom - tipBounds.height, r.y)));
			
			r = tipAsDisplayObject.parent.globalToLocal(r);
			
        	tipAsDisplayObject.x = r.x;
        	tipAsDisplayObject.y = r.y;
    	}
    }
}

}
