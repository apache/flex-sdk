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

package spark.core
{

import mx.core.IVisualElement;

/**
 *  The IViewport interface is implemented by components that support a viewport. 
 *  If a component's children are larger than the component, 
 *  and you want to clip the children to the component boundaries, you can define a viewport and scroll bars. 
 *  A viewport is a rectangular subset of the area of a component that you want to display, 
 *  rather than displaying the entire component.
 *
 *  <p>A viewport on its own is not movable by the application user. 
 *  However, you can combine a viewport with scroll bars so the user can scroll 
 *  the viewport to see the entire content of the component. 
 *  Use the Scroller component to add scrolbars to the component.</p>
 *
 *  @see spark.components.Scroller
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface IViewport extends IVisualElement
{
    
    /**
     *  The width of the viewport along the x axis. 
     *  The value of this property is defined relative to the component's
     *  coordinate system.
     * 
     *  <p>Implementations of this property must be Bindable and
     *  must generate events of type <code>propertyChange</code>.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get contentWidth():Number;
    
    /**
     *  The height of the viewport along the y axis.
     *  The value of this property is defined relative to the container's
     *  coordinate system.
     *
     *  <p>Implementations of this property must be Bindable and
     *  must generate events of type <code>propertyChange</code>.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get contentHeight():Number;

    /**
     *  The x coordinate of the origin of the viewport in the component's coordinate system, 
     *  where the default value is (0,0) corresponding to the upper-left corner of the component.
     * 
     *  If <code>clipAndEnableScrolling</code> is <code>true</code>, setting this property 
     *  typically causes the viewport to be set to:
     *  <pre>
     *  new Rectangle(horizontalScrollPosition, verticalScrollPosition, width, height)
     *  </pre>
     * 
     *  Implementations of this property must be Bindable and
     *  must generate events of type <code>propertyChange</code>.
     *   
     *  @default 0
     * 
     *  @see target
     *  @see verticalScrollPosition
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get horizontalScrollPosition():Number;
    function set horizontalScrollPosition(value:Number):void;
     
     /**
     *  The y coordinate of the origin of the viewport in the component's coordinate system, 
     *  where the default value is (0,0) corresponding to the upper-left corner of the component.
     * 
     *  If <code>clipAndEnableScrolling</code> is <code>true</code>, setting this property 
     *  typically causes the viewport to be set to:
     *  <pre>
     *  new Rectangle(horizontalScrollPosition, verticalScrollPosition, width, height)
     *  </pre>
     * 
     *  Implementations of this property must be Bindable and
     *  must generate events of type <code>propertyChange</code>.
     *   
     *  @default 0
     * 
     *  @see horizontalScrollPosition
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get verticalScrollPosition():Number;
    function set verticalScrollPosition(value:Number):void;
    
    /**
     *  Returns the amount to add to the viewport's current 
     *  <code>horizontalScrollPosition</code> to scroll by the requested scrolling unit.
     *
     *  @param scrollUnit The amount to scroll. 
     *  The value of unit must be one of the following spark.core.ScrollUnit
     *  constants: <code>LEFT</code>, <code>RIGHT</code>, <code>PAGE_LEFT</code>, 
     *  <code>PAGE_RIGHT</code>, <code>HOME</code>, or <code>END</code>.
     *  To scroll by a single column, use <code>LEFT</code> or <code>RIGHT</code>.
     *  To scroll to the first or last column, use <code>HOME</code> or <code>END</code>.
     *
     *  @return The number of pixels to add to <code>horizontalScrollPosition</code>.
     * 
     *  @see ScrollUnit
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function getHorizontalScrollPositionDelta(scrollUnit:uint):Number;
    
    /**
     *  Returns the amount to add to the viewport's current 
     *  <code>verticalScrollPosition</code> to scroll by the requested scrolling unit.
     *
     *  @param scrollUnit The amount to scroll. 
     *  The value of unit must be one of the following spark.core.ScrollUnit
     *  constants: <code>UP</code>, <code>DOWN</code>, <code>PAGE_UP</code>, 
     *  <code>PAGE_DOWN</code>, <code>HOME</code>, or <code>END</code>.
     *  To scroll by a single row use <code>UP</code> or <code>DOWN</code>.
     *  To scroll to the first or last row, use <code>HOME</code> or <code>END</code>.
     *
     *  @return The number of pixels to add to <code>verticalScrollPosition</code>.
     * 
     *  @see ScrollUnit
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function getVerticalScrollPositionDelta(scrollUnit:uint):Number;
     
    /**
     *  If <code>true</code>, specifies to clip the children to the boundaries of the viewport. 
     *  If <code>false</code>, the container children extend past the container boundaries, 
     *  regardless of the size specification of the component. 
     *  
     *  @default false
     *
     *  @see LayoutBase#updateScrollRect
     *  @see verticalScrollPosition
     *  @see horizontalScrollPosition
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get clipAndEnableScrolling():Boolean;
    function set clipAndEnableScrolling(value:Boolean):void;    
}

}
