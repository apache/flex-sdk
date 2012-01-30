////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.charts.skins.halo
{

import flash.display.Graphics;
import flash.geom.Rectangle;
import mx.charts.chartClasses.GraphicsUtilities;
import mx.graphics.IFill;
import mx.graphics.IStroke;
import mx.skins.ProgrammaticSkin;

/**
 *  @private
 */
public class SelectionSkin extends ProgrammaticSkin
{
    include "../../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function SelectionSkin() 
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
	override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);

		var fill:IFill =
			GraphicsUtilities.fillFromStyle(getStyle("selectionFill"));
		var stroke:IStroke = getStyle("selectionStroke");
				
		var w:Number = stroke ? stroke.weight / 2 : 0;
		var rc:Rectangle = new Rectangle(w, w, width - 2 * w, height - 2 * w);
		
		var g:Graphics = graphics;
		g.clear();		
		g.moveTo(rc.left, rc.top);
		if (stroke)
			stroke.apply(g);
		if (fill)
			fill.begin(g, rc);
		g.lineTo(rc.right, rc.top);
		g.lineTo(rc.right, rc.bottom);
		g.lineTo(rc.left, rc.bottom);
		g.lineTo(rc.left, rc.top);
		if (fill)
			fill.end(g);
	}
}

}
