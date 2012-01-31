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

package mx.components.baseClasses
{

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;
import mx.components.FxButton;
import mx.core.IViewport;

/**
 *  A ScrollBar control is used to help position
 *  the portion of data that is displayed when there is too much data
 *  to fit in a display area.
 *  
 *  <p>This control extends the Range class and
 *  is the base class for the FxHScrollBar and FxVScrollBar
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
public class FxScrollBar extends FxTrackBase
{
    include "../../core/Version.as";

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
    public function FxScrollBar():void
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
     *  <code>decrementButton</code> is an optional SkinPart that defines a button 
     *  that, when pressed, will step the scrollbar "up", which is equivalent 
     *  to a decreasing step in the <code>value</code> property.
     */
    public var decrementButton:FxButton;
    
    [SkinPart(required="false")]
    
    /**
     *  <code>incrementButton</code> is an optional SkinPart that defines a button 
     *  that, when pressed, will step the scrollbar "down", which is equivalent
     *  to a increasing step in the <code>value</code> property.
     */
    public var incrementButton:FxButton;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

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
    //  Overridden properties: Range
    //
    //--------------------------------------------------------------------------
    
    override public function set valueInterval(value:Number):void
    {
        super.valueInterval = value;
        
        // setting valueInterval may change the pageSize
        pageSizeChanged = true;
    }

    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------
    
    //---------------------------------
    // pageSize
    //--------------------------------- 

    private var _pageSize:Number = 20;

    private var pageSizeChanged:Boolean = false;

    /**
     *  Amount of change in <code>value</code> when
     *  the range is paged. Affects the thumb size.
     *
     *  @default 20
     */
    public function get pageSize():Number
    {
        return _pageSize;
    }

    public function set pageSize(value:Number):void
    {
        if (value == _pageSize)
            return;
            
        _pageSize = value;
        pageSizeChanged = true;
        
        invalidateProperties();
        invalidateDisplayList();
    }
    
    //----------------------------------
    //  viewport
    //----------------------------------    

    private var _viewport:IViewport;
    
    public function get viewport():IViewport
    {
        return _viewport;
    }
    
    public function set viewport(value:IViewport):void
    {
        _viewport = value;
    }    
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (pageSizeChanged)
        {
            if (valueInterval != 0)
                _pageSize = nearestValidInterval(_pageSize, valueInterval);
            
            pageSizeChanged = false;
        }
    }
    
    /**
     *  @private
     */    
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == decrementButton)
        {
            decrementButton.addEventListener("buttonDown",
                                            decrementButton_buttonDownHandler);
            decrementButton.autoRepeat = true;
        }
        else if (instance == incrementButton)
        {
            incrementButton.addEventListener("buttonDown",
                                            incrementButton_buttonDownHandler);
            incrementButton.autoRepeat = true;
        }
        else if (instance == track)
        {
            track.addEventListener(MouseEvent.ROLL_OVER,
                                   track_rollOverHandler);
            track.addEventListener(MouseEvent.ROLL_OUT,
                                   track_rollOutHandler);
        }
    }

    /**
     *  @private
     */    
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == decrementButton)
        {
            decrementButton.removeEventListener("buttonDown",
                                            decrementButton_buttonDownHandler);
        }
        else if (instance == incrementButton)
        {
            incrementButton.removeEventListener("buttonDown",
                                            incrementButton_buttonDownHandler);
        }
        else if (instance == track)
        {
            track.removeEventListener(MouseEvent.ROLL_OVER,
                                      track_rollOverHandler);
            track.removeEventListener(MouseEvent.ROLL_OUT, 
                                      track_rollOutHandler);
        }
    }

    /**
     *  Make the skins reflect the enabled state of the ScrollBar.
     */
    override protected function enableSkinParts(value:Boolean):void
    {
        super.enableSkinParts(value);
        
        if (decrementButton)
            decrementButton.enabled = value;
        if (incrementButton)
            incrementButton.enabled = value;
    }

    /**
     *  Pages the <code>value</code> up or down.
     *
     *  @param increase Whether the paging action increases or
     *  decreases <code>value</code>.
     */
    public function page(increase:Boolean = true):void
    {
        if (increase)
            setValue(nearestValidValue(value + pageSize, pageSize));
        else
            setValue(nearestValidValue(value - pageSize, pageSize));
    }

    /**
     *  This utility method calculates an appropriate size for
     *  the thumb, given the current range, pageSize, and
     *  trackSize settings.
     */
    override protected function calculateThumbSize():Number
    {
        var range:Number = maximum - minimum;
        
        // Thumb takes up entire track.
        if (range == 0)
            return trackSize;

        return Math.min((pageSize / (range + pageSize) ) * trackSize, trackSize);
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
     *  Handle a click on the up button of the scroll bar. This
     *  should up one step.
     */
    protected function decrementButton_buttonDownHandler(event:Event):void
    {
        var oldValue:Number = value;
        
        step(false); // up
        
        if (value != oldValue)
        {
            positionThumb(valueToPosition(value));
            dispatchEvent(new Event("change"));
        }
    }
    
    /**
     *  Handle a click on the down button of the scroll bar. This
     *  should down one step.
     */
    protected function incrementButton_buttonDownHandler(event:Event):void
    {
        var oldValue:Number = value;
        
        step(true); // down
        
        if (value != oldValue)
        {
            positionThumb(valueToPosition(value));
            dispatchEvent(new Event("change"));
        }
    }    
    
    //---------------------------------
    // Track dragging handlers
    //---------------------------------
    
    /**
     *  Handle mouse-down events for the scroll track. In our handler,
     *  we figure out where the event occurred on the track and begin
     *  paging the scroll position toward that location. We start a 
     *  timer to handle repeating events if the user keeps the button
     *  pressed on the track.
     */
    override protected function track_mouseDownHandler(event:MouseEvent):void
    {
        // TODO (chaase): We might want a different event mechanism eventually
        // which would push this enabled check into the child/skin components
        if (!enabled)
            return;
                    
        var pt:Point = new Point(event.stageX, event.stageY);
        // Cache original event location for use on later repeating events
        trackPosition = track.globalToLocal(pt);
        var newScrollPosition:Number = pointToPosition(trackPosition.x, trackPosition.y);
        var newScrollValue:Number = positionToValue(newScrollPosition);
        
        trackScrollDown = (newScrollValue > value);
        
        var oldValue:Number = value;
        
        page(trackScrollDown);
        
        if (value != oldValue)
        {
            positionThumb(valueToPosition(value));
            dispatchEvent(new Event("change"));
        }

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
        var newScrollPosition:Number = pointToPosition(
            trackPosition.x, trackPosition.y);
        var newScrollValue:Number = positionToValue(newScrollPosition);
                
        if (trackScrollDown)
        {
            var range:Number = maximum - minimum;
            if (range == 0)
                return;
            
            //if (newScrollValue <= (value + (thumbSize / trackSize) * range))
            if ((value + pageSize) > newScrollValue)
                return;
        }
        else if (newScrollValue > value)
        {
            return;
        }

        var oldValue:Number = value;
        
        page(trackScrollDown);
        
        if (value != oldValue)
        {
            positionThumb(valueToPosition(value));
            dispatchEvent(new Event("change"));
        }

        if (trackScrollTimer && trackScrollTimer.repeatCount == 1)
        {
            // If this was the first time repeating, set the Timer to
            // repeat indefinitely with an appropriate interval delay
            trackScrollTimer.delay = REPEAT_INTERVAL;
            trackScrollTimer.repeatCount = 0;
        }
    }

    /**
     *  Handle mouse-move events for track scrolling anywhere on the stage
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
     *  @private
     *  Stop scrolling the track if the mouse leaves the stage
     *  area. Remove the listeners and stop the Timer.
     */
    private function track_mouseLeaveHandler(event:Event):void
    {
        trackScrolling = false;
        removeSystemHandlers(MouseEvent.MOUSE_MOVE, track_mouseMoveHandler,
                stage_track_mouseMoveHandler);
        systemManager.removeEventListener(MouseEvent.MOUSE_UP,
                track_mouseLeaveHandler, true);
        systemManager.stage.removeEventListener(Event.MOUSE_LEAVE, 
                            track_mouseLeaveHandler);

        if (trackScrollTimer)
            trackScrollTimer.reset();
    }

    /**
     *  @private
     *  If we are still in the middle of track-scrolling, restart the
     *  timer when the mouse re-enters the track area.
     */
    private function track_rollOverHandler(event:MouseEvent):void
    {
        if (trackScrolling)
            trackScrollTimer.start();
    }
    
    /**
     *  @private
     *  Stop the track-scrolling repeat events if the mouse leaves
     *  the track area.
     */
    private function track_rollOutHandler(event:MouseEvent):void
    {
        if (trackScrolling)
            trackScrollTimer.stop();
    }
}

}