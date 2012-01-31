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
 */
public final class ResizeMode
{
    /**
     *  @private
     */
    public static const _NORMAL_UINT:uint = 0;
    /**
     *  Resize by changing <code>width</code> and <code>height</code>.
     *
     *  <p>The component always sizes itself, and then lays out 
     *  its children at the actual size specified by the layout or the user.</p>
     */
    public static const NORMAL:String = "Normal";

    /**
     *  @private
     */
    public static const _SCALE_UINT:uint = 1;
    /**
     *  Resize by setting the <code>scaleX</code> 
     *  and <code>scaleY</code> properties.
     *
     *  <p>The component always sizes itself, and then lays out 
     *  Its children at its measured size. 
     *  The scale is adjusted to match the specified size by the layout or the user.</p>
     */
    public static const SCALE:String = "Scale";

    /**
     *  Converts from the <code>String</code> to the <code>uint</code>
     *  representation of the enumeration value.
     *
     *  @param value The String representation of the enumeration.
     *
     *  @return The uint value corresponding to the String.
     */
    public static function toUINT(value:String):uint
    {
        if (value == SCALE)
            return _SCALE_UINT;
        return _NORMAL_UINT;
    }

    /**
     *  Converts from the <code>uint</code> to the <code>String</code>
     *  representation of the enumeration values.
     *
     *  @param value The uint value of the enumeration. 
     *
     *  @return The String corresponding to the uint value.
     */
    public static function toString(value:uint):String
    {
        if (value == _SCALE_UINT)
            return SCALE;
        return NORMAL;
    }
}

}