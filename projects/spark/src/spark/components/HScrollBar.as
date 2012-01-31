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

package spark.components
{
import mx.core.mx_internal;
import mx.events.PropertyChangeEvent;
import mx.events.ResizeEvent;
    
import spark.components.supportClasses.ScrollBar;
import spark.core.NavigationUnit;
import spark.core.IViewport;

use namespace mx_internal;

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("HScrollBar.png")]
[DefaultTriggerEvent("change")]

/**
 *  The HScrollBar (horizontal ScrollBar) control lets you control
 *  the portion of data that is displayed when there is too much data
 *  to fit horizontally in a display area.
 * 
 *  <p>Although you can use the HScrollBar control as a stand-alone control,
 *  you usually combine it as part of another group of components to
 *  provide scrolling functionality.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class HScrollBar extends ScrollBar
{
    include "../core/Version.as";

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
    public function HScrollBar()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    override public function set viewport(newViewport:IViewport):void
    {
        super.viewport = newViewport;
        if (newViewport)
        {
            var hsp:Number = newViewport.horizontalScrollPosition;
            // Special case: if contentWidth is 0, assume that it hasn't been 
            // updated yet.  Making the maximum==hsp here avoids trouble later
            // when Range constrains value
            var cWidth:Number = newViewport.contentWidth;
            maximum = (cWidth == 0) ? hsp : cWidth - newViewport.width;
            pageSize = newViewport.width;
            value = hsp;
        }
    }      
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function pointToValue(x:Number, y:Number):Number
    {
        var r:Number = track.getLayoutBoundsWidth() - thumb.getLayoutBoundsWidth();
        return minimum + ((r != 0) ? (x / r) * (maximum - minimum) : 0); 
    }
    
    /**
     *  @private
     */
    override protected function updateSkinDisplayList():void
    {
        if (!thumb || !track)
            return;
        
        var trackPos:Number = track.getLayoutBoundsX();
        var trackSize:Number = track.getLayoutBoundsWidth();
        var range:Number = maximum - minimum;
        
        var thumbPos:Number = 0;
        var thumbSize:Number = trackSize;
        if (range > 0)
        {
            thumbSize = Math.min((pageSize / (range + pageSize)) * trackSize, trackSize)
            thumbSize = Math.max(thumb.minWidth, thumbSize);
            thumbPos = (value - minimum) * ((trackSize - thumbSize) / range);
        }
        
        if (getStyle("fixedThumbSize") === false)
            thumb.setLayoutBoundsSize(thumbSize, NaN);
        if (getStyle("autoThumbVisibility") === true)
            thumb.visible = thumbSize < trackSize;
        thumb.setLayoutBoundsPosition(Math.round(trackPos + thumbPos), thumb.getLayoutBoundsY());
    }
    
    /**
     *  Update the value property and, if viewport is non null, then set 
     *  its horizontalScrollPosition to <code>value</code>.
     * 
     *  @param value The new value of the <code>value</code> property. 
     *  @see viewport
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function setValue(value:Number):void
    {
        super.setValue(value);
        if (viewport)
            viewport.horizontalScrollPosition = value;
    }
    

    /**
     *  If <code>viewport</code> is not null, 
     *  change the horizontal scroll position for page up or page down by 
     *  scrolling the viewport.
     *  This method calculates the amount to scroll by calling the 
     *  <code>IViewport.getHorizontalScrollPositionDelta()</code> method 
     *  with either <code>flash.ui.Keyboard.PAGE_UP</code> 
     *  or <code>flash.ui.Keyboard.PAGE_DOWN</code>.
     *  It then calls the <code>setValue()</code> method to 
     *  set the <code>IViewport.horizontalScrollPosition</code> property 
     *  to the appropriate value.
     *
     *  <p>If <code>viewport</code> is null, 
     *  change the scroll position for page up or page down by calling 
     *  the <code>changeValueByPage()</code> method.</p>
     *
     *  @param increase Whether the page scroll is up (<code>true</code>) or
     *  down (<code>false</code>). 
     * 
     *  @see mx.components.baseClasses.TrackBase#changeValueByPage()
     *  @see mx.components.baseClasses.TrackBase#setValue()
     *  @see spark.core.IViewport
     *  @see spark.core.IViewport#horizontalScrollPosition
     *  @see spark.core.IViewport#getHorizontalScrollPositionDelta()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function changeValueByPage(increase:Boolean = true):void
    {
        var oldPageSize:Number;
        if (viewport)
        {
            // Want to use ScrollBar's changeValueByPage() implementation to get the same
            // animated behavior for scrollbars with and without viewports.
            // For now, just change pageSize temporarily and call the superclass
            // implementation.
            oldPageSize = pageSize;
            pageSize = Math.abs(viewport.getHorizontalScrollPositionDelta(
                (increase) ? NavigationUnit.PAGE_RIGHT : NavigationUnit.PAGE_LEFT));
        }
        super.changeValueByPage(increase);
        if (viewport)
            pageSize = oldPageSize;
    }

    /**
     * @private
     */
    override protected function animatePaging(newValue:Number, pageSize:Number):void
    {
        if (viewport)
        {
            var vpPageSize:Number = Math.abs(viewport.getHorizontalScrollPositionDelta(
                (newValue > value) ? NavigationUnit.PAGE_RIGHT : NavigationUnit.PAGE_LEFT));
            super.animatePaging(newValue, vpPageSize);
            return;
        }        
        super.animatePaging(newValue, pageSize);
    }
    
    /**
     *  If <code>viewport</code> is not null, 
     *  change the horizontal scroll position for line up or line down by 
     *  scrolling the viewport.
     *  This method calculates the amount to scroll by calling the 
     *  <code>IViewport.getHorizontalScrollPositionDelta()</code> method 
     *  with either <code>flash.ui.Keyboard.RIGHT</code> 
     *  or <code>flash.ui.Keyboard.LEFT</code>.
     *  It then calls the <code>setValue()</code> method to 
     *  set the <code>IViewport.horizontalScrollPosition</code> property 
     *  to the appropriate value.
     *
     *  <p>If <code>viewport</code> is null, 
     *  change the scroll position for line up or line down by calling 
     *  the <code>changeValueByStep()</code> method.</p>
     *
     *  @param increase Whether the line scoll is up (<code>true</code>) or
     *  down (<code>false</code>). 
     * 
     *  @see mx.components.baseClasses.TrackBase#changeValueByStep()
     *  @see mx.components.baseClasses.TrackBase#setValue()
     *  @see spark.core.IViewport
     *  @see spark.core.IViewport#horizontalScrollPosition
     *  @see spark.core.IViewport#getHorizontalScrollPositionDelta()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function changeValueByStep(increase:Boolean = true):void
    {
        var oldStepSize:Number;
        if (viewport)
        {
            // Want to use ScrollBar's changeValueByStep() implementation to get the same
            // animated behavior for scrollbars with and without viewports.
            // For now, just change pageSize temporarily and call the superclass
            // implementation.
            oldStepSize = stepSize;
            stepSize = Math.abs(viewport.getHorizontalScrollPositionDelta(
                (increase) ? NavigationUnit.RIGHT : NavigationUnit.LEFT));
        }
        super.changeValueByStep(increase);
        if (viewport)
            stepSize = oldStepSize;
    }   
    
    /**
     *  @private
     */    
    override protected function partAdded(partName:String, instance:Object):void
    {
        if (instance == thumb)
        {
            thumb.setConstraintValue("left", undefined);
            thumb.setConstraintValue("right", undefined);
            thumb.setConstraintValue("horizontalCenter", undefined);
        }      
        
        super.partAdded(partName, instance);
    }
    
    /**
     *  @private 
     *  Set this scrollbar's value to the viewport's current horizontalScrollPosition.
     */
    override mx_internal function viewportHorizontalScrollPositionChangeHandler(event:PropertyChangeEvent):void
    {
        if (viewport)
            value = viewport.horizontalScrollPosition;
    } 
    
    /**
     *  @private 
     *  Set this scrollbar's maximum to the viewport's contentWidth 
     *  less the viewport width and its pageSize to the viewport's width. 
     */
    override mx_internal function viewportResizeHandler(event:ResizeEvent):void
    {
        if (viewport)
        {
            var hsp:Number = viewport.horizontalScrollPosition;
            // Special case: if contentWidth is 0, assume that it hasn't been 
            // updated yet.  Making the maximum==hsp here avoids trouble later
            // when Range constrains value
            var cWidth:Number = viewport.contentWidth;
            maximum = (cWidth == 0) ? hsp : cWidth - viewport.width;
            pageSize = viewport.width;
        } 
    }
    
    /**
     *  @private 
     *  Set this scrollbar's maximum to the viewport's contentWidth 
     *  less the viewport width. 
     */
    override mx_internal function viewportContentWidthChangeHandler(event:PropertyChangeEvent):void
    {
        if (viewport)
            maximum = viewport.contentWidth - viewport.width;
    }

        
}

}
