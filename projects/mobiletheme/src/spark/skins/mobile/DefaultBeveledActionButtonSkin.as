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
import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  Emphasized button uses accentColor instead of chromeColor. Replaces the
 *  BeveledNavigationButtonSkin.
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
public class DefaultBeveledActionButtonSkin extends BeveledActionButtonSkin
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function DefaultBeveledActionButtonSkin()
    {
        super();
        
        fillColorStyleName = "accentColor";
    }
}
}