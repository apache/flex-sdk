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
import mx.core.ILayoutElement;
import mx.events.PropertyChangeEvent;
import mx.events.ResizeEvent;

import spark.components.supportClasses.ScrollBar;
import spark.core.IViewport;
import spark.core.ScrollUnit;

[IconFile("VScrollBar.png")]

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

    /**
     *  The size of the track, which equals the height of the track.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function get trackSize():Number
    {
        if (track)
            return track.height;
        else
            return 0;
    }
    
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
     *  Position the thumb button according to the given thumbPos parameter,
     *  relative to the current y location of the track in the scrollbar control.
     * 
     *  @param thumbPos A number representing the new position of the thumb
     *  button in the control.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function positionThumb(thumbPos:Number):void
    {
        if (!thumb)
            return;
            
        var trackPos:Number = track ? track.y : 0;
        thumb.setLayoutBoundsPosition(thumb.getLayoutBoundsX(), Math.round(trackPos + thumbPos));
    }

    /**
     *  @private
     */
    override protected function calculateThumbSize():Number
    {
        if (!thumb)
            return super.calculateThumbSize();
            
        var size:Number = (fixedThumbSize) ? thumb.getPreferredBoundsHeight() : super.calculateThumbSize();
        return Math.max(thumb.minHeight, size);
    }

    /**
     *  @private
     *  Note: we're comparing the "calculated", not fixed, size of the thumb with the trackSize
     *  to decide if the thumb should be visible.  We want to know if the thumb needs to be visible,
     *  and the comparison would fail if we always compared the track size and the fixed thumb size.
     *  See calculateThumbSize().
     */
    override protected function sizeThumb(thumbSize:Number):void
    {
        if (!thumb)
            return;

        thumb.setLayoutBoundsSize(NaN, thumbSize);
        var calculatedThumbSize:Number = (fixedThumbSize) ? super.calculateThumbSize() : thumbSize;        
        thumb.visible = calculatedThumbSize < trackSize;
    }
    
    /**
     *  Returns the position of the thumb button on an VScrollBar control, 
     *  which is equal to the <code>localY</code> parameter.
     * 
     *  @param localX The X position relative to the scrollbar control.
     *
     *  @param localY The Y position relative to the scrollbar control.
     *
     *  @return The position of the thumb button.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function pointToPosition(localX:Number, 
                                                localY:Number):Number
    {
        return localY;
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
     *  the <code>page()</code> method.</p>
     *
     *  @param increase Whether the page scroll is up (<code>true</code>) or
     *  down (<code>false</code>). 
     * 
     *  @see mx.components.baseClasses.TrackBase#page()
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
     override public function page(increase:Boolean = true):void
    {
        var oldPageSize:Number;
        if (viewport)
        {
            // Want to use ScrollBar's page() implementation to get the same
            // animated behavior for scrollbars with and without viewports.
            // For now, just change pageSize temporarily and call the superclass
            // implementation.
            oldPageSize = pageSize;
            pageSize = Math.abs(viewport.getVerticalScrollPositionDelta(
                (increase) ? ScrollUnit.PAGE_DOWN : ScrollUnit.PAGE_UP));
        }
        super.page(increase);
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
                (newValue > value) ? ScrollUnit.PAGE_DOWN : ScrollUnit.PAGE_UP));
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
     *  the <code>step()</code> method.</p>
     *
     *  @param increase Whether the line scoll is up (<code>true</code>) or
     *  down (<code>false</code>). 
     * 
     *  @see mx.components.baseClasses.TrackBase#step()
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
     override public function step(increase:Boolean = true):void
    {
        var oldStepSize:Number;
        if (viewport)
        {
            // Want to use ScrollBar's step() implementation to get the same
            // animated behavior for scrollbars with and without viewports.
            // For now, just change pageSize temporarily and call the superclass
            // implementation.
            oldStepSize = stepSize;
            stepSize = Math.abs(viewport.getVerticalScrollPositionDelta(
                (increase) ? ScrollUnit.DOWN : ScrollUnit.UP));
        }
        super.step(increase);
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
