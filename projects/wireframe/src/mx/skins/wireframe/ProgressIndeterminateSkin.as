////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2004-2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.skins.wireframe
{

import flash.display.Graphics;
import mx.skins.Border;
import mx.styles.StyleManager;
import mx.utils.ColorUtil;

/**
 *  The wireframe skin for the indeterminate state of the MX ProgressBar component.
 *  
 *  @see mx.controls.ProgressBar
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ProgressIndeterminateSkin extends Border
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
	public function ProgressIndeterminateSkin()
	{
		super();
	}	

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
	//  measuredWidth
    //----------------------------------
    
    /**
     *  @private
     */    
    override public function get measuredWidth():Number
    {
        return 195;
    }
    
    //----------------------------------
	//  measuredHeight
    //----------------------------------
    
    /**
     *  @private
     */        
    override public function get measuredHeight():Number
    {
        return 6;
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
		
		// User-defined styles
		var hatchInterval:Number = getStyle("indeterminateMoveInterval");
		
		if (isNaN(hatchInterval))
			hatchInterval = 28;

		var g:Graphics = graphics;
		
		g.clear();
		
		// Hatches
		for (var i:int = 0; i < w; i += hatchInterval)
		{
			g.beginFill(0xEEEEEE, 1);
			g.moveTo(i, 1);
			g.lineTo(Math.min(i + 7, w), 2);
			g.lineTo(Math.min(i + 3, w), h - 2);
			g.lineTo(Math.max(i - 4, 0), h - 2);
			g.lineTo(i, 1);
			g.endFill();
			g.lineStyle(1, 0xFFFFFF, 1);
			
		}
	}
}

}
