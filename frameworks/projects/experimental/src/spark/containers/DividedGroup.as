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
package spark.containers
{
	import flash.events.Event;
	import flash.events.MouseEvent;

	import mx.core.IVisualElement;
	import mx.events.SandboxMouseEvent;
	import mx.managers.CursorManager;
	import mx.managers.CursorManagerPriority;

	import spark.components.Group;

	[Exclude(name="layout", kind="property")]
	[DefaultProperty("children")]
	[ResourceBundle("dividers")]
	/**
	 * @author Bogdan Dinu (http://www.badu.ro)
	 */
	public class DividedGroup extends Group
	{
		public var dividers : Array;

		protected function get cursorClass():Class
		{
			return null;
		}

		protected var _cursorID : int = CursorManager.NO_CURSOR;
		protected var _currentActiveDivider : Divider;

		protected var _showTooltipOnDividers : Boolean = false;
		public function get showTooltipOnDividers():Boolean
		{
			return _showTooltipOnDividers;
		}
		public function set showTooltipOnDividers(value:Boolean):void
		{
			_showTooltipOnDividers = value;
		}

		public function DividedGroup()
		{
			super();
		}

		[ArrayElementType("mx.core.IVisualElement")]
		protected var _children : Array;

		[Inspectable(category="General", type="Array")]
		public function get children():Array
		{
			return _children;
		}

		public function set children(value:Array):void
		{
			_children = value;
		}

		protected function createNewDivider(firstChild : IVisualElement , secondChild : IVisualElement, dividerClass : Class = null):Divider
		{
			var result : Divider = new dividerClass();
			result.addEventListener(MouseEvent.MOUSE_OVER , onDividerMouseOver);
			result.addEventListener(MouseEvent.MOUSE_OUT , onDividerMouseOut);
			result.addEventListener(MouseEvent.MOUSE_DOWN , onDividerMouseDown);
			result.upOrRightNeighbour = firstChild;
			result.downOrLeftNeighbour = secondChild;
			dividers.push(result);
			return result;
		}

		protected function removeDivider(index : int):Boolean
		{
			var result : Boolean = false;
			var divider : Divider = getElementAt(index) as Divider;
			if (divider)
			{
				divider.removeEventListener(MouseEvent.MOUSE_OVER , onDividerMouseOver);
				divider.removeEventListener(MouseEvent.MOUSE_OUT , onDividerMouseOut);
				divider.removeEventListener(MouseEvent.MOUSE_DOWN , onDividerMouseDown);
				super.removeElement( divider );
				result = true;
			}
			return result;
		}

		protected function onDividerMouseOver(e:MouseEvent):void
		{
			_cursorID = cursorManager.setCursor(cursorClass , CursorManagerPriority.HIGH, 0, 0);
		}

		protected function onDividerMouseOut(e:MouseEvent = null):void
		{
			if (_cursorID != CursorManager.NO_CURSOR)
			{
				cursorManager.removeCursor(_cursorID);
				_cursorID = CursorManager.NO_CURSOR;
			}
		}

		protected function onDividerMouseDown(e:MouseEvent):void
		{
			_currentActiveDivider = e.currentTarget as Divider;
			startDividerDrag(e);
			systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, onDividerMouseUp, true);
			systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, onDividerMouseUp);
		}

		private function onDividerMouseUp(e:Event):void
		{
			onDividerMouseOut();
			stopDividerDrag();
			systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP, onDividerMouseUp, true);
			systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, onDividerMouseUp);
		}

		protected function startDividerDrag(e:MouseEvent):void
		{
			systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_MOVE, onDividerMouseMove, true);
			systemManager.deployMouseShields(true);
		}

		protected function stopDividerDrag():void
		{
			_currentActiveDivider = null;
			systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_MOVE, onDividerMouseMove, true);
			systemManager.deployMouseShields(false);
			makePercentsOutOfWidths();
		}

		protected function makePercentsOutOfWidths():void
		{

		}

		protected function onDividerMouseMove(e:MouseEvent):void
		{

		}
		/**
		 * Not used, not properly tested yet.
		 *
		 * TODO :
		 * make it work, so we can add and remove children at runtime
		 */
		/*
		override public function addElement(element:IVisualElement):IVisualElement
		{
			var result : IVisualElement = super.addElement(element);
			if (_isCreatingChildren) return result;
			if (numElements > 1)
			{
				addElementAt(createNewDivider(numElements-1) , numElements-1);
			}
			return result;
		}

		override public function removeElement(element:IVisualElement):IVisualElement
		{
			var result : IVisualElement = super.removeElement(element);
			if (numElements > 1)
			{
				if (!removeDivider(numElements-1))
				{
					throw new Error("Divider not found");
				}
			}
			return result;
		}
		*/

		protected function checkPercentsOnChildren():void
		{

		}

		override protected function createChildren():void {
            super.createChildren();
            dividers = new Array();
            if (!_children || _children.length <= 1) {
                throw new Error(resourceManager.getString('dividers', 'atLeastTwoChildrenRequiredError'));
            }
            checkPercentsOnChildren();
            addElement(_children[0]);
            for (var i:int = 1; i < _children.length; i++) {
                addElement(createNewDivider(_children[i - 1], _children[i]));
                addElement(_children[i]);
            }
            invalidateLayering();
        }

	}
}
