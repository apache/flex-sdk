////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package mx.utils
{
    import flash.events.IEventDispatcher;
    import flash.events.Event;
    import flash.events.EventDispatcher;

	/**
	 * OnDemandEventDispatcher serves as a base class for classes that dispatch events but expect listeners
	 * to be infrequent.  When a class extends OnDemandEventDispatcher instead of the standard EventDispatcher,
	 * it is trading off a small overhead on every single instance for a slightly larger overhead on only the instances
	 * that actually have listeners attached to them.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
    public class OnDemandEventDispatcher implements IEventDispatcher
    {
        private var _dispatcher:EventDispatcher;
    

	//--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
        public function OnDemandEventDispatcher()
        {
        }

    /**
     *  @copy flash.events.EventDispatcher#addEventListener
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
        public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
        {
            if (_dispatcher == null)
            {
                _dispatcher = new EventDispatcher(this);
            }
            _dispatcher.addEventListener(type,listener,useCapture,priority,useWeakReference); 
        }
        
            
    /**
     *  @copy flash.events.EventDispatcher#dispatchEvent
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
        public function dispatchEvent(event:Event):Boolean
        {
            if (_dispatcher != null)
                return _dispatcher.dispatchEvent(event);
            return true; 
        }
    
    /**
     *  @copy flash.events.EventDispatcher#hasEventListener
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
        public function hasEventListener(type:String):Boolean
        {
            if (_dispatcher != null)
                return _dispatcher.hasEventListener(type);
            return false; 
        }
            
    /**
     *  @copy flash.events.EventDispatcher#removeEventListener
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
        public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
        {
            if (_dispatcher != null)
                _dispatcher.removeEventListener(type,listener,useCapture);         
        }
    
    /**
     *  @copy flash.events.EventDispatcher#willTrigger
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
        public function willTrigger(type:String):Boolean
        {
            if (_dispatcher != null)
                return _dispatcher.willTrigger(type);
            return false; 
        }

    }
}