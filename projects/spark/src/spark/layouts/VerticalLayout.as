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
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.components.baseClasses.GroupBase;
import mx.containers.utilityClasses.Flex;
import mx.core.ILayoutElement;
import mx.events.PropertyChangeEvent;
import mx.layout.LinearLayoutVector;


/**
 *  Documentation is not currently available.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
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
    	                                                         layoutElement.getMinBoundsWidth(),
    	                                                         layoutElement.getMaxBoundsWidth() );
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
            layoutElement.setLayoutBoundsSize(newWidth, height);
        else
            layoutElement.setLayoutBoundsSize(newWidth, rowHeight);
    }
        
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  The vertical space between layout elements.
     * 
     *  Note that the gap is only applied between layout elements, so if there's
     *  just one element, the gap has no effect on the layout.
     * 
     *  @default 6
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        llv.gap = value;
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

    [Inspectable(category="General", enumeration="left,right,center,justify,contentJustify", defaultValue="left")]

    /** 
     *  Horizontal alignment of layout elements.
     * 
     *  If the value is one of "left", "right", "center"  then the 
     *  layout element is aligned relative to the target's contentWidth.
     * 
     *  If the value is "contentJustify" then the layout element's actual
     *  width is set to the contentWidth.
     * 
     *  If the value is "justify" then the layout element's actual width
     *  is set to the target's width.
     *
     *  This property does not affect the layout's measured size.
     *  
     *  @default "left"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  The measured size of this layout will be big enough to display 
     *  the first <code>requestedRowCount</code> layout elements. 
     * 
     *  If <code>requesteRowCount</code> is -1, then the measured
     *  size will be big enough for all of the layout elements.
     * 
     *  This property implies the layout target's <code>measuredHeight</code>.
     * 
     *  If the actual size of the <code>target</code> has been explicitly set,
     *  then this property has no effect.
     * 
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  If variableRowHeight="false" then 
     *  this property specifies the actual height of each layout element.
     * 
     *  If variableRowHeight="true" (the default), then this property
     *  has no effect.
     * 
     *  The default value of this property is the preferred height
     *  of the typicalLayoutElement.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get rowHeight():Number
    {
        if (!isNaN(_rowHeight))
            return _rowHeight;
        else 
        {
            var elt:ILayoutElement = typicalLayoutElement
            return (elt) ? elt.getPreferredBoundsHeight() : 0;
        }
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
     *  Specifies that layout elements are to be allocated their 
     *  preferred height.
     * 
     *  Setting this property to false specifies fixed height rows.
     * 
     *  If false, the actual height of each layout element will be 
     *  the value value of <code>rowHeight</code>.
     * 
     *  Setting this property to false causes the layout to ignore 
     *  layout elements' percentHeight.
     * 
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
	 *  The index of the first layout element that's part of the 
	 *  layout and within the layout target's scrollRect, or -1 
	 *  if nothing has been displayed yet.
	 *  
	 *  "Part of the layout" means that the element is non-null
	 *  and that its includeInLayout property is true.
	 * 
	 *  Note that the layout element may only be partially in view.
	 * 
	 *  @see lastIndexInView
	 *  @see inView
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
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
     *  "Part of the layout" means that the element is non-null
     *  and that its includeInLayout property is true.
     * 
     *  Note that the row may only be partially in view.
     * 
     *  @see firstIndexInView
     *  @see inView
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function inView(index:int):Number 
	{
		var g:GroupBase = GroupBase(target);
	    if (!g)
	        return 0.0;
	        
	    if ((index < 0) || (index >= g.numElements))
	       return 0.0;
	       
        if (!clipAndEnableScrolling)
            return 1.0;

	       
        var r0:int = firstIndexInView;	
        var r1:int = lastIndexInView;
        
        // outside the visible index range
        if ((r0 == -1) || (r1 == -1) || (index < r0) || (index > r1))
            return 0.0;

        // within the visible index range, but not first or last            
        if ((index > r0) && (index < r1))
            return 1.0;

        // get the layout element's Y and Height
	    var eltY:Number;
	    var eltHeight:Number;
	    if (useVirtualLayout)
	    {
	        eltY = llv.start(index);
	        eltHeight = llv.getMajorSize(index);
	    }
	    else 
	    {
            var elt:ILayoutElement = g.getElementAt(index);
            if (!elt || !elt.includeInLayout)
                return 0.0;
            eltY = elt.getLayoutBoundsY();
            eltHeight = elt.getLayoutBoundsHeight();
	    }
            
        // So, index is either the first or last row in the scrollRect
        // and potentially partially visible.
        //   y0,y1 - scrollRect top,bottom edges
        //   iy0, iy1 - layout element top,bottom edges
        var y0:Number = g.verticalScrollPosition;
        var y1:Number = y0 + g.height;
        var iy0:Number = eltY;
        var iy1:Number = iy0 + eltHeight;
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
        var element:ILayoutElement = g.getElementAt(index);	    
	    var elementY:Number = element.getLayoutBoundsY();
        var elementHeight:Number = element.getLayoutBoundsHeight();
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
        var n:int = g.numElements;
        while((i >= 0) && (i < n))
        {
           var element:ILayoutElement = g.getElementAt(i);
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
    *  
    *  @langversion 3.0
    *  @playerversion Flash 10
    *  @playerversion AIR 1.5
    *  @productversion Flex 4
    */
    override protected function scrollPositionChanged():void
    {
        super.scrollPositionChanged();
        
        var g:GroupBase = target;
        if (!g)
            return;     

        var n:int = g.numElements - 1;
        if (n < 0) 
        {
            setIndexInView(-1, -1);
            return;
        }
        
        var scrollR:Rectangle = getTargetScrollRect();
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

        var i0:int;
        var i1:int;
        if (useVirtualLayout)
        {
            i0 = llv.indexOf(y0);
            i1 = llv.indexOf(y1);
        }
        else
        {
            i0 = findIndexAt(y0 + gap, gap, g, 0, n);
            i1 = findIndexAt(y1, gap, g, 0, n);
        }
        
        // Special case: no element overlaps y0, is index 0 visible?
        if (i0 == -1)
        {   
            var index0:int = findLayoutElementIndex(g, 0, +1);
            if (index0 != -1)
            {
                var element0:ILayoutElement = g.getElementAt(index0); 
                var element0Y:Number = element0.getLayoutBoundsY();
                var elementHeight:Number = element0.getLayoutBoundsHeight();                 
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
                var element1:ILayoutElement = g.getElementAt(index1); 
                var element1Y:Number = element1.getLayoutBoundsY();
                var element1Height:Number = element1.getLayoutBoundsHeight();                 
                if ((element1Y < y1) && ((element1Y + element1Height) > y0))
                    i1 = index1;
            }
        }
        
        if (useVirtualLayout)
            g.invalidateDisplayList();
                
        setIndexInView(i0, i1);
    }

    /**
     *  If the element at index i is non-null and includeInLayout,
     *  then return it's actual bounds, otherwise return null.
     * 
     *  @private
     */
    private function layoutElementBounds(g:GroupBase, i:int):Rectangle
    {
        if (useVirtualLayout)
            return llv.getBounds(i);        
        else 
        {
            var element:ILayoutElement = g.getElementAt(i);
            if (element && element.includeInLayout)
            {
                return new Rectangle(element.getLayoutBoundsX(),
                                     element.getLayoutBoundsY(),
                                     element.getLayoutBoundsWidth(),
                                     element.getLayoutBoundsHeight());        
            }
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
        var n:int = g.numElements;

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
     *  @private 
     */
    override protected function elementBoundsAboveScrollRect(scrollRect:Rectangle):Rectangle
    {
        return findLayoutElementBounds(target, firstIndexInView, -1, scrollRect);
    } 

    /**
     *  @private 
     */
    override protected function elementBoundsBelowScrollRect(scrollRect:Rectangle):Rectangle
    {
        return findLayoutElementBounds(target, lastIndexInView, +1, scrollRect);
    } 

    /**
     *  @private
     *  Compute exact values for measuredWidth,Height and  measuredMinWidth,Height.
     * 
     *  If requestedRowCount is not -1, measure as many layout elements,
     *  padding with typicalLayoutElement if needed, starting with index 0.  
     *  Otherwise measure all of the layout elements.
     */
    private function measureReal(layoutTarget:GroupBase):void
    {
        var layoutEltCount:int = layoutTarget.numElements;
        var reqEltCount:int = requestedRowCount; // -1 means "all elements"
        var eltCount:uint = Math.max(reqEltCount, layoutEltCount);
        var eltInLayoutCount:uint = 0; // elts that have been measured

        var preferredHeight:Number = 0; // sum of the elt preferred heights
        var preferredWidth:Number = 0;  // max of the elt preferred widths
        var minHeight:Number = 0; // sum of the elt minimum heights
        var minWidth:Number = 0;  // max of the elt minimum widths

        var fixedRowHeight:Number = NaN;
        if (!variableRowHeight)
            fixedRowHeight = rowHeight;  // may query typicalLayoutElement, elt at index=0

        for (var i:uint = 0; i < eltCount; i++)
        {
            if ((reqEltCount != -1) && (eltInLayoutCount >= reqEltCount))
                break;

            if (i < layoutEltCount) // target.numElements
                var elt:ILayoutElement = layoutTarget.getElementAt(i);
            else // target.numElements < requestedElementCount, so "pad"
                elt = typicalLayoutElement;
            if (!elt || !elt.includeInLayout)
                continue;
                
            var height:Number = isNaN(fixedRowHeight) ? elt.getPreferredBoundsHeight() : fixedRowHeight;
            var width:Number = elt.getPreferredBoundsWidth();
            preferredHeight += height;
            preferredWidth = Math.max(preferredWidth, width);
            minHeight += (isNaN(elt.percentHeight)) ? height : elt.getMinBoundsHeight();
            minWidth = Math.max(minWidth, (isNaN(elt.percentWidth)) ? width : elt.getMinBoundsWidth());

            eltInLayoutCount += 1;
        }
        
        if (eltInLayoutCount > 1)
        { 
            var vgap:Number = gap * (eltInLayoutCount - 1);
            preferredHeight += vgap;
            minHeight += vgap;
        }
        
        layoutTarget.measuredHeight = preferredHeight;
        layoutTarget.measuredWidth = preferredWidth;
        layoutTarget.measuredMinHeight = minHeight;
        layoutTarget.measuredMinWidth  = minWidth;
    }
    
    private var llv:LinearLayoutVector = new LinearLayoutVector();
    
    /**
     *  @private
     *  Syncs the LinearLayoutVector llv with typicalLayoutElement and
     *  the target's numElements.  Calling this function accounts
     *  for the possibility that the typicalLayoutElement has changed, or
     *  something that its preferred size depends on has changed.
     */
     private function updateLLV(layoutTarget:GroupBase):void
     {
        var typicalElt:ILayoutElement = typicalLayoutElement;
        if (typicalElt)
        {
            var typicalWidth:Number = typicalElt.getPreferredBoundsWidth();
            var typicalHeight:Number = typicalElt.getPreferredBoundsHeight();
            llv.minorSize = Math.max(llv.minorSize, typicalWidth);
            llv.defaultMajorSize = typicalHeight;        
        }
        if (layoutTarget)
            llv.length = layoutTarget.numElements;        
     }

    /**
     *  @private 
     *  Compute potentially approximate values for measuredWidth,Height and 
     *  measuredMinWidth,Height.
     * 
     *  This method does not get layout elements from the target except
     *  as a side effect of calling typicalLayoutElement.
     * 
     *  If variableRowHeight="false" then all dimensions are based on 
     *  typicalLayoutElement and the sizes already cached in llv.  The 
     *  llv's defaultMajorSize, minorSize, and minMinorSize 
     *  are based on typicalLayoutElement.
     */
    private function measureVirtual(layoutTarget:GroupBase):void
    {
        var eltCount:uint = layoutTarget.numElements;
        var measuredEltCount:int = (requestedRowCount != -1) ? requestedRowCount : eltCount;
        
        updateLLV(layoutTarget);     
        if (variableRowHeight)
            layoutTarget.measuredHeight =  llv.end(measuredEltCount - 1);
        else
        {
            var vgap:Number = (measuredEltCount > 1) ? (measuredEltCount - 1) * gap : 0;
            layoutTarget.measuredHeight = (measuredEltCount * rowHeight) + vgap;
        }
        layoutTarget.measuredWidth = llv.minorSize;
                
        layoutTarget.measuredMinWidth = layoutTarget.measuredWidth;
        layoutTarget.measuredMinHeight = layoutTarget.measuredHeight;
    }

    /**
     *  If requestedRowCount is specified then as many layout elements
     *  or "rows" are measured, starting with element 0, otherwise all of the 
     *  layout elements are measured.
     *  
     *  If requestedRowCount is specified and is greater than the
     *  number of layout elements, then the typicalLayoutElement is used
     *  in place of the missing layout elements.
     * 
     *  If variableRowHeight="true", then the layoutTarget's measuredHeight 
     *  is the sum of preferred heights of the layout elements, plus the sum of the
     *  gaps between elements, and its measuredWidth is the max of the elements' 
     *  preferred widths.
     * 
     *  If variableRowHeight="false", then the layoutTarget's measuredHeight 
     *  is rowHeight multiplied by the number or layout elements, plus the 
     *  sum of the gaps between elements.
     * 
     *  The layoutTarget's measuredMinHeight is the sum of the minHeights of 
     *  layout elements that have specified a value for the percentHeight
     *  property, and the preferredHeight of the elements that have not, 
     *  plus the sum of the gaps between elements.
     * 
     *  The difference reflects the fact that elements which specify 
     *  percentHeight are considered to be "flexible" and updateDisplayList 
     *  will give flexible components at least their minHeight.  
     * 
     *  Layout elements that aren't flexible always get their preferred height.
     * 
     *  The layoutTarget's measuredMinWidth is the max of the minWidths for 
     *  elements that have specified percentWidth (that are "flexible") and the 
     *  preferredWidth of the elements that have not.
     * 
     *  As before the difference is due to the fact that flexible items are only
     *  guaranteed their minWidth.
     * 
    *  
    *  @langversion 3.0
    *  @playerversion Flash 10
    *  @playerversion AIR 1.5
    *  @productversion Flex 4
    */
    override public function measure():void
    {
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;
            
        if (layoutTarget.numElements == 0)
        {
            layoutTarget.measuredWidth = 0;
            layoutTarget.measuredHeight = 0;
            layoutTarget.measuredMinWidth = 0;
            layoutTarget.measuredMinHeight = 0;
        }            
        else if (useVirtualLayout)
            measureVirtual(layoutTarget);
        else 
            measureReal(layoutTarget);
    }
    
    //  - virtual layout only - 
    private function calculateElementWidth(elt:ILayoutElement, targetWidth:Number, containerWidth:Number):Number
    {
       // If percentWidth is specified then the element's width is the percentage
       // of targetWidth clipped to min/maxWidth and to (upper limit) targetWidth.
       var percentWidth:Number = elt.percentWidth;
       if (!isNaN(percentWidth))
       {
          var width:Number = percentWidth * 0.01 * targetWidth;
          return Math.min(targetWidth, Math.min(elt.getMaxBoundsWidth(), Math.max(elt.getMinBoundsWidth(), width)));
       }
       switch(horizontalAlign)
       {
           case HorizontalAlign.JUSTIFY: 
               return targetWidth;
           case HorizontalAlign.CONTENT_JUSTIFY: 
               return Math.max(elt.getPreferredBoundsWidth(), containerWidth);
       }
       return elt.getPreferredBoundsWidth();
    }
    
    //  - virtual layout only - 
    private function calculateElementX(elt:ILayoutElement, eltWidth:Number, containerWidth:Number):Number
    {
       switch(horizontalAlign)
       {
           case HorizontalAlign.CENTER: 
               return (containerWidth - eltWidth) * 0.5;
           case HorizontalAlign.RIGHT: 
               return containerWidth - eltWidth;
       }
       return 0;  // HorizontalAlign.LEFT
    }


    /**
     *  @private
     *  Update the layout of the virtualized elements that overlap
     *  the scrollRect's vertical extent.
     *
     *  The height of each layout element will be its preferred height, and its
     *  y will be the bottom of the previous item, plus the gap.
     * 
     *  No support for percentHeight, includeInLayout=false, or null layoutElements,
     * 
     *  The width of each layout element will be set to its preferred width, unless
     *  one of the following is true:
     * 
     *  - If percentWidth is specified for this element, then its width will be the
     *  specified percentage of the target's actual (unscaled) width, clipped 
     *  the layout element's minimum and maximum width.
     * 
     *  - If horizontalAlign is "justify", then the element's width will
     *  be set to the target's actual (unscaled) width.
     * 
     *  - If horizontalAlign is "contentJustify", then the element's width
     *  will be set to the larger of the target's width and its content width.
     * 
     *  The X coordinate of each layout element will be set to 0 unless one of the
     *  following is true:
     * 
     *  - If horizontalAlign is "center" then x is set so that the element's preferred
     *  width is centered within the larger of the contentWidth, target width:
     *      x = (Math.max(contentWidth, target.width) - layoutElementWidth) * 0.5
     * 
     *  - If horizontalAlign is "right" the x is set so that the element's right
     *  edge is aligned with the the right edge of the content:
     *      x = (Math.max(contentWidth, target.width) - layoutElementWidth)
     * 
     *  Implementation note: unless horizontalAlign is either "justify" or 
     *  "left", the layout elements' x or width depends on the contentWidth.
     *  The contentWidth is a maximum and although it may be updated to 
     *  different value after all (viewable) elements have been laid out, it
     *  often does not change.  For that reason we use the current contentWidth
     *  for the initial layout and then, if it has changed, we loop through 
     *  the layout items again and fix up the x/width values.
     */
    private function updateDisplayListVirtual():void
    {
        var layoutTarget:GroupBase = target; 
        var eltCount:int = layoutTarget.numElements;
        var targetWidth:Number = layoutTarget.width;
        var minVisibleY:Number = layoutTarget.verticalScrollPosition;
        var maxVisibleY:Number = minVisibleY + layoutTarget.height;
       
        updateLLV(layoutTarget);
        var startIndex:int = llv.indexOf(minVisibleY);     
            
        var fixedRowHeight:Number = NaN;
        if (!variableRowHeight)
            fixedRowHeight = rowHeight;  // may query typicalLayoutElement, elt at index=0
         
        var contentWidth:Number = llv.minorSize;
        var containerWidth:Number = Math.max(contentWidth, targetWidth);        
        var y:Number = llv.start(startIndex);
        var index:int = startIndex;
        
        // First pass: compute element x,y,width,height based on 
        // current contentWidth; cache computed widths/heights in llv.
        for (; (y < maxVisibleY) && (index < eltCount); index++)
        {
            var elt:ILayoutElement = layoutTarget.getElementAt(index);
            var h:Number = (isNaN(fixedRowHeight)) ? elt.getPreferredBoundsHeight() : fixedRowHeight;
            var w:Number = calculateElementWidth(elt, targetWidth, containerWidth);
            var x:Number = calculateElementX(elt, w, containerWidth);
            elt.setLayoutBoundsPosition(x, y);
            elt.setLayoutBoundsSize(w, h);            
            llv.cacheDimensions(index, elt);
            y += h + gap;
        }
        var endIndex:int = index - 1;

        // Second pass: if neccessary, fix up x and width values based
        // on the updated contentWidth
        if (llv.minorSize != contentWidth)
        {
            contentWidth = llv.minorSize;
            containerWidth = Math.max(contentWidth, targetWidth);            
            if ((horizontalAlign != HorizontalAlign.LEFT) && (horizontalAlign != HorizontalAlign.JUSTIFY))
            {
                for (index = startIndex; index <= endIndex; index++)
                {
                    elt = layoutTarget.getElementAt(index);
                    w = calculateElementWidth(elt, targetWidth, containerWidth);
                    x = calculateElementX(elt, w, containerWidth);
                    elt.setLayoutBoundsPosition(x, elt.getLayoutBoundsY());
                    elt.setLayoutBoundsSize(w, elt.getLayoutBoundsHeight());         
                }
            }
        }

        setRowCount(index - startIndex);
        setIndexInView(startIndex, endIndex);
        layoutTarget.setContentSize(contentWidth, llv.end(llv.length - 1));
    }
    

    private function updateDisplayListReal():void
    {
        var layoutTarget:GroupBase = target;
        var targetWidth:Number = layoutTarget.width;
        var targetHeight:Number = layoutTarget.height;
        
        var layoutElement:ILayoutElement;
        var count:uint = layoutTarget.numElements;
        
        // If horizontalAlign is left, we don't need to figure out the contentWidth
        // Otherwise the contentWidth is used to position the element and even size 
        // the element if it's "contentJustify" or "justify".
        var containerWidth:Number = targetWidth;        
        
        // TODO: in the center or right case, we end up calculating percentWidth 
        // twice.  Once here for the contentWidth and once in distributeHeight
        // to size that particular element.
        if (horizontalAlign != HorizontalAlign.LEFT)
        {
            for (var i:int = 0; i < count; i++)
            {
                layoutElement = layoutTarget.getElementAt(i);
                if (!layoutElement || !layoutElement.includeInLayout)
                    continue;

                var layoutElementWidth:Number;
                if (hasPercentWidth(layoutElement))
                    layoutElementWidth = calculatePercentWidth(layoutElement, targetWidth);
                else
                    layoutElementWidth = layoutElement.getPreferredBoundsWidth();
                
                containerWidth = Math.max(containerWidth, layoutElementWidth);
            }
        }

        // If we're justifying the elements, then all widths should be set to
        // targetWidth.  If we're content justifying the elements, then 
        // all widths should be set to the contentWidth.
        // Otherwise restrictedWidth is ignored in distributedHeight.
        var restrictedWidth:Number;
        if (horizontalAlign == HorizontalAlign.JUSTIFY)
            restrictedWidth = targetWidth;
        else if (horizontalAlign == HorizontalAlign.CONTENT_JUSTIFY)
            restrictedWidth = containerWidth;
    
        distributeHeight(targetWidth, targetHeight, restrictedWidth);
        
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
        var maxVisibleY:Number = minVisibleY + targetHeight;
        
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
            layoutElement = layoutTarget.getElementAt(index);
            if (!layoutElement || !layoutElement.includeInLayout)
                continue;
                
            // Set the layout element's position
            var x:Number = (containerWidth - layoutElement.getLayoutBoundsWidth()) * hAlign;
            layoutElement.setLayoutBoundsPosition(x, y);
                            
            // Update maxX,Y, first,lastVisibleIndex, and y
            var dx:Number = layoutElement.getLayoutBoundsWidth();
            var dy:Number = layoutElement.getLayoutBoundsHeight();
            
            maxX = Math.max(maxX, x + dx);
            maxY = Math.max(maxY, y + dy);
            if (!clipAndEnableScrolling ||
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        var count:uint = target.numElements;
        var totalCount:uint = count; // number of elements to use in gap calculation
        
        // If the child is flexible, store information about it in the
        // childInfoArray. For non-flexible children, just set the child's
        // width and height immediately.
        for (var index:int = 0; index < count; index++)
        {
            layoutElement = target.getElementAt(index);
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
                childInfo.min        = layoutElement.getMinBoundsHeight();
                childInfo.max        = layoutElement.getMaxBoundsHeight();
                
                childInfoArray.push(childInfo);                
            }
            else
            {
                sizeLayoutElement(layoutElement, width, horizontalAlign, 
                               restrictedWidth, NaN, variableRowHeight, rh);
                
                spaceToDistribute -= layoutElement.getLayoutBoundsHeight();
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
    
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        var layoutTarget:GroupBase = target; 
        if (!layoutTarget)
            return;
            
        if (layoutTarget.numElements == 0)
        {
            setRowCount(0);
            setIndexInView(-1, -1);
            layoutTarget.setContentSize(0, 0);            
        }
        else if (useVirtualLayout) 
            updateDisplayListVirtual();
        else
            updateDisplayListReal();
    } 
}
}

[ExcludeClass]

import mx.core.ILayoutElement;
import mx.containers.utilityClasses.FlexChildInfo;

class LayoutElementFlexChildInfo extends FlexChildInfo
{
    public var layoutElement:ILayoutElement;	
}
