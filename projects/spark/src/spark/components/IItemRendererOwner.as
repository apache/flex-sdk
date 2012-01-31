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
 *  that a class must to  support items renderers. 
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
     *  @param item The date item to display.
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
     *  Updates renderer-specific properties of the item renderer, such as 
     *  <code>data</code>, <code>labelText</code> and <code>owner</code>. 
     *  This is a convenience method that you can implement to 
     *  update all of the renderer properties from the host component.  
     *
     *  @param renderer The item renderer.
     *
     *  @param data The date item to display.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function updateRendererInformation(renderer:IVisualElement, data:Object=null):void;  

}   
}