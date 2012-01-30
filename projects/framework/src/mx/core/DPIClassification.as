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
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public final class DPIClassification
{
    /**
     *  Density value for low-density devices.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const DPI_160:Number = 160;

    /**
     *  Density value for medium-density devices.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const DPI_240:Number = 240;

    /**
     *  Density value for high-density devices.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
         */
    public static const DPI_320:Number = 320;
}
}