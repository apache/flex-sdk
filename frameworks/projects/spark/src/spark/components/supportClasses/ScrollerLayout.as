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
     *  The viewport does not contribute to the minimum size.
     * 
     *  Note also: at updateDisplayList() time, we honor the vertical
     *  scrollbar's minimum height, and the horizontal scrollbar's 
     *  minimum width.  
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
        
        var hsb:ScrollBar = scroller.horizontalScrollBar;
        var showHSB:Boolean = false;
        switch(scroller.horizontalScrollPolicy) {
            case ScrollPolicy.ON: 
                if (hsb) showHSB = true; 
                break;
            case ScrollPolicy.AUTO: 
                if (hsb) showHSB = hsb.visible;  
                break;
        } 

        var vsb:ScrollBar = scroller.verticalScrollBar;
        var showVSB:Boolean = false;
        switch(scroller.verticalScrollPolicy) {
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
    
    /** 
     *  @private
     *  Arrange the viewport and scrollbars conventionally within
     *  the specified width and height: vertical scrollbar on the 
     *  right, horizontal scrollbar along the bottom.
     * 
     *  In other words, the Scroller's height will not
     *  shrink below the vertical scrollbar's minimum height, and its
     *  width will not shrink below the horizontal scrollbar's
     *  minimum width.
     * 
     *  The scrollbars are made visible if the viewport's content size is
     *  bigger than the actual size.
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
        
        var oldShowHSB:Boolean = hsb && hsb.visible;
        var oldShowVSB:Boolean = vsb && vsb.visible;
        
        // If the viewport's size has been explicitly set (not typical) then use it 
        var viewportUIC:IUIComponent = viewport as IUIComponent;
        var explicitViewportW:Number = viewportUIC ? viewportUIC.explicitWidth : NaN;
        var explicitViewportH:Number = viewportUIC ? viewportUIC.explicitHeight : NaN;
        
        // Decide which scrollbars will be visible based on the viewport's content size
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
                    var contentWidth:Number = viewport.contentWidth;
                    if (isNaN(explicitViewportW))
                        showHSB = contentWidth > (w - (minViewportInset * 2));
                    else
                        showHSB = contentWidth > explicitViewportW; 
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
                    var contentHeight:Number = viewport.contentHeight;
                    if (isNaN(explicitViewportH))
                        showVSB = contentHeight > (h - (minViewportInset * 2));
                    else
                        showVSB = contentHeight >  explicitViewportH;
                }                        
                break;
        }
        
        // Shrink the viewport's width,height for the visible scrollbars
        var viewportH:Number = h - minViewportInset;
        var hsbH:Number = 0;
        if (showHSB) 
        {
            hsbH = hsb.getPreferredBoundsHeight();
            viewportH -= Math.max(minViewportInset, hsbH);
        }
        var viewportW:Number = w - minViewportInset;
        var vsbW:Number = 0;
        if (showVSB) 
        {
            vsbW = vsb.getPreferredBoundsWidth();
            viewportW -= Math.max(minViewportInset, vsbW);
        }
        
        // If the scrollBarPolicy is auto, and we're only showing one scrollbar, 
        // the viewport may have shrunk enough to require showing the other one.
        if (showVSB && !showHSB && hAuto && (viewport.contentWidth > viewportW))
        {
            showHSB = true;
            hsbH = hsb.getPreferredBoundsHeight();                
            viewportH -= Math.max(minViewportInset, hsbH);
        }
        else if (!showVSB && showHSB && vAuto && (viewport.contentHeight > viewportH))
        {
            showVSB = true;
            vsbW = vsb.getPreferredBoundsWidth();                
            viewportW -= Math.max(minViewportInset, vsbW);
        }
        
        // Factor in scrollBar-side viewportInsets where there aren't scrollbars
        if (!showHSB)
            viewportH -= minViewportInset;
        if (!showVSB)
            viewportW -= minViewportInset;
            
        // Unless the viewport's size is explicitly set and larger than the
        // available space, the scrollbar's size will match the viewport's.
        var hsbW:Number = viewportW;  
        var vsbH:Number = viewportH;
        
        // Special case: viewport's size is explicitly set
        if (!isNaN(explicitViewportW))
        {
            viewportW = explicitViewportW;
            hsbW = Math.min(hsbW, viewportW);
        }
        if (!isNaN(explicitViewportH))
        {
            viewportH = explicitViewportH;
            vsbH = Math.min(vsbH, viewportH);
        }
        
        // layout the viewport
        if (viewport)
        {
            var viewportElt:ILayoutElement = ILayoutElement(viewport);
            viewportElt.setLayoutBoundsSize(viewportW, viewportH);
            viewportElt.setLayoutBoundsPosition(minViewportInset, minViewportInset);
        }
        
        // layout the scrollbars
        if (hsb) hsb.visible = showHSB;
        if (showHSB)
        {
            hsb.setLayoutBoundsSize(Math.max(hsb.getMinBoundsWidth(), hsbW), hsbH);
            hsb.setLayoutBoundsPosition(minViewportInset, h - Math.max(minViewportInset, hsbH));
        }
        if (vsb) vsb.visible = showVSB;
        if (showVSB)
        {
            vsb.setLayoutBoundsSize(vsbW, Math.max(vsb.getMinBoundsHeight(), vsbH));
            vsb.setLayoutBoundsPosition(w - Math.max(minViewportInset, vsbW), minViewportInset);
        }
        
        // If the scroller's size isn't explicit and we've added a scrollbar, then
        // the measured size is likely to have been wrong.  
        if ((isNaN(target.explicitWidth) || isNaN(target.explicitHeight)) && 
            ((showVSB != oldShowVSB) || (showHSB != oldShowHSB)))
            target.invalidateSize();
             
        target.setContentSize(w, h);
    }

}

}
