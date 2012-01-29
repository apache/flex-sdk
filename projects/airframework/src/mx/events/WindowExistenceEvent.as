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


package mx.events
{
import flash.events.Event;

import mx.core.IWindow;

[ExcludeClass]

/**
 *  @private
 *  The WindowExistenceEvent class is used as a global event 
 *  when a window gets created or destroyed.
 * 
 *  @see mx.core.Window
 *  @see mx.core.WindowedApplication
 * 
 */
public class WindowExistenceEvent extends Event
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  The <code>WindowExistenceEvent.WINDOW_CREATE</code> constant defines the value of the 
     *  <code>type</code> property of the event object for a <code>globalNotifyWindowCreate</code> event. 
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
     *     <tr><td><code>window</code></td><td>The window object that 
     *       was created.</td></tr>
     *  </table>
     *
     *  @eventType globalNotifyWindowCreate
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const WINDOW_CREATE:String = "globalNotifyWindowCreate";
	
	/**
	 *  The <code>WindowExistenceEvent.WINDOW_CREATING</code> constant defines the value of the 
	 *  <code>type</code> property of the event object for a <code>globalNotifyWindowCreating</code> event. 
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
	 *     <tr><td><code>window</code></td><td>The window object that 
	 *       was created.</td></tr>
	 *  </table>
	 *
	 *  @eventType globalNotifyWindowCreating
	 *  
	 *  @langversion 3.0
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const WINDOW_CREATING:String = "globalNotifyWindowCreating";
    
        /**
     *  The <code>WindowExistenceEvent.WINDOW_CLOSE</code> constant defines the value of the 
     *  <code>type</code> property of the event object for a <code>globalNotifyWindowClose</code> event. 
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
     *     <tr><td><code>window</code></td><td>The window object that 
     *       was closed.</td></tr>
     *  </table>
     *
     *  @eventType globalNotifyWindowClose
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const WINDOW_CLOSE:String = "globalNotifyWindowClose";
    
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
     *  @param bubbles Specifies whether the event can bubble
     *  up the display list hierarchy.
     *
     *  @param cancelable Specifies whether the behavior
     *  associated with the event can be prevented.
     *
     *  @param window The window object that was created or closed
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function WindowExistenceEvent(type:String, bubbles:Boolean = false,
                                cancelable:Boolean = false, window:IWindow = null)
    {
        super(type, bubbles, cancelable);

        this.window = window;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The window that was created or destroyed
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var window:IWindow;

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
        return new WindowExistenceEvent(type, bubbles, cancelable, window);
    }
    
}
}