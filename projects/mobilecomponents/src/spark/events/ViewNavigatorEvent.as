////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.events
{
import flash.events.Event;

/**
 *  The ViewNavigatorEvent class represents event objects dispatched by the 
 *  View class.
 *
 *  @see spark.components.View
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class ViewNavigatorEvent extends Event
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The <code>ViewNavigatorEvent.REMOVING</code> constant defines the value of the
     *  <code>type</code> property of the event object for an <code>removing</code> 
     *  event.  This event is dispatched when a screen is about to be replaced by
     *  another screen through a navigator action.  If <code>preventDefault()</code>
     *  is called on this event, the view removal will be canceled.
     *
     *  <p>The properties of the event object have the following values:</p>
     * 
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>action</code></td><td>The navigation action committed 
     *        by the view navigator that resulted in the event.</td></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>true</td></tr>
     *     <tr><td><code>returnValue</code></td><td>null</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>Type</code></td><td>ViewNavigatorEvent.SCREEN_REMOVING</td></tr>
     *  </table>
     *
     *  @eventType removing
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const REMOVING:String = "removing";
    
    /**
     *  The <code>ViewNavigatorEvent.VIEW_ACTIVATE</code> constant defines the value of the
     *  <code>type</code> property of the event object for an <code>viewActivate</code> 
     *  event.  This event is dispatched when a component is activated.
     *
     *  <p>The properties of the event object have the following values:</p>
     * 
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>action</code></td><td>The navigation action committed 
     *        by the view navigator that resulted in the event.</td></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>returnValue</code></td><td>null</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>Type</code></td><td>ViewNavigatorEvent.VIEW_ACTIVATE</td></tr>
     *  </table>
     *
     *  @eventType activate
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const VIEW_ACTIVATE:String = "viewActivate";
    
    /**
     *  The <code>ViewNavigatorEvent.VIEW_DEACTIVATE</code> constant defines the value of the
     *  <code>type</code> property of the event object for an <code>viewDeactivate</code> 
     *  event.  This event is dispatched when a component is deactivated.
     *
     *  <p>The properties of the event object have the following values:</p>
     * 
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>action</code></td><td>The navigation action committed 
     *        by the view navigator that resulted in the event.</td></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>returnValue</code></td><td>null</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>Type</code></td><td>ViewNavigatorEvent.VIEW_DEACTIVATE</td></tr>
     *  </table>
     *
     *  @eventType deactivate
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const VIEW_DEACTIVATE:String = "viewDeactivate";
    
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
     *  @param bubbles Specifies whether the event can bubble up
     *  the display list hierarchy.
     *
     *  @param cancelable Specifies whether the behavior
     *  associated with the event can be prevented.
     *
     *  @param action The navigation action committed by the view navigator 
     *  that resulted in the event.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function ViewNavigatorEvent(type:String, bubbles:Boolean = false, 
                                       cancelable:Boolean = false,
                                       action:String = null)
    {
        super(type, bubbles, cancelable);
        
        this.action = action;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  action
    //----------------------------------
    
    /**
     *  The navigation action committed by the view navigator that resulted
     *  in the event.
     *  Possible actions include a view being activated or deactivated.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var action:String;
    
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
        return new ViewNavigatorEvent(type, bubbles, cancelable, action);
    }
}
}