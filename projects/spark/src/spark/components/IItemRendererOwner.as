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

package mx.components
{

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

}
	
}