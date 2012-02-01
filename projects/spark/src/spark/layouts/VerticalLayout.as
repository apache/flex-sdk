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

package spark.layouts
{
import flash.events.Event;
import flash.geom.Rectangle;

import mx.containers.utilityClasses.Flex;
import mx.core.ILayoutElement;
import mx.events.PropertyChangeEvent;

import spark.components.supportClasses.GroupBase;
import spark.core.NavigationUnit;
import spark.layouts.supportClasses.LayoutBase;
import spark.layouts.supportClasses.LayoutElementHelper;
import spark.layouts.supportClasses.LinearLayoutVector;

/**
 *  The VerticalLayout class arranges the layout elements in a vertical sequence,
 *  top to bottom, with optional gaps between the elements and optional padding
 *  around the sequence of elements.
 *
 *  <p>The vertical position of the elements is determined by arranging them
 *  in a vertical sequence, top to bottom, taking into account the padding
 *  before the first element and the gaps between the elements.</p>
 *
 *  <p>The horizontal position of the elements is determined by the layout's
 *  <code>horizontalAlign</code> property.</p>
 *
 *  <p>During the execution of the <code>measure()</code> method, 
 *  the default size of the container is calculated by
 *  accumulating the preferred sizes of the elements, including gaps and padding.
 *  When <code>requestedRowCount</code> is set, only the space for that many elements
 *  is measured, starting from the first element.</p>
 *
 *  <p>During the execution of the <code>updateDisplayList()</code> method, 
 *  the height of each element is calculated
 *  according to the following rules, listed in their respective order of
 *  precedence (element's minimum height and maximum height are always respected):</p>
 *  <ul>
 *    <li>If <code>variableRowHeight</code> is <code>false</code>, 
 *    then set the element's height to the
 *    value of the <code>rowHeight</code> property.</li>
 *
 *    <li>If the element's <code>percentHeight</code> is set, then calculate the element's
 *    height by distributing the available container height between all
 *    elements with a <code>percentHeight</code> setting. 
 *    The available container height
 *    is equal to the container height minus the gaps, the padding and the
 *    space occupied by the rest of the elements. The element's <code>precentHeight</code>
 *    property is ignored when the layout is virtualized.</li>
 *
 *    <li>Set the element's height to its preferred height.</li>
 *  </ul>
 *
 *  <p>The width of each element is calculated according to the following rules,
 *  listed in their respective order of precedence (element's minimum width and
 *  maximum width are always respected):</p>
 *  <ul>
 *    <li>If <code>horizontalAlign</code> is <code>"justify"</code>, 
 *    then set the element's width to the container width.</li>
 *
 *    <li>If <code>horizontalAlign</code> is <code>"contentJustify"</code>,
 *    then set the element's width to the maximum between the container's width 
 *    and all elements' preferred width.</li>
 *
 *    <li>If the element's <code>percentWidth</code> is set, then calculate the element's
 *    width as a percentage of the container's width.</li>
 *
 *    <li>Set the element's width to its preferred width.</li>
 *  </ul>
 *
 *  @mxml 
 *  <p>The <code>&lt;s:VerticalLayout&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:VerticalLayout 
 *    <strong>Properties</strong>
 *    gap="6"
 *    horizontalAlign="left"
 *    paddingBottom="0"
 *    paddingLeft="0"
 *    paddingRight="0"
 *    paddingTop="0"
 *    requestedRowCount="-1"
 *    rowHeight="<i>calculated</i>"
 *    variableRowHeight="true"
 *  /&gt;
 *  </pre>
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class VerticalLayout extends LayoutBase
{
    include "../core/Version.as";
    
    /**
     *  @private
     *  Cached row heights, max column width for virtual layout.   Not used unless
     *  useVirtualLayout=true.   See updateLLV(), resetCachedVirtualLayoutState(),
     *  etc.
     */
    private var llv:LinearLayoutVector = new LinearLayoutVector();
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    private static function calculatePercentWidth(layoutElement:ILayoutElement, width:Number):Number
    {
        var percentWidth:Number = LayoutElementHelper.pinBetween(Math.round(layoutElement.percentWidth * 0.01 * width),
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
            if (!isNaN(layoutElement.percentWidth))
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
     *  The current number of visible elements.
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
     *  @private
     * 
     *  Sets the <code>rowCount</code> property and dispatches a
     *  PropertyChangeEvent.
     */
    private function setRowCount(value:int):void
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
     *  The horizontal alignment of layout elements.
     *  If the value is <code>"left"</code>, <code>"right"</code>, or <code>"center"</code> then the 
     *  layout element is aligned relative to the container's <code>contentWidth</code> property.
     * 
     *  <p>If the value is <code>"contentJustify"</code>, then the layout element's actual
     *  width is set to the <code>contentWidth</code> of the container.
     *  The <code>contentWidth</code> of the container is the width of the largest layout element. 
     *  If all layout elements are smaller than the width of the container, 
     *  then set the width of all layout elements to the width of the container.</p>
     * 
     *  <p>If the value is <code>"justify"</code> then the layout element's actual width
     *  is set to the container's width.</p>
     *
     *  <p>This property does not affect the layout's measured size.</p>
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

        var layoutTarget:GroupBase = target;
        if (layoutTarget)
            layoutTarget.invalidateDisplayList();
    }
    
    //----------------------------------
    //  paddingLeft
    //----------------------------------

    private var _paddingLeft:Number = 0;
    
    [Inspectable(category="General")]

    /**
     *  The minimum number of pixels between the container's left edge and
     *  the left edge of the layout element.
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get paddingLeft():Number
    {
        return _paddingLeft;
    }

    /**
     *  @private
     */
    public function set paddingLeft(value:Number):void
    {
        if (_paddingLeft == value)
            return;
                               
        _paddingLeft = value;
        invalidateTargetSizeAndDisplayList();
    }    
    
    //----------------------------------
    //  paddingRight
    //----------------------------------

    private var _paddingRight:Number = 0;
    
    [Inspectable(category="General")]

    /**
     *  The minimum number of pixels between the container's right edge and
     *  the right edge of the layout element.
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get paddingRight():Number
    {
        return _paddingRight;
    }

    /**
     *  @private
     */
    public function set paddingRight(value:Number):void
    {
        if (_paddingRight == value)
            return;
                               
        _paddingRight = value;
        invalidateTargetSizeAndDisplayList();
    }    
    
    //----------------------------------
    //  paddingTop
    //----------------------------------

    private var _paddingTop:Number = 0;
    
    [Inspectable(category="General")]

    /**
     *  Number of pixels between the container's top edge
     *  and the top edge of the first layout element.
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get paddingTop():Number
    {
        return _paddingTop;
    }

    /**
     *  @private
     */
    public function set paddingTop(value:Number):void
    {
        if (_paddingTop == value)
            return;
                               
        _paddingTop = value;
        invalidateTargetSizeAndDisplayList();
    }    
    
    //----------------------------------
    //  paddingBottom
    //----------------------------------

    private var _paddingBottom:Number = 0;
    
    [Inspectable(category="General")]

    /**
     *  Number of pixels between the container's bottom edge
     *  and the bottom edge of the last layout element.
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get paddingBottom():Number
    {
        return _paddingBottom;
    }

    /**
     *  @private
     */
    public function set paddingBottom(value:Number):void
    {
        if (_paddingBottom == value)
            return;
                               
        _paddingBottom = value;
        invalidateTargetSizeAndDisplayList();
    }    
    
    //----------------------------------
    //  requestedRowCount
    //----------------------------------

    private var _requestedRowCount:int = -1;
    
    [Inspectable(category="General")]

    /**
     *  The measured size of this layout is tall enough to display 
     *  the first <code>requestedRowCount</code> layout elements. 
     * 
     *  <p>If <code>requestedRowCount</code> is -1, then the measured
     *  size will be big enough for all of the layout elements.</p>
     * 
     *  <p>If the actual size of the container has been explicitly set,
     *  then this property has no effect.</p>
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
     *  If <code>variableRowHeight</code> is <code>false</code>, then 
     *  this property specifies the actual height of each child.
     * 
     *  <p>If <code>variableRowHeight</code> is <code>true</code>, 
     *  the default, then this property has no effect.</p>
     * 
     *  <p>The default value of this property is the preferred height
     *  of the <code>typicalLayoutElement</code>.</p>
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

    [Inspectable(category="General", enumeration="true,false")]

    /**
     *  Specifies whether layout elements are allocated their 
     *  preferred height.
     *  Setting this property to <code>false</code> specifies fixed height rows.
     * 
     *  <p>If <code>false</code>, the actual height of each layout element is 
     *  the value of <code>rowHeight</code>.
     *  Setting this property to <code>false</code> causes the layout to ignore 
     *  the layout elements' <code>percentHeight</code> property.</p>
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
     *  The index of the first layout element that is part of the 
     *  layout and within the layout target's scroll rectangle, or -1 
     *  if nothing has been displayed yet.
     *  
     *  <p>"Part of the layout" means that the element is non-null
     *  and that its <code>includeInLayout</code> property is <code>true</code>.</p>
     * 
     *  <p>Note that the layout element may only be partially in view.</p>
     * 
     *  @see fractionOfElementInView()
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
     *  the container's scroll rectangle, or -1 if nothing has been displayed yet.
     * 
     *  <p>"Part of the layout" means that the child is non-null
     *  and that its <code>includeInLayout</code> property is <code>true</code>.</p>
     * 
     *  <p>Note that the row may only be partially in view.</p>
     * 
     *  @see firstIndexInView
     *  @see fractionOfElementInView
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
     *  @param firstIndex The new value for firstIndexInView.
     *  @param lastIndex The new value for lastIndexInView.
     * 
     *  @see firstIndexInView
     *  @see lastIndexInview
     *  
     *  @private
     */
    private function setIndexInView(firstIndex:int, lastIndex:int):void
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
     * @private
     */
    override public function clearVirtualLayoutCache():void
    {
        llv.clear();
    }     

    /**
     *  @private
     */
    override protected function getElementBounds(index:int):Rectangle
    {
        if (!useVirtualLayout)
            return super.getElementBounds(index);

        var g:GroupBase = GroupBase(target);
        if (!g || (index < 0) || (index >= g.numElements)) 
            return null;

        return llv.getBounds(index);
    }
    
    /**
     *  Returns 1.0 if the specified index is completely in view, 0.0 if
     *  it's not, or a value between 0.0 and 1.0 that represents the percentage 
     *  of the if the index that is partially in view.
     * 
     *  <p>An index is "in view" if the corresponding non-null layout element is 
     *  within the vertical limits of the container's <code>scrollRect</code>
     *  and included in the layout.</p>
     *  
     *  <p>If the specified index is partially within the view, the 
     *  returned value is the percentage of the corresponding
     *  layout element that's visible.</p>
     *
     *  @param index The index of the row.
     * 
     *  @return The percentage of the specified element that's in view.
     *  Returns 0.0 if the specified index is invalid or if it corresponds to
     *  null element, or a ILayoutElement for which 
     *  the <code>includeInLayout</code> property is <code>false</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function fractionOfElementInView(index:int):Number 
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
     *  @private
     * 
     *  Binary search for the first layout element that contains y.  
     * 
     *  This function considers both the element's actual bounds and 
     *  the gap that follows it to be part of the element.  The search 
     *  covers index i0 through i1 (inclusive).
     *  
     *  This function is intended for variable height elements.
     * 
     *  Returns the index of the element that contains y, or -1.
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
     *  @private
     * 
     *  Returns the index of the first non-null includeInLayout element, 
     *  beginning with the element at index i.  
     * 
     *  Returns -1 if no such element can be found.
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
     *  @private
     * 
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
     *  @private
     * 
     *  Returns the actual position/size Rectangle of the first partially 
     *  visible or not-visible, non-null includeInLayout element, beginning
     *  with the element at index i, searching in direction dir (dir must
     *  be +1 or -1).   The last argument is the GroupBase scrollRect, it's
     *  guaranteed to be non-null.
     * 
     *  Returns null if no such element can be found.
     */
    private function findLayoutElementBounds(g:GroupBase, i:int, dir:int, r:Rectangle):Rectangle
    {
        var n:int = g.numElements;

        if (fractionOfElementInView(i) >= 1)
        {
            // Special case: if we hit the first/last element, 
            // then return the area of the padding so that we
            // can scroll all the way to the start/end.
            i += dir;
            if (i < 0)
                return new Rectangle(0, 0, 0, paddingTop);
            if (i >= n)
                return new Rectangle(0, getElementBounds(n-1).bottom, 0, paddingBottom);
        }

        while((i >= 0) && (i < n))
        {
           var elementR:Rectangle = getElementBounds(i);
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
    override protected function getElementBoundsAboveScrollRect(scrollRect:Rectangle):Rectangle
    {
        return findLayoutElementBounds(target, firstIndexInView, -1, scrollRect);
    } 

    /**
     *  @private 
     */
    override protected function getElementBoundsBelowScrollRect(scrollRect:Rectangle):Rectangle
    {
        return findLayoutElementBounds(target, lastIndexInView, +1, scrollRect);
    } 

    /**
     *  @private
     * 
     *  Compute exact values for measuredWidth,Height and measuredMinWidth,Height.
     * 
     *  Measure each of the layout elements.  If requestedRowCount >= 0 we 
     *  consider the height and width of as many layout elements, padding with 
     *  typicalLayoutElement if needed, starting with index 0. We then only 
     *  consider the width of the elements remaining.
     * 
     *  If requestedRowCount is -1, we measure all of the layout elements.
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
            if (i < layoutEltCount) // target.numElements
                var elt:ILayoutElement = layoutTarget.getElementAt(i);
            else // target.numElements < requestedElementCount, so "pad"
                elt = typicalLayoutElement;
            if (!elt || !elt.includeInLayout)
                continue;
            
            // If requestedRowCount is specified, no need to consider the height
            // of rows outside the bounds of the "requested" range. Otherwise, we
            // consider each element.
            if ((reqEltCount == -1) || ((reqEltCount != -1) && eltInLayoutCount < requestedRowCount))
            {
                var height:Number = isNaN(fixedRowHeight) ? elt.getPreferredBoundsHeight() : fixedRowHeight;
                height = Math.ceil(height); // Round up to give it a whole pixel.
                preferredHeight += height;
                minHeight += (isNaN(elt.percentHeight)) ? height : Math.ceil(elt.getMinBoundsHeight());
                eltInLayoutCount += 1;
            }
            
            // Consider the width of each element, inclusive of those outside
            // the requestedRowCount range.
            var width:Number = Math.ceil(elt.getPreferredBoundsWidth());
            preferredWidth = Math.max(preferredWidth, width);
            var flexibleWidth:Boolean = !isNaN(elt.percentWidth) || horizontalAlign == HorizontalAlign.JUSTIFY;
            minWidth = Math.max(minWidth, flexibleWidth ? Math.ceil(elt.getMinBoundsWidth()) : width);           
        }
        
        if (eltInLayoutCount > 1)
        { 
            var vgap:Number = gap * (eltInLayoutCount - 1);
            preferredHeight += vgap;
            minHeight += vgap;
        }
        
        var hPadding:Number = paddingLeft + paddingRight;
        var vPadding:Number = paddingTop + paddingBottom;
        
        layoutTarget.measuredHeight = preferredHeight + vPadding;
        layoutTarget.measuredWidth = preferredWidth + hPadding;
        layoutTarget.measuredMinHeight = minHeight + vPadding;
        layoutTarget.measuredMinWidth  = minWidth + hPadding;
    }
    
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
        llv.gap = gap;
        llv.majorAxisOffset = paddingTop;
    }
     
    /**
     *  @private
     */
     override public function elementAdded(index:int):void
     {
         if ((index >= 0) && useVirtualLayout)
            llv.insert(index);  // insert index parameter is uint
     }

    /**
     *  @private
     */
     override public function elementRemoved(index:int):void
     {
        if ((index >= 0) && useVirtualLayout)
            llv.remove(index);  // remove index parameter is uint
     }     

    /**
     *  @private
     * 
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
        
        var hPadding:Number = paddingLeft + paddingRight;
        var vPadding:Number = paddingTop + paddingBottom;
        
        if (measuredEltCount <= 0)
        {
            layoutTarget.measuredWidth = layoutTarget.measuredMinWidth = hPadding;
            layoutTarget.measuredHeight = layoutTarget.measuredMinHeight = vPadding;
            return;
        }        
        
        updateLLV(layoutTarget);     
        if (variableRowHeight)
        {
            // Special case: fewer elements than requestedRowCount, so temporarily
            // make llv.length == requestedRowCount.
            var oldLength:int = -1;
            if (measuredEltCount > llv.length)
            {
                oldLength = llv.length;
                llv.length = measuredEltCount;
            }   
            // paddingTop is already taken into account as the majorAxisOffset of the llv   
            layoutTarget.measuredHeight = llv.end(measuredEltCount - 1) + paddingBottom;
            if (oldLength != -1)
                llv.length = oldLength;            
        }
        else
        {
            var vgap:Number = (measuredEltCount > 1) ? (measuredEltCount - 1) * gap : 0;
            layoutTarget.measuredHeight = (measuredEltCount * rowHeight) + vgap + vPadding;
        }
        layoutTarget.measuredWidth = llv.minorSize + hPadding;
                
        layoutTarget.measuredMinWidth = (horizontalAlign == HorizontalAlign.JUSTIFY) ? 
                llv.minMinorSize + hPadding : layoutTarget.measuredWidth;
        layoutTarget.measuredMinHeight = layoutTarget.measuredHeight;
    }

    /**
     *  @private
     * 
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
     */
    override public function measure():void
    {
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;
            
        var hPadding:Number = paddingLeft + paddingRight;
        var vPadding:Number = paddingTop + paddingBottom;

        if (layoutTarget.numElements == 0)
        {
            layoutTarget.measuredWidth = layoutTarget.measuredMinWidth = hPadding;
            layoutTarget.measuredHeight = layoutTarget.measuredMinHeight = vPadding;
        }            
        else if (useVirtualLayout)
            measureVirtual(layoutTarget);
        else 
            measureReal(layoutTarget);
            
        // Use Math.ceil() to make sure that if the content partially occupies
        // the last pixel, we'll count it as if the whole pixel is occupied.
        layoutTarget.measuredWidth = Math.ceil(layoutTarget.measuredWidth);    
        layoutTarget.measuredHeight = Math.ceil(layoutTarget.measuredHeight);    
        layoutTarget.measuredMinWidth = Math.ceil(layoutTarget.measuredMinWidth);    
        layoutTarget.measuredMinHeight = Math.ceil(layoutTarget.measuredMinHeight);    
    }
    
    /**
     *  @private 
     */  
    override public function getNavigationDestinationIndex(currentIndex:int, navigationUnit:uint, arrowKeysWrapFocus:Boolean):int
    {
        if (!target || target.numElements < 1)
            return -1; 

        var maxIndex:int = target.numElements - 1;

        // Special case when nothing was previously selected
        if (currentIndex == -1)
        {
            if (navigationUnit == NavigationUnit.UP)
                return arrowKeysWrapFocus ? maxIndex : -1;
            if (navigationUnit == NavigationUnit.DOWN)
                return 0;    
        }    
            
        // Make sure currentIndex is within range
        currentIndex = Math.max(0, Math.min(maxIndex, currentIndex));

        var newIndex:int; 
        var bounds:Rectangle;
        var y:Number;

        switch (navigationUnit)
        {
            case NavigationUnit.UP:
            {
               if (arrowKeysWrapFocus && currentIndex == 0)
                   newIndex = maxIndex;
               else
                   newIndex = currentIndex - 1;  
               break;
            } 

            case NavigationUnit.DOWN: 
            {
               if (arrowKeysWrapFocus && currentIndex == maxIndex)
                   newIndex = 0;
               else
                   newIndex = currentIndex + 1;  
               break;
            }
             
            case NavigationUnit.PAGE_UP:
            {
                // Find the first fully visible element
                var firstVisible:int = firstIndexInView;
                var firstFullyVisible:int = firstVisible;
                if (fractionOfElementInView(firstFullyVisible) < 1)
                    firstFullyVisible += 1;
                 
                // Is the current element in the middle of the viewport?
                if (firstFullyVisible < currentIndex && currentIndex <= lastIndexInView)
                    newIndex = firstFullyVisible;
                else
                {
                    // Find an element that's one page up
                    if (currentIndex == firstFullyVisible || currentIndex == firstVisible)
                    {
                        // currentIndex is visible, we can calculate where the scrollRect top
                        // would end up if we scroll by a page                    
                        y = getVerticalScrollPositionDelta(NavigationUnit.PAGE_UP) + getScrollRect().top;
                    }
                    else
                    {
                        // currentIndex is not visible, just find an element a page up from currentIndex
                        y = getElementBounds(currentIndex).bottom - getScrollRect().height;
                    }

                    // Find the element after the last element that spans above the y position
                    newIndex = currentIndex - 1;
                    while (0 <= newIndex)
                    {
                        bounds = getElementBounds(newIndex);
                        if (bounds && bounds.top < y)
                        {
                            // This element spans the y position, so return the next one
                            newIndex = Math.min(currentIndex - 1, newIndex + 1);
                            break;
                        }
                        newIndex--;    
                    }
                }
                break;
            }

            case NavigationUnit.PAGE_DOWN:
            {
                // Find the last fully visible element:
                var lastVisible:int = lastIndexInView;
                var lastFullyVisible:int = lastVisible;
                if (fractionOfElementInView(lastFullyVisible) < 1)
                    lastFullyVisible -= 1;
                
                // Is the current element in the middle of the viewport?
                if (firstIndexInView <= currentIndex && currentIndex < lastFullyVisible)
                    newIndex = lastFullyVisible;
                else
                {
                    // Find an element that's one page down
                    if (currentIndex == lastFullyVisible || currentIndex == lastVisible)
                    {
                        // currentIndex is visible, we can calculate where the scrollRect bottom
                        // would end up if we scroll by a page                    
                        y = getVerticalScrollPositionDelta(NavigationUnit.PAGE_DOWN) + getScrollRect().bottom;
                    }
                    else
                    {
                        // currentIndex is not visible, just find an element a page down from currentIndex
                        y = getElementBounds(currentIndex).top + getScrollRect().height;
                    }

                    // Find the element before the first element that spans below the y position
                    newIndex = currentIndex + 1;
                    while (newIndex <= maxIndex)
                    {
                        bounds = getElementBounds(newIndex);
                        if (bounds && bounds.bottom > y)
                        {
                            // This element spans the y position, so return the previous one
                            newIndex = Math.max(currentIndex + 1, newIndex - 1);
                            break;
                        }
                        newIndex++;    
                    }
                }
                break;
            }

            default: return super.getNavigationDestinationIndex(currentIndex, navigationUnit, arrowKeysWrapFocus);
        }
        return Math.max(0, Math.min(maxIndex, newIndex));  
    }
    
    /**
     *  @private
     * 
     *  Used only for virtual layout.
     */
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
       return NaN;  // not constrained
    }
    
    /**
     *  @private
     * 
     *  Used only for virtual layout.
     */
    private function calculateElementX(elt:ILayoutElement, eltWidth:Number, containerWidth:Number):Number
    {
       switch(horizontalAlign)
       {
           case HorizontalAlign.CENTER: 
               return Math.round((containerWidth - eltWidth) * 0.5);
           case HorizontalAlign.RIGHT: 
               return containerWidth - eltWidth;
       }
       return 0;  // HorizontalAlign.LEFT
    }


    /**
     *  @private
     * 
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
        var targetWidth:Number = Math.max(0, layoutTarget.width - paddingLeft - paddingRight);
        var minVisibleY:Number = layoutTarget.verticalScrollPosition;
        var maxVisibleY:Number = minVisibleY + layoutTarget.height;
       
        updateLLV(layoutTarget);
		
		// Find the index of the first visible item. Since the item's bounds includes the gap
		// that follows it, we want to avoid looking at an item that has only a portion of
		// its gap intersecting with the visible region.
		// We have to also be careful, as gap could be negative and in that case, we should
		// simply start from minVisibleY - SDK-22497.
        var startIndex:int = llv.indexOf(Math.max(0, minVisibleY + gap));
        if (startIndex == -1)
            return;
                        
        var fixedRowHeight:Number = NaN;
        if (!variableRowHeight)
            fixedRowHeight = rowHeight;  // may query typicalLayoutElement, elt at index=0
        
        var justifyWidths:Boolean = horizontalAlign == HorizontalAlign.JUSTIFY;
        var eltWidth:Number = (justifyWidths) ? targetWidth : NaN;
        var eltHeight:Number = NaN;  
        var contentWidth:Number = (justifyWidths) ? Math.max(llv.minMinorSize, targetWidth) : llv.minorSize;
        var containerWidth:Number = Math.max(contentWidth, targetWidth);        
        var y:Number = llv.start(startIndex);
        var index:int = startIndex;
        var x0:Number = paddingLeft;
        
        // First pass: compute element x,y,width,height based on 
        // current contentWidth; cache computed widths/heights in llv.
        for (; (y < maxVisibleY) && (index < eltCount); index++)
        {
            var elt:ILayoutElement = layoutTarget.getVirtualElementAt(index, eltWidth, eltHeight);
            var w:Number = calculateElementWidth(elt, targetWidth, containerWidth); // can be NaN
            var h:Number = fixedRowHeight; // NaN for variable height rows
            elt.setLayoutBoundsSize(w, h);
            w = elt.getLayoutBoundsWidth();        
            h = elt.getLayoutBoundsHeight();            
            var x:Number = x0 + calculateElementX(elt, w, containerWidth);
            elt.setLayoutBoundsPosition(x, y);
            llv.cacheDimensions(index, elt);
            y += h + gap;
        }
        var endIndex:int = index - 1;

        // Second pass: if neccessary, fix up x and width values based
        // on the updated contentWidth
        if (!justifyWidths && (llv.minorSize != contentWidth))
        {
            contentWidth = llv.minorSize;
            containerWidth = Math.max(contentWidth, targetWidth);            
            if (horizontalAlign != HorizontalAlign.LEFT)
            {
                for (index = startIndex; index <= endIndex; index++)
                {
                    elt = layoutTarget.getVirtualElementAt(index, eltWidth, eltHeight);
                    w = calculateElementWidth(elt, targetWidth, containerWidth);  // can be NaN
                    elt.setLayoutBoundsSize(w, elt.getLayoutBoundsHeight());
                    w = elt.getLayoutBoundsWidth();
                    x = x0 + calculateElementX(elt, w, containerWidth);
                    elt.setLayoutBoundsPosition(x, elt.getLayoutBoundsY());
                }
            }
        }

        setRowCount(index - startIndex);
        setIndexInView(startIndex, endIndex);
        
        // Make sure that if the content spans partially over a pixel to the right/bottom,
        // the content size includes the whole pixel.
        var paddedContentWidth:Number = Math.ceil(contentWidth + paddingLeft + paddingRight);
        var paddedContentHeight:Number = Math.ceil(llv.end(llv.length - 1) + paddingBottom);
        layoutTarget.setContentSize(paddedContentWidth, paddedContentHeight);
    }
    

    /**
     *  @private
     */
    private function updateDisplayListReal():void
    {
        var layoutTarget:GroupBase = target;
        var targetWidth:Number = Math.max(0, layoutTarget.width - paddingLeft - paddingRight);
        var targetHeight:Number = Math.max(0, layoutTarget.height - paddingTop - paddingBottom);
        
        var layoutElement:ILayoutElement;
        var count:uint = layoutTarget.numElements;
        
        // If horizontalAlign is left, we don't need to figure out the contentWidth
        // Otherwise the contentWidth is used to position the element and even size 
        // the element if it's "contentJustify" or "justify".
        var containerWidth:Number = targetWidth;        
        
        // FIXME (egeorgie): in the center or right case, we end up calculating percentWidth 
        // twice.  Once here for the contentWidth and once in distributeHeight
        // to size that particular element.
        if (horizontalAlign == HorizontalAlign.CONTENT_JUSTIFY ||
           (clipAndEnableScrolling && (horizontalAlign == HorizontalAlign.CENTER ||
                                       horizontalAlign == HorizontalAlign.RIGHT))) 
        {
            for (var i:int = 0; i < count; i++)
            {
                layoutElement = layoutTarget.getElementAt(i);
                if (!layoutElement || !layoutElement.includeInLayout)
                    continue;

                var layoutElementWidth:Number;
                if (!isNaN(layoutElement.percentWidth))
                    layoutElementWidth = calculatePercentWidth(layoutElement, targetWidth);
                else
                    layoutElementWidth = layoutElement.getPreferredBoundsWidth();
                
                containerWidth = Math.max(containerWidth, Math.ceil(layoutElementWidth));
            }
        }

        distributeHeight(targetWidth, targetHeight, containerWidth);
        
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
        var x0:Number = paddingLeft;
        var y:Number = paddingTop;
        var maxX:Number = paddingLeft;
        var maxY:Number = paddingTop;
        var firstRowInView:int = -1;
        var lastRowInView:int = -1;
        
        for (var index:int = 0; index < count; index++)
        {
            layoutElement = layoutTarget.getElementAt(index);
            if (!layoutElement || !layoutElement.includeInLayout)
                continue;
                
            // Set the layout element's position
            var dx:Number = Math.ceil(layoutElement.getLayoutBoundsWidth());
            var dy:Number = Math.ceil(layoutElement.getLayoutBoundsHeight());

            var x:Number = x0 + (containerWidth - dx) * hAlign;
            // In case we have HorizontalAlign.CENTER we have to round
            if (hAlign == 0.5)
                x = Math.round(x);
            layoutElement.setLayoutBoundsPosition(x, y);
                            
            // Update maxX,Y, first,lastVisibleIndex, and y
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
        
        // Make sure that if the content spans partially over a pixel to the right/bottom,
        // the content size includes the whole pixel.
        layoutTarget.setContentSize(Math.ceil(maxX + paddingRight),
                                    Math.ceil(maxY + paddingBottom));
    }
    
    /**
     *  @private
     * 
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
    private function distributeHeight(width:Number, 
                                      height:Number, 
                                      restrictedWidth:Number):Number
    {
        var spaceToDistribute:Number = height;
        var totalPercentHeight:Number = 0;
        var childInfoArray:Array = [];
        var childInfo:LayoutElementFlexChildInfo;
        var layoutElement:ILayoutElement;
        
        // rowHeight can be expensive to compute
        var rh:Number = (variableRowHeight) ? 0 : Math.ceil(rowHeight);
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
            
            if (!isNaN(layoutElement.percentHeight) && variableRowHeight)
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
                
                spaceToDistribute -= Math.ceil(layoutElement.getLayoutBoundsHeight());
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

            var roundOff:Number = 0;            
            for each (childInfo in childInfoArray)
            {
                // Make sure the calculated percentages are rounded to pixel boundaries
                var childSize:int = Math.round(childInfo.size + roundOff);
                roundOff += childInfo.size - childSize;

                sizeLayoutElement(childInfo.layoutElement, width, horizontalAlign, 
                               restrictedWidth, childSize, 
                               variableRowHeight, rh);
            }
        }
        return spaceToDistribute;
    }
    
    /**
     *  @private
     */
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        var layoutTarget:GroupBase = target; 
        if (!layoutTarget)
            return;
            
        if ((layoutTarget.numElements == 0) || (unscaledWidth == 0) || (unscaledHeight == 0))
        {
            setRowCount(0);
            setIndexInView(-1, -1);
            if (layoutTarget.numElements == 0)
                layoutTarget.setContentSize(Math.ceil(paddingLeft + paddingRight),
                                            Math.ceil(paddingTop + paddingBottom));
            return;         
        }
        
        if (useVirtualLayout) 
            updateDisplayListVirtual();
        else
            updateDisplayListReal();
    }
    
    /**
     *  @private 
     *  Convenience function for subclasses that invalidates the
     *  target's size and displayList so that both layout's <code>measure()</code>
     *  and <code>updateDisplayList</code> methods get called.
     * 
     *  <p>Typically a layout invalidates the target's size and display list so that
     *  it gets a chance to recalculate the target's default size and also size and
     *  position the target's elements. For example changing the <code>gap</code>
     *  property on a <code>VerticalLayout</code> will internally call this method
     *  to ensure that the elements are re-arranged with the new setting and the
     *  target's default size is recomputed.</p> 
     */
    private function invalidateTargetSizeAndDisplayList():void
    {
        var g:GroupBase = target;
        if (!g)
            return;

        g.invalidateSize();
        g.invalidateDisplayList();
    }
        
}
}

import mx.core.ILayoutElement;
import mx.containers.utilityClasses.FlexChildInfo;

class LayoutElementFlexChildInfo extends FlexChildInfo
{
    public var layoutElement:ILayoutElement;    
}
