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

package flex.core
{

/**
 *  An enum of the modes a component fills in the dimensions
 *  specified by the layout system.
 *
 *  For a given size the component may change it's own dimensions (width and height)
 *  and re-layout its children appropriately (this is the default resize mode).
 *
 *  Alternative option for the component is to change its scale, in which case
 *  the children don't need to change at all. This is supported by <code>Group</code>.
 */
public final class ResizeMode
{
    /**
     *  Resize by changing width and height.
     *
     *  Component always sizes itself and lays out its children at the actual
     *  size specified by the layout or the user.
     */
    public static const _NORMAL_UINT:uint = 0;
    public static const NORMAL:String = "Normal";

    /**
     *  Resize by setting scaleX and scaleY.
     *
     *  Component always sizes itself and lays out children at at its measured
     *  size. Scale is adjusted to match the specified size by the layout or
     *  the user.
     */
    public static const _SCALE_UINT:uint = 1;
    public static const SCALE:String = "Scale";

    /**
     *  Converts from the <code>String</code> to the <code>uint</code>
     *  representation of the enum values.
     */
    public static function toUINT(value:String):uint
    {
        if (value == SCALE)
            return _SCALE_UINT;
        return _NORMAL_UINT;
    }

    /**
     *  Converts from the <code>uint</code> to the <code>String</code>
     *  representation of the enum values.
     */
    public static function toString(value:uint):String
    {
        if (value == _SCALE_UINT)
            return SCALE;
        return NORMAL;
    }
}

}