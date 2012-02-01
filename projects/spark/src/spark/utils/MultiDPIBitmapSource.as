////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.utils
{
import mx.core.DPIClassification;
    
/**
 *  This class provides a list of bitmaps for various runtime densities.  It is supplied
 *  as the source to BitmapImage or Image and as the icon of a Button.  The components
 *  will use the Application.runtimeDPI to choose which image to display.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.2
 *  @playerversion AIR 2.6
 *  @productversion Flex 4.5
 */
public class MultiDPIBitmapSource
{
    include "../core/Version.as";

    /**
     *  The source to use if the Application.runtimeDPI is DPIClassification.DPI_160.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.6
     *  @productversion Flex 4.5
     */
    public var source160dpi:Object;

    /**
     *  The source to use if the Application.runtimeDPI is DPIClassification.DPI_240.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.6
     *  @productversion Flex 4.5
     */
    public var source240dpi:Object;
    
    /**
     *  The source to use if the Application.runtimeDPI is DPIClassification.DPI_320.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.6
     *  @productversion Flex 4.5
     */
    public var source320dpi:Object;
    
    /**
     *  Select one of the sourceXXXdpi properties based on the given DPI.  This
     *  function will handle the fallback to different sourceXXXdpi properties
     *  if the given one is null.  The strategy is to try to choose the next highest
     *  property if it is not null, then return a lower property if not null, then 
     *  just return null.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.6
     *  @productversion Flex 4.5
     */
    public function getSource(desiredDPI:Number):Object
    {
        var source:Object = source160dpi;
        switch (desiredDPI)
        {
            case DPIClassification.DPI_160:
                source = source160dpi;
                if (!source || source == "")
                    source = source240dpi;
                if (!source || source == "")
                    source = source320dpi;
                break;
            case DPIClassification.DPI_240:
                source = source240dpi;
                if (!source || source == "")
                    source = source320dpi;
                if (!source || source == "")
                    source = source160dpi;
                break;
            case DPIClassification.DPI_320:
                source = source320dpi;
                if (!source || source == "")
                    source = source240dpi;
                if (!source || source == "")
                    source = source160dpi;
                break;
        }
        return source;
        
    }
    
}
}