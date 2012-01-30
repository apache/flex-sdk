////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.core
{
/**
 *  The ContainerCreationPolicy class defines the constant values
 *  for the <code>destructionPolicy</code> property of spark view
 *  classes.
 *
 *  @see spark.components.supportClasses.ViewNavigatorBase#destructionPolicy
 *  @see spark.components.View#destructionPolicy
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public final class ContainerDestructionPolicy
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The lifespan of the container's children is automatically
     *  managed by the container based on the container's own
     *  heuristic.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const AUTO:String = "auto";
    
    /**
     *  The container never destroys its children.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const NEVER:String = "never";
}
}