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

import spark.components.IItemRendererOwner; 
import mx.core.IDataRenderer;
import mx.core.IVisualElement; 

/**
 *  The IItemRenderer interface defines the basic set of APIs
 *  that you must implement to create a renderer that can 
 *  communicate with an IItemRendererOwner, like a List or
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
    
    /**
     *  The text to display for this renderer. For 
     *  controls like List and ButtonBar, this is the result 
     *  of either a labelField or labelFunction applied to the 
     *  renderer's data, otherwise the toString() representation
     *  of the renderer's data. 
     *  
     */
    function get labelText():String;
    function set labelText(value:String):void;
    

}

}