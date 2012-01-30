package mx.filters
{
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.Event;

   /**
    *  
    *  @langversion 3.0
    *  @playerversion Flash 10
    *  @playerversion AIR 1.5
    *  @productversion Flex 4
    */     
    public class BaseFilter extends EventDispatcher
    {
       /**
        *  
        *  @langversion 3.0
        *  @playerversion Flash 10
        *  @playerversion AIR 1.5
        *  @productversion Flex 4
        */     
        public static const CHANGE:String = "change";       
        
       /**
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