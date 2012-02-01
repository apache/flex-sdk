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

package spark.events
{
import flash.display.DisplayObject;
import flash.events.Event;

[ExcludeClass]

/**
 *  The DisplayLayerExistanceEvent class represents events that are dispatched when 
 *  an object is added to or removed from a DisplayLayer. 
 *
 *  @see spark.components.supportClasses.DisplayLayerObjectExistenceEvent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class DisplayLayerObjectExistenceEvent extends Event
{
	include "../core/Version.as";
	
	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  The <code>DisplayLayerExistanceEvent.OBJECT_ADD</code> constant 
	 *  defines the value of the <code>type</code> property of the event 
	 *  object for an <code>objectAdd</code> event.
	 *
	 *  <p>The properties of the event object have the following values:</p>
	 *  <table class="innertable">
	 *     <tr><th>Property</th><th>Value</th></tr>
	 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
	 *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	 *       event listener that handles the event. For example, if you use 
	 *       <code>myGroup.addEventListener()</code> to register an event listener, 
	 *       myGroup is the value of the <code>currentTarget</code>. </td></tr>
	 *     <tr><td><code>object</code></td><td>Contains a reference
	 *         to the object that was added.</td></tr>
	 *     <tr><td><code>index</code></td><td>The index where the 
	 *       object that was added.</td></tr>
	 *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	 *       it is not always the Object listening for the event. 
	 *       Use the <code>currentTarget</code> property to always access the 
	 *       Object listening for the event.</td></tr>
	 *  </table>
	 *
	 *  @eventType objectAdd
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public static const OBJECT_ADD:String = "objectAdd";
	
	/**
	 *  The <code>DisplayLayer.OBJECT_REMOVE</code> constant 
	 *  defines the value of the <code>type</code> property of the event 
	 *  object for an <code>objectRemove</code> event.
	 *
	 *  <p>The properties of the event object have the following values:</p>
	 *  <table class="innertable">
	 *     <tr><th>Property</th><th>Value</th></tr>
	 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
	 *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	 *       event listener that handles the event. For example, if you use 
	 *       <code>myGroup.addEventListener()</code> to register an event listener, 
	 *       myGroup is the value of the <code>currentTarget</code>. </td></tr>
	 *     <tr><td><code>object</code></td><td>A reference
	 *        to the object that is about to be removed.</td></tr>
	 *     <tr><td><code>index</code></td><td>The index of 
	 *       object that is being removed.</td></tr>
	 *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	 *       it is not always the Object listening for the event. 
	 *       Use the <code>currentTarget</code> property to always access the 
	 *       Object listening for the event.</td></tr>
	 *  </table>
	 *
	 *  @eventType objectRemove
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public static const OBJECT_REMOVE:String = "objectRemove";
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  Constructor.
	 *
	 *  @param type The event type; indicates the action that caused the event.
	 *
	 *  @param bubbles Specifies whether the event can bubble up the display list hierarchy.
	 *
	 *  @param cancelable Specifies whether the behavior associated with the event can be prevented.
	 *
	 *  @param object Reference to the object that was added or removed.
	 * 
	 *  @param index The index where the object was added or removed.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function DisplayLayerObjectExistenceEvent(
		type:String, bubbles:Boolean = false,
		cancelable:Boolean = false,
		object:DisplayObject = null, 
		index:int = -1)
	{
		super(type, bubbles, cancelable);
		
		this.object = object;
		this.index = index;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  index
	//----------------------------------
	
	/**
	 *  The index where the object was added or removed.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public var index:int;
	
	//----------------------------------
	//  object
	//----------------------------------
	
	/**
	 *  Reference to the object that was added or removed.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public var object:DisplayObject;
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods: Event
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @private
	 */
	override public function clone():Event
	{
		return new DisplayLayerObjectExistenceEvent(type, bubbles, cancelable,
			object, index);
	}
}
}
