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
package spark.layouts
{
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import mx.core.ILayoutElement;
	import mx.core.ISelectableList;
	import mx.core.IVisualElement;
	import mx.core.mx_internal;
	
	import spark.components.supportClasses.ButtonBarBase;
	import spark.components.supportClasses.GroupBase;
	import spark.effects.animation.Animation;
	
	import spark.layouts.supportClasses.AnimationNavigatorLayoutBase;
	import spark.layouts.supportClasses.LayoutAxis;

	use namespace mx_internal;
	
	/**
	 *  An AccordionLayout class arranges the layout elements in a vertical
	 *  or horizontal sequence, with one of them at a time fully visible.
	 * 
	 *  <p>The position of the elements is determined by arranging them
	 *  in a sequence, top to bottom or left to right depending on the
	 *  value or <code>duration</code>.</p>
	 * 
	 *  <p>If the <code>target</code> of the layout implements ISelectable list,
	 *  a ButtonBarBase can be set using the <code>buttonBar</code> property and the layout
	 *  will connect the <code>target</code> and ButtonBarBase together so that the 
	 *  ButtonBarBase can be used to navigate through the elements.</p>
	 *
	 *  @mxml
	 *
	 *  <p>The <code>&lt;st:Accordion&gt;</code> tag inherits all of the
	 *  tag attributes of its superclass, and adds the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;st:AccordionLayout
	 *    <strong>Properties</strong>
	 *    buttonRotation="none|left|right"
	 *    direction="vertical|horizontal"
	 *    duration="700"
	 *    easer=""<i>IEaser</i>""
	 *    labelField="label"
	 *    labelFunction="null"
	 *    layoutAllButtonBarBounds="true"
	 *    minElementSize="0"
	 *    useScrollRect"true"
	 *  /&gt;
	 *  </pre>
	 *
	 *  @includeExample examples/AccordionExample.mxml
	 *
	 *  @see spark.layouts.AccordionLayout
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public class AccordionLayout extends AnimationNavigatorLayoutBase
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
		public function AccordionLayout()
		{
			super( AnimationNavigatorLayoutBase.DIRECT );
			_measuredCache = new MeasuredCache();
			_buttonLayout = new ButtonLayout( this );
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private var _proposedSelectedIndexOffset	: Number = 0;
		
		/**
		 *  @private
		 */
		private var _buttonLayout:ButtonLayout;
		
		/**
		 *  @private
		 */
		private var _elementSizes:Vector.<ElementSize> = new Vector.<ElementSize>();
		
		/**
		 *  @private
		 */
		private var _animator:Animation;
		
		/**
		 *  @private
		 */
		private var _measuredCache:MeasuredCache;
		
		/**
		 *  @private
		 *  Flag to indicate the size and positioning of the buttonBar have changed.
		 */
		private var _buttonBarChanged:Boolean;
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  buttonRotation
		//----------------------------------    
		
		/**
		 *  @private
		 *  Storage property for buttonRotation.
		 */
		private var _buttonRotation:String = "none";
		
		[Inspectable(category="General", enumeration="none,left,right", defaultValue="none")]
		
		/** 
		 *  rotateButtonBar.
		 * 
		 *  @default "vertical"
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get buttonRotation():String
		{
			return _buttonRotation;
		}
		/**
		 *  @private
		 */
		public function set buttonRotation( value:String ):void
		{
			if( value == _buttonRotation ) return;
			
			_buttonRotation = value;
			
			_buttonBarChanged = true;
			_elementSizesInvalid = true;
			_buttonLayout.invalidateTargetDisplayList();
			invalidateTargetDisplayList();
			invalidateTargetSize();
		}
		
		
		//----------------------------------
		//  direction
		//----------------------------------    
		
		/**
		 *  @private
		 *  Storage property for direction.
		 */
		private var _direction:String = LayoutAxis.VERTICAL;
		
		[Inspectable(category="General", enumeration="vertical,horizontal", defaultValue="vertical")]
		
		/** 
		 *  direction.
		 * 
		 *  @default "vertical"
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get direction():String
		{
			return _direction;
		}
		/**
		 *  @private
		 */
		public function set direction( value:String ):void
		{
			if( value == _direction ) return;
			
			_direction = value;
			
			_buttonBarChanged = true;
			_elementSizesInvalid = true;
			_buttonLayout.invalidateTargetDisplayList();
			_buttonLayout.invalidateTargetSize();
			invalidateTargetDisplayList();
			invalidateTargetSize();
		}
		
		
		//----------------------------------
		//  overlayButtonBar
		//----------------------------------    
		
		/**
		 *  @private
		 *  Storage property for overlayButtonBar.
		 */
		private var _layoutAllButtonBarBounds:Boolean = false;
		
		[Inspectable(category="General", enumeration="true,false", defaultValue="true")]
		
		/** 
		 *  overlayButtonBar.
		 * 
		 *  @default "vertical"
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get layoutAllButtonBarBounds():Boolean
		{
			return _layoutAllButtonBarBounds;
		}
		/**
		 *  @private
		 */
		public function set layoutAllButtonBarBounds( value:Boolean ):void
		{
			if( value == _layoutAllButtonBarBounds ) return;
			
			_layoutAllButtonBarBounds = value;
			
			_buttonBarChanged = true;
			_buttonLayout.invalidateTargetDisplayList();
			_buttonLayout.invalidateTargetSize();
			invalidateTargetDisplayList();
			invalidateTargetSize();
		}
		
		//----------------------------------
		//  minElementSize
		//----------------------------------    
		
		/**
		 *  @private
		 *  Storage property for minElementSize.
		 */
		private var _minElementSize:Number = 0;
		
		/** 
		 *  The minumm size of an element when it's element index isn't the
		 *  selectedIndex of the layout.
		 * 
		 *  @default 0
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get minElementSize():Number
		{
			return _minElementSize;
		}
		/**
		 *  @private
		 */
		public function set minElementSize( value:Number ):void
		{
			if( value == _minElementSize ) return;
			
			_minElementSize = value;
			
			_elementSizesInvalid = true;
			invalidateTargetDisplayList();
			if( target ) target.invalidateSize();
		}
		
		
//		//----------------------------------
//		//  verticalAlign
//		//----------------------------------    
//		
//		/**
//		 *  @private
//		 *  Storage property for verticalAlign.
//		 */
//		private var _verticalAlign:String = VerticalAlign.JUSTIFY;
//		
//		[Inspectable(category="General", enumeration="justify", defaultValue="justify")]
//		
//		/** 
//		 *  The vertical alignment of layout elements.
//		 * 
//		 *  <p>If the value is <code>"bottom"</code>, <code>"middle"</code>, 
//		 *  or <code>"top"</code> then the layout elements are aligned relative 
//		 *  to the container's <code>contentHeight</code> property.</p>
//		 * 
//		 *  <p>If the value is <code>"contentJustify"</code> then the actual
//		 *  height of the layout element is set to 
//		 *  the container's <code>contentHeight</code> property. 
//		 *  The content height of the container is the height of the largest layout element. 
//		 *  If all layout elements are smaller than the height of the container, 
//		 *  then set the height of all the layout elements to the height of the container.</p>
//		 * 
//		 *  <p>If the value is <code>"justify"</code> then the actual height
//		 *  of the layout elements is set to the container's height.</p>
//		 *
//		 *  <p>This property does not affect the layout's measured size.</p>
//		 *  
//		 *  @default "justify"
//		 *  
//		 *  @langversion 3.0
//		 *  @playerversion Flash 10
//		 *  @playerversion AIR 1.5
//		 *  @productversion Flex 4
//		 */
//		public function get verticalAlign():String
//		{
//			return _verticalAlign;
//		}
//		/**
//		 *  @private
//		 */
//		public function set verticalAlign( value:String ):void
//		{
////			if( value == _verticalAlign ) return;
////			
////			_verticalAlign = value;
////			
////			invalidateTargetDisplayList();
//		}
//		
//		
//		//----------------------------------
//		//  horizontalAlign
//		//----------------------------------  
//		
//		/**
//		 *  @private
//		 *  Storage property for horizontalAlign.
//		 */
//		private var _horizontalAlign:String = HorizontalAlign.JUSTIFY;
//		
//		[Inspectable(category="General", enumeration="justify", defaultValue="justify")]
//		
//		/** 
//		 *  The horizontal alignment of layout elements.
//		 *  If the value is <code>"left"</code>, <code>"right"</code>, or <code>"center"</code> then the 
//		 *  layout element is aligned relative to the container's <code>contentWidth</code> property.
//		 * 
//		 *  <p>If the value is <code>"contentJustify"</code>, then the layout element's actual
//		 *  width is set to the <code>contentWidth</code> of the container.
//		 *  The <code>contentWidth</code> of the container is the width of the largest layout element. 
//		 *  If all layout elements are smaller than the width of the container, 
//		 *  then set the width of all layout elements to the width of the container.</p>
//		 * 
//		 *  <p>If the value is <code>"justify"</code> then the layout element's actual width
//		 *  is set to the container's width.</p>
//		 *
//		 *  <p>This property does not affect the layout's measured size.</p>
//		 *  
//		 *  @default "justify"
//		 *  
//		 *  @langversion 3.0
//		 *  @playerversion Flash 10
//		 *  @playerversion AIR 1.5
//		 *  @productversion Flex 4
//		 */
//		public function get horizontalAlign():String
//		{
//			return _horizontalAlign;
//		}
//		/**
//		 *  @private
//		 */
//		public function set horizontalAlign( value:String ):void
//		{
////			if( value == _horizontalAlign ) return;
////			
////			_horizontalAlign = value;
////			
////			invalidateTargetDisplayList();
//		}
		
		
		//----------------------------------
		//  buttonBar
		//----------------------------------    
		
		/**
		 *  @private
		 *  Storage property for buttonBar.
		 */
		private var _buttonBar:ButtonBarBase;
		
		/**
		 *  useScrollRect
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get buttonBar():ButtonBarBase
		{
			return _buttonBar;
		}
		/**
		 *  @private
		 */
		public function set buttonBar( value:ButtonBarBase ):void
		{
			if( _buttonBar == value ) return;
			_buttonBar = value;
			
			if( _buttonBar )
			{
				_buttonBar.layout = _buttonLayout;
				if( _buttonBar && target is ISelectableList ) _buttonBar.dataProvider = ISelectableList( target );
				if( target ) target.invalidateSize();
			}
		}
		
		
		//----------------------------------
		//  useScrollRect
		//----------------------------------    
		
		/**
		 *  @private
		 *  Storage property for useScrollRect.
		 */
		private var _useScrollRect:Boolean = true;
		
		/**
		 *  useScrollRect
		 * 
		 *  @default true
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get useScrollRect():Boolean
		{
			return _useScrollRect;
		}
		/**
		 *  @private
		 */
		public function set useScrollRect( value:Boolean ):void
		{
			if( _useScrollRect == value ) return;
			
			_useScrollRect = value;
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  target
		//----------------------------------    
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override public function set target(value:GroupBase):void
		{
			if( target == value ) return;

			super.target = value;
			
			if( _buttonBar && target is ISelectableList ) _buttonBar.dataProvider = ISelectableList( target );
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		
		
		/**
		 *  @private
		 *  Sort function used to store the list of element sizes in display list order.
		 */
		private function sortElementSizes( a:ElementSize, b:ElementSize ):int
		{
			if( a.displayListIndex < b.displayListIndex ) return -1;
			if( a.displayListIndex > b.displayListIndex ) return 1;
			return 0;
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Methods
		//
		//--------------------------------------------------------------------------
		
		private var _elementSizesInvalid:Boolean;
		
		public function invalidateElementSizes():void
		{
			_elementSizesInvalid = true;
			invalidateTargetDisplayList();
		}
		
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		
		override protected function updateDisplayListBetween():void
		{
			if( sizeChangedInLayoutPass || _buttonBarChanged )
			{
				_buttonBarChanged = false;
				
				// TODO I think this should solve the issue of animating when resizing.
				// If we are resizing due to an index change we want to animate,
				// if its not due to an index change we do not want to animate.
				if( !animationValue ) clearVirtualLayoutCache();
					
				_elementSizesInvalid = true;
				_buttonLayout.invalidateTargetDisplayList();
				if( _buttonBar && target )
				{
					_buttonBar.includeInLayout = !layoutAllButtonBarBounds;
					
					if( _layoutAllButtonBarBounds && !isNaN( unscaledWidth ) && !isNaN( unscaledHeight ) )
					{
						_buttonBar.setLayoutBoundsSize( unscaledWidth, unscaledHeight );
						_buttonBar.setLayoutBoundsPosition( target.x, target.y );
					}
				}
			}
		}
		
		
		
		override public function measure():void
		{
			super.measure();

			if( !target ) return;
			
			if( !indicesInLayout || !indicesInLayout.length )
			{
				target.measuredWidth = target.measuredMinWidth;
				target.measuredHeight = target.measuredMinHeight;
				return;
			}  
			
			var i:int
			var element:ILayoutElement;
			
			if( _buttonBarChanged ) _measuredCache.reset();
			
			if( !useVirtualLayout )
			{
				// If we are not using a virtual layout, reset the measured cache
				// and measure all elements again.
				_measuredCache.reset();
				for each( i in indicesInLayout )
				{
					_measuredCache.cache( target.getElementAt( indicesInLayout[ i ] ) );
				}
			}
			else if( selectedIndex != -1 )
			{
				const index:int = selectedIndex >= numElementsInLayout ? numElementsInLayout - 1 : 0
				// If we are using a virtual layout, cache the size of the selected item.
				_measuredCache.cache( target.getElementAt( indicesInLayout[ index ] ) );
			}
			
			const prevButtonSize:Number = _buttonLayout._totalSize;
			_buttonLayout._totalSize = 0;
			_buttonLayout._buttonSizes = new Vector.<int>();
			
			if( _buttonBar )
			{
				
				var matrix:Matrix = new Matrix();
				var rotation:Number = buttonRotation == "none" ? 0 : buttonRotation == "left" ? -90 : 90;
				if( rotation ) matrix.rotate( rotation * ( Math.PI / 180 ) );

				var size:Number;
				const numElements:int = target.numElements;
				var s:Number = 0;
				for( i = 0; i < numElements; i++ )
				{
					element = _buttonLayout.target.getElementAt( i );
					
					if( !element ) continue;
					if( matrix ) element.setLayoutMatrix( matrix, true );
					
					if( direction == LayoutAxis.VERTICAL  )
					{
						size = element.getPreferredBoundsHeight();
						if( i < numElements - 1 ) size--;
						_buttonLayout._totalSize += size;
					}
					else
					{
						size = element.getPreferredBoundsWidth();
						if( i < numElements - 1 ) size--;
						_buttonLayout._totalSize += size;
					}
					
					_buttonLayout._buttonSizes[ i ] = size;
				}
			}
			
			var w:Number = 0;
			var h:Number = 0;
			switch( direction )
			{
				case  LayoutAxis.VERTICAL :
				{
					if( minElementSize ) h += minElementSize * ( numElementsInLayout - 1 );
					if( _buttonBar ) h += _buttonLayout._totalSize;
					break;
				}
				case  LayoutAxis.HORIZONTAL :
				{
					if( minElementSize ) w += minElementSize * ( numElementsInLayout - 1 );
					if( _buttonBar ) w += _buttonLayout._totalSize;
					break;
				}
			}
			
			
			target.measuredWidth = _measuredCache.measuredWidth + w;
			target.measuredHeight = _measuredCache.measuredHeight + h;
			target.measuredMinWidth = target.measuredWidth;
			target.measuredMinHeight = target.measuredHeight;
			
			// Use Math.ceil() to make sure that if the content partially occupies
			// the last pixel, we'll count it as if the whole pixel is occupied.
			target.measuredWidth = Math.ceil( target.measuredWidth );    
			target.measuredHeight = Math.ceil( target.measuredHeight );    
			target.measuredMinWidth = Math.ceil( target.measuredMinWidth );    
			target.measuredMinHeight = Math.ceil( target.measuredMinHeight );  
			
			if( _buttonBar )
			{
				_buttonBar.invalidateSize();
				_buttonBar.validateNow();
				
				if( target.measuredWidth < _buttonBar.measuredWidth ) target.measuredWidth = Math.ceil( _buttonBar.measuredWidth );
				if( target.measuredMinWidth < _buttonBar.measuredMinWidth ) target.measuredMinWidth = Math.ceil( _buttonBar.measuredMinWidth );
				
				if( target.measuredHeight < _buttonBar.measuredHeight ) target.measuredHeight = Math.ceil( _buttonBar.measuredHeight );
				if( target.measuredMinHeight < _buttonBar.measuredMinHeight ) target.measuredMinHeight = Math.ceil( _buttonBar.measuredMinHeight );
			}
			
			if( prevButtonSize != _buttonLayout._totalSize ) 
			{
				invalidateElementSizes();
				invalidateTargetDisplayList();
			}
		}
		
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			_elementSizesInvalid = false;
			updateDisplayListElements();
		}
		
		
		/**
		 *  @inheritDoc
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override public function clearVirtualLayoutCache():void
		{
			super.clearVirtualLayoutCache();
			
			// At this point we don't want animation so we clear out the element sizes.
			_elementSizes = new Vector.<ElementSize>();
			
			_measuredCache.reset();
		}
		
		
		
		/**
		 *  @private
		 */
		private function updateDisplayListElements():void
		{
//			var prevSize:Number;
			var elementSize:ElementSize;
			var element:IVisualElement;
			var elementPos:Number = 0;
			const offsetMultiplier:Number = 1 - animationValue;
			const numElements:int = _elementSizes.length;
			for( var i:int = 0; i < numElements; i++ )
			{
				if( _buttonLayout._buttonSizes.length > i )
				{
					element = _buttonLayout.target.getElementAt( i );
					if( direction == LayoutAxis.VERTICAL )
					{
						element.setLayoutBoundsPosition( 0, elementPos );
					}
					else
					{
						element.setLayoutBoundsPosition( elementPos, 0 );
					}
					elementPos += _buttonLayout._buttonSizes[ i ];
				}
				
				elementSize = _elementSizes[ i ];
//				prevSize = elementSize.size;
				elementSize.size = elementSize.start + ( elementSize.diff * offsetMultiplier );
				
				if( elementSize.start || elementSize.diff )
				{
					if( direction == LayoutAxis.VERTICAL )
					{
						if( _useScrollRect && elementSize.element is DisplayObject )
						{
							DisplayObject( elementSize.element ).scrollRect = new Rectangle( 0, 0, unscaledWidth, elementSize.size );
							elementSize.element.setLayoutBoundsSize( unscaledWidth, unscaledHeight - _buttonLayout._totalSize );
						}
						else
						{
							elementSize.element.setLayoutBoundsSize( unscaledWidth, elementSize.size );
						}
						
						elementSize.element.setLayoutBoundsPosition( 0, elementPos );
					}
					else
					{
						if( _useScrollRect && elementSize.element is DisplayObject )
						{
							DisplayObject( elementSize.element ).scrollRect = new Rectangle( 0, 0, elementSize.size, unscaledHeight );
							elementSize.element.setLayoutBoundsSize( unscaledWidth - _buttonLayout._totalSize, unscaledHeight );
						}
						else
						{
							elementSize.element.setLayoutBoundsSize( elementSize.size, unscaledHeight );
						}
						
						elementSize.element.setLayoutBoundsPosition( elementPos, 0 );
					}
					
					
				}
				
				elementPos += elementSize.size;
			}
		}
		
		
		private function update( e:ElementSize, selectedSize:Number, creatingAll:Boolean ):void
		{
			if( creatingAll )
			{
				e.size = e.layoutIndex == selectedIndex ? selectedSize : minElementSize;
				e.start = e.size;
			}
			else
			{
				e.start = e.size;
				e.diff = e.layoutIndex == selectedIndex ? selectedSize - e.start : minElementSize - e.start;
			}
		}
		
		
		
		
		/**
		 *  @inheritDoc
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override protected function updateDisplayListVirtual():void
		{
			super.updateDisplayListVirtual();		

			if( !indicesInLayout.length ) return;
			
			var i:int;
			var elementSize:ElementSize;
			const numElementSizes:int = _elementSizes.length;
			const creatingAll:Boolean = numElementSizes == 0;
			
			if( _elementSizesInvalid )
			{
				// We use this vector to store a reference to the element index
				// of any item that is currently in the display list.
				// If we are creating a new elementSize, we must make sure that this element
				// is actually added (i.e. not worry about being virtual as it's already created).
//				const indicesCreated:Vector.<int> = new Vector.<int>();
				const size:Number = direction == LayoutAxis.VERTICAL ? unscaledHeight : unscaledWidth;
				const selectedSize:Number = size - _buttonLayout._totalSize - ( minElementSize * ( numElementsInLayout - 1 ) );
				
				// Store a reference to the indices that we need ElementSize items for.
				var indicesRequired:Vector.<int>;
				var indicesRequiredIndex:int;
				var element:IVisualElement;
				
				if( buttonBar || minElementSize >= 0 )
				{
					indicesRequired = indicesInLayout.concat();
				}
				else
				{
//					if( target.numChildren > 1 )
//					{
//						for( i = 0; i < target.numChildren; i++ )
//						{
//							element =  IVisualElement( target.getChildAt( i ) );
//							if( element.includeInLayout )
//							{
//								// Store a reference to the the element index of all children.
//								indicesCreated.push( target.getElementIndex( element ) );
//								
//							}
//						}
//					}
//					
//					// Also add this as an index that is required.
//					indicesRequired = indicesCreated.concat();
					
					// Make sure we always push the selectedIndex
					var selected:int = indicesInLayout[ selectedIndex ];
					if( indicesRequired && indicesRequired.indexOf( selected ) == -1 ) 
						indicesRequired.push( selected );
				}
				
				for( i = numElementSizes - 1; i >= 0; i-- )
				{
					elementSize = _elementSizes[ i ];
					
					// Remove ElementSize items that are not in the layout.
					indicesRequiredIndex = indicesRequired.indexOf( elementSize.displayListIndex );
					if( indicesRequiredIndex == -1 || !elementSize.size )
					{
						_elementSizes.splice( i, 1 );
					}
					// Update ElementSize items.
					else
					{
						if( indicesRequiredIndex != -1 ) indicesRequired.splice( indicesRequiredIndex, 1 )
						
						// Only get the virtual element if it is the selectedIndex,
						// its start size is bigger than 0, or its diff in size is bigger than 0.
						if( elementSize.displayListIndex == selectedIndex || elementSize.start || elementSize.diff ) elementSize.element = target.getVirtualElementAt( elementSize.displayListIndex );
						
						update( elementSize, selectedSize, creatingAll );
					}
				}
				
				// If we need to create some ElementSize items.
				const numElementsRequired:int = indicesRequired.length;
				for( i = 0; i < numElementsRequired; i++ )
				{
					elementSize = new ElementSize();
					elementSize.diff = 0;
					elementSize.size = minElementSize;
					elementSize.displayListIndex = indicesRequired[ i ];
					elementSize.layoutIndex = indicesInLayout.indexOf( elementSize.displayListIndex );
					
					// Only get the virtual element if it is the selectedIndex,
					// its start size is bigger than 0.
					if( elementSize.displayListIndex == selectedIndex ||
						elementSize.start || elementSize.size )
//					indicesCreated.indexOf( elementSize.displayListIndex ) != -1 )
					{
						elementSize.element = target.getVirtualElementAt( elementSize.displayListIndex );
					}
					
					_elementSizes.push( elementSize );
					
					update( elementSize, selectedSize, creatingAll );
				}
				
				// If we've added items we now need to do a sort.
				if( numElementsRequired ) _elementSizes.sort( sortElementSizes );
			}
			else
			{
				for( i = 0; i < numElementSizes; i++ )
				{
					elementSize = _elementSizes[ i ];
					
					// Only get the virtual element if its size is bigger than 0,
					// or it is the selectedIndex.
					if( selectedIndex == elementSize.layoutIndex || elementSize.size )
					{
						elementSize.element = target.getVirtualElementAt( elementSize.displayListIndex );
					}
				}
			}
		}
		
		
		
		/**
		 *  @inheritDoc
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override protected function updateDisplayListReal():void
		{
			super.updateDisplayListReal();

			if( !indicesInLayout.length ) return;
			
			var i:int;
			var elementSize:ElementSize;
			const numElementSizes:int = _elementSizes.length;
			const creatingAll:Boolean = numElementSizes == 0;
			
			if( _elementSizesInvalid )
			{
				var indicesRequiredIndex:int;
				
				const size:Number = direction == LayoutAxis.VERTICAL ? unscaledHeight : unscaledWidth;
				const selectedSize:Number = size - _buttonLayout._totalSize - ( minElementSize * ( numElementsInLayout - 1 ) );
				
				// Store a reference to the indices that we need ElementSize items for.
				//const indicesRequired:Vector.<int> = buttonBar || minElementSize ? indicesInLayout.concat() : Vector.<int>( [ indicesInLayout[ selectedIndex ] ] );
				const indicesRequired:Vector.<int> = indicesInLayout.concat();
				
				for( i = numElementSizes - 1; i >= 0; i-- )
				{
					elementSize = _elementSizes[ i ];
					
					// Remove ElementSize items that are not in the layout.
					indicesRequiredIndex = indicesRequired.indexOf( elementSize.displayListIndex );
					if( indicesRequiredIndex == -1 && !elementSize.size )
					{
						_elementSizes.splice( i, 1 );
					}
						// Update ElementSize items.
					else
					{
						if( indicesRequiredIndex != -1 ) indicesRequired.splice( indicesRequiredIndex, 1 )
						elementSize.element = target.getElementAt( elementSize.displayListIndex );
						
						update( elementSize, selectedSize, creatingAll );
					}
				}
				
				
				// If we need to create some ElementSize items.
				const numElementsRequired:int = indicesRequired.length;
				for( i = 0; i < numElementsRequired; i++ )
				{
					elementSize = new ElementSize();
					elementSize.diff = 0;
					elementSize.size = minElementSize;
					elementSize.displayListIndex = indicesRequired[ i ];
					elementSize.layoutIndex = indicesInLayout.indexOf( elementSize.displayListIndex );
					
					elementSize.element = target.getElementAt( elementSize.displayListIndex );
					
					_elementSizes.push( elementSize );
					
					update( elementSize, selectedSize, creatingAll );
				}
				
				// If we've added items we now need to do a sort.
				if( numElementsRequired ) _elementSizes.sort( sortElementSizes );
			}
			else
			{
				for( i = 0; i < numElementSizes; i++ )
				{
					elementSize = _elementSizes[ i ];
					elementSize.element = target.getElementAt( elementSize.displayListIndex );
				}
			}
			
		}
		
		/**
		 *  @private
		 */
		override protected function invalidateSelectedIndex( index:int, offset:Number ):void
		{
			super.invalidateSelectedIndex( index, offset );
			invalidateElementSizes();
		}
		
		/**
		 *  @private
		 */
		override protected function updateIndicesInView():void
		{
			super.updateIndicesInView();
			indicesInView( 0, numElementsInLayout );
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override protected function restoreElement( element:IVisualElement ):void
		{
			super.restoreElement( element );
			
			if( element is DisplayObject ) DisplayObject( element ).scrollRect = null;
		}
        
    }
}
import flash.geom.Matrix;

import mx.core.ILayoutElement;
import mx.core.IVisualElement;

import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;

import spark.layouts.AccordionLayout;
import spark.layouts.supportClasses.LayoutAxis;


internal class ElementSize
{
	public var start:Number;
	public var diff:Number;
	
	public var displayListIndex:uint;
	public var layoutIndex:uint;
	
	
	
	public function ElementSize()
	{
	}
	
	public function toString():String
	{
		return "start: " + start.toString() + " size: " + size.toString() + " displayListIndex: " + displayListIndex.toString() + " element: " + ( element == null ).toString() + "!!!!";
	}
	
	private var _element:IVisualElement;
	public function get element():IVisualElement
	{
		return _element;
	}
	public function set element( value:IVisualElement ):void
	{
		if( _element == value ) return;
		
		_element = value;
		if( _element ) _elementChanged = true;
	}
	
	private var _size:Number;
	public function get size():Number
	{
		return _size;
	}
	public function set size( value:Number ):void
	{
		if( _size == value ) return;
		
		if( ( _size + value > 0 ) && _element ) _elementChanged = true;
		_size = value;
//		if( _size ) _elementChanged = true;
	}
	
	private var _elementChanged:Boolean;
	public function get elementChanged():Boolean
	{
		var f:Boolean = _elementChanged;
		_elementChanged = false;
		return f;
	}
}

internal class MeasuredCache
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
	public function MeasuredCache()
	{
		reset();
	}
	
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  measuredWidth
	//----------------------------------
	
	/**
	 *  @private
	 *	Storage property for measuredWidth.
	 */
	private var _measuredWidth:Number;
	
	/**
	 *  measuredWidth
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get measuredWidth():Number
	{
		return _measuredWidth;
	}
	
	
	//----------------------------------
	//  measuredHeight
	//----------------------------------
	
	/**
	 *  @private
	 *	Storage property for measuredHeight.
	 */
	private var _measuredHeight:Number;
	
	/**
	 *  measuredHeight
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get measuredHeight():Number
	{
		return _measuredHeight;
	}
	
	
	//----------------------------------
	//  measuredMinWidth
	//----------------------------------
	
	/**
	 *  @private
	 *	Storage property for measuredMinWidth.
	 */
	private var _measuredMinWidth:Number;
	
	/**
	 *  measuredMinWidth
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get measuredMinWidth():Number
	{
		return _measuredMinWidth;
	}
	
	
	//----------------------------------
	//  measuredMinHeight
	//----------------------------------
	
	/**
	 *  @private
	 *	Storage property for measuredMinHeight.
	 */
	private var _measuredMinHeight:Number;
	
	/**
	 *  measuredMinHeight
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get measuredMinHeight():Number
	{
		return _measuredMinHeight;
	}

	public function cache( elt:ILayoutElement ):void
	{
		if( !elt ) return;
		
		var preferred:Number;
		var min:Number;
		
		// Calculate preferred width first, as it's being used to calculate min width
		preferred = Math.ceil(elt.getPreferredBoundsWidth());
		// Calculate min width
		min = !isNaN(elt.percentWidth) ? Math.ceil(elt.getMinBoundsWidth()) : preferred;
		_measuredWidth = Math.max( _measuredWidth, preferred );
		_measuredMinWidth = Math.max( _measuredMinWidth, min );
		
		// Calculate preferred width first, as it's being used to calculate min width
		preferred = Math.ceil(elt.getPreferredBoundsHeight());
		// Calculate min width
		min = !isNaN(elt.percentHeight) ? Math.ceil(elt.getMinBoundsHeight()) : preferred;
		_measuredHeight = Math.max( _measuredHeight, preferred );
		_measuredMinHeight = Math.max( _measuredMinHeight, min );
		
	}
	
	public function reset():void
	{
		_measuredWidth = 0;
		_measuredMinWidth = 0;
		_measuredHeight = 0;
		_measuredMinHeight = 0;
	}
}


internal class ButtonLayout extends LayoutBase
{
	
	private var _parentLayout:AccordionLayout;
	public var _buttonSizes:Vector.<int> = new Vector.<int>();
	public var _totalSize:int = 0;
	public var _rotation:Number;
	
	public function ButtonLayout( parentLayout:AccordionLayout ):void
	{
		_parentLayout = parentLayout;
	}
	
	override public function measure():void
	{
		if( !_parentLayout.target ) return;
		var matrix:Matrix;
		var rotation:Number = _parentLayout.buttonRotation == "none" ? 0 : _parentLayout.buttonRotation == "left" ? -90 : 90;
		if( rotation != _rotation )
		{
			_rotation = rotation;
			matrix = new Matrix();
			matrix.rotate( _rotation * ( Math.PI / 180 ) );
		}

		var element:IVisualElement;
		var size:Number;
		const numElements:int = target.numElements;
		var s:Number = 0;
		for( var i:int = 0; i < numElements; i++ )
		{
			element = target.getElementAt( i );
			
			if( matrix ) element.setLayoutMatrix( matrix, true );
			
			if( _parentLayout.direction == LayoutAxis.VERTICAL  )
			{
				
				s = Math.max( s, element.getPreferredBoundsWidth() );
			}
			else
			{
				s = Math.max( s, element.getPreferredBoundsHeight() );
			}
			
		}
		
		if( _parentLayout.direction == LayoutAxis.VERTICAL  )
		{
			target.measuredWidth = target.measuredMinWidth = s;
			target.measuredHeight = _parentLayout.target.measuredHeight;
			target.measuredMinHeight = _parentLayout.target.measuredMinHeight;
		}
		else
		{
			target.measuredWidth = _parentLayout.target.measuredWidth
			target.measuredMinWidth = _parentLayout.target.measuredWidth;
			target.measuredHeight = target.measuredMinHeight = s;
		}
	}
	
	public function invalidateTargetDisplayList() : void
	{
		if( !target ) return;
		target.invalidateDisplayList();
	}
	
	public function invalidateTargetSize() : void
	{
		if( !target ) return;
		target.invalidateSize();
	}
	
	override public function set target( value:GroupBase ):void
	{
		_totalSize = 0;
		_buttonSizes.splice( 0, _buttonSizes.length );
		super.target = value;
	}
	override public function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
	{
		super.updateDisplayList( unscaledWidth, unscaledHeight );
		
		if( !target || !_parentLayout.target ) return;
		
		var matrix:Matrix;
		var rotation:Number = _parentLayout.buttonRotation == "none" ? 0 : _parentLayout.buttonRotation == "left" ? -90 : 90;
		if( rotation != _rotation )
		{
			_rotation = rotation;
			matrix = new Matrix();
			matrix.rotate( _rotation * ( Math.PI / 180 ) );
		}
			
		var element:IVisualElement;
		const numElements:int = target.numElements;
		for( var i:int = 0; i < numElements; i++ )
		{
			element = target.getElementAt( i );
			
			if( matrix ) element.setLayoutMatrix( matrix, true );
			
			if( _parentLayout.direction == LayoutAxis.VERTICAL  )
			{
				element.setLayoutBoundsSize( unscaledWidth, element.getPreferredBoundsHeight() );
			}
			else
			{
				element.setLayoutBoundsSize( element.getPreferredBoundsWidth(), unscaledHeight );
			}
		}
		
		_parentLayout.invalidateElementSizes();
	}
	
}
