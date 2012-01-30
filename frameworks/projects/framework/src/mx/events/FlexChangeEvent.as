////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2006-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.events
{
import flash.events.Event;

[ExcludeClass]

/**
 *  @private
 *  The FlexChangeEvent class represents the event object passed to
 *  an event listener for Flex events that have data associated with
 *  some change in Flex. The <code>data</code> property provides 
 *  additional information about the event.
 *  
 */
public class FlexChangeEvent extends Event
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  The <code>FlexChangeEvent.ADD_CHILD_BRIDGE</code> constant defines the value of the
     *  <code>type</code> property of the event object for an <code>addChildBridge</code> event.
     *
     *  This event is dispatch by a SystemManager after a child SWFBridge has been added. This 
     *  event's <code>data</code> property is a reference to the added SWFBridge.
     * 
     *  added to the SystemManager.
     * 
     *  <p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
     *       event listener that handles the event. For example, if you use
     *       <code>myButton.addEventListener()</code> to register an event listener,
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
     *       it is not always the Object listening for the event.
     *       Use the <code>currentTarget</code> property to always access the
     *       Object listening for the event.</td></tr>
     *  </table>
     *
     *  @eventType addChildBridge
     */
    public static const ADD_CHILD_BRIDGE:String = "addChildBridge";

    /**
     *  The <code>FlexChangeEvent.REMOVE_CHILD_BRIDGE</code> constant defines the value of the
     *  <code>type</code> property of the event object for an <code>removeChildBridge</code> event.
     *
     *  This event is dispatch by a SystemManager just before a child SWFBridge is removed. This 
     *  event's <code>data</code> property is a reference to the removed SWFBridge.
     * 
     *  <p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
     *       event listener that handles the event. For example, if you use
     *       <code>myButton.addEventListener()</code> to register an event listener,
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
     *       it is not always the Object listening for the event.
     *       Use the <code>currentTarget</code> property to always access the
     *       Object listening for the event.</td></tr>
     *  </table>
     *
     *  @eventType removeChildBridge
     */
    public static const REMOVE_CHILD_BRIDGE:String = "removeChildBridge";


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
     *  @param data Data related to the event.
     */ 
    public function FlexChangeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:Object = null)
    {
        super(type, bubbles, cancelable);
        
        this.data = data;
    }
        
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  data
    //----------------------------------

    /**
     *  Data related to the event. For more information on this object, see each event type.
     */
    public var data:Object;
    
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
        return new FlexChangeEvent(type, bubbles, cancelable, data);
    }

}
}