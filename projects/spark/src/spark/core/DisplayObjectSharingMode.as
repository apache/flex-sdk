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
 *  Enumerated type for the IGraphicElement's <code>displayObjectSharingMode</code>
 *  property.
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
     *  Such <code>IGraphicElement</code> owns a DisplayObject exclusively.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const OWNS_UNSHARED_OBJECT:String = "ownsUnsharedObject";
    
    /**
     *  Such <code>IGraphicElement</code> owns a DisplayObject that is also
     *  assigned to some other <code>IGraphicElement</code> by the parent
     *  <code>Group</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const OWNS_SHARED_OBJECT:String = "ownsSharedObject";
    
    /**
     *  Such <code>IGraphicElement</code> is assigned a DisplayObject by
     *  its parent <code>Group</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const USES_SHARED_OBJECT:String = "usesSharedObject";
}
}
