
package mx.managers
{

import flash.events.MouseEvent;

import mx.core.DragSource;
import mx.core.IFlexDisplayObject;
import mx.core.IUIComponent;

[ExcludeClass]

/**
 *  @private
 */
public interface IDragManager
{
	function get isDragging():Boolean;
	function doDrag(
			dragInitiator:IUIComponent, 
			dragSource:DragSource,
			mouseEvent:MouseEvent,
			dragImage:IFlexDisplayObject = null, // instance of dragged item(s)
			xOffset:Number = 0,
			yOffset:Number = 0,
			imageAlpha:Number = 0.5,
			allowMove:Boolean = true):void;
	function acceptDragDrop(target:IUIComponent):void;
	function showFeedback(feedback:String):void;
	function getFeedback():String;
	function endDrag():void;
}

}

