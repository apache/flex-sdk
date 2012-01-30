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

package mx.charts.series.renderData
{

import mx.charts.chartClasses.RenderData

/**
 *  Represents all the information needed by the BubbleSeries to render.  
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class BubbleSeriesRenderData extends RenderData
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
     *  @param cache The list of BubbleSeriesItem objects representing the items in the dataProvider.
     *  @param filteredCache The list of BubbleSeriesItem objects representing the items in the dataProvider that remain after filtering.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function BubbleSeriesRenderData(cache:Array /* of BubbleSeriesItem */ = null,
                                           filteredCache:Array /* of BubbleSeriesItem */ = null)
    {
        super(cache, filteredCache);

    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function clone():RenderData
    {
        return new BubbleSeriesRenderData(cache, filteredCache);
    }
}

}
