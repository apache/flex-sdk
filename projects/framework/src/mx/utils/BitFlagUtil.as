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

package mx.utils
{

[ExcludeClass]

/**
 *  @private
 *  BitFlagUtil is a framework internal class to help manipulate 
 *  bit flags for the purpose of storing booleans effeciently in 
 *  one integer.
 */
public class BitFlagUtil
{
    public function BitFlagUtil()
    {
        super();
    }
        
    /**
     *  Returns true if all of the flags specified by <code>flagMask</code> are set. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    public static function isSet(flags:uint, flagMask:uint):Boolean
    {
        return flagMask == (flags & flagMask);
    }

    /**
     *  Sets the flags specified by <code>flagMask</code> according to <code>value</code>. 
     *  Returns the new bitflag.
     *  <code>flagMask</code> can be a combination of multiple flags.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    public static function update(flags:uint, flagMask:uint, value:Boolean):uint
    {
        if (value)
        {
            if ((flags & flagMask) == flagMask)
                return flags; // Nothing to change
            // Don't use ^ since flagMask could be a combination of multiple flags
            flags |= flagMask;
        }
        else
        {
            if ((flags & flagMask) == 0)
                return flags; // Nothing to change
            // Don't use ^ since flagMask could be a combination of multiple flags
            flags &= ~flagMask;
        }
        return flags;
    }

}
}