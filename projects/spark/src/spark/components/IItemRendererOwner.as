////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{

import mx.core.IVisualElement;

/**
 *  The IItemRendererOwner interface defines the basic set of APIs
 *  that a class must implement to  support items renderers. 
 *  A class  that implements the IItemRendererOwner interface 
 *  is called the host component of the item renderer.
 *  
 *  <p>The class defining the item renderer must implement the 
 *  IItemRenderer interface.</p> 
 *  
 *  @see spark.components.IItemRenderer
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 *  
 */
public interface IItemRendererOwner
{

    /**
     *  Returns the String for display in an item renderer.
     *  The String is written to the <code>labelText</code>
     *  property of the item renderer.
     *
     *  @param item The data item to display.
     *
     *  @return The String for display in an item renderer.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function itemToLabel(item:Object):String;
    
    /**
     *  Updates the renderer for reuse. 
     *  This method first prepares the item
     *  renderer for reuse by cleaning out any stale properties
     *  as well as updating it with new properties.
     * 
     *  <p>The last thing this method should do is set the <code>data</code> property 
     *  of the item renderer.</p>    
     *
     *  @param renderer The item renderer.
     *  @param itemIndex The index of the data in the data provider.
     *  @param data The data object this item renderer is representing.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function updateRenderer(renderer:IVisualElement, itemIndex:int, data:Object):void;  

}   
}
