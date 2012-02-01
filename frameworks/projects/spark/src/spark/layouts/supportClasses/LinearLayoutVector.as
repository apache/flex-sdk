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
import flash.geom.Rectangle;
import mx.graphics.Rect;
import mx.layout.ILayoutElement;

    
/**
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
 */ 
public final class LinearLayoutVector
{
    /**
     *  Specifies that the <code>majorAxis</code> is vertical.
     * 
     *  @see majorAxis
     */
    public static const VERTICAL:uint = 0;
    
    
    /**
     *  Specifies that the <code>majorAxis</code> is horizontal.
     * 
     *  @see majorAxis
     */
    public static const HORIZONTAL:uint = 1;

    /* Assumption: vector elements (sizes) will typically be set in
     * small ranges that reflect localized scrolling.  Allocate vector
     * elements in blocks of BLOCK_SIZE, which must be a power of 2.
     * BLOCK_SHIFT is the power of 2 and BLOCK_MASK masks off as many 
     * low order bits.  The blockTable contains all of the allocated 
     * blocks and has length/BLOCK_SIZE elements which are allocated lazily.
     */ 
    internal static const BLOCK_SIZE:uint = 128;
    internal static const BLOCK_SHIFT:uint = 7;
    internal static const BLOCK_MASK:uint = 0x7F;
    private var blockTable:Vector.<Block> = new Vector.<Block>(0, false);
    

    public function LinearLayoutVector()
    {
    }
    
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  length
    //----------------------------------

    private var _length:uint = 0;
    
    /**
     *  The number of item size valued elements.
     * 
     *  @default 0
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
    
    private var _majorAxis:Number = VERTICAL;
    
    /**
     *  Defines how the <code>getBounds()</code> method maps from 
     *  majorSize, minorSize to width and height.
     * 
     *  @default VERTICAL
     *  @see #cacheDimensions
     */
    public function get majorAxis():Number
    {
        return _majorAxis;
    }
    
    /**
     * @private
     */
    public function set majorAxis(value:Number):void
    {
        _majorAxis = value;
    }

    //----------------------------------
    //  gap
    //----------------------------------
    
    private var _gap:Number = 6;

    /**
     *  The distance between items.
     * 
     *  @default 6  
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
     */      
    public function setMajorSize(index:uint, value:Number):void
    {
        if (index >= length)
            throw new Error("invalid index");
            
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
     *  The cumulative distance to the start of the item at index, including
     *  the gaps between items. 
     * 
     *  The value of start(0) is 0.  
     * 
     *  Equivalent to:
     *  <pre>
     *  var distance:Number = 0;
     *  for (var i:int = 0; i &lt; index; i++)
     *      distance += get(i);
     *  return distance + (gap * index);
     *  </pre>
     * 
     *  The actual implementation is relatively efficient.
     * 
     *  @param index The item's index.
     *  @see #end
     */
    public function start(index:uint):Number
    {
        if (index == 0)
            return 0;
            
        if (index >= _length)
            throw new Error("invalid index");            

        var distance:Number = 0;
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
            for(i = 0; i < lastBlockLength; i++)
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
     *  <code>start(index) + get(index) + gap</code>.
     * 
     *  The gap isn't added for the last item.
     * 
     *  @param index The item's index.
     *  @see #start
     */
    public function end(index:uint):Number
    {
        var distance:Number = start(index) + getMajorSize(index);
        if (index < (_length - 1))
            distance += gap;
       return distance;
    }

    /**
     *  Returns the index of the item that overlaps the specified distance.
     * 
     *  The item at index <code>i</code> overlaps a distance value 
     *  if <code>start(i) &lt;= distance &lt; end(i)</code>.
     * 
     *  If no such item exists, -1 is returned.
     */
    public function indexOf(distance:Number):int
    {
        if ((_length == 0) || (distance < 0))
            return -1;
            
        var curDistance:Number = 0;
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
            return index + Math.ceil(Number(distance - curDistance) / Number(_defaultMajorSize + _gap));
        }
    }
        
    /**
     *  Stores the majorSize for the specified ILayoutElement at index, 
     *  and  updates the minorSize and minMinorSize properties.
     * 
     *  If majorAxis is VERTICAL then majorSize corresponds to the 
     *  height of this ILayoutElement, and the minor sizes to the 
     *  with and minWidth.
     * 
     *  If majorAxis is HORIZONTAL, then the roles of the dimensions
     *  are reversed.
     * 
     *  The minMinorSize is intended to be used LinearLayout::measure() time.
     * 
     *  It accumulates the maximum of the minWidth,Height for items for which
     *  percentWidth,Height is specified, and preferredWidth,Height when
     *  a percent size is not specified.
     * 
     *  This is because LinearLayouts give items their preferred size along
     *  the minor axis, unless percent size was specified.
     * 
     *  @param index The item's index.
     *  @param elt The layout element at index.
     * 
     *  @see #getMajorSize
     *  @see minorSize
     *  @see minMinorSize
     *  @see majorAxis
     */
    public function cacheDimensions(index:uint, elt:ILayoutElement):void
    {
        if (!elt || (index >= _length))
            return;
            
        if (majorAxis == VERTICAL)
        {
            setMajorSize(index, elt.getLayoutBoundsHeight());
            minorSize = Math.max(minorSize, elt.getLayoutBoundsWidth());
            var mw:Number =  isNaN(elt.percentWidth) ? elt.getPreferredBoundsWidth() : elt.getMinBoundsWidth();            
            minMinorSize = Math.max(minMinorSize, mw);
        }
        else
        {
            setMajorSize(index, elt.getLayoutBoundsWidth());            
            minorSize = Math.max(minorSize, elt.getLayoutBoundsHeight());
            var mh:Number =  isNaN(elt.percentHeight) ? elt.getPreferredBoundsWidth() : elt.getMinBoundsHeight();            
            minMinorSize = Math.max(minMinorSize, mh);
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
