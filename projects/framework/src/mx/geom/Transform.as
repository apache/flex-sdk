package mx.geom
{
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.events.PropertyChangeEvent;
	import flash.display.DisplayObject;
	
	public class Transform extends flash.geom.Transform implements IEventDispatcher
	{
		private var dispatcher:EventDispatcher;
		
		public function Transform(src:DisplayObject = null)
		{
			dispatcher = new EventDispatcher();
			
			if(src == null)
				src = new Shape();
			super(src);				
		}
		
		[Bindable("propertyChange")]
		override public function set matrix(value:Matrix):void
		{
			var oldMatrix:Matrix = super.matrix;
			super.matrix = value;	
			
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "matrix", oldMatrix, value));

		}
		
		[Bindable("propertyChange")]
		override public function set colorTransform(value:ColorTransform):void
		{
			var oldColorTransform:ColorTransform = super.colorTransform;
			super.colorTransform = value;
			
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "colorTransform", oldColorTransform, value));
		}
		
		//--------------------------------------------------------------------------
		//
		//  IEventDispatcher properties and methods
		//
		//--------------------------------------------------------------------------
		public function addEventListener(type:String, listener:Function, 
										 useCapture:Boolean = false, priority:int = 0, 
										 useWeakReference:Boolean = false):void 
		{
			return dispatcher.addEventListener(type, listener, useCapture, priority, 
										useWeakReference);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			 return dispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return dispatcher.hasEventListener(type);
		} 
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			return dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return dispatcher.willTrigger(type);
		}  
	}
}