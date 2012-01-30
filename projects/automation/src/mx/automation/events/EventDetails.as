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
    import flash.display.DisplayObject;
    import flash.events.Event;
    
    /**
     *  Holds the details of an event like its type, handler etc...
	 * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public class EventDetails
    {
       /**
        *  Type of the event
		*
        *  @langversion 3.0
        *  @playerversion Flash 10
        *  @playerversion AIR 1.5
        *  @productversion Flex 4
        */
        public var eventType:String;

       /**
        *  Handler function that processes the event
		*
        *  @langversion 3.0
        *  @playerversion Flash 10
        *  @playerversion AIR 1.5
        *  @productversion Flex 4
        */
        public var handlerFunction:Function;

       /**
        *  Determines whether the listener works in the capture phase or the target and bubbling phases.
		*  @default false
		*
        *  @langversion 3.0
        *  @playerversion Flash 10
        *  @playerversion AIR 1.5
        *  @productversion Flex 4
        */
        public var useCapture:Boolean;

       /**
        *  The priority level of the event listener.
		*  @default 0
		*
        *  @langversion 3.0
        *  @playerversion Flash 10
        *  @playerversion AIR 1.5
        *  @productversion Flex 4
        */
        public var priority:int;

       /**
        *  Determines whether the reference to the listener is strong or weak. 
		*  strong reference (the default) prevents your listener from being garbage-collected. 
		*  weak reference does not.
		*  @default false
		* 
        *  @langversion 3.0
        *  @playerversion Flash 10
        *  @playerversion AIR 1.5
        *  @productversion Flex 4
        */
        public var useWeekRef:Boolean;
        
       /**
        *  Constructor
		*  @param type The event type; indicates the action that caused the event.
        *  
        *  @param handler Handler function that processes the event.
		*  
		*  @param useCapture Determines whether the listener works in the capture phase or the target and bubbling phases.
        *
        *  @param priority The priority level of the event listener.
        *  
        *  @param useWeakReference Determines whether the reference to the listener is strong or weak. 
		*  strong reference (the default) prevents your listener from being garbage-collected. 
		*  weak reference does not.
        * 
		*  @langversion 3.0
        *  @playerversion Flash 10
        *  @playerversion AIR 1.5
        *  @productversion Flex 4
        */
        public function EventDetails(type:String, handler:Function,
                                     useCapture:Boolean= false,
                                     priority:int = 0, useWeakReference:Boolean= false )
        {
            this.eventType = type;
            this.handlerFunction = handler;
            this.useCapture = useCapture;
            this.priority = priority;
            this.useWeekRef = useWeakReference;
        }
        
    }
}