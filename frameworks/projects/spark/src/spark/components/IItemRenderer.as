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

import mx.components.IItemRendererOwner; 
import mx.core.IDataRenderer;
import mx.core.IVisualElement; 

/**
 *  The IItemRenderer interface defines the basic set of APIs
 *  that you must implement to create a renderer that can 
 *  communication with an IItemRendererOwner, like a List or
 *  ButtonBar. 
 *  
 */
public interface IItemRenderer extends IDataRenderer, IVisualElement
{
    /**
	 *  True if the renderer should allow interaction to change its
	 *  selected state to selected=false
     *  
     */
    function get allowDeselection():Boolean;
    function set allowDeselection(value:Boolean):void;

    /**
	 *  True if the renderer should show itself as selected
     *  
     */
    function get selected():Boolean;
    function set selected(value:Boolean):void;

    /**
	 *  True if the renderer should show itself as focused
	 *  even if it doesn't have focus
     *  
     */
    function get showFocusIndicator():Boolean;
    function set showFocusIndicator(value:Boolean):void;

}

}