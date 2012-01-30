
package mx.utils
{
    
/**
 *  Class representing a doubly linked list node.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class LinkedListNode
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor
     *
     *  @param value Generic value associated with this node. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function LinkedListNode(value:* = null):void
    {
        this.value = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  next
    //----------------------------------
    
    /**
     *  Reference to adjacent 'next' node. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var next:LinkedListNode;
    
    //----------------------------------
    //  prev
    //----------------------------------
    
    /**
     *  Reference to adjacent 'prev' node. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var prev:LinkedListNode;
    
    //----------------------------------
    //  value
    //----------------------------------
    
    /**
     *  Generic value associated with this node.
     *     
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var value:*;
}
}