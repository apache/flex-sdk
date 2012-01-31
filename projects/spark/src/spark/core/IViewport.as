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

package mx.core
{
import flash.events.IEventDispatcher;

public interface IViewport extends IEventDispatcher
{
    function get width():Number;
    function get height():Number;
    
    /**
     *  The positive extent of the content, relative to the 0,0
     *  origin, along the X axis.
     * 
     *  The value of this property is defined relative to the container's
     *  coordinate system.
     * 
     *  Implementations of this property must be Bindable and
     *  they must generate events of type "propertyChange".
     */
    function get contentWidth():Number;
    
    /**
     *  The positive extent of the content, relative to the 0,0 
     *  origin, along the Y axis.
     * 
     *  The value of this property is defined relative to the container's
     *  coordinate system.
     *
     *  Implementations of this property must be Bindable and
     *  they must generate events of type "propertyChange".  
     */
    function get contentHeight():Number;

    /**
     *  The X coordinate of the origin of the region the target is
     *  scrolled to.  
     * 
     *  If clipContent is true, setting this property typically causes 
     *  <code>scrollRect</code> to be set to:
     *  <pre>
     *  new Rectangle(horizontalScrollPosition, verticalScrollPosition, width, height)
     *  </pre>
     * 
     *  Implementations of this property must be Bindable and
     *  they must generate events of type "propertyChange".
     *   
     *  @default 0
     *  @see target
     *  @see verticalScrollPosition
     */
    function get horizontalScrollPosition():Number;
    function set horizontalScrollPosition(value:Number):void;
     
     /**
     *  The Y coordinate of the origin of the region this Group is
     *  scrolled to.  
     * 
     *  If clipContent is true, stting this property typically causes 
     *  the <code>scrollRect</code> to be set to:
     *  <pre>
     *  new Rectangle(horizontalScrollPosition, verticalScrollPosition, width, height)
     *  </pre>                 
     * 
     *  Implementations of this property must be Bindable and
     *  they must generate events of type "propertyChange".
     *   
     *  @default 0
     *  @see horizontalScrollPosition
     */
    function get verticalScrollPosition():Number;
    function set verticalScrollPosition(value:Number):void;
    
    /**
     *  Returns the amount one would have to add to the viewport's current 
     *  horizontalScrollPosition to scroll by the requested "scrolling" unit.
     * 
     *  The value of unit must be one of the following mx.core.ScrollUnit
     *  constants: LEFT, RIGHT, PAGE_LEFT, PAGE_RIGHT, HOME, END.
     * 
     *  To scroll by a single column use LEFT or RIGHT and to scroll to the
     *  first or last column, use HOME or END.
     * 
     *  @see ScrollUnit
     */
    function getHorizontalScrollPositionDelta(unit:ScrollUnit):Number
    
    /**
     *  Returns the amount one would have to add to the viewport's current 
     *  verticalScrollPosition to scroll by the requested "scrolling" unit.
     * 
     *  The value of unit must be one of the following mx.core.ScrollUnit
     *  constants: UP, DOWN, PAGE_UP, PAGE_DOWN, HOME, END.
     * 
     *  To scroll by a single row use UP or DOWN and to scroll to the
     *  first or last row, use HOME or END.
     * 
     *  @see ScrollUnit
     */
    function getVerticalScrollPositionDelta(unit:ScrollUnit):Number
     
    /**
     *  If true then clip the viewport's contents by setting its scrollRect
     *  to a rectangle with origin at horizontalScrollPosition,
     *  verticalScrollPosition and width and height equal to the 
     *  viewport's width and height.
     * 
     *  If false, the scrollRect is set to null.
     * 
     *  @default false
     *  @see LayoutBase#updateScrollRect
     *  @see verticalScrollPosition
     *  @see horizontalScrollPosition
     */
    function get clipContent():Boolean;
    function set clipContent(value:Boolean):void;    
}

}
