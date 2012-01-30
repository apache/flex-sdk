////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.utils
{
import mx.core.DeviceDensity;

/**
 *  The <code>DensityUtil</code> class is an all-static class with methods for working with
 *  density within Flex.
 * 
 *  Flex uses this class to calculate the scaling factor when automatic density
 *  scaling is enabled for the <code>Application</code>.
 *
 *  @see mx.core.DeviceDensity
 *  @see spark.components.Appliction#authorDensity 
 *  @see mx.core.ISystemManager#densityScale
 */
public class DensityUtil
{
    /**
     *  Matches the specified DPI to <code>DeviceDensity</code> value.
     *
     *  Flex uses this method to calculate the current density value when an Application
     *  authored for a specific density is adapted to the current one through scaling.
     * 
     *  A number of devices can have slightly different DPI values and Flex maps these
     *  into the several density buckets.
     * 
     *  Flex uses the <code>flash.system.Capabilities.screenDPI</code> to calculate the
     *  current device density.
     * 
     *  @param dpi The DPI value.  
     *  @return The corresponding <code>DeviceDensity</code> value.
     * 
     *  @see #getDensityScale 
     *  @see mx.core.DeviceDensity
     *  @see spark.components.Appliction#authorDensity
     *  @see mx.core.ISystemManager#densityScale
     */
    public static function screenDPIToDeviceDensity(dpi:Number):String
    {
        if (dpi < 200)
            return DeviceDensity.PPI_160;
        
        if (dpi <= 280)
            return DeviceDensity.PPI_240;
        
        return DeviceDensity.PPI_320; 
    }
    
    /**
     *  Calculates a scale factor to be used when element authored for 
     *  <code>sourceDensity</code> is rendered at <code>targetDensity</code>.
     *  
     *  @param sourceDensity The <code>DeviceDensity</code> value for which a
     *  resource is optimized.
     * 
     *  @param targetDensity The <code>DeviceDensity</code> density value at
     *  which a resource is rendered.
     * 
     *  @return The scale factor to be applied to the resource at render time.
     *
     *  @see #screenDPIToDeviceDensity
     *  @see mx.core.DeviceDensity
     *  @see spark.components.Appliction#authorDensity
     *  @see mx.core.ISystemManager#densityScale
     */
    public static function getDensityScale(sourceDensity:String, targetDensity:String):Number
    {
        // Unknown density returns NaN
        if ((sourceDensity != DeviceDensity.PPI_160 && sourceDensity != DeviceDensity.PPI_240 && sourceDensity != DeviceDensity.PPI_320) ||
            (targetDensity != DeviceDensity.PPI_160 && targetDensity != DeviceDensity.PPI_240 && targetDensity != DeviceDensity.PPI_320))
        {
            return NaN;
        }

        var density2Index:Function = function (density:String):int
        {
            return (density == DeviceDensity.PPI_160) ? 0 :
                   (density == DeviceDensity.PPI_240) ? 1 : 2;
        }

        var sourceIndex:int = density2Index(sourceDensity);
        var targetIndex:int = density2Index(targetDensity);
        
        var scale:Number = scaleTable[ sourceIndex ][ targetIndex ];
        return scale;
    }
    
    /**
     *  @private
     *  Scale table for the getDensityScale() method 
     */
    private static const scaleTable:Array = [[ 160 / 160 /* 160 -> 160 */, 240 / 160 /* 160 -> 240*/, 320 / 160 /* 160 -> 320*/], 
                                             [ 160 / 240 /* 240 -> 160 */, 240 / 240 /* 240 -> 240*/, 320 / 240 /* 240 -> 320*/],
                                             [ 160 / 320 /* 320 -> 160 */, 240 / 320 /* 320 -> 240*/, 320 / 320 /* 320 -> 320*/]];
}

}