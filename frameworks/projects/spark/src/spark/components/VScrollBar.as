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

package mx.components
{
import mx.components.baseClasses.FxScrollBar;
import mx.core.IViewport;
import mx.core.ScrollUnit;  
import mx.events.PropertyChangeEvent;
import mx.events.ResizeEvent;
import mx.core.ILayoutElement;
import mx.layout.LayoutElementFactory;

[IconFile("FxVScrollBar.png")]

/**
 *  The FxVScrollBar (vertical ScrollBar) control lets you control
 *  the portion of data that is displayed when there is too much data
 *  to fit vertically in a display area.
 * 
 *  <p>Although you can use the FxVScrollBar control as a stand-alone control,
 *  you usually combine it as part of another group of components to
 *  provide scrolling functionality.</p>
 */
public class FxVScrollBar extends FxScrollBar
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */    
    public function FxVScrollBar()
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
            // when FxRange constrains value
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
     */
    override protected function positionThumb(thumbPos:Number):void
    {
        if (thumb)
        {
            var trackPos:Number = track ? track.y : 0;
            var layoutElement:ILayoutElement = LayoutElementFactory.getLayoutElementFor(thumb);
            layoutElement.setLayoutBoundsPosition(layoutElement.getLayoutBoundsX(),
                                            Math.round(trackPos + thumbPos));
        }
    }

    /**
     *  @private
     */
    override protected function calculateThumbSize():Number
    {
        return Math.max(thumb.minHeight, super.calculateThumbSize());
    }

    /**
     *  @private
     */
    override protected function sizeThumb(thumbSize:Number):void
    {
        thumb.height = thumbSize;
        thumb.visible = thumbSize < trackSize;        
    }
    
    /**
     *  Returns the position of the thumb button on an FxVScrollBar control, 
     *  which is equal to the <code>localY</code> parameter.
     * 
     *  @param localX The X position relative to the scrollbar control.
     *
     *  @param localY The Y position relative to the scrollbar control.
     *
     *  @return The position of the thumb button.
     */
    override protected function pointToPosition(localX:Number, 
                                                localY:Number):Number
    {
        return localY;
    }
    
    
    /**
     *  Implicitly update the viewport's verticalScrollPosition per the
     *  specified scrolling unit, by setting the scrollbar's value.
     *
     *  @private
     */
    private function updateViewportVSP(unit:ScrollUnit):void
    {
        var delta:Number = viewport.getVerticalScrollPositionDelta(unit);
        setValue(viewport.verticalScrollPosition + delta);
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
     *  @see mx.components.baseClasses.FxTrackBase#page()
     *  @see mx.components.baseClasses.FxTrackBase#setValue()
     *  @see mx.core.IViewport
     *  @see mx.core.IViewport#verticalScrollPosition
     *  @see mx.core.IViewport#getVerticalScrollPositionDelta()     
    */
    override public function page(increase:Boolean = true):void
    {
        if (!viewport)
            super.page(increase);
        else
            updateViewportVSP((increase) ? ScrollUnit.PAGE_DOWN : ScrollUnit.PAGE_UP);
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
     *  @see mx.components.baseClasses.FxTrackBase#step()
     *  @see mx.components.baseClasses.FxTrackBase#setValue()
     *  @see mx.core.IViewport
     *  @see mx.core.IViewport#verticalScrollPosition
     *  @see mx.core.IViewport#getVerticalScrollPositionDelta()
     */
    override public function step(increase:Boolean = true):void
    {
        if (!viewport)
            super.step(increase);
        else
            updateViewportVSP((increase) ? ScrollUnit.DOWN : ScrollUnit.UP);
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
     */
    override protected function viewportVerticalScrollPositionChangeHandler(event:PropertyChangeEvent):void
    {
        if (viewport)
            value = viewport.verticalScrollPosition;
    }
    
    /**
     *  Set this scrollbar's maximum to the viewport's contentHeight 
     *  less the viewport height and its pageSize to the viewport's height. 
     */
    override protected function viewportResizeHandler(event:ResizeEvent):void
    {
        if (viewport)
        {
            var vsp:Number = viewport.verticalScrollPosition;
            // Special case: if contentHeight is 0, assume that it hasn't been 
            // updated yet.  Making the maximum==vsp here avoids trouble later
            // when FxRange constrains value
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
     */
    override protected function viewportContentHeightChangeHandler(event:PropertyChangeEvent):void
    {
        if (viewport)
            maximum = viewport.contentHeight - viewport.height;
    }
    
}

}
