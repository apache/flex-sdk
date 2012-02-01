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
 *  The PopUpEvent class represents an event dispatched by the SkinnablePopUpContainer.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class PopUpEvent extends Event
{   
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The PopUpEvent.OPEN constant defines the value of the 
     *  <code>type</code> property of the PopUpEvent object for an
     *  <code>open</code> event.
     *
     *  <p>The properties of the event object have the following values:</p>
     * 
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>commit</code></td><td>Not used</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>Data</code></td><td>Not used</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>Type</code></td><td>PopUpEvent.OPEN</td></tr>
     *  </table>
     *
     *  @eventType open
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const OPEN:String = "open";

    /**
     *  The PopUpEvent.CLOSE constant defines the value of the 
     *  <code>type</code> property of the PopUpEvent object for an
     *  <code>close</code> event.
     *
     *  <p>The properties of the event object have the following values:</p>
     * 
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>commit</code></td><td>Specifies whether the listener 
     *       should commit the data.</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>Data</code></td><td>Any data returned to the application 
     *       from the SkinnablePopUpContainer.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>Type</code></td><td>PopUpEvent.OPEN</td></tr>
     *  </table>
     *
     *  @eventType close
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static const CLOSE:String = "close";
    
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
     *  @param commit Specifies whether the listener should commit the data from the SkinnablePopUpContainer.
     *  Only used with the <code>PopUpEvent.CLOSE</code> event.
     * 
     *  @param data The data to commit. Only used with the <code>PopUpEvent.CLOSE</code> event.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function PopUpEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, 
                               commit:Boolean = false, data:* = undefined)
    {
        super(type, bubbles, cancelable);
        this.commit = commit;
        this.data = data;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  commit
    //----------------------------------
    
    /**
     *  Specifies whether the event listener should commit the data
     *  returned in the <code>data</code> property.
     *  Only used with <code>PopUpEvent.CLOSE</code> event.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var commit:Boolean;

    //----------------------------------
    //  data
    //----------------------------------
    
    /**
     *  The data to commit.
     *  Only used with <code>PopUpEvent.CLOSE</code> event.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var data:*;
    
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
        return new PopUpEvent(type, bubbles, cancelable, commit, data);
    }
}

}
