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

import mx.charts.chartClasses.RenderData;

/**
 *  Represents all the information needed by the BarSeries to render.  
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class BarSeriesRenderData extends RenderData
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
     *  @param cache The list of BarSeriesItem objects representing the items in the dataProvider
     *  @param filteredCache The list of BarSeriesItem objects representing the items in the dataProvider that remain after filtering.
     *  @param renderedBase The horizontal position of the base of the bars, in pixels.
     *  @param renderedHalfWidth Half the width of a bar, in pixels.
     *  @param renderedYOffset The offset of each bar from its y value, in pixels.
     *  @param labelScale The scale factor of the labels rendered by the bar series.
     *  @param labelData A structure of data associated with the layout of the labels rendered by the bar series.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function  BarSeriesRenderData(cache:Array /* of BarSeriesItem */ = null,
                                         filteredCache:Array /* of BarSeriesItem */ = null,
                                         renderedBase:Number = 0,
                                         renderedHalfWidth:Number = 0,
                                         renderedYOffset:Number = 0,
                                         labelScale:Number = 1,
                                         labelData:Object = null) 
    {       
        super(cache, filteredCache);

        this.renderedBase = renderedBase;
        this.renderedHalfWidth = renderedHalfWidth;
        this.renderedYOffset = renderedYOffset;
        this.labelScale = labelScale;
        this.labelData = labelData;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  labelData
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  A structure of data associated with the layout of the labels rendered by the bar series.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var labelData:Object;
    
    //----------------------------------
    //  labelScale
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  The scale factor of the labels rendered by the bar series.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var labelScale:Number;
    
    //----------------------------------
    //  renderedBase
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  The horizontal position of the base of the bars, in pixels.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var renderedBase:Number;

    //----------------------------------
    //  renderedHalfWidth
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  Half the width of a bar, in pixels.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var renderedHalfWidth:Number;

    //----------------------------------
    //  renderedYOffset
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  The offset of each bar from its y value, in pixels.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var renderedYOffset:Number;

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
        return new BarSeriesRenderData(cache, filteredCache, renderedBase,
                                       renderedHalfWidth, renderedYOffset,
                                       labelScale,labelData);
    }
}

}
