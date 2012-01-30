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

package mx.automation.air
{
	import flash.desktop.Clipboard;
	import flash.desktop.NativeDragOptions;
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NativeDragEvent;
	
	import mx.automation.IAutomationObject;
	import mx.automation.events.AutomationDragEvent;
	import mx.core.DragSource;
	import mx.managers.ISystemManager;
	
	[Mixin]
	
	/**
	 *  Helper class that provides methods required for automation of drag and drop in AIR applications
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2
	 *  @productversion Flex 4.1
	 */
	public class AirDragManagerAutomationHandler
	{
		private static var sm:ISystemManager;
		private static  var dragStartHappened:Boolean = false;
		private static var _lastClipBoardObject:Clipboard;
		private static var dragOptions:NativeDragOptions;
		private static var lastDragStartObj:IAutomationObject ;
		private static var _lastDragSource:DragSource;
		
		/**
		 *  Constructor
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2
		 *  @productversion Flex 4.1
		 */
		public function AirDragManagerAutomationHandler()
		{
		}
		
		/**
		 *  @private
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2
		 *  @productversion Flex 4.1
		 */
		public static function init(root:DisplayObject):void
		{
			sm = root as ISystemManager;
		}
		
		
		
		/**
		 *  Returns the target of last drag start event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2
		 *  @productversion Flex 4.1
		 */
		public static function getlastDragStartObj():IAutomationObject
		{
			return lastDragStartObj;
		}
		
		/**
		 *  Stores the details of current drag source
		 *  @param dragSource DragSource object
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2
		 *  @productversion Flex 4.1
		 */
		public static function storeAIRDragSourceDetails(dragSource:DragSource):void
		{
			dragOptions = new NativeDragOptions();
			dragOptions.allowCopy = true;
			dragOptions.allowMove = true;
			dragOptions.allowLink = false;
			
			_lastClipBoardObject = null;
			dragStartHappened = true;
			
			_lastDragSource = dragSource;
		}
		
		/**
		 * @private
		 * Builds clipboard object from the passed dragSource object
		 * 
		 */
		private static function formClipboard(dragSource:DragSource):Clipboard
		{
			var clipboardObj:Clipboard = new Clipboard();
			
			var formatsArr:Array = dragSource.formats;
			if (formatsArr)
			{
				//var dataArray:Array = new Array();
				var count: int  = formatsArr.length;
				var index:int  = 0;
				while (index < count)
				{
					// get the data object
					//var currentDataObject:Object = dragSource.dataForFormat(formatsArr[index]);
					//clipboardObj.setData(formatsArr[index],currentDataObject,false);
					// The above commented part was throwing an RTE if currentDataObject is null.
					// http://bugs.adobe.com/jira/browse/FLEXENT-1069
					// So we are using setDataHandler() method of ClipBoard instead of setData()
					// in the same way how NativeDragManager constructs a clipboard object in doDrag()
					var dataFetcher:DragDataFormatFetcher = new DragDataFormatFetcher();
					dataFetcher.dragSource = dragSource;
					dataFetcher.format = formatsArr[index];
					clipboardObj.setDataHandler(formatsArr[index],dataFetcher.getDragSourceData,false);
					index++;
				}
			}
			return clipboardObj;
		}       
		
		/**
		 *  Replays drag start event
		 *  @param realTarget Object on which the event is to be dispatched
		 *  @param dragEvent AutomationDragEvent object that holds information required to build a drag start event
		 *  @param draggedItems Object which is dragged
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2
		 *  @productversion Flex 4.1
		 */
		public static function replayAIRDragStartEvent(realTarget:EventDispatcher , dragEvent:AutomationDragEvent, draggedItems:IAutomationObject):void
		{
			lastDragStartObj = realTarget as IAutomationObject;
			//dragStartHappened = false;
			if (dragStartHappened == false)
			{
				_lastClipBoardObject = new Clipboard();
				_lastClipBoardObject.setData("items",new Object(),false);
				if (!dragOptions)
					dragOptions = new NativeDragOptions();
				dragOptions.allowCopy = true;
				dragOptions.allowMove = true;
				dragOptions.allowLink = false;
				
				// we need to crete a native drag enter event and then a drag drop event and dispatch on our component.
				var dragStartEvent:NativeDragEvent = new NativeDragEvent(NativeDragEvent.NATIVE_DRAG_START);
				dragStartEvent.clipboard = _lastClipBoardObject;
				dragStartEvent.allowedActions = dragOptions;
				dragStartEvent.dropAction = dragEvent.action;
				dragStartEvent.localX = dragEvent.localX;
				dragStartEvent.localY = dragEvent.localY;
				dragStartEvent.buttonDown = true;
				if (dragStartEvent.isDefaultPrevented())
					trace  ('here-x');
				realTarget.dispatchEvent(dragStartEvent);
			}
		}
		
		/**
		 *  Replays drag drop event
		 *  @param realTarget Object on which event is to be dispatched
		 *  @param dragEvent AutomationDragEvent object that holds information required to build a drag drop event
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2
		 *  @productversion Flex 4.1
		 */
		public static function replayAIRDragDropEvent(realTarget:EventDispatcher , dragEvent:AutomationDragEvent/*,dragSource:DragSource*/):void
		{
			// we should have   dragStartHappened as true,_lastClipBoardObject and dragOptions as non null values.
			// in the case marhshalled application drag start and drag drop can be in different application domain.
			if (!dragStartHappened)
			{
				// we need to get the details from the application where the current dragStart happened.
			}
			else
			{
				_lastClipBoardObject = formClipboard(_lastDragSource);
				if (_lastClipBoardObject && dragOptions)
				{
					// we need to crete a native drag enter event and then a drag drop event and dispatch on our component.
					var dragEnterEvent:NativeDragEvent = new NativeDragEvent(NativeDragEvent.NATIVE_DRAG_ENTER);
					dragEnterEvent.clipboard = _lastClipBoardObject;
					dragEnterEvent.allowedActions = dragOptions;
					dragEnterEvent.dropAction = dragEvent.action;
					dragEnterEvent.localX = dragEvent.localX;
					dragEnterEvent.localY = dragEvent.localY;
					dragEnterEvent.buttonDown = true;
					realTarget.dispatchEvent(dragEnterEvent);
					
					var dragDropEvent:NativeDragEvent = new NativeDragEvent(NativeDragEvent.NATIVE_DRAG_DROP);
					dragDropEvent.clipboard = _lastClipBoardObject;
					dragDropEvent.allowedActions = dragOptions;
					dragDropEvent.dropAction = dragEvent.action;
					dragDropEvent.localX = dragEvent.localX;
					dragDropEvent.localY = dragEvent.localY;
					realTarget.dispatchEvent(dragDropEvent);
					
					// we need to dispatch the dragComplete on the dragStart object.
					if (lastDragStartObj as IEventDispatcher)
					{
						var dragCompleteEvent:NativeDragEvent = new NativeDragEvent(NativeDragEvent.NATIVE_DRAG_COMPLETE);
						dragCompleteEvent.clipboard = _lastClipBoardObject;
						dragCompleteEvent.allowedActions = dragOptions;
						dragCompleteEvent.dropAction = dragEvent.action;
						dragCompleteEvent.localX = dragEvent.localX;
						dragCompleteEvent.localY = dragEvent.localY;
						(lastDragStartObj as IEventDispatcher).dispatchEvent(dragCompleteEvent);
					}
					
					
				}
			}
			
			dragStartHappened = false;
			
			_lastDragSource = null;
			
		}
		
		
		/**
		 *  Replays drag drop event in marshalled applications
		 *  @param realTarget Object on which event is to be dispatched
		 *  @param dragEvent AutomationDragEvent object that holds information required to build a drag drop event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2
		 *  @productversion Flex 4.1
		 */
		public static function replayAIRDragDropMarshalledEvent(realTarget:Object , dragEvent:Object/*,dragSource:DragSource*/):void
		{
			// we should have   dragStartHappened as true,_lastClipBoardObject and dragOptions as non null values.
			// in the case marhshalled application drag start and drag drop can be in different application domain.
			if (dragStartHappened == false)
			{
				// we need to get the details from the application where the current dragStart happened.
			}
			else
			{
				_lastClipBoardObject = formClipboard(_lastDragSource);
				if (_lastClipBoardObject && dragOptions)
				{
					// we need to crete a native drag enter event and then a drag drop event and dispatch on our component.
					var dragEnterEvent:NativeDragEvent = new NativeDragEvent(NativeDragEvent.NATIVE_DRAG_ENTER);
					dragEnterEvent.clipboard = _lastClipBoardObject;
					dragEnterEvent.allowedActions = dragOptions;
					dragEnterEvent.dropAction = dragEvent["action"];
					dragEnterEvent.localX = dragEvent["localX"];
					dragEnterEvent.localY = dragEvent["localY"];
					dragEnterEvent.buttonDown = true;
					realTarget.dispatchEvent(dragEnterEvent);
					
					var dragDropEvent:NativeDragEvent = new NativeDragEvent(NativeDragEvent.NATIVE_DRAG_DROP);
					dragDropEvent.clipboard = _lastClipBoardObject;
					dragDropEvent.allowedActions = dragOptions;
					dragDropEvent.dropAction = dragEvent["action"];
					dragDropEvent.localX = dragEvent["localX"];
					dragDropEvent.localY = dragEvent["localY"];
					realTarget.dispatchEvent(dragDropEvent);
					
					// we need to dispatch the dragComplete on the dragStart object.
					if (lastDragStartObj as IEventDispatcher)
					{
						var dragCompleteEvent:NativeDragEvent = new NativeDragEvent(NativeDragEvent.NATIVE_DRAG_COMPLETE);
						dragCompleteEvent.clipboard = _lastClipBoardObject;
						dragCompleteEvent.allowedActions = dragOptions;
						dragCompleteEvent.dropAction = dragEvent["action"];
						dragCompleteEvent.localX = dragEvent["localX"];
						dragCompleteEvent.localY = dragEvent["localY"];
						(lastDragStartObj as IEventDispatcher).dispatchEvent(dragCompleteEvent);
					}
					
					
				}
			}
			
			dragStartHappened = false;
			_lastDragSource = null;
			
		}
		
		/**
		 *  Replays drag cancel event
		 *  @param realTarget Object on which event is to be dispatched
		 *  @param dragEvent AutomationDragEvent object that holds information required to build a drag cancel event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2
		 *  @productversion Flex 4.1
		 */
		public static function replayAIRDragCancelEvent(realTarget:EventDispatcher,dragEvent:AutomationDragEvent ):void
		{
			_lastClipBoardObject = formClipboard(_lastDragSource);
			var dragCancelEvent:NativeDragEvent = new NativeDragEvent(NativeDragEvent.NATIVE_DRAG_COMPLETE);
			dragCancelEvent.clipboard = _lastClipBoardObject;
			dragCancelEvent.allowedActions = dragOptions;
			dragCancelEvent.dropAction = dragEvent.action;
			dragCancelEvent.localX = dragEvent.localX;
			dragCancelEvent.localY = dragEvent.localY;
			(lastDragStartObj as IEventDispatcher).dispatchEvent(dragCancelEvent);
			
			dragStartHappened = false;
			_lastDragSource = null;
			
		}
		
		/**
		 *  Returns the clipboard instance of last drag event
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2
		 *  @productversion Flex 4.1
		 */
		public static function  get lastClipBoardObject():Clipboard
		{
			return lastClipBoardObject;
		}
	}
}
import mx.core.DragSource;


class DragDataFormatFetcher
{
	
	include "../../core/Version.as";
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  Constructor.
	 */
	public function DragDataFormatFetcher()
	{
		super();
	}
	
	/**
	 *  @private
	 */
	public var dragSource:DragSource;
	
	/**
	 *  @private
	 */
	public var format:String;
	
	/**
	 *  @private
	 */
	public function getDragSourceData():Object
	{
		if (dragSource)
			return dragSource.dataForFormat(format);
		else
			return null;
	}
}