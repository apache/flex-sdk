package spark.components.supportClasses
{

[ExcludeClass]

import mx.collections.ArrayCollection;

/**
 *  Open LinkedList implementation for representing
 *  row heights in a Grid.
 */
public class GridRowList
{
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    private var _head:GridRowNode;
    private var _tail:GridRowNode;
    private var _length:Number = 0;
    
    private var recentNode:GridRowNode;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function GridRowList():void
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  first
    //----------------------------------
    
    /**
     *  First node in list.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get first():GridRowNode
    {
        return _head;
    }
    
    //----------------------------------
    //  last
    //----------------------------------
    
    /**
     *  Last node in list.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get last():GridRowNode
    {
        return _tail;
    }
    
    //----------------------------------
    //  tail
    //----------------------------------
    
    /**
     *  Node representing tail of the list.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get tail():GridRowNode
    {
        return _tail;
    }
    
    //----------------------------------
    //  head
    //----------------------------------
    
    /**
     *  Node representing head of the list.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get head():GridRowNode
    {
        return _head;
    }
    
    //----------------------------------
    //  length
    //----------------------------------
    
    /**
     *  Returns length of list.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get length():Number
    {
        return _length;
    }
    
    //----------------------------------
    //  numColumns
    //----------------------------------
    
    private var _numColumns:uint = 0;

    /**
     *  Returns number of columns per row.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get numColumns():uint
    {
        return _numColumns;
    }
    
    public function set numColumns(value:uint):void
    {
        if (_numColumns == value)
            return;
        
        _numColumns = value;
        
        var cur:GridRowNode = _head;
        while (cur)
        {
            cur.numColumns = value;
            cur = cur.next;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Inserts new node at the specified index. If a RowNode with the
     *  index already exists, it will be returned.
     * 
     *  @param value Value to insert. If the value is not a RowNode
     *  one will be created.
     *  @param prev The previous node to insert relative to.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function insert(index:int):GridRowNode
    {
        // empty list
        if (_head == null)
        {
            _head = new GridRowNode(numColumns, index);
            _tail = _head;
            return _head;
        }
        
        // This part can be optimized by a better search mechanism
        // Bookmarks, LRU node...etc...
        var cur:GridRowNode = findNearest(index);
        if (cur && cur.rowIndex == index)
            return cur;
        
        var newNode:GridRowNode = new GridRowNode(numColumns, index);
        
        // index is before head.
        if (!cur)
            insertBefore(_head, newNode);
        else // index is after cur.
            insertAfter(cur, newNode);
        
        return newNode;
    }
    
    /**
     *  Inserts a new node after the specified node. Returns
     *  the new node.
     */
    private function insertAfter(node:GridRowNode, newNode:GridRowNode):void
    {
        newNode.prev = node;
        newNode.next = node.next;
        if (node.next == null)
            _tail = newNode;
        else
            node.next.prev = newNode;
        node.next = newNode;
        
        _length++;
    }
    
    /**
     *  Inserts a new node after the specified node. Returns
     *  the new node.
     */
    private function insertBefore(node:GridRowNode, newNode:GridRowNode):void
    {
        newNode.prev = node.prev;
        newNode.next = node;
        if (node.prev == null)
            _head = newNode;
        else
            node.prev.next = newNode;
        node.prev = newNode;
        
        _length++;
    }
    
    /**
     *  Searches through all nodes for the given value.
     * 
     *  @param index The value to find.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function find(index:int):GridRowNode
    {
        // use bookmarks? or maybe a least recently used one.
        if (!_head)
            return null;
        
        var indexToRecent:int;
        var temp:int;
        var lastToIndex:int = _tail.rowIndex - index;
        var result:GridRowNode = null;
        
        if (recentNode)
        {
            if (recentNode.rowIndex == index)
                return recentNode;
            
            indexToRecent = recentNode.rowIndex - index;
            temp = Math.abs(indexToRecent);
        }
        
        // Uses last searched node if its closest to the target.
        if (recentNode && temp < lastToIndex && temp < index)
        {
            if (indexToRecent > 0)
                result = findBefore(index, recentNode);
            else
                result = findAfter(index, recentNode);
        }
        else if (lastToIndex < index)
        {
            result = findBefore(index, _tail);
        }
        else
        {
            result = findAfter(index, _head);
        }
        
        recentNode = result;
        
        return result;
    }
    
    /**
     *  @private
     *  Searches for the given value after the specified node.
     */
    private function findAfter(index:int, node:GridRowNode):GridRowNode
    {
        var cur:GridRowNode = node;
        var result:GridRowNode = null;
        while (cur && cur.rowIndex <= index)
        {
            if (cur.rowIndex == index)
            {
                result = cur;
                break;
            }
            cur = cur.next;
        }
        return result;
    }
    
    /**
     *  @private
     *  Searches for the given value before the specified node.
     */
    private function findBefore(index:int, node:GridRowNode):GridRowNode
    {
        var cur:GridRowNode = node;
        var result:GridRowNode = null;
        while (cur && cur.rowIndex >= index)
        {
            if (cur.rowIndex == index)
            {
                result = cur;
                break;
            }
            cur = cur.prev;
        }
        return result;
    }
    
    /**
     *  Searches through all nodes for the value closest and less than
     *  the specified index. If the index exists, it will just return
     *  the node at that index. Returns null if nearest is at the head
     *  of the list.
     * 
     *  @param index The value to find
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function findNearest(index:int):GridRowNode
    {
        // use bookmarks? or maybe a least recently used one.
        if (!_head || index < 0)
            return null;
        
        var indexToRecent:int;
        var lastToIndex:int = _tail.rowIndex - index;
        var result:GridRowNode = null;
        
        // Uses last searched node if its closest to the target.
        if (lastToIndex < 0)
        {
            result = _tail;
        }
        else if (lastToIndex < index)
        {
            result = findNearestBefore(index, _tail);
        }
        else
        {
            result = findNearestAfter(index, _head);
        }
        
        return result;
    }
    
    /**
     *  @private
     *  Searches for the node with the closest value less than the specified
     *  index. Searches forwards from the specified node.
     */
    private function findNearestAfter(index:int, node:GridRowNode):GridRowNode
    {
        var cur:GridRowNode = node;
        while (cur && cur.rowIndex < index)
        {
            if (cur.next == null)
                break;
            else if (cur.next.rowIndex > index)
                break;
            
            cur = cur.next;
        }
        return cur;
    }
    
    /**
     *  @private
     *  Searches for the node with the closest value less than the specified
     *  index. Searches backwards from the specified node.
     */
    private function findNearestBefore(index:int, node:GridRowNode):GridRowNode
    {
        var cur:GridRowNode = node;
        while (cur && cur.rowIndex > index)
        {
            cur = cur.prev;
        }
        return cur;
    }
    
    /**
     *  Searches through all nodes for the given value and
     *  removes it from the list if found.
     * 
     *  @param value The value to find and remove.
     *  @return The removed node, null otherwise.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function remove(index:int):GridRowNode
    {
        var node:GridRowNode = find(index);
        if (node)
            removeNode(node);
        return node;
    }
    
    /**
     *  @private
     *  Removes specified node.
     */
    private function removeNode(node:GridRowNode):void
    {
        if (node.prev == null)
            _head = node.next;
        else
            node.prev.next = node.next;
        
        if (node.next == null)
            _tail = node.prev;
        else
            node.next.prev = node.prev;
        
        node.next = null;
        node.prev = null;
        
        if (node == recentNode)
            recentNode = null;
        
        _length--;
    }
    
    /**
     *  Removes all the nodes.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function removeAll():void
    {
        this._head = null;
        this._tail = null;
        this._length = 0;
        this.recentNode = null;
    }
    
    /**
     *  for testing;
     */
    public function toString():String
    {
        var s:String = "[ ";
        var node:GridRowNode = this.first;
        
        while (node)
        {
//            s += "max = " + node.maxCellHeight + "; index = " + node.rowIndex + "; "
//                 node.cellHeights + "\n";
            s += "(" + node.rowIndex + "," + node.maxCellHeight + ") -> ";
            node = node.next;
        }
        s += "]";
        
        return s;
    }
    
    public function toArray():ArrayCollection
    {
        var arr:ArrayCollection = new ArrayCollection();
        var node:GridRowNode = this.first;
        var index:int = 0;
        
        while (node)
        {
            arr.addItem(node);
            node = node.next;
        }
        return arr;
    }
}
}