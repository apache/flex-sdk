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

import mx.core.IInvalidating;
import mx.core.IUIComponent;
import mx.core.ScrollPolicy;
import mx.utils.MatrixUtil;

import spark.components.Scroller;
import spark.core.IViewport;
import spark.layouts.supportClasses.LayoutBase;

[ExcludeClass]

/**
 *  @private
 */
public class ScrollerLayout extends LayoutBase
{
    public function ScrollerLayout()    
    {
        super();
    }

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
        if ((cw == 0) && (ch == 0))
            return new Point(0,0);
        return MatrixUtil.transformSize(new Point(cw, ch), viewport.getLayoutMatrix());
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
        var hsb:ScrollBar = getScroller().horizontalScrollBar;
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
        var hsb:ScrollBar = getScroller().horizontalScrollBar;
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
     *  Return true if the specified dimensions provide enough space to layout 
     *  the horizontal scrollbar (hsb) at its minimum size.   The HSB is assumed 
     *  to be non-null and visible.
     */
    private function hsbFits(w:Number, h:Number):Boolean
    {
        if (vsbVisible)
        {
            var vsb:ScrollBar = getScroller().verticalScrollBar;            
            w -= vsb.getPreferredBoundsWidth();
            h -= vsb.getMinBoundsHeight();
        }
        var hsb:ScrollBar = getScroller().horizontalScrollBar;        
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
        var vsb:ScrollBar = getScroller().verticalScrollBar;
        return vsb && vsb.visible;
    }
    
    /**
     *  @private
     *  The logic here is the same as for the horizontal scrollbar, see above.
     */
    private function set vsbVisible(value:Boolean):void
    {
        var vsb:ScrollBar = getScroller().verticalScrollBar;
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
     *  Return true if the specified dimensions provide enough space to layout 
     *  the vertical scrollbar (vsb) at its minimum size.   The VSB is assumed 
     *  to be non-null and visible.
     */
    private function vsbFits(w:Number, h:Number):Boolean
    {
        if (hsbVisible)
        {
            var hsb:ScrollBar = getScroller().horizontalScrollBar;            
            w -= hsb.getMinBoundsWidth();
            h -= hsb.getPreferredBoundsHeight();
        }
        var vsb:ScrollBar = getScroller().verticalScrollBar;  
        return (w >= vsb.getPreferredBoundsWidth()) && (h >= vsb.getMinBoundsHeight());
    }
        
    /**
     * @private
     *  Computes the union of the preferred size of the visible 
     *  scrollbars and the viewport.  
     * 
     *  This becomes the ScrollerSkin's measuredWidth,Height.
     *    
     *  The ScrollerSkin's minimum size is only big enough to 
     *  acccomodate the visible scrollbars.
     * 
     *  The viewport does not contribute to the minimum size unless its
     *  explicit size has been set.
     */
    override public function measure():void
    {
        var scroller:Scroller = getScroller();
        if (!scroller) 
            return;
            
        var minViewportInset:Number = scroller.minViewportInset;
        var measuredW:Number = minViewportInset;
        var measuredH:Number = minViewportInset;
        
        var hsb:ScrollBar = scroller.horizontalScrollBar;
        var showHSB:Boolean = false;
        var hAuto:Boolean = false;
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

        var vsb:ScrollBar = scroller.verticalScrollBar;
        var showVSB:Boolean = false;
        var vAuto:Boolean = false;
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
        
        if (showHSB)
            measuredH += Math.max(minViewportInset, hsb.getPreferredBoundsHeight());
        else
            measuredH += minViewportInset;

        if (showVSB)
            measuredW += Math.max(minViewportInset, vsb.getPreferredBoundsWidth());
        else
            measuredW += minViewportInset;

        // The measured size of the viewport is just its preferredBounds, except:
        // don't give up space if doing so would make an auto scrollbar visible.
        // In other words, if an auto scrollbar isn't already showing, and using
        // the preferred size would force it to show, and the current size would not,
        // then use its current size as the measured size.

        var viewport:IViewport = scroller.viewport;
        if (viewport)
        {
            var contentSize:Point = getLayoutContentSize(viewport);

            var viewportPreferredW:Number =  viewport.getPreferredBoundsWidth();
            var viewportContentW:Number = contentSize.x;
            var viewportW:Number = viewport.getLayoutBoundsWidth();  // "current" size
            var currentSizeNoHSB:Boolean = !isNaN(viewportW) && (viewportW >= viewportContentW);
            if (hAuto && !showHSB && (viewportPreferredW < viewportContentW) && currentSizeNoHSB)
                measuredW += viewportW;
            else
                measuredW += Math.max(viewportPreferredW, (showHSB) ? hsb.getMinBoundsWidth() : 0);

            var viewportPreferredH:Number = viewport.getPreferredBoundsHeight();
            var viewportContentH:Number = contentSize.y;
            var viewportH:Number = viewport.getLayoutBoundsHeight();  // "current" size
            var currentSizeNoVSB:Boolean = !isNaN(viewportH) && (viewportH >= viewportContentH);
            if (vAuto && !showVSB && (viewportPreferredH < viewportContentH) && currentSizeNoVSB)
                measuredH += viewportH;
            else
                measuredH += Math.max(viewportPreferredH, (showVSB) ? vsb.getMinBoundsHeight() : 0);
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
        var hsb:ScrollBar = scroller.horizontalScrollBar;
        var vsb:ScrollBar = scroller.verticalScrollBar;
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
        var viewportUIC:IUIComponent = viewport as IUIComponent;
        var explicitViewportW:Number = viewportUIC ? viewportUIC.explicitWidth : NaN;
        var explicitViewportH:Number = viewportUIC ? viewportUIC.explicitHeight : NaN;
        
        var oldShowHSB:Boolean = hsbVisible;
        var oldShowVSB:Boolean = vsbVisible;
        
        // Decide which scrollbars will be visible based on the viewport's content size
        // and the scroller's scroll policies.

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
                    var viewportW:Number = 
                        isNaN(explicitViewportW) ? (w - (minViewportInset * 2)) : explicitViewportW;
                    hsbVisible = (contentW > viewportW);
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
                    var viewportH:Number = 
                        isNaN(explicitViewportH) ? (h - (minViewportInset * 2)) : explicitViewportH;
                    vsbVisible = (contentH > viewportH);
                }                        
                break;

            default:
                vsbVisible = false;
        }

        // Shrink the viewport's width,height for the visible scrollbars
        
        viewportH = h - minViewportInset;
        if (hsbVisible)
            viewportH -= Math.max(minViewportInset, hsb.getPreferredBoundsHeight());
            
        viewportW = w - minViewportInset;
        if (vsbVisible)
            viewportW -= Math.max(minViewportInset, vsb.getPreferredBoundsWidth());
        
        // If the scrollBarPolicy is auto, and we're only showing one scrollbar, 
        // the viewport may have shrunk enough to require showing the other one.

        if (vsbVisible && !hsbVisible && hAuto && (contentW > viewportW))
        {
            hsbVisible = true;
            viewportH -= Math.max(minViewportInset, hsb.getPreferredBoundsHeight());
        }
        else if (!vsbVisible && hsbVisible && vAuto && (contentH > viewportH))
        {
            vsbVisible = true;
            viewportW -= Math.max(minViewportInset, vsb.getPreferredBoundsWidth());
        }

        // Factor in scrollBar-side viewportInsets where there aren't scrollbars

        if (!hsbVisible) 
            viewportH -= minViewportInset;

        if (!vsbVisible) 
            viewportW -= minViewportInset;
        
        // If the HSB doesn't fit, hide it and give the space back.   Likewise for VSB.
        // If both scrollbars are supposed to be visible but they don't both fit, 
        // then prefer to show just a VSB over just a HSB.
    
        if (hsbVisible && vsbVisible)
        {
            var hsbPreferredH:Number = hsb.getPreferredBoundsHeight();  
            var vsbPreferredW:Number = vsb.getPreferredBoundsWidth();

            if (!hsbFits(w, h))
                hsbVisible = false;

            if (!vsbFits(w, h))
            {
                vsbVisible = false;
                hsbVisible = true;
                if (!hsbFits(w, h))
                    hsbVisible = false;
            }

            if (!hsbVisible)
                viewportH += Math.max(minViewportInset, hsbPreferredH);
            if (!vsbVisible)
                viewportW += Math.max(minViewportInset, vsbPreferredW);
        }
        else if (hsbVisible && !hsbFits(w, h))
        {
            viewportH += Math.max(minViewportInset, hsb.getPreferredBoundsHeight());
            hsbVisible = false;
        }
        else if (vsbVisible && !vsbFits(w, h))
        {
            viewportW += Math.max(minViewportInset, vsb.getPreferredBoundsWidth());
            vsbVisible = false;
        }
        
        // Special case: viewport's size is explicitly set

        if (!isNaN(explicitViewportW)) 
            viewportW = explicitViewportW;

        if (!isNaN(explicitViewportH)) 
            viewportH = explicitViewportH;
        
        // Layout the viewport scrollbars.

        if (viewport)
        {
            viewport.setLayoutBoundsSize(viewportW, viewportH);
            viewport.setLayoutBoundsPosition(minViewportInset, minViewportInset);
        }
        
        if (hsbVisible)
        {
            var hsbW:Number = (vsbVisible) ? w - vsb.getPreferredBoundsWidth() : w;
            var hsbH:Number = hsb.getPreferredBoundsHeight();
            hsb.setLayoutBoundsSize(Math.max(hsb.getMinBoundsWidth(), hsbW), hsbH);
            hsb.setLayoutBoundsPosition(0, h - hsbH);
        }

        if (vsbVisible)
        {
            var vsbW:Number = vsb.getPreferredBoundsWidth(); 
            var vsbH:Number = (hsbVisible) ? h - hsb.getPreferredBoundsHeight() : h;
            vsb.setLayoutBoundsSize(vsbW, Math.max(vsb.getMinBoundsHeight(), vsbH));
            vsb.setLayoutBoundsPosition(w - vsbW, 0);
        }

        // If we've added an auto scrollbar, then the measured size is likely to have been wrong.
        // There's a risk of looping here, so we count.  
        if ((invalidationCount < 2) && (((vsbVisible != oldShowVSB) && vAuto) || ((hsbVisible != oldShowHSB) && hAuto)))
        {
            target.invalidateSize();
            invalidationCount += 1; 
        }
        else
            invalidationCount = 0;
             
        target.setContentSize(w, h);
    }

}

}
