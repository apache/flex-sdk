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

package mx.charts.events
{

import flash.events.Event;
import flash.events.MouseEvent;
import mx.charts.LegendItem;
import flash.display.InteractiveObject;

/**
 *   The LegendMouseEvent class represents event objects that are specific to the chart legend components.
 *   such as when a legend item is clicked on.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class LegendMouseEvent extends MouseEvent
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

	/**
	 *  Event type constant; indicates that the user clicked the mouse button
	 *  over a legend item.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const ITEM_MOUSE_DOWN:String = "itemMouseDown";
	
	/**
	 *  Event type constant; indicates that the user released the mouse button
	 *  while over  a legend item.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const ITEM_MOUSE_UP:String = "itemMouseUp";
	
	/**
	 *  Event type constant; indicates that the user rolled the mouse pointer
	 *  away from a legend item.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const ITEM_MOUSE_OUT:String = "itemMouseOut";
	
	/**
	 *  Event type constant; indicates that the user rolled the mouse pointer
	 *  over  a legend item.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const ITEM_MOUSE_OVER:String = "itemMouseOver";
	
	/**
	 *  Event type constant; indicates that the user clicked the mouse button
	 *  over a legend item.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const ITEM_CLICK:String = "itemClick";

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private static function convertType(baseType:String):String
	{
		switch (baseType)
		{
			case MouseEvent.CLICK:
			{
				return ITEM_CLICK;
			}
				
			case MouseEvent.MOUSE_DOWN:
			{
				return ITEM_MOUSE_DOWN;
			}
				
			case MouseEvent.MOUSE_UP:
			{
				return ITEM_MOUSE_UP;
			}
				
			case MouseEvent.MOUSE_OVER:
			{
				return ITEM_MOUSE_OVER;
			}
				
			case MouseEvent.MOUSE_OUT:
			{
				return ITEM_MOUSE_OUT;
			}
		}
		
		return baseType;
	}

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 *
	 *	@param type The type of Mouse event. If a mouse event type is given it 
	 *  would be converted into a LegendMouseEvent type.
	 *
	 *  @param triggerEvent The MouseEvent that triggered this LegentMouseEvent.
	 *
	 *  @param item The item in the Legend on which this event was triggered.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function LegendMouseEvent(type:String, triggerEvent:MouseEvent=null, 
												item:LegendItem=null)
	{	
		var eventType:String = convertType(type);
		var bubbles:Boolean = true;
		var cancelable:Boolean = false;
		var localX:int = 0;
		var localY:int = 0;
		var relatedObject:InteractiveObject = null;
		var ctrlKey:Boolean = false;
		var shiftKey:Boolean = false;
		var altKey:Boolean = false;
		var buttonDown:Boolean = false;
		var delta:int = 0;
			
		if (triggerEvent)
		{
        	bubbles = triggerEvent.bubbles;
			cancelable = triggerEvent.cancelable;
			localX = triggerEvent.localX;
			localY = triggerEvent.localY;
			relatedObject = triggerEvent.relatedObject;
			ctrlKey = triggerEvent.ctrlKey;
			altKey = triggerEvent.altKey;
			shiftKey = triggerEvent.shiftKey;
			buttonDown = triggerEvent.buttonDown;
			delta = triggerEvent.delta;
		}

		super(eventType, bubbles, cancelable, 
				localX, localY, relatedObject, 
				ctrlKey, altKey, shiftKey, 
				buttonDown, delta);

		this.item = item;
	}
	
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
	//  item
    //----------------------------------

	[Inspectable(environment="none")]

	/**
	 *  The item in the Legend on which this event was triggered.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var item:LegendItem;

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: event
    //
    //--------------------------------------------------------------------------

	/**
	 *	@private
	 */
	override public function clone():Event
	{
		return new LegendMouseEvent(type, this, item);
	}
}

}
