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

package mx.layout
{

import flash.events.Event;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.ui.Keyboard;

import mx.components.baseClasses.GroupBase;
import mx.core.ScrollUnit;
import mx.layout.ILayoutItem;
import mx.utils.OnDemandEventDispatcher;


public class LayoutBase extends OnDemandEventDispatcher
{
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    internal static function hasPercentWidth(layoutItem:ILayoutItem):Boolean
    {
        return !isNaN( layoutItem.percentWidth );
    }
    
    internal static function hasPercentHeight(layoutItem:ILayoutItem):Boolean
    {
        return !isNaN( layoutItem.percentHeight );
    }

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    public function LayoutBase()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  target
    //----------------------------------    

    private var _target:GroupBase;
    
    /**
     *  The GroupBase whose layout we're responsible for.  
     *  
     *  The target is responsible for delegating the updateDisplayList()
     *  and measure() methods to its layout.
     * 
     *  @default null;
     *  @see #updateDisplayList
     *  @see #measure
     */
    public function get target():GroupBase
    {
        return _target;
    }
    
    /**
     * @private
     */
    public function set target(value:GroupBase):void
    {
        _target = value;
    }
    
    //----------------------------------
    //  horizontalScrollPosition
    //----------------------------------
        
    private var _horizontalScrollPosition:Number = 0;
    
    [Bindable]
    [Inspectable(category="General")]
    
    /**
     *  @copy flex.intf.IViewport#horizontalScrollPosition
     */
    public function get horizontalScrollPosition():Number 
    {
        return _horizontalScrollPosition;
    }
    
    /**
     *  @private
     */
    public function set horizontalScrollPosition(value:Number):void 
    {
        if (value == _horizontalScrollPosition) 
            return;
    
        _horizontalScrollPosition = value;
        scrollPositionChanged();
    }
    
    //----------------------------------
    //  verticalScrollPosition
    //----------------------------------

    private var _verticalScrollPosition:Number = 0;
    
    [Bindable]
    [Inspectable(category="General")]    
    
    /**
     *  @copy flex.intf.IViewport#verticalScrollPosition
     */
    public function get verticalScrollPosition():Number 
    {
        return _verticalScrollPosition;
    }
    
    /**
     *  @private
     */
    public function set verticalScrollPosition(value:Number):void 
    {
        if (value == _verticalScrollPosition)
            return;
            
        _verticalScrollPosition = value;
        scrollPositionChanged();
    }    
    
    //----------------------------------
    //  clipContent
    //----------------------------------
        
    private var _clipContent:Boolean = false;
    
    [Inspectable(category="General")]
    
    /**
     *  @copy flex.intf.IViewport#clipContent
     */
    public function get clipContent():Boolean 
    {
        return _clipContent;
    }
    
    /**
     *  @private
     */
    public function set clipContent(value:Boolean):void 
    {
        if (value == _clipContent) 
            return;
    
        _clipContent = value;
        var g:GroupBase = target;
        if (g)
            updateScrollRect(g.width, g.height);
    }
        

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @copy flex.intf.IViewport#horizontalScrollPositionDelta
     */
    public function getHorizontalScrollPositionDelta(unit:ScrollUnit):Number
    {
        var g:GroupBase = target;
        if (!g)
            return 0;     

        var maxIndex:int = g.numLayoutItems -1;
        if (maxIndex < 0)
            return 0;

        var scrollR:Rectangle = g.scrollRect;
        if (!scrollR)
            return 0;
            
        var maxDelta:Number = g.contentWidth - scrollR.width - scrollR.x;
        var minDelta:Number = -scrollR.x; 
            
        switch (unit)
        {
            case ScrollUnit.LEFT:
                return Math.max(-1, minDelta);
                
            case ScrollUnit.RIGHT:
                return Math.min(1, maxDelta);
                
            case ScrollUnit.PAGE_LEFT:
                return Math.max(minDelta, -scrollR.width);
                
            case ScrollUnit.PAGE_RIGHT:
                return Math.min(maxDelta, scrollR.width);
                
            case ScrollUnit.HOME: 
                return minDelta;
                
            case ScrollUnit.END: 
                return maxDelta;
                
            default:
                return 0;
        }       
    }
    
    /**
     *  @copy flex.intf.IViewport#verticalScrollPositionDelta
     */
    public function getVerticalScrollPositionDelta(unit:ScrollUnit):Number
    {
        var g:GroupBase = target;
        if (!g)
            return 0;     

        var maxIndex:int = g.numLayoutItems -1;
        if (maxIndex < 0)
            return 0;

        var scrollR:Rectangle = g.scrollRect;
        if (!scrollR)
            return 0;
            
        var maxDelta:Number = g.contentHeight - scrollR.height - scrollR.y;
        var minDelta:Number = -scrollR.y; 
            
        switch (unit)
        {
        	case ScrollUnit.UP:
        	    return Math.max(-1, minDelta);
        	    
        	case ScrollUnit.DOWN:
        	    return Math.min(1, maxDelta);
        	    
            case ScrollUnit.PAGE_UP:
                return Math.max(minDelta, -scrollR.height);
                
            case ScrollUnit.PAGE_DOWN:
                return Math.min(maxDelta, scrollR.height);
                
            case ScrollUnit.HOME: 
                return minDelta;
                
            case ScrollUnit.END: 
                return maxDelta;
                
            default:
                return 0;
        }    	
    }
    
    /**
     *  LayoutBase::getScrollPositionDelta() computes the
     *  vertical and horizontalScrollPosition deltas needed to 
     *  scroll the item at the specified index into view.
     * 
     *  If clipContent is true and the item at the specified index is not
     *  entirely visible relative to the target's scrollRect, then 
     *  return the delta to be added to horizontalScrollPosition and
     *  verticalScrollPosition that will scroll the item completely 
     *  within the scrollRect's bounds.
     * 
     *  If the specified item is partially visible and larger than the
     *  scrollRect, i.e. it's already the only item visible, then
     *  null is returned.
     * 
     *  This method attempts to minmimze the change to verticalScrollPosition
     *  and horizontalScrollPosition.
     * 
     *  If the specified index is invalid, or target is null, then
     *  null is returned.
     * 
     *  If the item at the specified index is null or includeInLayout
     *  false, then null is returned.
     * 
     *  @param index The index of the item to be scrolled into view.
     *  @return A Point that contains offsets to horizontalScrollPosition 
     *      and verticalScrollPosition that will scroll the specified
     *      item into view, or null if no change is needed. 
     * 
     *  @see clipContent
     *  @see verticalScrollPosition
     *  @see horizontalScrollPosition
     *  @see udpdateScrollRect
     */
     public function getScrollPositionDelta(index:int):Point
     {
         if (!target || !clipContent)
            return null;
            
         var n:int = target.numLayoutItems;
         if ((index < 0) || (index >= n))
            return null;
            
         var item:ILayoutItem = target.getLayoutItemAt(index);
         if (!item || !item.includeInLayout)
            return null;
            
         var scrollR:Rectangle = target.scrollRect;
         if (!scrollR)
            return null;
            
         var itemXY:Point = item.actualPosition;
         var itemWH:Point = item.actualSize;
         var itemR:Rectangle = new Rectangle(itemXY.x, itemXY.y, itemWH.x, itemWH.y);
         
         if (scrollR.containsRect(itemR) || itemR.containsRect(scrollR))
            return null;
            
         var dxl:Number = itemR.left - scrollR.left;     // left justify item
         var dxr:Number = itemR.right - scrollR.right;   // right justify item
         var dyt:Number = itemR.top - scrollR.top;       // top justify item
         var dyb:Number = itemR.bottom - scrollR.bottom; // bottom justify item
         
         // minimize the scroll
         var dx:Number = (Math.abs(dxl) < Math.abs(dxr)) ? dxl : dxr;
         var dy:Number = (Math.abs(dyt) < Math.abs(dyb)) ? dyt : dyb;
                 
         // scrollR "contains"  itemR in just one dimension
         if ((itemR.left >= scrollR.left) && (itemR.right <= scrollR.right))
            dx = 0;
         else if ((itemR.bottom >= scrollR.bottom) && (itemR.top <= scrollR.top))
            dy = 0;
            
         // itemR "contains" scrollR in just one dimension
         if ((itemR.left <= scrollR.left) && (itemR.right >= scrollR.right))
            dx = 0;
         else if ((itemR.bottom <= scrollR.bottom) && (itemR.top >= scrollR.top))
            dy = 0;
            
         return new Point(dx, dy);
     }
     
    /**
     *  Called when the verticalScrollPosition or horizontalScrollPosition 
     *  properties change.
     * 
     *  Resets the target's scrollRect property by calling
     *  <code>updateScrollRect()</code>.
     * 
     *  Subclasses can override this method to compute other values that are
     *  based on the current scrollPosition or scrollRect.
     * 
     *  @see updateScrollRect
     */  
    protected function scrollPositionChanged():void
    {
        var g:GroupBase = target;
        if (!g)
            return;

        updateScrollRect(g.width, g.height);
    }
    
    /**
     *  If clipContent is true, sets the origin of the scrollRect to 
     *  verticalScrollPosition,horizontalScrollPosition and its width
     *  width,height to w,h (the target's unscaled width,height).
     * 
     *  If clipContent is false, sets the scrollRect to null.
     *  
     *  @param w The target's unscaled width.
     *  @param h The target's unscaled height.
     * 
     *  @see target
     *  @see flash.display.DisplayObject#scrollRect
     *  @see updateDisplayList
     */ 
    public function updateScrollRect(w:Number, h:Number):void
    {
        var g:GroupBase = target;
        if (!g)
            return;
            
        if (clipContent)
        {
            var hsp:Number = horizontalScrollPosition;
            var vsp:Number = verticalScrollPosition;
            g.scrollRect = new Rectangle(hsp, vsp, w, h);
        }
        else
            g.scrollRect = null;
    } 
    
    /**
     *  Convenience function for subclasses that invalidates the
     *  target's size and displayList if the target is non-null.
     * 
     *  @see mx.core.UIComponent#invalidateSize
     *  @see mx.core.UIComponent#invalidateDisplayList
     */
    protected function invalidateTargetSizeAndDisplayList():void
    {
        var g:GroupBase = target;
        if (!g)
            return;

        g.invalidateSize();
        g.invalidateDisplayList();
    }
    
    /**
     *  Convenience function for subclasses that invalidates the
     *  target's displayList if the target is non-null.
     * 
     *  @see mx.core.UIComponent#invalidateDisplayList
     */
    protected function invalidateTargetDisplayList():void
    {
        var g:GroupBase = target;
        if (!g)
            return;

        g.invalidateDisplayList();
    }
    
    /**
     *  @copy mx.core.UIComponent#measure
     */
    public function measure():void
    {
    }
    
    /**
     *  @copy mx.core.UIComponent#updateDisplayList
     */
    public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
    }          
}

}
