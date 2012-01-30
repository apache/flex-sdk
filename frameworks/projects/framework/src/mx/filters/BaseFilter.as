package mx.filters
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.Event;

	public class BaseFilter extends EventDispatcher
	{
		public static const CHANGE:String = "change"; 		
		
		public function BaseFilter(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function notifyFilterChanged():void
		{
			dispatchEvent(new Event(CHANGE));
		}
		
	}
}