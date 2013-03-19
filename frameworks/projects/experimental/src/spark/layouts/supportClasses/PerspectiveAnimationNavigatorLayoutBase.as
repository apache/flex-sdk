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
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.VerticalAlign;
	import spark.primitives.Rect;

	public class PerspectiveAnimationNavigatorLayoutBase extends AnimationNavigatorLayoutBase
	{
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor. 
		 * 
		 *  @param animationType The type of animation.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */ 
		public function PerspectiveAnimationNavigatorLayoutBase( animationType:String )
		{
			super( animationType );
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private var _projectionChanged	: Boolean;
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  projectionCenterX
		//----------------------------------  
		
		/**
		 *  @private
		 *	Storage property for projectionCenterX.
		 */
		private var _projectionCenterX:Number = NaN;
		
		/**
		 *  @private
		 *	Flag to indicate that the projectCenterX property as been set to number
		 *  value other than NaN.
		 */
		private var _projectionCenterXSet:Boolean;
		
		[Inspectable(category="General", defaultValue="NaN")]
		/**
		 *  projectionCenterX
		 * 
		 *  @default 0
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get projectionCenterX():Number
		{
			return _projectionCenterX;
		}
		/**
		 *  @private
		 */
		public function set projectionCenterX(value:Number):void
		{
			if( _projectionCenterX == value ) return;
			
			_projectionCenterX = value;
			_projectionChanged = true;
			_projectionCenterXSet = true;
			invalidateTargetDisplayList();
		}    
		
		
		//----------------------------------
		//  projectionCenterY
		//----------------------------------  
		
		/**
		 *  @private
		 *	Storage property for projectionCenterY.
		 */
		private var _projectionCenterY:Number = NaN;
		
		/**
		 *  @private
		 *	Flag to indicate that the projectCenterY property as been set to number
		 *  value other than NaN.
		 */
		private var _projectionCenterYSet:Boolean;
		
		[Inspectable(category="General", defaultValue="NaN")]
		/**
		 *  projectionCenterY
		 * 
		 *  @default NaN
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get projectionCenterY():Number
		{
			return _projectionCenterY;
		}
		/**
		 *  @private
		 */
		public function set projectionCenterY(value:Number):void
		{
			if( _projectionCenterY == value ) return;
			
			_projectionCenterY = value;
			_projectionChanged = true;
			_projectionCenterYSet = true;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  fieldOfView
		//----------------------------------  
		
		/**
		 *  @private
		 *	Storage property for fieldOfView.
		 */
		private var _fieldOfView:Number = NaN;
		
		[Inspectable(category="General")]
		/**
		 *  fieldOfView
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get fieldOfView():Number
		{
			return ( perspectiveProjection ) ? perspectiveProjection.fieldOfView : _fieldOfView;
		}
		/**
		 *  @private
		 */
		public function set fieldOfView( value:Number ):void
		{
			if( _fieldOfView == value ) return;
			
			_fieldOfView = value;
			_focalLength = NaN;
			_projectionChanged = true;
			invalidateTargetDisplayList();
		}    
		
		
		//----------------------------------
		//  focalLength
		//----------------------------------  
		
		/**
		 *  @private
		 *	Storage property for focalLength.
		 */
		private var _focalLength:Number = NaN;
		
		[Inspectable(category="General")]
		/**
		 *  focalLength
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get focalLength():Number
		{
			return ( perspectiveProjection ) ? perspectiveProjection.focalLength : _focalLength;
		}
		/**
		 *  @private
		 */
		public function set focalLength( value:Number ):void
		{
			if( _focalLength == value ) return;
			
			_focalLength = value;
			_fieldOfView = NaN;
			_projectionChanged = true;
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  perspectiveProjection
		//----------------------------------  
		
		/**
		 *  @private
		 */
		private function get perspectiveProjection():PerspectiveProjection
		{
			return target.transform.perspectiveProjection;
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
			super.target = value;
			
			_projectionChanged = true;
			invalidateTargetDisplayList();
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Returns the visible projection plane at a specific depth.
		 *  
		 *  @param z The depth of the projection plane.
		 * 
		 *  @return Rectangle A Rectangle object with the coordinates of the projection plane.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function getProjectionRectAtZ( z:Number ):Rectangle
		{
			const rectangle:Rectangle = new Rectangle();
			rectangle.right = getProjectionCoord( projectionCenterX, unscaledWidth, z );
			rectangle.left = getProjectionCoord( projectionCenterX, 0, z );
			rectangle.bottom = getProjectionCoord( projectionCenterY, unscaledHeight, z );
			rectangle.top = getProjectionCoord( projectionCenterY, 0, z );
			return rectangle;
		}
		
		/**
		 *  @private
		 *  Util function to return a side of the Rect.
		 */
		private function getProjectionCoord( center:Number, border:Number, z:Number ):Number
		{
//			private function angle( p1:Point, p2:Point ):Number
//			{
//				return ( Math.atan2( p2.y - p1.y, p2.x - p1.x ) * ( 180 / Math.PI ) ) % 360;
//			}
//			
//			private function tanD( a:Number ):Number
//			{
//				return Math.tan( a * ( Math.PI / 180 ) );
//			}
//			a = 90 - angle( new Point( projectionCenterX.value, 0 ), new Point( 400, p.focalLength ) );
//			displayRect.right =projectionCenterX.value + ( tanD( a ) * distance );
//			a = 90 - angle( new Point( projectionCenterX.value, 0 ), new Point( 0, p.focalLength ) );
//			displayRect.left = projectionCenterX.value + ( tanD( a ) * distance );
//			a = 90 - angle( new Point( projectionCenterY.value, 0 ), new Point( 300, p.focalLength ) );
//			displayRect.bottom = projectionCenterY.value + ( tanD( a ) * distance );
//			a = 90 - angle( new Point( projectionCenterY.value, 0 ), new Point( 0, p.focalLength ) );
//			displayRect.top = projectionCenterY.value + tanD( a ) * distance;
			
			// Find the angle from the center of the projection to the edge of the projection plane.
			const angle:Number = ( Math.atan2( focalLength, border - center ) * ( 180 / Math.PI ) ) % 360;
			// Find the edge of the plane at the specified z.
			return center + ( Math.tan( ( 90 - angle ) * ( Math.PI / 180 ) ) * ( z + focalLength ) );
		}
		
		
		
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
		override protected function updateDisplayListBetween():void
		{
			
			
			if( target && _projectionChanged || ( sizeChangedInLayoutPass && !_projectionCenterXSet || !_projectionCenterYSet ) )
			{
				_projectionChanged = false;
				
				if( !perspectiveProjection ) target.transform.perspectiveProjection = new PerspectiveProjection();
				
				if( !_projectionCenterXSet || isNaN( _projectionCenterX ) ) _projectionCenterX = unscaledWidth / 2;
				if( !_projectionCenterYSet || isNaN( _projectionCenterY ) ) _projectionCenterY = unscaledHeight / 2;
				perspectiveProjection.projectionCenter = new Point( _projectionCenterX, _projectionCenterY );
				
				if( !isNaN( _fieldOfView ) ) perspectiveProjection.fieldOfView = _fieldOfView;
				if( !isNaN( _focalLength ) ) perspectiveProjection.focalLength = _focalLength;
			}
			
			super.updateDisplayListBetween();
		}
		
		
		
	}
}