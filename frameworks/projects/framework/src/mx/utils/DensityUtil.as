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
import mx.core.DPIClassification;

[ExcludeClass]

/**
 *  The <code>DensityUtil</code> class is an all-static class with methods for working with
 *  density within Flex.
 * 
 *  Flex uses this class to calculate the scaling factor when automatic density
 *  scaling is enabled for the <code>Application</code>.
 *
 *  @see mx.core.DPIClassification
 *  @see spark.components.Application#applicationDPI 
 */
public class DensityUtil
{
    /**
     *  Matches the specified DPI to a <code>DPIClassification</code> value.
     *
     *  Flex uses this method to calculate the current dpi value when an Application
     *  authored for a specific dpi is adapted to the current one through scaling.
     * 
     *  A number of devices can have slightly different DPI values and Flex maps these
     *  into the several dpi buckets.
     * 
     *  Flex uses the <code>flash.system.Capabilities.screenDPI</code> to calculate the
     *  current device dpi.
     * 
     *  @param dpi The DPI value.  
     *  @return The corresponding <code>DPIClassification</code> value.
     * 
     *  @see #getDPIScale 
     *  @see mx.core.DPIClassification
     */
    public static function classifyDPI(dpi:Number):int
    {
        if (dpi < 200)
            return DPIClassification.DPI_160;
        
        if (dpi <= 280)
            return DPIClassification.DPI_240;
        
        return DPIClassification.DPI_320; 
    }
    
    /**
     *  Calculates a scale factor to be used when element authored for 
     *  <code>sourceDPI</code> is rendered at <code>targetDPI</code>.
     *  
     *  @param sourceDPI The <code>DPIClassification</code> value for which a
     *  resource is optimized.
     * 
     *  @param targetDPI The <code>DPIClassification</code> dpi value at
     *  which a resource is rendered.
     * 
     *  @return The scale factor to be applied to the resource at render time.
     *
     *  @see #classifyDPI
     *  @see mx.core.DPIClassification
     */
    public static function getDPIScale(sourceDPI:int, targetDPI:int):Number
    {
        // Unknown dpi returns NaN
        if ((sourceDPI != DPIClassification.DPI_160 && sourceDPI != DPIClassification.DPI_240 && sourceDPI != DPIClassification.DPI_320) ||
            (targetDPI != DPIClassification.DPI_160 && targetDPI != DPIClassification.DPI_240 && targetDPI != DPIClassification.DPI_320))
        {
            return NaN;
        }

        return Number(targetDPI) / Number(sourceDPI);
    }
}

}