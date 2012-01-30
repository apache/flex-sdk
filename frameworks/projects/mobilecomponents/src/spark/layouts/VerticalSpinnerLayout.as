////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package spark.layouts
{	
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.ILayoutElement;
import mx.core.IVisualElement;
import mx.core.mx_internal;

import spark.components.DataGroup;
import spark.components.SpinnerList;
import spark.components.supportClasses.GroupBase;
import spark.core.NavigationUnit;

use namespace mx_internal;

[ExcludeClass]

/**
 *  Custom wrapping layout for the SpinnerList
 */ 
public class VerticalSpinnerLayout extends VerticalLayout
{
	public function VerticalSpinnerLayout()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	private function get totalHeight():Number
	{
		return Math.ceil(target.numElements * rowHeight);
	}
	
	// If true, then when the layout encounters a disabled element, it will scroll past it
	// in ascending index order. If false, then it will scroll in the descending index order
	mx_internal var autoScrollAscending:Boolean = false;
	
	mx_internal static const FORCE_NO_WRAP_ELEMENTS_CHANGE:String = "forceNoWrapElementsChange";
    
    // If the scrollPosition is too small or large, we need to shift the y positions
    // of the item renderers or else we hit a player limitation. 
    private var yOffset:Number = 0;
    
    // The max value for x/y seems to be 2^30 / 10. int.MAX_VALUE = 2^31;
    private static const MAX_Y_VALUE:Number = int.MAX_VALUE / 20;
    private static const MIN_Y_VALUE:Number = int.MIN_VALUE / 20;
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  requestedWrapElements
	//----------------------------------
	
	private var _requestedWrapElements:Boolean = true;
	
	/**
	 *  This is the suggested value for wrapElements. However, the layout might not honor this value
	 *  if there are too few elements to display in the viewable area. 
	 * 
	 *  @default true
	 */
	public function get requestedWrapElements():Boolean
	{
		return _requestedWrapElements;
	}
	
	public function set requestedWrapElements(value:Boolean):void
	{
		if (value == _requestedWrapElements)
			return;
		
		_requestedWrapElements = value;
		target.invalidateSize();
		target.invalidateDisplayList();
	}
	
	/**
	 *  If true, the layout has forced wrapElements to be false
	 */ 
	public var forceNoWrapElements:Boolean = false;
	
	//----------------------------------
	//  wrapElements
	//----------------------------------
	
	/**
	 *  When true, scrolling past the last element will scroll to the first element. 
	 * 
	 *  @default true
	 */
	public function get wrapElements():Boolean
	{
		if (forceNoWrapElements)
			return false;
		else
			return requestedWrapElements;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------
		
	override public function measure():void
	{					
		var preferredWidth:Number = 0;  // max of the elt preferred widths
		
		var element:ILayoutElement;
		var startIndex:int = 0;
        
		var iter:LayoutIterator = new LayoutIterator(target, startIndex);
        
		if (useVirtualLayout)
		{
			if (typicalLayoutElement)
				preferredWidth = typicalLayoutElement.getPreferredBoundsWidth();
		}
		else
		{
            do
            {
                element = iter.getCurrentElement();
                if (element && element.includeInLayout)
                    preferredWidth = Math.max(Math.ceil(element.getPreferredBoundsWidth()), preferredWidth);
                iter.next();
            } 
            while (startIndex != iter.currentIndex); // Loop until we are back at the start
                
		}
		        
		var rowsToMeasure:int = getRowsToMeasure(target.numElements);
		
		// Calculate the height by multiplying the number of elements time the row height
		target.measuredHeight = Math.ceil(rowsToMeasure * Math.max(5, rowHeight));
		target.measuredWidth = preferredWidth;
	}
	
    override public function updateDisplayList(width:Number, height:Number):void
    {
        var element:ILayoutElement;
        var numElements:int = target.numElements;
        
        var oldForceNoWrapElements:Boolean = forceNoWrapElements;
        
        // If there are fewer elements than will fit, we need to set wrapElements = false
        if (requestedWrapElements && (height > numElements * rowHeight))
            forceNoWrapElements = true;
        else
            forceNoWrapElements = false;
        
        if (forceNoWrapElements != oldForceNoWrapElements)
            dispatchEvent(new Event(FORCE_NO_WRAP_ELEMENTS_CHANGE));
        
        var scrollPosition:Number = verticalScrollPosition;
		
        var itemIndex:int = Math.floor(scrollPosition / rowHeight);
        var yPos:Number;
        var yPosMax:Number;
        
        var foundLastVisibleElement:Boolean = false;
        var numVisibleElements:int = 0;
        var numVisitedElements:int = 0;
        
        // Translate the vsp to the item index
        if (!wrapElements)
        {
            if (!useVirtualLayout)
                itemIndex = 0;
            else
                itemIndex = Math.max(Math.min(itemIndex, numElements - 1), 0);           
        }		
        
        yPos = itemIndex * rowHeight + yOffset;
        
        // Calculate the y position of the bottom of the viewable area
        yPosMax = yPos + rowHeight + height;
        
        // Normalize the itemIndex
        if (wrapElements)
            itemIndex = normalizeItemIndex(itemIndex);
        
        // Start at the top index
        var iter:LayoutIterator = new LayoutIterator(target, itemIndex);
        
        if (numElements > 0)
        {
            do
            {
                element = iter.getCurrentElement();
                if (element && element.includeInLayout)
                {
                    numVisitedElements++;
                    
                    element.setLayoutBoundsSize(width, rowHeight);
                    element.setLayoutBoundsPosition(0, yPos);
                    
                    yPos += rowHeight;
                    
                    // If we are using virtual layout, only size and position 
                    // the visible elements
                    if (yPos > yPosMax && !foundLastVisibleElement)
                    {
                        foundLastVisibleElement = true;
                        // Keep track of the number of elements visible in the viewing area
                        numVisibleElements = numVisitedElements;
                        if (useVirtualLayout)
                            break;
                    }
                }
                
                // Make sure to not wrap if wrapElements = false
                if (!wrapElements && iter.currentIndex == numElements - 1)
                    break;
                
                iter.next();
            } 
            while (itemIndex != iter.currentIndex)
        }
        
        setRowCount(numVisibleElements);
        
        // Set the contentWidth and contentHeight
        target.setContentSize(target.width, Math.ceil(numElements * rowHeight));
    }
    
    override public function updateScrollRect(w:Number, h:Number):void
    {
        var g:GroupBase = target;
        if (!g)
            return;
        
        if (clipAndEnableScrolling)
        {
            var hsp:Number = horizontalScrollPosition;
            var vsp:Number = verticalScrollPosition;
            
            // If the verticalScrollPosition exceeds the max/min y value, then the
            // renderers will not be properly positioned. In which case,
            // we offset the y position of the renderers by the verticalScrollPosition
            if (((vsp + yOffset + g.getPreferredBoundsHeight()) > MAX_Y_VALUE) ||
                ((vsp + yOffset) < MIN_Y_VALUE))
                yOffset = -vsp;
            g.scrollRect = new Rectangle(hsp, vsp + yOffset, w, h);
        }
        else
            g.scrollRect = null;
    }

	override public function getElementBounds(index:int):Rectangle
	{		
		return new Rectangle(0, index * rowHeight, target.measuredWidth, rowHeight); 
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden scroll methods
	//
	//--------------------------------------------------------------------------
	
	override protected function scrollPositionChanged():void
	{        
        var g:GroupBase = target;
        if (!g)
            return;
        
        updateScrollRect(g.width, g.height);
        
        var n:int = g.numElements - 1;
        if (n < 0) 
        {
            setIndexInView(-1, -1);
            return;
        }
        
        var scrollR:Rectangle = getScrollRect();
        if (!scrollR)
        {
            setIndexInView(0, n);
            return;    
        }
        
        // Apply the offset        
        var y0:Number = scrollR.top + yOffset;
        var y1:Number = scrollR.bottom + yOffset - .0001; 
        if (y1 <= y0)
        {
            setIndexInView(-1, -1);
            return;
        }
        
        var i0:int;
        var i1:int;
        
        if (wrapElements)
        {
            i0 = normalizeItemIndex(Math.floor(y0 / rowHeight));
            i1 = normalizeItemIndex(Math.floor(y1 / rowHeight));
        }
        else
        {
            i0 = Math.min(Math.max(Math.floor(y0 / rowHeight), 0),n);
            i1 = Math.min(Math.max(Math.floor(y1 / rowHeight), 0),n);
        }
        
        setIndexInView(i0, i1);
        
        var firstElement:ILayoutElement = g.getElementAt(firstIndexInView);
        var lastElement:ILayoutElement = g.getElementAt(lastIndexInView);
        
        if (wrapElements)
        {
            if (!firstElement || !lastElement || 
                y0 < firstElement.getLayoutBoundsY() || 
                y1 >= (lastElement.getLayoutBoundsY() + lastElement.getLayoutBoundsHeight()))
            {
                g.invalidateDisplayList();
            }
        }
        else
        {
            if (!firstElement || !lastElement || 
                (y0 < firstElement.getLayoutBoundsY() && firstIndexInView != 0) || 
                (y1 >= (lastElement.getLayoutBoundsY() + lastElement.getLayoutBoundsHeight()) && lastIndexInView != n))
            {
                g.invalidateDisplayList();
            }
        }
	}
	
	override public function getHorizontalScrollPositionDelta(navigationUnit:uint):Number
	{
		return 0;
	}
	
	override public function getVerticalScrollPositionDelta(navigationUnit:uint):Number
	{		
		return 0;
	}
	
	override mx_internal function getElementNearestScrollPosition(
		position:Point,elementComparePoint:String = "center"):int
	{
		var index:int = Math.floor(position.y / rowHeight); // may be larger than numElements to indicate wrapping
		
        var item:Object;
		var startIndex:int = index % target.numElements;
        var distance:int = 0;
        var direction:int = autoScrollAscending ? 1 : -1;
        var dataGroup:DataGroup = target as DataGroup;
        
		if (startIndex < 0)
            startIndex += target.numElements;
		
		// If the element at index % numElements) is not selectable, find the nearest one that is              
        var iter:LayoutIterator = new LayoutIterator(target, startIndex);
        
        if (dataGroup && dataGroup.dataProvider && dataGroup.dataProvider.length > 0)
        {
            while (Math.abs(distance) <= (target.numElements / 2) + 1)
            {
                // Try searching in one direction
                iter.currentIndex = startIndex + distance * direction;

                item = dataGroup.dataProvider.getItemAt(normalizeItemIndex(iter.currentIndex));
                
                if (isElementEnabled(item))
                    break;
                
                if (distance != 0)
                {
                    // Flip the direction
                    direction *= -1;
                    
                    // Try searching in the other direction
                    iter.currentIndex = startIndex + distance * direction;
                    item = dataGroup.dataProvider.getItemAt(normalizeItemIndex(iter.currentIndex));   
                    
                    if (isElementEnabled(item))
                        break;
                    
                    // Flip the direction back
                    direction *= -1;
                }
                
                distance++;
            }
        }
        
		// If we don't allow wrapping, then cap the max index
		if(!wrapElements)
			index = Math.max(0, Math.min(index, target.numElements - 1));
		
		return index + distance * direction;
	}
		
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  Returns the index of the element intersected by the vertical center of the viewable area
	 */ 
	public function getIndexAtVerticalCenter():int
	{
        var midY:Number = target.getLayoutBoundsHeight() / 2;
		var vsp:Number = wrapElements ? normalizeScrollPosition(verticalScrollPosition + midY) : verticalScrollPosition + midY;
        
		return getElementNearestScrollPosition(new Point(0, vsp), "center"); 
	}
    
	/**
	 *  Takes an index between 0 and numElements and returns the closest index 
     *  to the current position, taking wrapping into account
	 */   
    public function getClosestUnwrappedElementIndex(index:int):int
    {
        if (wrapElements)
        {
            // Figure out the wrapCount of the center index
            var midVSP:Number = target.getLayoutBoundsHeight() / 2 + verticalScrollPosition;
            var wrapCount:int = Math.floor(midVSP / totalHeight);
            
            // Get unwrapped middle index
            var centerIndex:int = getElementNearestScrollPosition(new Point(0, midVSP), "center");
            
            // Get the unwrapped indicies near the center index
            var prevIndex:int = index + (wrapCount - 1) * target.numElements;
            var midIndex:int = prevIndex + target.numElements;
            var nextIndex:int = midIndex + target.numElements;
            
            var prevDistance:int = Math.abs(centerIndex - prevIndex);
            var midDistance:int = Math.abs(midIndex - centerIndex);
            var nextDistance:int = Math.abs(nextIndex - centerIndex)
                        
            // Figure out which index is closer to the centerIndex and return that value
            if (prevDistance < midDistance)
                index = prevIndex;                    
            else if (midDistance < nextDistance)
                index = midIndex;
            else
                index = nextIndex;
        }
        
        return index;
    }
    
	// Helper function to calculate the non-wrapped, non-negative scroll position
	private function normalizeScrollPosition(vsp:int):int
	{
		// Normalize the scrollPosition
 		if (!isNaN(totalHeight))
		{
			vsp %= totalHeight;
			
			if (vsp < 0)
				vsp += totalHeight;
		}
		
		return vsp;
	}
    
    // Helper function to normalize the item index
    private function normalizeItemIndex(index:int):int
    {
        if (target)
        {
            index %= target.numElements;
            
            if (index < 0)
                index += target.numElements;
        }
        
        return index;
    }
    
    // Helper function to return whether an element is enabled or not
    private function isElementEnabled(element:Object):Boolean
    {       
        var result:Boolean = true;
        
        // If data is a String or other primitive, this call will fail
        try 
        {
            result = element["_enabled_"] == undefined || element["_enabled_"];
        }
        catch (e:Error)
        {
            
        }
        
        return result;
    }
}
}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: LayoutIterator
//
////////////////////////////////////////////////////////////////////////////////

import mx.core.ILayoutElement;

import spark.components.supportClasses.GroupBase;

/**
 *  Layout helper class. Iterates over a set of items. The iterator can optionally wrap around the 
 *  end of the set back to the beginning of the set.  
 */ 
class LayoutIterator 
{
	/**
	 *  Constructor. Takes a layout target and the starting index for the iterator
	 *  
	 *  @param target The GroupBase target that contains the elements
	 *  @param index The starting index for the iterator  
	 */ 
	public function LayoutIterator(target:GroupBase, index:int = 0):void
	{
		totalElements = target.numElements;
		_target = target;
		_curIndex = index;
		_useVirtual = _target.layout.useVirtualLayout;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	private var _curIndex:int;
	private var _target:GroupBase;
	private var _useVirtual:Boolean;
	private var totalElements:int;
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  Returns the index that the iterator is currently pointing
	 */ 
	public function get currentIndex():int
	{
		return _curIndex;
	}
    
    public function set currentIndex(value:int):void
    {
        _curIndex = value;
    }
		
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	/**
     *  Get the element at the currentIndex 
     */ 
    public function getCurrentElement():ILayoutElement
    {
        return _useVirtual ? _target.getVirtualElementAt(_curIndex) :
                             _target.getElementAt(_curIndex);
    }
    
    /**
     *  Move the currentIndex to the next index. If the currentIndex is at
     *  the last index, then it is set to the first index. 
     */
    public function next():int
    {
        if (_curIndex == totalElements - 1)
            _curIndex = 0;
        else
            _curIndex++;
        
        return _curIndex;
    }
    
    /**
     *  Move the currentIndex to the previous index. If the currentIndex is at
     *  the fist index, then it is set to the last index. 
     */
    public function prev():int
    {
        if (_curIndex == 0)
            _curIndex = totalElements - 1;
        else
            _curIndex--;
        
        return _curIndex;
    }

}