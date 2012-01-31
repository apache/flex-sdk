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

package spark.components
{

/**
 *  The ResizeMode class defines an enumeration of the modes 
 *  a component uses to resize its children in the dimensions
 *  specified by the layout system.
 *
 *  <p>The component can change its own dimensions (<code>width</code> and <code>height</code>)
 *  and re-layout its children appropriately (this is the default resize mode).</p>
 *
 *  <p>An alternative option for the component is to change its scale, in which case
 *  the children don't need to change at all. This option is supported by <code>Group</code>.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public final class ResizeMode
{
    /**
     *  Resizes by changing the <code>width</code> and <code>height</code>.
     *
     *  <p>The component always sizes itself and then lays out 
     *  its children at the actual size specified by the layout or the user.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const NO_SCALE:String = "noScale";

    /**
     *  Resizes by setting the <code>scaleX</code> 
     *  and <code>scaleY</code> properties.
     *
     *  <p>The component always sizes itself and then lays out 
     *  its children at its measured size. 
     *  The scale is adjusted to match the specified size by the layout or the user.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const SCALE:String = "scale";
}

}