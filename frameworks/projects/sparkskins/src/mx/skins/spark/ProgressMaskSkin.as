////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.skins.spark
{

import flash.display.Graphics;
import mx.skins.ProgrammaticSkin;

/**
 *  The Spark skin for the mask of the MX ProgressBar component's determinate and indeterminate bars.
 *  The mask defines the area in which the progress bar or 
 *  indeterminate progress bar is displayed.
 *  By default, the mask defines the progress bar to be inset 1 pixel from the track.
 *
 *  @see mx.controls.ProgressBar
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ProgressMaskSkin extends ProgrammaticSkin
{        
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
    public function ProgressMaskSkin()
    {
        super();
    }

     //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */        
    override protected function updateDisplayList(w:Number, h:Number):void
    {
        super.updateDisplayList(w, h);

        // draw the mask
        var g:Graphics = graphics;
        g.clear();
        g.beginFill(0xFFFF00);
        g.drawRect(2, 1, w - 4, h - 2);
        g.endFill();
    }


}

}       