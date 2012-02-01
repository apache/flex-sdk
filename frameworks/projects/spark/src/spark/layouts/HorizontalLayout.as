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

import mx.containers.utilityClasses.Flex;
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
    	var percentHeight:Number = LayoutElementHelper.pinBetween(Math.round(layoutElement.percentHeight * 0.01 * height),
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
            if (!isNaN(layoutElement.percentHeight))
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  The horizontal space between layout elements.
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  The measured size of this layout will be big enough to display 
     *  the first <code>requestedColumnCount</code> layout elements. 
     * 
     *  If <code>requesteColumnCount</code> is -1, then the measured
     *  size will be big enough for all of the layout elements.
     * 
     *  This property implies the layout target's <code>measuredWidth</code>.
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
     *  If variableColumnWidth="false" then 
     *  this property specifies the actual width of each layout element.
     * 
     *  If variableColumnWidth="true" (the default), then this property
     *  has no effect.
     * 
     *  The default value of this property is the preferred width
     *  of the typicalLayoutElement.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get columnWidth():Number
    {
        if (!isNaN(_columnWidth))
            return _columnWidth;
        else 
        {
            var elt:ILayoutElement = typicalLayoutElement
            return (elt) ? elt.getPreferredBoundsWidth() : 0;
        }
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
     *  Specifies that layout elements are to be allocated their 
     *  preferred width.
     * 
     *  Setting this property to false specifies fixed width columns.
     * 
     *  If false, the actual width of each layout element will be 
     *  the value value of <code>columnWidth</code>.
     * 
     *  Setting this property to false causes the layout to ignore 
     *  layout elements' percentWidth.
     * 
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  The index of the last column that's part of the layout and within
     *  the layout target's scrollRect, or -1 if nothing has been displayed yet.
     * 
     *  Note that the column may only be partially in view.
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
    
    //----------------------------------
    //  verticalAlign
    //----------------------------------

    /**
     *  @private
     */
    private var _verticalAlign:String = VerticalAlign.TOP;

    [Inspectable(category="General", enumeration="top,bottom,middle,justify,contentJustify", defaultValue="top")]

    /** 
     *  Vertical alignment of layout elements.
     * 
     *  If the value is one of "bottom", "middle", "top"  then the 
     *  layout element is aligned relative to the target's contentHeight.
     * 
     *  If the value is "contentJustify" then the layout element's actual
     *  height is set to the contentHeight.
     * 
     *  If the value is "justify" then the layout element's actual height
     *  is set to the target's height.
     *
     *  This property does not affect the layout's measured size.
     *  
     *  @default "top"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function inView(index:int):Number 
    {
        var g:GroupBase = target;
        if (!g)
            return 0.0;
                
        if ((index < 0) || (index >= g.numElements))
            return 0.0;
               
        if (!clipAndEnableScrolling)
            return 1.0;
               
        var r0:int = firstIndexInView;  
        var r1:int = lastIndexInView;
        
        // index is outside the "in view" or visible range
        if ((r0 == -1) || (r1 == -1) || (index < r0) || (index > r1))
            return 0.0;

        // within the visible index range, but not first or last            
        if ((index > r0) && (index < r1))
            return 1.0;

        // get the layout element's X and Width
        var eltX:Number;
        var eltWidth:Number;
        if (useVirtualLayout)
        {
            eltX = llv.start(index);
            eltWidth = llv.getMajorSize(index);
        }
        else 
        {
            var elt:ILayoutElement = g.getElementAt(index);
            if (!elt || !elt.includeInLayout)
                return 0.0;
            eltX = elt.getLayoutBoundsX();
            eltWidth = elt.getLayoutBoundsWidth();
        }
            
        // index is either the first or last column in the scrollRect
        // and potentially partially visible.
        //   x0,x1 - scrollRect left,right edges
        //   ix0, ix1 - layout element left,right edges
        var x0:Number = g.horizontalScrollPosition; 
        var x1:Number = x0 + g.width;
        var ix0:Number = eltX;
        var ix1:Number = ix0 + eltWidth;
        if (ix0 >= ix1)  // element has 0 or negative height
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
        var element:ILayoutElement = g.getElementAt(index);        
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

        var i0:int;
        var i1:int;
        if (useVirtualLayout)
        {
            i0 = llv.indexOf(x0);
            i1 = llv.indexOf(x1);
        }
        else
        {
            i0 = findIndexAt(x0 + gap, gap, g, 0, n);
            i1 = findIndexAt(x1, gap, g, 0, n);
        }

        // Special case: no element overlaps x0, is index 0 visible?
        if (i0 == -1)
        {   
            var index0:int = findLayoutElementIndex(g, 0, +1);
            if (index0 != -1)
            {
                var element0:ILayoutElement = g.getElementAt(index0); 
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
                var element1:ILayoutElement = g.getElementAt(index1); 
                var element1X:Number = element1.getLayoutBoundsX();
                var element1Width:Number = element1.getLayoutBoundsWidth();                 
                if ((element1X < x1) && ((element1X + element1Width) > x0))
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
     *  @private 
     */
    override protected function elementBoundsLeftOfScrollRect(scrollRect:Rectangle):Rectangle
    {
        return findLayoutElementBounds(target, firstIndexInView, -1, scrollRect);
    } 

    /**
     *  @private 
     */
    override protected function elementBoundsRightOfScrollRect(scrollRect:Rectangle):Rectangle
    {
        return findLayoutElementBounds(target, lastIndexInView, +1, scrollRect);
    } 

    /**
     *  @private
     *  Compute exact values for measuredWidth,Height and  measuredMinWidth,Height.
     * 
     *  If requestedColumnCount is not -1, measure as many layout elements,
     *  padding with typicalLayoutElement if needed, starting with index 0.  
     *  Otherwise measure all of the layout elements.
     */
    private function measureReal(layoutTarget:GroupBase):void
    {
        var layoutEltCount:int = layoutTarget.numElements;
        var reqEltCount:int = requestedColumnCount; // -1 means "all elements"
        var eltCount:uint = Math.max(reqEltCount, layoutEltCount);
        var eltInLayoutCount:uint = 0; // elts that have been measured

        var preferredHeight:Number = 0; // max of the elt preferred heights
        var preferredWidth:Number = 0;  // sum of the elt preferred widths
        var minHeight:Number = 0; // max of the elt minimum heights
        var minWidth:Number = 0;  // sum of the elt minimum widths

        var fixedColumnWidth:Number = NaN;
        if (!variableColumnWidth)
            fixedColumnWidth = columnWidth;  // may query typicalLayoutElement, elt at index=0

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
                
            var height:Number = elt.getPreferredBoundsHeight();
            var width:Number = isNaN(fixedColumnWidth) ? elt.getPreferredBoundsWidth() : fixedColumnWidth;
            preferredHeight = Math.max(preferredHeight, height);
            preferredWidth += width;
            minHeight = Math.max(minHeight, (isNaN(elt.percentHeight)) ? height : elt.getMinBoundsHeight());
            minWidth += (isNaN(elt.percentWidth)) ? width : elt.getMinBoundsWidth();

            eltInLayoutCount += 1;
        }
        
        if (eltInLayoutCount > 1)
        { 
            var hgap:Number = gap * (eltInLayoutCount - 1);
            preferredWidth += hgap;
            minWidth += hgap;
        }
        
        layoutTarget.measuredHeight = preferredHeight;
        layoutTarget.measuredWidth = preferredWidth;
        layoutTarget.measuredMinHeight = minHeight;
        layoutTarget.measuredMinWidth  = minWidth;
    }

    private var llv:LinearLayoutVector = new LinearLayoutVector(LinearLayoutVector.HORIZONTAL);
    
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
            llv.minorSize = Math.max(llv.minorSize, typicalHeight);
            llv.defaultMajorSize = typicalWidth;      
        }
        if (layoutTarget)
            llv.length = layoutTarget.numElements;        
        llv.gap = gap;
     }

    /**
     *  @private
     */
     override public function elementAdded(index:int):void
     {
         if (useVirtualLayout)
            llv.insert(index);
     }

    /**
     *  @private
     */
     override public function elementRemoved(index:int):void
     {
        if (useVirtualLayout)
            llv.remove(index);
     }     

    /**
     *  @private 
     *  Compute potentially approximate values for measuredWidth,Height and 
     *  measuredMinWidth,Height.
     * 
     *  This method does not get layout elements from the target except
     *  as a side effect of calling typicalLayoutElement.
     * 
     *  If variableColumnWidth="false" then all dimensions are based on 
     *  typicalLayoutElement and the sizes already cached in llv.  The 
     *  llv's defaultMajorSize, minorSize, and minMinorSize 
     *  are based on typicalLayoutElement.
     */
    private function measureVirtual(layoutTarget:GroupBase):void
    {
        var eltCount:uint = layoutTarget.numElements;
        var measuredEltCount:int = (requestedColumnCount != -1) ? requestedColumnCount : eltCount;
        
        updateLLV(layoutTarget);     
        if (variableColumnWidth)
        {
            var endIndex:int = Math.max(0, Math.min(measuredEltCount, eltCount) - 1);
            layoutTarget.measuredWidth =  llv.end(measuredEltCount - 1);
        }
        else
        {
            var hgap:Number = (measuredEltCount > 1) ? (measuredEltCount - 1) * gap : 0;
            layoutTarget.measuredWidth = (measuredEltCount * columnWidth) + hgap;
        }
        layoutTarget.measuredHeight = llv.minorSize;
                
        layoutTarget.measuredMinWidth = layoutTarget.measuredWidth;
        layoutTarget.measuredMinHeight = layoutTarget.measuredHeight;
    }

    /**
     *  If requestedColumnCount is specified then as many layout elements
     *  or "columns" are measured, starting with element 0, otherwise all of the 
     *  layout elements are measured.
     *  
     *  If requestedColumnCount is specified and is greater than the
     *  number of layout elements, then the typicalLayoutElement is used
     *  in place of the missing layout elements.
     * 
     *  If variableColumnWidth="true", then the layoutTarget's measuredWidth
     *  is the sum of preferred widths of the layout elements, plus the sum of the
     *  gaps between elements, and its measuredHeight is the max of the elements' 
     *  preferred heights.
     * 
     *  If variableColumnWidth="false", then the layoutTarget's measuredWidth
     *  is columnWidth multiplied by the number or layout elements, plus the 
     *  sum of the gaps between elements.
     * 
     *  The layoutTarget's measuredMinWidth is the sum of the minWidths of 
     *  layout elements that have specified a value for the percentWidth
     *  property, and the preferredWidtj of the elements that have not, 
     *  plus the sum of the gaps between elements.
     * 
     *  The difference reflects the fact that elements which specify 
     *  percentWidth are considered to be "flexible" and updateDisplayList 
     *  will give flexible components at least their minWidth.  
     * 
     *  Layout elements that aren't flexible always get their preferred width.
     * 
     *  The layoutTarget's measuredMinHeight is the max of the minHeights for 
     *  elements that have specified percentHeight (that are "flexible") and the 
     *  preferredHeight of the elements that have not.
     * 
     *  As before the difference is due to the fact that flexible items are only
     *  guaranteed their minHeight.
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
    private function calculateElementHeight(elt:ILayoutElement, targetHeight:Number, containerHeight:Number):Number
    {
       // If percentHeight is specified then the element's height is the percentage
       // of targetHeight clipped to min/maxHeight and to (upper limit) targetHeight.
       var percentHeight:Number = elt.percentHeight;
       if (!isNaN(percentHeight))
       {
          var height:Number = percentHeight * 0.01 * targetHeight;
          return Math.min(targetHeight, Math.min(elt.getMaxBoundsHeight(), Math.max(elt.getMinBoundsHeight(), height)));
       }
       switch(verticalAlign)
       {
           case VerticalAlign.JUSTIFY: 
               return targetHeight;
           case VerticalAlign.CONTENT_JUSTIFY: 
               return Math.max(elt.getPreferredBoundsHeight(), containerHeight);
       }
       return elt.getPreferredBoundsHeight();
    }

    //  - virtual layout only - 
    private function calculateElementY(elt:ILayoutElement, eltHeight:Number, containerHeight:Number):Number
    {
       switch(verticalAlign)
       {
           case VerticalAlign.MIDDLE: 
               return Math.round((containerHeight - eltHeight) * 0.5);
           case VerticalAlign.BOTTOM: 
               return containerHeight - eltHeight;
       }
       return 0;  // VerticalAlign.TOP
    }

    /**
     *  @private
     *  Update the layout of the virtualized elements that overlap
     *  the scrollRect's horizontal extent.
     *
     *  The width of each layout element will be its preferred width, and its
     *  x will be the right edge of the previous item, plus the gap.
     * 
     *  No support for percentWidth, includeInLayout=false, or null layoutElements,
     * 
     *  The height of each layout element will be set to its preferred height, unless
     *  one of the following is true:
     * 
     *  - If percentHeight is specified for this element, then its height will be the
     *  specified percentage of the target's actual (unscaled) height, clipped 
     *  the layout element's minimum and maximum height.
     * 
     *  - If verticalAlign is "justify", then the element's height will
     *  be set to the target's actual (unscaled) height.
     * 
     *  - If verticalAlign is "contentJustify", then the element's height
     *  will be set to the target's content height.
     * 
     *  The Y coordinate of each layout element will be set to 0 unless one of the
     *  following is true:
     * 
     *  - If verticalAlign is "middle" then y is set so that the element's preferred
     *  height is centered within the larget of the contentHeight and the target's height:
     *      y = (Math.max(contentHeight, target.height) - layoutElementHeight) * 0.5
     * 
     *  - If verticalAlign is "bottom" the y is set so that the element's bottom
     *  edge is aligned with the the bottom edge of the content:
     *      y = (Math.max(contentHeight, target.height) - layoutElementHeight)
     * 
     *  Implementation note: unless verticalAlign is either "justify" or 
     *  "top", the layout elements' y or height depends on the contentHeight.
     *  The contentHeight is a maximum and although it may be updated to 
     *  different value after all (viewable) elements have been laid out, it
     *  often does not change.  For that reason we use the current contentHeight
     *  for the initial layout and then, if it has changed, we loop through 
     *  the layout items again and fix up the y/height values.
     */
    private function updateDisplayListVirtual():void
    {
        var layoutTarget:GroupBase = target; 
        var eltCount:int = layoutTarget.numElements;
        var targetHeight:Number = layoutTarget.height;
        var minVisibleX:Number = layoutTarget.horizontalScrollPosition;
        var maxVisibleX:Number = minVisibleX + layoutTarget.width;
       
        updateLLV(layoutTarget);
        var startIndex:int = llv.indexOf(minVisibleX);
        if (startIndex == -1)
            return; 
            
        var fixedColumnWidth:Number = NaN;
        if (!variableColumnWidth)
            fixedColumnWidth = columnWidth;  // may query typicalLayoutElement, elt at index=0
         
        var contentHeight:Number = llv.minorSize;
        var containerHeight:Number = Math.max(contentHeight, targetHeight);
        var x:Number = llv.start(startIndex);
        var index:int = startIndex;
        
        // First pass: compute element x,y,width,height based on 
        // current contentHeight; cache computed widths/heights in llv.
        for (; (x < maxVisibleX) && (index < eltCount); index++)
        {
            var elt:ILayoutElement = layoutTarget.getVirtualElementAt(index);
            var w:Number = (isNaN(fixedColumnWidth)) ? elt.getPreferredBoundsWidth() : fixedColumnWidth;
            var h:Number = calculateElementHeight(elt, targetHeight, containerHeight);
            var y:Number = calculateElementY(elt, h, containerHeight);
            elt.setLayoutBoundsPosition(x, y);
            elt.setLayoutBoundsSize(w, h);            
            llv.cacheDimensions(index, elt);
            x += w + gap;
        }
        var endIndex:int = index - 1;

        // Second pass: if neccessary, fix up y and height values based
        // on the updated contentHeight
        if (llv.minorSize != contentHeight)
        {
            contentHeight = llv.minorSize;
            containerHeight = Math.max(contentHeight, targetHeight);            
            if ((verticalAlign != VerticalAlign.TOP) && (verticalAlign != VerticalAlign.JUSTIFY))
            {
                for (index = startIndex; index <= endIndex; index++)
                {
                    elt = layoutTarget.getVirtualElementAt(index);
                    h = calculateElementHeight(elt, targetHeight, containerHeight);
                    y = calculateElementY(elt, h, containerHeight);
                    elt.setLayoutBoundsPosition(elt.getLayoutBoundsX(), y);
                    elt.setLayoutBoundsSize(elt.getLayoutBoundsWidth(), h);
                }
             }
        }

        setColumnCount(index - startIndex);
        setIndexInView(startIndex, endIndex);
        layoutTarget.setContentSize(llv.end(llv.length - 1), contentHeight);
    }
    
    private function updateDisplayListReal():void
    {
        var layoutTarget:GroupBase = target;
        var targetWidth:Number = layoutTarget.width;
        var targetHeight:Number = layoutTarget.height;
        
        var layoutElement:ILayoutElement;
        var count:uint = layoutTarget.numElements;
        
        // If verticalAlign is top, we don't need to figure out the contentHeight.
        // Otherwise the contentHeight is used to position the element and even size 
        // the element if it's "contentJustify" or "justify".
        var containerHeight:Number = targetHeight;
        
        
        // TODO: in the middle or bottom case, we end up calculating percentHeight 
        // twice.  Once here for the contentHeight and once in distributeWidth
        // to size that particular element.
        if (verticalAlign != VerticalAlign.TOP)
        {
            for (var i:int = 0; i < count; i++)
            {
                layoutElement = layoutTarget.getElementAt(i);
                if (!layoutElement || !layoutElement.includeInLayout)
                    continue;
                
                var layoutElementHeight:Number;
                if (!isNaN(layoutElement.percentHeight))
                    layoutElementHeight = calculatePercentHeight(layoutElement, targetHeight);
                else
                    layoutElementHeight = layoutElement.getPreferredBoundsHeight();
                    
                containerHeight = Math.max(containerHeight, layoutElementHeight);
            }
        }

        // If we're justifying the elements, then all heights should be set to
        // targetHeight.  If we're content justifying the elements, then 
        // all heights should be set to the contentHeight.
        // Otherwise restrictedHeight is ignored in distributedWidth.
        var restrictedHeight:Number;
        if (verticalAlign == VerticalAlign.JUSTIFY)
            restrictedHeight = targetHeight;
        else if (verticalAlign == VerticalAlign.CONTENT_JUSTIFY)
            restrictedHeight = containerHeight;

        distributeWidth(targetWidth, targetHeight, restrictedHeight);    
        
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
        var maxVisibleX:Number = minVisibleX + targetWidth

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
            layoutElement = layoutTarget.getElementAt(index);
            if (!layoutElement || !layoutElement.includeInLayout)
                continue;

            // Set the layout element's position
            var y:Number = (containerHeight - layoutElement.getLayoutBoundsHeight()) * vAlign;
            // In case we have VerticalAlign.MIDDLE we have to round
            if (vAlign == 0.5)
                y = Math.round(y);
            layoutElement.setLayoutBoundsPosition(x, y);

            // Update maxX,Y, first,lastVisibleIndex, and x
            var dx:Number = layoutElement.getLayoutBoundsWidth();
            var dy:Number = layoutElement.getLayoutBoundsHeight();
            maxX = Math.max(maxX, x + dx);
            maxY = Math.max(maxY, y + dy);            
            if (!clipAndEnableScrolling || 
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
            
            if (!isNaN(layoutElement.percentWidth) && variableColumnWidth)
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
            var roundOff:Number = 0;
            for each (childInfo in childInfoArray)
            {
                // Make sure the calculated percentages are rounded to pixel boundaries
                var childSize:int = Math.round(childInfo.size + roundOff);
                roundOff += childInfo.size - childSize;

                sizeLayoutElement(childInfo.layoutElement, height, verticalAlign, 
                                  restrictedHeight, childSize, 
                                  variableColumnWidth, cw); 
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
            setColumnCount(0);
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

import mx.core.ILayoutElement;
import mx.containers.utilityClasses.FlexChildInfo;

class HLayoutElementFlexChildInfo extends FlexChildInfo
{
    public var layoutElement:ILayoutElement;	
}
