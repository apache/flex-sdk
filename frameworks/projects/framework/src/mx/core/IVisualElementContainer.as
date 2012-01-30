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

package mx.core
{


/**
 *  Documentation is not currently available.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IVisualElementContainer
{
    //----------------------------------
    //  Visual Element iteration
    //----------------------------------
    
    /**
     *  The number of visual elements in this visual container.
     * 
     *  @return The number of elements in this visual container
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get numElements():int;
    
    /**
     *  Returns the visual element that exists at the specified index.
     *
     *  @param index The index of the element to retrieve.
     *
     *  @return The element at the specified index.
     * 
     *  @throws RangeError If the index position does not exist in the child list.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    function getElementAt(index:int):IVisualElement
    
    //----------------------------------
    //  Visual Element addition
    //----------------------------------
    
    /**
     *  Adds a visual element to this visual container. The element is 
     *  added after all other elements and on top of all other elements.  
     *  (To add a visual element to a specific index position, use 
     *  the <code>addElementAt()</code> method.)
     * 
     *  <p>If you add a visual element object that already has a different
     *  container as a parent, the element is removed from the child 
     *  list of the other container.</p>  
     *
     *  @param element The element to add as a child of this visual container.
     *
     *  @return The element that was added to the visual container.
     * 
     *  @event elementAdded ElementExistenceChangedEvent Dispatched when 
     *  the element is added to the child list.
     * 
     *  @throws ArgumentError If the element is the same as the visual container.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */   
    function addElement(element:IVisualElement):IVisualElement;
    
    /**
     *  Adds a visual element to this visual container. The element is 
     *  added at the index position specified.  An index of 0 represents   
     *  the first element and the back (bottom) of the display list, unless
     *  <code>layer</code> is specified.
     * 
     *  <p>If you add a visual element object that already has a different
     *  container as a parent, the element is removed from the child 
     *  list of the other container.</p>  
     *
     *  @param element The element to add as a child of this visual container.
     * 
     *  @param index The index position to which the element is added. If 
     *  you specify a currently occupied index position, the child object 
     *  that exists at that position and all higher positions are moved 
     *  up one position in the child list.
     *
     *  @return The element that was added to the visual container.
     * 
     *  @event elementAdded ElementExistenceChangedEvent Dispatched when 
     *  the element is added to the child list.
     * 
     *  @throws ArgumentError If the element is the same as the visual container.
     * 
     *  @throws RangeError If the index position does not exist in the child list.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function addElementAt(element:IVisualElement, index:int):IVisualElement;
    
    //----------------------------------
    //  Visual Element removal
    //----------------------------------
    
    /**
     *  Removes the specified visual element from the child list of 
     *  this visual container.  The index positions of any elements 
     *  above the element in this visual container are decreased by 1.
     *
     *  @param element The element to be removed from the visual container.
     *
     *  @return The element removed from the visual container.
     * 
     *  @throws ArgumentError If the element parameter is not a child of 
     *  this visual container.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function removeElement(element:IVisualElement):IVisualElement;
    
    /**
     *  Removes a visual element from the specified index position 
     *  in the visual container.
     *
     *  @param index The index of the element to remove.
     *
     *  @return The element removed from the visual container.
     * 
     *  @throws RangeError If the index does not exist in the child list.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function removeElementAt(index:int):IVisualElement;
    
    //----------------------------------
    //  Visual Element index
    //----------------------------------
    
    /**
     *  Returns the index position of a visual element.
     *
     *  @param element The element to identify.
     *
     *  @return The index position of the element to identify.
     * 
     *  @throws ArgumentError If the element is not a child of this visual container.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    function getElementIndex(element:IVisualElement):int;
    
    /**
     *  Changes the position of an existing visual element in the visual container.
     * 
     *  <p>When you call the <code>setElementIndex()</code> method and specify an 
     *  index position that is already occupied, the only positions 
     *  that change are those in between the elements's former and new position.
     *  All others will stay the same.</p>
     *
     *  <p>If a visual element is moved to an index 
     *  lower than its current index, the index of all elements in between increases
     *  by 1.  If an element is moved to an index
     *  higher than its current index, the index of all elements in between 
     *  decreases by 1.</p>
     *
     *  @param element The element for which you want to change the index number.
     * 
     *  @param index The resulting index number for the element.
     * 
     *  @throws RangeError - If the index does not exist in the child list.
     *
     *  @throws ArgumentError - If the element parameter is not a child 
     *  of this visual container.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function setElementIndex(element:IVisualElement, index:int):void;
    
    //----------------------------------
    //  Visual Element swapping
    //----------------------------------
    
    /**
     *  Swaps the index of the two specified visual elements. All other elements
     *  remain in the same index position.
     *
     *  @param element1 The first visual element.
     *  @param element2 The second visual element.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function swapElements(element1:IVisualElement, element2:IVisualElement):void;
    
    /**
     *  Swaps the visual elements at the two specified index 
     *  positions in the visual container.  All other visual 
     *  elements remain in the same index position.
     *
     *  @param index1 The index of the first element.
     * 
     *  @param index2 The index of the second element.
     * 
     *  @throws RangeError If either index does not exist in 
     *  the visual container.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function swapElementsAt(index1:int, index2:int):void;

}

}
