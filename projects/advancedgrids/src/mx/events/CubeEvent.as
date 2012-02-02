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

/**
 *  Event class used by OLAPCube to indicate its status.
 *  The CubeEvent class represents event objects that are specific to
 *  the OLAPCube class, such as the event that is dispatched when an 
 *  cube is ready to be queried.
 *
 *  @see mx.olap.OLAPCube
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class CubeEvent extends Event
{
	//--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The <code>CubeEvent.QUERY_PROGRESS</code> constant defines the value of the 
     *  <code>type</code> property of the event object for a 
     *  <code>queryProgress</code> event.
     * 
     *  <p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
     *     <tr><td><code>cancelable</code></td><td><code>true</code></td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>description</code></td><td>Description of what is being processed.</td></tr>
     *     <tr><td><code>progress</code></td><td>The number of elements in the cube 
     *       that have been updated.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>total</code></td><td>The total number of elements in the cube 
     *       that need to be udpated.</td></tr>
     *     <tr><td><code>type</code></td><td>CubeEvent.QUERY_PROGRESS</td></tr>
     *  </table>
     *
     *  @eventType queryProgress
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const QUERY_PROGRESS:String = "queryProgress";
    
    /**
     *  The <code>CubeEvent.CUBE_PROGRESS</code> constant defines the value of the 
     *  <code>type</code> property of the event object for a 
     *  <code>progress</code> event.
     * 
     *  <p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
     *     <tr><td><code>cancelable</code></td><td><code>true</code></td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>description</code></td><td>Description of what is being processed.</td></tr>
     *     <tr><td><code>progress</code></td><td>The number of elements in the cube 
     *       that have been updated.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>total</code></td><td>The total number of elements in the cube 
     *       that need to be udpated.</td></tr>
     *     <tr><td><code>type</code></td><td>CubeEvent.CUBE_PROGRESS</td></tr>
     *  </table>
     *
     *  @eventType progress
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const CUBE_PROGRESS:String = "progress";

    /**
     *  The <code>CubeEvent.CUBE_COMPLETE</code> constant defines the value of the 
     *  <code>type</code> property of the event object for a 
     *  <code>complete</code> event.
     * 
     *  <p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
     *     <tr><td><code>cancelable</code></td><td><code>true</code></td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>description</code></td><td>Description of what is being processed.</td></tr>
     *     <tr><td><code>progress</code></td><td>The number of elements in the cube 
     *       that have been updated.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>total</code></td><td>The total number of elements in the cube 
     *       that need to be udpated.</td></tr>
     *     <tr><td><code>type</code></td><td>CubeEvent.CUBE_COMPLETE</td></tr>
     *  </table>
     *
     *  @eventType queryProgress
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const CUBE_COMPLETE:String = "complete";
    
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
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function CubeEvent(type:String)
    {
        super(type);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  progress
    //----------------------------------
    
    /**
     *  The number of elements in the cube that have been updated.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var progress:int;
    
    //----------------------------------
    //  total
    //----------------------------------
    
    /**
     *  The total number of elements in the cube that need to be udpated.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var total:int;
    
    //----------------------------------
    //  message
    //----------------------------------
    
    /**
     *  A description of what is being processed.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */     
    public var message:String;
}
}
