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

package spark.layouts.supportClasses
{

import flash.geom.Point;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.ui.Keyboard; 

import spark.components.supportClasses.GroupBase;
import spark.core.NavigationUnit;
import mx.core.ILayoutElement;
import mx.utils.OnDemandEventDispatcher;
import spark.core.NavigationUnit;

/**
 *  The base class for all layouts.
 * 
 *  To create a custom layout that works with the Spark containers,
 *  you must extend <code>LayoutBase</code> or one of its subclasses.
 *
 *  <p>At minimum, subclasses must implement the <code>updateDisplayList()</code>
 *  method, which positions and sizes the target GroupBase's elements, and 
 *  the <code>measure()</code> method, which calculates the target's default
 *  size.</p>
 *
 *  <p>Subclasses may override methods like <code>getElementBoundsAboveScrollRect()</code>
 *  and <code>getElementBoundsBelowScrollRect()</code> to customize the way 
 *  the target behaves when it's connected to scrollbars.</p>
 * 
 *  <p>Subclasses that support virtualization must respect the 
 *  <code>useVirtualLayout</code> property and should only retrieve
 *  layout elements within the scrollRect (the value of
 *  <code>getScrollRect()</code>) using <code>getVirtualElementAt()</code>
 *  from within <code>updateDisplayList()</code>.</p>
 */
public class LayoutBase extends OnDemandEventDispatcher
{
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
     *  The GroupBase whose elements are measured, sized and positioned
     *  by this layout.
     * 
     *  <p>Subclasses may override the setter to perform target specific
     *  actions. For example a 3D layout may set the target's
     *  <code>maintainProjectionCenter</code> property here.</p> 
     *
     *  @default null
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
        if (_target == value)
            return;
        clearVirtualLayoutCache();
        _target = value;
    }
    
    //----------------------------------
    //  useVirtualLayout
    //----------------------------------

    private var _useVirtualLayout:Boolean = false;

    [Inspectable(defaultValue="false")]

    /**
     *  If true, subclasses must only layout elements that are in view based on the 
     *  current scrollRect.
     * 
     *  Layout subclasses that do not support virtualization must prevent changing
     *  this property.
     * 
     *  When useVirtualLayout=true, layouts that support virtualization must use 
     *  target.getVirtualElementAt(), rather than getElementAt(), and must only get the 
     *  elements they anticipate will be visible given the value of getScrollRect().
     * 
     *  To support useVirtualLayout=true, the layout class must be able to compute
     *  the indices of the layout elements that overlap the scrollRect in its 
     *  updateDisplayList() method based exclusively on cached information, not
     *  by getting layout elements and examining their bounds.
     * 
     *  Typically virtual layouts update their cached information in updateDisplayList(),
     *  based on the sizes and locations computed for the elements in view.
     * 
     *  Similarly, at measure() time, virtual layouts should update the target's 
     *  measured size properties based on the typicalLayoutElement and other
     *  cached layout information, not by measuring elements.
     * 
     *  Presently only "data containers", i.e. that containers that construct 
     *  an ItemRenderer layout element for each dataProvider item, support virtualization.   
     * 
     *  DataGroup is a data container and SkinnableDataContainer (e.g. List
     *  and DropDownList) has a DataGroup skin part.
     * 
     *  Data containers cooperate with useVirtualLayout=true layouts by 
     *  "recycling" ItemRenderers that were previously constructed in response
     *  to getVirtualLayoutElement() calls by are no longer in use.
     * 
     *  An item is considered to be no longer in use if its index is not
     *  within the range of getVirtualElementAt() indices requested during
     *  the container's most recent updateDisplayList() invocation.
     *  @default false
     * 
     *  @see #getScrollRect
     *  @see #typicalLayoutElement
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

        dispatchEvent(new Event("useVirtualLayoutChanged"));
        
        if (_useVirtualLayout && !value)  // turning virtual layout off
            clearVirtualLayoutCache();
                     
        _useVirtualLayout = value;
        if (target)
            target.invalidateDisplayList();
    }     
    
    /**
     *  When useVirtualLayout=true, this method can be used by the layout target
     *  to clear cached layout information when target state that might invalidate
     *  such information changes.   
     * 
     *  For example, when a DataGroup's dataProvider or itemRenderer changes, cached 
     *  elements sizes will become invalid. 
     * 
     *  When useVirtualLayout changes to false, this method is called automatically.
     * 
     *  Subclasses that support useVirtualLayout=true must override this method. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function clearVirtualLayoutCache():void
    {
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
     *  @see spark.layouts.VerticalLayout#variableRowHeight
     *  @see spark.layouts.HorizontalLayout#variableColumnWidth
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
     *  Measures the target's default size based on its content, and optionally
     *  measures the target's default minimum size.
     *
     *  <p>This is one of the methods that you must override when creating a
     *  subclass of LayoutBase. The other method is <code>updateDisplayList()</code>.
     *  You do not call these methods directly. Flex calls this method as part
     *  of a layout pass. A layout pass consists of three phases.</p>
     *
     *  <p>First, if the target's properties are invalid, the LayoutManager calls
     *  the target's <code>commitProperties</code> method.</p>
     *
     *  <p>Second, if the target's size is invalid, LayoutManager calls the target's
     *  <code>validateSize()</code> method. The target's <code>validateSize()</code>
     *  will in turn call the layout's <code>measure()</code> to calculate the
     *  target's default size unless it was explicitly specified by both target's
     *  <code>explicitWidth</code> and <code>explicitHeight</code> properties.
     *  If the default size changes, Flex will invalidate the target's display list.</p>
     *
     *  <p>Last, if the target's display list is invalid, LayoutManager calls the target's
     *  <code>validateDisplayList</code>. The target's <code>validateDisplayList</code>
     *  will in turn call the layout's <code>updateDisplayList</code> method to
     *  size and position the target's elements.</p>
     *
     *  <p>When implementing this method, you must set the target's
     *  <code>measuredWidth</code> and <code>measuredHeight</code> properties
     *  to define the target's default size. You may optionally set the
     *  <code>measuredMinWidth</code> and <code>measuredMinHeight</code>
     *  properties to define the default minimum size.
     *  A typical implementation iterates through the target's elements
     *  and uses the methods defined by the <code>ILayoutElement</code> to
     *  accumulate the preferred and/or minimum sizes of the elements and then sets
     *  the target's <code>measuredWidth</code>, <code>measuredHeight</code>,
     *  <code>measuredMinWidth</code> and <code>measuredMinHeight</code>.</p>
     *
     *  @see #updateDisplayList
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
     *  Sizes and positions the target's elements.
     *
     *  <p>This is one of the methods that you must override when creating a
     *  subclass of LayoutBase. The other method is <code>measure()</code>.
     *  You do not call these methods directly. Flex calls this method as part
     *  of a layout pass. A layout pass consists of three phases.</p>
     *
     *  <p>First, if the target's properties are invalid, the LayoutManager calls
     *  the target's <code>commitProperties</code> method.</p>
     *
     *  <p>Second, if the target's size is invalid, LayoutManager calls the target's
     *  <code>validateSize()</code> method. The target's <code>validateSize()</code>
     *  will in turn call the layout's <code>measure()</code> to calculate the
     *  target's default size unless it was explicitly specified by both target's
     *  <code>explicitWidth</code> and <code>explicitHeight</code> properties.
     *  If the default size changes, Flex will invalidate the target's display list.</p>
     *
     *  <p>Last, if the target's display list is invalid, LayoutManager calls the target's
     *  <code>validateDisplayList</code>. The target's <code>validateDisplayList</code>
     *  will in turn call the layout's <code>updateDisplayList</code> method to
     *  size and position the target's elements.</p>
     *
     *  <p>A typical implementation iterates through the target's elements
     *  and uses the methods defined by the <code>ILayoutElement</code> to
     *  position and resize the elements. Then the layout must also calculate and set
     *  the target's <code>contentWidth</code> and <code>contentHeight</code>
     *  properties to define the target's scrolling region.</p>
     *
     *  @param unscaledWidth Specifies the width of the target, in pixels,
     *  in the targets's coordinates.
     *
     *  @param unscaledHeight Specifies the height of the component, in pixels,
     *  in the target's coordinates.
     *
     *  @see #measure
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function updateDisplayList(width:Number, height:Number):void
    {
    }          

    /**
     *  This method must is called by the target after a layout element 
     *  has been added and before the target's size and display list are
     *  validated.   
     * 
     *  Layouts that cache per element state, like virtual layouts, can 
     *  override this method to update their cache.
     * 
     *  If the target calls this method, it's only guaranteeing that a
     *  a layout element will exist at the specified index at
     *  <code>updateDisplayList()</code> time, for example a DataGroup
     *  with a virtual layout will call this method when a dataProvider
     *  item is added.
     * 
     *  By default, this method does nothing.
     * 
     *  @param index The index of the element that was added.
     *  @see #elementRemoved    
     */
     public function elementAdded(index:int):void
     {
     }

    /**
     *  This method must is called by the target after a layout element 
     *  has been removed and before the target's size and display list are
     *  validated.   
     * 
     *  Layouts that cache per element state, like virtual layouts, can 
     *  override this method to update their cache.
     * 
     *  If the target calls this method, it's only guaranteeing that a
     *  a layout element will no longer exist at the specified index at
     *  <code>updateDisplayList()</code> time, for example a DataGroup
     *  with a virtual layout will call this method when a dataProvider
     *  item is added.
     * 
     *  By default, this method does nothing.
     * 
     *  @param index The index of the element that was added.
     *  @see #elementAdded
     */
     public function elementRemoved(index:int):void
     {
     }

    /**
     *  Called when the verticalScrollPosition or horizontalScrollPosition 
     *  properties change.
     *
     *  The default implementation updates the target's scrollRect property by
     *  calling <code>updateScrollRect()</code>.
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
     *  Called by the target at the end of its <code>updateDisplayList</code>
     *  to have the layout update its scrollRect.
     * 
     *  If clipAndEnableScrolling is true, the default implementation
     *  sets the origin of the scrollRect to verticalScrollPosition,
     *  horizontalScrollPosition and its size to the width, height
     *  parameters (the target's unscaled width,height).
     * 
     *  If clipAndEnableScrolling is false, the default implementation
     *  sets the scrollRect to null.
     *  
     *  @param width The target's width.
     *  @param height The target's height.
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
     *  Delegation method that determines which item  
     *  to navigate to based on the current item in focus 
     *  and user input in terms of NavigationUnit. This method
     *  is used by derivatives of ListBase to handle 
     *  keyboard navigation. ListBase maps user input to
     *  NavigationUnit constants.
     * 
     *  Subclasses can override this method to compute other 
     *  values that are based on the current index and key 
     *  stroke encountered. 
     * 
     *  @param currentIndex The current index of the item with focus.
     * 
     *  @param navigationUnit The NavigationUnit constant that determines
     *  which item to navigate to next.  
     * 
     *  @param arrowKeysWrapFocus If <code>true</code>, using arrow keys to 
     *  navigate within the component wraps when it hits either end.
     * 
     *  @return The index of the next item to jump to. Returns -1
     *  when if the layout doens't recognize the navigationUnit.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */  
    public function getNavigationDestinationIndex(currentIndex:int, navigationUnit:uint, arrowKeysWrapFocus:Boolean):int
     {
        if (!target || target.numElements < 1)
            return -1; 
            
         //Sub-classes implement according to their own layout 
         //logic. Common cases handled here. 
         switch (navigationUnit)
         {
             case NavigationUnit.HOME:
                 return 0; 

             case NavigationUnit.END:
                 return target.numElements - 1; 

             default:
                 return -1;
         }
     }

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
    protected function getScrollRect():Rectangle
    {
        var g:GroupBase = target;
        if (!g || !g.clipAndEnableScrolling)
            return null;     
        var vsp:Number = g.verticalScrollPosition;
        var hsp:Number = g.horizontalScrollPosition;
        return new Rectangle(hsp, vsp, g.width, g.height);
    }
    
   /**
     *  Returns the specified element's layout bounds as a Rectangle or null
     *  if the index is invalid, the corresponding element is null
     *  or <code>includeInLayout=false</code>, or if this layout's target is null.
     *   
     *  Layout subclasses that support <code>useVirtualLayout=true</code> must
     *  override this method to compute a potentially approximate value for
     *  elements that are not in view.
     * 
     *  @return Returns the specified element's layout bounds.
     *  @param index Index of the layout element.
     * 
     *  @see mx.core.ILayoutElement#getLayoutBoundsX
     *  @see mx.core.ILayoutElement#getLayoutBoundsY
     *  @see mx.core.ILayoutElement#getLayoutBoundsWidth
     *  @see mx.core.ILayoutElement#getLayoutBoundsHeight
     *   
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function getElementBounds(index:int):Rectangle
    {
        var g:GroupBase = target;
        if (!g)
            return null;

         var n:int = g.numElements;
         if ((index < 0) || (index >= n))
            return null;
            
         var elt:ILayoutElement = g.getElementAt(index);
         if (!elt || !elt.includeInLayout)
            return null;
            
         var eltX:Number = elt.getLayoutBoundsX();
         var eltY:Number = elt.getLayoutBoundsY();
         var eltW:Number = elt.getLayoutBoundsWidth();
         var eltH:Number = elt.getLayoutBoundsHeight();
         return new Rectangle(eltX, eltY, eltW, eltH);
    }

    /**
     *  Returns the bounds of the first layout element that either spans or
     *  is to the left of the scrollRect's left edge.
     * 
     *  <p>This is a convenience method that is used by the default
     *  implementation of the <code>getHorizontalScrollPositionDelta()</code> method.
     *  Subclasses that rely on the default implementation of
     *  <code>getHorizontalScrollPositionDelta()</code> should override this method to
     *  provide an accurate bounding rectangle that has valid <code>left</code> and 
     *  <code>right</code> properties.</p>
     * 
     *  By default this method returns a Rectangle with width=1, height=0, 
     *  whose left edge is one less than the scrollRect's left edge, 
     *  and top=0.
     * 
     *  @param scrollRect The target's scrollRect.
     *  @return Returns the bounds of the first element that spans or is to
     *  the left of the scrollRect’s left edge.
     *  
     *  @see #getElementBoundsRightOfScrollRect
     *  @see #getElementBoundsAboveScrollRect
     *  @see #getElementBoundsBelowScrollRect
     *  @see #getHorizontalScrollPositionDelta
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function getElementBoundsLeftOfScrollRect(scrollRect:Rectangle):Rectangle
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
     *  <p>This is a convenience method that is used by the default
     *  implementation of the <code>getHorizontalScrollPositionDelta()</code> method.
     *  Subclasses that rely on the default implementation of
     *  <code>getHorizontalScrollPositionDelta()</code> should override this method to
     *  provide an accurate bounding rectangle that has valid <code>left</code> and 
     *  <code>right</code> properties.</p>
     * 
     *  By default this method returns a Rectangle with width=1, height=0, 
     *  whose right edge is one more than the scrollRect's right edge, 
     *  and top=0.
     * 
     *  @param scrollRect The target's scrollRect.
     *  @return Returns the bounds of the first element that spans or is to
     *  the right of the scrollRect’s right edge.
     *  
     *  @see #getElementBoundsLeftOfScrollRect
     *  @see #getElementBoundsAboveScrollRect
     *  @see #getElementBoundsBelowScrollRect
     *  @see #getHorizontalScrollPositionDelta
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function getElementBoundsRightOfScrollRect(scrollRect:Rectangle):Rectangle
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
     *  <p>This is a convenience method that is used by the default
     *  implementation of the <code>getVerticalScrollPositionDelta()</code> method.
     *  Subclasses that rely on the default implementation of
     *  <code>getVerticalScrollPositionDelta()</code> should override this method to
     *  provide an accurate bounding rectangle that has valid <code>top</code> and 
     *  <code>bottom</code> properties.</p>
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
     *  @see #getElementBoundsLeftOfScrollRect
     *  @see #getElementBoundsRightScrollRect
     *  @see #getElementBoundsBelowScrollRect
     *  @see #getVerticalScrollPositionDelta
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function getElementBoundsAboveScrollRect(scrollRect:Rectangle):Rectangle
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
     *  <p>This is a convenience method that is used by the default
     *  implementation of the <code>getVerticalScrollPositionDelta()</code> method.
     *  Subclasses that rely on the default implementation of
     *  <code>getVerticalScrollPositionDelta()</code> should override this method to
     *  provide an accurate bounding rectangle that has valid <code>top</code> and 
     *  <code>bottom</code> properties.</p>
     *
     *  By default this method returns a Rectangle with width=0, height=1, 
     *  whose bottom edge is one more than the scrollRect's bottom edge, 
     *  and left=0.
     *
     *  @param scrollRect The target's scrollRect.
     *  @return Returns the bounds of the first element that spans or is
     *  below the scrollRect’s bottom edge.
     *
     *  @see #getElementBoundsLeftOfScrollRect
     *  @see #getElementBoundsRightScrollRect
     *  @see #getElementBoundsAboveScrollRect
     *  @see #getVerticalScrollPositionDelta
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function getElementBoundsBelowScrollRect(scrollRect:Rectangle):Rectangle
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
     *  The implementation calls <code>getElementBoundsLeftOfScrollRect()</code> and
     *  <code>getElementBoundsRightOfScrollRect()</code> to determine the bounds of
     *  the elements.  Layout classes usually override those methods instead of
     *  getHorizontalScrollPositionDelta(). 
     * 
     *  @see #getElementBoundsLeftOfScrollRect
     *  @see #getElementBoundsRightOfScrollRect
     *  @see #getHorizontalScrollPositionDelta
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getHorizontalScrollPositionDelta(navigationUnit:uint):Number
    {
        var g:GroupBase = target;
        if (!g)
            return 0;     

        var scrollRect:Rectangle = getScrollRect();
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
        var getElementBounds:Rectangle;
        switch(navigationUnit)
        {
            case NavigationUnit.LEFT:
            case NavigationUnit.PAGE_LEFT:
                // Find the bounds of the first non-fully visible element
                // to the left of the scrollRect.
                getElementBounds = getElementBoundsLeftOfScrollRect(scrollRect);
                break;

            case NavigationUnit.RIGHT:
            case NavigationUnit.PAGE_RIGHT:
                // Find the bounds of the first non-fully visible element
                // to the right of the scrollRect.
                getElementBounds = getElementBoundsRightOfScrollRect(scrollRect);
                break;

            case NavigationUnit.HOME: 
                return minDelta;
                
            case NavigationUnit.END: 
                return maxDelta;
                
            default:
                return 0;
        }
        
        if (!getElementBounds)
            return 0;

        var delta:Number = 0;
        switch (navigationUnit)
        {
            case NavigationUnit.LEFT:
                // Snap the left edge of element to the left edge of the scrollRect.
                // The element is the the first non-fully visible element left of the scrollRect.
                delta = Math.max(getElementBounds.left - scrollRect.left, -scrollRect.width);
            break;    
            case NavigationUnit.RIGHT:
                // Snap the right edge of the element to the right edge of the scrollRect.
                // The element is the the first non-fully visible element right of the scrollRect.
                delta = Math.min(getElementBounds.right - scrollRect.right, scrollRect.width);
            break;    
            case NavigationUnit.PAGE_LEFT:
            {
                // Snap the right edge of the element to the right edge of the scrollRect.
                // The element is the the first non-fully visible element left of the scrollRect. 
                delta = getElementBounds.right - scrollRect.right;
                
                // Special case: when an element is wider than the scrollRect,
                // we want to snap its left edge to the left edge of the scrollRect.
                // The delta will be limited to the width of the scrollRect further below.
                if (delta >= 0)
                    delta = Math.max(getElementBounds.left - scrollRect.left, -scrollRect.width);  
            }
            break;
            case NavigationUnit.PAGE_RIGHT:
            {
                // Align the left edge of the element to the left edge of the scrollRect.
                // The element is the the first non-fully visible element right of the scrollRect.
                delta = getElementBounds.left - scrollRect.left;
                
                // Special case: when an element is wider than the scrollRect,
                // we want to snap its right edge to the right edge of the scrollRect.
                // The delta will be limited to the width of the scrollRect further below.
                if (delta <= 0)
                    delta = Math.min(getElementBounds.right - scrollRect.right, scrollRect.width);
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
     *  The implementation calls <code>getElementBoundsAboveScrollRect()</code> and
     *  <code>getElementBoundsBelowScrollRect()</code> to determine the bounds of
     *  the elements.  Layout classes usually override those methods instead of
     *  getVerticalScrollPositionDelta(). 
     * 
     *  @see #getElementBoundsAboveScrollRect
     *  @see #getElementBoundsBelowScrollRect
     *  @see #getVerticalScrollPositionDelta
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getVerticalScrollPositionDelta(navigationUnit:uint):Number
    {
        var g:GroupBase = target;
        if (!g)
            return 0;     

        var scrollRect:Rectangle = getScrollRect();
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
        var getElementBounds:Rectangle;
        switch(navigationUnit)
        {
            case NavigationUnit.UP:
            case NavigationUnit.PAGE_UP:
                // Find the bounds of the first non-fully visible element
                // that spans right of the scrollRect.
                getElementBounds = getElementBoundsAboveScrollRect(scrollRect);
                break;

            case NavigationUnit.DOWN:
            case NavigationUnit.PAGE_DOWN:
                // Find the bounds of the first non-fully visible element
                // that spans below the scrollRect.
                getElementBounds = getElementBoundsBelowScrollRect(scrollRect);
                break;

            case NavigationUnit.HOME: 
                return minDelta;

            case NavigationUnit.END: 
                return maxDelta;

            default:
                return 0;
        }
        
        if (!getElementBounds)
            return 0;

        var delta:Number = 0;
        switch (navigationUnit)
        {
            case NavigationUnit.UP:
                // Snap the top edge of element to the top edge of the scrollRect.
                // The element is the the first non-fully visible element above the scrollRect.
                delta = Math.max(getElementBounds.top - scrollRect.top, -scrollRect.height);
            break;    
            case NavigationUnit.DOWN:
                // Snap the bottom edge of the element to the bottom edge of the scrollRect.
                // The element is the the first non-fully visible element below the scrollRect.
                delta = Math.min(getElementBounds.bottom - scrollRect.bottom, scrollRect.height);
            break;    
            case NavigationUnit.PAGE_UP:
            {
                // Snap the bottom edge of the element to the bottom edge of the scrollRect.
                // The element is the the first non-fully visible element below the scrollRect. 
                delta = getElementBounds.bottom - scrollRect.bottom;
                
                // Special case: when an element is taller than the scrollRect,
                // we want to snap its top edge to the top edge of the scrollRect.
                // The delta will be limited to the height of the scrollRect further below.
                if (delta >= 0)
                    delta = Math.max(getElementBounds.top - scrollRect.top, -scrollRect.height);  
            }
            break;
            case NavigationUnit.PAGE_DOWN:
            {
                // Align the top edge of the element to the top edge of the scrollRect.
                // The element is the the first non-fully visible element below the scrollRect.
                delta = getElementBounds.top - scrollRect.top;
                
                // Special case: when an element is taller than the scrollRect,
                // we want to snap its bottom edge to the bottom edge of the scrollRect.
                // The delta will be limited to the height of the scrollRect further below.
                if (delta <= 0)
                    delta = Math.min(getElementBounds.bottom - scrollRect.bottom, scrollRect.height);
            }
            break;
        }

        return Math.min(maxDelta, Math.max(minDelta, delta));
    }
    
    /**
     *  LayoutBase::getScrollPositionDeltaToElement() computes the
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
     public function getScrollPositionDeltaToElement(index:int):Point
     {
         var elementR:Rectangle = getElementBounds(index);
         if (!elementR)
            return null;
         
         var scrollR:Rectangle = getScrollRect();
         if (!scrollR || !target.clipAndEnableScrolling)
            return null;
         
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
}
}
