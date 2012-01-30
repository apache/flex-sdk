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

/**
 *  The ContentBackgroundAppearance class defines the constants for the
 *  allowed values of the <code>contentBackgroundAppearance</code> style of 
 *  Callout.
 * 
 *  @see spark.components.Callout#style:contentBackgroundAppearance
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
public final class ContentBackgroundAppearance
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Applies a shadow and mask to the contentGroup.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const INSET:String = "inset";
    
    /**
     *  Applies mask to the contentGroup.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const FLAT:String = "flat";
    
    /**
     *  Disables both the <code>contentBackgroundColor</code> style and
     *  contentGroup masking. Use this value when Callout's contents should
     *  appear directly on top of the <code>backgroundColor</code> or when
     *  contents provide their own masking. 
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const NONE:String = "none";
}
}