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
import mx.core.ScrollPolicy;

import spark.components.Scroller;
import spark.core.IViewport;
import spark.layout.supportClasses.LayoutBase;

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
            
        var measuredW:Number = 0;
        var measuredH:Number = 0;
        var minW:Number = 0;
        var minH:Number = 0;            
        
        var viewport:IViewport = scroller.viewport;
        if (viewport)
        {
            var viewportElt:ILayoutElement = ILayoutElement(viewport);
            measuredW = viewportElt.getPreferredBoundsWidth();
            measuredH = viewportElt.getPreferredBoundsHeight();
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
            measuredH += hsb.getPreferredBoundsHeight();
            minW += hsb.getMinBoundsWidth();              
            minH += hsb.getMinBoundsHeight();  
        }
        if (showVSB)
        {
            measuredW += vsb.getPreferredBoundsWidth();
            minW += vsb.getMinBoundsWidth();
            minH += vsb.getMinBoundsHeight();
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
           
        // Decide which scrollbars will be visible
        var showHSB:Boolean = false;
        var hAuto:Boolean = false; 
        switch(scroller.horizontalScrollPolicy) {
            case ScrollPolicy.ON: 
                if (hsb) showHSB = true; 
                break;
            case ScrollPolicy.AUTO: 
                if (hsb && viewport)
                {
                    showHSB = viewport.contentWidth > w;
                    hAuto = true;
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
                    showVSB = viewport.contentHeight > h;
                    vAuto = true;
                }                        
                break;
        }
        
        // Shrink the viewport's width,height for the visible scrollbars
        var viewportH:Number = h;
        var hsbH:Number = 0;
        if (showHSB) 
        {
            hsbH = hsb.getPreferredBoundsHeight();
            viewportH -= hsbH;
        }
        var viewportW:Number = w;
        var vsbW:Number = 0;
        if (showVSB) 
        {
            vsbW = vsb.getPreferredBoundsWidth();
            viewportW -= vsbW;
        }
        
        // If the scrollBarPolicy is auto, and we're only showing one scrollbar, 
        // the viewport may have shrunk enough to require showing the other one.
        
        if (showVSB && !showHSB && hAuto && (viewport.contentWidth > viewportW))
        {
            showHSB = true;
            hsbH = hsb.getPreferredBoundsHeight();                
            viewportH -= hsbH;
        }
        else if (!showVSB && showHSB && vAuto && (viewport.contentHeight > viewportH))
        {
            showVSB = true;
            vsbW = vsb.getPreferredBoundsWidth();                
            viewportW -= vsbW;
        }

        // layout the viewport
        if (viewport)
        {
            var viewportElt:ILayoutElement = ILayoutElement(viewport);
            viewportElt.setLayoutBoundsSize(viewportW, viewportH);
            viewportElt.setLayoutBoundsPosition(0,0);
        }
        
        // layout the scrollbars
        if (hsb) hsb.visible = showHSB;
        if (showHSB)
        {
            hsb.setLayoutBoundsSize(Math.max(hsb.getMinBoundsWidth(), viewportW), hsbH);
            hsb.setLayoutBoundsPosition(0, h - hsbH);
        }
        if (vsb) vsb.visible = showVSB;
        if (showVSB)
        {
            vsb.setLayoutBoundsSize(vsbW, Math.max(vsb.getMinBoundsHeight(), viewportH));
            vsb.setLayoutBoundsPosition(w - vsbW, 0);
        }
        
        target.setContentSize(w, h);
    }

}

}