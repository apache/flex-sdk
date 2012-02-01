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
import flash.geom.Rectangle;

import mx.core.ILayoutElement;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

//--------------------------------------
//  Other metadata
//--------------------------------------

[ResourceBundle("layout")]

[ExcludeClass]
    
/**
 *  @private
 *  A sparse array of "major dimension" sizes that represent 
 *  VerticalLayout item heights or HorizontalLayout item widths, 
 *  and the current "minor dimension" maximum size.
 * 
 *  Provides efficient support for finding the cumulative distance to 
 *  the start/end of an item along the major axis, and similarly for
 *  finding the index of the item at a particular distance.
 * 
 *  Default major/minor sizes is used for items whose size hasn't 
 *  been specified.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
public final class LinearLayoutVector
{
    /**
     *  Specifies that the <code>majorAxis</code> is vertical.
     * 
     *  @see majorAxis
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const VERTICAL:uint = 0;
    
    
    /**
     *  Specifies that the <code>majorAxis</code> is horizontal.
     * 
     *  @see majorAxis
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const HORIZONTAL:uint = 1;

    /* Assumption: vector elements (sizes) will typically be set in
     * small ranges that reflect localized scrolling.  Allocate vector
     * elements in blocks of BLOCK_SIZE, which must be a power of 2.
     * BLOCK_SHIFT is the power of 2 and BLOCK_MASK masks off as many 
     * low order bits.  The blockTable contains all of the allocated 
     * blocks and has length/BLOCK_SIZE elements which are allocated lazily.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    internal static const BLOCK_SIZE:uint = 128;
    internal static const BLOCK_SHIFT:uint = 7;
    internal static const BLOCK_MASK:uint = 0x7F;
    private var blockTable:Vector.<Block> = new Vector.<Block>(0, false);

    public function LinearLayoutVector(majorAxis:uint = VERTICAL)
    {
        super();
        this.majorAxis = majorAxis;
    }
    
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  resourceManager
    //----------------------------------

    /**
     *  @private
     *  Used for accessing localized Error messages.
     */
    private function get resourceManager():IResourceManager
    {
        return ResourceManager.getInstance();
    }
    
    
    //----------------------------------
    //  length
    //----------------------------------

    private var _length:uint = 0;
    
    /**
     *  The number of item size valued elements.
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get length():uint
    {
        return _length;
    }
    
    /**
     * @private
     */
    public function set length(value:uint):void
    {
        if (_length == value)
            return;
        
        _length = value;  
        var partialBlock:uint = ((_length & BLOCK_MASK) == 0) ? 0 : 1;
        blockTable.length = (_length >> BLOCK_SHIFT) + partialBlock;       
    }
    
    //----------------------------------
    //  defaultMajorSize
    //----------------------------------
    
    private var _defaultMajorSize:Number = 20;
    
    /**
     *  The size of items whose majorSize was not specified with setMajorSize.
     * 
     *  @default 20
     *  @see #cacheDimensions
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get defaultMajorSize():Number
    {
        return _defaultMajorSize;
    }
    
    /**
     * @private
     */
    public function set defaultMajorSize(value:Number):void
    {
        _defaultMajorSize = value;
    }
    
    //----------------------------------
    //  minorSize
    //----------------------------------
    
    private var _minorSize:Number = 0;

    /**
     *  The maximum size of items along the axis opposite the majorAxis.
     * 
     *  This property is updated by the <code>cacheDimensions()</code> method.
     * 
     *  @default 0
     *  @see #cacheDimensions
     *  @see majorAxis
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get minorSize():Number
    {
        return _minorSize;
    }
    
    /**
     * @private
     */
    public function set minorSize(value:Number):void
    {
        _minorSize = value;
    }
    
    //----------------------------------
    //  minMinorSize
    //----------------------------------
    
    private var _minMinorSize:Number = 0;
    
    /**
     *  The maximum of the minimum size of items relative to the minor axis.
     * 
     *  If majorAxis is VERTICAL then this is the maximum of items' minWidths,
     *  and if majorAxis is HORIZONTAL, then this is the maximum of the
     *  items' minHeights. 
     * 
     *  This property is updated by the <code>cacheDimensions()</code> method.
     * 
     *  @default 0
     *  @see #cacheDimensions
     *  @see majorAxis
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get minMinorSize():Number
    {
        return _minMinorSize;
    }
    
    /**
     * @private
     */
    public function set minMinorSize(value:Number):void
    {
        _minMinorSize = value;
    }
    
    //----------------------------------
    //  majorAxis
    //----------------------------------
    
    private var _majorAxis:uint = VERTICAL;
    
    /**
     *  Defines how the <code>getBounds()</code> method maps from 
     *  majorSize, minorSize to width and height.
     * 
     *  @default VERTICAL
     *  @see #cacheDimensions
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get majorAxis():uint
    {
        return _majorAxis;
    }
    
    /**
     * @private
     */
    public function set majorAxis(value:uint):void
    {
        _majorAxis = value;
    }

    //----------------------------------
    //  majorAxisOffset
    //----------------------------------
    
    private var _majorAxisOffset:Number = 0;
    
    /**
     *  The offset of the first item from the origin in the majorAxis
     *  direction. This is useful when implementing padding,
     *  in addition to gaps, for virtual layouts.
     *  
     *  @see #gap
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get majorAxisOffset():Number
    {
        return _majorAxisOffset;
    }

    /**
     * @private
     */
    public function set majorAxisOffset(value:Number):void
    {
        _majorAxisOffset = value;
    }

    //----------------------------------
    //  gap
    //----------------------------------
    
    private var _gap:Number = 6;

    /**
     *  The distance between items.
     * 
     *  @default 6  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get gap():Number
    {
        return _gap;
    }
    
    /**
     * @private
     */
    public function set gap(value:Number):void
    {
        _gap = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
     
    /**
     *  Return the size of the item at index.  If no size was ever
     *  specified then then the defaultMajorSize is returned.
     * 
     *  @param index The item's index.
     *  @see defaultMajorSize
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */      
    public function getMajorSize(index:uint):Number
    {
        var block:Block = blockTable[index >> BLOCK_SHIFT];
        if (block)
        {
            var value:Number = block.sizes[index & BLOCK_MASK];
            return (isNaN(value)) ? _defaultMajorSize : value;
        }
        else
            return _defaultMajorSize;
    }
    
    /**
     *  Set the size of the item at index.   If an index is 
     *  set to <code>NaN</code> then subsequent calls to get
     *  will return the defaultMajorSize.
     * 
     *  @param index The item's index.
     *  @param value The item's size.
     *  @see defaultMajorSize
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */      
    public function setMajorSize(index:uint, value:Number):void
    {
        if (index >= length)
            throw new Error(resourceManager.getString("layout", "invalidIndex"));
            
        var blockIndex:uint = index >> BLOCK_SHIFT;
        var block:Block = blockTable[blockIndex];
        if (!block)
            block = blockTable[blockIndex] = new Block();
        var sizesIndex:uint = index & BLOCK_MASK;
        var sizes:Vector.<Number> = block.sizes;
        var oldValue:Number = sizes[sizesIndex];
        if (oldValue == value)
            return;
        if (isNaN(oldValue)) 
        { 
            block.defaultCount -= 1;
            block.sizesSum += value;
        }   
        else if (isNaN(value))
        {
            block.defaultCount += 1;
            block.sizesSum -= oldValue;
        }
        else
            block.sizesSum += value - oldValue;
        block.sizes[sizesIndex] = value;
    }
    
    /**
     *  @private
     *  Shift block.sizes[startIndex ... BLOCK_SIZE-2] to the right one position, replace
     *  block.sizes[startIndex] with value, and return the original value of 
     *  block.sizes[BLOCK_SIZE-1].
     * 
     *  We're shifting the sizes to the right to make room for the new value at
     *  startIndex, and we're returning the value that gets shifted off the end.
     * 
     *  This function returns the (old) last value so that a series of blocks
     *  can be shifted bucket brigade style, by making the last elt of
     *  one block the first element - after shifting - of the next block.
     *
     *  @param block The Block.
     *  @param startIndex The block relative index.
     *  @param value The value that block.sizes[startIndex] should have
     *  @return The value of block.sizes[BLOCK_SIZE-1] before the shift.
     */
    private function shiftBlockRight(block:Block, startIndex:uint, value:Number):Number
    {
        var sizes:Vector.<Number> = block.sizes;
        var lastSize:Number = sizes[BLOCK_SIZE - 1];
        if (!isNaN(lastSize))
        {
            block.sizesSum -= lastSize;
            block.defaultCount += 1;
        }
        if (!isNaN(value))
        {
            block.sizesSum += value;
            block.defaultCount -= 1;
        }
        for (var i:int = BLOCK_SIZE - 2; i >= startIndex; i--)
            sizes[i + 1] = sizes[i];
        sizes[startIndex] = value;
        return lastSize;
    }
    
    /**
     *  Make room for a new item at index by shifting all of the sizes 
     *  one position to the right, beginning with startIndex.  
     * 
     *  The value at index will be NaN. 
     * 
     *  This is similar to array.splice(index, 0, NaN).
     * 
     *  @param index The position of the new NaN size item.
     */
    public function insert(index:uint):void
    {
        length = Math.max(length, index) + 1;
        var lastSize:Number = NaN;
        var blockIndex:uint = index >> BLOCK_SHIFT;
        var sizesIndex:uint = index & BLOCK_MASK;        
        do
        {
            var block:Block = blockTable[blockIndex];
            if (!block)
            {
                if (!isNaN(lastSize))
                {
                    block = blockTable[blockIndex] = new Block();
                    block.sizes[sizesIndex] = lastSize;
                    block.sizesSum = lastSize;
                    block.defaultCount -= 1;
                }
                break;
            }
            else
                lastSize = shiftBlockRight(block, sizesIndex, lastSize);
                
            sizesIndex = 0;
            blockIndex += 1;
        }
        while(blockIndex < blockTable.length)        
    }

    /**
     *  @private
     *  Shift block.sizes[removeIndex ... BLOCK_SIZE-1] to the left one position, 
     *  effectively removing removeIndex, and replace block.sizes[BLOCK_SIZE-1]
     *  with lastValue.
     * 
     *  @param block The Block.
     *  @param startIndex The block relative index.
     *  @param value The value that block.sizes[startIndex] should have
     *  @return The value of block.sizes[0] before the shift.
     */
    private function shiftBlockLeft(block:Block, removeIndex:uint, lastValue:Number):void
    {
        var sizes:Vector.<Number> = block.sizes;
        var removedSize:Number = sizes[removeIndex];
        if (!isNaN(removedSize))
        {
            block.sizesSum -= removedSize;
            block.defaultCount += 1;
        }
        if (!isNaN(lastValue))
        {
            block.sizesSum += lastValue;
            block.defaultCount -= 1;
        }
        for (var i:int = removeIndex; i < BLOCK_SIZE - 1; i++)
            sizes[i] = sizes[i + 1];
        sizes[BLOCK_SIZE - 1] = lastValue;
    }
    

    /**
     *  Remove index by shifting all of the sizes one position to the left, 
     *  begining with index+1.  
     * 
     *  This is similar to array.splice(index, 1).
     * 
     *  @param index The position to be removed.
     */
    public function remove(index:uint):void
    {
        if (index >= length)
            throw new Error(resourceManager.getString("layout", "invalidIndex"));
            
        var blockIndex:uint = index >> BLOCK_SHIFT;
        var sizesIndex:uint = index & BLOCK_MASK;        
        do
        {
            var block:Block = blockTable[blockIndex];
            if (!block)
                break;
            else
            {
                var nextBlock:Block = ((blockIndex + 1) < blockTable.length) ? blockTable[blockIndex + 1] : null;
                var firstSize:Number = (nextBlock) ? nextBlock.sizes[0] : NaN;
                shiftBlockLeft(block, sizesIndex, firstSize);
            }
                
            sizesIndex = 0;
            blockIndex += 1;
        }
        while(blockIndex < blockTable.length)
        length -= 1;
    }
    
    /**
     *  The cumulative distance to the start of the item at index, including
     *  the gaps between items and the majorAxisOffset. 
     * 
     *  The value of start(0) is majorAxisOffset.  
     * 
     *  Equivalent to:
     *  <pre>
     *  var distance:Number = majorAxisOffset;
     *  for (var i:int = 0; i &lt; index; i++)
     *      distance += get(i);
     *  return distance + (gap * index);
     *  </pre>
     * 
     *  The actual implementation is relatively efficient.
     * 
     *  @param index The item's index.
     *  @see #end
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function start(index:uint):Number
    {
        if ((_length == 0) || (index == 0))
            return majorAxisOffset;
            
        if (index >= _length)
            throw new Error(resourceManager.getString("layout", "invalidIndex"));            

        var distance:Number = majorAxisOffset;
        var blockIndex:uint = index >> BLOCK_SHIFT;
        for (var i:int = 0; i < blockIndex; i++)
        {
            var block:Block = blockTable[i];
            if (block)
                distance += block.sizesSum + (block.defaultCount * _defaultMajorSize);
            else
                distance += BLOCK_SIZE * _defaultMajorSize;
        }
        var lastBlock:Block = blockTable[blockIndex];
        var lastBlockOffset:uint = index & ~BLOCK_MASK;
        var lastBlockLength:uint = index - lastBlockOffset;
        if (lastBlock)
        {
            var sizes:Vector.<Number> = lastBlock.sizes;
            for (i = 0; i < lastBlockLength; i++)
            {
                var size:Number = sizes[i];
                distance += (isNaN(size)) ? _defaultMajorSize : size;
            }
        }
        else 
            distance += _defaultMajorSize * lastBlockLength;
        distance += index * gap;
        return distance;
    }

    /**
     *  The cumulative distance to the end of the item at index, including
     *  the gaps between items.
     * 
     *  If <code>index &lt;(length-1)</code> then the value of this 
     *  function is defined as: 
     *  <code>start(index) + get(index)</code>.
     * 
     *  @param index The item's index.
     *  @see #start
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function end(index:uint):Number
    {
       return start(index) + getMajorSize(index);
    }

    /**
     *  Returns the index of the item that overlaps the specified distance.
     * 
     *  The item at index <code>i</code> overlaps a distance value 
     *  if <code>start(i) &lt;= distance &lt; end(i)</code>.
     * 
     *  If no such item exists, -1 is returned.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function indexOf(distance:Number):int
    {
        var index:int = indexOfInternal(distance);
        return (index >= _length) ? -1 : index;
    }

    private function indexOfInternal(distance:Number):int
    {
        if ((_length == 0) || (distance < 0))
            return -1;

        // The area of the first item includes the majorAxisOffset            
        var curDistance:Number = majorAxisOffset;
        if (distance < curDistance)
            return 0;
        
        var index:int = -1;
        var block:Block = null;
        var blockGap:Number = _gap * BLOCK_SIZE;
        
        // Find the block that contains distance and the index of its
        // first element
        for (var blockIndex:uint = 0; blockIndex < blockTable.length; blockIndex++)
        {
            block = blockTable[blockIndex];
            var blockDistance:Number = blockGap;
            if (block)
                blockDistance += block.sizesSum + (block.defaultCount * _defaultMajorSize);
            else
                blockDistance += BLOCK_SIZE * _defaultMajorSize;
            if ((distance == curDistance) ||
                ((distance >= curDistance) && (distance < (curDistance + blockDistance))))
            {
                index = blockIndex << BLOCK_SHIFT;
                break;
            }
            curDistance += blockDistance;
        }
        
        if ((index == -1) || (distance == curDistance))
            return index;

        // At this point index corresponds to the first item in this block
        if (block)
        {
            // Find the item that contains distance and return its index
            var sizes:Vector.<Number> = block.sizes;
            for (var i:int = 0; i < BLOCK_SIZE - 1; i++)
            {
                var size:Number = sizes[i];
                curDistance += _gap + (isNaN(size) ? _defaultMajorSize : size);
                if (curDistance > distance)
                    return index + i;
            }
            // TBD special-case for the very last index
            return index + BLOCK_SIZE - 1;
        }
        else
        {
            return index + Math.floor(Number(distance - curDistance) / Number(_defaultMajorSize + _gap));
        }
    }

    /**
     *  Stores the <code>majorSize</code> for the specified ILayoutElement at index, 
     *  and updates the <code>minorSize</code> and <code>minMinorSize</code> properties.
     * 
     *  If <code>majorAxis</code> is <code>VERTICAL</code> then <code>majorSize</code> corresponds to the 
     *  height of this ILayoutElement, and the minor sizes to the 
     *  <code>preferredBoundsWidth</code> and <code>minWidth</code>.
     * 
     *  If <code>majorAxis</code> is <code>HORIZONTAL</code>, then the roles of the dimensions
     *  are reversed.
     * 
     *  The <code>minMinorSize</code> is intended to be used at the time that the <code>LinearLayout::measure()</code> method is called.
     * 
     *  It accumulates the maximum of the <code>minWidth</code>, <code>Height</code> for all items.
     * 
     *  @param index The item's index.
     *  @param elt The layout element at index.
     * 
     *  @see #getMajorSize
     *  @see minorSize
     *  @see minMinorSize
     *  @see majorAxis
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function cacheDimensions(index:uint, elt:ILayoutElement):void
    {
        if (!elt || (index >= _length))
            return;
            
        // The minorSize is the min of the acutal width and the preferred width
        // because we do not want the contentWidth to track the target's width, 
        // per horizontalAlign="contentJustify" or "justify".  
        // The majorAxis=HORIZONTAL case is similar.
        
        if (majorAxis == VERTICAL)
        {
            setMajorSize(index, elt.getLayoutBoundsHeight());
            var w:Number = Math.min(elt.getPreferredBoundsWidth(), elt.getLayoutBoundsWidth());
            minorSize = Math.max(minorSize, w);
            minMinorSize = Math.max(minMinorSize, elt.getMinBoundsWidth());
        }
        else
        {
            setMajorSize(index, elt.getLayoutBoundsWidth());            
            var h:Number = Math.min(elt.getPreferredBoundsHeight(), elt.getLayoutBoundsHeight());
            minorSize = Math.max(minorSize, h);
            minMinorSize = Math.max(minMinorSize, elt.getMinBoundsHeight());
        }
    }
    
    /** 
     *  Returns the implict bounds of the item at index.
     * 
     *  The bounds do not include the gap that follows the item.
     * 
     *  If majorAxis is VERTICAL then the returned value is equivalent to:
     *  <pre>
     *    new Rectangle(0, start(index), major, minor)
     *  </pre>
     * 
     *  If majorAxis is HORIZONTAL then the returned value is equivalent to:
     *  <pre>
     *    new Rectangle(start(index), 0, minor, major)
     *  </pre>
     * 
     *  @param index The item's index.
     *  @param bounds The Rectangle to return or null for a new Rectangle
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getBounds(index:uint, bounds:Rectangle = null):Rectangle
    {
        if (!bounds)
            bounds = new Rectangle();

        var major:Number = getMajorSize(index); 
        var minor:Number = minorSize;
        if (majorAxis == VERTICAL)
        {
            bounds.x = 0;
            bounds.y = start(index);
            bounds.height = major;
            bounds.width = minor;
        }
        else  // HORIZONTAL
        {
            bounds.x = start(index);
            bounds.y = 0;
            bounds.height = minor;
            bounds.width = major;
        }
        return bounds;
    }
    
    /**
     *  Clear all cached state, reset length to zero.
     */
    public function clear():void
    {
        length = 0;
        minorSize = 0;
        minMinorSize = 0;
    }
    
    public function toString():String
    {
        return "LinearLayoutVector{" + 
            "length=" + _length +
            " [blocks=" + blockTable.length + "]" + 
            " " + ((majorAxis == VERTICAL) ? "VERTICAL" : "HORIZONTAL") + 
            " gap=" + _gap + 
            " defaultMajorSize=" + _defaultMajorSize + 
            "}";
    }
}

}
