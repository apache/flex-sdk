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
 *  The DateChooserEvent class represents the event object passed to 
 *  the event listener for the <code>scroll</code> event for 
 *  the DateChooser and DateField controls.
 *
 *  @see mx.controls.DateChooser
 *  @see mx.controls.DateField
 *  @see mx.events.DateChooserEventDetail
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class DateChooserEvent extends Event
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	/**
	 *  The <code>DateChooserEvent.SCROLL</code> constant defines the value of the 
	 *  <code>type</code> property of the event object for a <code>scroll</code>event.
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
     *     <tr><td><code>detail</code></td><td>The scroll direction.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>triggerEvent</code></td><td>The event that triggered this change event;
	 *       usually a <code>scroll</code>.</td></tr>
	 *  </table>
	 *
     *  @eventType scroll
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const SCROLL:String = "scroll";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 *  Normally called by the DateChooser object and not used in application code.
	 *
	 *  @param type The event type; indicates the action that triggered the event.
	 *
	 *  @param bubbles Specifies whether the event can bubble up the display list hierarchy.
	 *
	 *  @param cancelable Specifies whether the behavior associated with the event can be prevented.
	 *
	 *  @param detail Indicates the unit and direction of scrolling.
	 *  The possible values are
	 *  <code>DateChooserEventDetail.NEXT_MONTH</code>,
	 *  <code>DateChooserEventDetail.NEXT_YEAR</code>,
	 *  <code>DateChooserEventDetail.PREVIOUS_MONTH</code>, or
	 *  <code>DateChooserEventDetail.PREVIOUS_YEAR</code>.
	 *
	 *  @param triggerEvent The event that triggered this change event;
	 *   usually a <code>scroll</code>.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function DateChooserEvent(type:String, bubbles:Boolean = false,
									 cancelable:Boolean = false,
									 detail:String = null,
                                     triggerEvent:Event = null)
	{
		super(type, bubbles, cancelable);

		this.detail = detail;
		this.triggerEvent = triggerEvent;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  detail
	//----------------------------------

	/**
     *  Indicates the direction of scrolling. The values are defined by 
     *  the DateChooserEventDetail class.
	 *  The possible values are
	 *  <code>DateChooserEventDetail.NEXT_MONTH</code>,
	 *  <code>DateChooserEventDetail.NEXT_YEAR</code>,
	 *  <code>DateChooserEventDetail.PREVIOUS_MONTH</code>, or
	 *  <code>DateChooserEventDetail.PREVIOUS_YEAR</code>.
	 *
	 *  @see mx.events.DateChooserEventDetail
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var detail:String;

	//----------------------------------
	//  triggerEvent
	//----------------------------------

	/**
	 *  The event that triggered this change;
	 *  usually a <code>scroll</code>.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var triggerEvent:Event;

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
		return new DateChooserEvent(type, bubbles, cancelable,
									detail, triggerEvent);
	}
}

}
