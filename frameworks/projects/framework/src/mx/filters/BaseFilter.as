////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.filters
{
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.Event;

   /**
    *  Base class for some Spark filters.
    * 
    *  @langversion 3.0
    *  @playerversion Flash 10
    *  @playerversion AIR 1.5
    *  @productversion Flex 4
    */     
    public class BaseFilter extends EventDispatcher
    {
       /**
        *  The string <code>"change"</code>. Used by the event when the filter has changed.
        * 
        *  @langversion 3.0
        *  @playerversion Flash 10
        *  @playerversion AIR 1.5
        *  @productversion Flex 4
        */     
        public static const CHANGE:String = "change";       
        
       /**
        *  Constructor.
        * 
        *  @param target The target to which the filter is applied.
        * 
        *  @langversion 3.0
        *  @playerversion Flash 10
        *  @playerversion AIR 1.5
        *  @productversion Flex 4
        */     
        public function BaseFilter(target:IEventDispatcher=null)
        {
            super(target);
        }
        
       /**
        *  Propagates a change event when the filter has changed.
        * 
        *  @langversion 3.0
        *  @playerversion Flash 10
        *  @playerversion AIR 1.5
        *  @productversion Flex 4
        */     
        public function notifyFilterChanged():void
        {
            dispatchEvent(new Event(CHANGE));
        }
        
    }
}