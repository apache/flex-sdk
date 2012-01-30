////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.mobile
{
import mx.core.DPIClassification;

/**
 *  Additional skin class for the Spark ActionBar component for use with a
 *  ViewNavigator inside a Callout component.
 * 
 *  Uses a transparent background instead of a gradient fill.
 *  
 *  @see spark.skins.mobile.ActionBarSkin
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
public class CalloutActionBarSkin extends ActionBarSkin
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    public function CalloutActionBarSkin()
    {
        super();
        
        // remove default background
        borderClass = null;
        
        // shorten ActionBar height visual paddingTop comes from CalloutSkin
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                layoutContentGroupHeight = 54;
                break;
            }
            case DPIClassification.DPI_240:
            {
                layoutContentGroupHeight = 42;
                break;
            }
            default:
            {
                // default DPI_160
                layoutContentGroupHeight = 28;
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // do not draw chromeColor
    }
}
}