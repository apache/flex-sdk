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
package spark.components
{
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.ILayoutElement;
	import mx.core.LayoutDirection;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.managers.SystemManager;
	import mx.utils.MatrixUtil;
	import mx.utils.PopUpUtil;
	
	import spark.components.SkinnablePopUpContainer;
	
	
	use namespace mx_internal;
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
	 *  Appearance of the <code>contentGroup</code>. 
	 *  Valid MXML values are <code>inset</code>, 
	 *  <code>flat</code>, and <code>none</code>.
	 *
	 *  <p>In ActionScript, you can use the following constants
	 *  to set this property:
	 *  <code>ContentBackgroundAppearance.INSET</code>,
	 *  <code>ContentBackgroundAppearance.FLAT</code> and
	 *  <code>ContentBackgroundAppearance.NONE</code>.</p>
	 *
	 *  @default ContentBackgroundAppearance.INSET
	 *  
	 *  @langversion 3.0
	 *  @playerversion AIR 3
	 *  @productversion Flex 4.6
	 */ 
	[Style(name="contentBackgroundAppearance", type="String", enumeration="inset,flat,none", inherit="no")]
	
	public class CallOut extends SkinnablePopUpContainer
	{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		private static var decomposition:Vector.<Number> = new <Number>[0,0,0,0,0];
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *
		 *  @langversion 3.0
		 *  @playerversion AIR 3
		 *  @productversion Flex 4.6
		 */
		public function CallOut()
		{
			super();
		}
		
		/*
		override protected function createChildren():void
		{
			super.createChildren();
			
			arrow			= new CallOutArrow();
			arrow.visible	= false;
			
			this.addElement(arrow);
		}
		*/
		
		//--------------------------------------------------------------------------
		//
		//  Skin parts
		//
		//--------------------------------------------------------------------------
		
		//[Bindable]
		// [SkinPart(required="false")]
		/**
		 *  An optional skin part that visually connects the owner to the
		 *  contentGroup.
		 *
		 *  @langversion 3.0
		 *  @playerversion AIR 3
		 *  @productversion Flex 4.6
		 */
		//public var arrow:CallOutArrow;
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		private var invalidatePositionFlag:Boolean = false;
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  horizontalPosition
		//----------------------------------
		
		private var _horizontalPosition:String = CallOutPosition.AUTO;
		
		[Inspectable(category="General", enumeration="before,start,middle,end,after,auto", defaultValue="auto")]
		
		/**
		 *  Horizontal position of the callout relative to the owner.
		 *
		 *  <p>Possible values are <code>"before"</code>, <code>"start"</code>,
		 *  <code>"middle"</code>, <code>"end"</code>, <code>"after"</code>,
		 *  and <code>"auto"</code> (default).</p>
		 *
		 *  @default CalloutPosition.AUTO
		 *  @see spark.components.CalloutPosition
		 *
		 *  @langversion 3.0
		 *  @playerversion AIR 3
		 *  @productversion Flex 4.6
		 */
		public function get horizontalPosition():String
		{
			return _horizontalPosition;
		}
		
		/**
		 *  @private
		 */
		public function set horizontalPosition(value:String):void
		{
			if (value == _horizontalPosition)
				return;
			
			_horizontalPosition = value;
			
			invalidatePosition();
		}
		
		//----------------------------------
		//  actualHorizontalPosition
		//----------------------------------
		
		private var _actualHorizontalPosition:String;
		
		/**
		 *  Fully resolved horizontal position after evaluating CalloutPosition.AUTO.
		 * 
		 *  <p>Update this property in <code>commitProperties()</code> when the
		 *  explicit <code>horizontalPosition</code> is CalloutPosition.AUTO. 
		 *  This property must be updated in <code>updatePopUpPosition()</code>
		 *  when attempting to reposition the Callout.</p> 
		 *  
		 *  <p>Subclasses should read this property when computing the <code>arrowDirection</code>,
		 *  the arrow position in <code>updateSkinDisplayList()</code>.</p>
		 *
		 *  @langversion 3.0
		 *  @playerversion AIR 3
		 *  @productversion Flex 4.6
		 */
		mx_internal function get actualHorizontalPosition():String
		{
			if (_actualHorizontalPosition)
				return _actualHorizontalPosition;
			
			return horizontalPosition;
		}
		
		/**
		 *  @private
		 */
		mx_internal function set actualHorizontalPosition(value:String):void
		{
			_actualHorizontalPosition = value;
		}
		
		//----------------------------------
		//  verticalPosition
		//----------------------------------
		
		private var _verticalPosition:String = CallOutPosition.AUTO;
		
		[Inspectable(category="General", enumeration="before,start,middle,end,after,auto", defaultValue="auto")]
		
		/**
		 *  Vertical position of the callout relative to the owner.
		 *
		 *  <p>Possible values are <code>"before"</code>, <code>"start"</code>,
		 *  <code>"middle"</code>, <code>"end"</code>, <code>"after"</code>,
		 *  and <code>"auto"</code> (default).</p>
		 *
		 *  @default CalloutPosition.AUTO
		 *  @see spark.components.CalloutPosition
		 *
		 *  @langversion 3.0
		 *  @playerversion AIR 3
		 *  @productversion Flex 4.6
		 */
		public function get verticalPosition():String
		{
			return _verticalPosition;
		}
		
		/**
		 *  @private
		 */
		public function set verticalPosition(value:String):void
		{
			if (value == _verticalPosition)
				return;
			
			_verticalPosition = value;
			
			invalidatePosition();
		}
		
		//----------------------------------
		//  actualVerticalPosition
		//----------------------------------
		
		private var _actualVerticalPosition:String;
		
		/**
		 *  Fully resolved vertical position after evaluating CalloutPosition.AUTO.
		 * 
		 *  <p>Update this property in <code>commitProperties()</code> when the
		 *  explicit <code>verticalPosition</code> is CalloutPosition.AUTO. 
		 *  This property must be updated in <code>updatePopUpPosition()</code>
		 *  when attempting to reposition the Callout.</p> 
		 *  
		 *  <p>Subclasses should read this property when computing the <code>arrowDirection</code>,
		 *  the arrow position in <code>updateSkinDisplayList()</code>.</p>
		 *
		 *  @langversion 3.0
		 *  @playerversion AIR 3
		 *  @productversion Flex 4.6
		 */
		mx_internal function get actualVerticalPosition():String
		{
			if (_actualVerticalPosition)
				return _actualVerticalPosition;
			
			return verticalPosition;
		}
		
		/**
		 *  @private
		 */
		mx_internal function set actualVerticalPosition(value:String):void
		{
			_actualVerticalPosition = value;
		}
		
		//----------------------------------
		//  arrowDirection
		//----------------------------------
		
		private var _arrowDirection:String = ArrowDirection.NONE;
		
		/**
		 *  @private
		 *  Indicates if arrow direction was flipped automatically.
		 */
		private var arrowDirectionAdjusted:Boolean = false;
		
		/**
		 *  A read-only property that indicates the direction from the callout
		 *  towards the owner.
		 *
		 *  <p>This value is computed based on the callout position given by
		 *  <code>horizontalPosition</code> and <code>verticalPosition</code>.
		 *  Exterior and interior positions will point from the callout towards
		 *  the edge of the owner. Corner and absolute center positions are not
		 *  supported and will return a value of <code>"none".</code></p>
		 * 
		 *  @default none
		 *
		 *  @see spark.components.ArrowDirection
		 *
		 *  @langversion 3.0
		 *  @playerversion AIR 3
		 *  @productversion Flex 4.6
		 */
		public function get arrowDirection():String
		{
			return _arrowDirection;
		}
		
		/**
		 *  @private
		 *  Invalidate skin when the arrowDirection changes. Dispatches an 
		 *  "arrowDirectionChanged" event when the property is set.
		 */
		mx_internal function setArrowDirection(value:String):void
		{
			if (_arrowDirection == value)
				return;
			
			_arrowDirection = value;
			
			//arrow.setArrowDirection(value);
			
			// Instead of using skin states for each arrowDirection, the
			// skin must override commitProperties() and account for
			// arrowDirection on it's own.
			skin.invalidateProperties();
			
			
			
			// adjust margins based on arrow direction
			/*
			switch (arrowDirection)
			{
				case ArrowDirection.DOWN:
				{
					// Set the marginBottom to zero to place the arrow adjacent to the keyboard
					softKeyboardEffectMarginBottom = 0;
					softKeyboardEffectMarginTop = margin;
					break;
				}
				case ArrowDirection.UP:
				{
					// Arrow should already be adjacent to the owner or the top of
					// the screen.
					softKeyboardEffectMarginTop = 0;
					softKeyboardEffectMarginBottom = margin;
					break;
				}
				default:
				{
					softKeyboardEffectMarginBottom = margin;
					softKeyboardEffectMarginTop = margin;
					break;
				}
			}
			*/
			if (hasEventListener("arrowDirectionChanged"))
				dispatchEvent(new Event("arrowDirectionChanged"));
		}
		
		//----------------------------------
		//  margin
		//----------------------------------
		
		private var _margin:Number = NaN;
		
		/**
		 *  @private
		 *  Defines a margin around the Callout to nudge it's position away from the
		 *  edge of the screen.
		 */
		mx_internal function get margin():Number
		{
			if (isNaN(_margin))
			{
				_margin = 8;
			}
			
			return _margin;
		}
		
		//----------------------------------
		//  calloutMaxWidth
		//----------------------------------
		
		private var _calloutMaxWidth:Number = NaN;
		
		/**
		 *  @private
		 */
		mx_internal function get calloutMaxWidth():Number
		{
			return _calloutMaxWidth;
		}
		
		/**
		 *  @private
		 */
		mx_internal function set calloutMaxWidth(value:Number):void
		{
			if (_calloutMaxWidth == value)
				return;
			
			_calloutMaxWidth = value;
			
			invalidateMaxSize();
		}
		
		
		//----------------------------------
		//  calloutMaxHeight
		//----------------------------------
		
		private var _calloutMaxHeight:Number = NaN;
		
		/**
		 *  @private
		 */
		mx_internal function get calloutMaxHeight():Number
		{
			return _calloutMaxHeight;
		}
		
		/**
		 *  @private
		 */
		mx_internal function set calloutMaxHeight(value:Number):void
		{
			if (_calloutMaxHeight == value)
				return;
			
			_calloutMaxHeight = value;
			
			invalidateMaxSize();
		}

		/**
		 * ORIGINAL
		 */
		/*
		override public function updatePopUpPosition():void {
			if (!owner || !systemManager) return;
			
			var position:Point = calculatePopUpPosition();
			var ownerComponent:UIComponent = owner as UIComponent;
			var color:ColorTransform = ownerComponent ? ownerComponent.$transform.concatenatedColorTransform : null;
			
			PopUpUtil.applyPopUpTransform(owner, color, systemManager, this, position);
		}
		
		protected function calculatePopUpPosition():Point {
			//start from owner's global position
			var pos:Point = owner.parent.localToGlobal(new Point(owner.x, owner.y));
			
			pos.x += owner.width / 2 - width / 2;
			pos.y += owner.height;
			
			return pos;
		}
		*/
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function get explicitMaxWidth():Number
		{
			if (!isNaN(super.explicitMaxWidth))
				return super.explicitMaxWidth;
			
			return calloutMaxWidth;
		}
		
		/**
		 *  @private
		 */
		override public function get explicitMaxHeight():Number
		{
			if (!isNaN(super.explicitMaxHeight))
				return super.explicitMaxHeight;
			
			return calloutMaxHeight;
		}
		
		/**
		 *  @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			// Do not commit position changes if closed (no owner) or owner was 
			// removed from the display list.
			if (!owner || !owner.parent)
				return;
			
			// Compute actual positions when using AUTO
			commitAutoPosition();
			
			// Compute max size based on actual positions
			commitMaxSize();
			
			/*
			if (arrow)
			{
			*/
				// arrowDirection can be set in 2 ways: (1) horizontalPostion/verticalPosition
				// changes and (2) flipping the axis to fit on screen. 
				if (!arrowDirectionAdjusted)
				{
					// Invalidate only when the arrow direction changes
					var direction:String = determineArrowPosition(actualHorizontalPosition, actualVerticalPosition);
					
					// trace("direction: "+direction);
					// trace("arrowDirection: "+arrowDirection);
					
					if (arrowDirection != direction)
					{
						setArrowDirection(direction);
						/*
						if(arrow)
							arrow.visible = (arrowDirection != ArrowDirection.NONE);
						*/
						//trace("visibility arrow: "+arrow.visible.toString());
					}
				}
				
				// Always reset the arrow position
				invalidateDisplayList();
			//}
			
		}
		
		/**
		 *  @private
		 *  Re-position the pop-up using actualHorizontalPosition and
		 *  actualVerticalPosition. 
		 */
		override public function updatePopUpPosition():void
		{
			if (!owner || !systemManager)
				return;
			
			var popUpPoint:Point = calculatePopUpPosition();
			var ownerComponent:UIComponent = owner as UIComponent;
			var concatenatedColorTransform:ColorTransform = (ownerComponent) ? ownerComponent.$transform.concatenatedColorTransform : null;
			
			PopUpUtil.applyPopUpTransform(owner, concatenatedColorTransform, systemManager, this, popUpPoint);
		}
		
		/**
		 *  @private
		 *
		 *  Cooperative layout
		 *  @see spark.components.supportClasses.TrackBase#partAdded
		 */
		/*
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			
			if (instance == arrow)
				arrow.addEventListener(ResizeEvent.RESIZE, arrow_resizeHandler);
		}
		*/
		/**
		 *  @private
		 */
		/*
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			if (instance == arrow)
				arrow.removeEventListener(ResizeEvent.RESIZE, arrow_resizeHandler);
		}
		*/
		/**
		 *  @private
		 */
		override public function open(owner:DisplayObjectContainer, modal:Boolean=false):void
		{
			if (isOpen)
				return;
			
			// reset state
			invalidatePositionFlag = false;
			arrowDirectionAdjusted = false;
			
			// Add to PopUpManager, calls updatePopUpPosition(), and change state
			super.open(owner, modal);
			
			// Reposition the callout when the screen changes
			var systemManagerParent:SystemManager = this.parent as SystemManager;
			
			if (systemManagerParent)
				systemManagerParent.addEventListener(Event.RESIZE, systemManager_resizeHandler);
		}
		
		/**
		 *  @private
		 */
		override public function close(commit:Boolean=false, data:*=null):void
		{
			if (!isOpen)
				return;
			
			var systemManagerParent:SystemManager = this.parent as SystemManager;
			
			if (systemManagerParent)
				systemManagerParent.removeEventListener(Event.RESIZE, systemManager_resizeHandler);
			
			super.close(commit, data);
		}
		
		/**
		 *  @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// Callout can be respositioned while open via SystemManager resize or
			// explicit changes to horizontalPostion and verticalPosition.
			if (isOpen && invalidatePositionFlag)
			{
				updatePopUpPosition();
				invalidatePositionFlag = false;
			}
			
			// Position the arrow
			//updateSkinDisplayList();
			//arrow.invalidateSkinState();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function invalidatePosition():void
		{
			arrowDirectionAdjusted = false;
			
			invalidateProperties();
			
			if (isOpen)
				invalidatePositionFlag = true;
		}
		
		/**
		 *  @private
		 *  Force a new measurement when callout should use it's screen-constrained
		 *  max size.
		 */
		private function invalidateMaxSize():void
		{
			// calloutMaxWidth and calloutMaxHeight don't invalidate 
			// explicitMaxWidth or explicitMaxHeight. If callout's max size changes
			// and explicit max sizes aren't set, then invalidate size here so that
			// callout's max size is applied.
			if (!canSkipMeasurement() && !isMaxSizeSet)
				skin.invalidateSize();
		}
		
		/**
		 *  Sets the bounds of <code>arrow</code>, whose geometry isn't fully
		 *  specified by the skin's layout.
		 *
		 *  <p>Subclasses can override this method to update the arrow's size,
		 *  position, and visibility, based on the computed
		 *  <code>arrowDirection</code>.</p>
		 *
		 *  <p>By default, this method aligns the arrow on the shorter of either
		 *  the <code>arrow</code> bounds or the <code>owner</code> bounds. This
		 *  implementation assumes that the <code>arrow</code> and the Callout skin
		 *  share the same coordinate space.</p>
		 *
		 *  @langversion 3.0
		 *  @playerversion AIR 3
		 *  @productversion Flex 4.6
		 */
		/*
		protected function updateSkinDisplayList():void
		{
			var ownerVisualElement:IVisualElement = owner as IVisualElement;
			
			// Sanity check to verify owner is still on the display list. If not,
			// leave the arrow in the current position.
			if (!arrow || !ownerVisualElement || (arrowDirection == ArrowDirection.NONE) ||	(!ownerVisualElement.parent))
				return;
			
			var isStartPosition:Boolean = false;
			var isMiddlePosition:Boolean = false;
			var isEndPosition:Boolean = false;
			
			var position:String = (isArrowVertical) ? actualHorizontalPosition : actualVerticalPosition;
			
			isStartPosition = (position == CalloutPosition.START);
			isMiddlePosition = (position == CalloutPosition.MIDDLE);
			isEndPosition = (position == CalloutPosition.END);
			
			var isEndOfCallout:Boolean = (arrowDirection == ArrowDirection.DOWN) || (arrowDirection == ArrowDirection.RIGHT);
			
			var calloutWidth:Number = getLayoutBoundsWidth();
			var calloutHeight:Number = getLayoutBoundsHeight();
			var arrowWidth:Number = arrow.getLayoutBoundsWidth();
			var arrowHeight:Number = arrow.getLayoutBoundsHeight();
			
			// arrow X/Y in pop-up coordinates
			var arrowX:Number = 0;
			var arrowY:Number = 0;
			
			// Max arrow positions
			var maxArrowX:Number = calloutWidth - arrowWidth;
			var maxArrowY:Number = calloutHeight - arrowHeight;
			
			// Find the registration point of the owner
			var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
			var regPoint:Point = owner.localToGlobal(new Point());
			regPoint = sandboxRoot.globalToLocal(regPoint);
			
			if (isArrowVertical)
			{
				// Vertical arrows need horizontal alignment
				var ownerX:Number = regPoint.x;
				var ownerVisibleWidth:Number = (ownerVisualElement)	? ownerVisualElement.getLayoutBoundsWidth() : owner.width;
				
				// Edge cases when start/end of owner is not visible
				if ((ownerX < 0) && (ownerVisibleWidth < screen.width))
					ownerVisibleWidth = Math.max(ownerVisibleWidth + ownerX, 0);
				else if ((ownerX >= 0) && ((ownerX + ownerVisibleWidth) >= screen.width))
					ownerVisibleWidth = Math.max(screen.width - ownerX, 0);
				
				ownerVisibleWidth = Math.min(ownerVisibleWidth, screen.width);
				
				if (calloutWidth <= ownerVisibleWidth)
				{
					arrowX = (calloutWidth - arrowWidth) / 2;
				}
				else // if (calloutWidth > ownerWidth)
				{
					// Center the arrow on the owner
					arrowX = (ownerVisibleWidth - arrowWidth) / 2;
					
					// Add owner offset
					if (ownerX > 0)
						arrowX += Math.abs(ownerX - getLayoutBoundsX());
					
					if (ownerX < margin)
						arrowX -= (margin - ownerX);
				}
				
				// arrow should not extend past the callout bounds
				arrowX = Math.max(Math.min(maxArrowX, arrowX), 0);
				
				// Move the arrow to the bottom of the callout
				if (isEndOfCallout)
					arrowY = calloutHeight - arrowHeight;
			}
			else
			{
				// Horizontal arrows need vertical alignment
				var ownerY:Number = regPoint.y;
				var ownerVisibleHeight:Number = (ownerVisualElement) ? ownerVisualElement.getLayoutBoundsHeight() : owner.height;
				
				// Edge cases when start/end of owner is not visible
				if ((ownerY < 0) && (ownerVisibleHeight < screen.height))
					ownerVisibleHeight = Math.max(ownerVisibleHeight + ownerY, 0);
				else if ((ownerY >= 0) && ((ownerY + ownerVisibleHeight) >= screen.height))
					ownerVisibleHeight = Math.max(screen.height - ownerY, 0);
				
				ownerVisibleHeight = Math.min(ownerVisibleHeight, screen.height);
				
				if (calloutHeight <= ownerVisibleHeight)
				{
					arrowY = (calloutHeight - arrowHeight) / 2;
				}
				else // if (calloutHeight > ownerHeight)
				{
					// Center the arrow on the owner
					arrowY = (ownerVisibleHeight - arrowHeight) / 2;
					
					// Add owner offset
					if (ownerY > 0)
						arrowY += Math.abs(ownerY - getLayoutBoundsY());
					
					if (ownerY < margin)
						ownerY -= (margin - ownerY);
				}
				
				// arrow should not extend past the callout bounds
				arrowY = Math.max(Math.min(maxArrowY, arrowY), 0);
				
				// Move the arrow to the end of the callout
				if (isEndOfCallout)
					arrowX = calloutWidth - arrowWidth;
			}
			
			arrow.setLayoutBoundsPosition(Math.floor(arrowX), Math.floor(arrowY));
			arrow.invalidateDisplayList();
		}
		*/
		/**
		 *  @private
		 * 
		 *  Flip or clear the adjusted position when the callout bounds are outside
		 *  the screen bounds.
		 */
		mx_internal function adjustCalloutPosition(actualPosition:String, preferredPosition:String,
												   calloutStart:Number, calloutEnd:Number,
												   screenStart:Number, screenEnd:Number,
												   ownerStart:Number, ownerEnd:Number,
												   revert:Boolean=false):String
		{
			if (!actualPosition)
				return null;
			
			var adjustedPosition:String = null;
			var calloutSize:Number = calloutEnd - calloutStart;
			
			// Exterior space
			var exteriorSpaceStart:Number = Math.max(0, ownerStart - screenStart);
			var exteriorSpaceEnd:Number = Math.max(0, ownerEnd - screenEnd);
			
			// Fallback to interior positions if using AUTO and callout can not
			// fit in either exterior positions
			var useInterior:Boolean = (preferredPosition == CallOutPosition.AUTO) &&
				(exteriorSpaceStart < calloutSize) &&
				(exteriorSpaceEnd < calloutSize);
			var isExterior:Boolean = false;
			
			// Flip to opposite position
			switch (actualPosition)
			{
				case CallOutPosition.BEFORE:
				{
					isExterior = true;
					
					if (calloutStart < screenStart)
						adjustedPosition = CallOutPosition.AFTER;
					
					break;
				}
				case CallOutPosition.AFTER:
				{
					isExterior = true;
					
					if (calloutEnd > screenEnd)
						adjustedPosition = CallOutPosition.BEFORE;
					
					break;
				}
				case CallOutPosition.END:
				{
					if (calloutStart < screenStart)
						adjustedPosition = CallOutPosition.START;
					break;
				}
				case CallOutPosition.START:
				{
					if (calloutEnd > screenEnd)
						adjustedPosition = CallOutPosition.END;
					break;
				}
					// case CalloutPosition.MIDDLE:
					// Nudge instead of flipping
			}
			
			// Use interior position if exterior flipping was necessary
			if (useInterior && adjustedPosition && isExterior)
			{
				// Choose the exterior position with the most available space.
				// Note that START grows towards the exterior END and vice versa.
				adjustedPosition = (exteriorSpaceEnd >= exteriorSpaceStart) ? 
					CallOutPosition.START : CallOutPosition.END;
			}
			
			// Return null to revert the adjusted position
			// Otherwise, return the incoming position
			if (revert)
				return (adjustedPosition) ? null : actualPosition;
			
			// Adjusted position or null if the callout already fits
			return adjustedPosition;
		}
		
		/**
		 *  @private
		 * 
		 *  Nudge the callout position to fit on screen. Prefer top/left positions
		 *  and allow overflow to get clipped on the bottom/right.
		 */
		mx_internal function nudgeToFit(calloutStart:Number, calloutEnd:Number,
										screenStart:Number, screenEnd:Number,
										scaleFactor:Number):Number
		{
			var position:Number = 0;
			
			if (calloutStart < screenStart)
				position += (screenStart - calloutStart) / scaleFactor;
			else if (calloutEnd > screenEnd)
				position -= (calloutEnd - screenEnd) / scaleFactor;
			
			return position;
		}
		
		/**
		 *  @private
		 *
		 *  Basically the same as PopUpAnchor, but with more position options
		 *  including exterior, interior and corner positions.
		 * 
		 *  Nudging to fit the screen accounts for <code>margin</code> so that
		 *  the Callout is not positioned in the margin.
		 * 
		 *  <code>arrowDirection</code> will change if required for the callout
		 *  to fit.
		 *
		 *  @see #margin
		 */
		mx_internal function calculatePopUpPosition():Point
		{
			// This implementation doesn't handle rotation
			var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
			var matrix:Matrix = MatrixUtil.getConcatenatedMatrix(owner, sandboxRoot);
			
			var regPoint:Point = new Point();
			
			if (!matrix)
				return regPoint;
			
			var adjustedHorizontalPosition:String;
			var adjustedVerticalPosition:String;
			var calloutBounds:Rectangle = determinePosition(actualHorizontalPosition, actualVerticalPosition, matrix, regPoint);
			var ownerBounds:Rectangle = owner.getBounds(systemManager.getSandboxRoot());
			
			// Position the callout in the opposite direction if it
			// does not fit on the screen.
			if (screen)
			{
				adjustedHorizontalPosition = adjustCalloutPosition(
					actualHorizontalPosition, horizontalPosition,
					calloutBounds.left, calloutBounds.right,
					screen.left, screen.right,
					ownerBounds.left, ownerBounds.right);
				
				adjustedVerticalPosition = adjustCalloutPosition(
					actualVerticalPosition, verticalPosition,
					calloutBounds.top, calloutBounds.bottom,
					screen.top, screen.bottom,
					ownerBounds.top, ownerBounds.bottom);
			}
			
			var oldArrowDirection:String = arrowDirection;
			var actualArrowDirection:String = null;
			
			// Reset arrowDirectionAdjusted
			arrowDirectionAdjusted = false;
			
			// Get the new registration point based on the adjusted position
			if ((adjustedHorizontalPosition != null) || (adjustedVerticalPosition != null))
			{
				var adjustedRegPoint:Point = new Point();
				var tempHorizontalPosition:String = (adjustedHorizontalPosition) ? adjustedHorizontalPosition : actualHorizontalPosition;
				var tempVerticalPosition:String = (adjustedVerticalPosition) ? adjustedVerticalPosition : actualVerticalPosition;
				
				// Adjust arrow direction after adjusting position
				actualArrowDirection = determineArrowPosition(tempHorizontalPosition, tempVerticalPosition);
				
				// All position flips gaurantee an arrowDirection change
				setArrowDirection(actualArrowDirection);
				arrowDirectionAdjusted = true;
				
				/*
				if (arrow)
					arrow.visible = (arrowDirection != ArrowDirection.NONE);
				
				// Reposition the arrow
				//updateSkinDisplayList();
				
				arrow.invalidateSkinState();
				*/
				var adjustedBounds:Rectangle = determinePosition(tempHorizontalPosition, tempVerticalPosition, matrix, adjustedRegPoint);
				
				if (screen)
				{
					// If we adjusted the position but the callout still doesn't fit,
					// then revert to the original position.
					adjustedHorizontalPosition = adjustCalloutPosition(
						adjustedHorizontalPosition, horizontalPosition,
						adjustedBounds.left, adjustedBounds.right,
						screen.left, screen.right,
						ownerBounds.left, ownerBounds.right,
						true);
					
					adjustedVerticalPosition = adjustCalloutPosition(
						adjustedVerticalPosition, verticalPosition,
						adjustedBounds.top, adjustedBounds.bottom,
						screen.top, screen.bottom, 
						ownerBounds.top, ownerBounds.bottom,
						true);
				}
				
				if ((adjustedHorizontalPosition != null) || (adjustedVerticalPosition != null))
				{
					regPoint = adjustedRegPoint;
					calloutBounds = adjustedBounds;
					
					// Temporarily set actual positions to reposition the arrow
					if (adjustedHorizontalPosition)
						actualHorizontalPosition = adjustedHorizontalPosition;
					
					if (adjustedVerticalPosition)
						actualVerticalPosition = adjustedVerticalPosition;
					
					// Reposition the arrow with the new actual position
					//updateSkinDisplayList();
					//arrow.invalidateSkinState();
				}
				else
				{
					// Restore previous arrow direction *before* reversing the
					// adjusted positions
					setArrowDirection(oldArrowDirection);
					arrowDirectionAdjusted = false;
					
					// Reposition the arrow to the original position
					//updateSkinDisplayList();
					//arrow.invalidateSkinState();
				}
			}
			
			MatrixUtil.decomposeMatrix(decomposition, matrix, 0, 0);
			var concatScaleX:Number = decomposition[3];
			var concatScaleY:Number = decomposition[4];
			
			// If the callout still doesn't fit, then nudge it
			// so it is completely on the screen. Make sure to include scale.
			var screenTop:Number = screen.top;
			var screenBottom:Number = screen.bottom;
			var screenLeft:Number = screen.left;
			var screenRight:Number = screen.right;
			
			// Allow zero margin on the the side with the arrow
			switch (arrowDirection)
			{
				case ArrowDirection.UP:
				{
					screenBottom -= margin;
					screenLeft += margin;
					screenRight -= margin
					break;
				}
				case ArrowDirection.DOWN:
				{
					screenTop += margin;
					screenLeft += margin;
					screenRight -= margin
					break;
				}
				case ArrowDirection.LEFT:
				{
					screenTop += margin;
					screenBottom -= margin;
					screenRight -= margin
					break;
				}
				case ArrowDirection.RIGHT:
				{
					screenTop += margin;
					screenBottom -= margin;
					screenLeft += margin;
					break;
				}
				default:
				{
					screenTop += margin;
					screenBottom -= margin;
					screenLeft += margin;
					screenRight -= margin
					break;
				}
			}
			
			regPoint.y += nudgeToFit(calloutBounds.top, calloutBounds.bottom, screenTop, screenBottom, concatScaleY);
			
			regPoint.x += nudgeToFit(calloutBounds.left, calloutBounds.right, screenLeft, screenRight, concatScaleX);
			
			// trace("regpoint: " + regPoint.toString());
			
			calculateArrowPosition();
			
			// Compute the stage coordinates of the upper,left corner of the PopUp, taking
			// the postTransformOffsets - which include mirroring - into account.
			// If we're mirroring, then the implicit assumption that x=left will fail,
			// so we compensate here.
			
			if (layoutDirection == LayoutDirection.RTL)
				regPoint.x += calloutBounds.width;
			return MatrixUtil.getConcatenatedComputedMatrix(owner, sandboxRoot).transformPoint(regPoint);
		}
		
		mx_internal function calculateArrowPosition():void
		{
			// trace("horizontalPosition: " + horizontalPosition);
			
			// trace("verticalPosition: " + verticalPosition);
		}
		
		/**
		 *  @private
		 *  Computes <code>actualHorizontalPosition</code> and/or
		 *  <code>actualVerticalPosition</code> values when using
		 *  <code>CalloutPosition.AUTO</code>. When implementing subclasses of
		 *  Callout, use <code>actualHorizontalPosition</code> and
		 *  <code>actualVerticalPosition</code> to compute
		 *  <code>arrowDirection</code> and positioning in
		 *  <code>updatePopUpPosition()</code> and <code>updateSkinDisplayList()</code>.
		 *
		 *  <p>The default implementation chooses "outer" positions for the callout
		 *  such that the owner is not obscured. Horizontal/Vertical orientation
		 *  relative to the owner choosen based on the aspect ratio.</p>
		 *
		 *  <p>When the aspect ratio is landscape, and the callout can fit to the
		 *  left or right of the owner, <code>actualHorizontalPosition</code> is
		 *  set to <code>CalloutPosition.BEFORE</code> or
		 *  <code>CalloutPosition.AFTER</code> as appropriate.
		 *  <code>actualVerticalPosition</code> is set to
		 *  <code>CalloutPosition.MIDDLE</code> to have the vertical center of the
		 *  callout align to the vertical center of the owner.</p>
		 *
		 *  <p>When the aspect ratio is portrait, and the callout can fit
		 *  above or below the owner, <code>actualVerticalPosition</code> is
		 *  set to <code>CalloutPosition.BEFORE</code> or
		 *  <code>CalloutPosition.AFTER</code> as appropriate.
		 *  <code>actualHorizontalPosition</code> is set to
		 *  <code>CalloutPosition.MIDDLE</code> to have the horizontal center of the
		 *  callout align to the horizontal center of the owner.</p>
		 *
		 *  <p>Subclasses may override to modify automatic positioning behavior.</p>
		 */
		mx_internal function commitAutoPosition():void
		{
			if (!screen || ((horizontalPosition != CallOutPosition.AUTO) &&
				(verticalPosition != CallOutPosition.AUTO)))
			{
				// Use explicit positions instead of AUTO
				actualHorizontalPosition = null;
				actualVerticalPosition = null;
				
				return;
			}
			
			var ownerBounds:Rectangle = owner.getBounds(systemManager.getSandboxRoot());
			
			// Use aspect ratio to determine vertical/horizontal preference
			var isLandscape:Boolean = (screen.width > screen.height);
			
			// Exterior space
			var exteriorSpaceLeft:Number = Math.max(0, ownerBounds.left);
			var exteriorSpaceRight:Number = Math.max(0, screen.width - ownerBounds.right);
			var exteriorSpaceTop:Number = Math.max(0, ownerBounds.top);
			var exteriorSpaceBottom:Number = Math.max(0, screen.height - ownerBounds.bottom);
			
			if (verticalPosition != CallOutPosition.AUTO)
			{
				// Horizontal auto only
				switch (verticalPosition)
				{
					case CallOutPosition.START:
					case CallOutPosition.MIDDLE:
					case CallOutPosition.END:
					{
						actualHorizontalPosition = (exteriorSpaceRight > exteriorSpaceLeft) ? CallOutPosition.AFTER : CallOutPosition.BEFORE;
						break;
					}
					default:
					{
						actualHorizontalPosition = CallOutPosition.MIDDLE;
						break;
					}
				}
				
				actualVerticalPosition = null;
			}
			else if (horizontalPosition != CallOutPosition.AUTO)
			{
				// Vertical auto only
				switch (horizontalPosition)
				{
					case CallOutPosition.START:
					case CallOutPosition.MIDDLE:
					case CallOutPosition.END:
					{
						actualVerticalPosition = (exteriorSpaceBottom > exteriorSpaceTop) ? CallOutPosition.AFTER : CallOutPosition.BEFORE;
						break;
					}
					default:
					{
						actualVerticalPosition = CallOutPosition.MIDDLE;
						break;
					}
				}
				
				actualHorizontalPosition = null;
			}
			else // if ((verticalPosition == CalloutPosition.AUTO) && (horizontalPosition == CalloutPosition.AUTO))
			{
				if (!isLandscape)
				{
					// Arrow will be vertical when in portrait
					actualHorizontalPosition = CallOutPosition.MIDDLE;
					actualVerticalPosition = (exteriorSpaceBottom > exteriorSpaceTop) ? CallOutPosition.AFTER : CallOutPosition.BEFORE;
				}
				else
				{
					// Arrow will be horizontal when in landscape
					actualHorizontalPosition = (exteriorSpaceRight > exteriorSpaceLeft) ? CallOutPosition.AFTER : CallOutPosition.BEFORE;
					actualVerticalPosition = CallOutPosition.MIDDLE;
				}
			}
		}
		
		/**
		 *  @private
		 *  Return true if user-specified max size if set
		 */
		mx_internal function get isMaxSizeSet():Boolean
		{
			var explicitMaxW:Number = super.explicitMaxWidth;
			var explicitMaxH:Number = super.explicitMaxHeight;
			
			return (!isNaN(explicitMaxW) && !isNaN(explicitMaxH));
		}
		
		/**
		 *  @private
		 *  Return the original height if the soft keyboard is active. This height
		 *  is used to stabilize AUTO positioning so that the position is based
		 *  on the original height of the Callout instead of a possibly shorter
		 *  height due to soft keyboard effects.
		 */
		mx_internal function get calloutHeight():Number
		{
			return (isSoftKeyboardEffectActive) ? softKeyboardEffectCachedHeight : getLayoutBoundsHeight();
		}
		
		/**
		 *  @private
		 *  Compute max width and max height. Uses the the owner and screen bounds 
		 *  as well as preferred positions to determine max width and max height  
		 *  for all possible exterior and interior positions.
		 */
		mx_internal function commitMaxSize():void
		{
			var ownerBounds:Rectangle = owner.getBounds(systemManager.getSandboxRoot());
			var ownerLeft:Number = ownerBounds.left;
			var ownerRight:Number = ownerBounds.right;
			var ownerTop:Number = ownerBounds.top;
			var ownerBottom:Number = ownerBounds.bottom;
			var maxW:Number;
			var maxH:Number;
			
			switch (actualHorizontalPosition)
			{
				case CallOutPosition.MIDDLE:
				{
					// Callout matches screen width
					maxW = screen.width - (margin * 2);
					break;
				}
				case CallOutPosition.START:
				case CallOutPosition.END:
				{
					// Flip left and right when using inner positions
					ownerLeft = ownerBounds.right;
					ownerRight = ownerBounds.left;
					
					// Fall through
				}
				default:
				{
					// Maximum is the larger of the actual position or flipped position
					maxW = Math.max(ownerLeft, screen.right - ownerRight) - margin;
					break;
				}
			}
			
			// If preferred position was AUTO, then allow maxWidth to grow to
			// fit the interior position if the owner is wide
			if ((horizontalPosition == CallOutPosition.AUTO) &&
				(ownerBounds.width > maxW))
				maxW += ownerBounds.width;
			
			switch (actualVerticalPosition)
			{
				case CallOutPosition.MIDDLE:
				{
					// Callout matches screen height
					maxH = screen.height - (margin * 2);
					break;
				}
				case CallOutPosition.START:
				case CallOutPosition.END:
				{
					// Flip top and bottom when using inner positions
					ownerTop = ownerBounds.bottom;
					ownerBottom = ownerBounds.top;
					
					// Fall through
				}
				default:
				{
					// Maximum is the larger of the actual position or flipped position
					maxH = Math.max(ownerTop, screen.bottom - ownerBottom) - margin;
					break;
				}
			}
			
			// If preferred position was AUTO, then allow maxHeight to grow to
			// fit the interior position if the owner is tall
			if ((verticalPosition == CallOutPosition.AUTO) && 
				(ownerBounds.height > maxH))
				maxH += ownerBounds.height;
			
			calloutMaxWidth = maxW;
			calloutMaxHeight = maxH;
		}
		
		/**
		 *  @private
		 */
		mx_internal function determineArrowPosition(horizontalPos:String, verticalPos:String):String
		{
			// Determine arrow direction, outer positions get priority.
			// Corner positions and center show no arrow
			var direction:String = ArrowDirection.NONE;
			
			if (horizontalPos == CallOutPosition.BEFORE)
			{
				if ((verticalPos != CallOutPosition.BEFORE)
					&&  (verticalPos != CallOutPosition.AFTER))
				{
					direction = ArrowDirection.RIGHT;
				}
			}
			else if (horizontalPos == CallOutPosition.AFTER)
			{
				if ((verticalPos != CallOutPosition.BEFORE)
					&& (verticalPos != CallOutPosition.AFTER))
				{
					direction = ArrowDirection.LEFT;
				}
			}
			else if (verticalPos == CallOutPosition.BEFORE)
			{
				direction = ArrowDirection.DOWN;
			}
			else if (verticalPos == CallOutPosition.AFTER)
			{
				direction = ArrowDirection.UP;
			}
			else if (horizontalPos == CallOutPosition.START)
			{
				direction = ArrowDirection.LEFT;
			}
			else if (horizontalPos == CallOutPosition.END)
			{
				direction = ArrowDirection.RIGHT;
			}
			else if (verticalPos == CallOutPosition.START)
			{
				direction = ArrowDirection.UP;
			}
			else if (verticalPos == CallOutPosition.END)
			{
				direction = ArrowDirection.DOWN;
			}
			
			return direction
		}
		
		/**
		 *  @private
		 * 
		 *  Uses horizontalPosition and verticalPosition to determine the bounds of
		 *  the callout.
		 */
		mx_internal function determinePosition(horizontalPos:String, verticalPos:String, matrix:Matrix, registrationPoint:Point):Rectangle
		{
			var ownerVisualElement:ILayoutElement = owner as ILayoutElement;
			var ownerWidth:Number = (ownerVisualElement) ? ownerVisualElement.getLayoutBoundsWidth() : owner.width;
			var ownerHeight:Number = (ownerVisualElement) ? ownerVisualElement.getLayoutBoundsHeight() : owner.height;
			var calloutWidth:Number = getLayoutBoundsWidth();
			var calloutHeight:Number = this.calloutHeight;
			
			/*
			var arrowWidth:Number	= arrow.arrowWidth();
			var arrowHeight:Number	= arrow.arrowHeight();
			*/
			switch (horizontalPos)
			{
				case CallOutPosition.BEFORE:
				{
					// The full width of the callout is before the owner
					// All arrow directions are ArrowDirection.RIGHT x=(width - arrow.width)
					registrationPoint.x = -calloutWidth;
					break;
				}
				case CallOutPosition.START:
				{
					// ArrowDirection.LEFT is at x=0
					registrationPoint.x = 0;
					break;
				}
				case CallOutPosition.END:
				{
					// The ends of the owner and callout are aligned
					registrationPoint.x = (ownerWidth - calloutWidth);
					break;
				}
				case CallOutPosition.AFTER:
				{
					// The full width of the callout is after the owner
					// All arrow directions are ArrowDirection.LEFT (x=0)
					registrationPoint.x = ownerWidth;
					break;
				}
				default: // case CalloutPosition.MIDDLE:
				{
					registrationPoint.x = Math.floor((ownerWidth - calloutWidth) / 2);
					break;
				}
			}
			
			switch (verticalPos)
			{
				case CallOutPosition.BEFORE:
				{
					// The full height of the callout is before the owner
					// All arrow directions are ArrowDirection.DOWN y=(height - arrow.height)
					registrationPoint.y = -calloutHeight;
					break;
				}
				case CallOutPosition.START:
				{
					// ArrowDirection.UP is at y=0
					registrationPoint.y = 0;
					break;
				}
				case CallOutPosition.MIDDLE:
				{
					registrationPoint.y = Math.floor((ownerHeight - calloutHeight) / 2);
					break;
				}
				case CallOutPosition.END:
				{
					// The ends of the owner and callout are aligned
					registrationPoint.y = (ownerHeight - calloutHeight);
					break;
				}
				default: //case CalloutPosition.AFTER:
				{
					// The full height of the callout is after the owner
					// All arrow directions are ArrowDirection.UP (y=0)
					registrationPoint.y = ownerHeight;
					break;
				}
			}
			
			var topLeft:Point = registrationPoint.clone();
			var size:Point = MatrixUtil.transformBounds(calloutWidth, calloutHeight, matrix, topLeft);
			var bounds:Rectangle = new Rectangle();
			
			bounds.left = topLeft.x;
			bounds.top = topLeft.y;
			bounds.width = size.x;
			bounds.height = size.y;
			
			return bounds;
		}
		
		/**
		 * @private
		 */
		mx_internal function get isArrowVertical():Boolean
		{
			return (arrowDirection == ArrowDirection.UP ||
				arrowDirection == ArrowDirection.DOWN);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		/*
		private function arrow_resizeHandler(event:Event):void
		{
			//updateSkinDisplayList();
			arrow.invalidateSkinState();
		}
		*/
		/**
		 *  @private
		 */
		private function systemManager_resizeHandler(event:Event):void
		{
			// Remove explicit settings if due to Resize effect
			softKeyboardEffectResetExplicitSize();
			
			// Screen resize might require a new arrow direction and callout position
			invalidatePosition();
			
			if (!isSoftKeyboardEffectActive)
			{
				// Force validation and use new screen size only if the keyboard
				// effect is not active. The stage dimensions may be invalid while 
				// the soft keyboard is active. See SDK-31860.
				validateNow();
			}
		}
	}
}
