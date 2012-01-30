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

package mx.automation.events
{
	
	import flash.events.Event;
	
	/**
	 * The TextSelectionEvent class lets you track selection within a text field.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class TextSelectionEvent extends Event
	{
		include "../../core/Version.as";
		
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  The <code>TextSelectionEvent.TEXT_SELECTION_CHANGE</code> constant defines the value of the 
		 *  <code>type</code> property of the event object for a <code>textSelectionChange</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>beginIndex</code></td><td>Index at which selection starts.</td></tr>
		 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
		 *     <tr><td><code>cancelable</code></td><td>false</td></tr>
		 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
		 *       event listener that handles the event. For example, if you use 
		 *       <code>myButton.addEventListener()</code> to register an event listener, 
		 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
		 *     <tr><td><code>endIndex</code></td><td>Index at which selection ends.</td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
		 *       it is not always the Object listening for the event. 
		 *       Use the <code>currentTarget</code> property to always access the 
		 *       Object listening for the event.</td></tr>
		 *  </table>
		 *
		 *  @eventType textSelectionChange
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public static const TEXT_SELECTION_CHANGE:String = "textSelectionChange";
		
		//--------------------------------------------------------------------------
		//
		//  Properties
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
		 *  @param beginIndex Index at which selection starts.
		 *  
		 *  @param endIndex Index at which selection ends.
		 *  
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function TextSelectionEvent(type:String = "textSelectionChange",
										   bubbles:Boolean = false,
										   cancelable:Boolean = false,
										   beginIndex:int = -1,
										   endIndex:int = -1)
		{
			super(type, bubbles, cancelable);
			
			this.beginIndex = beginIndex;
			this.endIndex = endIndex;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  beginIndex
		//----------------------------------
		
		/**
		 *  Index at which selection starts.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public var beginIndex:int;
		
		//----------------------------------
		//  endIndex
		//----------------------------------
		
		/**
		 *  Index at which selection ends.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public var endIndex:int;
		
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
			return new TextSelectionEvent(type, bubbles, cancelable, 
				beginIndex, endIndex);
		}    
	}
	
}
