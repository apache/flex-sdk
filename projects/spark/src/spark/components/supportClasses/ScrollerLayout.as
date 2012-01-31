////////////////////////////////////////////////////////////////////////////////
//
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

import mx.core.ILayoutElement;
import mx.core.IUIComponent;
import mx.core.ScrollPolicy;

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
    
    private function getScroller():Scroller
    {
        var g:Skin = target as Skin;
        return (g && ("hostComponent" in g)) ? Object(g).hostComponent as Scroller : null;
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
        var minW:Number = minViewportInset;
        var minH:Number = minViewportInset;            
        
        var viewport:IViewport = scroller.viewport;
        if (viewport)
        {
            var viewportElt:ILayoutElement = ILayoutElement(viewport);
            measuredW += viewportElt.getPreferredBoundsWidth();
            measuredH += viewportElt.getPreferredBoundsHeight();
        }
        
        // If the viewport's explicit size is set, then 
        // include that in the scroller's minimum size
        var viewportUIC:IUIComponent = viewport as IUIComponent;
        var explicitViewportW:Number = viewportUIC ? viewportUIC.explicitWidth : NaN;
        var explicitViewportH:Number = viewportUIC ? viewportUIC.explicitHeight : NaN;
        if (!isNaN(explicitViewportW)) minW += explicitViewportW;
        if (!isNaN(explicitViewportH)) minH += explicitViewportH;
        
        var hsb:ScrollBar = scroller.horizontalScrollBar;
        var showHSB:Boolean = false;
        switch(scroller.horizontalScrollPolicy) 
        {
            case ScrollPolicy.ON: 
                if (hsb) showHSB = true; 
                break;
            case ScrollPolicy.AUTO: 
                if (hsb) showHSB = hsb.visible;
                break;
        } 

        var vsb:ScrollBar = scroller.verticalScrollBar;
        var showVSB:Boolean = false;
        switch(scroller.verticalScrollPolicy) 
        {
           case ScrollPolicy.ON: 
                if (vsb) showVSB = true; 
                break;
            case ScrollPolicy.AUTO: 
                if (vsb) showVSB = vsb.visible;
                break;
        }
        
        if (showHSB)
        {
            measuredH += Math.max(minViewportInset, hsb.getPreferredBoundsHeight());
            minW += hsb.getMinBoundsWidth();              
            minH += Math.max(minViewportInset, hsb.getMinBoundsHeight());  
        }
        else
        {
            measuredH += minViewportInset;
            minH += minViewportInset;
        }

        if (showVSB)
        {
            measuredW += Math.max(minViewportInset, vsb.getPreferredBoundsWidth());
            minW += Math.max(minViewportInset, vsb.getMinBoundsWidth());
            minH += vsb.getMinBoundsHeight();
        }
        else
        {
            measuredW += minViewportInset;
            minW += minViewportInset;
        }

        var g:GroupBase = target;
        g.measuredWidth = measuredW;
        g.measuredHeight = measuredH;
        g.measuredMinWidth = minW; 
        g.measuredMinHeight = minH;
    }
    
    // Used by updateDisplayList() to prevent looping, see below.
    private var invalidationCount:int = 0;
    
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
        
        var vsbW:Number = (vsb) ? vsb.getPreferredBoundsWidth() : 0;
        var hsbH:Number = (hsb) ? hsb.getPreferredBoundsHeight() : 0;
        var contentW:Number = (viewport) ? viewport.contentWidth : 0;
        var contentH:Number = (viewport) ? viewport.contentHeight : 0;
        
        var oldShowHSB:Boolean = hsb && hsb.visible;
        var oldShowVSB:Boolean = vsb && vsb.visible;
        
        // If the viewport's size has been explicitly set (not typical) then use it 
        var viewportUIC:IUIComponent = viewport as IUIComponent;
        var explicitViewportW:Number = viewportUIC ? viewportUIC.explicitWidth : NaN;
        var explicitViewportH:Number = viewportUIC ? viewportUIC.explicitHeight : NaN;
        
        // Decide which scrollbars will be visible based on the viewport's content size
        // See the method doc above for more information.

        var showHSB:Boolean = false;
        var hAuto:Boolean = false; 
        switch(scroller.horizontalScrollPolicy) {
            case ScrollPolicy.ON: 
                if (hsb) showHSB = true; 
                break;
            case ScrollPolicy.AUTO: 
                if (hsb && viewport)
                {
                    hAuto = true;
                    var viewportW:Number = 
                        isNaN(explicitViewportW) ? (w - (minViewportInset * 2)) : explicitViewportW;
                    showHSB = (contentW > viewportW) && (w >= hsb.minWidth);
                } 
                break;
        } 

        var showVSB:Boolean = false;
        var vAuto:Boolean = false;
        switch(scroller.verticalScrollPolicy) {
           case ScrollPolicy.ON: 
                if (vsb) showVSB = true; 
                break;
            case ScrollPolicy.AUTO: 
                if (vsb && viewport)
                { 
                    vAuto = true;
                    var viewportH:Number = 
                        isNaN(explicitViewportH) ? (h - (minViewportInset * 2)) : explicitViewportH;
                    showVSB = (contentH > viewportH) && (h >= vsb.minHeight);
                }                        
                break;
        }
        
        // Shrink the viewport's width,height for the visible scrollbars
        
        viewportH = h - minViewportInset;
        if (showHSB) viewportH -= Math.max(minViewportInset, hsbH);
            
        viewportW = w - minViewportInset;
        if (showVSB) viewportW -= Math.max(minViewportInset, vsbW);
        
        // If the scrollBarPolicy is auto, and we're only showing one scrollbar, 
        // the viewport may have shrunk enough to require showing the other one.
        // We only show the other scrollbar, if there's enough space for it.
        if (showVSB && !showHSB && hAuto && (contentW > viewportW))
        {
            viewportH -= Math.max(minViewportInset, hsbH);
            showHSB = w >= (hsb.minWidth + vsb.minWidth); 
        }
        else if (!showVSB && showHSB && vAuto && (contentH > viewportH))
        {
            viewportW -= Math.max(minViewportInset, vsbW);
            showVSB = h >= (hsb.minHeight + vsb.minHeight);
        }
        
        // Factor in scrollBar-side viewportInsets where there aren't scrollbars
        if (!showHSB) viewportH -= minViewportInset;
        if (!showVSB) viewportW -= minViewportInset;
            
        // Special case: viewport's size is explicitly set
        if (!isNaN(explicitViewportW)) viewportW = explicitViewportW;
        if (!isNaN(explicitViewportH)) viewportH = explicitViewportH;
        
        // layout the viewport
        if (viewport)
        {
            viewport.setLayoutBoundsSize(viewportW, viewportH);
            viewport.setLayoutBoundsPosition(minViewportInset, minViewportInset);
        }
        
        // layout the scrollbars

        if (hsb) hsb.includeInLayout = hsb.visible = showHSB;
        if (showHSB)
        {
            var hsbW:Number = (showVSB) ? w - vsbW : w;
            hsb.setLayoutBoundsSize(Math.max(hsb.getMinBoundsWidth(), hsbW), hsbH);
            hsb.setLayoutBoundsPosition(0, h - hsbH);
        }
        
        if (vsb) vsb.includeInLayout = vsb.visible = showVSB;
        if (showVSB)
        {
            var vsbH:Number = (showHSB) ? h - hsbH : h;
            vsb.setLayoutBoundsSize(vsbW, Math.max(vsb.getMinBoundsHeight(), vsbH));
            vsb.setLayoutBoundsPosition(w - vsbW, 0);
        }
        
        // If we've added an auto scrollbar, then the measured size is likely to have been wrong.
        // There's a risk of looping here, so we count.  
        if ((invalidationCount < 2) && (((showVSB != oldShowVSB) && vAuto) || ((showHSB != oldShowHSB) && hAuto)))
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
