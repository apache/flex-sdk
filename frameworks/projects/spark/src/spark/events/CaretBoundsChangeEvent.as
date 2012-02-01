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
import flash.geom.Rectangle;


[ExcludeClass]

/**
 *  @private 
 * 
 *  The CaretBoundsChangeEvent class is dispatched when the caret bounds of a text
 *  component has changed
 *
 *  @see spark.components.TextArea
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class CaretBoundsChangeEvent extends Event
{
    /**
     *  Constructor
     */  
    public function CaretBoundsChangeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, oldCaretBounds:Rectangle=null, newCaretBounds:Rectangle=null)
    {
        this.oldCaretBounds = oldCaretBounds;
        this.newCaretBounds = newCaretBounds;
        super(type, bubbles, cancelable);
    }
    
    /**
     *  The <code>CaretBoundsChangeEvent.CARET_BOUNDS_CHANGE</code> constant defines the value of the
     *  <code>type</code> property of the event object for a <code>caretBoundsChange</code> 
     *  event.  
     *
     *  <p>The properties of the event object have the following values:</p>
     * 
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>true</td></tr>
     *     <tr><td><code>oldCaretBounds</code></td><td>null</td></tr>
     *     <tr><td><code>newCaretBounds</code></td><td>null</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>Type</code></td><td>CaretBoundsChangeEvent.CARET_BOUNDS_CHANGE</td></tr>
     *  </table>
     *
     *  @eventType removing
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static var CARET_BOUNDS_CHANGE:String = "caretBoundsChange";
    
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  oldCaretBounds
    //----------------------------------
    /**
     * @private
     * The old bounds of the caret in the target's coordinate space
     */   
    public var oldCaretBounds:Rectangle;
    
    
    //----------------------------------
    //  newCaretBounds
    //----------------------------------
    /**
     * @private
     * The new bounds of the caret in the target's coordinate space
     */ 
    public var newCaretBounds:Rectangle; 
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: Event
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     */
    override public function clone():Event
    {
        return new CaretBoundsChangeEvent(
            type, bubbles, cancelable, 
            oldCaretBounds, newCaretBounds);
    }
}
}