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

package mx.charts.effects
{

import mx.charts.effects.effectClasses.SeriesInterpolateInstance;

/**
 *  The SeriesInterpolate effect moves the graphics that represent
 *  the existing data in a series to the new points.
 *  Instead of clearing the chart and then repopulating it
 *  as with SeriesZoom and SeriesSlide,
 *  this effect keeps the data on the screen at all times.
 *
 *  <p>You only use the SeriesInterpolate effect
 *  with a <code>showDataEffect</code> effect trigger.
 *  It has no effect if set with a <code>hideDataEffect</code>.</p>
 *
 *  @includeExample examples/SeriesInterpolateExample.mxml
 *
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class SeriesInterpolate extends SeriesEffect
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
     *  @param target The target of the effect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function SeriesInterpolate(target:Object = null)
    {
        super(target);

        instanceClass = SeriesInterpolateInstance;
    }
}

}
