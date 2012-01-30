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
 *  When working with DPI, Flex collapses similar DPI values into DPI classes.
 *
 *  @see spark.components.Application#applicationDPI
 *  @see spark.components.Application#runtimeDPI
 */
public final class DPIClassification
{
    /**
     *  Density value for low-density devices.
     */
    public static const DPI_160:int = 160;

    /**
     *  Density value for medium-density devices.
     */
    public static const DPI_240:int = 240;

    /**
     *  Density value for high-density devices.
     */
    public static const DPI_320:int = 320;
}
}