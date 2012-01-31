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

package mx.effects
{
/**
 *  The WipeDirection class defines the values
 *  for the <code>direction</code> property of the FxWipe class.
 *
 *  @see mx.effects.FxWipe
 */
public class WipeDirection
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     * Wipe direction that starts at the left and moves right
     */
    public static const RIGHT:String = "right";

    /**
     * Wipe direction that starts at the bottom and moves up
     */
    public static const UP:String = "up";

    /**
     * Wipe direction that starts at the right and moves left
     */
    public static const LEFT:String = "left";

    /**
     * Wipe direction that starts at the top and moves down
     */
    public static const DOWN:String = "down";
}
}