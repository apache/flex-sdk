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

package spark.layout.supportClasses
{

import flash.geom.Point;
import flash.geom.Rectangle;

import spark.components.supportClasses.GroupBase;
import spark.core.ScrollUnit;
import mx.core.ILayoutElement;
import mx.utils.OnDemandEventDispatcher;

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
 *  <p>Subclasses may override methods like <code>elementBoundsAboveScrollRect()</code>
 *  and <code>elementBoundsBelowScrollRect()</code> to customize the way 
 *  the target behaves when it's connected to scrollbars.</p>
 * 
 *  <p>Subclasses that support virtualization must respect the 
 *  <code>useVirtualLayout</code> property and should only retrieve
 *  layout elements within the scrollRect (the value of
 *  <code>getTargetScrollRect()</code>) using <code>getVirtualElementAt()</code>
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
     *  If true, subclasses will be advised that it's
     *  preferable to lazily create layout elements as they come into view,
     *  and to discard or recycle layout elements that are no longer in view.
     * 
     *  <p>You should implement virtualization support if the layout is going
     *  to be used with data containers and you want to spend resources only
     *  on the data items that are displayed on the screen.
     *  To support virtualization, a layout must be implemented in such a way
     *  that it does not iterate through all of the target's elements as anytime 
     *  you access a data container element, the container allocates an
     *  <code>ItemRenderer</code> for the corresponding data item.
     *  Instead, you should calculate and only access the elements that will be in view.
     *  A typical implementation of a virtual layout will examine the target's
     *  scrollRect and the size of the typicalLayoutElement to determine which
     *  elements will be in view. Additionally some layouts, like the
     *  <code>VerticalLayout</code> and the <code>HorizontalLayout</code>, keep a
     *  cache of the sizes of all elements that have already been accessed
     *  for more precise calculations for casese of bigger variations
     *  in sizes between the typicalLayoutElement and the actual elements.</p>
     * 
     *  @default false
     * 
     *  @see #getTargetScrollRect
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
     *  @see spark.layout.VerticalLayout#variableRowHeight
     *  @see spark.layout.HorizontalLayout#variableColumnWidth
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get typicalLayoutElement():ILayoutElement
    {
        if (!_typicalLayoutElement && target && (target.numElements > 0))
            _typicalLayoutElement = target.getVirtualElementAt(0);
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
     * 
     *  @see #invalidateTargetDisplayList
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
     *  target's displayList so that the layout's <code>updateDisplayList()</code>
     *  gets called.
     * 
     *  <p>Typically a layout invalidates the target's display list so that
     *  it gets a chance to size and position the target's elements, but doesn't need to
     *  recompute the target's default size. For example changing the <code>horizontalAlign</code>
     *  property on a <code>VerticalLayout</code> will internally call this method
     *  to ensure that the elements are re-arranged with the new setting.
     *  The <code>horizontalAlign</code> does not affect the target's default size.</p>
     *
     *  @see #invalidateTargetSizeAndDisplayList
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
}
}
