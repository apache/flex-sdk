////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.utils
{
    
/**
 *  Provides a generic doubly linked list implementation.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
public class LinkedList
{
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    private var _head:LinkedListNode;
    private var _tail:LinkedListNode;
    private var _length:Number = 0;
    
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
     *  @productversion Flex 4.5
     */
    public function LinkedList():void
    {
        _head = new LinkedListNode();
        _tail = new LinkedListNode();
        _head.next = _tail;
        _tail.prev = _head;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  head
    //----------------------------------
    
    /**
     *  Node representing head of the list.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get head():LinkedListNode
    {
        return (_head.next == _tail) ? null : _head.next;
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
     *  @productversion Flex 4.5
     */
    public function get length():Number
    {
        return _length;
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
     *  @productversion Flex 4.5
     */
    public function get tail():LinkedListNode
    {
        return (_tail.prev == _head) ? null : _tail.prev;
    }
        
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Inserts new node after a previously existing node. 
     * 
     *  @param value Value to insert. If the value is not a LinkedListNode
     *  one will be created.
     * 
     *  @param prev The previous node to insert relative to.
     *  
     *  @return The new node.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function insertAfter(value:*, prev:LinkedListNode):LinkedListNode
    {
        var node:LinkedListNode = makeNode(value);
        node.prev = prev;
        node.next = prev.next;
        node.prev.next = node;
        node.next.prev = node;
        
        _length++;
        return node;
    }
    
    /**
     *  Inserts new node before a previously existing node. 
     * 
     *  @param value Value to insert. If the value is not a LinkedListNode
     *  one will be created.
     * 
     *  @param prev The node to insert relative to.
     *  
     *  @return The new node.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function insertBefore(value:*, next:LinkedListNode):LinkedListNode
    {
        var node:LinkedListNode = makeNode(value);
        
        node.prev = next.prev;
        node.next = next;
        node.prev.next = node;
        node.next.prev = node;
        
        _length++;
        return node;
    }
        
    /**
     *  Searches through all nodes for the given value.
     * 
     *  @param value The value to find.
     *
     *  @return The node location.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function find(value:*):LinkedListNode
    {
        var cur:LinkedListNode = _head;
        while (cur.value != value && cur != _tail)
            cur = cur.next;
        return (cur == _tail) ? null : cur;
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
     *  @productversion Flex 4.5
     */
    public function remove(value:*):LinkedListNode
    {
        var node:LinkedListNode = getNode(value);
        if (node)
        {
            node.prev.next = node.next;
            node.next.prev = node.prev;  
            node.next = node.prev = null;
            _length--;
        }
        return node;
    }
    
    /**
     *  Push a new node to the tail of list.
     * 
     *  @param value The value to append.
     *  @return The newly appended node.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function push(value:*):LinkedListNode
    {
        return insertAfter(value, _tail.prev);
    }
    
    /**
     *  Removes the node at the tail of the list.
     * 
     *  @return The removed node.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function pop():LinkedListNode
    {
        return (_length == 0) ? null : remove(_tail.prev);  
    }
    
    /**
     *  Push a new node to the head of list.
     * 
     *  @param value The value to append.
     *  @return The newly appended node.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function unshift(value:*):LinkedListNode
    {
        return insertAfter(value, _head);
    }
    
    /**
     *  Removes the node at the head of the list.
     * 
     *  @return The removed node.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function shift():LinkedListNode
    {
        return (_length == 0) ? null : remove(_head.next);
    }
    
    /**
     *  @private
     */
    protected function getNode(value:*):LinkedListNode
    {
        return (value is LinkedListNode) ? value : find(value);
    }
    
    /**
     *  @private
     */
    protected function makeNode(value:*):LinkedListNode
    {
        return (value is LinkedListNode) ? value : new LinkedListNode(value);
    }
}
}