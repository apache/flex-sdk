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
 *  The CalloutPosition calss defines the enumeration of 
 *  horizontal and vertical positions of the Callout component
 *  relative to the owner.
 * 
 *  @see spark.components.Callout
 *  @see spark.components.Callout#horizontalPosition
 *  @see spark.components.Callout#verticalPosition
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
public final class CalloutPosition
{
    
    /**
     *  Position the trailing edge of the callout before the leading edge of the owner.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const BEFORE:String = "before";
    
    /**
     *  Position the leading edge of the callout at the leading edge of the owner.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const START:String = "start";
    
    /**
     *  Position the horizontalCenter of the callout to the horizontalCenter of the owner.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const MIDDLE:String = "middle";
    
    /**
     *  Position the trailing edge of the callout at the trailing edge of the owner.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const END:String = "end";
    
    /**
     *  Position the leading edge of the callout after the trailing edge of the owner.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const AFTER:String = "after";
    
    /**
     *  Position the callout on the exterior of the owner where the callout 
     *  requires the least amount of resizing to fit.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const AUTO:String = "auto";
    
}

}