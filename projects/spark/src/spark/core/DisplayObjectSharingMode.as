////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package spark.core
{
/**
 *  The DisplayObjectSharingMode class defines the possible values for the 
 *  <code>displayObjectSharingMode</code> property of the IGraphicElement class.
 * 
 *  @see IGraphicElement#displayObjectSharingMode
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public final class DisplayObjectSharingMode
{   
    /**
     *  IGraphicElement owns a DisplayObject exclusively.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const OWNS_UNSHARED_OBJECT:String = "ownsUnsharedObject";
    
    /**
     *  IGraphicElement owns a DisplayObject that is also
     *  assigned to some other IGraphicElement by the parent
     *  Group container.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const OWNS_SHARED_OBJECT:String = "ownsSharedObject";
    
    /**
     *  IGraphicElement is assigned a DisplayObject by
     *  its parent Group container.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const USES_SHARED_OBJECT:String = "usesSharedObject";
}
}
