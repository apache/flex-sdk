////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
///////////////////////////////////////////////////////////////////////////////

package spark.events 
{

import flash.events.Event;

/**
 *  The VideoEvent class represents the event object passed to the event listener for 
 *  events dispatched by the video control.
 *
 *  @see spark.components.VideoPlayer 
 *  @see spark.primitives.VideoElement
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class VideoEvent extends Event 
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The <code>VideoEvent.CLOSE</code> constant defines the value of the 
     *  <code>type</code> property of the event object for a <code>close</code> event.
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
     *     <tr><td><code>metadataInfo</code></td><td>If the event was triggerred from 
     *       new metadata, an object describing the FLV file.</td></tr>
     *     <tr><td><code>playheadTime</code></td><td>The location of the playhead 
     *       when the event occurs.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *  </table>
     *
     *  @eventType close
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const CLOSE:String = "close";
    
    /**
     *  The <code>VideoEvent.COMPLETE</code> constant defines the value of the 
     *  <code>type</code> property of the event object for a <code>complete</code> event.
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
     *     <tr><td><code>metadataInfo</code></td><td>If the event was triggerred from 
     *       new metadata, an object describing the FLV file.</td></tr>
     *     <tr><td><code>playheadTime</code></td><td>The location of the playhead 
     *       when the event occurs.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *  </table>
     *
     *  @eventType complete
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */    
    public static const COMPLETE:String = "complete";
    
    /**
     * The VideoEvent.METADATA_RECEIVED constant defines the value of the 
     * <code>type</code> property for a <code>metadataReceived</code> event.
     *
     * <p>This event has the following properties:</p>
     * <table class="innertable" width="100%">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
     *     <tr><td><code>cancelable</code></td><td><code>false</code>; 
     *        there is no default behavior to cancel.</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>metadataInfo</code></td><td>If the event was triggerred from 
     *       new metadata, an object describing the FLV file.</td></tr>
     *     <tr><td><code>playheadTime</code></td><td>The location of the playhead 
     *       when the event occurs.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>  
     * </table>
     * 
     *  @eventType metadataReceived
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const METADATA_RECEIVED:String = "metadataReceived";
     
    /**
     *  The <code>VideoEvent.PLAYHEAD_UPDATE</code> constant defines the value of the 
     *  <code>type</code> property of the event object for a <code>playheadUpdate</code> event.
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
     *     <tr><td><code>metadataInfo</code></td><td>If the event was triggerred from 
     *       new metadata, an object describing the FLV file.</td></tr>
     *     <tr><td><code>playheadTime</code></td><td>The location of the playhead 
     *       when the event occurs.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *  </table>
     *
     *  @eventType playheadUpdate
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */    
    public static const PLAYHEAD_UPDATE:String = "playheadUpdate"; 
       
    /**
     *  The <code>VideoEvent.READY</code> constant defines the value of the 
     *  <code>type</code> property of the event object for a <code>ready</code> event.
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
     *     <tr><td><code>metadataInfo</code></td><td>If the event was triggerred from 
     *       new metadata, an object describing the FLV file.</td></tr>
     *     <tr><td><code>playheadTime</code></td><td>The location of the playhead 
     *       when the event occurs.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *  </table>
     *
     *  @eventType ready
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */         
    public static const READY:String = "ready";
    
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
     *  @param cancelable Specifies whether the behavior associated with 
     *  the event can be prevented.
     *
     *  @param playeheadTime The location of the playhead when the event occurs.   
     *
     *  @param metadataInfo The metadata information object with properties 
     *  describing the FLV file.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function VideoEvent(type:String, bubbles:Boolean = false,
                               cancelable:Boolean = false,
                               playheadTime:Number = NaN, 
                               metadataInfo:Object = null) 
    {
        super(type, bubbles, cancelable);

        this.playheadTime = playheadTime;
        this.metadataInfo = metadataInfo;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  metadataInfo
    //----------------------------------

    /**
     *  The metadata information object with properties describing the FLV file.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */    
    public var metadataInfo:Object;

    //----------------------------------
    //  playheadTime
    //----------------------------------

    /**
     *  The location of the playhead of the video control 
     *  when the event occurs.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */   
    public var playheadTime:Number;

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
        return new VideoEvent(type, bubbles, cancelable, 
                              playheadTime, metadataInfo);
    }
}

}
