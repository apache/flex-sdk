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
package spark.layouts.supportClasses
{
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.net.getClassByAlias;
	
	import mx.core.IVisualElement;
	import mx.core.mx_internal;
	import mx.events.ChildExistenceChangedEvent;
	import mx.events.FlexEvent;
	
	import spark.components.DataGroup;
	import spark.components.Scroller;
	import spark.components.supportClasses.GroupBase;
	import spark.core.NavigationUnit;
	import spark.events.IndexChangeEvent;
	import spark.layouts.supportClasses.LayoutBase;
	import spark.primitives.supportClasses.GraphicElement;
	
	use namespace mx_internal;
	
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 *  @eventType spark.events.IndexChangeEvent.CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Event(name="change", type="spark.events.IndexChangeEvent")]
	
	/**
	 *  @eventType mx.events.FlexEvent.VALUE_COMMIT
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Event(name="valueCommit", type="mx.events.FlexEvent")]
	
	
	/**
	 *  A NavigatorLayoutBase class is a base class for navigator layouts.
	 * 
	 *  <p>More info coming.</p>.
	 * 
	 *  @mxml
	 *
	 *  <p>The <code>&lt;st:NavigatorLayoutBase&gt;</code> tag inherits all of the
	 *  tag attributes of its superclass, and adds the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;st:NavigatorLayoutBase
	 *    <strong>Properties</strong>
	 * 	  firstIndexInView="<i>calculated</i>"
	 *    indicesInLayout="<i>calculated</i>"
	 *    lastIndexInView="<i>calculated</i>"
	 * 	  numElementsInLayout="<i>calculated</i>"
	 *    numElementsNotInLayout="<i>calculated</i>"
	 * 	  numIndicesInView="<i>calculated</i>"
	 *    renderingData="<i>calculated</i>"
	 * 	  scrollBarDirection="horizontal|vertical"
	 *    selectedIndex="-1"
	 *    unscaledWidth="<i>calculated</i>"
	 *    unscaledHeight="<i>calculated</i>"
	 *    useScrollBarForNavigation="true"
	 * 
	 *    <strong>Events</strong>
	 *    change="<i>No default</i>"
	 *    valueCommit="<i>No default</i>"
	 *  /&gt;
	 *  </pre>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public class NavigatorLayoutBase extends LayoutBase implements INavigatorLayout
	{
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function NavigatorLayoutBase()
		{
			super();
			
			//			useVirtualLayout = true;
			
			useScrollBarForNavigation = true;
			
			_scrollBarDirection = LayoutAxis.VERTICAL;
		}	
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *	Flag to indicate the selectedIndex changed after the target was changed.
		 */
		private var _selectedIndexChangedAfterTargetChanged	: Boolean;
		
		/**
		 *  @private
		 *	Flag to indicate the IVisualElements in the target have changed.
		 */
		private var _elementsChanged: Boolean;
		
		/**
		 *  @private
		 *	Flag to indicate the target has changed.
		 */
		private var _targetChanged:Boolean;
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  lastIndexInView
		//---------------------------------- 
		
		/**
		 *  @private
		 *	Storage property for lastIndexInView.
		 */
		private var _lastIndexInView		: int = -1;
		
		/**
		 *  lastIndexInView
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get lastIndexInView():int
		{
			return _lastIndexInView;
		}
		
		
		//----------------------------------
		//  firstIndexInView
		//---------------------------------- 
		
		/**
		 *  @private
		 *	Storage property for firstIndexInView.
		 */
		private var _firstIndexInView		: int = -1;
		
		/**
		 *  firstIndexInView
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get firstIndexInView():int
		{
			return _firstIndexInView;
		}
		
		
		//----------------------------------
		//  numVisibleElements
		//---------------------------------- 
		
		/**
		 *  @private
		 *	Storage property for numIndicesInView.
		 */
		private var _numIndicesInView		: int = -1;
		
		/**
		 *  inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get numIndicesInView():int
		{
			return _numIndicesInView;
		}
		
		
		//----------------------------------
		//  renderingData
		//---------------------------------- 
		
		/**
		 *  inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get renderingData():Boolean
		{
			if( target is DataGroup )
			{
				var dataGroup:DataGroup = DataGroup( target );
				if( dataGroup.itemRenderer || dataGroup.itemRendererFunction != null ) return true;
			}
			
			return false;
		}
		
		//		[Inspectable(category="General", enumeration="false,true", defaultValue="true")]
		//		public function get stepScrollBar():Boolean
		//		{
		//			return _stepScrollBar;
		//		}
		//		public function set stepScrollBar(value:Boolean):void
		//		{
		//			if( value == _stepScrollBar ) return;
		//			
		//			_stepScrollBar = value;
		//			
		//			invalidateTargetDisplayList();
		//		}
		
		
		//----------------------------------
		//  selectedIndexOffset
		//---------------------------------- 
		//		
		//		/**
		//		 *  @private
		//		 *	Storage property for selectedIndexOffset.
		//		 */
		//		private var _selectedIndexOffset	: Number = 0;
		//		
		//		/**
		//		 *  inheritDoc
		//		 *  
		//		 *  @langversion 3.0
		//		 *  @playerversion Flash 10
		//		 *  @playerversion AIR 1.5
		//		 *  @productversion Flex 4
		//		 */
		//		public function get selectedIndexOffset():Number
		//		{
		//			return _selectedIndexOffset;
		//		}
		//		/**
		//		 *  @private
		//		 */
		//		public function set selectedIndexOffset( value:Number ):void
		//		{
		//			if( _useScrollBarForNavigation )
		//			{
		//				updateScrollBar( _selectedIndex, value );
		//			}
		//			else
		//			{
		//				updateSelectedIndex( _selectedIndex, value );
		//			}
		//		}
		
		
		//----------------------------------
		//  selectedElement
		//---------------------------------- 
		
		private var _selectedElement:IVisualElement;
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get selectedElement():IVisualElement
		{
			return _selectedElement;
		}
		
		
		
		//----------------------------------
		//  selectedIndex
		//---------------------------------- 
		
		/**
		 *  @private
		 *	Storage property for selectedIndex.
		 */
		private var _selectedIndex			: int = -1;
		
		/**
		 *  @private
		 */
		private var _programmaticSelectedIndex:int;
		
		[Bindable( event="change" )]
		[Bindable( event="valueCommit" )]
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get selectedIndex():int
		{
			return _proposedSelectedIndex == -1 ? _selectedIndex : _proposedSelectedIndex;
		}
		/**
		 *  @private
		 */
		public function set selectedIndex( value:int ):void
		{
			if( selectedIndex == value ) return;
			
			_programmaticSelectedIndex = value;
			if( _targetChanged ) _selectedIndexChangedAfterTargetChanged = true;
			
			if( _useScrollBarForNavigation && getScroller() )
			{
				updateScrollBar( value, 0 );
			}
			else
			{
				//				updateSelectedIndex( value, 0 );
				invalidateSelectedIndex( value, 0 );
			}
		}
		
		
		//----------------------------------
		//  useScrollBarForNavigation
		//---------------------------------- 
		
		/**
		 *  @private
		 *  Storage property for useScrollBarForNavigation.
		 */
		private var _useScrollBarForNavigation:Boolean;
		
		[Inspectable(category="General", enumeration="false,true", defaultValue="true")]
		/**
		 *  useScrollBarForNavigation
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get useScrollBarForNavigation():Boolean
		{
			return _useScrollBarForNavigation;
		}
		/**
		 *  @private
		 */
		public function set useScrollBarForNavigation(value:Boolean):void
		{
			if( value == _useScrollBarForNavigation ) return;
			
			_useScrollBarForNavigation = value;
			
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  scrollBarDirection
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for scrollBarDirection.
		 */
		private var _scrollBarDirection		: String;
		
		[Inspectable(category="General", enumeration="horizontal,vertical", defaultValue="vertical")]
		
		/**
		 *  The direction of the ScrollBar to use for navigation.
		 * 
		 * 	<p>If <code>scrollBarDirection</code> is set to <code>LayoutAxis.VERTICAL</code>
		 *  a VScrollBar will be displayed in the views Scroller.
		 * 	If set to <code>LayoutAxis.HORIZONTAL</code> a HScrollBar will be displayed
		 * 	in the views Scroller.</p>
		 *  
		 * 	<p>If the viewport doesn't have a Scroller or <code>useScrollBarForNavigation</code>
		 *  is set to <code>false</code> a ScrollBar is displayed.</p>
		 * 
		 *  <p>The default value is <code>LayoutAxis.VERTICAL</code></p>
		 *
		 * 	@see mx.controls.scrollClasses.LayoutAxis
		 *  @see spark.layouts.NavigatorLayoutBase#useScrollBarForNavigation
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get scrollBarDirection():String
		{
			return _scrollBarDirection;
		}
		/**
		 *  @private
		 */
		public function set scrollBarDirection( value:String ) : void
		{
			if( _scrollBarDirection == value ) return;
			
			switch( value )
			{
				case LayoutAxis.HORIZONTAL :
				case LayoutAxis.VERTICAL :
				{
					_scrollBarDirection = value;
					if( target ) scrollPositionChanged();
					invalidateTargetDisplayList();
					break;
				}
				default :
				{
					
				}
			}
		}
		
		
		//----------------------------------
		//  numElementsInLayout
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for numElementsInLayout.
		 */
		private var _numElementsInLayout:int = -1;
		
		/**
		 *  Returns an <code>int</code> specifying number of elements included in the layout.
		 * 
		 *  @see mx.core.UIComponent#includeInLayout
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get numElementsInLayout():int
		{
			return _numElementsInLayout;
		}
		
		
		//----------------------------------
		//  numElementsNotInLayout
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for numElementsNotInLayout.
		 */
		private var _numElementsNotInLayout:int = -1;
		
		/**
		 *  Returns an <code>int</code> specifying number of elements not included in the layout.
		 * 
		 *  @see mx.core.UIComponent#includeInLayout
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get numElementsNotInLayout():int
		{
			return _numElementsNotInLayout;
		}
		
		
		//----------------------------------
		//  indicesInLayout
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for indicesInLayout.
		 */
		private var _indicesInLayout:Vector.<int>;
		
		/**
		 *  A convenience method for determining the elements included in the layout.
		 * 
		 *  @return A list of the element indices not included in the layout.
		 * 
		 *  @see mx.core.UIComponent#includeInLayout
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get indicesInLayout():Vector.<int>
		{
			return _indicesInLayout;
		}
		
		
		//----------------------------------
		//  indicesNotInLayout
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for indicesNotInLayout.
		 */
		private var _indicesNotInLayout:Vector.<int>;
		
		/**
		 *  A convenience method for determining the elements excluded from the layout.
		 * 
		 *  @return A list of the element indices not included in the layout.
		 * 
		 *  @see mx.core.UIComponent#includeInLayout
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get indicesNotInLayout():Vector.<int>
		{
			return _indicesNotInLayout;
		}
		
		
		//----------------------------------
		//  unscaledWidth
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for unscaledWidth.
		 */
		private var _unscaledWidth	: Number;
		
		/**
		 *  A convenience method for determining the unscaled width of the viewport.
		 *
		 *  @return A Number which is unscaled width of the component
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get unscaledWidth():Number
		{
			return _unscaledWidth;
		}
		
		
		//----------------------------------
		//  unscaledHeight
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for unscaledHeight.
		 */
		private var _unscaledHeight	: Number;
		
		/**
		 *  A convenience method for determining the unscaled height of the viewport.
		 *
		 *  @return A Number which is unscaled height of the component
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get unscaledHeight():Number
		{
			return _unscaledHeight;
		}
		
		
		
		
		
		//TODO tink comment and implement properly
		protected var _elements	: Vector.<IVisualElement>;
		public function get elements():Vector.<IVisualElement>
		{
			return _elements;
		}
		
		
		private var _sizeChangedInLayoutPass:Boolean;
		public function get sizeChangedInLayoutPass():Boolean
		{
			return _sizeChangedInLayoutPass;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override public function set target( value:GroupBase ):void
		{
			if( target == value ) return;
			
			if( target ) restoreElements();
			super.target = value;
			
			_targetChanged = true;
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Methods
		//
		//--------------------------------------------------------------------------
		
		
		override public function measure():void
		{
			updateElements();
			updateElementsInLayout();
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override public function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			_sizeChangedInLayoutPass = _unscaledWidth != unscaledWidth || _unscaledHeight != unscaledHeight;
			_unscaledWidth = unscaledWidth;
			_unscaledHeight = unscaledHeight;
			
			//			if( _elementsChanged || _targetChanged )
			//			{
			//				_elementsChanged = false;
			//				updateElements();
			//			}
			
			var scrollPositionInvalid:Boolean;
			
			//TODO support includeInLayout
			// Only really want to do this if...
			// a) the number of elements have changed
			// b) includeLayout has changed on an element
			 updateElementsInLayout();
			
			// TODO This was move to measure, but if the target has an explicit size
			// measure isn't invoked, so checking it here too.
			// If fired in measure this should no longer get invoked due to
			// the check in place.
			if( !indicesInLayout || target.numElements != indicesInLayout.length + indicesNotInLayout.length )
			{
				updateElements();
				updateElementsInLayout();
			}
			
			//			if( numElementsInLayout != _numElementsInLayout ) scrollPositionInvalid = true;
			
			// If the selected index has changed exit the method as its handle in selectedIndex
			if( _numElementsInLayout == 0 )
			{
				//				_selectedIndex = -1;
				_selectedIndexInvalid = true;
				_proposedSelectedIndex = -1;
				//				_proposedSelectedIndexOffset = 0;
			}
			else if( selectedIndex == -1 )
			{
				_selectedIndexInvalid = true;
				_proposedSelectedIndex = 0;
				//				_proposedSelectedIndexOffset = 0;
				//				scrollPositionChanged();
				scrollPositionInvalid = true;
			}
			else if( selectedIndex >= _numElementsInLayout )
			{
				_selectedIndexInvalid = true;
				_proposedSelectedIndex = 0;
				scrollPositionInvalid = true;
			}
			
			if( _targetChanged )
			{
				_targetChanged = false;
				
				// Only update if the target was changed after the selectedIndex
				if( !_selectedIndexChangedAfterTargetChanged )
				{
					//					scrollPositionChanged();
					scrollPositionInvalid = true;
				}
				else
				{
					_selectedIndexChangedAfterTargetChanged = false;
				}
			}
			
			if( scrollPositionInvalid ) scrollPositionChanged();
			
			if( _useScrollBarForNavigation )
			{
				updateScrollerForNavigation();
			}
			else
			{
				updateScrollerForContent();
			}
			
			const selectedIndexChanged:Boolean = _selectedIndexInvalid;
			
			if( _selectedIndexInvalid )
			{
				_selectedIndexInvalid = false;
				_selectedIndex = numElementsInLayout ? _proposedSelectedIndex % numElementsInLayout : _proposedSelectedIndex;
				_proposedSelectedIndex = -1;
				
				//				updateSelectedIndex( _proposedSelectedIndex, _proposedSelectedIndexOffset );
				//				updateSelectedIndex( _proposedSelectedIndex, 0 );
			}
			
			if( selectedIndex > -1 )
			{
				if( useVirtualLayout )
				{
					_selectedElement = target ? target.getVirtualElementAt( indicesInLayout[ selectedIndex ] ) : null;
				}
				else
				{
					_selectedElement = target ? target.getElementAt( indicesInLayout[ selectedIndex ] ) : null;
				}
			}
			
			updateDisplayListBetween();
			
			if( useVirtualLayout )
			{
				updateDisplayListVirtual();
			}
			else
			{
				updateDisplayListReal();
			}
			
			_sizeChangedInLayoutPass = false;
			
			if( selectedIndexChanged )
			{
				if( _programmaticSelectedIndex == selectedIndex )
				{
					dispatchEvent( new FlexEvent( FlexEvent.VALUE_COMMIT ) );
				}
				else
				{
					dispatchEvent( new IndexChangeEvent( IndexChangeEvent.CHANGE ) );
				}
				_programmaticSelectedIndex = -2;
			}
		}
		
		protected function updateDisplayListBetween():void
		{
		}
		
		protected function updateElements():void
		{
			var elts:Array;
			if( target is DataGroup )
			{
				var dataGroup:DataGroup = DataGroup( target );
				
				// If the user isn't using itemRenderers instead directly adding children to the dataProvider
				if( !dataGroup.itemRenderer && dataGroup.itemRendererFunction == null && dataGroup.dataProvider )
				{
					elts = dataGroup.dataProvider.toArray();
				}
				else
				{
					elts = new Array();
					for( var i:int = 0; i < dataGroup.numChildren; i++ )
					{
						elts.push( dataGroup.getChildAt( i ) );
					}
				}
			}
			else
			{
				try
				{
					elts = target[ "getMXMLContent" ]();
				}
				catch( e:Error )
				{
					elts = target[ "toArray" ]();
				}
				catch( e:Error )
				{
					throw new Error( "NavigatorLayoutBase cannot be used as a layout for this kind of container" );
					elts = new Array();
				}
			}
			
			_elements = ( elts ) ? Vector.<IVisualElement>( elts ) : new Vector.<IVisualElement>();
		}
		
		protected function updateElementsInLayout():void
		{
			_indicesInLayout = new Vector.<int>();
			_indicesNotInLayout = new Vector.<int>();
			
			var i:int;
			var numElements:int;
			
			if( renderingData )
			{
				numElements = target.numElements;
				for( i = 0; i < numElements; i++ )
				{
					_indicesInLayout.push( i );
				}
				
				_numElementsInLayout = _indicesInLayout.length;
				_numElementsNotInLayout = _indicesNotInLayout.length;
				return;
			}
			
			numElements = _elements.length;
			for( i = 0; i < numElements; i++ )
			{
				if( _elements[ i ].includeInLayout )
				{
					_indicesInLayout.push( i );
				}
				else
				{
					_indicesNotInLayout.push( i );
				}
			}
			_numElementsInLayout = _indicesInLayout.length;
			_numElementsNotInLayout = _indicesNotInLayout.length;
		}
		
		protected function updateScrollerForNavigation():void
		{
			if( !target ) return;
			
			var scroller:Scroller = getScroller();
			switch( scrollBarDirection )
			{
				case LayoutAxis.HORIZONTAL :
				{
					target.setContentSize( unscaledWidth * _numElementsInLayout, unscaledHeight );
					if( scroller && scroller.horizontalScrollBar ) 
					{
						scroller.horizontalScrollBar.stepSize = unscaledWidth;
						target.horizontalScrollPosition = selectedIndex * unscaledWidth;
					}
					break;
				}
				case LayoutAxis.VERTICAL :
				{
					target.setContentSize( unscaledWidth, unscaledHeight * _numElementsInLayout );
					if( scroller && scroller.verticalScrollBar )
					{
						scroller.verticalScrollBar.stepSize = unscaledHeight;
						target.verticalScrollPosition = selectedIndex * unscaledHeight;
					}
					break;
				}
			}
		}
		
		protected function updateScrollerForContent():void
		{
			target.setContentSize( unscaledWidth, unscaledHeight );
		}
		
		/**
		 *  @private
		 *  Update the layout of the virtualized elements in view.
		 */
		protected function updateDisplayListVirtual():void
		{
			//			var numElementsNoInLayout:int = _indicesNotInLayout.length;
			//			for( var i:int = 0; i < numElementsNoInLayout; i++ )
			//			{
			//				target.getVirtualElementAt( _indicesNotInLayout[ i ] );
			//			}
		}
		
		/**
		 *  @private
		 *  Update the layout of all elements that in target.
		 */
		protected function updateDisplayListReal():void
		{
			//			var numElementsNoInLayout:int = _indicesNotInLayout.length;
			//			for( var i:int = 0; i < numElementsNoInLayout; i++ )
			//			{
			//				target.getElementAt( _indicesNotInLayout[ i ] );
			//			}
		}
		
		protected function setElementLayoutBoundsSize( element:IVisualElement, postLayoutTransform:Boolean = true ):void
		{
			if( !element ) return;
			element.setLayoutBoundsSize(
				getElementLayoutBoundsWidth( element, postLayoutTransform ),
				getElementLayoutBoundsHeight( element, postLayoutTransform ),
				postLayoutTransform );
		}
		
		protected function getElementLayoutBoundsWidth( element:IVisualElement, postLayoutTransform:Boolean = true ):Number
		{
			return isNaN( element.percentWidth ) ? element.getPreferredBoundsWidth( postLayoutTransform ) : unscaledWidth * ( element.percentWidth / 100 )
		}
		
		protected function getElementLayoutBoundsHeight( element:IVisualElement, postLayoutTransform:Boolean = true ):Number
		{
			return isNaN( element.percentHeight ) ? element.getPreferredBoundsHeight( postLayoutTransform ) : unscaledHeight * ( element.percentHeight / 100 );
		}
		
		override protected function scrollPositionChanged() : void
		{
			if( !target || !_useScrollBarForNavigation ) return;
			
			var scrollPosition:Number;
			var indexMaxScroll:Number;
			switch( scrollBarDirection )
			{
				case LayoutAxis.HORIZONTAL :
				{
					scrollPosition = horizontalScrollPosition;
					indexMaxScroll = ( _unscaledWidth * _numElementsInLayout ) / _numElementsInLayout;
					break;
				}
				case LayoutAxis.VERTICAL :
				{
					scrollPosition = verticalScrollPosition;
					indexMaxScroll = ( _unscaledHeight * _numElementsInLayout ) / _numElementsInLayout;
					break;
				}
			}
			
			if( target.numElements )
			{
				//				updateSelectedIndex( Math.round( scrollPosition / indexMaxScroll ),
				//								( scrollPosition % indexMaxScroll > indexMaxScroll / 2 ) ? -( 1 - ( scrollPosition % indexMaxScroll ) / indexMaxScroll ) : ( scrollPosition % indexMaxScroll ) / indexMaxScroll );			
				invalidateSelectedIndex( Math.round( scrollPosition / indexMaxScroll ),
					( scrollPosition % indexMaxScroll > indexMaxScroll / 2 ) ? -( 1 - ( scrollPosition % indexMaxScroll ) / indexMaxScroll ) : ( scrollPosition % indexMaxScroll ) / indexMaxScroll );			
			}
			else
			{
				//				updateSelectedIndex( -1, NaN );
				invalidateSelectedIndex( -1, NaN );
			}
		}
		
		protected function updateScrollBar( index:int, offset:Number ):void
		{
			if( !target ) return;
			
			var scroller:Scroller = getScroller();
			switch( scrollBarDirection )
			{
				case LayoutAxis.HORIZONTAL :
				{
					if( !isNaN( unscaledWidth ) ) target.horizontalScrollPosition = ( index + offset ) * unscaledWidth;
				}
				case LayoutAxis.VERTICAL :
				{
					if( !isNaN( unscaledHeight ) ) target.verticalScrollPosition = (  index + offset ) * unscaledHeight;
				}
			}
		}
		
		/**
		 *  Updates the selectedIndex and selectedIndexOffset properties if they have changed.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */  
		//		protected function updateSelectedIndex( index:int, offset:Number ):void
		//		{
		////			trace( "updateSelectedIndex", index, offset );
		//			if( _selectedIndex == index ) return;// && ( _selectedIndexOffset == offset || ( isNaN( _selectedIndexOffset ) && isNaN( offset ) ) ) ) return;
		//			
		//			_proposedSelectedIndex = -1;
		////			_proposedSelectedIndexOffset = 0;
		//			
		//			_selectedIndexChanged = _selectedIndex != index;
		//			_selectedIndex = index;
		////			_selectedIndexOffset = offset;
		////			invalidateTargetDisplayList();
		//		}
		
		private var _proposedSelectedIndex:int = -1;
		//		private var _proposedSelectedIndexOffset:Number = 0;;
		private var _selectedIndexInvalid:Boolean;
		protected function invalidateSelectedIndex( index:int, offset:Number ):void
		{
			if( _proposedSelectedIndex == index ) return;// && ( _proposedSelectedIndexOffset == offset || ( isNaN( _proposedSelectedIndexOffset ) && isNaN( offset ) ) ) ) return;
			
			_selectedIndexInvalid = true;
			_proposedSelectedIndex = index;// % numElementsInLayout;
			//			_proposedSelectedIndexOffset = offset;
			invalidateTargetDisplayList();
		}
		
		protected function indicesInView( firstIndexinView:int, numIndicesInView:int ):void
		{
			if( firstIndexinView == _firstIndexInView && _numIndicesInView == numIndicesInView ) return;
			
			_firstIndexInView = firstIndexinView;
			_numIndicesInView = numIndicesInView;
			
			_lastIndexInView = _firstIndexInView + ( _numIndicesInView - 1 );
			
			invalidateTargetDisplayList();
		}
		
		protected function invalidateTargetDisplayList() : void
		{
			if( !target ) return;
			
			target.invalidateDisplayList();
		}
		
		public function invalidateTargetSize() : void
		{
			if( !target ) return;
			
			target.invalidateSize();
		}
		
		/**
		 *  Returns a reference to the views Scroller if there is one.
		 *	If there is no Scroller for the view <code>null</code> is returned.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		protected function getScroller():Scroller
		{
			if( !target ) return null;
			
			// TODO changes for NavigatorApplication, look into
			try
			{
				return target.parent.parent as Scroller;
			}
			catch( e:Error )
			{
				
			}
			
			return null;
		}
		
		//		/**
		//		 *  @inheritDoc
		//		 *  
		//		 *  @langversion 3.0
		//		 *  @playerversion Flash 10
		//		 *  @playerversion AIR 1.5
		//		 *  @productversion Flex 4
		//		 */
		//		override public function elementAdded( index:int ):void
		//		{
		//			super.elementAdded( index );
		//			
		//			_elementsChanged = true;
		//			
		//			invalidateTargetDisplayList();
		//			//TODO maybe add a listener here for "includeInLayoutChanged"
		//			// not implement due to risk of not being able to remove the listener
		//			// (https://bugs.adobe.com/jira/browse/SDK-25896)
		//			
		//			
		//			// TODO Tink
		//			// We should fire this if the index added is less or equal to the
		//			// selectedIndex.
		//			// WE NEED TO FORCE THIS TO UPDATE THOUGH AS IT WON'T BY DEFAULT
		//			// AS THE INDEX HASN'T CHANGED
		////			if( selectedIndex == -1 ) scrollPositionChanged();
		//		}
		
		//		/**
		//		 *  @inheritDoc
		//		 *  
		//		 *  @langversion 3.0
		//		 *  @playerversion Flash 10
		//		 *  @playerversion AIR 1.5
		//		 *  @productversion Flex 4
		//		 */
		//		override public function elementRemoved(index:int):void
		//		{
		//			super.elementRemoved( index );
		//			
		//			_elementsChanged = true;
		//			
		//			//TODO restor element (https://bugs.adobe.com/jira/browse/SDK-25896)
		//			
		//			// TODO Tink
		//			// We should fire this if the index added is less or equal to the
		//			// selectedIndex.
		//			// WE NEED TO FORCE THIS TO UPDATE THOUGH AS IT WON'T BY DEFAULT
		//			// AS THE INDEX HASN'T CHANGED
		////			if( selectedIndex == -1 ) scrollPositionChanged();
		//		}
		
		/**
		 *  @private
		 */
		protected function restoreElements():void
		{
			// When using virtualization, elements get created after updateElements()
			// has been invoked as part of getVirtualItemAt(), therefore we must re-calculate them.
			if( target is DataGroup && target.numChildren != _elements.length ) updateElements();
			
			for each( var element:IVisualElement in _elements )
			{
				// Only restoe the element if its includeInLayout property
				// is true.
				if( element.includeInLayout ) restoreElement( element );
			}
		}
		
		override public function updateScrollRect( w:Number, h:Number ):void
		{
			if( !target ) return;
			
			target.scrollRect = clipAndEnableScrolling ? new Rectangle( 0, 0, w, h ) : null;
		}
		
		/**
		 *  Restores the element to reset any changes to is visible properties. 
		 *  This method should be overridden in a subclass to return any elements
		 *  used in the layout to its default state when it is removed from the
		 *  targets displayList or when the target is removed from the layout.
		 * 
		 *  @param element The element to be restored.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		protected function restoreElement( element:IVisualElement ):void
		{
			
		}
		
		override public function getHorizontalScrollPositionDelta( navigationUnit:uint ):Number
		{
			if( _useScrollBarForNavigation )
			{
				switch( navigationUnit )
				{
					case NavigationUnit.PAGE_RIGHT :
					case NavigationUnit.RIGHT :
					{
						return unscaledWidth;
					}
					case NavigationUnit.END :
					{
						return ( unscaledWidth * ( _numElementsInLayout - 1 ) ) - horizontalScrollPosition;
					}
					case NavigationUnit.HOME :
					{
						return -horizontalScrollPosition;
					}
					case NavigationUnit.PAGE_LEFT :
					case NavigationUnit.LEFT :
					{
						return -unscaledWidth;
					}
					default :
					{
						return 0;
					}
				}
			}
			else
			{
				return super.getHorizontalScrollPositionDelta( navigationUnit );
			}
		}
		
		override public function getVerticalScrollPositionDelta( navigationUnit:uint ):Number
		{
			if( _useScrollBarForNavigation )
			{
				switch( navigationUnit )
				{
					case NavigationUnit.PAGE_DOWN :
					case NavigationUnit.DOWN :
					{
						return unscaledHeight;
					}
					case NavigationUnit.END :
					{
						return ( unscaledHeight * ( _numElementsInLayout - 1 ) ) - verticalScrollPosition;
					}
					case NavigationUnit.HOME :
					{
						return -verticalScrollPosition;
					}
					case NavigationUnit.PAGE_UP :
					case NavigationUnit.UP :
					{
						return -unscaledHeight;
					}
					default :
					{
						return 0;
					}
				}
			}
			else
			{
				return super.getVerticalScrollPositionDelta( navigationUnit );
			}
		}
		
		final protected function applyColorTransformToElement( element:IVisualElement, colorTransform:ColorTransform ):void
		{
			if( element is GraphicElement )
			{
				GraphicElement( element ).transform.colorTransform = colorTransform;
			}
			else
			{
				DisplayObject( element ).transform.colorTransform = colorTransform;
			}
		}
		
	}
}