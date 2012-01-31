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
import mx.events.PropertyChangeEvent;
import mx.events.ResizeEvent;

import spark.components.supportClasses.ScrollBar;
import spark.core.IViewport;
import spark.core.NavigationUnit;

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("VScrollBar.png")]
[DefaultTriggerEvent("change")]

/**
 *  The VScrollBar (vertical ScrollBar) control lets you control
 *  the portion of data that is displayed when there is too much data
 *  to fit vertically in a display area.
 * 
 *  <p>Although you can use the VScrollBar control as a stand-alone control,
 *  you usually combine it as part of another group of components to
 *  provide scrolling functionality.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class VScrollBar extends ScrollBar
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
    public function VScrollBar()
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
            var vsp:Number = newViewport.verticalScrollPosition;
            // Special case: if contentHeight is 0, assume that it hasn't been 
            // updated yet.  Making the maximum==vsp here avoids trouble later
            // when Range constrains value
            var cHeight:Number = newViewport.contentHeight;
            maximum = (cHeight == 0) ? vsp : cHeight - newViewport.height;
            pageSize = newViewport.height;
            value = vsp;
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
        var r:Number = track.getLayoutBoundsHeight() - thumb.getLayoutBoundsHeight();
        return minimum + ((r != 0) ? (y / r) * (maximum - minimum) : 0); 
    }

    /**
     *  @private
     */
    override protected function updateSkinDisplayList():void
    {
        if (!thumb || !track)
            return;

        var trackPos:Number = track.getLayoutBoundsY();
        var trackSize:Number = track.getLayoutBoundsHeight();
        var range:Number = maximum - minimum;

        var thumbPos:Number = 0;
        var thumbSize:Number = trackSize;
        if (range > 0)
        {
            thumbSize = Math.min((pageSize / (range + pageSize)) * trackSize, trackSize)
            thumbSize = Math.max(thumb.minHeight, thumbSize);
            thumbPos = (value - minimum) * ((trackSize - thumbSize) / range);
        }

        if (getStyle("fixedThumbSize") === false)
            thumb.setLayoutBoundsSize(NaN, thumbSize);
        if (getStyle("autoThumbVisibility") === true)
            thumb.visible = thumbSize < trackSize;
        thumb.setLayoutBoundsPosition(thumb.getLayoutBoundsX(), Math.round(trackPos + thumbPos));
    }
    
    
    /**
     *  Update the value property and, if viewport is non null, then set 
     *  its verticalScrollPosition to <code>value</code>.
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
            viewport.verticalScrollPosition = value;
    }
        
    /**
     *  If <code>viewport</code> is not null, 
     *  change the vertical scroll position for page up or page down by 
     *  scrolling the viewport.
     *  This method calculates the amount to scroll by calling the 
     *  <code>IViewport.getVerticalScrollPositionDelta()</code> method 
     *  with either <code>flash.ui.Keyboard.PAGE_UP</code> 
     *  or <code>flash.ui.Keyboard.PAGE_DOWN</code>.
     *  It then calls the <code>setValue()</code> method to 
     *  set the <code>IViewport.verticalScrollPosition</code> property 
     *  to the appropriate value.
     *
     *  <p>If <code>viewport</code> is null, 
     *  change the vertical scroll position for page up or page down by calling 
     *  the <code>changeValueByPage()</code> method.</p>
     *
     *  @param increase Whether the page scroll is up (<code>true</code>) or
     *  down (<code>false</code>). 
     * 
     *  @see mx.components.baseClasses.TrackBase#changeValueByPage()
     *  @see mx.components.baseClasses.TrackBase#setValue()
     *  @see spark.core.IViewport
     *  @see spark.core.IViewport#verticalScrollPosition
     *  @see spark.core.IViewport#getVerticalScrollPositionDelta()     
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
            pageSize = Math.abs(viewport.getVerticalScrollPositionDelta(
                (increase) ? NavigationUnit.PAGE_DOWN : NavigationUnit.PAGE_UP));
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
            var vpPageSize:Number = Math.abs(viewport.getVerticalScrollPositionDelta(
                (newValue > value) ? NavigationUnit.PAGE_DOWN : NavigationUnit.PAGE_UP));
            super.animatePaging(newValue, vpPageSize);
            return;
        }        
        super.animatePaging(newValue, pageSize);
    }
    
    /**
     *  If <code>viewport</code> is not null, 
     *  change the vertical scroll position for line up or line down by 
     *  scrolling the viewport.
     *  This method calculates the amount to scroll by calling the 
     *  <code>IViewport.getVerticalScrollPositionDelta()</code> method 
     *  with either <code>flash.ui.Keyboard.RIGHT</code> 
     *  or <code>flash.ui.Keyboard.LEFT</code>.
     *  It then calls the <code>setValue()</code> method to 
     *  set the <code>IViewport.verticalScrollPosition</code> property 
     *  to the appropriate value.
     *
     *  <p>If <code>viewport</code> is null, 
     *  change the vertical scroll position for line up or line down by calling 
     *  the <code>changeValueByStep()</code> method.</p>
     *
     *  @param increase Whether the line scoll is up (<code>true</code>) or
     *  down (<code>false</code>). 
     * 
     *  @see mx.components.baseClasses.TrackBase#changeValueByStep()
     *  @see mx.components.baseClasses.TrackBase#setValue()
     *  @see spark.core.IViewport
     *  @see spark.core.IViewport#verticalScrollPosition
     *  @see spark.core.IViewport#getVerticalScrollPositionDelta()
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
            stepSize = Math.abs(viewport.getVerticalScrollPositionDelta(
                (increase) ? NavigationUnit.DOWN : NavigationUnit.UP));
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
            thumb.setConstraintValue("top", undefined);
            thumb.setConstraintValue("bottom", undefined);
            thumb.setConstraintValue("verticalCenter", undefined);
        }      
        
        super.partAdded(partName, instance);
    }     

    /**
     *  Set this scrollbar's value to the viewport's current 
     *  verticalScrollPosition.
     * 
     *  @see IViewport#verticalScrollPosition
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function viewportVerticalScrollPositionChangeHandler(event:PropertyChangeEvent):void
    {
        if (viewport)
            value = viewport.verticalScrollPosition;
    }
    
    /**
     *  Set this scrollbar's maximum to the viewport's contentHeight 
     *  less the viewport height and its pageSize to the viewport's height. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function viewportResizeHandler(event:ResizeEvent):void
    {
        if (viewport)
        {
            var vsp:Number = viewport.verticalScrollPosition;
            // Special case: if contentHeight is 0, assume that it hasn't been 
            // updated yet.  Making the maximum==vsp here avoids trouble later
            // when Range constrains value
            var cHeight:Number = viewport.contentHeight;
            maximum = (cHeight == 0) ? vsp : cHeight - viewport.height;
            pageSize = viewport.height;
        } 
    }

    /**
     *  Set this scrollbar's maximum to the viewport's contentHeight 
     *  less the viewport height. 
     *
     *  @see IViewport#contentWidth
     *  @see IViewport#width 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function viewportContentHeightChangeHandler(event:PropertyChangeEvent):void
    {
        if (viewport)
            maximum = viewport.contentHeight - viewport.height;
    }
    
}

}
