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

	import spark.layouts.HorizontalLayout;
	/**
	 *  @langversion 3.0
	 *  @playerversion Flash 10.1
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */
	/**
	 * @author Bogdan Dinu (http://www.badu.ro)
	 */
	public class HDividerGroup extends DividedGroup
	{
		private var _onStartDragFirstNeighbourWidth : Number;
		private var _onStartDragSecondNeighbourWidth : Number;
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		[Embed(source='../../../assets/dividers/HDividerCursor.png')]
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
		private var _minElementWidth : int = -1;
		public function get minElementWidth():int
		{
			return _minElementWidth;
		}
		public function set minElementWidth(value:int):void
		{
			_minElementWidth = value;
		}
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function HDividerGroup()
		{
			super();
			var hLayout : HorizontalLayout = new HorizontalLayout();
			hLayout.gap = 0;
			hLayout.useVirtualLayout = false;
			super.layout = hLayout;
		}
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		override protected function createNewDivider(firstChild : IVisualElement , secondChild : IVisualElement, dividerClass : Class = null):Divider
		{
			return super.createNewDivider(firstChild, secondChild, HDivider);
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
			_onStartDragFirstNeighbourWidth = _currentActiveDivider.upOrRightNeighbour.width - e.stageX;
			_onStartDragSecondNeighbourWidth = _currentActiveDivider.downOrLeftNeighbour.width + e.stageX;
		}
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		override protected function onDividerMouseMove(e:MouseEvent):void
		{
			var newFirstNeighbourWidth : int = _onStartDragFirstNeighbourWidth + e.stageX;
			var newSecondNeighbourWidth : int = _onStartDragSecondNeighbourWidth - e.stageX;
			if (_showTooltipOnDividers) _currentActiveDivider.toolTip = newFirstNeighbourWidth+" px / "+newSecondNeighbourWidth+" px";
			if (newFirstNeighbourWidth > minElementWidth && newSecondNeighbourWidth > minElementWidth)
			{
				_currentActiveDivider.downOrLeftNeighbour.width = newSecondNeighbourWidth;
				_currentActiveDivider.upOrRightNeighbour.width = newFirstNeighbourWidth;
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
				if (isNaN((_children[j] as IVisualElement).percentWidth))
				{
					throw new Error(resourceManager.getString('dividers','childDoesntHavePercentWidthError'));
				}
				else
				{
					totalPercents += (_children[j] as IVisualElement).percentWidth;
				}
			}
			if (totalPercents > 100)
			{
				throw new Error(resourceManager.getString('dividers','totalPercentsGreaterThanOneHundredError'));
			}
		}
		/**
		 *  @langversion 3.0
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
			var _typicalDividerWidth : int = horizontalLayout.getElementBounds(1).width;
			for (var j : int = 0 ; j < _children.length ; j++)
			{
				if (isNaN((_children[j] as IVisualElement).percentWidth))
				{
					(_children[j] as IVisualElement).percentWidth = (_children[j] as IVisualElement).width / (unscaledWidth - _typicalDividerWidth - horizontalLayout.gap) * 100 ;
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
		private function get horizontalLayout():HorizontalLayout
		{
			return HorizontalLayout(layout);
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
			return horizontalLayout.gap;
		}

		/**
		 *  @private
		 */
		public function set gap(value:int):void
		{
			horizontalLayout.gap = value;
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
			return horizontalLayout.horizontalAlign;
		}

		/**
		 *  @private
		 */
		public function set horizontalAlign(value:String):void
		{
			horizontalLayout.horizontalAlign = value;
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
			return horizontalLayout.verticalAlign;
		}

		/**
		 *  @private
		 */
		public function set verticalAlign(value:String):void
		{
			horizontalLayout.verticalAlign = value;
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
			return horizontalLayout.paddingLeft;
		}

		/**
		 *  @private
		 */
		public function set paddingLeft(value:Number):void
		{
			horizontalLayout.paddingLeft = value;
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
			return horizontalLayout.paddingRight;
		}

		/**
		 *  @private
		 */
		public function set paddingRight(value:Number):void
		{
			horizontalLayout.paddingRight = value;
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
			return horizontalLayout.paddingTop;
		}

		/**
		 *  @private
		 */
		public function set paddingTop(value:Number):void
		{
			horizontalLayout.paddingTop = value;
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
			return horizontalLayout.paddingBottom;
		}

		/**
		 *  @private
		 */
		public function set paddingBottom(value:Number):void
		{
			horizontalLayout.paddingBottom = value;
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
			return horizontalLayout.firstIndexInView;
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
			return horizontalLayout.lastIndexInView;
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
						horizontalLayout.addEventListener(type, redispatchHandler);
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
						horizontalLayout.removeEventListener(type, redispatchHandler);
					break;
			}
		}

		private function redispatchHandler(event:Event):void
		{
			dispatchEvent(event);
		}
	}
}
