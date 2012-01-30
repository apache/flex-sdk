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
import mx.core.mx_internal;

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
	mx_internal var autoScrollAscending:Boolean = true;
	
	mx_internal static const FORCE_NO_WRAP_ELEMENTS_CHANGE:String = "forceNoWrapElementsChange";
	
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
		
		var iter:LayoutIterator = new LayoutIterator(target);
		
		if (useVirtualLayout)
		{
			if (typicalLayoutElement)
				preferredWidth = typicalLayoutElement.getPreferredBoundsWidth();
		}
		else
		{
			while (iter.visitedElementCount < target.numElements)
			{
				element = iter.nextWrappedElement();
				
				if (element)
				{
					// Get the largest width
					preferredWidth = Math.max(Math.ceil(element.getPreferredBoundsWidth()), preferredWidth);
				}
			}
		}
		
		var rowsToMeasure:int = getRowsToMeasure(target.numElements);
		
		// Calculate the height by multiplying the number of elements time the row height
		target.measuredHeight = Math.ceil(rowsToMeasure * rowHeight);
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
        
        var scrollPosition:Number = wrapElements ? 
            normalizeScrollPosition(verticalScrollPosition) : 
            verticalScrollPosition;
		
		// TODO (jszeto) Modify LayoutIterator to not require seeding w/ index - 1
        var itemIndex:int = -1;
        var yPos:Number = 0;
        var numVisibleElements:int = -1;
        
        // Translate the vsp to the item index
        if (wrapElements)
        {
            itemIndex = Math.floor(scrollPosition / rowHeight) - 1;
            // The top item might only be partially visible. 
            yPos = -(scrollPosition % rowHeight);
        }
        else
        {
            // If wrapElements == false, then start at the first index
            yPos = -scrollPosition;
        }			
        
        // Start at the top index
        var iter:LayoutIterator = new LayoutIterator(target, itemIndex);
        
        while (iter.visitedElementCount < numElements)
        {
            element = iter.nextWrappedElement();
            
            element.setLayoutBoundsSize(width, rowHeight);
            element.setLayoutBoundsPosition(0, yPos);
            
            yPos += rowHeight;
            
            // If we are using virtual layout, only size and position 
            // the visible elements
            if (yPos > height && numVisibleElements != 0)
            {
				// Keep track of the number of elements visible in the viewing area
                numVisibleElements = iter.visitedElementCount;
                if (useVirtualLayout)
                    break;
            }
        }
        
        setRowCount(numVisibleElements);
        
        // Set the contentWidth and contentHeight
        target.setContentSize(target.width, Math.ceil(numElements * rowHeight));
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
	
	override public function updateScrollRect(w:Number, h:Number):void
	{
		var g:GroupBase = target;
		if (!g)
			return;
		
		// Instead of moving the scrollRect position, we reposition the elements
		if (clipAndEnableScrolling)
			g.scrollRect = new Rectangle(0, 0, w, h);
		else
			g.scrollRect = null;
	}
	
	override protected function scrollPositionChanged():void
	{
		if (target)
		{
			target.invalidateDisplayList();
			setIndexInView(0, target.numElements - 1);
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
		
		var element:ILayoutElement;
		var currentIndex:int = index % target.numElements;
		
		if (currentIndex < 0)
			currentIndex += target.numElements;
		
		// If the element at index % numElements) is not selectable, find the nearest one that is 
		var iter:LayoutIterator = new LayoutIterator(target, currentIndex - (autoScrollAscending ? 1 : -1));
		while (iter.visitedElementCount < target.numElements)
		{
			if (autoScrollAscending)
				element = iter.nextWrappedElement();
			else
				element = iter.prevWrappedElement();
			
			try 
			{
				if (!element || element["enabled"] == undefined || element["enabled"] == true)
					break;
			}
			catch (e:Error)
			{
				
			}
			
			if (autoScrollAscending)
				index++;
			else
				index--;
		}
		
		
		// If we don't allow wrapping, then cap the max index
		if(!wrapElements)
			index = Math.max(0, Math.min(index, target.numElements - 1));
		
		return index;
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
	 *  Takes an index between 0 and numElements and returns the index taking wrapping into account
	 */
	public function getUnwrappedElementIndex(index:int):int
	{
		// find the non-wrapped (i.e. non-modulo) index of the element on screen
		if (wrapElements)
		{
			var wrapCount:int = Math.floor(verticalScrollPosition / totalHeight);
			index += wrapCount * target.numElements;
			
			var firstVisibleItem:int = (verticalScrollPosition ) / rowHeight;
			if (index < firstVisibleItem)
				index += target.numElements;
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
	public function LayoutIterator(target:GroupBase, index:int = -1):void
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
	private var _loopIndex:int = -1;
	private var _visitedElementCount:int = 0;
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
	
	/**
	 *  The number of elements the iterator has visited 
	 */ 
	public function get visitedElementCount():int
	{
		return _visitedElementCount;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  Returns the element after the currentIndex. Returns null if the current index
	 *  is the last element.  
	 */ 
	public function nextElement():ILayoutElement
	{
		while (_curIndex < totalElements - 1)
		{
			var el:ILayoutElement = _useVirtual ? _target.getVirtualElementAt(++_curIndex) :
				_target.getElementAt(++_curIndex);
			if (el && el.includeInLayout)
			{
				++_visitedElementCount;
				return el;
			}
		}
		return null;
	}
	
	/**
	 *  Returns the element before the currentIndex. Returns null if the current index
	 *  is the first element.  
	 */
	public function prevElement():ILayoutElement
	{
		while (_curIndex > 0)
		{
			var el:ILayoutElement = _useVirtual ? _target.getVirtualElementAt(--_curIndex) :
				_target.getElementAt(--_curIndex);
			if (el && el.includeInLayout)
			{
				++_visitedElementCount;
				return el;
			}
		}
		return null;
	}
	
	/**
	 *  Returns the element after the currentIndex. Returns the first element if the current index
	 *  is the last element.  
	 */
	public function nextWrappedElement():ILayoutElement
	{
		if (_loopIndex == -1)
			_loopIndex = _curIndex;
		else if (_loopIndex == _curIndex)
			return null;
		
		var el:ILayoutElement = nextElement();
		if (el)
			return el;
		else if (_curIndex == totalElements - 1)
			_curIndex = -1;
		return nextElement();
	}
	
	/**
	 *  Returns the element before the currentIndex. Returns the last element if the current index
	 *  is the first element.  
	 */
	public function prevWrappedElement():ILayoutElement
	{
		if (_loopIndex == -1)
			_loopIndex = _curIndex;
		else if (_loopIndex == _curIndex)
			return null;
		
		var el:ILayoutElement = prevElement();
		if (el)
			return el;
		else if (_curIndex == 0)
			_curIndex = totalElements;
		return prevElement();
	}
}