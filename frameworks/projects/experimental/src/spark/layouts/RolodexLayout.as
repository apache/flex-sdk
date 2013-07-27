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
	import flash.geom.Vector3D;
	
	import mx.core.IVisualElement;
	
	import spark.layouts.HorizontalAlign;
	import spark.layouts.VerticalAlign;

	/**
	 *  The RolodexLayout class arranges the layout elements in a depth sequence,
	 *  front to back, with optional depths between the elements and optional aligment
	 *  of the sequence of elements.
	 * 
	 * 	<p>When moving between elements the first element is rotated by 270 degrees,
	 *  with the transform point anchored on the side of the element specified with
	 *  <code>rotationAnchor</code> to transition the element in and out of view.</p>
	 *
	 *  <p>The vertical position of the elements is determined by a combination
	 *  of the <code>verticalAlign</code>, <code>verticalOffset</code>,
	 *  <code>verticalDisplacement</code> and the number of indices the element
	 *  is from the <code>selectedIndex</code> property.
	 *  First the element is aligned using the <code>verticalAlign</code> property
	 *  and then the <code>verticalOffset</code> is applied. The value of
	 *  <code>verticalDisplacement</code> is then multiplied of the number of
	 *  elements the element is from the selected element.</p>
	 *
	 *  <p>The horizontal position of the elements is determined by a combination
	 *  of the <code>horizontalAlign</code>, <code>horizontalOffset</code>,
	 *  <code>horizontalDisplacement</code> and the number of indices the element
	 *  is from the <code>selectedIndex</code> property.
	 *  First the element is aligned using the <code>horizontalAlign</code> property
	 *  and then the <code>determined</code> is applied. The value of
	 *  <code>horizontalDisplacement</code> is then multiplied of the number of
	 *  elements the element is from the selected element.</p>
	 * 
	 *  @mxml
	 *
	 *  <p>The <code>&lt;st:RolodexLayout&gt;</code> tag inherits all of the tag 
	 *  attributes of its superclass and adds the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;st:RolodexLayout
	 *    <strong>Properties</strong>
	 *    rotationAnchor="bottom"
	 *  /&gt;
	 *  </pre>
	 *
	 *  @see spark.containers.Navigator
	 *  @see spark.containers.NavigatorGroup
	 *  @see spark.components.DataNavigator
	 *  @see spark.components.DataNavigatorGroup
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public class RolodexLayout extends TimeMachineLayout
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
		public function RolodexLayout()
		{
			super();
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  rotationAnchor
		//---------------------------------- 
		
		/**
		 *  @private
		 *  Storage property for rotationAnchor.
		 */
		private var _rotationAnchor:String;
		
		[Inspectable(category="General", enumeration="bottom,left,right,top", defaultValue="top")]
		/**
		 *  The side where the rotation transform will be centered on elements.
		 * 
		 *  @default "top"
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */ 
		public function get rotationAnchor():String
		{ 
			return _rotationAnchor;
		}
		/**
		 *  @private
		 */
		public function set rotationAnchor( value:String ):void
		{
			if( _rotationAnchor == value ) return;
			
			_rotationAnchor = value;
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  If the element is the first item, makes sure that the element has a z position of 0,
		 *  and a depth of 0 if the indexOffset is bigger than 0.5 (so that it appears behind
		 *  other elements).
		 * 
		 *  The element is also rotated depending on the <code>anchorPoint</code>.
		 */
		override protected function transformElement( element:IVisualElement, viewIndex:int, indexOffset:Number, alphaDeltaOffset:Number, zDeltaOffset:Number, isFirst:Boolean ):void
		{
			super.transformElement( element, viewIndex, isFirst ? 0 : indexOffset, alphaDeltaOffset, isFirst ? 0 : zDeltaOffset, isFirst );
			
			if( isFirst )
			{
				const rVector3D:Vector3D = new Vector3D();
				const pVector:Vector3D = new Vector3D();
				switch( rotationAnchor )
				{
					
					case HorizontalAlign.LEFT :
					{
						rVector3D.y = 270 * indexOffset;
						break;
					}
					case HorizontalAlign.RIGHT :
					{
						rVector3D.y = -270 * indexOffset;
						pVector.x = element.getLayoutBoundsWidth();
						break;
					}
					case VerticalAlign.TOP :
					{
						rVector3D.x = -270 * indexOffset;
						break;
					}
					case VerticalAlign.BOTTOM :
					default :
					{
						rVector3D.x = 270 * indexOffset;
						pVector.y = element.getLayoutBoundsHeight();
						break;
					}
				}

				if( indexOffset > 0.5 ) element.depth = 0;
				element.transformAround( pVector, null, rVector3D );
			}
		}
	}
}