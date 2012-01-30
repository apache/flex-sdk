package flex.filters
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.Event;

	public class BaseFilter extends EventDispatcher
	{
		public static const FILTER_CHANGED_TYPE:String = "filterChanged"; 		
		
		public function BaseFilter(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function notifyFilterChanged():void
		{
			dispatchEvent(new Event(FILTER_CHANGED_TYPE));
		}
		
	}
}