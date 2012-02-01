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

import flash.geom.Point;
import flash.geom.Rectangle;

import mx.components.baseClasses.GroupBase;
import mx.core.ScrollUnit;
import mx.core.ILayoutElement;
import mx.utils.OnDemandEventDispatcher;


public class LayoutBase extends OnDemandEventDispatcher
{
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    internal static function hasPercentWidth(layoutElement:ILayoutElement):Boolean
    {
        return !isNaN(layoutElement.percentWidth);
    }
    
    internal static function hasPercentHeight(layoutElement:ILayoutElement):Boolean
    {
        return !isNaN(layoutElement.percentHeight);
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    //  useVirtualLayout
    //----------------------------------

    private var _useVirtualLayout:Boolean = false;

    [Inspectable(defaultValue="false")]

    /**
     *  If true, subclasses will be advised that when scrolling it's
     *  preferable to lazily create layout elements as they come into view,
     *  and to discard or recycle layout elements that are no longer in view.
     * 
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get useVirtualLayout():Boolean
    {
        return _useVirtualLayout;
    }

    /**
     *  @private
     */
    public function set useVirtualLayout(value:Boolean):void
    {
        if (_useVirtualLayout == value)
            return;

        _useVirtualLayout = value;
        if (target)
            target.invalidateDisplayList();
    }
    
    //----------------------------------
    //  horizontalScrollPosition
    //----------------------------------
        
    private var _horizontalScrollPosition:Number = 0;
    
    [Bindable]
    [Inspectable(category="General")]
    
    /**
     *  @copy flex.intf.IViewport#horizontalScrollPosition
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    //  clipAndEnableScrolling
    //----------------------------------
        
    private var _clipAndEnableScrolling:Boolean = false;
    
    [Inspectable(category="General")]
    
    /**
     *  @copy flex.intf.IViewport#clipAndEnableScrolling
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get clipAndEnableScrolling():Boolean 
    {
        return _clipAndEnableScrolling;
    }
    
    /**
     *  @private
     */
    public function set clipAndEnableScrolling(value:Boolean):void 
    {
        if (value == _clipAndEnableScrolling) 
            return;
    
        _clipAndEnableScrolling = value;
        var g:GroupBase = target;
        if (g)
            updateScrollRect(g.width, g.height);
    }
    
    //----------------------------------
    //  typicalLayoutElement
    //----------------------------------

    private var _typicalLayoutElement:ILayoutElement = null;

    /**
     *  Used by layouts when fixed row/column sizes are requested but
     *  a specific size isn't specified.
     * 
     *  Used by virtual layouts to estimate the size of layout elements
     *  that have not been scrolled into view.
     * 
     *  If this property has not been set and the target is non-null 
     *  then the target's first layout element is cached and returned.
     * 
     *  @default The target's first layout element.
     *  @see target
     *  @see DataGroup#typicalItem
     *  @see mx.layout.VerticalLayout#variableRowHeight
     *  @see mx.layout.HorizontalLayout#variableColumnWidth
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get typicalLayoutElement():ILayoutElement
    {
        if (!_typicalLayoutElement && target && (target.numElements > 0))
            _typicalLayoutElement = target.getElementAt(0);
        return _typicalLayoutElement;
    }

    /**
     *  @private
     *  Current implementation limitations:
     * 
     *  The default value of this property may be initialized
     *  lazily to layout element zero.  That means you can't rely on the
     *  set method being called to stay in sync with the property's value.
     * 
     *  If the default value is lazily initialized, it will not be reset if
     *  the target changes.
     */
    public function set typicalLayoutElement(value:ILayoutElement):void
    {
        if (_typicalLayoutElement == value)
            return;

        _typicalLayoutElement = value;
        var g:GroupBase = target;
        if (g)
            g.invalidateSize();
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Returns the bounds of the target's scrollRect in layout coordinates.
     * 
     *  Layout methods should not get the target's scrollRect directly.
     * 
     *  @return The bounds of the target's scrollRect in layout coordinates, null
     *      if target or clipAndEnableScrolling is false. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function getTargetScrollRect():Rectangle
    {
        var g:GroupBase = target;
        if (!g || !g.clipAndEnableScrolling)
            return null;     
        var vsp:Number = g.verticalScrollPosition;
        var hsp:Number = g.horizontalScrollPosition;
        return new Rectangle(hsp, vsp, g.width, g.height);
    }


    /**
     *  Returns the bounds of the first layout element that either spans or
     *  is to the left of the scrollRect's left edge.
     * 
     *  Used by the getHorizontalScrollPositionDelta() method.
     * 
     *  By default this method returns a Rectangle with width=1, height=0, 
     *  whose left edge is one less than the scrollRect's left edge, 
     *  and top=0.
     * 
     *  Subclasses should override this method to provide an accurate
     *  bounding rectangle that has valid <code>left</code> and 
     *  <code>right</code> properties.
     * 
     *  @param scrollRect The target's scrollRect.
     *  @return Returns the bounds of the first element that spans or is to
     *  the left of the scrollRect’s left edge.
     *  
     *  @see #elementBoundsRightOfScrollRect
     *  @see #elementBoundsAboveScrollRect
     *  @see #elementBoundsBelowScrollRect
     *  @see #getHorizontalScrollPositionDelta
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function elementBoundsLeftOfScrollRect(scrollRect:Rectangle):Rectangle
    {
        var bounds:Rectangle = new Rectangle();
        bounds.left = scrollRect.left - 1;
        bounds.right = scrollRect.left; 
        return bounds;
    } 

    /**
     *  Returns the bounds of the first layout element that either spans or
     *  is to the right of the scrollRect's right edge.
     * 
     *  Used by the getHorizontalScrollPositionDelta() method.
     * 
     *  By default this method returns a Rectangle with width=1, height=0, 
     *  whose right edge is one more than the scrollRect's right edge, 
     *  and top=0.
     * 
     *  Subclasses should override this method to provide an accurate
     *  bounding rectangle that has valid <code>left</code> and 
     *  <code>right</code> properties.
     * 
     *  @param scrollRect The target's scrollRect.
     *  @return Returns the bounds of the first element that spans or is to
     *  the right of the scrollRect’s right edge.
     *  
     *  @see #elementBoundsLeftOfScrollRect
     *  @see #elementBoundsAboveScrollRect
     *  @see #elementBoundsBelowScrollRect
     *  @see #getHorizontalScrollPositionDelta
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function elementBoundsRightOfScrollRect(scrollRect:Rectangle):Rectangle
    {
        var bounds:Rectangle = new Rectangle();
        bounds.left = scrollRect.right;
        bounds.right = scrollRect.right + 1;
        return bounds;
    } 

    /**
     *  Returns the bounds of the first layout element that either spans or
     *  is above the scrollRect's top edge.
     * 
     *  Used by the getVerticalScrollPositionDelta() method.
     * 
     *  By default this method returns a Rectangle with width=0, height=1, 
     *  whose top edge is one less than the scrollRect's top edge, 
     *  and left=0.
     * 
     *  Subclasses should override this method to provide an accurate
     *  bounding rectangle that has valid <code>top</code> and 
     *  <code>bottom</code> properties.
     * 
     *  @param scrollRect The target's scrollRect.
     *  @return Returns the bounds of the first element that spans or is
     *  above the scrollRect’s top edge.
     *  
     *  @see #elementBoundsLeftOfScrollRect
     *  @see #elementBoundsRightScrollRect
     *  @see #elementBoundsBelowScrollRect
     *  @see #getVerticalScrollPositionDelta
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function elementBoundsAboveScrollRect(scrollRect:Rectangle):Rectangle
    {
        var bounds:Rectangle = new Rectangle();
        bounds.top = scrollRect.top - 1;
        bounds.bottom = scrollRect.top;
        return bounds;
    } 

    /**
     *  Returns the bounds of the first layout element that either spans or
     *  is below the scrollRect's bottom edge.
     * 
     *  Used by the getVerticalScrollPositionDelta() method.
     * 
     *  By default this method returns a Rectangle with width=0, height=1, 
     *  whose bottom edge is one more than the scrollRect's bottom edge, 
     *  and left=0.
     * 
     *  Subclasses should override this method to provide an accurate
     *  bounding rectangle that has valid <code>top</code> and 
     *  <code>bottom</code> properties.
     * 
     *  @param scrollRect The target's scrollRect.
     *  @return Returns the bounds of the first element that spans or is
     *  below the scrollRect’s bottom edge.
     *  
     *  @see #elementBoundsLeftOfScrollRect
     *  @see #elementBoundsRightScrollRect
     *  @see #elementBoundsAboveScrollRect
     *  @see #getVerticalScrollPositionDelta
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function elementBoundsBelowScrollRect(scrollRect:Rectangle):Rectangle
    {
        var bounds:Rectangle = new Rectangle();
        bounds.top = scrollRect.bottom;
        bounds.bottom = scrollRect.bottom + 1;
        return bounds;
    } 
    
    /**
     *  Implements the default handling of
     *  LEFT, RIGHT, PAGE_LEFT, PAGE_RIGHT, HOME and END. 
     * 
     *  <ul>
     * 
     *  <li> 
     *  <code>LEFT</code>
     *  Returns scroll delta that will left justify the scrollRect
     *  with the first element that spans or is to the left of the
     *  scrollRect's left edge.
     *  </li>
     * 
     *  <li> 
     *  <code>RIGHT</code>
     *  Returns scroll delta that will right justify the scrollRect
     *  with the first element that spans or is to the right of the
     *  scrollRect's right edge.
     *  </li>
     * 
     *  <code>PAGE_LEFT</code>
     *  <li>
     *  Returns scroll delta that will right justify the scrollRect
     *  with the first element that spans or is to the left of the
     *  scrollRect's left edge.
     *  </li>
     * 
     *  <li> 
     *  <code>PAGE_RIGHT</code>
     *  Returns scroll delta that will left justify the scrollRect
     *  with the first element that spans or is to the right of the
     *  scrollRect's right edge.
     *  </li>
     *  
     *  <li> 
     *  <code>HOME</code>
     *  Returns scroll delta that will left justify the scrollRect
     *  to the content area.
     *  </li>
     * 
     *  <li> 
     *  <code>END</code>
     *  Returns scroll delta that will right justify the scrollRect
     *  to the content area.
     *  </li>
     *
     *  </ul>
     * 
     *  The implementation calls <code>elementBoundsLeftOfScrollRect()</code> and
     *  <code>elementBoundsRightOfScrollRect()</code> to determine the bounds of
     *  the elements.  Layout classes usually override those methods instead of
     *  getHorizontalScrollPositionDelta(). 
     * 
     *  @see #elementBoundsLeftOfScrollRect
     *  @see #elementBoundsRightOfScrollRect
     *  @see #getHorizontalScrollPositionDelta
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getHorizontalScrollPositionDelta(scrollUnit:uint):Number
    {
        var g:GroupBase = target;
        if (!g)
            return 0;     

        var scrollRect:Rectangle = getTargetScrollRect();
        if (!scrollRect)
            return 0;
            
        // Special case: if the scrollRect's origin is 0,0 and it's bigger 
        // than the target, then there's no where to scroll to
        if ((scrollRect.x == 0) && (scrollRect.width >= g.contentWidth))
            return 0;  

        // maxDelta is the horizontalScrollPosition delta required 
        // to scroll to the END and minDelta scrolls to HOME. 
        var maxDelta:Number = g.contentWidth - scrollRect.right;
        var minDelta:Number = -scrollRect.left;
        var elementBounds:Rectangle;
        switch(scrollUnit)
        {
            case ScrollUnit.LEFT:
            case ScrollUnit.PAGE_LEFT:
                // Find the bounds of the first non-fully visible element
                // to the left of the scrollRect.
                elementBounds = elementBoundsLeftOfScrollRect(scrollRect);
                break;

            case ScrollUnit.RIGHT:
            case ScrollUnit.PAGE_RIGHT:
                // Find the bounds of the first non-fully visible element
                // to the right of the scrollRect.
                elementBounds = elementBoundsRightOfScrollRect(scrollRect);
                break;

            case ScrollUnit.HOME: 
                return minDelta;
                
            case ScrollUnit.END: 
                return maxDelta;
                
            default:
                return 0;
        }
        
        if (!elementBounds)
            return 0;

        var delta:Number = 0;
        switch (scrollUnit)
        {
            case ScrollUnit.LEFT:
                // Snap the left edge of element to the left edge of the scrollRect.
                // The element is the the first non-fully visible element left of the scrollRect.
                delta = Math.max(elementBounds.left - scrollRect.left, -scrollRect.width);
            break;    
            case ScrollUnit.RIGHT:
                // Snap the right edge of the element to the right edge of the scrollRect.
                // The element is the the first non-fully visible element right of the scrollRect.
                delta = Math.min(elementBounds.right - scrollRect.right, scrollRect.width);
            break;    
            case ScrollUnit.PAGE_LEFT:
            {
                // Snap the right edge of the element to the right edge of the scrollRect.
                // The element is the the first non-fully visible element left of the scrollRect. 
                delta = elementBounds.right - scrollRect.right;
                
                // Special case: when an element is wider than the scrollRect,
                // we want to snap its left edge to the left edge of the scrollRect.
                // The delta will be limited to the width of the scrollRect further below.
                if (delta >= 0)
                    delta = Math.max(elementBounds.left - scrollRect.left, -scrollRect.width);  
            }
            break;
            case ScrollUnit.PAGE_RIGHT:
            {
                // Align the left edge of the element to the left edge of the scrollRect.
                // The element is the the first non-fully visible element right of the scrollRect.
                delta = elementBounds.left - scrollRect.left;
                
                // Special case: when an element is wider than the scrollRect,
                // we want to snap its right edge to the right edge of the scrollRect.
                // The delta will be limited to the width of the scrollRect further below.
                if (delta <= 0)
                    delta = Math.min(elementBounds.right - scrollRect.right, scrollRect.width);
            }
            break;
        }

        // Makse sure we don't get out of bounds. Also, don't scroll 
        // by more than the scrollRect width at a time.
        return Math.min(maxDelta, Math.max(minDelta, delta));
    }
    
    /**
     *  Implements the default handling of
     *  UP, DOWN, PAGE_UP, PAGE_DOWN, HOME and END. 
     * 
     *  <ul>
     * 
     *  <li> 
     *  <code>UP</code>
     *  Returns scroll delta that will top justify the scrollRect
     *  with the first element that spans or is above the scrollRect's
     *  top edge.
     *  </li>
     * 
     *  <li> 
     *  <code>DOWN</code>
     *  Returns scroll delta that will bottom justify the scrollRect
     *  with the first element that spans or is below the scrollRect's
     *  bottom edge.
     *  </li>
     * 
     *  <code>PAGE_UP</code>
     *  <li>
     *  Returns scroll delta that will bottom justify the scrollRect
     *  with the first element that spans or is above the scrollRect's
     *  top edge.
     *  </li>
     * 
     *  <li> 
     *  <code>PAGE_DOWN</code>
     *  Returns scroll delta that will top justify the scrollRect
     *  with the first element that spans or is below the scrollRect's
     *  bottom edge.
     *  </li>
     *  
     *  <li> 
     *  <code>HOME</code>
     *  Returns scroll delta that will top justify the scrollRect
     *  to the content area.
     *  </li>
     * 
     *  <li> 
     *  <code>END</code>
     *  Returns scroll delta that will bottom justify the scrollRect
     *  to the content area.
     *  </li>
     *
     *  </ul>
     * 
     *  The implementation calls <code>elementBoundsAboveScrollRect()</code> and
     *  <code>elementBoundsBelowScrollRect()</code> to determine the bounds of
     *  the elements.  Layout classes usually override those methods instead of
     *  getVerticalScrollPositionDelta(). 
     * 
     *  @see #elementBoundsAboveScrollRect
     *  @see #elementBoundsBelowScrollRect
     *  @see #getVerticalScrollPositionDelta
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getVerticalScrollPositionDelta(scrollUnit:uint):Number
    {
        var g:GroupBase = target;
        if (!g)
            return 0;     

        var scrollRect:Rectangle = getTargetScrollRect();
        if (!scrollRect)
            return 0;
            
        // Special case: if the scrollRect's origin is 0,0 and it's bigger 
        // than the target, then there's no where to scroll to
        if ((scrollRect.y == 0) && (scrollRect.height >= g.contentHeight))
            return 0;  
            
        // maxDelta is the horizontalScrollPosition delta required 
        // to scroll to the END and minDelta scrolls to HOME. 
        var maxDelta:Number = g.contentHeight - scrollRect.bottom;
        var minDelta:Number = -scrollRect.top;
        var elementBounds:Rectangle;
        switch(scrollUnit)
        {
            case ScrollUnit.UP:
            case ScrollUnit.PAGE_UP:
                // Find the bounds of the first non-fully visible element
                // that spans right of the scrollRect.
                elementBounds = elementBoundsAboveScrollRect(scrollRect);
                break;

            case ScrollUnit.DOWN:
            case ScrollUnit.PAGE_DOWN:
                // Find the bounds of the first non-fully visible element
                // that spans below the scrollRect.
                elementBounds = elementBoundsBelowScrollRect(scrollRect);
                break;

            case ScrollUnit.HOME: 
                return minDelta;

            case ScrollUnit.END: 
                return maxDelta;

            default:
                return 0;
        }
        
        if (!elementBounds)
            return 0;

        var delta:Number = 0;
        switch (scrollUnit)
        {
            case ScrollUnit.UP:
                // Snap the top edge of element to the top edge of the scrollRect.
                // The element is the the first non-fully visible element above the scrollRect.
                delta = Math.max(elementBounds.top - scrollRect.top, -scrollRect.height);
            break;    
            case ScrollUnit.DOWN:
                // Snap the bottom edge of the element to the bottom edge of the scrollRect.
                // The element is the the first non-fully visible element below the scrollRect.
                delta = Math.min(elementBounds.bottom - scrollRect.bottom, scrollRect.height);
            break;    
            case ScrollUnit.PAGE_UP:
            {
                // Snap the bottom edge of the element to the bottom edge of the scrollRect.
                // The element is the the first non-fully visible element below the scrollRect. 
                delta = elementBounds.bottom - scrollRect.bottom;
                
                // Special case: when an element is taller than the scrollRect,
                // we want to snap its top edge to the top edge of the scrollRect.
                // The delta will be limited to the height of the scrollRect further below.
                if (delta >= 0)
                    delta = Math.max(elementBounds.top - scrollRect.top, -scrollRect.height);  
            }
            break;
            case ScrollUnit.PAGE_DOWN:
            {
                // Align the top edge of the element to the top edge of the scrollRect.
                // The element is the the first non-fully visible element below the scrollRect.
                delta = elementBounds.top - scrollRect.top;
                
                // Special case: when an element is taller than the scrollRect,
                // we want to snap its bottom edge to the bottom edge of the scrollRect.
                // The delta will be limited to the height of the scrollRect further below.
                if (delta <= 0)
                    delta = Math.min(elementBounds.bottom - scrollRect.bottom, scrollRect.height);
            }
            break;
        }

        return Math.min(maxDelta, Math.max(minDelta, delta));
    }
    
    /**
     *  LayoutBase::getScrollPositionDelta() computes the
     *  vertical and horizontalScrollPosition deltas needed to 
     *  scroll the element at the specified index into view.
     * 
     *  If clipAndEnableScrolling is true and the element at the specified index is not
     *  entirely visible relative to the target's scrollRect, then 
     *  return the delta to be added to horizontalScrollPosition and
     *  verticalScrollPosition that will scroll the element completely 
     *  within the scrollRect's bounds.
     * 
     *  If the specified element is partially visible and larger than the
     *  scrollRect, i.e. it's already the only element visible, then
     *  null is returned.
     * 
     *  This method attempts to minmimze the change to verticalScrollPosition
     *  and horizontalScrollPosition.
     * 
     *  If the specified index is invalid, or target is null, then
     *  null is returned.
     * 
     *  If the element at the specified index is null or includeInLayout
     *  false, then null is returned.
     * 
     *  @param index The index of the element to be scrolled into view.
     *  @return A Point that contains offsets to horizontalScrollPosition 
     *      and verticalScrollPosition that will scroll the specified
     *      element into view, or null if no change is needed. 
     * 
     *  @see clipAndEnableScrolling
     *  @see verticalScrollPosition
     *  @see horizontalScrollPosition
     *  @see udpdateScrollRect
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
     public function getScrollPositionDelta(index:int):Point
     {
        var g:GroupBase = target;
        if (!g || !clipAndEnableScrolling)
            return null;     
            
         var n:int = g.numElements;
         if ((index < 0) || (index >= n))
            return null;
            
         var element:ILayoutElement = g.getElementAt(index);
         if (!element || !element.includeInLayout)
            return null;
            
         var scrollR:Rectangle = getTargetScrollRect();
         if (!scrollR)
            return null;
         
         // TODO EGeorgie: helper method?   
         var elementX:Number = element.getLayoutBoundsX();
         var elementY:Number = element.getLayoutBoundsY();
         var elementW:Number = element.getLayoutBoundsWidth();
         var elementH:Number = element.getLayoutBoundsHeight();
         var elementR:Rectangle = new Rectangle(elementX, elementY, elementW, elementH);
         
         if (scrollR.containsRect(elementR) || elementR.containsRect(scrollR))
            return null;
            
         var dxl:Number = elementR.left - scrollR.left;     // left justify element
         var dxr:Number = elementR.right - scrollR.right;   // right justify element
         var dyt:Number = elementR.top - scrollR.top;       // top justify element
         var dyb:Number = elementR.bottom - scrollR.bottom; // bottom justify element
         
         // minimize the scroll
         var dx:Number = (Math.abs(dxl) < Math.abs(dxr)) ? dxl : dxr;
         var dy:Number = (Math.abs(dyt) < Math.abs(dyb)) ? dyt : dyb;
                 
         // scrollR "contains"  elementR in just one dimension
         if ((elementR.left >= scrollR.left) && (elementR.right <= scrollR.right))
            dx = 0;
         else if ((elementR.bottom <= scrollR.bottom) && (elementR.top >= scrollR.top))
            dy = 0;
            
         // elementR "contains" scrollR in just one dimension
         if ((elementR.left <= scrollR.left) && (elementR.right >= scrollR.right))
            dx = 0;
         else if ((elementR.bottom >= scrollR.bottom) && (elementR.top <= scrollR.top))
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */  
    protected function scrollPositionChanged():void
    {
        var g:GroupBase = target;
        if (!g)
            return;

        updateScrollRect(g.width, g.height);
    }
    
    /**
     *  If clipAndEnableScrolling is true, sets the origin of the scrollRect to 
     *  verticalScrollPosition,horizontalScrollPosition and its width
     *  width,height to w,h (the target's unscaled width,height).
     * 
     *  If clipAndEnableScrolling is false, sets the scrollRect to null.
     *  
     *  @param w The target's unscaled width.
     *  @param h The target's unscaled height.
     * 
     *  @see target
     *  @see flash.display.DisplayObject#scrollRect
     *  @see updateDisplayList
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function updateScrollRect(w:Number, h:Number):void
    {
        var g:GroupBase = target;
        if (!g)
            return;
            
        if (clipAndEnableScrolling)
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function measure():void
    {
    }
    
    /**
     *  @copy mx.core.UIComponent#updateDisplayList
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
    }          
}

}
