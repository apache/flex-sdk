////////////////////////////////////////////////////////////////////////////////
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////


package spark.components.supportClasses
{
import flash.geom.Point;

import mx.core.IUIComponent;
import mx.core.InteractionMode;
import mx.core.ScrollPolicy;
import mx.core.mx_internal;
import mx.utils.MatrixUtil;

import spark.components.Scroller;
import spark.core.IViewport;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 */
public class ScrollerLayout extends LayoutBase
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  SDT - Scrollbar Display Threshold.  If the content size exceeds the
     *  viewport's size by SDT, then we show a scrollbar.  For example, if the 
     *  contentWidth >= viewport width + SDT, show the horizontal scrollbar.
     */
    mx_internal static const SDT:Number = 1.0;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    public function ScrollerLayout()    
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------   

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
    //  canScrollHorizontally
    //----------------------------------  
    
    /**
     *  @private
     */
    private var _canScrollHorizontally:Boolean;
    
    /**
     *  @private
     *  Helper function to determine whether the viewport scrolls horizontally.
     * 
     *  <p>This is used for touch scrolling purposes to 
     *  determine if one can scroll horizontally.</p>
     * 
     *  <p>The value is set in updateDisplayList()</p>
     */
    mx_internal function get canScrollHorizontally():Boolean
    {
        return _canScrollHorizontally;
    }
    
    //----------------------------------
    //  canScrollVertically
    //----------------------------------  
    
    /**
     *  @private
     */
    private var _canScrollVertically:Boolean;
    
    /**
     *  @private
     *  Helper function to determine whether the viewport scrolls vertically.
     * 
     *  <p>This is used for touch scrolling purposes to 
     *  determine if one can scroll vertically.</p>
     * 
     *  <p>The value is set in updateDisplayList()</p>
     */
    mx_internal function get canScrollVertically():Boolean
    {
        return _canScrollVertically;
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
        if (!hsb || hsb.visible == value)
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
        
        // TODO (rfrishbe) (or hmuller): perhaps rather than setting scale to 0,
        // we should be adding/removing it from the display list
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
    private function hsbRequiredHeight():Number 
    {
        var scroller:Scroller = getScroller();
        var minViewportInset:Number = scroller.minViewportInset;
        var hsb:ScrollBarBase = scroller.horizontalScrollBar;
        var sy:Number = (hsbVisible) ? 1 : hsbScaleY;
        return Math.max(minViewportInset, hsb.getPreferredBoundsHeight(hsbVisible) * sy);
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
            w -= vsb.getPreferredBoundsWidth();
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
        if (!vsb || vsb.visible == value)
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
    private function vsbRequiredWidth():Number 
    {
        var scroller:Scroller = getScroller();
        var minViewportInset:Number = scroller.minViewportInset;
        var vsb:ScrollBarBase = scroller.verticalScrollBar;
        var sx:Number = (vsbVisible) ? 1 : vsbScaleX;
        return Math.max(minViewportInset, vsb.getPreferredBoundsWidth(vsbVisible) * sx);
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
            h -= hsb.getPreferredBoundsHeight();
        }
        var vsb:ScrollBarBase = getScroller().verticalScrollBar;  
        return (w >= vsb.getPreferredBoundsWidth()) && (h >= vsb.getMinBoundsHeight());
    }
    
	
	
    //--------------------------------------------------------------------------
    //
    //  Overidden Methods
    //
    //--------------------------------------------------------------------------
    
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
        const measuredSizeIncludesScrollBars:Boolean = scroller.measuredSizeIncludesScrollBars && (scroller.getStyle("interactionMode") == InteractionMode.MOUSE);

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
        
        measuredH += (showHSB) ? hsbRequiredHeight() : minViewportInset;
        measuredW += (showVSB) ? vsbRequiredWidth() : minViewportInset;

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
        var hsbTakeUpSpace:Boolean = true; // if visible
        switch(scroller.getStyle("horizontalScrollPolicy")) 
        {
            case ScrollPolicy.ON: 
				_canScrollHorizontally = true;
                hsbVisible = true;
                break;

            case ScrollPolicy.AUTO: 
                if (viewport)
                {
                    hAuto = true;
					_canScrollHorizontally = (contentW >= (viewportW + SDT));
                    hsbVisible = (hsb && _canScrollHorizontally);
                } 
                break;
            
            default:
				_canScrollHorizontally = false;
                hsbVisible = false;
        }

        var vAuto:Boolean = false;
        var vsbTakeUpSpace:Boolean = true; // if visible
        switch(scroller.getStyle("verticalScrollPolicy")) 
        {
           case ScrollPolicy.ON: 
                _canScrollVertically = true;
                vsbVisible = true;
                break;

            case ScrollPolicy.AUTO: 
                if (viewport)
                { 
                    vAuto = true;
					_canScrollVertically = (contentH >= (viewportH + SDT));
                    vsbVisible = (vsb && _canScrollVertically);
                }                        
                break;
            
            default:
                _canScrollVertically = false;
                vsbVisible = false;
        }
        
        // if in touch mode, only show scrollbars if a scroll is currently in progress
        if (scroller.getStyle("interactionMode") == InteractionMode.TOUCH)
        {
            hsbTakeUpSpace = false;
            hsbVisible = scroller.horizontalScrollInProgress;
            
            vsbTakeUpSpace = false;
            vsbVisible = scroller.verticalScrollInProgress;
        }

        // Reset the viewport's width,height to account for the visible scrollbars, unless
        // the viewport's size was explicitly set, then we just use that. 
        
        if (isNaN(explicitViewportW))
            viewportW = w - ((vsbVisible && vsbTakeUpSpace) ? (minViewportInset + vsbRequiredWidth()) : (minViewportInset * 2));
        else 
            viewportW = explicitViewportW;
        
        if (isNaN(explicitViewportH))
            viewportH = h - ((hsbVisible && hsbTakeUpSpace) ? (minViewportInset + hsbRequiredHeight()) : (minViewportInset * 2));
        else 
            viewportH = explicitViewportH;

        // If the scrollBarPolicy is auto, and we're only showing one scrollbar, 
        // the viewport may have shrunk enough to require showing the other one.
        
        var hsbIsDependent:Boolean = false;
        var vsbIsDependent:Boolean = false;
        
        if (vsbVisible && !hsbVisible && hAuto && (contentW >= (viewportW + SDT)))
            hsbVisible = hsbIsDependent = _canScrollHorizontally = true;
        else if (!vsbVisible && hsbVisible && vAuto && (contentH >= (viewportH + SDT)))
            vsbVisible = vsbIsDependent = _canScrollVertically = true;

        // If the HSB doesn't fit, hide it and give the space back.   Likewise for VSB.
        // If both scrollbars are supposed to be visible but they don't both fit, 
        // then prefer to show the "non-dependent" auto scrollbar if we added the second
        // "dependent" auto scrollbar because of the space consumed by the first.
        
        if ((hsbVisible && hsbTakeUpSpace) && (vsbVisible && vsbTakeUpSpace)) 
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
        else if (hsbVisible && hsbTakeUpSpace && !hsbFits(w, h))  // just trying to show HSB, but it doesn't fit
            hsbVisible = false;
        else if (vsbVisible && vsbTakeUpSpace && !vsbFits(w, h))  // just trying to show VSB, but it doesn't fit
            vsbVisible = false;
        
        // if the only reason for showing one particular scrollbar was because the 
        // other scrollbar was visible, and we're now not showing the other scrollbar, 
        // then there's no need to allow scrolling in that direction anymore.
        if (hsbIsDependent && !vsbVisible)
            _canScrollHorizontally = false;
        if (vsbIsDependent && !hsbVisible)
            _canScrollVertically = false;
        
        // Reset the viewport's width,height to account for the visible scrollbars, unless
        // the viewport's size was explicitly set, then we just use that.
        
        if (isNaN(explicitViewportW))
            viewportW = w - ((vsbVisible && vsbTakeUpSpace) ? (minViewportInset + vsbRequiredWidth()) : (minViewportInset * 2));
        else 
            viewportW = explicitViewportW;

        if (isNaN(explicitViewportH))
            viewportH = h - ((hsbVisible && hsbTakeUpSpace) ? (minViewportInset + hsbRequiredHeight()) : (minViewportInset * 2));
        else 
            viewportH = explicitViewportH;
        
        // Layout the viewport and scrollbars.

        if (viewport)
        {
            viewport.setLayoutBoundsSize(viewportW, viewportH);
            viewport.setLayoutBoundsPosition(minViewportInset, minViewportInset);
        }
        
        if (hsbVisible)
        {
			var hsbH:Number = hsb.getPreferredBoundsHeight();
            var hsbW:Number = vsbVisible ? w - vsb.getPreferredBoundsWidth() : w;
            hsb.setLayoutBoundsSize(Math.max(hsb.getMinBoundsWidth(), hsbW), hsbH);
            
			hsb.setLayoutBoundsPosition(0, h - hsbH);
        }

        if (vsbVisible)
        {
            var vsbW:Number = vsb.getPreferredBoundsWidth(); 
            var vsbH:Number = hsbVisible ? h - hsb.getPreferredBoundsHeight() : h;
			vsb.setLayoutBoundsSize(vsbW, Math.max(vsb.getMinBoundsHeight(), vsbH));
			
			vsb.setLayoutBoundsPosition(w - vsbW, 0);
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

}

}
