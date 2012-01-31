////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package mx.events
{

import flash.events.Event;

/**
 *  The CuePointEvent class represents the event object passed to the event listener for 
 *  cue point events dispatched by the VideoDisplay control.
 *
 *  @see mx.controls.VideoDisplay
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class CuePointEvent extends Event
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	// Class constants
	//
	//--------------------------------------------------------------------------

	/**
	 *  The <code>CuePointEvent.CUE_POINT</code> constant defines the value of the 
	 *  <code>type</code> property of the event object for a <code>cuePoint</code> event.
	 * 
     *	<p>The properties of the event object have the following values:</p>
	 *  <table class="innertable">
	 *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>cuePointName</code></td><td>The name of the cue point.</td></tr>
     *     <tr><td><code>cuePointTime</code></td><td>The time of the cue point, in seconds.</td></tr>
     *     <tr><td><code>cuePointType</code></td><td>The string 
     *       <code>"actionscript"</code>.</td></tr>
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
	 *  @eventType cuePoint
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const CUE_POINT:String = "cuePoint";	

	//--------------------------------------------------------------------------
	//
	// Constructor
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
	 *  @param cuePointName The name of the cue point.
	 *
	 *  @param cuePointTime The time of the cue point, in seconds.
	 *
	 *  @param cuePointType The string <code>"actionscript"</code>.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function CuePointEvent(type:String, bubbles:Boolean = false,
								  cancelable:Boolean = false, 
								  cuePointName:String = null,
								  cuePointTime:Number = NaN,
								  cuePointType:String = null)
	{
		super(type, bubbles, cancelable);

		this.cuePointName = cuePointName;
		this.cuePointTime = cuePointTime;
		this.cuePointType = cuePointType;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  cuePointName
	//----------------------------------

	/**
	 *  The name of the cue point that caused the event.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var cuePointName:String;

	//----------------------------------
	//  cuePointTime
	//----------------------------------

	/**
	 *  The time of the cue point that caused the event, in seconds.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var cuePointTime:Number;

	//----------------------------------
	//  cuePointType
	//----------------------------------

	/**
	 *  The string <code>"actionscript"</code>.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var cuePointType:String;

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
		return new CuePointEvent(type, bubbles, cancelable, 
								 cuePointName, cuePointTime, cuePointType);
	}
}

}
