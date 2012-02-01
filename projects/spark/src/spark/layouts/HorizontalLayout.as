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
import mx.core.ILayoutElement;
import mx.core.ScrollUnit;

import mx.containers.utilityClasses.Flex;
import mx.events.PropertyChangeEvent;


/**
 *  Documentation is not currently available.
 */
public class HorizontalLayout extends LayoutBase
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------
    
    private static function calculatePercentHeight(layoutElement:ILayoutElement, height:Number):Number
    {
    	var percentHeight:Number = LayoutElementHelper.pinBetween(layoutElement.percentHeight * 0.01 * height,
    	                                                          layoutElement.getMinBoundsHeight(),
    	                                                          layoutElement.getMaxBoundsHeight() );
    	return percentHeight < height ? percentHeight : height;
    }
    
    private static function sizeLayoutElement(layoutElement:ILayoutElement, height:Number, 
                                              verticalAlign:String, restrictedHeight:Number, 
                                              width:Number, variableColumnWidth:Boolean, 
                                              columnWidth:Number):void
    {
        var newHeight:Number = NaN;
        
        // if verticalAlign is "justify" or "contentJustify", 
        // restrict the height to restrictedHeight.  Otherwise, 
        // size it normally
        if (verticalAlign == VerticalAlign.JUSTIFY ||
            verticalAlign == VerticalAlign.CONTENT_JUSTIFY)
        {
            newHeight = restrictedHeight;
        }
        else
        {
            if (hasPercentHeight(layoutElement))
               newHeight = calculatePercentHeight(layoutElement, height);   
        }
        
        if (variableColumnWidth)
            layoutElement.setLayoutBoundsSize(width, newHeight);
        else
            layoutElement.setLayoutBoundsSize(columnWidth, newHeight);
    }
        
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */    
    public function HorizontalLayout():void
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
     *  Horizontal space between columns.
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
    //  columnCount
    //----------------------------------

    private var _columnCount:int = -1;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  Returns the current number of visible elements.
     * 
     *  @default -1
     */
    public function get columnCount():int
    {
        return _columnCount;
    }

    /**
     *  Sets the <code>columnCount</code> property and dispatches
     *  a PropertyChangeEvent.
     * 
     *  This method is intended to be used by subclass updateDisplayList() 
     *  methods to sync the columnCount property with the actual number
     *  of visible columns.
     *
     *  @param value The number of visible columns.
     */
    protected function setColumnCount(value:int):void
    {
        if (_columnCount == value)
            return;
        var oldValue:int = _columnCount;
        _columnCount = value;
        dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "columnCount", oldValue, value));
    }
        
    
    //----------------------------------
    //  requestedColumnCount
    //----------------------------------

    private var _requestedColumnCount:int = -1;
    
    [Inspectable(category="General")]

    /**
     *  Specifies the number of elements to display.
     * 
     *  If <code>requestedColumnCount</code> is -1, then all of them elements are displayed.
     * 
     *  This property implies the layout's <code>measuredWidth</code>.
     * 
     *  If the width of the <code>target</code> has been explicitly set,
     *  then this property has no effect.
     * 
     *  @default -1
     */
    public function get requestedColumnCount():int
    {
        return _requestedColumnCount;
    }

    /**
     *  @private
     */
    public function set requestedColumnCount(value:int):void
    {
        if (_requestedColumnCount == value)
            return;
                               
        _requestedColumnCount = value;
        invalidateTargetSizeAndDisplayList();
    }    
    
    //----------------------------------
    //  columnWidth
    //----------------------------------
    
    private var _columnWidth:Number;

    [Inspectable(category="General")]

    /**
     *  Specifies the width of the columns if <code>variableColumnWidth</code>
     *  is false.
     * 
     *  If this property isn't explicitly set, then the measured width
     *  of the first element is returned.
     */
    public function get columnWidth():Number
    {
        if (!isNaN(_columnWidth))
            return _columnWidth;
        else if (!target || (target.numLayoutElements <= 0))
            return 0;
        else
            return target.getLayoutElementAt(0).getPreferredBoundsWidth();
    }

    /**
     *  @private
     */
    public function set columnWidth(value:Number):void
    {
        if (_columnWidth == value)
            return;
            
        _columnWidth = value;
        invalidateTargetSizeAndDisplayList();
    }

    //----------------------------------
    //  variableColumnWidth
    //----------------------------------

    /**
     *  @private
     */
    private var _variableColumnWidth:Boolean = true;

    [Inspectable(category="General")]

    /**
     *  If false, i.e. "fixed column width" is specified, the width of
     *  each element is set to the value of <code>columnWidth</code>.
     * 
     *  If the <code>columnWidth</code> property wasn't explicitly set,
     *  then it's initialized with the <code>measuredWidth</code> of
     *  the first element.
     * 
     *  The elements' <code>includeInLayout</code>, 
     *  <code>measuredWidth</code>, <code>minWidth</code>,
     *  and <code>percentWidth</code> properties are ignored when 
     *  <code>variableColumnWidth</code> is false.
     * 
     *  @default true
     */
    public function get variableColumnWidth():Boolean
    {
        return _variableColumnWidth;
    }

    /**
     *  @private
     */
    public function set variableColumnWidth(value:Boolean):void
    {
        if (value == _variableColumnWidth) return;
        
        _variableColumnWidth = value;
 		var layoutTarget:GroupBase = target;
        if (layoutTarget != null) {
    		layoutTarget.invalidateSize();
        	layoutTarget.invalidateDisplayList();
        }
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
     *  The index of the first column that's part of the layout and within
     *  the layout target's scrollRect, or -1 if nothing has been displayed yet.
     * 
     *  Note that the column may only be partially in view.
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
     *  The index of the last column that's part of the layout and within
     *  the layout target's scrollRect, or -1 if nothing has been displayed yet.
     * 
     *  Note that the column may only be partially in view.
     * 
     *  @see firstIndexInView
     *  @see inView
     */
    public function get lastIndexInView():int
    {
        return _lastIndexInView;
    }
    
    //----------------------------------
    //  verticalAlign
    //----------------------------------

    /**
     *  @private
     */
    private var _verticalAlign:String = VerticalAlign.TOP;

    [Inspectable(category="General")]

    /** 
     *  Vertical alignment of children in the container.
     *  Possible values are <code>"top"</code>, <code>"middle"</code>,
     *  <code>"bottom"</code>, <code>"justify"</code>, 
     *  and <code>"contentJustify"</code>.
     *  The default value is <code>"top"</code>, but some containers,
     *  such as List, use a different default value.  There are constants 
     *  for these values in <code>mx.layout.VerticalAlign</code>.
     */
    public function get verticalAlign():String
    {
        return _verticalAlign;
    }

    /**
     *  @private
     */
    public function set verticalAlign(value:String):void
    {
        if (value == _verticalAlign) 
            return;
        
        _verticalAlign = value;
        invalidateTargetDisplayList();
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
    
    /**
     *  An index is "in view" if the corresponding non-null layout element is 
     *  within the horizontal limits of the layout target's scrollRect
     *  and included in the layout.
     *  
     *  Returns 1.0 if the specified index is completely in view, 0.0 if
     *  it's not, and a value in between if the index is partially 
     *  within the view.
     * 
     *  If the specified index is partially within the view, the 
     *  returned value is the percentage of the corresponding
     *  layout element that's visible.
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
           
        var le:ILayoutElement = g.getLayoutElementAt(index);
        if ((le == null) || !le.includeInLayout)
            return 0.0;
            
        if (!clipContent)
            return 1.0;
            
        var c0:int = firstIndexInView; 
        var c1:int = lastIndexInView;
        
        // outside the visible index range
        if ((c0 == -1) || (c1 == -1) || (index < c0) || (index > c1))
            return 0.0;
            
        // within the visible index range, but not first or last            
        if ((index > c0) && (index < c1))
            return 1.0;

        // index is first (c0) or last (c1) visible column
        var x0:Number = g.horizontalScrollPosition;
        var x1:Number = x0 + g.width;
        var ix0:Number = le.getLayoutBoundsX();
        var ix1:Number = ix0 + le.getLayoutBoundsWidth();
        if (ix0 >= ix1)  // element has 0 or negative width
            return 1.0;
        if ((ix0 >= x0) && (ix1 <= x1))
            return 1.0;
        return (Math.min(x1, ix1) - Math.max(x0, ix0)) / (ix1 - ix0);
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
     *  Returns the index of the element that contains x, or -1.
     * 
     * @private 
     */
    private static function findIndexAt(x:Number, gap:int, g:GroupBase, i0:int, i1:int):int
    {
        var index:int = (i0 + i1) / 2;
        var element:ILayoutElement = g.getLayoutElementAt(index);        
        var elementX:Number = element.getLayoutBoundsX();
        // TBD: deal with null element, includeInLayout false.
        if ((x >= elementX) && (x < elementX + element.getLayoutBoundsWidth() + gap))
            return index;
        else if (i0 == i1)
            return -1;
        else if (x < elementX)
            return findIndexAt(x, gap, g, i0, Math.max(i0, index-1));
        else 
            return findIndexAt(x, gap, g, Math.min(index+1, i1), i1);
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
        // the elements that overlap the left and right edges of the scrollRect.
        // Values that are exactly equal to scrollRect.right aren't actually
        // rendered, since the left,right interval is only half open.
        // To account for that we back away from the right edge by a
        // hopefully infinitesimal amount.
     
        var x0:Number = scrollR.left;
        var x1:Number = scrollR.right - .0001;
        if (x1 <= x0)
        {
            setIndexInView(-1, -1);
            return;
        }

        // TBD: special case for variableRowHeight false

        var i0:int = findIndexAt(x0 + gap, gap, g, 0, n);
        var i1:int = findIndexAt(x1, gap, g, 0, n);
        // Special case: no element overlaps x0, is index 0 visible?
        if (i0 == -1)
        {   
            var index0:int = findLayoutElementIndex(g, 0, +1);
            if (index0 != -1)
            {
                var element0:ILayoutElement = g.getLayoutElementAt(index0); 
                var element0X:Number = element0.getLayoutBoundsX();
                var element0Width:Number = element0.getLayoutBoundsWidth();                 
                if ((element0X < x1) && ((element0X + element0Width) > x0))
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
                var element1X:Number = element1.getLayoutBoundsX();
                var element1Width:Number = element1.getLayoutBoundsWidth();                 
                if ((element1X < x1) && ((element1X + element1Width) > x0))
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
            return new Rectangle(element.getLayoutBoundsX(),
                                 element.getLayoutBoundsY(),
                                 element.getLayoutBoundsWidth(),
                                 element.getLayoutBoundsHeight());        
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
           // elementR, then if we're searching left (dir == -1),
           // and elementR's left edge is visible, then try again
           // with i-1.   Likewise for dir == +1.
           if (elementR)
           {
               var overlapsLeft:Boolean = (dir == -1) && (elementR.left == r.left) && (elementR.right >= r.right);
               var overlapsRight:Boolean = (dir == +1) && (elementR.right == r.right) && (elementR.left <= r.left);
               if (!(overlapsLeft || overlapsRight))             
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
     *  <code>LEFT</code>
     *  If the firstIndexInView element is partially visible then top justify
     *  it, otherwise top justify the element at the previous index.
     *  </li>
     * 
     *  <li> 
     *  <code>RIGHT</code>
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
     *  @see horizontalScrollPosition
     */
    override public function getHorizontalScrollPositionDelta(unit:ScrollUnit):Number
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
            case ScrollUnit.LEFT:
            case ScrollUnit.PAGE_LEFT:
                elementR = findLayoutElementBounds(g, firstIndexInView, -1, scrollR);
                break;

            case ScrollUnit.RIGHT:
            case ScrollUnit.PAGE_RIGHT:
                elementR = findLayoutElementBounds(g, lastIndexInView, +1, scrollR);
                break;

            default:
                return super.getHorizontalScrollPositionDelta(unit);
        }
        
        if (!elementR)
            return 0;
            
        var delta:Number = 0;     
        switch (unit)
        {
            case ScrollUnit.LEFT:
                delta = Math.max(-scrollR.width, elementR.left - scrollR.left);
                break;
                
            case ScrollUnit.RIGHT:
                delta = Math.min(scrollR.width, elementR.right - scrollR.right);
                break;
                
            case ScrollUnit.PAGE_LEFT:
                if ((elementR.left < scrollR.left) && (elementR.right >= scrollR.right))
                    delta = Math.max(-scrollR.width, elementR.left - scrollR.left);
                else
                    delta = elementR.right - scrollR.right;
                break;

            case ScrollUnit.PAGE_RIGHT:
                if ((elementR.left <= scrollR.left) && (elementR.right > scrollR.right))
                    delta = Math.min(scrollR.width, elementR.right - scrollR.right);
                else
                    delta = elementR.left - scrollR.left;
                break;
        }
        
        var maxDelta:Number = g.contentWidth - scrollR.width - scrollR.x;
        var minDelta:Number = -scrollR.x;
        return Math.min(maxDelta, Math.max(minDelta, delta));        
    }     

    public function variableColumnWidthMeasure(layoutTarget:GroupBase):void
    {
        var minWidth:Number = 0;
        var minHeight:Number = 0;
        var preferredWidth:Number = 0;
        var preferredHeight:Number = 0;
        var visibleWidth:Number = 0;
        var visibleColumns:uint = 0;
        var reqColumns:int = requestedColumnCount;        
        
        var count:uint = layoutTarget.numLayoutElements;
        var totalCount:uint = count; // How many elements will be laid out
        for (var i:int = 0; i < count; i++)
        {
            var le:ILayoutElement = layoutTarget.getLayoutElementAt(i);
            if (!le || !le.includeInLayout)
            {
            	totalCount--;
                continue;
            }            

            preferredHeight = Math.max(preferredHeight, le.getPreferredBoundsHeight());
            preferredWidth += le.getPreferredBoundsWidth(); 
            
            var vcr:Boolean = (reqColumns != -1) && (visibleColumns < reqColumns);
            if (vcr || (reqColumns == -1))
            {
                var mw:Number = hasPercentWidth(le)  ? le.getMinBoundsWidth() : le.getPreferredBoundsWidth();
                var mh:Number = hasPercentHeight(le) ? le.getMinBoundsHeight() : le.getPreferredBoundsHeight();                   
                minWidth += mw;
                minHeight = Math.max(minHeight, mh);
            }
            if (vcr) 
            {
            	visibleWidth = preferredWidth;
            	visibleColumns += 1;
            }
        }
        
        if (totalCount > 1)
        { 
            preferredWidth += gap * (totalCount - 1);
            var vgap:Number = (visibleColumns > 1) ? ((visibleColumns - 1) * gap) : 0;
            visibleWidth +=  vgap;
            minWidth += vgap;
        }
        
        layoutTarget.measuredWidth = (reqColumns == -1) ? preferredWidth : visibleWidth;
        layoutTarget.measuredHeight = preferredHeight;

        layoutTarget.measuredMinWidth = minWidth; 
        layoutTarget.measuredMinHeight = minHeight;
        
        layoutTarget.setContentSize(preferredWidth, preferredHeight);
    }
    
    
    private function fixedColumnWidthMeasure(layoutTarget:GroupBase):void
    {
        var cols:uint = layoutTarget.numLayoutElements;
        var visibleCols:uint = (requestedColumnCount == -1) ? cols : requestedColumnCount;

        var cw:Number = columnWidth; // can be expensive to compute
        var contentWidth:Number = (cols * cw) + ((cols > 1) ? (gap * (cols - 1)) : 0);
        var visibleWidth:Number = (visibleCols * cw) + ((visibleCols > 1) ? (gap * (visibleCols - 1)) : 0);
        
        var rowHeight:Number = layoutTarget.explicitHeight;
        var minRowHeight:Number = rowHeight;
        if (isNaN(rowHeight)) 
        {
			minRowHeight = rowHeight = 0;
	        var count:uint = layoutTarget.numLayoutElements;
	        for (var i:int = 0; i < count; i++)
	        {
	            var layoutElement:ILayoutElement = layoutTarget.getLayoutElementAt(i);
	            if (!layoutElement || !layoutElement.includeInLayout) continue;
	            rowHeight = Math.max(rowHeight, layoutElement.getPreferredBoundsHeight());
	            var elementMinHeight:Number = hasPercentHeight(layoutElement) ? layoutElement.getMinBoundsHeight() : layoutElement.getPreferredBoundsHeight();
	            minRowHeight = Math.max(minRowHeight, elementMinHeight);
	        }
        }     
        
        layoutTarget.measuredWidth = visibleWidth;
        layoutTarget.measuredHeight = rowHeight;
        
        layoutTarget.measuredMinWidth = visibleWidth;
        layoutTarget.measuredMinHeight = minRowHeight;
        
        layoutTarget.setContentSize(contentWidth, rowHeight);
    }
    

    override public function measure():void
    {
        super.measure();
        
    	var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;
            
        if (variableColumnWidth) 
        	variableColumnWidthMeasure(layoutTarget);
        else 
        	fixedColumnWidthMeasure(layoutTarget);
    }    
    
    
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
    	var layoutTarget:GroupBase = target; 
        if (!layoutTarget)
            return;
        
        var layoutElement:ILayoutElement;
        var count:uint = layoutTarget.numLayoutElements;
        
        // If verticalAlign is top, we don't need to figure out the contentHeight.
        // Otherwise the contentHeight is used to position the element and even size 
        // the element if it's "contentJustify" or "justify".
        var contentHeight:Number = unscaledHeight;
        
        
        // TODO: in the middle or bottom case, we end up calculating percentHeight 
        // twice.  Once here for the contentHeight and once in distributeWidth
        // to size that particular element.
        if (verticalAlign != VerticalAlign.TOP)
        {
            for (var i:int = 0; i < count; i++)
            {
                layoutElement = layoutTarget.getLayoutElementAt(i);
                if (!layoutElement || !layoutElement.includeInLayout)
                    continue;
                
                var layoutElementHeight:Number;
                if (hasPercentHeight(layoutElement))
                    layoutElementHeight = calculatePercentHeight(layoutElement, unscaledHeight);
                else
                    layoutElementHeight = layoutElement.getPreferredBoundsHeight();
                    
                contentHeight = Math.max(contentHeight, layoutElementHeight);
            }
        }

        // If we're justifying the elements, then all heights should be set to
        // unscaledHeight.  If we're content justifying the elements, then 
        // all heights should be set to the contentHeight.
        // Otherwise restrictedHeight is ignored in distributedWidth.
        var restrictedHeight:Number;
        if (verticalAlign == VerticalAlign.JUSTIFY)
            restrictedHeight = unscaledHeight;
        else if (verticalAlign == VerticalAlign.CONTENT_JUSTIFY)
            restrictedHeight = contentHeight;

        distributeWidth(unscaledWidth, unscaledHeight, restrictedHeight);    
        
        // default to top (0)
        var vAlign:Number = 0;
        if (verticalAlign == VerticalAlign.MIDDLE)
            vAlign = .5;
        else if (verticalAlign == VerticalAlign.BOTTOM)
            vAlign = 1;
        
        // If columnCount wasn't set, then as the LayoutElements are positioned
        // we'll count how many columns fall within the layoutTarget's scrollRect
        var visibleColumns:uint = 0;
        var minVisibleX:Number = layoutTarget.horizontalScrollPosition;
        var maxVisibleX:Number = minVisibleX + unscaledWidth
            
        // Finally, position the LayoutElements and find the first/last
        // visible indices, the content size, and the number of 
        // visible elements. 
        var x:Number = 0;
        var maxX:Number = 0;
        var maxY:Number = 0;     
        var firstColInView:int = -1;
        var lastColInView:int = -1;
                
        for (var index:int = 0; index < count; index++)
        {
            layoutElement = layoutTarget.getLayoutElementAt(index);
            if (!layoutElement || !layoutElement.includeInLayout)
                continue;
                
            // Set the layout element's position
            var y:Number = (contentHeight - layoutElement.getLayoutBoundsHeight()) * vAlign;
            layoutElement.setLayoutBoundsPosition(x, y);
            
            // Update maxX,Y, first,lastVisibleIndex, and x
            var dx:Number = layoutElement.getLayoutBoundsWidth();
            var dy:Number = layoutElement.getLayoutBoundsHeight();
            maxX = Math.max(maxX, x + dx);
            maxY = Math.max(maxY, y + dy);            
            if (!clipContent || 
                ((x < maxVisibleX) && ((x + dx) > minVisibleX)) || 
                ((dx <= 0) && ((x == maxVisibleX) || (x == minVisibleX))))            
            {
                visibleColumns += 1;
                if (firstColInView == -1)
                   firstColInView = lastColInView = index;
                else
                   lastColInView = index;
            }                
            x += dx + gap;
        }

        setColumnCount(visibleColumns);  
        setIndexInView(firstColInView, lastColInView);
        layoutTarget.setContentSize(maxX, maxY);      	      
    }


    /**
     *  This function sets the width of each child
     *  so that the widths add up to <code>width</code>. 
     *  Each child is set to its preferred width
     *  if its percentWidth is zero.
     *  If its percentWidth is a positive number,
     *  the child grows (or shrinks) to consume its
     *  share of extra space.
     *  
     *  The return value is any extra space that's left over
     *  after growing all children to their maxWidth.
     */
    public function distributeWidth(width:Number,
                                    height:Number,
                                    restrictedHeight:Number):Number
    {
        var spaceToDistribute:Number = width;
        var totalPercentWidth:Number = 0;
        var childInfoArray:Array = [];
        var childInfo:HLayoutElementFlexChildInfo;
        var newHeight:Number;
        var layoutElement:ILayoutElement;
        
        // columnWidth can be expensive to compute
        var cw:Number = (variableColumnWidth) ? 0 : columnWidth;
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
            
            if (hasPercentWidth(layoutElement) && variableColumnWidth)
            {
                totalPercentWidth += layoutElement.percentWidth;

                childInfo = new HLayoutElementFlexChildInfo();
                childInfo.layoutElement = layoutElement;
                childInfo.percent    = layoutElement.percentWidth;
                childInfo.min        = layoutElement.getMinBoundsWidth();
                childInfo.max        = layoutElement.getMaxBoundsWidth();
                
                childInfoArray.push(childInfo);                
            }
            else
            {
                sizeLayoutElement(layoutElement, height, verticalAlign, 
                               restrictedHeight, NaN, variableColumnWidth, cw);
                
                spaceToDistribute -= layoutElement.getLayoutBoundsWidth();
            } 
        }
        
        if (totalCount > 1)
            spaceToDistribute -= (totalCount-1) * gap;

        // Distribute the extra space among the flexible children
        if (totalPercentWidth)
        {
            spaceToDistribute = Flex.flexChildrenProportionally(width,
                                                                spaceToDistribute,
                                                                totalPercentWidth,
                                                                childInfoArray);
            
            for each (childInfo in childInfoArray)
            {
                sizeLayoutElement(childInfo.layoutElement, height, verticalAlign, 
                               restrictedHeight, childInfo.size, 
                               variableColumnWidth, cw); 
            }
        }
        return spaceToDistribute;
    }

}
}

[ExcludeClass]

import mx.core.ILayoutElement;
import mx.containers.utilityClasses.FlexChildInfo;

class HLayoutElementFlexChildInfo extends FlexChildInfo
{
    public var layoutElement:ILayoutElement;	
}
