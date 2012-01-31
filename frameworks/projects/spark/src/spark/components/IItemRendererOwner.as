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
 *  that you must implement to create a component that can
 *  communicate with renderers implementing the IItemRenderer 
 *  interface. 
 *  
 */
public interface IItemRendererOwner
{

    /**
     *  Method that returns the label an item renderer displays. 
     */
    function itemToLabel(item:Object):String;
	
    /**
     *  Method that updates renderer-specific properties like 
     *  data, labelText and owner. This is a convenience method which 
     *  funnels all updates to the renderer properties owned by 
     *  the owner.  
     */
    function updateRendererInformation(renderer:IVisualElement, data:Object=null):void;  

}	
}