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

package mx.components
{

/**
 *  The ResizeMode class defines an enumeration of the modes 
 *  a component uses to resize its children in the dimensions
 *  specified by the layout system.
 *
 *  <p>The component can change it's own dimensions (<code>width</code> and <code>height</code>)
 *  and relayout its children appropriately (this is the default resize mode).</p>
 *
 *  <p>Alternative option for the component is to change its scale, in which case
 *  the children don't need to change at all. This is supported by <code>Group</code>.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public final class ResizeMode
{
    /**
     *  Resize by changing <code>width</code> and <code>height</code>.
     *
     *  <p>The component always sizes itself, and then lays out 
     *  its children at the actual size specified by the layout or the user.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const NORMAL:String = "normal";

    /**
     *  Resize by setting the <code>scaleX</code> 
     *  and <code>scaleY</code> properties.
     *
     *  <p>The component always sizes itself, and then lays out 
     *  Its children at its measured size. 
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