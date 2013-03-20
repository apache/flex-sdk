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
	
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.VerticalAlign;

	public class PerspectiveNavigatorLayoutBase extends NavigatorLayoutBase
	{
		
		private var _projectionChanged	: Boolean;
		
		private var _unscaledWidth	: Number;
		private var _unscaledHeight	: Number;
		
		
		public function PerspectiveNavigatorLayoutBase()
		{
			super();
		}
		
		override public function set target(value:GroupBase):void
		{
			super.target = value;
			
			_projectionChanged = true;
			invalidateTargetDisplayList();
		}
		
		public function get projectionCenter():Point
		{
			return ( perspectiveProjection ) ? perspectiveProjection.projectionCenter : getProjectionCenter();
		}
		
		private var _projectionCenterHorizontalAlign:String = HorizontalAlign.CENTER;
		[Inspectable(category="General", enumeration="left,right,center", defaultValue="center")]
		public function get projectionCenterHorizontalAlign():String
		{
			return _projectionCenterHorizontalAlign;
		}
		public function set projectionCenterHorizontalAlign(value:String):void
		{
			if( value == _projectionCenterHorizontalAlign ) return;
			
			_projectionCenterHorizontalAlign = value;
			
			invalidateTargetDisplayList();
		}
		
		private var _projectionCenterVerticalAlign:String = VerticalAlign.MIDDLE;
		[Inspectable(category="General", enumeration="top,bottom,middle", defaultValue="middle")]
		public function get projectionCenterVerticalAlign():String
		{
			return _projectionCenterVerticalAlign;
		}
		public function set projectionCenterVerticalAlign(value:String):void
		{
			if( value == _projectionCenterVerticalAlign ) return;
			
			_projectionCenterVerticalAlign = value;
			
			invalidateTargetDisplayList();
		}
		
		
		private var _projectionCenterHorizontalOffset:Number = 0;
		[Inspectable(category="General", defaultValue="0")]
		public function get projectionCenterHorizontalOffset():Number
		{
			return _projectionCenterHorizontalOffset;
		}
		public function set projectionCenterHorizontalOffset(value:Number):void
		{
			if( _projectionCenterHorizontalOffset == value ) return;
			
			_projectionCenterHorizontalOffset = value;
			invalidateTargetDisplayList();
		}    
		
		private var _projectionCenterVerticalOffset:Number = 0;
		[Inspectable(category="General", defaultValue="0")]
		public function get projectionCenterVerticalOffset():Number
		{
			return _projectionCenterVerticalOffset;
		}
		public function set projectionCenterVerticalOffset(value:Number):void
		{
			if( _projectionCenterVerticalOffset == value ) return;
			
			_projectionCenterVerticalOffset = value;
			invalidateTargetDisplayList();
		}
		
		
		private var _fieldOfView:Number = NaN;
		[Inspectable(category="General", defaultValue="55")]
		public function get fieldOfView():Number
		{
			return ( perspectiveProjection ) ? perspectiveProjection.fieldOfView : _fieldOfView;
		}
		public function set fieldOfView( value:Number ):void
		{
			if( _fieldOfView == value ) return;
			
			_fieldOfView = value;
			_focalLength = NaN;
			_projectionChanged = true;
			invalidateTargetDisplayList();
		}    
		
		private var _focalLength:Number = NaN;
		[Inspectable(category="General")]
		public function get focalLength():Number
		{
			return ( perspectiveProjection ) ? perspectiveProjection.focalLength : _focalLength;
		}
		public function set focalLength( value:Number ):void
		{
			if( _focalLength == value ) return;
			
			_focalLength = value;
			_fieldOfView = NaN;
			_projectionChanged = true;
			invalidateTargetDisplayList();
		}
		
		override public function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			if( _unscaledWidth != unscaledWidth || _unscaledHeight != unscaledHeight )
			{
				_unscaledWidth = unscaledWidth;
				_unscaledHeight = unscaledHeight;
				_projectionChanged = true;
			}
			
			if( target && _projectionChanged )
			{
				_projectionChanged = false;
				
				if( !perspectiveProjection ) target.transform.perspectiveProjection = new PerspectiveProjection();
				
				perspectiveProjection.projectionCenter = getProjectionCenter();
				if( !isNaN( _fieldOfView ) ) perspectiveProjection.fieldOfView = _fieldOfView;
				if( !isNaN( _focalLength ) ) perspectiveProjection.focalLength = _focalLength;
			}
			
		}
		
		
		private function getProjectionCenter():Point
		{
			var p:Point = new Point();
			switch( _projectionCenterHorizontalAlign )
			{
				case HorizontalAlign.LEFT :
				{
					p.x = _projectionCenterHorizontalOffset;
					break;
				}
				case HorizontalAlign.CENTER :
				{
					p.x = ( _unscaledWidth / 2 ) + _projectionCenterHorizontalOffset;
					break;
				}
				case HorizontalAlign.RIGHT :
				{
					p.x = _unscaledWidth + _projectionCenterHorizontalOffset;
					break;
				}
			}
			
			switch( _projectionCenterVerticalAlign )
			{
				case VerticalAlign.TOP :
				{
					p.y = _projectionCenterVerticalOffset;
					break;
				}
				case VerticalAlign.MIDDLE :
				{
					p.y = ( _unscaledHeight / 2 ) + _projectionCenterVerticalOffset;
					break;
				}
				case VerticalAlign.BOTTOM :
				{
					p.y = _unscaledHeight + _projectionCenterVerticalOffset;
					break;
				}
			}
			
			return p;
		}
		
		private function get perspectiveProjection():PerspectiveProjection
		{
			return target.transform.perspectiveProjection;
		}
		
		
	}
}