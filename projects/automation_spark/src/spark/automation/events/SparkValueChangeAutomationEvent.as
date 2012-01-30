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

package spark.automation.events
{
    
    import flash.events.Event;
    
    /**
     *  The SparkValueChangeAutomationEvent class represents event objects 
     *  that are dispatched when the value in a control changes. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public class SparkValueChangeAutomationEvent extends Event
    {
        
        include "../../core/Version.as";
        
        
        /**
         *  The <code>SparkValueChangeAutomationEvent.CHANGE</code> constant defines the value of the
         *  <code>type</code> property of the event object for an event that is
         *  dispatched when a value changes.
         *
         *  <p>The properties of the event object have the following values.
         *  Not all properties are meaningful for all kinds of events.
         *  See the detailed property descriptions for more information.</p>
         *  <table class="innertable">
         *     <tr><th>Property</th><th>Value</th></tr>
         *     <tr><td><code>bubbles</code></td><td>false</td></tr>
         *     <tr><td><code>cancelable</code></td><td>false</td></tr>
         *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
         *       event listener that handles the event. For example, if you use
         *       <code>myButton.addEventListener()</code> to register an event listener,
         *       myButton is the value of the <code>currentTarget</code>. </td></tr>
         *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
         *       it is not always the Object listening for the event.
         *       Use the <code>currentTarget</code> property to always access the
         *       Object listening for the event.</td></tr>
         *     <tr><td><code>triggerEvent</code></td><td>The event, such as a 
         *             mouse or keyboard event, that triggered the action.</td></tr>
         *     <tr><td><code>type</code></td><td>SparkValueChangeAutomationEvent.CHANGE</td></tr>
         *     <tr><td><code>value</code></td><td>The new value.</td></tr>
         *  </table>
         *
         *  @eventType change
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public static const CHANGE:String = "change";
        
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
        *  @param value The new value.
        *  
        *  @langversion 3.0
        *  @playerversion Flash 9
        *  @playerversion AIR 1.5
        *  @productversion Flex 4
        */
        public function SparkValueChangeAutomationEvent(type:String, bubbles:Boolean = false,
                                                        cancelable:Boolean = false,value:Number= -1)
        {
            super(type, bubbles, cancelable);
            this.value = value;
            
        }
        
        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------
        
        //----------------------------------
        //  change
        //----------------------------------
        
        /**
         *  The new value.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public var value:Number;
        
        
        
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
            return new SparkValueChangeAutomationEvent(type, bubbles, cancelable,value
            );
        }
    }
    
}
