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

package spark.layouts.supportClasses
{

[ExcludeClass]

/**
 *  @private
 *  A LinearLayoutVector block of layout element heights or widths.
 *  
 *  Total "distance" for a Block is: sizesSum + (defaultCount * distanceVector.default).
 * 
 *  This class is essentially a C-struct.   If it was possible to make it a private static
 *  inner class of LinearyLayoutVector (as in Java), then it would be.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public final class Block
{
    internal const sizes:Vector.<Number> = new Vector.<Number>(LinearLayoutVector.BLOCK_SIZE, true);
    internal var sizesSum:Number = 0;
    internal var defaultCount:uint = LinearLayoutVector.BLOCK_SIZE;
    public function Block()
    {
        super();
        for (var i:int = 0; i < LinearLayoutVector.BLOCK_SIZE; i++)
            sizes[i] = NaN;
    }
}

}
