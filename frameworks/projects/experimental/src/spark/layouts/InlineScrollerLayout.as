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
	import flash.geom.Point;
	
	import mx.core.IUIComponent;
	import mx.core.ScrollPolicy;
	import mx.utils.MatrixUtil;
	
	import spark.components.Scroller;
	import spark.components.supportClasses.GroupBase;
	import spark.components.supportClasses.ScrollBarBase;
	import spark.components.supportClasses.Skin;
	import spark.core.IViewport;
	import spark.layouts.supportClasses.LayoutBase;
	import spark.layouts.supportClasses.LayoutElementHelper;
	
	[ExcludeClass]
	
	/**
	 *  @private
	 */
	public class InlineScrollerLayout extends LayoutBase
	{
		public function InlineScrollerLayout()    
		{
			super();
		}
		
		/**
		 *  @private
		 *  SDT - Scrollbar Display Threshold.  If the content size exceeds the
		 *  viewport's size by SDT, then we show a scrollbar.  For example, if the 
		 *  contentWidth >= viewport width + SDT, show the horizontal scrollbar.
		 */
		private static const SDT:Number = 1.0;
		
		/**
		 *  @private
		 *  Used by updateDisplayList() to prevent looping.
		 */
		private var invalidationCount:int = 0;
		
		
		/**
		 *  @private
		 */
		private function getScroller():Scroller
		{
			var g:Skin = target as Skin;
			return (g && ("hostComponent" in g)) ? Object(g).hostComponent as Scroller : null;
		}
		
		/**
		 *  @private
		 *  Returns the viewport's content size transformed into the Scroller's coordiante
		 *  system.   This makes it possible to compare the viewport size (also reported
		 *  relative to the Scroller) and the content size when a transform has been applied
		 *  to the viewport.  See http://bugs.adobe.com/jira/browse/SDK-19702
		 */
		private function getLayoutContentSize(viewport:IViewport):Point
		{
			// TODO(hmuller):prefer to do nothing if transform doesn't change size, see UIComponent/nonDeltaLayoutMatrix()
			var cw:Number = viewport.contentWidth;
			var ch:Number = viewport.contentHeight;
			if (((cw == 0) && (ch == 0)) || (isNaN(cw) || isNaN(ch)))
				return new Point(0,0);
			return MatrixUtil.transformSize(cw, ch, viewport.getLayoutMatrix());
		}
		
		//----------------------------------
		//  hsbVisible
		//----------------------------------    
		
		private var hsbScaleX:Number = 1;
		private var hsbScaleY:Number = 1;
		
		/**
		 *  @private
		 */
		private function get hsbVisible():Boolean
		{
			var hsb:ScrollBarBase = getScroller().horizontalScrollBar;
			return hsb && hsb.visible;
		}
		
		/**
		 *  @private 
		 *  To make the scrollbars invisible to methods like getRect() and getBounds() 
		 *  as well as to methods based on them like hitTestPoint(), we set their scale 
		 *  to 0.  More info about this here: http://bugs.adobe.com/jira/browse/SDK-21540
		 */
		private function set hsbVisible(value:Boolean):void
		{
			var hsb:ScrollBarBase = getScroller().horizontalScrollBar;
			if (!hsb)
				return;
			
			hsb.includeInLayout = hsb.visible = value;
			if (value)
			{
				if (hsb.scaleX == 0) 
					hsb.scaleX = hsbScaleX;
				if (hsb.scaleY == 0) 
					hsb.scaleY = hsbScaleY;
			}
			else 
			{
				if (hsb.scaleX != 0)
					hsbScaleX = hsb.scaleX;
				if (hsb.scaleY != 0)
					hsbScaleY = hsb.scaleY;
				hsb.scaleX = hsb.scaleY = 0;            
			}
		}
		
		/**
		 *  @private
		 *  Returns the vertical space required by the horizontal scrollbar.   
		 *  That's the larger of the minViewportInset and the hsb's preferred height.   
		 * 
		 *  Computing this value is complicated by the fact that if the HSB is currently 
		 *  hsbVisible=false, then it's scaleX,Y will be 0, and it's preferred size is 0.  
		 *  For that reason we specify postLayoutTransform=false to getPreferredBoundsHeight() 
		 *  and then multiply by the original scale factor, hsbScaleY.
		 */
//		private function hsbRequiredHeight():Number 
//		{
//			var scroller:Scroller = getScroller();
//			var minViewportInset:Number = scroller.minViewportInset;
//			var hsb:ScrollBarBase = scroller.horizontalScrollBar;
//			var sy:Number = (hsbVisible) ? 1 : hsbScaleY;
//			return Math.max(minViewportInset, hsb.getPreferredBoundsHeight(hsbVisible) * sy);
//		}
		private function hsbRequiredWidth():Number 
		{
			var scroller:Scroller = getScroller();
			var minViewportInset:Number = scroller.minViewportInset;
			var hsb:ScrollBarBase = scroller.horizontalScrollBar;
			var sx:Number = (hsbVisible) ? 1 : hsbScaleX;
//			return Math.max(minViewportInset, ( hsb.getPreferredBoundsWidth(hsbVisible) * 2 ) * sx);
			return Math.max(minViewportInset, hsb.getPreferredBoundsWidth(hsbVisible) * sx);
		}
		
		/**
		 *  @private
		 *  Return true if the specified dimensions provide enough space to layout 
		 *  the horizontal scrollbar (hsb) at its minimum size.   The HSB is assumed 
		 *  to be non-null and visible.
		 * 
		 *  If includeVSB is false we check to see if the HSB woudl fit if the 
		 *  VSB wasn't visible.
		 */
		private function hsbFits(w:Number, h:Number, includeVSB:Boolean=true):Boolean
		{
			if (vsbVisible && includeVSB)
			{
				var vsb:ScrollBarBase = getScroller().verticalScrollBar;            
//				w -= vsb.getPreferredBoundsWidth();
				h -= vsb.getMinBoundsHeight();
			}
			var hsb:ScrollBarBase = getScroller().horizontalScrollBar;        
			return (w >= hsb.getMinBoundsWidth()) && (h >= hsb.getPreferredBoundsHeight());
		}
		
		//----------------------------------
		//  vsbVisible
		//----------------------------------    
		
		private var vsbScaleX:Number = 1;
		private var vsbScaleY:Number = 1;
		
		/**
		 *  @private
		 */
		private function get vsbVisible():Boolean
		{
			var vsb:ScrollBarBase = getScroller().verticalScrollBar;
			return vsb && vsb.visible;
		}
		
		/**
		 *  @private
		 *  The logic here is the same as for the horizontal scrollbar, see above.
		 */
		private function set vsbVisible(value:Boolean):void
		{
			
			
			var vsb:ScrollBarBase = getScroller().verticalScrollBar;
			if (!vsb)
				return;
			
			vsb.includeInLayout = vsb.visible = value;
			if (value)
			{
				if (vsb.scaleX == 0) 
					vsb.scaleX = vsbScaleX;
				if (vsb.scaleY == 0) 
					vsb.scaleY = vsbScaleY;
			}
			else 
			{
				if (vsb.scaleX != 0)
					vsbScaleX = vsb.scaleX;
				if (vsb.scaleY != 0)
					vsbScaleY = vsb.scaleY;
				vsb.scaleX = vsb.scaleY = 0;            
			}
		}
		
		/**
		 *  @private
		 *  Returns the vertical space required by the horizontal scrollbar.   
		 *  That's the larger of the minViewportInset and the hsb's preferred height.  
		 *  
		 *  Computing this value is complicated by the fact that if the HSB is currently 
		 *  hsbVisible=false, then it's scaleX,Y will be 0, and it's preferred size is 0.  
		 *  For that reason we specify postLayoutTransform=false to getPreferredBoundsWidth() 
		 *  and then multiply by the original scale factor, vsbScaleX.
		 */
//		private function vsbRequiredWidth():Number 
//		{
//			var scroller:Scroller = getScroller();
//			var minViewportInset:Number = scroller.minViewportInset;
//			var vsb:ScrollBarBase = scroller.verticalScrollBar;
//			var sx:Number = (vsbVisible) ? 1 : vsbScaleX;
//			return Math.max(minViewportInset, vsb.getPreferredBoundsWidth(vsbVisible) * sx);
//		}
		private function vsbRequiredHeight():Number 
		{
			var scroller:Scroller = getScroller();
			var minViewportInset:Number = scroller.minViewportInset;
			var vsb:ScrollBarBase = scroller.verticalScrollBar;
			var sy:Number = (vsbVisible) ? 1 : vsbScaleY;

//			return Math.max(minViewportInset, ( vsb.getPreferredBoundsHeight(vsbVisible) * 2 ) * sy);
			return Math.max(minViewportInset, vsb.getPreferredBoundsHeight(vsbVisible) * sy);
		}
		
		/**
		 *  @private
		 *  Return true if the specified dimensions provide enough space to layout 
		 *  the vertical scrollbar (vsb) at its minimum size.   The VSB is assumed 
		 *  to be non-null and visible.
		 * 
		 *  If includeHSB is false, we check to see if the VSB would fit if the 
		 *  HSB wasn't visible.
		 */
		private function vsbFits(w:Number, h:Number, includeHSB:Boolean=true):Boolean
		{
			if (hsbVisible && includeHSB)
			{
				var hsb:ScrollBarBase = getScroller().horizontalScrollBar;            
				w -= hsb.getMinBoundsWidth();
//				h -= hsb.getPreferredBoundsHeight();
			}
			var vsb:ScrollBarBase = getScroller().verticalScrollBar;  
			return (w >= vsb.getPreferredBoundsWidth()) && (h >= vsb.getMinBoundsHeight());
		}
		
		/**
		 * @private
		 *  Computes the union of the preferred size of the visible scrollbars 
		 *  and the viewport if target.measuredSizeIncludesScrollbars=true, otherwise
		 *  it's just the preferred size of the viewport.
		 * 
		 *  This becomes the ScrollerSkin's measuredWidth,Height.
		 *    
		 *  The viewport does not contribute to the minimum size unless its
		 *  explicit size has been set.
		 */
		override public function measure():void
		{
			const scroller:Scroller = getScroller();
			if (!scroller) 
				return;
			
			const minViewportInset:Number = scroller.minViewportInset;
			const measuredSizeIncludesScrollBars:Boolean = scroller.measuredSizeIncludesScrollBars;
			
			var measuredW:Number = minViewportInset;
			var measuredH:Number = minViewportInset;
			
			const hsb:ScrollBarBase = scroller.horizontalScrollBar;
			var showHSB:Boolean = false;
			var hAuto:Boolean = false;
			if (measuredSizeIncludesScrollBars)
				switch(scroller.getStyle("horizontalScrollPolicy")) 
				{
					case ScrollPolicy.ON: 
						if (hsb) showHSB = true; 
						break;
					case ScrollPolicy.AUTO: 
						if (hsb) showHSB = hsb.visible;
						hAuto = true;
						break;
				} 
			
			const vsb:ScrollBarBase = scroller.verticalScrollBar;
			var showVSB:Boolean = false;
			var vAuto:Boolean = false;
			if (measuredSizeIncludesScrollBars)
				switch(scroller.getStyle("verticalScrollPolicy")) 
				{
					case ScrollPolicy.ON: 
						if (vsb) showVSB = true; 
						break;
					case ScrollPolicy.AUTO: 
						if (vsb) showVSB = vsb.visible;
						vAuto = true;
						break;
				}
			
			 measuredW += (showHSB) ? hsbRequiredWidth() : minViewportInset;
			 measuredH += (showVSB) ? vsbRequiredHeight() : minViewportInset;
			
			// The measured size of the viewport is just its preferredBounds, except:
			// don't give up space if doing so would make an auto scrollbar visible.
			// In other words, if an auto scrollbar isn't already showing, and using
			// the preferred size would force it to show, and the current size would not,
			// then use its current size as the measured size.  Note that a scrollbar
			// is only shown if the content size is greater than the viewport size 
			// by at least SDT.
			
			var viewport:IViewport = scroller.viewport;
			if (viewport)
			{
				if (measuredSizeIncludesScrollBars)
				{
					var contentSize:Point = getLayoutContentSize(viewport);
					
					var viewportPreferredW:Number =  viewport.getPreferredBoundsWidth();
					var viewportContentW:Number = contentSize.x;
					var viewportW:Number = viewport.getLayoutBoundsWidth();  // "current" size
					var currentSizeNoHSB:Boolean = !isNaN(viewportW) && ((viewportW + SDT) > viewportContentW);
					if (hAuto && !showHSB && ((viewportPreferredW + SDT) <= viewportContentW) && currentSizeNoHSB)
						measuredW += viewportW;
					else
						measuredW += Math.max(viewportPreferredW, (showHSB) ? hsb.getMinBoundsWidth() : 0);
					
					var viewportPreferredH:Number = viewport.getPreferredBoundsHeight();
					var viewportContentH:Number = contentSize.y;
					var viewportH:Number = viewport.getLayoutBoundsHeight();  // "current" size
					var currentSizeNoVSB:Boolean = !isNaN(viewportH) && ((viewportH + SDT) > viewportContentH);
					if (vAuto && !showVSB && ((viewportPreferredH + SDT) <= viewportContentH) && currentSizeNoVSB)
						measuredH += viewportH;
					else
						measuredH += Math.max(viewportPreferredH, (showVSB) ? vsb.getMinBoundsHeight() : 0);
				}
				else
				{
					measuredW += viewport.getPreferredBoundsWidth();
					measuredH += viewport.getPreferredBoundsHeight();
				}
			}
			
			var minW:Number = minViewportInset * 2;
			var minH:Number = minViewportInset * 2;
			
			// If the viewport's explicit size is set, then 
			// include that in the scroller's minimum size
			
			var viewportUIC:IUIComponent = viewport as IUIComponent;
			var explicitViewportW:Number = viewportUIC ? viewportUIC.explicitWidth : NaN;
			var explicitViewportH:Number = viewportUIC ? viewportUIC.explicitHeight : NaN;
			
			if (!isNaN(explicitViewportW)) 
				minW += explicitViewportW;
			
			if (!isNaN(explicitViewportH)) 
				minH += explicitViewportH;
			
			var g:GroupBase = target;
			g.measuredWidth = Math.ceil(measuredW);
			g.measuredHeight = Math.ceil(measuredH);
			g.measuredMinWidth = Math.ceil(minW); 
			g.measuredMinHeight = Math.ceil(minH);
		}
		
		/**
		 *  @return Returns the maximum value for an element's dimension so that the component doesn't
		 *  spill out of the container size. Calculations are based on the layout rules.
		 *  Pass in unscaledWidth, hCenter, left, right, childX to get a maxWidth value.
		 *  Pass in unscaledHeight, vCenter, top, bottom, childY to get a maxHeight value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		static private function maxSizeToFitIn(totalSize:Number,
											   center:Number,
											   lowConstraint:Number,
											   highConstraint:Number,
											   position:Number):Number
		{
			if (!isNaN(center))
			{
				// (1) x == (totalSize - childWidth) / 2 + hCenter
				// (2) x + childWidth <= totalSize
				// (3) x >= 0
				//
				// Substitue x in (2):
				// (totalSize - childWidth) / 2 + hCenter + childWidth <= totalSize
				// totalSize - childWidth + 2 * hCenter + 2 * childWidth <= 2 * totalSize
				// 2 * hCenter + childWidth <= totalSize se we get:
				// (3) childWidth <= totalSize - 2 * hCenter
				//
				// Substitute x in (3):
				// (4) childWidth <= totalSize + 2 * hCenter
				//
				// From (3) & (4) above we get:
				// childWidth <= totalSize - 2 * abs(hCenter)
				
				return totalSize - 2 * Math.abs(center);
			}
			else if (!isNaN(lowConstraint))
			{
				// childWidth + left <= totalSize
				return totalSize - lowConstraint;
			}
			else if (!isNaN(highConstraint))
			{
				// childWidth + right <= totalSize
				return totalSize - highConstraint;
			}
			else
			{
				// childWidth + childX <= totalSize
				return totalSize - position;
			}
		}
		
		/** 
		 *  @private
		 *  Arrange the viewport and scrollbars conventionally within
		 *  the specified width and height: vertical scrollbar on the 
		 *  right, horizontal scrollbar along the bottom.
		 * 
		 *  Scrollbars for which the corresponding scrollPolicy=auto 
		 *  are made visible if the viewport's content size is bigger 
		 *  than the actual size.   This introduces the possibility of
		 *  validateSize,DisplayList() looping because the measure() 
		 *  method computes the size of the viewport and the currently
		 *  visible scrollbars. 
		 * 
		 */
		override public function updateDisplayList(w:Number, h:Number):void
		{  
			
			var scroller:Scroller = getScroller();
			if (!scroller) 
				return;
			
			var viewport:IViewport = scroller.viewport;
			var hsb:ScrollBarBase = scroller.horizontalScrollBar;
			var vsb:ScrollBarBase = scroller.verticalScrollBar;
			var minViewportInset:Number = scroller.minViewportInset;
			
			var contentW:Number = 0;
			var contentH:Number = 0;
			if (viewport)
			{
				var contentSize:Point = getLayoutContentSize(viewport);
				contentW = contentSize.x;
				contentH = contentSize.y;
			}
			
			// If the viewport's size has been explicitly set (not typical) then use it
			// The initial values for viewportW,H are only used to decide if auto scrollbars
			// should be shown. 
			
			var viewportUIC:IUIComponent = viewport as IUIComponent;
			var explicitViewportW:Number = viewportUIC ? viewportUIC.explicitWidth : NaN;
			var explicitViewportH:Number = viewportUIC ? viewportUIC.explicitHeight : NaN;
			
			var viewportW:Number = isNaN(explicitViewportW) ? (w - (minViewportInset * 2)) : explicitViewportW;
			var viewportH:Number = isNaN(explicitViewportH) ? (h - (minViewportInset * 2)) : explicitViewportH;
			
			// Decide which scrollbars will be visible based on the viewport's content size
			// and the scroller's scroll policies.  A scrollbar is shown if the content size 
			// greater than the viewport's size by at least SDT.
			
			var oldShowHSB:Boolean = hsbVisible;
			var oldShowVSB:Boolean = vsbVisible;
			
			var hAuto:Boolean = false; 
			switch(scroller.getStyle("horizontalScrollPolicy")) 
			{
				case ScrollPolicy.ON: 
					hsbVisible = true;
					break;
				
				case ScrollPolicy.AUTO: 
					if (hsb && viewport)
					{
						hAuto = true;
						hsbVisible = (contentW >= (viewportW + SDT));
					} 
					break;
				
				default:
					hsbVisible = false;
			} 
			
			var vAuto:Boolean = false;
			switch(scroller.getStyle("verticalScrollPolicy")) 
			{
				case ScrollPolicy.ON: 
					vsbVisible = true; 
					break;
				
				case ScrollPolicy.AUTO: 
					if (vsb && viewport)
					{ 
						vAuto = true;
						vsbVisible = (contentH >= (viewportH + SDT));
					}                        
					break;
				
				default:
					vsbVisible = false;
			}
			
			// Reset the viewport's width,height to account for the visible scrollbars, unless
			// the viewport's size was explicitly set, then we just use that. 
			
			if (isNaN(explicitViewportW))
				viewportW = w - ((hsbVisible) ? (minViewportInset + hsbRequiredWidth()) : (minViewportInset * 2));
			else 
				viewportW = explicitViewportW;
			
			if (isNaN(explicitViewportH))
				viewportH = h - ((vsbVisible) ? (minViewportInset + vsbRequiredHeight()) : (minViewportInset * 2));
			else 
				viewportH = explicitViewportH;
			
			// If the scrollBarPolicy is auto, and we're only showing one scrollbar, 
			// the viewport may have shrunk enough to require showing the other one.
			
			var hsbIsDependent:Boolean = false;
			var vsbIsDependent:Boolean = false;
			
			if (vsbVisible && !hsbVisible && hAuto && (contentW >= (viewportW + SDT)))
				hsbVisible = hsbIsDependent = true;
			else if (!vsbVisible && hsbVisible && vAuto && (contentH >= (viewportH + SDT)))
				vsbVisible = vsbIsDependent = true;
			
			
			// If the HSB doesn't fit, hide it and give the space back.   Likewise for VSB.
			// If both scrollbars are supposed to be visible but they don't both fit, 
			// then prefer to show the "non-dependent" auto scrollbar if we added the second
			// "dependent" auto scrollbar because of the space consumed by the first.
			
			if (hsbVisible && vsbVisible) 
			{
				if (hsbFits(w, h) && vsbFits(w, h))
				{
					// Both scrollbars fit, we're done.
				}
				else if (!hsbFits(w, h, false) && !vsbFits(w, h, false))
				{
					// Neither scrollbar would fit, even if the other scrollbar wasn't visible.
					hsbVisible = false;
					vsbVisible = false;
				}
				else
				{
					// Only one of the scrollbars will fit.  If we're showing a second "dependent"
					// auto scrollbar because the first scrollbar consumed enough space to
					// require it, if the first scrollbar doesn't fit, don't show either of them.
					
					if (hsbIsDependent)
					{
						if (vsbFits(w, h, false))  // VSB will fit if HSB isn't shown   
							hsbVisible = false;
						else 
							vsbVisible = hsbVisible = false;
						
					}
					else if (vsbIsDependent)
					{
						if (hsbFits(w, h, false)) // HSB will fit if VSB isn't shown
							vsbVisible = false;
						else
							hsbVisible = vsbVisible = false; 
					}
					else if (vsbFits(w, h, false)) // VSB will fit if HSB isn't shown
						hsbVisible = false;
					else // hsbFits(w, h, false)   // HSB will fit if VSB isn't shown
						vsbVisible = false;
				}
			}
			else if (hsbVisible && !hsbFits(w, h))  // just trying to show HSB, but it doesn't fit
				hsbVisible = false;
			else if (vsbVisible && !vsbFits(w, h))  // just trying to show VSB, but it doesn't fit
				vsbVisible = false;
			
			// Reset the viewport's width,height to account for the visible scrollbars, unless
			// the viewport's size was explicitly set, then we just use that.
			
			if (isNaN(explicitViewportW))
				viewportW = w - ((hsbVisible) ? (minViewportInset + hsbRequiredWidth()) : (minViewportInset * 2));
			else 
				viewportW = explicitViewportW;
			
			if (isNaN(explicitViewportH))
				viewportH = h - ((vsbVisible) ? (minViewportInset + vsbRequiredHeight()) : (minViewportInset * 2));
			else 
				viewportH = explicitViewportH;
			
			// Layout the viewport and scrollbars.
			
			if (viewport)
			{
				viewport.setLayoutBoundsSize(viewportW, viewportH);
				viewport.setLayoutBoundsPosition( minViewportInset + ( ( w - viewportW ) / 2 ), minViewportInset + ( ( h - viewportH ) / 2 ) );
			}
			
			var center:Number;
			var bounds:Number;
			var startPosition:Number;
			var endPosition:Number;
			var size:Number;
			var position:Number;
			
			if (hsbVisible)
			{
//				hsb.setLayoutBoundsPosition( 0, ( h - viewportH ) / 2 );
//				hsb.setLayoutBoundsSize( Math.max( hsb.getMinBoundsWidth(), w ), viewportH );
				
				center = LayoutElementHelper.parseConstraintValue( hsb.verticalCenter );
				bounds = hsb.getLayoutBoundsY();
				startPosition = LayoutElementHelper.parseConstraintValue(hsb.top);
				endPosition = LayoutElementHelper.parseConstraintValue(hsb.bottom);
				size = getSize( center,
					bounds,
					startPosition,
					endPosition,
					hsb.percentHeight, viewportH,
					hsb.getMinBoundsHeight(), hsb.getMaxBoundsHeight() )
				
				hsb.setLayoutBoundsSize( Math.max( hsb.getMinBoundsWidth(), w ), size );
				
				position = getPosition( center, bounds,
					startPosition, endPosition,
					hsb.getLayoutBoundsHeight(), viewportH,
					h, minViewportInset );
				
				hsb.setLayoutBoundsPosition( 0, position );
//				var hsbW:Number = (vsbVisible) ? w - vsb.getPreferredBoundsWidth() : w;
//				var hsbH:Number = hsb.getPreferredBoundsHeight();
//				hsb.setLayoutBoundsSize(Math.max(hsb.getMinBoundsWidth(), w), hsbH);
//				hsb.setLayoutBoundsPosition(0, ( h - hsbH ) / 2);
			}
			
			if (vsbVisible)
			{
//				vsb.setLayoutBoundsPosition( ( w - viewportW ) / 2, 0 );
//				vsb.setLayoutBoundsSize( viewportW, Math.max( vsb.getMinBoundsHeight(), h ) );
				
				center = LayoutElementHelper.parseConstraintValue( vsb.horizontalCenter );
				bounds = vsb.getLayoutBoundsX();
				startPosition = LayoutElementHelper.parseConstraintValue(vsb.left);
				endPosition = LayoutElementHelper.parseConstraintValue(vsb.right);
				
				size = getSize( center,
					bounds,
					startPosition,
					endPosition,
					vsb.percentWidth, viewportW,
					vsb.getMinBoundsWidth(), vsb.getMaxBoundsWidth() );
					
				vsb.setLayoutBoundsSize( size, Math.max( vsb.getMinBoundsHeight(), h ) );
				
				position = getPosition( center, bounds,
					startPosition, endPosition,
					vsb.getLayoutBoundsWidth(), viewportW,
					w, minViewportInset );
				
				vsb.setLayoutBoundsPosition( position, 0 );
			}
			
			// If we've added an auto scrollbar, then the measured size is likely to have been wrong.
			// There's a risk of looping here, so we count.  
			if ((invalidationCount < 2) && (((vsbVisible != oldShowVSB) && vAuto) || ((hsbVisible != oldShowHSB) && hAuto)))
			{
				target.invalidateSize();
				
				// If the viewport's layout is virtual, it's possible that its
				// measured size changed as a consequence of laying it out,
				// so we invalidate its size as well.
				var viewportGroup:GroupBase = viewport as GroupBase;
				if (viewportGroup && viewportGroup.layout && viewportGroup.layout.useVirtualLayout)
					viewportGroup.invalidateSize();
				
				invalidationCount += 1; 
			}
			else
				invalidationCount = 0;
			
			target.setContentSize(w, h);
			
			
			
		}
		
		
		protected function getSize( center:Number, position:Number,
									startPositon:Number, endPosition:Number,
									percent:Number, viewportSize:Number,
									minBounds:Number, maxBounds:Number ):Number
		{
			var elementMax:Number = NaN; 
			
			// Calculate size
			var childSize:Number = NaN;
			
			if (!isNaN(percent))
			{
				var available:Number = viewportSize;
				if (!isNaN(startPositon))
					available -= startPositon;
				if (!isNaN(endPosition))
					available -= endPosition;
				
				childSize = Math.round(available * Math.min(percent * 0.01, 1));
				elementMax = Math.min(maxBounds,
					maxSizeToFitIn(viewportSize, center, startPositon, endPosition, position));
			}
			else if (!isNaN(startPositon) && !isNaN(endPosition))
			{
				childSize = viewportSize - endPosition - startPositon;
			}
			
			// Apply min and max constraints, make sure min is applied last. In the cases
			// where childSize and childHeight are NaN, setLayoutBoundsSize will use preferredSize
			// which is already constrained between min and max.
			if (!isNaN(childSize))
			{
				if (isNaN(elementMax))
					elementMax = maxBounds;
				childSize = Math.max(minBounds, Math.min(elementMax, childSize));
			}
			
			return childSize;
		}
		
		protected function getPosition( center:Number, position:Number,
											   startPositon:Number, endPosition:Number,
											   layoutBounds:Number, viewportSize:Number,
												unscaledSize:Number,
												minInset:Number ):Number
		{
			var childX:Number = NaN;
			
			// Horizontal position
			if (!isNaN(center))
				childX = Math.round( ( (viewportSize - layoutBounds) / 2 + center ) );
			else if (!isNaN(startPositon))
				childX = startPositon;
			else if (!isNaN(endPosition))
				childX = viewportSize - layoutBounds - endPosition;
			else
				childX = position;
			
			childX += minInset + ( ( unscaledSize - viewportSize ) / 2 );
			
			return childX;
		}
		
			
	}
	
	
}
