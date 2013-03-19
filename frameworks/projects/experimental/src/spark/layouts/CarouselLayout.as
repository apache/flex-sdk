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
	import flash.geom.Vector3D;
	
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	
	import spark.layouts.HorizontalAlign;
	import spark.layouts.VerticalAlign;
	import spark.primitives.supportClasses.GraphicElement;
	
	import spark.layouts.supportClasses.PerspectiveAnimationNavigatorLayoutBase;

	/**
	 *  A CarouselLayout class arranges the layout elements in a
	 *  sequence along an arc, with one of them at a time selected.
	 * 
	 *  <p>The position of the elements is determined by the radii
	 *  <code>radiusX</code>, <code>radiusY</code> and <code>radiusZ</code>.
	 *  These can be properties can be set the negative values to produce
	 *  a ring of elements surrounding the view point.</p>
	 * 
	 *  <p>The rotation of the elements is determined by the
	 *  <code>rotationX</code> and <code>rotationY</code> properties.</p>
	 *  <ul>
	 *    <li>If a value of <code>"none"</code> is used for a rotation property, 
	 *    no rotation is applied to the element around the corresponding axis.</li>
	 *
	 *    <li>If a value of <code>"standard"</code> is used for a rotation property, 
	 *    the element will be rotated so that it faces outwards around the arc.</li>
	 *
	 *    <li>If a value of <code>"reversed"</code> is used for a rotation property, 
	 *    the element will be rotated so that it faces inwards around the arc.</li>
	 *  </ul>
	 * 
	 *  @mxml
	 *
	 *  <p>The <code>&lt;st:CarouselLayout&gt;</code> tag inherits all of the
	 *  tag attributes of its superclass, and adds the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;st:AccordionLayout
	 *    <strong>Properties</strong>
	 *    angle="360"
	 *    depthColor="-1"
	 *    depthColorAlpha="1"
	 *    horizontalAlign="center|left|right"
	 *    horizontalAlignOffset="0"
	 *    horizontalAlignOffsetPercent="0"
	 *    numUnselectedElements="-1"
	 *    radiusX="100"
	 *    radiusY="0"
	 *    radiusZ="NaN"
	 *    rotateX="none|reversed|standard"
	 *    rotateY="none|reversed|standard"
	 *    verticalAlign="bottom|middle|top"
	 *    verticalAlignOffset="0"
	 *    verticalAlignOffsetPercent="0"
	 *  /&gt;
	 *  </pre>
	 *
	 *  @includeExample examples/CarouselLayoutExample.mxml
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public class CarouselLayout extends PerspectiveAnimationNavigatorLayoutBase
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
		public function CarouselLayout()
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
		 */
		private var _displayedElements					: Vector.<IVisualElement>	
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  angle
		//---------------------------------- 
		
		/**
		 *  @private
		 *  Storage property for angle.
		 */
		private var _angle:Number = 360;
		
		/**
		 *	The segment of a circle to rotate the elements around.
		 * 
		 *  @default 360
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get angle():Number
		{
			return _angle;
		}
		/**
		 *  @private
		 */
		public function set angle( value:Number ) : void
		{
			if( _angle == value ) return;
			
			_angle = value;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  rotateX
		//---------------------------------- 
		
		/**
		 *  @private
		 *  Storage property for rotateX.
		 */
		private var _rotateX:int = 0;
		
		[Inspectable(category="General", enumeration="none,reversed,standard", defaultValue="none")]
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
		public function get rotateX():String
		{
			return _rotateX ? _rotateX < 0 ? "reversed" : "standard" : "none";
		}
		/**
		 *  @private
		 */
		public function set rotateX( value:String ) : void
		{
			var r:int;
			
			switch( value )
			{
				case "reversed" :
				{
					r = -1;
					break;
				}
				case "standard" :
				{
					r = 1;
					break;
				}
				default :
				{
					r = 0;
				}
					
			}
			
			if( _rotateX == r ) return;

			_rotateX = r;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  rotateY
		//---------------------------------- 
		
		/**
		 *  @private
		 *  Storage property for rotateY.
		 */
		private var _rotateY:int = 1;
		
		[Inspectable(category="General", enumeration="none,reversed,standard", defaultValue="standard")]
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
		public function get rotateY():String
		{
			return _rotateY ? _rotateY < 0 ? "reversed" : "standard" : "none";
		}
		/**
		 *  @private
		 */
		public function set rotateY( value:String ) : void
		{
			var r:int;
			
			switch( value )
			{
				case "reversed" :
				{
					r = -1;
					break;
				}
				case "standard" :
				{
					r = 1;
					break;
				}
				default :
				{
					r = 0;
				}
					
			}
			
			if( r == _rotateY ) return;
			
			_rotateY = r;
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
//			_indicesInViewChanged = true;
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
//			_indicesInViewChanged = true;
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
//			_indicesInViewChanged = true;
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
		
		
		//----------------------------------
		//  radiusX
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for radiusX.
		 */
		private var _radiusX	: Number = 100;
		
		[Inspectable(category="General", type="Number", defaultValue="100")]
		/**
		 *	The radius to be used on the x axis for the SemiCarouselLayout.
		 * 
		 *  @default 100
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get radiusX():Number
		{
			return _radiusX;
		}
		/**
		 *  @private
		 */
		public function set radiusX( value:Number ):void
		{
			if( value == _radiusX ) return;
			
			_radiusX = value;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  radiusY
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for radiusY.
		 */
		private var _radiusY	: Number = 0;
		
		[Inspectable(category="General", type="Number", defaultValue="0")]
		/**
		 *	The radius to be used on the y axis for the SemiCarouselLayout.
		 * 
		 *  @default 0
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get radiusY():Number
		{
			return _radiusY;
		}
		/**
		 *  @private
		 */
		public function set radiusY( value:Number ):void
		{
			if( value == _radiusY ) return;
			
			_radiusY = value;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  radiusZ
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for radiusZ.
		 */
		private var _radiusZ	: Number;
		
		[Inspectable(category="General", type="Number", defaultValue="NaN")]
		/**
		 *	The radius to be used on the z axis for the SemiCarouselLayout.
		 * 
		 * 	<p>If a value of NaN is passed the largest of <code>radiusX</code>
		 *	or <code>radiusY</code> is used.</p>
		 * 
		 *  @default NaN
		 * 
		 * 	@see #radiusX
		 *	@see #radiusY
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get radiusZ():Number
		{
			return _radiusZ;
		}
		/**
		 *  @private
		 */
		public function set radiusZ( value:Number ):void
		{
			if( value == _radiusZ ) return;
			
			_radiusZ = value;
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
			_displayedElements.push( element );
			
			setElementLayoutBoundsSize( element, false );
			
			_transformCalculator.updateForIndex( index, element, element.width, element.height, _elementHorizontalCenterMultiplier, _elementVerticalCenterMultiplier );
			
//			elementTransformAround( element );
			applyColorTransformToElement( element, _transformCalculator.colorTransform );
			element.visible = true;
		}
		
		/**
		 *	@private
		 */
		private function sortElementsByZ( a:IVisualElement, b:IVisualElement ):int
		{
			if( getZ( a ) > getZ( b ) )
			{
				return -1;
			}
			else if( getZ( a ) < getZ( b ) )
			{
				return 1;
			}
			
			return 0;
		}
		
		/**
		 *	@private
		 * 
		 *	Util function to return the value of the z property
		 *  on an element.
		 */
		private function getZ( e:IVisualElement ):Number
		{
			if( e is GraphicElement )
			{
				return GraphicElement( e ).z;
			}
			else
			{
				return UIComponent( e ).z;
			}
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
				if( !element ) continue;
				elements.push( element );
			}
			
			elements.sort( sortElementsByZ );
			var num:int = elements.length;
			for( i = 0; i < num; i++ )
			{
				elements[ i ].depth = depths[ i ];
			}
			
//			target.validateNow();
//			for( i = firstIndexInView; i <= lastIndexInView; i++ )
//			{
//				index = indicesInLayout[ i ];
//				element = target.getElementAt( index );
//				if( !element ) continue;
//				if( index <  indicesInLayout[ animationIndex ] )
//				{
//					element.depth = _transformCalculator.radiusZ > -1 ? depths.shift() : depths.pop();
//				}
////				else if ( index > indicesInLayout[ animationIndex ] )
////				{
////					element.depth = _direction == SemiCarouselLayoutDirection.CONVEX ? depths.pop() : depths.shift();
////				}
//				else
//				{
//					element.depth = _transformCalculator.radiusZ > -1 ? depths.pop() : depths.shift();
//				}
//			}
//			
//			
//			var numElementsNotInLayout:int = indicesNotInLayout.length;
//			for( i = 0; i < numElementsNotInLayout; i++ )
//			{
//				if( indicesNotInLayout[ i ] > indicesInLayout[ animationIndex ] )
//				{
//					break;
//				}
//				else
//				{
//					numBeforeMinDepth++;
//				}
//			}
//			
//			minDepth -= numBeforeMinDepth - 1;
//			for( i = 0; i < numElementsNotInLayout; i++ )
//			{
//				element = target.getElementAt( indicesNotInLayout[ i ] );
//				if( !element ) continue;
//				if( indicesNotInLayout[ i ] > indicesInLayout[ animationIndex ] )
//				{
//					element.depth = maxDepth;
//					maxDepth++;
//				}
//				else
//				{
//					element.depth = minDepth;
//					minDepth++;
//				}
//			}
//			
//			target.validateNow();
		}
		
		/**
		 *	@private
		 * 
		 *	A convenience method used to transform an element by applying
		 *  the current values if the TransforCalulator instance.
		 */
//		private function elementTransformAround( element:IVisualElement ):void
//		{
//			var halfWidth:Number = element.width / 2;
//			var halfHeight:Number = element.height / 2;
//			var offsetX:Number = halfWidth * ( _elementHorizontalCenterMultiplier - 0.5 ) * 2;
//			var offsetY:Number = halfHeight * ( _elementVerticalCenterMultiplier - 0.5 ) * 2;
//			
//			element.transformAround( new Vector3D( element.width / 2, element.height / 2, 0 ),
//				null,
//				null,
//				new Vector3D( _transformCalculator.x - offsetX, _transformCalculator.y - offsetY, _transformCalculator.z ),
//				null,
//				new Vector3D( _transformCalculator.xRotation, _transformCalculator.yRotation, 0 ),
//				new Vector3D( _transformCalculator.x - offsetX, _transformCalculator.y - offsetY, _transformCalculator.z ),
//				false );
//			
//		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Methods
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
		override public function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number):void
		{
//			if( this.unscaledWidth != unscaledWidth || this.unscaledHeight != unscaledHeight ) _sizeChanged = true;
			
			if( _horizontalAlignChange )
			{
				_horizontalAlignChange = false;
//				_indicesInViewChanged = true;
				
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
//				_indicesInViewChanged = true;
				
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
//				_indicesInViewChanged = true;
				
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
//				_indicesInViewChanged = true;
				
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
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override protected function updateDisplayListBetween():void
		{
			super.updateDisplayListBetween();
			
			if( sizeChangedInLayoutPass )
			{
//				_indicesInViewChanged = true;
				if( !isNaN( _horizontalAlignOffsetPercent ) ) _horizontalAlignOffset = unscaledHeight * ( _horizontalAlignOffsetPercent / 100 );
				if( !isNaN( _verticalAlignOffsetPercent ) ) _verticalAlignOffset = unscaledHeight * ( _verticalAlignOffsetPercent / 100 );
			}
			
			_transformCalculator.updateForLayoutPass( _horizontalCenterMultiplier, _verticalCenterMultiplier, _rotateX, _rotateY );
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override protected function updateDisplayListVirtual():void
		{
			super.updateDisplayListVirtual();
			
			var element:IVisualElement;
			var depths:Vector.<int> = new Vector.<int>();
			
			for each( element in _displayedElements )
			{
				element.visible = false;
			}
			
			_displayedElements = new Vector.<IVisualElement>();
			
			for( var i:int = firstIndexInView; i <= lastIndexInView; i++ )
			{
				element = target.getVirtualElementAt( indicesInLayout[ i ] );
				depths.push( indicesInLayout[ i ] );
				updateVisibleElementAt( element, i );
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
		override protected function updateDisplayListReal():void
		{
			super.updateDisplayListReal();

			var element:IVisualElement;
			var depths:Vector.<int> = new Vector.<int>();
			
			_displayedElements = new Vector.<IVisualElement>();
			
			for( var i:int = 0; i < numElementsInLayout; i++ )
			{
				element = target.getElementAt( indicesInLayout[ i ] );
				if( i >= firstIndexInView && i <= lastIndexInView )
				{
					depths.push( indicesInLayout[ i ] );
					updateVisibleElementAt( element, i);
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
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override protected function updateIndicesInView():void
		{
			super.updateIndicesInView();
			
			if( _numUnselectedElements > 0 )
			{
				const ceilIndex:int = Math.ceil( animationValue );
				const floorIndex:int = Math.floor( animationValue );
				const firstIndexInView:int = Math.max( ceilIndex - _numUnselectedElements, 0 );
				
				var numIndicesInView:int = ( _numUnselectedElements * 2 ) + 1; 
				// If the number of elements on the left are less than _numUnselectedElements
				if( floorIndex < _numUnselectedElements )
				{
					numIndicesInView -= _numUnselectedElements - floorIndex;
				}
				// If we are mid transition, we don't need the last item
				else if( floorIndex != animationValue )
				{
					numIndicesInView -= 1;
				}
				
				// If we are at the end of the list of elements
				if( floorIndex + _numUnselectedElements >= numElementsInLayout )
				{
					numIndicesInView -= _numUnselectedElements - ( ( numElementsInLayout - 1 ) - floorIndex );
				}
				
				indicesInView( firstIndexInView, numIndicesInView );
			}
			else
			{
				indicesInView( 0, numElementsInLayout );
			}
		}
		
		
	}
}



import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Vector3D;

import mx.core.IVisualElement;

import spark.layouts.CarouselLayout;


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
	public function TransformValues( layout:CarouselLayout )
	{
		_layout = layout;
		_colorTransform = new ColorTransform();
	}
	
	
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	private var _layout			: CarouselLayout;
	
	private var _index			: int;
	private var _indexOffset	: Number;
	
	// Center
	private var _cx				: Number;
	private var _cy				: Number;
	
	// AlignOffset
	private var _ho				: Number;
	private var _vo				: Number;
	
	private var _rx				: Number;
	private var _ry				: Number;
	private var _rz				: Number;
	
	// Number of items
	private var _ni				: Number;
	private var _an				: Number;
	
	private var _c				: int;
	private var _ca				: Number;
	
	private var _rotY				: int;
	private var _rotX				: int;
	
	private var _oy:Number;
	private var _ox:Number;
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  x
	//----------------------------------  
	
	/**
	 *  @private
	 *  Storage property for x.
	 */
	private var _x:Number;
	
//	/**
//	 *	x
//	 * 
//	 *  @langversion 3.0
//	 *  @playerversion Flash 10
//	 *  @playerversion AIR 1.5
//	 *  @productversion Flex 4
//	 */
//	public function get x():Number
//	{
//		return _x;
//	}
	
	
	//----------------------------------
	//  y
	//----------------------------------  
	
	/**
	 *  @private
	 *  Storage property for y.
	 */
	private var _y:Number;
	
//	/**
//	 *	y
//	 * 
//	 *  @langversion 3.0
//	 *  @playerversion Flash 10
//	 *  @playerversion AIR 1.5
//	 *  @productversion Flex 4
//	 */
//	public function get y():Number
//	{
//		return _y;
//	}
	
	
	//----------------------------------
	//  z
	//----------------------------------  
	
	/**
	 *  @private
	 *  Storage property for z.
	 */
	private var _z:Number;
	
//	/**
//	 *	z
//	 * 
//	 *  @langversion 3.0
//	 *  @playerversion Flash 10
//	 *  @playerversion AIR 1.5
//	 *  @productversion Flex 4
//	 */
//	public function get z():Number
//	{
//		return _z;
//	}
	
	
	//----------------------------------
	//  xRotation
	//----------------------------------  
	
	/**
	 *  @private
	 *  Storage property for xRotation.
	 */
	private var _xRotation:Number;
	
//	/**
//	 *	xRotation
//	 * 
//	 *  @langversion 3.0
//	 *  @playerversion Flash 10
//	 *  @playerversion AIR 1.5
//	 *  @productversion Flex 4
//	 */
//	public function get xRotation():Number
//	{
//		return _xRotation;
//	}
	
	
	//----------------------------------
	//  yRotation
	//----------------------------------  
	
	/**
	 *  @private
	 *  Storage property for yRotation.
	 */
	private var _yRotation:Number;
	
	/**
	 *	yRotation
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
//	public function get yRotation():Number
//	{
//		return _yRotation;
//	}
//	
//	
	public function get radiusZ():Number
	{
		return _rz;
	}
	
	
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
		
		_rx = _layout.radiusX;
		_ry = _layout.radiusY;
		_rz = _layout.radiusZ;
		
		if( isNaN( _rz ) ) _rz = Math.abs( ( Math.abs( _rx ) > Math.abs( _ry ) ) ? _rx : _ry );
		
		_rotY = rotY;
		_rotX = rotX;
		
		const numElements:int = _layout.numUnselectedElements < 0 ? 0 : _layout.numUnselectedElements;

		_an = numElements ? _layout.angle / ( numElements * 2 ) : _layout.angle / _layout.numElementsInLayout;
	}
	
	/**
	 *	circular
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	private function layout( index:Number ):void
	{
		const degree:Number = _an * index;
		const radian:Number = degree * Math.PI / 180;
		
		_x = _cx + _ho + ( Math.sin( radian ) * _rx );
		_y = _cy + _vo + ( Math.sin( radian ) * _ry );
		_z = _rz - ( Math.cos( radian ) * _rz );
		
		_yRotation = _rx && _rotY != 0 ? -( angle( _x, _z, _cx + _ho, _rz ) - 90 ) * _rotY : 0;
		_xRotation = _ry && _rotX != 0 ? ( angle( _y , _z, _cy + _vo, _rz ) - 90 ) * _rotX : 0;
		
		if( _rz < 0 )
		{
			if( _yRotation ) _yRotation += 180;
			if( _xRotation ) _xRotation += 180;
		}
	}
	
	public function angle( x1:Number, y1:Number, x2:Number, y2:Number ):Number
	{
		return Math.atan2( y2 - y1, x2 - x1 ) * ( 180 / Math.PI );
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
		
		layout( ( i - _index ) - _indexOffset );
		
		if( _c > -1 )
		{
			const radian:Number = ( _layout.angle / 2 ) * Math.PI / 180;
			const maxDepth:Number = _rz - ( Math.cos( radian ) * _rz )
			const v:Number = ( _z / maxDepth ) * _ca;
			
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