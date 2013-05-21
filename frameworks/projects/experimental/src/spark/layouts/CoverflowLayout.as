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
	
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	
	import spark.layouts.HorizontalAlign;
	import spark.layouts.VerticalAlign;
	import spark.primitives.supportClasses.GraphicElement;
	
	import spark.layouts.supportClasses.PerspectiveAnimationNavigatorLayoutBase;
	
	/**
	 *  A CoverflowLayout class arranges the layout elements in a
	 *  linear along with unselected items having a different z and rotation.
	 * 
	 *  <p>The horizontal position of the elements is determined by the combined
	 *  reult of <code>horizontalAlign</code>, <code>horizontalDisplacement</code>,
	 *  <code>horizontalAlignOffset</code> or <code>horizontalAlignOffsetPercent</code>,
	 *  <code>elementHorizontalAlign</code> and <code>selectedHorizontalDisplacement</code>.</p>
	 * 
	 *  <p>The horizontal position of the elements is determined by the combined
	 *  reult of <code>verticalAlign</code>, <code>verticalDisplacement</code>,
	 *  <code>verticalAlignOffset</code> or <code>verticalAlignOffsetPercent</code>,
	 *  <code>elementVerticalAlign</code> and <code>selectedVerticalDisplacement</code>.</p>
	 * 
	 *  <p>The z position of unselected elements is determined by the
	 *  <code>maximumZ</code> property.</p>
	 * 
	 *  <p>The rotation of the elements is determined by the <code>rotationX</code>,
	 *  <code>rotationY</code> and <code>rotationZ</code> properties.</p>
	 * 
	 *  <p>The color of unselected elements is determined by the <code>depthColor</code>
	 *  and <code>depthColorAlpha</code> properties.</p>
	 * 
	 *  <p>If <code>depthColor</code> has a value of -1, no color transform is applied.</p>
	 *  
	 *  <p>The number elements or elements rendered is determined by the
	 *  <code>numUnselectedElements</code> property. If <code>numUnselectedElements</code>
	 *  has a value of -1 and <code>useVirtualLayout</code> has a value of true, 
	 *  only the elements that fit within the bound of the target are rendered,
	 *  If <code>numUnselectedElements</code> has a value of -1 and <code>useVirtualLayout</code>
	 *  has a value of false, all elements are rendered.</p>
	 * 
	 *  @mxml
	 *
	 *  <p>The <code>&lt;st:CoverflowLayout&gt;</code> tag inherits all of the
	 *  tag attributes of its superclass, and adds the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;st:CoverflowLayout
	 *    <strong>Properties</strong>
	 * 	  depthColor="-1"
	 *    depthColorAlpha="1"
	 *    elementHorizontalAlign="center|left|right"
	 *    elementVerticalAlign="center|left|right"
	 *    horizontalAlign="center|left|right"
	 *    horizontalDisplacement="100"
	 *    horizontalAlignOffset="0"
	 *    horizontalAlignOffsetPercent="0"
	 *    maximumZ="100"
	 *    numUnselectedElements="-1"
	 *    rotationX="0"
	 *    rotationY="45"
	 *    rotationZ="0"
	 *    selectedHorizontalDisplacement="100"
	 *    selectedVerticalDisplacement="0"
	 *    verticalAlign="bottom|middle|top"
	 *    verticalDisplacement="0"
	 *    verticalAlignOffset="0"
	 *    verticalAlignOffsetPercent="0"
	 *  /&gt;
	 *  </pre>
	 *
	 *  @includeExample examples/CoverflowLayoutExample.mxml
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public class CoverflowLayout extends PerspectiveAnimationNavigatorLayoutBase
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
		public function CoverflowLayout()
		{
			super( INDIRECT );
			_transformCalculator = new TransformValues( this );
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private var _transformCalculator				: TransformValues;
		
		/**
		 *  @private
		 */
		private var _horizontalCenterMultiplier			: Number;
		
		/**
		 *  @private
		 */
		private var _verticalCenterMultiplier			: Number;
		
		/**
		 *  @private
		 */
		private var _elementHorizontalCenterMultiplier	: Number;
		
		/**
		 *  @private
		 */
		private var _elementVerticalCenterMultiplier	: Number;
		
		/**
		 *  @private
		 *  Stores reference to the elements currently displayed.
		 */
		private var _visibleElements:Vector.<IVisualElement>;
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  maximumZ
		//----------------------------------    
		
		/**
		 *  @private
		 *  Storage property for maximumZ.
		 */
		private var _maximumZ				: Number = 100;
		
		[Inspectable(category="General", defaultValue="100")]
		/**
		 *  maximumZ
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get maximumZ() : Number
		{
			return _maximumZ;
		}
		/**
		 *  @private
		 */
		public function set maximumZ( value : Number ) : void
		{
			if( _maximumZ == value ) return;
			
			_maximumZ = value;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  rotationX
		//---------------------------------- 
		
		/**
		 *  @private
		 *  Storage property for rotationX.
		 */
		private var _rotationX:Number = 0;
		
		/**
		 *	Whether rotation should be applied to the x axis of elements.
		 * 
		 *  @default true
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get rotationX():Number
		{
			return _rotationX;
		}
		/**
		 *  @private
		 */
		public function set rotationX( value:Number ) : void
		{
			if( _rotationX == value ) return;
			
			_rotationX = value;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  rotationY
		//---------------------------------- 
		
		/**
		 *  @private
		 *  Storage property for rotationY.
		 */
		private var _rotationY:Number = 45;
		
		/**
		 *	Whether rotation should be applied to the y axis of elements.
		 * 
		 *  @default true
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get rotationY():Number
		{
			return _rotationY;
		}
		/**
		 *  @private
		 */
		public function set rotationY( value:Number ):void
		{
			if( value == _rotationY ) return;
			
			_rotationY = value;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  horizontalDisplacement
		//----------------------------------    
		
		/**
		 *  @private
		 *  Storage property for horizontalDisplacement.
		 */
		private var _horizontalDisplacement:Number = 100;
		
		[Inspectable(category="General", defaultValue="100")]
		/**
		 *  horizontalDisplacement
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get horizontalDisplacement() : Number
		{
			return _horizontalDisplacement;
		}
		/**
		 *  @private
		 */
		public function set horizontalDisplacement( value : Number ) : void
		{
			if( _horizontalDisplacement == value ) return
				
			_horizontalDisplacement = value;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  selectedHorizontalDisplacement
		//----------------------------------    
		
		/**
		 *  @private
		 *  Storage property for selectedHorizontalDisplacement.
		 */
		private var _selectedHorizontalDisplacement:Number = 100;
		
		[Inspectable(category="General", defaultValue="100")]
		/**
		 *  selectedHorizontalDisplacement
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get selectedHorizontalDisplacement() : Number
		{
			return _selectedHorizontalDisplacement;
		}
		/**
		 *  @private
		 */
		public function set selectedHorizontalDisplacement( value:Number ) : void
		{
			if( _selectedHorizontalDisplacement == value ) return
				
			_selectedHorizontalDisplacement = value;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  verticalDisplacement
		//----------------------------------    
		
		/**
		 *  @private
		 *  Storage property for verticalDisplacement.
		 */
		private var _verticalDisplacement:Number = 0;
		
		[Inspectable(category="General", defaultValue="0")]
		/**
		 *  verticalDisplacement
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get verticalDisplacement() : Number
		{
			return _verticalDisplacement;
		}
		/**
		 *  @private
		 */
		public function set verticalDisplacement( value:Number ):void
		{
			if( _verticalDisplacement == value ) return;
			
			_verticalDisplacement = value;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  selectedVerticalDisplacement
		//----------------------------------    
		
		/**
		 *  @private
		 *  Storage property for selectedVerticalDisplacement.
		 */
		private var _selectedVerticalDisplacement:Number = 0;
		
		[Inspectable(category="General", defaultValue="0")]
		/**
		 *  selectedVerticalDisplacement
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get selectedVerticalDisplacement() : Number
		{
			return _selectedVerticalDisplacement;
		}
		/**
		 *  @private
		 */
		public function set selectedVerticalDisplacement( value:Number ) : void
		{
			if( _selectedVerticalDisplacement == value ) return
				
				_selectedVerticalDisplacement = value;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  depthColor
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for depthColor.
		 */
		private var _depthColor		: int = -1;
		
		[Inspectable(category="General", defaultValue="-1")]
		/**
		 *	The color tint to apply to elements as their are moved back on the z axis.
		 * 
		 *	<p>If a valid color is added to elements are tinted as they are moved
		 *	back on the z axis taking into account the <code>depthColorAlpha</code>
		 *	specified. If a value of -1 is set for the color no tinting is applied.</p>
		 * 
		 *  @default -1
		 * 
		 * 	@see #depthColorAlpha
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get depthColor():int
		{
			return _depthColor;
		}
		/**
		 *  @private
		 */
		public function set depthColor( value:int ) : void
		{
			if( _depthColor == value ) return;
			
			_depthColor = value;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  depthColorAlpha
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for depthColorAlpha.
		 */
		private var _depthColorAlpha		: Number = 1;
		
		[Inspectable(category="General", defaultValue="1")]
		
		/**
		 *	The alpha to be used for the color tint that is applied to elements
		 *	as their are moved back on the z axis.
		 * 
		 *  @default 1
		 * 
		 * 	@see #depthColor
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get depthColorAlpha():Number
		{
			return _depthColorAlpha;
		}
		/**
		 *  @private
		 */
		public function set depthColorAlpha( value:Number ) : void
		{
			if( _depthColorAlpha == value ) return;
			
			_depthColorAlpha = value;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  numUnselectedElements
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for numUnselectedElements.
		 */
		private var _numUnselectedElements	: int = -1;
		
		[Inspectable(category="General", defaultValue="-1")]
		/**
		 *	The number of items to show either side of the selected item
		 *	are positioned around this element.
		 * 
		 *	<p>Valid values are <code>HorizontalAlign.LEFT</code>, <code>HorizontalAlign.CENTER</code>
		 *	and <code>HorizontalAlign.RIGHT</code>.</p>
		 * 
		 *  @default 2
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		
		public function get numUnselectedElements():int
		{
			return _numUnselectedElements;
		}
		/**
		 *  @private
		 */
		public function set numUnselectedElements( value:int ) : void
		{
			if( _numUnselectedElements == value ) return;
			
			_numUnselectedElements = value;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  horizontalAlign
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for horizontalAlign.
		 */
		private var _horizontalAlign:String = HorizontalAlign.CENTER;
		
		/**
		 *  @private
		 *  Flag to indicate the horizontalAlign property has changed.
		 */
		private var _horizontalAlignChange:Boolean = true;
		
		[Inspectable(category="General", enumeration="left,right,center", defaultValue="center")]
		/**
		 *	The horizontal position of the selected element in the viewport. All other elements
		 *	are positioned around this element.
		 * 
		 *	<p>Valid values are <code>HorizontalAlign.LEFT</code>, <code>HorizontalAlign.CENTER</code>
		 *	and <code>HorizontalAlign.RIGHT</code>.</p>
		 * 
		 *  @default "center"
		 * 
		 * 	@see #horizontalAlignOffset
		 * 	@see #horizontalAlignOffsetPercent
		 * 	@see spark.layouts.HorizontalAlign
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get horizontalAlign():String
		{
			return _horizontalAlign;
		}
		/**
		 *  @private
		 */
		public function set horizontalAlign(value:String):void
		{
			if( value == _horizontalAlign ) return;
			
			_horizontalAlign = value;
			_horizontalAlignChange = true;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  verticalAlign
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for verticalAlign.
		 */
		private var _verticalAlign:String = VerticalAlign.MIDDLE;
		
		/**
		 *  @private
		 *  Flag to indicate the verticalAlign property has changed.
		 */
		private var _verticalAlignChange:Boolean = true;
		
		[Inspectable(category="General", enumeration="top,bottom,middle", defaultValue="middle")]
		/**
		 *	The vertical position of the selected element in the viewport. All other elements
		 *	are positioned around this element.
		 * 
		 *	<p>Valid values are <code>VerticalAlign.TOP</code>, <code>VerticalAlign.MIDDLE</code>
		 *	and <code>VerticalAlign.BOTTOM</code>.</p>
		 * 
		 *  @default "middle"
		 * 
		 * 	@see #verticalAlignOffset
		 * 	@see #verticalAlignOffsetPercent
		 * 	@see spark.layouts.VerticalAlign
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get verticalAlign():String
		{
			return _verticalAlign;
		}
		/**
		 *  @private
		 */
		public function set verticalAlign(value:String):void
		{
			if( value == _verticalAlign ) return;
			
			_verticalAlign = value;
			_verticalAlignChange = true;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  horizontalAlignOffset
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for horizontalAlignOffset.
		 */
		private var _horizontalAlignOffset:Number = 0;
		
		[Inspectable(category="General", defaultValue="0")]
		/**
		 *	The offset in pixels to be used in conjunction with <code>horizontalAlign</code>
		 *	to set the horizontal position of the selected element in the viewport. All other elements
		 *	are positioned around this element.
		 * 
		 *	<p>If <code>horizontalAlignOffsetPercent</code> is set after this property,
		 *	this property is set automatically depending on the value of <code>horizontalAlignOffsetPercent</code>.</p>
		 * 
		 *  @default 0
		 * 
		 * 	@see #horizontalAlign
		 * 	@see #horizontalAlignOffsetPercent
		 * 	@see spark.layouts.HorizontalAlign
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get horizontalAlignOffset():Number
		{
			return _horizontalAlignOffset;
		}
		/**
		 *  @private
		 */
		public function set horizontalAlignOffset(value:Number):void
		{
			if( _horizontalAlignOffset == value ) return;
			
			_horizontalAlignOffset = value;
			_horizontalAlignOffsetPercent = NaN;
			invalidateTargetDisplayList();
		}    
		
		
		//----------------------------------
		//  verticalAlignOffset
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for verticalAlignOffset.
		 */
		private var _verticalAlignOffset:Number = 0;
		
		[Inspectable(category="General", defaultValue="0")]
		/**
		 *	The offset in pixels to be used in conjunction with <code>verticalAlign</code>
		 *	to set the vertical position of the selected element in the viewport. All other elements
		 *	are positioned around this element.
		 * 
		 *	<p>If <code>verticalAlignOffsetPercent</code> is set after this property,
		 *	this property is set automatically depending on the value of <code>verticalAlignOffsetPercent</code>.</p>
		 * 
		 *  @default 0
		 * 
		 * 	@see #verticalAlign
		 * 	@see #verticalAlignOffsetPercent
		 * 	@see spark.layouts.VerticalAlign
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get verticalAlignOffset():Number
		{
			return _verticalAlignOffset;
		}
		/**
		 *  @private
		 */
		public function set verticalAlignOffset(value:Number):void
		{
			if( _verticalAlignOffset == value ) return;
			
			_verticalAlignOffset = value;
			_verticalAlignOffsetPercent = NaN;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  horizontalAlignOffsetPercent
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for horizontalAlignOffsetPercent.
		 */
		private var _horizontalAlignOffsetPercent:Number = 0;
		
		[Inspectable(category="General", defaultValue="0")]
		/**
		 *	The offset as a percentage of the unscaled width of the viewport
		 *  to be used in conjunction with <code>horizontalAlign</code> to set the horizontal
		 *	position of the selected element in the viewport. All other elements are
		 * 	positioned around this element.
		 * 
		 *	<p>Setting this property overrides any value set on <code>horizontalAlignOffset</code>.</p>
		 * 
		 *  @default 0
		 * 
		 * 	@see #horizontalAlign
		 * 	@see #horizontalAlignOffset
		 * 	@see spark.layouts.HorizontalAlign
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get horizontalAlignOffsetPercent():Number
		{
			return _horizontalAlignOffsetPercent;
		}
		/**
		 *  @private
		 */
		public function set horizontalAlignOffsetPercent(value:Number):void
		{
			if( _horizontalAlignOffsetPercent == value ) return;
			
			_horizontalAlignOffsetPercent = value;
			if( !isNaN( _horizontalAlignOffsetPercent ) ) _horizontalAlignOffset = unscaledHeight * ( _horizontalAlignOffsetPercent / 100 );
			invalidateTargetDisplayList();
		}    
		
		
		//----------------------------------
		//  verticalAlignOffsetPercent
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for verticalAlignOffsetPercent.
		 */
		private var _verticalAlignOffsetPercent:Number = 0;
		
		[Inspectable(category="General", defaultValue="0")]
		/**
		 *	The offset as a percentage of the unscaled height of the viewport
		 *  to be used in conjunction with <code>verticalAlign</code> to set the vertical
		 *	position of the selected element in the viewport. All other elements are
		 * 	positioned around this element.
		 * 
		 *	<p>Setting this property overrides any value set on <code>verticalAlignOffset</code>.</p>
		 * 
		 *  @default 0
		 * 
		 * 	@see #verticalAlign
		 * 	@see #verticalAlignOffset
		 * 	@see spark.layouts.VerticalAlign
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get verticalAlignOffsetPercent():Number
		{
			return _verticalAlignOffsetPercent;
		}
		/**
		 *  @private
		 */
		public function set verticalAlignOffsetPercent(value:Number):void
		{
			if( _verticalAlignOffsetPercent == value ) return;
			
			_verticalAlignOffsetPercent = value;
			if( !isNaN( _verticalAlignOffsetPercent ) ) _verticalAlignOffset = unscaledHeight * ( _verticalAlignOffsetPercent / 100 );
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  elementHorizontalAlign
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for elementHorizontalAlign.
		 */
		private var _elementHorizontalAlign:String = HorizontalAlign.CENTER;
		
		/**
		 *  @private
		 *  Flag to indicate the elementHorizontalAlign property has changed.
		 */
		private var _elementHorizontalAlignChange		: Boolean = true;
		
		[Inspectable(category="General", enumeration="left,right,center", defaultValue="center")]
		/**
		 *	The horizontal transform point of elements.
		 * 
		 *	<p>Valid values are <code>HorizontalAlign.LEFT</code>, <code>HorizontalAlign.CENTER</code>
		 *	and <code>HorizontalAlign.RIGHT</code>.</p>
		 * 
		 *  @default "center"
		 * 
		 * 	@see spark.layouts.HorizontalAlign
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get elementHorizontalAlign():String
		{
			return _elementHorizontalAlign;
		}
		/**
		 *  @private
		 */
		public function set elementHorizontalAlign(value:String):void
		{
			if( value == _elementHorizontalAlign ) return;
			
			_elementHorizontalAlign = value;
			_elementHorizontalAlignChange = true;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  elementVerticalAlign
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for elementVerticalAlign.
		 */
		private var _elementVerticalAlign:String = VerticalAlign.MIDDLE;
		
		/**
		 *  @private
		 *  Flag to indicate the elementVerticalAlign property has changed.
		 */
		private var _elementVerticalAlignChange			: Boolean = true;
		
		[Inspectable(category="General", enumeration="top,bottom,middle", defaultValue="middle")]
		/**
		 *	The vertical transform point of elements.
		 * 
		 *	<p>Valid values are <code>VerticalAlign.TOP</code>, <code>VerticalAlign.MIDDLE</code>
		 *	and <code>VerticalAlign.BOTTOM</code>.</p>
		 * 
		 *  @default "middle"
		 * 
		 * 	@see spark.layouts.VerticalAlign
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get elementVerticalAlign():String
		{
			return _elementVerticalAlign;
		}
		/**
		 *  @private
		 */
		public function set elementVerticalAlign(value:String):void
		{
			if( value == _elementVerticalAlign ) return;
			
			_elementVerticalAlign = value;
			_elementVerticalAlignChange = true;
			invalidateTargetDisplayList();
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *	@private
		 * 
		 *	Positions, transforms and sets the size of an element
		 *  that will be visible in the layout.
		 */
		protected function updateVisibleElementAt( element:IVisualElement, index:int ):void
		{
			setElementLayoutBoundsSize( element, false );
			
			_transformCalculator.updateForIndex( index, element, element.width, element.height, _elementHorizontalCenterMultiplier, _elementVerticalCenterMultiplier );
			
			applyColorTransformToElement( element, _transformCalculator.colorTransform );
		}
		
		
		/**
		 *	@private
		 * 
		 *	Sets the depth of elements inlcuded in the layout at depths
		 *	to display correctly for the z position set with transformAround.
		 * 
		 *	Also sets the depth of elements that are not included in the layout.
		 *	The depth of these is dependent on whether their element index is before
		 *	or after the index of the selected element.
		 * 
		 *	- If their element index is before the selected elements index
		 *   they appear beneath all items included in the layout.
		 * 
		 *	- If their element index is after the selected elements index
		 *   they appear above all items included in the layout
		 */
		private function updateDepths( depths:Vector.<int> ):void
		{
			if( !depths || !depths.length ) return;
			
			var animationIndex:int = Math.max( 0, Math.min( Math.round( animationValue ), numElementsInLayout - 1 ) );
			
			var element:IVisualElement;
			var index:int;
			var i:int
			var numBeforeMinDepth:int = 0;
			var minDepth:int = depths[ 0 ] - 1;
			var maxDepth:int = depths[ depths.length - 1 ] + 1;
			
			const elements:Vector.<IVisualElement> = new Vector.<IVisualElement>();
			for( i = firstIndexInView; i <= lastIndexInView; i++ )
			{
				index = indicesInLayout[ i ];
				element = target.getElementAt( index );
				element.depth = ( i > animationIndex ) ? -i : i;
				if( !element ) continue;
				elements.push( element );
			}
			
			target.invalidateLayering();
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number):void
		{
			if( _horizontalAlignChange )
			{
				_horizontalAlignChange = false;
				
				switch( _horizontalAlign )
				{
					case HorizontalAlign.LEFT :
					{
						_horizontalCenterMultiplier = 0;
						break;
					}
					case HorizontalAlign.RIGHT :
					{
						_horizontalCenterMultiplier = 1;
						break;
					}
					default :
					{
						_horizontalCenterMultiplier = 0.5;
					}
				}
			}
			
			if( _verticalAlignChange )
			{
				_verticalAlignChange = false;
				
				switch( _verticalAlign )
				{
					case VerticalAlign.TOP :
					{
						_verticalCenterMultiplier = 0;
						break;
					}
					case VerticalAlign.BOTTOM :
					{
						_verticalCenterMultiplier = 1;
						break;
					}
					default :
					{
						_verticalCenterMultiplier = 0.5;
					}
				}
			}
			
			if( _elementHorizontalAlignChange )
			{
				_elementHorizontalAlignChange = false;
				
				switch( _elementHorizontalAlign )
				{
					case HorizontalAlign.LEFT :
					{
						_elementHorizontalCenterMultiplier = 0;
						break;
					}
					case HorizontalAlign.RIGHT :
					{
						_elementHorizontalCenterMultiplier = 1;
						break;
					}
					default :
					{
						_elementHorizontalCenterMultiplier = 0.5;
					}
				}
			}
			
			if( _elementVerticalAlignChange )
			{
				_elementVerticalAlignChange = false;
				
				switch( _elementVerticalAlign )
				{
					case VerticalAlign.TOP :
					{
						_elementVerticalCenterMultiplier = 0;
						break;
					}
					case VerticalAlign.BOTTOM :
					{
						_elementVerticalCenterMultiplier = 1;
						break;
					}
					default :
					{
						_elementVerticalCenterMultiplier = 0.5;
					}
				}
			}
			
			super.updateDisplayList( unscaledWidth, unscaledHeight );
		}
		
		/**
		 *  @private
		 */
		override protected function updateDisplayListBetween():void
		{
			super.updateDisplayListBetween();
			
			if( sizeChangedInLayoutPass )
			{
				if( !isNaN( _horizontalAlignOffsetPercent ) ) _horizontalAlignOffset = unscaledHeight * ( _horizontalAlignOffsetPercent / 100 );
				if( !isNaN( _verticalAlignOffsetPercent ) ) _verticalAlignOffset = unscaledHeight * ( _verticalAlignOffsetPercent / 100 );
			}
				
			_transformCalculator.updateForLayoutPass( _horizontalCenterMultiplier, _verticalCenterMultiplier, _rotationX, _rotationY );
		}
		
		/**
		 *  @private
		 */
		override protected function updateDisplayListVirtual():void
		{
			super.updateDisplayListVirtual();
			
			// Store a references to the visible elements in case numUnselectedElements is used.
			const newVisibleElements:Vector.<IVisualElement> = new Vector.<IVisualElement>();
			
			var element:IVisualElement;
			var depths:Vector.<int> = new Vector.<int>();
			var index:int;

			for( var i:int = firstIndexInView; i <= lastIndexInView; i++ )
			{
				element = target.getVirtualElementAt( indicesInLayout[ i ] );
				if( _visibleElements )
				{
					index = _visibleElements.indexOf( element );
					if( index != -1 ) _visibleElements.splice( index, 1 );
				}
				newVisibleElements.push( element );
				depths.push( indicesInLayout[ i ] );
				element.visible = true;
				updateVisibleElementAt( element, i );
			}
			
			// Hide all previously visible elements that should show in the layout.
			for each( element in _visibleElements )
			{
				element.visible = false;
			}
			
			_visibleElements = newVisibleElements.concat();
			updateDepths( depths );
		}
		
		/**
		 *  @private
		 */
		override protected function updateDisplayListReal():void
		{
			super.updateDisplayListReal();

			var element:IVisualElement;
			var depths:Vector.<int> = new Vector.<int>();
			var index:int;
			
			_visibleElements = new Vector.<IVisualElement>();

			for( var i:int = 0; i < numElementsInLayout; i++ )
			{
				element = target.getElementAt( indicesInLayout[ i ] );
				
				if( i >= firstIndexInView && i <= lastIndexInView )
				{
					depths.push( indicesInLayout[ i ] );
					updateVisibleElementAt( element, i );
					element.visible = true;
					_visibleElements.push( element );
				}
				else
				{
					element.visible = false;
				}
			}
			
			updateDepths( depths );
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
			
			var vector:Vector3D = new Vector3D( 0, 0, 0 );
			element.visible = true;
			element.depth = 0;
			element.transformAround( vector, null, null, vector, null, vector, vector, false );
			applyColorTransformToElement( element, new ColorTransform() );
		}
		
		
		/**
		 *  @private
		 */
		private function angle( x1:Number, y1:Number, x2:Number, y2:Number ):Number
		{
			return ( Math.atan2( y2 - y1, x2 - x1 ) * ( 180 / Math.PI ) ) % 360;
		}
		
		/**
		 *  @private
		 */
		private function tanD( a:Number ):Number
		{
			return Math.tan( a * ( Math.PI / 180 ) );
		}
		
		/**
		 *  @private
		 */
		override protected function updateIndicesInView():void
		{
			super.updateIndicesInView();
			
			var start:int;
			var end:int;
			
			if( selectedElement )
			{
				const animationIndex:int = Math.round( animationValue );
				
				if( numUnselectedElements < 1 )
				{
					if( !useVirtualLayout )
					{
						start = 0;
						end = indicesInLayout.length;
					}
					else
					{
						// The projection rectangle in 3D.
						// TODO this should take into account the rotation
						// of each item to be accurrate.
						const plane:Rectangle = getProjectionRectAtZ( maximumZ );
						
						var center:Number;
						var startPoint:Number;
						var elementSize:Number;
						
						var numItemsRight:int = 0;
						var numItemsLeft:int = 0;
						var numItemsBottom:int = 0;
						var numItemsTop:int = 0;
						
						// horizontal
						if( horizontalDisplacement )
						{
							center = ( unscaledWidth * _horizontalCenterMultiplier ) + _horizontalAlignOffset;
							elementSize = getElementLayoutBoundsWidth( selectedElement );
							
							// right
							// add the offset for the selected item
							startPoint = center + selectedHorizontalDisplacement;
							// minus off the width of the nearest non-seleced element
							startPoint -= elementSize * _elementHorizontalCenterMultiplier;
							numItemsRight = Math.ceil( ( plane.right - startPoint ) / horizontalDisplacement );
							
							// left
							// add the offset for the selected item
							startPoint = center - selectedHorizontalDisplacement;
							// minus off the width of the nearest non-seleced element
							startPoint += elementSize * Math.abs( _elementHorizontalCenterMultiplier - 1 );
							numItemsLeft = Math.ceil( ( startPoint - plane.left ) / horizontalDisplacement );
						}
						
						// vertical
						if( verticalDisplacement )
						{
							center = ( unscaledHeight * _verticalCenterMultiplier ) + _verticalAlignOffset;
							elementSize = getElementLayoutBoundsHeight( selectedElement );
							
							// bottom
							// add the offset for the selected item
							startPoint = center + selectedVerticalDisplacement;
							// minus off the width of the nearest non-seleced element
							startPoint -= elementSize * _elementVerticalCenterMultiplier;
							numItemsBottom = Math.ceil( ( plane.bottom - startPoint ) / verticalDisplacement );
							
							// top
							// add the offset for the selected item
							startPoint = center - selectedVerticalDisplacement;
							// minus off the width of the nearest non-seleced element
							startPoint += elementSize * Math.abs( _elementVerticalCenterMultiplier - 1 );
							numItemsTop = Math.ceil( ( startPoint - plane.top ) / verticalDisplacement );
						}
						
						start = Math.max( animationIndex - ( numItemsTop != 0 && numItemsTop < numItemsLeft ? numItemsTop : numItemsLeft ), 0 );
						end = Math.min( animationIndex + ( numItemsBottom != 0 && numItemsBottom < numItemsRight ? numItemsBottom : numItemsRight ) + 1, target.numElements );
					}
				}
				else
				{
					start = Math.max( animationIndex - numUnselectedElements, 0 );
					end = Math.min( animationIndex + numUnselectedElements + 1, indicesInLayout.length )
				}
			}
			else
			{
				start = -1;
				end = -1;
			}
			
			indicesInView( start, end - start );
		}
		
		
	}
}


import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Vector3D;

import mx.core.IVisualElement;

import spark.layouts.CoverflowLayout;


internal class TransformValues
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
	public function TransformValues( layout:CoverflowLayout )
	{
		_layout = layout;
		_colorTransform = new ColorTransform();
	}
	
	
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	private var _layout			: CoverflowLayout;
	
	private var _index			: int;
	private var _indexOffset	: Number;
	
	// Center
	private var _cx				: Number;
	private var _cy				: Number;
	
	// AlignOffset
	private var _ho				: Number;
	private var _vo				: Number;
	
	// Number of items
	private var _ni				: Number;
	
	private var _c				: int;
	private var _ca				: Number;
	
	private var _rotY				: int;
	private var _rotX				: int;
	
	private var _oy:Number;
	private var _ox:Number;
	
	
	/**
	 *  @private
	 *  Storage property for x.
	 */
	private var _x:Number;
	
	/**
	 *  @private
	 *  Storage property for y.
	 */
	private var _y:Number;
	
	/**
	 *  @private
	 *  Storage property for z.
	 */
	private var _z:Number;
	
	/**
	 *  @private
	 *  Storage property for xRotation.
	 */
	private var _xRotation:Number;
	
	/**
	 *  @private
	 *  Storage property for yRotation.
	 */
	private var _yRotation:Number;
	
	
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  colorTransform
	//----------------------------------  
	
	/**
	 *  @private
	 *  Storage property for colorTransform.
	 */
	private var _colorTransform:ColorTransform;
	
	/**
	 *	colorTransform
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get colorTransform():ColorTransform
	{
		return _colorTransform;
	}
	
	
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *	updateForLayoutPass
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function updateForLayoutPass( centerMultiplierX:Number, centerMultiplierY:Number, rotX:int, rotY:int ):void
	{
		_index = Math.floor( _layout.animationValue );
		_indexOffset = _layout.animationValue - _index;
		
		
		_cx = _layout.unscaledWidth * centerMultiplierX;
		_cy = _layout.unscaledHeight * centerMultiplierY;
		
		_ho = _layout.horizontalAlignOffset;
		_vo = _layout.verticalAlignOffset;
		
		_c = _layout.depthColor;
		_ca = _layout.depthColorAlpha / 100;
		
		if( _c < 0 )
		{
			_colorTransform.redMultiplier = _colorTransform.greenMultiplier = _colorTransform.blueMultiplier = 1;
			_colorTransform.redOffset = _colorTransform.greenOffset = _colorTransform.blueOffset = _colorTransform.alphaOffset = 0;
		}
		
		_rotY = rotY;
		_rotX = -rotX;
	}
	
	/**
	 *	circular
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	private function calculatePos( index:Number ):void
	{
		var o:Number = Math.max( -1, Math.min( 1, index ) );
		
		var displacement:Number;
		
		_yRotation = _rotY * o;
		_xRotation = _rotX * o;
		
		if(  Math.abs( index ) > 1 )
		{
			var dir:Number = index < 0 ? index + 1 : index - 1;
			_x = _cx + _ho + ( _layout.selectedHorizontalDisplacement * o ) + ( _layout.horizontalDisplacement * dir );
			_y = _cy + _vo + ( _layout.selectedVerticalDisplacement * o ) + ( _layout.verticalDisplacement * dir );
		}
		else
		{
			_x = _cx + _ho + ( _layout.selectedHorizontalDisplacement * index );
			_y = _cy + _vo + ( _layout.selectedVerticalDisplacement * index );
		}
		
		_z = _layout.maximumZ * Math.abs( o );
	}
	
	/**
	 *	updateForIndex
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function updateForIndex( i:int, element:IVisualElement, width:Number, height:Number, hMultiplier:Number, vMultiplier:Number ):void
	{
		_ox = ( width / 2 ) * ( hMultiplier - 0.5 ) * 2;
		_oy = ( height / 2 ) * ( vMultiplier - 0.5 ) * 2;
		
		calculatePos( ( i - _index ) - _indexOffset );
		
		if( _c > -1 )
		{
			const v:Number = ( _z / _layout.maximumZ ) * _ca;
			
			_colorTransform.color = _c;
			_colorTransform.redOffset *= v;
			_colorTransform.greenOffset *= v;
			_colorTransform.blueOffset *= v;
			_colorTransform.redMultiplier = _colorTransform.greenMultiplier = _colorTransform.blueMultiplier = 1 - v;
		}
		
		element.transformAround( new Vector3D( width / 2, height / 2, 0 ),
			null,
			null,
			new Vector3D( _x - _ox, _y - _oy, _z ),
			null,
			new Vector3D( _xRotation, _yRotation, 0 ),
			new Vector3D( _x - _ox, _y - _oy, _z ),
			false );
	}
}