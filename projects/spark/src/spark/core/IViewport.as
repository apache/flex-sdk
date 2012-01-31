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
     * The positive extent of the content, relative to the 0,0
     * origin, along the X axis.
     */
    function get contentWidth():Number;
    
    /**
     * The positive extent of the content, relative to the 0,0 
     * origin, along the Y axis.
     */
    function get contentHeight():Number;

     /**
     *  The X coordinate of the origin of the region the target is
     *  scrolled to.  
     * 
     *  Setting this property causes the target's 
     *  <code>scrollRect</code> to be set, if necessary, to:
     *  <pre>
     *  new Rectangle(horizontalScrollPosition, verticalScrollPosition, width, height)
     *  </pre>
     *  Where <code>width</code> and <code>height</code> are properties
     *  of the target.
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
     *  Setting this property causes the <code>scrollRect</code> to
     *  be set, if necessary, to:
     *  <pre>
     *  new Rectangle(horizontalScrollPosition, verticalScrollPosition, width, height)
     *  </pre>                 
     *  Where <code>width</code> and <code>height</code> are properties
     *  of the target.
     * 
     *  @default 0
     *  @see horizontalScrollPosition
     */
    function get verticalScrollPosition():Number;
    function set verticalScrollPosition(value:Number):void;
    
    /**
     *  Returns the amount one would have to add to the viewport's current 
     *  verticalScrollPosition to scroll by the requested "scrolling" unit.
     * 
     *  The value of unit must be one of the following flash.ui.Keyboard
     *  constants: UP, DOWN, PAGE_UP, PAGE_DOWN, HOME, END.
     * 
     *  To scroll by a single row use UP or DOWN and to scroll to the
     *  first or last row, use HOME or END.
     */
    function horizontalScrollPositionDelta(unit:uint):Number
    
    /**
     *  Returns the amount one would have to add to the viewport's current 
     *  verticalScrollPosition to scroll by the requested "scrolling" unit.
     * 
     *  The value of unit must be one of the following flash.ui.Keyboard
     *  constants: UP, DOWN, PAGE_UP, PAGE_DOWN, HOME, END.
     * 
     *  To scroll by a single row use UP or DOWN and to scroll to the
     *  first or last row, use HOME or END.
     */
    function verticalScrollPositionDelta(unit:uint):Number
     
    /**
     *  When scrolling is enabled, clip the target's contents by 
     *  setting its scrollRect.  If this property is set to false,
     *  then the target's scrollRect will be null, even if its
     *  scrollPosition is non-zero or its content size is larger
     *  than its actual size.
     * 
     *  @default true
     *  @see target
     *  @see updateScrollRect
     *  @see verticalScrollPosition
     *  @see horizontalScrollPosition
     */
    function get clipContent():Boolean;
    function set clipContent(value:Boolean):void;    
}

}
