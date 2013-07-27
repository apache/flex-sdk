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

	import spark.layouts.VerticalLayout;
	/**
	 *  @langversion 3.0
	 *  @playerversion Flash 10.1
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */
	/**
	 * @author Bogdan Dinu (http://www.badu.ro)
	 */
	public class VDividerGroup extends DividedGroup
	{
		private var _onStartDragFirstNeighbourHeight : Number;
		private var _onStartDragSecondNeighbourHeight : Number;
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		[Embed(source='../../../assets/dividers/VDividerCursor.png')]
		private var _cursorClass : Class ;
		override protected function get cursorClass():Class
		{
			return _cursorClass;
		}
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		private var _minElementHeight : int = -1;
		public function get minElementHeight():int
		{
			return _minElementHeight;
		}
		public function set minElementHeight(value:int):void
		{
			_minElementHeight = value;
		}
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function VDividerGroup()
		{
			super();
			var vLayout : VerticalLayout = new VerticalLayout();
			vLayout.gap = 0;
			vLayout.useVirtualLayout = false;
			super.layout = vLayout;
		}
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		override protected function createNewDivider(firstChild : IVisualElement , secondChild : IVisualElement, dividerClass : Class = null):Divider
		{
			return super.createNewDivider(firstChild, secondChild, VDivider);
		}
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		override protected function startDividerDrag(e:MouseEvent):void
		{
			super.startDividerDrag(e);
			_onStartDragFirstNeighbourHeight = _currentActiveDivider.upOrRightNeighbour.height - e.stageY;
			_onStartDragSecondNeighbourHeight = _currentActiveDivider.downOrLeftNeighbour.height + e.stageY;
		}
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		override protected function onDividerMouseMove(e:MouseEvent):void
		{
			var newFirstNeighbourHeight : int = _onStartDragFirstNeighbourHeight + e.stageY;
			var newSecondNeighbourHeight : int = _onStartDragSecondNeighbourHeight - e.stageY;
			if (_showTooltipOnDividers) _currentActiveDivider.toolTip = newFirstNeighbourHeight+" px\n--\n"+newSecondNeighbourHeight+" px";
			if (newFirstNeighbourHeight > minElementHeight && newSecondNeighbourHeight > minElementHeight)
			{
				_currentActiveDivider.upOrRightNeighbour.height = newFirstNeighbourHeight;
				_currentActiveDivider.downOrLeftNeighbour.height = newSecondNeighbourHeight;
			}
		}
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		override protected function checkPercentsOnChildren():void
		{
			var totalPercents : Number = 0;
			for (var j : int = 0 ; j < _children.length ; j++)
			{
				if (isNaN((_children[j] as IVisualElement).percentHeight))
				{
					throw new Error(resourceManager.getString('dividers','childDoesntHavePercentHeightError'));
				}
				else
				{
					totalPercents += (_children[j] as IVisualElement).percentHeight;
				}
			}
			if (totalPercents > 100)
			{
				throw new Error(resourceManager.getString('dividers','totalPercentsGreaterThanOneHundredError'));
			}
		}
		/**
		 * @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 *
		 * After we finished dragging the divider, we need to recalculate percents
		 * because otherwise resizing the parent of this group won't rezise elements in layout
		 */
		override protected function makePercentsOutOfWidths():void
		{
			if (!_children || _children.length <= 1)
			{
				return;
			}
			//we're sure that the element #1 is divider, since if we don't have at least two elements and a divider we're throwing an error
			//@See createChildren method of the DividedGroup
			var _typicalDividerHeight : int = verticalLayout.getElementBounds(1).height;
			for (var j : int = 0 ; j < _children.length ; j++)
			{
				if (isNaN((_children[j] as IVisualElement).percentHeight))
				{
					(_children[j] as IVisualElement).percentHeight = (_children[j] as IVisualElement).height / (unscaledHeight - _typicalDividerHeight - verticalLayout.gap) * 100 ;
				}
			}
		}
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		//----------------------------------
		//  @private - internal
		//----------------------------------

		private function get verticalLayout():VerticalLayout
		{
			return VerticalLayout(layout);
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  gap
		//----------------------------------

		[Inspectable(category="General", defaultValue="0")]

		/**
		 *  @copy spark.layouts.VerticalLayout#gap
		 *
		 *  @default 6
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get gap():int
		{
			return verticalLayout.gap;
		}

		/**
		 *  @private
		 */
		public function set gap(value:int):void
		{
			verticalLayout.gap = value;
		}

		//----------------------------------
		//  horizontalAlign
		//----------------------------------

		[Inspectable(category="General", enumeration="left,right,center,justify,contentJustify", defaultValue="left")]

		/**
		 *  @copy spark.layouts.VerticalLayout#horizontalAlign
		 *
		 *  @default "left"
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get horizontalAlign():String
		{
			return verticalLayout.horizontalAlign;
		}

		/**
		 *  @private
		 */
		public function set horizontalAlign(value:String):void
		{
			verticalLayout.horizontalAlign = value;
		}

		//----------------------------------
		//  verticalAlign
		//----------------------------------

		[Inspectable(category="General", enumeration="top,bottom,middle", defaultValue="top")]

		/**
		 *  @copy spark.layouts.VerticalLayout#verticalAlign
		 *
		 *  @default "top"
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get verticalAlign():String
		{
			return verticalLayout.verticalAlign;
		}

		/**
		 *  @private
		 */
		public function set verticalAlign(value:String):void
		{
			verticalLayout.verticalAlign = value;
		}

		//----------------------------------
		//  paddingLeft
		//----------------------------------

		[Inspectable(category="General", defaultValue="0.0")]

		/**
		 *  @copy spark.layouts.VerticalLayout#paddingLeft
		 *
		 *  @default 0
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get paddingLeft():Number
		{
			return verticalLayout.paddingLeft;
		}

		/**
		 *  @private
		 */
		public function set paddingLeft(value:Number):void
		{
			verticalLayout.paddingLeft = value;
		}

		//----------------------------------
		//  paddingRight
		//----------------------------------

		[Inspectable(category="General", defaultValue="0.0")]

		/**
		 *  @copy spark.layouts.VerticalLayout#paddingRight
		 *
		 *  @default 0
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get paddingRight():Number
		{
			return verticalLayout.paddingRight;
		}

		/**
		 *  @private
		 */
		public function set paddingRight(value:Number):void
		{
			verticalLayout.paddingRight = value;
		}

		//----------------------------------
		//  paddingTop
		//----------------------------------

		[Inspectable(category="General", defaultValue="0.0")]

		/**
		 *  @copy spark.layouts.VerticalLayout#paddingTop
		 *
		 *  @default 0
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get paddingTop():Number
		{
			return verticalLayout.paddingTop;
		}

		/**
		 *  @private
		 */
		public function set paddingTop(value:Number):void
		{
			verticalLayout.paddingTop = value;
		}

		//----------------------------------
		//  paddingBottom
		//----------------------------------

		[Inspectable(category="General", defaultValue="0.0")]

		/**
		 *  @copy spark.layouts.VerticalLayout#paddingBottom
		 *
		 *  @default 0
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get paddingBottom():Number
		{
			return verticalLayout.paddingBottom;
		}

		/**
		 *  @private
		 */
		public function set paddingBottom(value:Number):void
		{
			verticalLayout.paddingBottom = value;
		}


		//----------------------------------
		//  firstIndexInView
		//----------------------------------

		[Bindable("indexInViewChanged")]
		[Inspectable(category="General")]

		/**
		 * @copy spark.layouts.VerticalLayout#firstIndexInView
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get firstIndexInView():int
		{
			return verticalLayout.firstIndexInView;
		}

		//----------------------------------
		//  lastIndexInView
		//----------------------------------

		[Bindable("indexInViewChanged")]
		[Inspectable(category="General")]

		/**
		 *  @copy spark.layouts.VerticalLayout#lastIndexInView
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get lastIndexInView():int
		{
			return verticalLayout.lastIndexInView;
		}

		//--------------------------------------------------------------------------
		//
		//  Event Handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			switch(type)
			{
				case "indexInViewChanged":
				case "propertyChange":
					if (!hasEventListener(type))
						verticalLayout.addEventListener(type, redispatchHandler);
					break;
			}
			super.addEventListener(type, listener, useCapture, priority, useWeakReference)
		}

		/**
		 * @private
		 */
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			super.removeEventListener(type, listener, useCapture);
			switch(type)
			{
				case "indexInViewChanged":
				case "propertyChange":
					if (!hasEventListener(type))
						verticalLayout.removeEventListener(type, redispatchHandler);
					break;
			}
		}

		private function redispatchHandler(event:Event):void
		{
			dispatchEvent(event);
		}
	}
}
