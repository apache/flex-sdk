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
package spark.components
{

import mx.core.DPIClassification;
import mx.core.mx_internal;
    
use namespace mx_internal;

/**
 *  The SpinnerListItemRenderer class defines the default item renderer
 *  for a SpinnerList control in the mobile theme.  
 *  This is a simple item renderer with a single text component.
 * 
 * @see spark.components.SpinnerList
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */ 
public class SpinnerListItemRenderer extends LabelItemRenderer
{
    /**
     *  Constructor.
     *        
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public function SpinnerListItemRenderer()
    {
        super();
        
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                minHeight = 20;
                break;
            }
            case DPIClassification.DPI_240:
            {
                minHeight = 15;
                break;
            }
            default: // default PPI160
            {
                minHeight = 10;
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // draw a transparent background for hit testing
        graphics.beginFill(0x000000, 0);
        graphics.lineStyle();
        graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
        graphics.endFill();
    }
}
}