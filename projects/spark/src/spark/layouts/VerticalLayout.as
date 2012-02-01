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
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.Event;
import flash.events.EventDispatcher;

import mx.components.baseClasses.GroupBase;
import mx.core.ScrollUnit;

import mx.containers.utilityClasses.Flex;
import mx.events.PropertyChangeEvent;


/**
 *  Documentation is not currently available.
 */
public class VerticalLayout extends LayoutBase
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    private static function calculatePercentWidth(layoutElement:ILayoutElement, width:Number):Number
    {
    	var percentWidth:Number = LayoutElementHelper.pinBetween(layoutElement.percentWidth * 0.01 * width,
    	                                                         layoutElement.getMinWidth(),
    	                                                         layoutElement.getMaxWidth() );
    	return percentWidth < width ? percentWidth : width;
    }
    
    private static function sizeLayoutElement(layoutElement:ILayoutElement, width:Number, 
                                           horizontalAlign:String, restrictedWidth:Number, 
                                           height:Number, variableRowHeight:Boolean, 
                                           rowHeight:Number):void
    {
        var newWidth:Number = NaN;
        
        // if horizontalAlign is "justify" or "contentJustify", 
        // restrict the width to restrictedWidth.  Otherwise, 
        // size it normally
        if (horizontalAlign == HorizontalAlign.JUSTIFY ||
            horizontalAlign == HorizontalAlign.CONTENT_JUSTIFY)
        {
            newWidth = restrictedWidth;
        }
        else
        {
            if (hasPercentWidth(layoutElement))
               newWidth = calculatePercentWidth(layoutElement, width);
        }
        
        if (variableRowHeight)
            layoutElement.setLayoutSize(newWidth, height);
        else
            layoutElement.setLayoutSize(newWidth, rowHeight);
    }
        
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */    
    public function VerticalLayout():void
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  gap
    //----------------------------------
    
    private var _gap:int = 6;
    
    [Inspectable(category="General")]

    /**
     *  Vertical space between rows.
     * 
     *  @default 6
     */
    public function get gap():int
    {
        return _gap;
    }

    /**
     *  @private
     */
    public function set gap(value:int):void
    {
        if (_gap == value) 
            return;

        _gap = value;
        invalidateTargetSizeAndDisplayList();
    }

    //----------------------------------
    //  rowCount
    //----------------------------------

    private var _rowCount:int = -1;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  Returns the current number of visible elements.
     * 
     *  @default -1
     */
    public function get rowCount():int
    {
        return _rowCount;
    }
    
    /**
     *  Sets the <code>rowCount</code> property and dispatches a
     *  PropertyChangeEvent.
     * 
     *  This method is intended to be used by subclass updateDisplayList() 
     *  methods to sync the rowCount property with the actual number
     *  of visible rows.
     *
     *  @param value The number of visible rows.
     */
    protected function setRowCount(value:int):void
    {
        if (_rowCount == value)
            return;
        var oldValue:int = _rowCount;
        _rowCount = value;
        dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "rowCount", oldValue, value));
    }
    
    //----------------------------------
    //  horizontalAlign
    //----------------------------------

    /**
     *  @private
     */
    private var _horizontalAlign:String = HorizontalAlign.LEFT;

    [Inspectable(category="General")]

    /** 
     *  Horizontal alignment of children in the container.
     *  Possible values are <code>"left"</code>, <code>"center"</code>,
     *  <code>"right"</code>, <code>"justify"</code>, 
     *  and <code>"contentJustify"</code>.
     *  The default value is <code>"left"</code>, but some containers,
     *  such as List, use a different default value.  There are constants 
     *  for these values in <code>mx.layout.HorizontalAlign</code>.
     */
    public function get horizontalAlign():String
    {
        return _horizontalAlign;
    }

    /**
     *  @private
     */
    public function set horizontalAlign(value:String):void
    {
        if (value == _horizontalAlign) 
            return;
        
        _horizontalAlign = value;
        invalidateTargetDisplayList();
    }
    
    //----------------------------------
    //  requestedRowCount
    //----------------------------------

    private var _requestedRowCount:int = -1;
    
    [Inspectable(category="General")]

    /**
     *  Specifies the number of elements to display.
     * 
     *  If <code>requestedRowCount</code> is -1, then all of the elements are displayed.
     * 
     *  This property implies the layout's <code>measuredHeight</code>.
     * 
     *  If the height of the <code>target</code> has been explicitly set,
     *  then this property has no effect.
     * 
     *  @default -1
     */
    public function get requestedRowCount():int
    {
        return _requestedRowCount;
    }

    /**
     *  @private
     */
    public function set requestedRowCount(value:int):void
    {
        if (_requestedRowCount == value)
            return;
                               
        _requestedRowCount = value;
        invalidateTargetSizeAndDisplayList();
    }    

    //----------------------------------
    //  rowHeight
    //----------------------------------
    
    private var _rowHeight:Number;

    [Inspectable(category="General")]

    /**
     *  Specifies the height of the rows if <code>variableRowHeight</code>
     *  is false.
     * 
     *  If this property isn't explicitly set, then the measured height
     *  of the first element is returned.
     */
    public function get rowHeight():Number
    {
        if (!isNaN(_rowHeight))
            return _rowHeight;
        else if (!target || (target.numLayoutElements <= 0))
            return 0;
        else
            return target.getLayoutElementAt(0).getPreferredHeight();
    }

    /**
     *  @private
     */
    public function set rowHeight(value:Number):void
    {
        if (_rowHeight == value)
            return;
            
        _rowHeight = value;
        invalidateTargetSizeAndDisplayList();
    }
    
    //----------------------------------
    //  variableRowHeight
    //----------------------------------

    /**
     *  @private
     */
    private var _variableRowHeight:Boolean = true;

    [Inspectable(category="General")]

    /**
     *  If false, i.e. "fixed row height" is specified, the height of
     *  each element is set to the value of <code>rowHeight</code>.
     * 
     *  If the <code>rowHeight</code> property wasn't explicitly set,
     *  then it's initialized with the <code>measuredHeight</code> of
     *  the first element.
     * 
     *  The elements' <code>includeInLayout</code>, 
     *  <code>measuredHeight</code>, <code>minHeight</code>,
     *  and <code>percentHeight</code> properties are ignored when 
     *  <code>variableRowHeight</code> is false.
     * 
     *  @default true
     */
    public function get variableRowHeight():Boolean
    {
        return _variableRowHeight;
    }

    /**
     *  @private
     */
    public function set variableRowHeight(value:Boolean):void
    {
        if (value == _variableRowHeight) 
            return;
        
        _variableRowHeight = value;
        invalidateTargetSizeAndDisplayList();
    }
    
    //----------------------------------
    //  firstIndexInView
    //----------------------------------

    /**
     *  @private
     */
    private var _firstIndexInView:int = -1;

    [Inspectable(category="General")]
    [Bindable("indexInViewChanged")]    

	/**
	 *  The index of the first row that's part of the layout and within
	 *  the layout target's scrollRect, or -1 if nothing has been displayed yet.
	 * 
	 *  Note that the row may only be partially in view.
	 * 
	 *  @see lastIndexInView
	 *  @see inView
	 */
	public function get firstIndexInView():int
	{
		return _firstIndexInView;
	}
	
	
    //----------------------------------
    //  lastIndexInView
    //----------------------------------

    /**
     *  @private
     */
    private var _lastIndexInView:int = -1;
    
    [Inspectable(category="General")]
    [Bindable("indexInViewChanged")]    

	/**
     *  The index of the last row that's part of the layout and within
     *  the layout target's scrollRect, or -1 if nothing has been displayed yet.
     * 
     *  Note that the row may only be partially in view.
     * 
     *  @see firstIndexInView
     *  @see inView
	 */
	public function get lastIndexInView():int
	{
		return _lastIndexInView;
	}

    /**
     *  Sets the <code>firstIndexInView</code> and <code>lastIndexInView</code>
     *  properties and dispatches a <code>"indexInViewChanged"</code>
     *  event.  
     * 
     *  This method is intended to be used by subclasses that 
     *  override updateDisplayList() to sync the first and 
     *  last indexInView properties with the current display.
     *
     *  @param firstIndex The new value for firstIndexInView.
     *  @param lastIndex The new value for lastIndexInView.
     * 
     *  @see firstIndexInView
     *  @see lastIndexInview
     */
    protected function setIndexInView(firstIndex:int, lastIndex:int):void
    {
        if ((_firstIndexInView == firstIndex) && (_lastIndexInView == lastIndex))
            return;
            
        _firstIndexInView = firstIndex;
        _lastIndexInView = lastIndex;
        dispatchEvent(new Event("indexInViewChanged"));
    }
    

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
	/**
	 *  An index is "in view" if the corresponding non-null layout element is 
	 *  within the vertical limits of the layout target's scrollRect
	 *  and included in the layout.
	 *  
	 *  Returns 1.0 if the specified index is completely in view, 0.0 if
	 *  it's not, and a value in between if the index is partially 
	 *  within the view.
	 * 
	 *  If the specified index is partially within the view, the 
	 *  returned value is the percentage of the corresponding layout
	 *  element that's visible.
	 * 
	 *  Returns 0.0 if the specified index is invalid or if it corresponds to
	 *  null element, or a ILayoutElement for which includeInLayout is false.
	 * 
	 *  @return the percentage of the specified element that's in view.
	 *  @see firstIndexInView
	 *  @see lastIndexInView
	 */
	public function inView(index:int):Number 
	{
		var g:GroupBase = GroupBase(target);
	    if (!g)
	        return 0.0;
	        
	    if ((index < 0) || (index >= g.numLayoutElements))
	       return 0.0;
	       
        var li:ILayoutElement = g.getLayoutElementAt(index);
        if ((li == null) || !li.includeInLayout)
            return 0.0;
            
        if (!clipContent)
            return 1.0;

        var r0:int = firstIndexInView;	
        var r1:int = lastIndexInView;
        
        // outside the visible index range
        if ((r0 == -1) || (r1 == -1) || (index < r0) || (index > r1))
            return 0.0;
            
        // within the visible index range, but not first or last            
        if ((index > r0) && (index < r1))
            return 1.0;

        // index is first (r0) or last (r1) visible row
        var y0:Number = g.verticalScrollPosition;
        var y1:Number = y0 + g.height;
        var iy0:Number = li.getLayoutPositionY();
        var iy1:Number = iy0 + li.getLayoutHeight();
        if (iy0 >= iy1)  // element has 0 or negative height
            return 1.0;
        if ((iy0 >= y0) && (iy1 <= y1))
            return 1.0;
        return (Math.min(y1, iy1) - Math.max(y0, iy0)) / (iy1 - iy0);
	}
	
	/**
	 *  Binary search for the first layout element that contains y.  
	 * 
	 *  This function considers both the element's actual bounds and 
	 *  the gap that follows it to be part of the element.  The search 
	 *  covers index i0 through i1 (inclusive).
	 *  
	 *  This function is intended for variable height elements.
	 * 
	 *  Returns the index of the element that contains y, or -1.
	 *   
	 * @private 
	 */
	private static function findIndexAt(y:Number, gap:int, g:GroupBase, i0:int, i1:int):int
	{
	    var index:int = (i0 + i1) / 2;
        var element:ILayoutElement = g.getLayoutElementAt(index);	    
	    var elementY:Number = element.getLayoutPositionY();
        var elementHeight:Number = element.getLayoutHeight();
        // TBD: deal with null element, includeInLayout false.
        if ((y >= elementY) && (y < elementY + elementHeight + gap))
            return index;
        else if (i0 == i1)
            return -1;
        else if (y < elementY)
            return findIndexAt(y, gap, g, i0, Math.max(i0, index-1));
        else 
            return findIndexAt(y, gap, g, Math.min(index+1, i1), i1);
	} 
	
   /**
    *  Returns the index of the first non-null includeInLayout element, 
    *  beginning with the element at index i.  
    * 
    *  Returns -1 if no such element can be found.
    *  
    *  @private
    */
    private static function findLayoutElementIndex(g:GroupBase, i:int, dir:int):int
    {
        var n:int = g.numLayoutElements;
        while((i >= 0) && (i < n))
        {
           var element:ILayoutElement = g.getLayoutElementAt(i);
           if (element && element.includeInLayout)
           {
               return i;      
           }
           i += dir;
        }
        return -1;
    }

   /**
    *  Updates the first,lastIndexInView properties per the new
    *  scroll position.
    *  
    *  @see setIndexInView
    */
    override protected function scrollPositionChanged():void
    {
        super.scrollPositionChanged();
        
        var g:GroupBase = target;
        if (!g)
            return;     

        var n:int = g.numLayoutElements - 1;
        if (n < 0) 
        {
            setIndexInView(-1, -1);
            return;
        }
        
        var scrollR:Rectangle = g.scrollRect;
        if (!scrollR)
        {
            setIndexInView(0, n);
            return;    
        }
        
        // We're going to use findIndexAt to find the index of 
        // the elements that overlap the top and bottom edges of the scrollRect.
        // Values that are exactly equal to scrollRect.bottom aren't actually
        // rendered, since the top,bottom interval is only half open.
        // To account for that we back away from the bottom edge by a
        // hopefully infinitesimal amount.
        
        var y0:Number = scrollR.top;
        var y1:Number = scrollR.bottom - .0001;
        if (y1 <= y0)
        {
            setIndexInView(-1, -1);
            return;
        }

        // TBD: special case for variableRowHeight false

        var i0:int = findIndexAt(y0 + gap, gap, g, 0, n);
        var i1:int = findIndexAt(y1, gap, g, 0, n);

        // Special case: no element overlaps y0, is index 0 visible?
        if (i0 == -1)
        {   
            var index0:int = findLayoutElementIndex(g, 0, +1);
            if (index0 != -1)
            {
                var element0:ILayoutElement = g.getLayoutElementAt(index0); 
                var element0Y:Number = element0.getLayoutPositionY();
                var elementHeight:Number = element0.getLayoutHeight();                 
                if ((element0Y < y1) && ((element0Y + elementHeight) > y0))
                    i0 = index0;
            }
        }

        // Special case: no element overlaps y1, is index n visible?
        if (i1 == -1)
        {
            var index1:int = findLayoutElementIndex(g, n, -1);
            if (index1 != -1)
            {
                var element1:ILayoutElement = g.getLayoutElementAt(index1); 
                var element1Y:Number = element1.getLayoutPositionY();
                var element1Height:Number = element1.getLayoutHeight();                 
                if ((element1Y < y1) && ((element1Y + element1Height) > y0))
                    i1 = index1;
            }
        }   

        setIndexInView(i0, i1);
    }

    /**
     *  If the element at index i is non-null and includeInLayout,
     *  then return it's actual bounds, otherwise return null.
     * 
     *  @private
     */
    private static function layoutElementBounds(g:GroupBase, i:int):Rectangle
    {
        var element:ILayoutElement = g.getLayoutElementAt(i);
        if (element && element.includeInLayout)
        {
            return new Rectangle(element.getLayoutPositionX(),
                                 element.getLayoutPositionY(),
                                 element.getLayoutWidth(),
                                 element.getLayoutHeight());        
        }
        return null;    
    }
    
    /**
     *  Returns the actual position/size Rectangle of the first partially 
     *  visible or not-visible, non-null includeInLayout element, beginning
     *  with the element at index i, searching in direction dir (dir must
     *  be +1 or -1).   The last argument is the GroupBase scrollRect, it's
     *  guaranteed to be non-null.
     * 
     *  Returns null if no such element can be found.
     *  
     *  @private
     */
    private function findLayoutElementBounds(g:GroupBase, i:int, dir:int, r:Rectangle):Rectangle
    {
        var n:int = g.numLayoutElements;

        if (inView(i) >= 1)
            i = Math.max(0, Math.min(n - 1, i + dir));

        while((i >= 0) && (i < n))
        {
           var elementR:Rectangle = layoutElementBounds(g, i);
           // Special case: if the scrollRect r _only_ contains
           // elementR, then if we're searching up (dir == -1),
           // and elementR's top edge is visible, then try again
           // with i-1.   Likewise for dir == +1.
           if (elementR)
           {
               var overlapsTop:Boolean = (dir == -1) && (elementR.top == r.top) && (elementR.bottom >= r.bottom);
               var overlapsBottom:Boolean = (dir == +1) && (elementR.bottom == r.bottom) && (elementR.top <= r.top);
               if (!(overlapsTop || overlapsBottom))             
                   return elementR;
           }
           i += dir;
        }
        return null;
    }

    /**
     *  Overrides the default handling of UP/DOWN and 
     *  PAGE_UP, PAGE_DOWN. 
     * 
     *  <ul>
     * 
     *  <li> 
     *  <code>UP</code>
     *  If the firstIndexInView element is partially visible then top justify
     *  it, otherwise top justify the element at the previous index.
     *  </li>
     * 
     *  <li> 
     *  <code>DOWN</code>
     *  If the lastIndexInView element is partially visible, then bottom justify
     *  it, otherwise bottom justify the element at the following index.
     *  </li>
     * 
     *  <code>PAGE_UP</code>
     *  <li>
     *  If the firstIndexInView element is partially visible, then bottom
     *  justify it, otherwise bottom justify element at the previous index.  
     *  </li>
     * 
     *  <li> 
     *  <code>PAGE_DOWN</code>
     *  If the lastIndexInView element is partially visible, then top
     *  justify it, otherwise top justify element at the following index.  
     *  </li>
     *  
     *  </ul>
     *   
     *  @see firstIndexInView
     *  @see lastIndexInView
     *  @see verticalScrollPosition
     */
    override public function getVerticalScrollPositionDelta(unit:ScrollUnit):Number
    {
        var g:GroupBase = target;
        if (!g)
            return 0;     

        var maxIndex:int = g.numLayoutElements -1;
        if (maxIndex < 0)
            return 0;
            
        var scrollR:Rectangle = g.scrollRect;
        if (!scrollR)
            return 0;
            
        var elementR:Rectangle = null;
        switch(unit)
        {
            case ScrollUnit.UP:
            case ScrollUnit.PAGE_UP:
                elementR = findLayoutElementBounds(g, firstIndexInView, -1, scrollR);
                break;

            case ScrollUnit.DOWN:
            case ScrollUnit.PAGE_DOWN:
                elementR = findLayoutElementBounds(g, lastIndexInView, +1, scrollR);
                break;

            default:
                return super.getVerticalScrollPositionDelta(unit);
        }
        
        if (!elementR)
            return 0;
            
        var delta:Number = 0;            
        switch (unit)
        {
            case ScrollUnit.UP:
                delta = Math.max(-scrollR.height, elementR.top - scrollR.top);
                break;
                
            case ScrollUnit.DOWN:
                delta = Math.min(scrollR.height, elementR.bottom - scrollR.bottom);
                break;
                
            case ScrollUnit.PAGE_UP:
                if ((elementR.top < scrollR.top) && (elementR.bottom >= scrollR.bottom))
                    delta = Math.max(-scrollR.height, elementR.top - scrollR.top);
                else
                    delta = elementR.bottom - scrollR.bottom;
                break;

            case ScrollUnit.PAGE_DOWN:
                if ((elementR.top <= scrollR.top) && (elementR.bottom > scrollR.bottom))
                    delta = Math.min(scrollR.height, elementR.bottom - scrollR.bottom);
                else
                    delta = elementR.top - scrollR.top;
                break;
        }

        var maxDelta:Number = g.contentHeight - scrollR.height - scrollR.y;
        var minDelta:Number = -scrollR.y;
        return Math.min(maxDelta, Math.max(minDelta, delta));
    }     
        
    private function variableRowHeightMeasure(layoutTarget:GroupBase):void
    {
        var minWidth:Number = 0;
        var minHeight:Number = 0;
        var preferredWidth:Number = 0;
        var preferredHeight:Number = 0;
        var visibleHeight:Number = 0;
        var visibleRows:uint = 0;
        var reqRows:int = requestedRowCount;
         
        var count:uint = layoutTarget.numLayoutElements;
        var totalCount:uint = count; // How many elements will be laid out
        for (var i:int = 0; i < count; i++)
        {
            var li:ILayoutElement = layoutTarget.getLayoutElementAt(i);
            if (!li || !li.includeInLayout)
            {
            	totalCount--;
                continue;
            }            

            preferredWidth = Math.max(preferredWidth, li.getPreferredWidth());
            preferredHeight += li.getPreferredHeight(); 
            
            var vrr:Boolean = (reqRows != -1) && (visibleRows < reqRows);

            if (vrr || (reqRows == -1))
            {
                var mw:Number =  hasPercentWidth(li) ? li.getMinWidth() : li.getPreferredWidth();
                var mh:Number = hasPercentHeight(li) ? li.getMinHeight() : li.getPreferredHeight();                   
                minWidth = Math.max(mw, minWidth);
                minHeight += mh;
            }

            if (vrr) 
            {
                visibleHeight = preferredHeight;
                visibleRows += 1;
            }            
        }
        
        if (totalCount > 1)
        { 
            preferredHeight += gap * (totalCount - 1);
            var vgap:Number = (visibleRows > 1) ? (gap * (visibleRows - 1)) : 0;
            visibleHeight += vgap;
            minHeight += vgap;
        }
        
        layoutTarget.measuredWidth = preferredWidth;
        layoutTarget.measuredHeight = (reqRows == -1) ? preferredHeight : visibleHeight;

        layoutTarget.measuredMinWidth = minWidth; 
        layoutTarget.measuredMinHeight = minHeight;

        layoutTarget.setContentSize(preferredWidth, preferredHeight);
    }
   
   
    private function fixedRowHeightMeasure(layoutTarget:GroupBase):void
    {
    	var rows:uint = layoutTarget.numLayoutElements;
        var visibleRows:uint = (requestedRowCount == -1) ? rows : requestedRowCount;
        
        var rh:Number = rowHeight; // can be expensive to compute
        var contentHeight:Number = (rows * rh) + ((rows > 1) ? (gap * (rows - 1)) : 0);
        var visibleHeight:Number = (visibleRows * rh) + ((visibleRows > 1) ? (gap * (visibleRows - 1)) : 0);
        
        var columnWidth:Number = layoutTarget.explicitWidth;
        var minColumnWidth:Number = columnWidth;
        if (isNaN(columnWidth)) 
        {
			minColumnWidth = columnWidth = 0;
	        var count:uint = layoutTarget.numLayoutElements;
	        for (var i:int = 0; i < count; i++)
	        {
	            var layoutElement:ILayoutElement = layoutTarget.getLayoutElementAt(i);
	            if (!layoutElement || !layoutElement.includeInLayout) 
	               continue;
	            columnWidth = Math.max(columnWidth, layoutElement.getPreferredWidth());
	            var elementMinWidth:Number = hasPercentWidth(layoutElement) ? layoutElement.getMinWidth() : layoutElement.getPreferredWidth();
	            minColumnWidth = Math.max(minColumnWidth, elementMinWidth);
	        }
        }     
        
        layoutTarget.measuredWidth = columnWidth;
        layoutTarget.measuredHeight = visibleHeight;

        layoutTarget.measuredMinWidth = minColumnWidth;
        layoutTarget.measuredMinHeight = visibleHeight;
        
        layoutTarget.setContentSize(columnWidth, contentHeight);
    }
    
    
    override public function measure():void
    {
        super.measure();
        
    	var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;
        if (variableRowHeight) 
            variableRowHeightMeasure(layoutTarget);
        else 
            fixedRowHeightMeasure(layoutTarget);

    }
    
    
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
    	var layoutTarget:GroupBase = target; 
        if (!layoutTarget)
            return;
        
        var layoutElement:ILayoutElement;
        var count:uint = layoutTarget.numLayoutElements;
        
        // If horizontalAlign is left, we don't need to figure out the contentWidth
        // Otherwise the contentWidth is used to position the element and even size 
        // the element if it's "contentJustify" or "justify".
        var contentWidth:Number = unscaledWidth;        
        
        // TODO: in the center or right case, we end up calculating percentWidth 
        // twice.  Once here for the contentWidth and once in distributeHeight
        // to size that particular element.
        if (horizontalAlign != HorizontalAlign.LEFT)
        {
            for (var i:int = 0; i < count; i++)
            {
                layoutElement = layoutTarget.getLayoutElementAt(i);
                if (!layoutElement || !layoutElement.includeInLayout)
                    continue;

                var layoutElementWidth:Number;
                if (hasPercentWidth(layoutElement))
                    layoutElementWidth = calculatePercentWidth(layoutElement, unscaledWidth);
                else
                    layoutElementWidth = layoutElement.getPreferredWidth();
                
                contentWidth = Math.max(contentWidth, layoutElementWidth);
            }
        }

        // If we're justifying the elements, then all widths should be set to
        // unscaledWidth.  If we're content justifying the elements, then 
        // all widths should be set to the contentWidth.
        // Otherwise restrictedWidth is ignored in distributedHeight.
        var restrictedWidth:Number;
        if (horizontalAlign == HorizontalAlign.JUSTIFY)
            restrictedWidth = unscaledWidth;
        else if (horizontalAlign == HorizontalAlign.CONTENT_JUSTIFY)
            restrictedWidth = contentWidth;

        distributeHeight(unscaledWidth, unscaledHeight, restrictedWidth);
        
        // default to left (0)
        var hAlign:Number = 0;
        if (horizontalAlign == HorizontalAlign.CENTER)
            hAlign = .5;
        else if (horizontalAlign == HorizontalAlign.RIGHT)
            hAlign = 1;
        
        // As the layoutElements are positioned, we'll count how many rows 
        // fall within the layoutTarget's scrollRect
        var visibleRows:uint = 0;
        var minVisibleY:Number = layoutTarget.verticalScrollPosition;
        var maxVisibleY:Number = minVisibleY + unscaledHeight;
        
        // Finally, position the layoutElements and find the first/last
        // visible indices, the content size, and the number of 
        // visible elements.    
        var y:Number = 0;
        var maxX:Number = 0;
        var maxY:Number = 0;
        var firstRowInView:int = -1;
        var lastRowInView:int = -1;
        
        for (var index:int = 0; index < count; index++)
        {
            layoutElement = layoutTarget.getLayoutElementAt(index);
            if (!layoutElement || !layoutElement.includeInLayout)
                continue;
                
            // Set the layout element's position
            var x:Number = (contentWidth - layoutElement.getLayoutWidth()) * hAlign;
            layoutElement.setLayoutPosition(x, y);
                
            // Update maxX,Y, first,lastVisibleIndex, and y
            var dx:Number = layoutElement.getLayoutWidth();
            var dy:Number = layoutElement.getLayoutHeight();
            maxX = Math.max(maxX, x + dx);
            maxY = Math.max(maxY, y + dy);
            if (!clipContent ||
                ((y < maxVisibleY) && ((y + dy) > minVisibleY)) || 
                ((dy <= 0) && ((y == maxVisibleY) || (y == minVisibleY))))
            {
            	visibleRows += 1;
            	if (firstRowInView == -1)
            	   firstRowInView = lastRowInView = index;
            	else
            	   lastRowInView = index;
            }
            y += dy + gap;
        }
        
        setRowCount(visibleRows);
        setIndexInView(firstRowInView, lastRowInView);
        layoutTarget.setContentSize(maxX, maxY);
    }
    
    /**
     *  This function sets the height of each child
     *  so that the heights add up to <code>height</code>. 
     *  Each child is set to its preferred height
     *  if its percentHeight is zero.
     *  If its percentHeight is a positive number,
     *  the child grows (or shrinks) to consume its
     *  share of extra space.
     *  
     *  The return value is any extra space that's left over
     *  after growing all children to their maxHeight.
     */
    public function distributeHeight(width:Number, 
                                     height:Number, 
                                     restrictedWidth:Number):Number
    {
        var spaceToDistribute:Number = height;
        var totalPercentHeight:Number = 0;
        var childInfoArray:Array = [];
        var childInfo:LayoutElementFlexChildInfo;
        var newWidth:Number;
        var layoutElement:ILayoutElement;
        
        // rowHeight can be expensive to compute
        var rh:Number = (variableRowHeight) ? 0 : rowHeight;
        var count:uint = target.numLayoutElements;
        var totalCount:uint = count; // number of elements to use in gap calculation
        
        // If the child is flexible, store information about it in the
        // childInfoArray. For non-flexible children, just set the child's
        // width and height immediately.
        for (var index:int = 0; index < count; index++)
        {
            layoutElement = target.getLayoutElementAt(index);
            if (!layoutElement || !layoutElement.includeInLayout)
            {
                totalCount--;
                continue;
            }
            
            if (hasPercentHeight(layoutElement) && variableRowHeight)
            {
                totalPercentHeight += layoutElement.percentHeight;

                childInfo = new LayoutElementFlexChildInfo();
                childInfo.layoutElement = layoutElement;
                childInfo.percent    = layoutElement.percentHeight;
                childInfo.min        = layoutElement.getMinHeight();
                childInfo.max        = layoutElement.getMaxHeight();
                
                childInfoArray.push(childInfo);                
            }
            else
            {
                sizeLayoutElement(layoutElement, width, horizontalAlign, 
                               restrictedWidth, NaN, variableRowHeight, rh);
                
                spaceToDistribute -= layoutElement.getLayoutHeight();
            } 
        }
        
        if (totalCount > 1)
            spaceToDistribute -= (totalCount-1) * gap;

        // Distribute the extra space among the flexible children
        if (totalPercentHeight)
        {
            spaceToDistribute = Flex.flexChildrenProportionally(height,
                                                                spaceToDistribute,
                                                                totalPercentHeight,
                                                                childInfoArray);
            
            for each (childInfo in childInfoArray)
            {
                sizeLayoutElement(childInfo.layoutElement, width, horizontalAlign, 
                               restrictedWidth, childInfo.size, 
                               variableRowHeight, rh);
            }
        }
        return spaceToDistribute;
    }
}
}

[ExcludeClass]

import mx.layout.ILayoutElement;
import mx.containers.utilityClasses.FlexChildInfo;

class LayoutElementFlexChildInfo extends FlexChildInfo
{
    public var layoutElement:ILayoutElement;	
}
