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

package mx.layout
{

[ExcludeClass]

/**
 *  Total "distance" for a Block is: sizesSum + (defaultCount * distanceVector.default).
 * 
 *  This class is essentially a C-struct.   If it was possible to make it a static
 *  inner class of DistanceVector, then it would be.
 */
public final class Block
{
    internal const sizes:Vector.<Number> = new Vector.<Number>(LinearLayoutVector.BLOCK_SIZE, true);
    internal var sizesSum:Number = 0;
    internal var defaultCount:uint = LinearLayoutVector.BLOCK_SIZE;
    public function Block()
    {
        super();
        for(var i:int = 0; i < LinearLayoutVector.BLOCK_SIZE; i++)
            sizes[i] = NaN;
    }
}

}