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
 *  Represents event objects that are involved with touch scrolling.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class TouchScrollEvent extends Event
{
    
    /**
     *  The <code>TouchScrollEvent.TOUCH_SCROLL_STARTING</code> constant defines the value of the
     *  <code>type</code> property of the event object for a <code>touchScrollStarting</code> event.
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
     *     <tr><td><code>scrollingObject</code></td><td>The object that owns this particular 
     *       scroll gesture</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
     *       it is not always the Object listening for the event.
     *       Use the <code>currentTarget</code> property to always access the
     *       Object listening for the event.</td></tr>
     *  </table>
     *
     *  @eventType touchScrollStarting
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const TOUCH_SCROLL_STARTING:String = "touchScrollStarting";
    
    /**
     *  The <code>TouchScrollEvent.TOUCH_SCROLL_START</code> constant defines the value of the
     *  <code>type</code> property of the event object for a <code>touchScrollStart</code> event.
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
     *     <tr><td><code>scrollingObject</code></td><td>The object that owns this particular 
     *       scroll gesture</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
     *       it is not always the Object listening for the event.
     *       Use the <code>currentTarget</code> property to always access the
     *       Object listening for the event.</td></tr>
     *  </table>
     *
     *  @eventType touchScrollStart
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const TOUCH_SCROLL_START:String = "touchScrollStart";
    
    /**
     *  The <code>TouchScrollEvent.TOUCH_SCROLL_DRAG</code> constant defines the value of the
     *  <code>type</code> property of the event object for a <code>touchScrollDrag</code> event.
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
     *     <tr><td><code>dragX</code></td><td>The number of pixels dragged in the x-axis since the 
     *       gesture has started</td></tr>
     *     <tr><td><code>dragY</code></td><td>The number of pixels dragged in the y-axis since the 
     *       gesture has started</td></tr>
     *     <tr><td><code>scrollingObject</code></td><td>The object that owns this particular 
     *       scroll gesture</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
     *       it is not always the Object listening for the event.
     *       Use the <code>currentTarget</code> property to always access the
     *       Object listening for the event.</td></tr>
     *  </table>
     *
     *  @eventType touchScrollDrag
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const TOUCH_SCROLL_DRAG:String = "touchScrollDrag";
    
    /**
     *  The <code>TouchScrollEvent.TOUCH_SCROLL_THROW</code> constant defines the value of the
     *  <code>type</code> property of the event object for a <code>touchScrollThrow</code> event.
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
     *     <tr><td><code>scrollingObject</code></td><td>The object that owns this particular 
     *       scroll gesture</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
     *       it is not always the Object listening for the event.
     *       Use the <code>currentTarget</code> property to always access the
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>velocityX</code></td><td>The velocity (pixels/msec) the user threw the list 
     *       in the x-axis</td></tr>
     *     <tr><td><code>velocityY</code></td><td>The velocity (pixels/msec) the user threw the list 
     *       in the y-axis</td></tr>
     *  </table>
     *
     *  @eventType touchScrollThrow
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const TOUCH_SCROLL_THROW:String = "touchScrollThrow";
    
    // FIXME (rfrishbe): Make this public and document it or make it internal
    public static const TOUCH_SCROLL_THROW_ANIMATION_END:String = "touchScrollThrowAnimationEnd";
    
    /**
     *  The <code>TouchScrollEvent.TOUCH_SCROLL_END</code> constant defines the value of the
     *  <code>type</code> property of the event object for a <code>touchScrollEnd</code> event.
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
     *     <tr><td><code>scrollingObject</code></td><td>The object that owns this particular 
     *       scroll gesture</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
     *       it is not always the Object listening for the event.
     *       Use the <code>currentTarget</code> property to always access the
     *       Object listening for the event.</td></tr>
     *  </table>
     *
     *  @eventType touchScrollStart
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const TOUCH_SCROLL_END:String = "touchScrollEnd";
    
    
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
    public function TouchScrollEvent(type:String, bubbles:Boolean = false,
                                     cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
    }
    
    //----------------------------------
    //  dragX
    //----------------------------------
    
    /**
     *  The number of pixels dragged in the x-axis since the 
     *  gesture has started
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var dragX:Number;
    
    //----------------------------------
    //  dragY
    //----------------------------------
    
    /**
     *  The number of pixels dragged in the y-axis since the 
     *  gesture has started
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var dragY:Number;
    
    //----------------------------------
    //  scrollingObject
    //----------------------------------
    
    /**
     *  The object that owns this particular 
     *  scroll gesture
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var scrollingObject:DisplayObject;
    
    //----------------------------------
    //  velocityX
    //----------------------------------
    
    /**
     *  The velocity (pixels/msec) the user threw the list 
     *  in the x-axis
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var velocityX:Number;
    
    //----------------------------------
    //  velocityY
    //----------------------------------
    
    /**
     *  The velocity (pixels/msec) the user threw the list 
     *  in the y-axis
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var velocityY:Number;
    
    /**
     *  @private
     */
    override public function clone():Event
    {
        var clonedEvent:TouchScrollEvent = new TouchScrollEvent(type, bubbles, cancelable);
        
        clonedEvent.dragX = dragX;
        clonedEvent.dragY = dragY;
        clonedEvent.velocityX = velocityX;
        clonedEvent.velocityY = velocityY;
        clonedEvent.scrollingObject = scrollingObject;
        
        return clonedEvent;
    }
}
}