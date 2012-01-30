
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

package mx.automation.events
{ 
    import flash.display.DisplayObject;
    import flash.events.Event;
    
    /**
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public class EventDetails
    {
       /**
        *  
        *  @langversion 3.0
        *  @playerversion Flash 10
        *  @playerversion AIR 1.5
        *  @productversion Flex 4
        */
        public var eventType:String;

       /**
        *  
        *  @langversion 3.0
        *  @playerversion Flash 10
        *  @playerversion AIR 1.5
        *  @productversion Flex 4
        */
        public var handlerFunction:Function;

       /**
        *  
        *  @langversion 3.0
        *  @playerversion Flash 10
        *  @playerversion AIR 1.5
        *  @productversion Flex 4
        */
        public var useCapture:Boolean;

       /**
        *  
        *  @langversion 3.0
        *  @playerversion Flash 10
        *  @playerversion AIR 1.5
        *  @productversion Flex 4
        */
        public var priority:int;

       /**
        *  
        *  @langversion 3.0
        *  @playerversion Flash 10
        *  @playerversion AIR 1.5
        *  @productversion Flex 4
        */
        public var useWeekRef:Boolean;
        
       /**
        *  
        *  @langversion 3.0
        *  @playerversion Flash 10
        *  @playerversion AIR 1.5
        *  @productversion Flex 4
        */
        public function EventDetails(type:String, handler:Function,
                                     useCapture:Boolean= false,
                                     priority:int = 0, useWeekReferance:Boolean= false )
        {
            this.eventType = type;
            this.handlerFunction = handler;
            this.useCapture = useCapture;
            this.priority = priority;
            this.useWeekRef = useWeekReferance;
        }
        
    }
}