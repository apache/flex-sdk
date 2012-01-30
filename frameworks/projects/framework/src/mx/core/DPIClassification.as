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

package mx.core
{

/**
 *  An enum of the device screen density classess.  
 *
 *  When working with density, Flex collapses similar DPIs into density classes.
 *
 *  @see spark.components.Appliction#authorDensity
 *  @see mx.core.DensityUtil
 */
public final class DeviceDensity
{
    /**
     *  Density value for low-density devices.
     */
    public static const PPI_160:String = "160ppi";

    /**
     *  Density value for medium-density devices.
     */
    public static const PPI_240:String = "240ppi";

    /**
     *  Density value for high-density devices.
     */
    public static const PPI_320:String = "320ppi";
}
}