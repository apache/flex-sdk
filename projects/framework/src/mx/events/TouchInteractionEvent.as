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

package mx.events
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Point;

/**
 *  GestureCaptureEvents are used to coordinate gestures recognition and response 
 *  among different components.  
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class GestureCaptureEvent extends Event
{
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The <code>GestureCaptureEvent.GESTURE_CAPTURE_STARTING</code> constant defines the value of the
     *  <code>type</code> property of the event object for a <code>gestureCaptureStarting</code> event.
     *
     *	<p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
     *     <tr><td><code>cancelable</code></td><td>true</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
     *       event listener that handles the event. For example, if you use
     *       <code>myButton.addEventListener()</code> to register an event listener,
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>reason</code></td><td>The reason for the gesture capture event.  See 
     *       <code>mx.events.GestureCaptureReason</code>.</td></tr>
     *     <tr><td><code>relatedObject</code></td><td>The object associated with this gesture capture event.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
     *       it is not always the Object listening for the event.
     *       Use the <code>currentTarget</code> property to always access the
     *       Object listening for the event.</td></tr>
     *  </table>
     *
     *  @eventType gestureCaptureStarting
     *  @see mx.events.GestureCaptureReason
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const GESTURE_CAPTURE_STARTING:String = "gestureCaptureStarting";
    
    /**
     *  The <code>GestureCaptureEvent.GESTURE_CAPTURE_START</code> constant defines the value of the
     *  <code>type</code> property of the event object for a <code>gestureCaptureStart</code> event.
     *
     *	<p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>true</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
     *       event listener that handles the event. For example, if you use
     *       <code>myButton.addEventListener()</code> to register an event listener,
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>reason</code></td><td>The reason for the gesture capture event.  See 
     *       <code>mx.events.GestureCaptureReason</code>.</td></tr>
     *     <tr><td><code>relatedObject</code></td><td>The object associated with this gesture capture event.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
     *       it is not always the Object listening for the event.
     *       Use the <code>currentTarget</code> property to always access the
     *       Object listening for the event.</td></tr>
     *  </table>
     *
     *  @eventType gestureCaptureStart
     *  @see mx.events.GestureCaptureReason
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const GESTURE_CAPTURE_START:String = "gestureCaptureStart";
    
    /**
     *  The <code>GestureCaptureEvent.GESTURE_CAPTURE_END</code> constant defines the value of the
     *  <code>type</code> property of the event object for a <code>gestureCaptureEnd</code> event.
     *
     *	<p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
     *       event listener that handles the event. For example, if you use
     *       <code>myButton.addEventListener()</code> to register an event listener,
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>reason</code></td><td>The reason for the gesture capture event.  See 
     *       <code>mx.events.GestureCaptureReason</code>.</td></tr>
     *     <tr><td><code>relatedObject</code></td><td>The object associated with this gesture capture event.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
     *       it is not always the Object listening for the event.
     *       Use the <code>currentTarget</code> property to always access the
     *       Object listening for the event.</td></tr>
     *  </table>
     *
     *  @eventType gestureCaptureEnd
     *  @see mx.events.GestureCaptureReason
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const GESTURE_CAPTURE_END:String = "gestureCaptureEnd";
    
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
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function GestureCaptureEvent(type:String, bubbles:Boolean = false,
                                        cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  reason
    //----------------------------------
    
    /**
     *  The reason for this geture capture event.
     * 
     *  @see mx.events.GestureCaptureReason
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var reason:String;
    
    //----------------------------------
    //  relatedObject
    //----------------------------------
    
    /**
     *  The object attempting to capture this user gesture.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var relatedObject:Object;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function clone():Event
    {
        var clonedEvent:GestureCaptureEvent = new GestureCaptureEvent(type, bubbles, cancelable);
        
        clonedEvent.reason = reason;
        clonedEvent.relatedObject = relatedObject;
        
        return clonedEvent;
    }
}
}