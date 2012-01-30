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

package mx.charts.renderers
{

import mx.charts.chartClasses.GraphicsUtilities;
import mx.core.IDataRenderer;
import mx.graphics.IStroke;
import mx.skins.ProgrammaticSkin;

/**
 *  A simple implementation of a line segment renderer
 *  that is used by LineSeries objects.
 *  This class renders a line on screen using the stroke and form defined by
 *  the owning series's <code>lineStroke</code> and <code>form</code> styles,
 *  respectively.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class LineRenderer extends ProgrammaticSkin implements IDataRenderer
{
    include "../../core/Version.as";

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
	public function LineRenderer() 
	{
		super();
	}

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
	//  data
    //----------------------------------

	/**
	 *  @private
	 *  Storage for the data property.
	 */
	private var _data:Object;
	
	[Inspectable(environment="none")]

	/**
	 *  The chart item that this renderer represents.
	 *  LineRenderers assume that this value is an instance of LineSeriesItem.
	 *  This value is assigned by the owning series.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get data():Object
	{
		return _data;
	}

	/**
	 *  @private
	 */
	public function set data(value:Object):void
	{
		_data = value;

		invalidateDisplayList();
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

		var stroke:IStroke = getStyle("lineStroke");		
		var form:String = getStyle("form");

		graphics.clear();

		GraphicsUtilities.drawPolyLine(graphics, _data.items,
									   _data.start, _data.end + 1,"x","y",
									   stroke,form);

	}
}

}
