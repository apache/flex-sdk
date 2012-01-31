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

package flex.component
{

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;

/**
 *  A ScrollBar control is used to help position
 *  the portion of data that is displayed when there is too much data
 *  to fit in a display area.
 *  
 *  <p>This control extends the Range class and
 *  is the base class for the HScrollBar and VScrollBar
 *  controls.</p> 
 * 
 *  <p>A ScrollBar consists of a track, a variable-size scroll thumb, and 
 *  two optional arrow buttons. The ScrollBar control uses four parameters 
 *  to calculate its display state:</p>
 *
 *  <ul>
 *    <li><code>minimum</code>: Minimum range value.</li>
 *    <li><code>maximum</code>:Maximum range value.</li>
 *    <li><code>value</code>: Current position, which must be within the
 *    minimum and maximum range values.</li>
 *    <li>Viewport size: represents the number of items
 *    in the range that you can display at one time. The
 *    number of items must be less than or equal to the 
 *    range, where the range is the set of values between
 *    the minimum range value and the maximum range value.</li>
 *  </ul>
 */
public class ScrollBar extends Range
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    // TODO (chaase): These constants should go away and be replaced by a more
    // flexible mechanism of setting the repeat parameters
    private const REPEAT_DELAY:Number = 500;
    private const REPEAT_INTERVAL:Number = 35;

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */
    public function ScrollBar():void
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    // Skins
    //
    //--------------------------------------------------------------------------

    [SkinPart(required="false")]
    
    /**
     * <code>upButton</code> is an optional SkinPart that defines a button that, when 
     * pressed, will step the scrollbar "up", which is equivalent to a decreasing step
     * in the <code>value</code> property.
     */
    public var upButton:Button;
    
    [SkinPart(required="false")]
    
    /**
     * <code>downButton</code> is an optional SkinPart that defines a button that, when 
     * pressed, will step the scrollbar "down", which is equivalent to a increasing step
     * in the <code>value</code> property.
     */
    public var downButton:Button;
    
    [SkinPart]
    
    /**
     * <code>thumb</code> is a SkinPart that defines a button that can be dragged on the track
     * to increase or decrease the scrollbar's <code>value</code> property. Updates
     * to the <code>value</code> through other means will automatically
     * update the position of the thumb with respect to the track.
     */
    public var thumb:Button; 
    
    [SkinPart]
    
    /**
     * <code>track</code> is a SkinPart that defines a button that, when 
     * pressed, will page the scrollbar.
     */
    public var track:Button; 
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    // TODO: transient?
    // Holds previous thumb location during thumb drags
    private var prevValue:Number;

    // TODO: transient?    
    // Direction indicator for current track-scrolling operations
    private var trackScrollDown:Boolean;
    
    // Timer used for repeated scrolling when mouse is held down on track
    private var trackScrollTimer:Timer;
    
    // TODO: transient?    
    // Cache current position on track for scrolling operations
    private var trackPosition:Point = new Point();
    
    // TODO: transient?    
    // Flag to indicate whether track-scrolling is in process
    private var trackScrolling:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    /**
     * Enable/disable this component. This also enables/disables any of the skin parts
     * for this component.
     */
    override public function set enabled(value:Boolean):void
    {
        super.enabled = value;
        enableSkinParts(value);
    }
    
    override public function set maximum(value:Number):void
    {
        super.maximum = value;
        invalidateDisplayList();
    }

    override public function set minimum(value:Number):void
    {
        super.minimum = value;
        invalidateDisplayList();
    }
    
    /**
     * Handle changes to the value property, which affects the position of
     * the thumb on the track.
     */ 
    override public function set value(newValue:Number):void
    {
        super.value = newValue;
        invalidateDisplayList();
    }



    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------
    
    // Implement thumbSize property as an overridable setter/getter so that
    // subclasses can modify the size as necessary.
    private var _thumbSize:Number;
    
    /**
     * Subclasses may choose to override this method to constrain the size
     * within certain limits. For example, a vertically oriented scrollbar
     * may choose to constrain the size to be at least as high as the 
     * <code>minHeight</code> of the skin button.
     */
    protected function get thumbSize():Number
    {
        return _thumbSize;
    }
    
    protected function set thumbSize(size:Number):void
    {
        _thumbSize = size;
    }
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------
        
    /**
     * Add behaviors associated with our skin. For example, we add listeners
     * for various events to the skin parts here.
     */
    override protected function attachBehaviors():void
    {
        super.attachBehaviors();
        
        if (upButton)
        {
            upButton.addEventListener("buttonDown", upButton_buttonDownHandler);
            upButton.autoRepeat = true;
        }
        if (downButton)
        {
            downButton.addEventListener("buttonDown", downButton_buttonDownHandler);
            downButton.autoRepeat = true;
        }
        
        thumb.stickyHighlighting = true;
        thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDownHandler);
        track.addEventListener(MouseEvent.MOUSE_DOWN, track_mouseDownHandler);
        track.addEventListener(MouseEvent.ROLL_OVER, track_rollOverHandler);
        track.addEventListener(MouseEvent.ROLL_OUT, track_rollOutHandler);
        
        skinObject.addEventListener("updateComplete", skin_updateCompleteHandler);
        
        enableSkinParts(enabled);
        calculateThumbSize();
        calculateThumbPosition(); 
    }
    
    /**
     * Make the skins reflect the enabled state of the scrollbar
     */
    protected function enableSkinParts(value:Boolean):void
    {
        if (thumb)
            thumb.enabled = value;
        if (upButton)
            upButton.enabled = value;
        if (downButton)
            downButton.enabled = value;
        if (track)
            track.enabled = value;
    }
    
    /**
     * Remove the behaviors associated with our skin. For example, listeners
     * for events on skin parts should be removed here.
     */
    override protected function removeBehaviors():void
    {
        if (upButton)
            upButton.removeEventListener("buttonDown", 
                                         upButton_buttonDownHandler);
        if (downButton)
            downButton.removeEventListener("buttonDown", 
                                           downButton_buttonDownHandler);

        thumb.removeEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDownHandler);
        track.removeEventListener(MouseEvent.MOUSE_DOWN, track_mouseDownHandler);
        track.removeEventListener(MouseEvent.ROLL_OVER, track_rollOverHandler);
        track.removeEventListener(MouseEvent.ROLL_OUT, track_rollOutHandler);
        
        skinObject.removeEventListener("updateComplete", skin_updateCompleteHandler);
    }
    
    /**
     * Utility function to handle positioning the thumb on the scrollbar,
     * given the current range value.
     */
    protected function calculateThumbPosition():void
    {
        // To calculate the thumb position, we first calculate the 
        // thumb size, based on the range, page size, and track size.
        // The thumb position on the track is based on the current
        // scrolling fraction and the thumb and track size.
        var range:Number = Math.max(1, maximum - minimum);        
        var thumbPos:Number = 
            (trackSize - thumbSize) * (value - minimum) / range;
            
        // Defer to subclasses to actually position the thumb; this is
        // completely dependent upon scrollbar orientation and shape
        positionThumb(thumbPos);
    }
    
    /**
     * This method positions and sizes the thumb button correctly, given
     * the position and sizing arguments. Subclasses should override this
     * method to position the thumb appropriately for their situation.
     */
    protected function positionThumb(thumbPos:Number):void {}

    /**
     * Utility method which returns the range value for a given
     * position on the track.
     */
    protected function valueFromPosition(position:Number):Number
    {
        var range:Number = maximum - minimum;
        var visibleTrack:Number = Math.max(1, trackSize - thumbSize);
        var val:Number = minimum + range * (position / visibleTrack);
        return val;
    }
    
    /**
     * This method returns the size of the scrollbar's track. Subclasses need
     * to override this method to return an appropriate value. Note that this
     * number can represent any units, but those units must be consistent with
     * the units for the thumbSize property and the values returned by
     * getScrollPosition.
     */
    protected function get trackSize():Number
    {
        return 0;
    }
    
    /**
     * This utility method calculates an appropriate size for the thumb
     * button, given the current range, pageSize, and trackSize settings.
     */
    protected function calculateThumbSize():void
    {
        var range:Number = Math.max(1, (maximum - minimum));
        thumbSize = Math.round(Math.min(1, pageSize / range) * trackSize);
    }

    /**
     * Calculate thumb position and size on track according to data which
     * has changed since the last updateDisplayList() call
     */
    override protected function updateDisplayList(unscaledWidth:Number, 
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        calculateThumbSize();
        calculateThumbPosition();
    }
    
    //--------------------------------------------------------------------------
    // 
    // Event Handlers
    //
    //--------------------------------------------------------------------------
    
    //---------------------------------
    // Mouse up/down handlers
    //---------------------------------
     
    /**
     * Handle a click on the up button of the scroll bar. This should
     * up one step.
     */
    protected function upButton_buttonDownHandler(event:Event):void
    {
        step(false); // up
    }
    
    /**
     * Handle a click on the down button of the scroll bar. This should
     * down one step.
     */
    protected function downButton_buttonDownHandler(event:Event):void
    {
        step(true); // down
    }

    //---------------------------------
    // Thumb dragging handlers
    //---------------------------------
    
    /**
    * Handle mouse-down events on the scroll thumb.
    */
    protected function thumb_mouseDownHandler(event:MouseEvent):void
    {
        // TODO (chaase): We might want a different event mechanism eventually
        // which would push this enabled check into the child/skin components
        if (!enabled)
            return;
            
        addSystemHandlers(MouseEvent.MOUSE_MOVE, system_mouseMoveHandler, 
                stage_mouseMoveHandler);
        addSystemHandlers(MouseEvent.MOUSE_UP, system_mouseUpHandler, 
                stage_mouseUpHandler);
                            
        // Record the location where this mouse-down event occurred; we will
        // use this in later drag operations to determine how much to move the
        // thumb button
        var pt:Point = new Point(event.stageX, event.stageY);
        pt = globalToLocal(pt);
        var position:Number = getScrollPosition(pt.x, pt.y);
        prevValue = valueFromPosition(position);
    }

    /**
    * @private
    * Capture mouse-move events on the thumb anywhere on the stage
    */
    private function stage_mouseMoveHandler(event:MouseEvent):void
    {
        if (event.target != stage)
            return;

        system_mouseMoveHandler(event);
    }
    
    /**
    * @private
    * Capture mouse-move events anywhere on or off the stage.
    * We calculate the delta between the current location and the past
    * location during this drag and move the thumb by that amount.
    */
    private function system_mouseMoveHandler(event:MouseEvent):void
    {
        var pt:Point = new Point(event.stageX, event.stageY);
        pt = globalToLocal(pt);
        var tempPosition:Number = getScrollPosition(pt.x, pt.y);
        var newValue:Number = valueFromPosition(tempPosition);
        var delta:Number = newValue - prevValue;
        var tempValue:Number = value + delta;
        // Clamp the move to lie within the range
        // and set the scroll fraction accordingly
        if (tempValue < minimum)
        {
            newValue += (minimum - tempValue);
            tempValue = minimum;
        } 
        else if (tempValue > maximum)
        {
            newValue -= (tempValue - maximum);
            tempValue = maximum;
        }
        value = tempValue;
        prevValue = newValue;
        
        // Force the visual update now to make scrolling smooth
        event.updateAfterEvent();
    }
    
    /**
    * @private
    * Handle mouse-up events anywhere on the stage
    */
    private function stage_mouseUpHandler(event:MouseEvent):void
    {
        if (event.target != stage)
            return;

        system_mouseUpHandler(event);
    }

    /**
    * @private
    * Handle mouse-up events anywhere on or off the stage. When we receive
    * a mouse-up event for the thumb button, we remove our event handlers
    * for everything except mouse-down.
    */
    private function system_mouseUpHandler(event:MouseEvent):void
    {   
        removeSystemHandlers(MouseEvent.MOUSE_MOVE, system_mouseMoveHandler, 
                stage_mouseMoveHandler);
        removeSystemHandlers(MouseEvent.MOUSE_UP, system_mouseUpHandler, 
                stage_mouseUpHandler);
    }
    
    
    //---------------------------------
    // Track dragging handlers
    //---------------------------------
    
    /**
     * Handle mouse-down events for the scroll track.  In our handler,
     * we figure out where the event occurred on the track and begin
     * paging the scroll position toward that location. We start a 
     * timer to handle repeating events if the user keeps the button
     * pressed on the track.
     */
    protected function track_mouseDownHandler(event:MouseEvent):void
    {
        // TODO (chaase): We might want a different event mechanism eventually
        // which would push this enabled check into the child/skin components
        if (!enabled)
            return;
                    
        var pt:Point = new Point(event.stageX, event.stageY);
        // Cache original event location for use on later repeating events
        trackPosition = track.globalToLocal(pt);
        var newScrollPosition:Number = getScrollPosition(trackPosition.x, trackPosition.y);
        var newScrollValue:Number = valueFromPosition(newScrollPosition);
        
        trackScrollDown = (newScrollValue > value);
        page(trackScrollDown);

        trackScrolling = true;

        // Add event handlers for drag and up events
        addSystemHandlers(MouseEvent.MOUSE_MOVE, track_mouseMoveHandler, 
            stage_track_mouseMoveHandler);
        systemManager.addEventListener(
            MouseEvent.MOUSE_UP, track_mouseLeaveHandler, true);
        systemManager.stage.addEventListener(Event.MOUSE_LEAVE, 
                            track_mouseLeaveHandler);
                            
        // TODO (chaase): consider using the repeat behavior of Button
        // to handle track-down repetition, instead of doing it with a
        // custom Timer. As long as we can distinguish the first
        // down event from subsequent ones, we may be able to just let
        // Button do most of this work.
        // Start a timer to handle repeating events if the user
        // continues to hold the mouse button down
        if (!trackScrollTimer)
        {
            trackScrollTimer = new Timer(REPEAT_DELAY, 1);
            trackScrollTimer.addEventListener(TimerEvent.TIMER, 
                                              trackScrollTimerHandler);
        } 
        else
        {
            // Note that this behavior, resetting the initial delay, differs 
            // from Flex3 but is more consistent with general application
            // scrollbar behavior
            trackScrollTimer.delay = REPEAT_DELAY;
            trackScrollTimer.repeatCount = 1;
        }
        trackScrollTimer.start();
    }

    /**
     *  @private
     *  This gets called at certain intervals to repeat the scroll 
     *  event when the user is still holding the mouse button 
     *  down on the track.
     */
    private function trackScrollTimerHandler(event:Event):void
    {
        // Only repeat the scrolling if the current scroll position
        // (represented by fraction) is not past the current
        // mouse position on the track 
        var newScrollPosition:Number = getScrollPosition(
            trackPosition.x, trackPosition.y);
        var newScrollValue:Number = valueFromPosition(newScrollPosition);
        
        if (trackScrollDown)
        {
            var range:Number = Math.max(1, maximum - minimum);
            if (newScrollValue <= (value + (thumbSize / trackSize) * range))
                return;
        }
        else if (newScrollValue > value)
        {
            return;
        }
        
        page(trackScrollDown);

        if (trackScrollTimer && trackScrollTimer.repeatCount == 1)
        {
            // If this was the first time repeating, set the Timer to
            // repeat indefinitely with an appropriate interval delay
            trackScrollTimer.delay = REPEAT_INTERVAL;
            trackScrollTimer.repeatCount = 0;
        }
    }

    /**
     * Handle mouse-move events for track scrolling anywhere on the stage
     */
    private function stage_track_mouseMoveHandler(event:MouseEvent):void
    {
        if (event.target != stage)
            return;

        track_mouseMoveHandler(event);
    }

    /**
     *  @private
     *  Record a new trackPosition, which is the location of the
     *  mouse on the track, relative to the stage. This is used 
     *  in the ongoing Timer events for track scrolling.  Note
     *  that the timer will be stopped when the mouse is not over
     *  the track, so although we are setting new trackPosition
     *  values, we are not actually stepping the scroll if the mouse
     *  is outside of the track area.
     */
    private function track_mouseMoveHandler(event:MouseEvent):void
    {
        if (trackScrolling)
        {
            var pt:Point = new Point(event.stageX, event.stageY);
            // Cache original event location for use on later repeating events
            trackPosition = track.globalToLocal(pt);
        }
    }

    /**
     * @private
     * Stop scrolling the track if the mouse leaves the stage
     * area. Remove the listeners and stop the Timer.
     */
    private function track_mouseLeaveHandler(event:Event):void
    {
        trackScrolling = false;
        removeSystemHandlers(MouseEvent.MOUSE_MOVE, track_mouseMoveHandler,
                stage_track_mouseMoveHandler);
        systemManager.removeEventListener(
            MouseEvent.MOUSE_UP, track_mouseLeaveHandler, true);
        systemManager.stage.removeEventListener(Event.MOUSE_LEAVE, 
                            track_mouseLeaveHandler);

        if (trackScrollTimer)
            trackScrollTimer.reset();
    }

    /**
     * @private
     * If we are still in the middle of track-scrolling, restart the
     * timer when the mouse re-enters the track area.
     */
    private function track_rollOverHandler(event:MouseEvent):void
    {
        if (trackScrolling)
            trackScrollTimer.start();
    }
    
    /**
     * @private
     * Stop the track-scrolling repeat events if the mouse leaves
     * the track area.
     */
    private function track_rollOutHandler(event:MouseEvent):void
    {
        if (trackScrolling)
            trackScrollTimer.stop();
    }

    /**
     * @private
     * Force the scrollbar to set itself up correctly now that the
     * skins have completed loading.
     */
    private function skin_updateCompleteHandler(event:Event):void
    {   
        invalidateDisplayList();
    }
    
    /**
     * This function returns a position on the scrollbar relative to its
     * orientation and shape. The <code>localX</code> and <code>localY</code>
     * values represent the location in the local coordinate system of the
     * scrollbar. Subclasses must override this method and return the
     * appropriate value for their situation. Values should not be clamped to
     * the ends of the scrollbar, as that clamping will happen later, prior
     * to setting the thumb position.
     */
    protected function getScrollPosition(localX:Number, localY:Number):Number
    {
        return 0;
    }
}

}
