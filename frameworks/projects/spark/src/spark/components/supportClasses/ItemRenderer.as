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

package mx.components
{
import flash.events.MouseEvent;

import mx.components.DataGroup;
import mx.components.MXMLComponent;
import mx.layout.HorizontalLayout;
import mx.layout.VerticalLayout;

/**
 *  The ItemRenderer class is the base class for List item renderers.
 */
public class ItemRenderer extends MXMLComponent
{    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
	public function ItemRenderer()
	{
		super();
		
		addHandlers();
	}
	
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
	//----------------------------------
	//  hovered
	//----------------------------------

	/**
	 *  @private
	 *  Flag that is set when the mouse is hovered over the item renderer.
	 */
	private var hovered:Boolean = false;
    
	//----------------------------------
	//  selected
	//----------------------------------

    private var _selected:Boolean = false;
    
    public function get selected():Boolean
    {
    	return _selected;
    }
    
	public function set selected(value:Boolean):void
	{
		if (value != _selected)
		{
			_selected = value;
			currentState = getCurrentSkinState();
		}
	}
	
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Attach the mouse events.
     */
	protected function addHandlers():void
	{
		addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
		addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	}
	
    /**
     *  @private
     *  Return the skin state. This can be overridden by subclasses to add more states.
     *  NOTE: Undocumented for now since MXMLComponent class has not been fleshed out.
     */
	protected function getCurrentSkinState():String
	{
		if (selected)
			return "selected";
		
		if (hovered)
			return "hovered";
			
		return "normal";
	}
	
	/**
	 *  @private
	 *  Mouse rollOver event handler.
	 */
	private function rollOverHandler(event:MouseEvent):void
	{
		hovered = true;
		currentState = getCurrentSkinState();
	}
	
	/**
	 *  @private
	 *  Mouse rollOut event handler.
	 */
	private function rollOutHandler(event:MouseEvent):void
	{
		hovered = false;
		currentState = getCurrentSkinState();
	}
	
	/**
	 *  @private
	 *  Mouse down event handler.
	 */
	private function mouseDownHandler(event:MouseEvent):void
	{
		dispatchEvent(new MouseEvent("click"));
	}
}
}