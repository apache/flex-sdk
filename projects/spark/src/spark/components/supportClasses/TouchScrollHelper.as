////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.supportClasses
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.events.TouchEvent;
import flash.geom.Point;
import flash.system.Capabilities;
import flash.utils.Timer;

import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.SandboxMouseEvent;
import mx.events.TouchInteractionEvent;
import mx.events.TouchInteractionReason;
import mx.managers.ISystemManager;
import mx.utils.GetTimerUtil;

use namespace mx_internal;
    
[ExcludeClass]

/**
 *  @private
 *  Helper class to handle some of the touch scrolling logic.  Specifically
 *  it is used to handle some of the mouse tracking and velocity calculations.
 */
public class TouchScrollHelper
{
        
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Number of mouse movements to keep in the history to calculate 
     *  velocity.
     */
    private static const EVENT_HISTORY_LENGTH:int = 5;
    
    /**
     *  @private
     *  Minimum velocity needed to start a throw gesture, in inches per second.
     */
    private static const MIN_START_VELOCITY_IPS:Number = 0.8;
    
    /**
     *  @private
     *  Maximum velocity of throw effect, in inches per second.
     */
    private static const MAX_THROW_VELOCITY_IPS:Number = 10.0;
    
    /**
     *  @private
     *  Weights to use when calculating velocity, giving the last velocity more of a weight 
     *  than the previous ones.
     */
    private static const VELOCITY_WEIGHTS:Vector.<Number> = Vector.<Number>([1, 1.33, 1.66, 2]);
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor
     */
    public function TouchScrollHelper()
    {
        super();
        
        isIOS = (Capabilities.version.indexOf("IOS") == 0);
        
        mouseEventCoordinatesHistory = new Vector.<Point>(EVENT_HISTORY_LENGTH);
        mouseEventTimeHistory = new Vector.<int>(EVENT_HISTORY_LENGTH);
    }
    

    /**
     *  @private
     *  A callback that is invoked when a drag is in progress
     *  and there's a new pixel delta. 
     */
    mx_internal var dragFunction:Function = null;

    /**
     *  @private
     *  A callback that is invoked when the drag part of the 
     *  touch gesture is over (mouse up was received), and 
     *  a throw may be necessary.  
     */
    mx_internal var throwFunction:Function = null;

    /**
     *  @private
     *  The component on which the touch interaction events are dispatched.
     */
    mx_internal var target:UIComponent;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  scrollSlop - the scrolling threshold (minimum number of 
     *  pixels needed to move before a scroll gesture is recognized
     */
    private var scrollSlop:Number;
    
    
    /**
     *  @private
     *  The point that was moused downed on for this scroll gesture
     */
    private var mouseDownedPoint:Point;
    
    /**
     *  @private
     *  The displayObject that was mousedowned on.
     */
    private var mouseDownedDisplayObject:DisplayObject;
    
    /**
     *  @private
     *  The point that a scroll was recognized from.
     * 
     *  <p>This is different from mouseDownedPoint because the user may 
     *  mousedown on one point, but a scroll isn't recognized until 
     *  they move more than the slop.  Because of this, we don't want
     *  the delta scrolled to be calculated from the mouseDowned point 
     *  because that would look jerky the first time a scroll occurred.</p>
     */
    private var scrollGestureAnchorPoint:Point;
    
    /**
     *  @private
     *  The delta coordinates of the most recent mouse event during a drag gesture
     */
    private var mostRecentDragDeltaX:Number;
    private var mostRecentDragDeltaY:Number;
    
    /**
     *  @private
     *  The time of the most recent mouse event during a drag gesture
     */
    private var mostRecentDragTime:Number;
    
    /**
     *  @private
     *  Timer used to do drag scrolling.
     */
    private var dragTimer:Timer = null;
    
    /**
     *  @private
     *  Indicates that the mouse coordinates have changed and the 
     *  next dragTimer invokation needs to do a scroll.
     */
    private var dragScrollPending:Boolean = false;
    
    /**
     *  @private
     *  The time the scroll started
     */
    private var startTime:Number;
    
    /**
     *  @private
     *  Keeps track of the coordinates where the mouse events 
     *  occurred.  We use this for velocity calculation along 
     *  with timeHistory.
     */
    private var mouseEventCoordinatesHistory:Vector.<Point>;
    
    /**
     *  @private
     *  Length of items in the mouseEventCoordinatesHistory and 
     *  timeHistory Vectors since a circular buffer is used to 
     *  conserve points.
     */
    private var mouseEventLength:Number = 0;
    
    /**
     *  @private
     *  A history of times the last few mouse events occurred.
     *  We keep HISTORY objects in memory, and we use this mouseEventTimeHistory
     *  Vector along with mouseEventCoordinatesHistory to determine the velocity
     *  a user was moving their fingers.
     */
    private var mouseEventTimeHistory:Vector.<int>;
    
    /**
     *  @private
     *  Whether we are currently in a scroll gesture or not.
     */
    private var isScrolling:Boolean;
    
    /**
     *  @private
     *  Indicates whether we're running on an iOS device
     */
    private var isIOS:Boolean = false;
    
    /**
     *  @private
     *  This determines the maximum rate at which the "dragFunction"
     *  callback will be invoked (aka "event thinning). A value of 
     *  NaN means that callbacks will be delivered as quickly as possible.
     */
    private var maxScrollRate:Number = NaN;
    
    /**
     *  @private
     *  True if we should watch for scrolling on the horizontal axis.
     */
    private var canScrollHorizontally:Boolean;
    
    /**
     *  @private
     *  True if we should watch for scrolling on the vertical axis.
     */
    private var canScrollVertically:Boolean;

    /**
     *  @private
     *  Keeps track of whether we currently have our mouse listeners installed.
     *  Used to avoid handling redundant events.  
     */
    private var mouseListenersInstalled:Boolean = false;

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Starts watching for a scroll operation.  This should take either 
     *  MouseEvent.MOUSE_DOWN or TouchEvent.TOUCH_BEGIN, but for now, only
     *  mousedown works.
     */
    mx_internal function startScrollWatch(
        event:Event, 
        canScrollHorizontally:Boolean = true, 
        canScrollVertically:Boolean = true, 
        slop:Number = 0, 
        maxScrollRate:Number = NaN):void
    {
        // this is the point from which all deltas are based.
        startTime = GetTimerUtil.getTimer();
        this.scrollSlop = slop;
        this.maxScrollRate = maxScrollRate; 
        this.canScrollHorizontally = canScrollHorizontally;
        this.canScrollVertically = canScrollVertically;
        
        if (event is MouseEvent && event.type == MouseEvent.MOUSE_DOWN)
        {
            var mouseEvent:MouseEvent = event as MouseEvent;
            
            if (!isScrolling)
            {
                this.mouseDownedDisplayObject = mouseEvent.target as DisplayObject;
                
                mouseDownedPoint = new Point(mouseEvent.stageX, mouseEvent.stageY);
            }
            
            installMouseListeners();
            
            // if we were already scrolling, continue scrolling
            if (isScrolling)
            {
                scrollGestureAnchorPoint = new Point(mouseEvent.stageX, mouseEvent.stageY);
                mouseDownedPoint = new Point(mouseEvent.stageX, mouseEvent.stageY);
            }
            
            // reset circular buffer index/length
            mouseEventLength = 0;
            
            addMouseEventHistory(mouseEvent.stageX, mouseEvent.stageY, GetTimerUtil.getTimer());
        }
        else if (event is TouchEvent && event.type == TouchEvent.TOUCH_BEGIN)
        {
            // TouchEvent case
            // TODO (rfrishbe)
        }            
    }
    
    /**
     *  @private
     *  Starts watching for a scroll operation.
     */
    mx_internal function stopScrollWatch():void
    {
        uninstallMouseListeners();
    }
    
    /**
     *  @private
     *  Adds the time and mouse coordinates for this event in to 
     *  our mouse event history so that we can use it later to 
     *  calculate velocity.
     * 
     *  @return the delta moved between this mouse event and the start
     *          of the scroll gesture.
     */
    private function addMouseEventHistory(stageX:Number, stageY:Number, time:Number):Point
    {
        // calculate dx, dy
        var dx:Number = stageX - mouseDownedPoint.x;
        var dy:Number = stageY - mouseDownedPoint.y;
        
        // either use a Point object already created or use one already created
        // in mouseEventCoordinatesHistory
        var currentPoint:Point;
        var currentIndex:int = (mouseEventLength % EVENT_HISTORY_LENGTH);
        if (mouseEventCoordinatesHistory[currentIndex])
        {
            currentPoint = mouseEventCoordinatesHistory[currentIndex];
            currentPoint.x = dx;
            currentPoint.y = dy;
        }
        else
        {
            currentPoint = new Point(dx, dy);
            mouseEventCoordinatesHistory[currentIndex] = currentPoint;
        }
        
        // add time history as well
        
        // Using the passed-in "time" value is more accurate than querying the timer here, as the 
        // delta coordinates may have been captured a while ago (i.e. in the event thinning
        // timer handler).  However, I'm only making this change for iOS right now in order
        // to reduce risk at the end of the 4.5.1 release.
        // TODO (eday):  Change this to use the passed-in time for all platforms.
        mouseEventTimeHistory[currentIndex] = isIOS ? (time - startTime) : (GetTimerUtil.getTimer() - startTime);
        
        // increment current length if appropriate
        mouseEventLength ++;
        
        return currentPoint;
    }
    
    /**
     *  @private
     *  Installs mouse listeners to determine how far we've moved.
     */
    private function installMouseListeners():void
    {
        const sm:ISystemManager = target.systemManager;
        const sbRoot:DisplayObject = sm.getSandboxRoot();
        
        sbRoot.addEventListener(MouseEvent.MOUSE_MOVE, sbRoot_mouseMoveHandler, true);
        sbRoot.addEventListener(MouseEvent.MOUSE_UP, sbRoot_mouseUpHandler, true);

        // If mouseUp is on StageText the only way to know that is to listen for it on the Stage.
        if (sm.stage && sm.isTopLevelRoot())
            sm.stage.addEventListener(MouseEvent.MOUSE_UP, sbRoot_mouseUpHandler);
        
        sbRoot.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, sbRoot_mouseUpHandler);
        
        target.systemManager.deployMouseShields(true);
        
        mouseListenersInstalled = true;
    }
    
    /**
     *  @private
     */
    private function uninstallMouseListeners():void
    {
        const sm:ISystemManager = target.systemManager;
        const sbRoot:DisplayObject = sm.getSandboxRoot();
        
        // mouse events added in installMouseListeners()
        sbRoot.removeEventListener(MouseEvent.MOUSE_MOVE, sbRoot_mouseMoveHandler, true);
        sbRoot.removeEventListener(MouseEvent.MOUSE_UP, sbRoot_mouseUpHandler, true);
        
        if (sm.stage && sm.isTopLevelRoot())
            sm.stage.removeEventListener(MouseEvent.MOUSE_UP, sbRoot_mouseUpHandler);
        
        sbRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, sbRoot_mouseUpHandler);

        target.systemManager.deployMouseShields(false);

        mouseListenersInstalled = false;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  If we are not scrolling, this is used to determine whether we should start 
     *  scrolling or not by checking if we've moved more than the slop.
     *  If we are scrolling, this is used to call dragFunction callback 
     *  and to determine how far the user has scrolled.
     */
    private function sbRoot_mouseMoveHandler(event:MouseEvent):void
    {
        var mouseDownedDifference:Point = 
            new Point(event.stageX - mouseDownedPoint.x, event.stageY - mouseDownedPoint.y);   
        
        if (!isScrolling)
        {
            var shouldBeScrolling:Boolean = false;
            
            // now figure out if we should scroll horizontally or vertically based on our slop
            if (canScrollHorizontally && Math.abs(mouseDownedDifference.x) >= scrollSlop)
                shouldBeScrolling = true;
            if (canScrollVertically && Math.abs(mouseDownedDifference.y) >= scrollSlop)
                shouldBeScrolling = true;
            
            // If we should be scrolling, start scrolling
            if (shouldBeScrolling)
            {
                // Dispatch a cancellable and bubbling event to notify others
                var scrollStartingEvent:TouchInteractionEvent = new TouchInteractionEvent(TouchInteractionEvent.TOUCH_INTERACTION_STARTING, true, true);
                scrollStartingEvent.relatedObject = target;
                scrollStartingEvent.reason = TouchInteractionReason.SCROLL;
                var eventAccepted:Boolean = dispatchBubblingEventOnMouseDownedDisplayObject(scrollStartingEvent);
                
                // if the event was preventDefaulted(), then stop scrolling scrolling
                if (!eventAccepted)
                {                    
                    // TODO (rfrishbe): do we need to call updateAfterEvent() here and below?
                    event.updateAfterEvent();
                    
                    // calling stopScrollWatch() will remove all the appropriate listeners
                    stopScrollWatch();
                    
                    return;
                }
                
                // if the event has been accepted, then dispatch a bubbling start event
                var scrollStartEvent:TouchInteractionEvent = new TouchInteractionEvent(TouchInteractionEvent.TOUCH_INTERACTION_START, true, true);
                scrollStartEvent.relatedObject = target;
                scrollStartEvent.reason = TouchInteractionReason.SCROLL;
                dispatchBubblingEventOnMouseDownedDisplayObject(scrollStartEvent);
                
                isScrolling = true;
                
                // now that we're scrolling, calculate the scrollAnchorPoint.  
                // There are three cases: diagonal, horizontal, and vertical.
                // if (0,0) is where you mouseDowned, (10,10) is where you are at now.  Then mouseDownedDiff is (10, 10)
                // scrollAnchorPoint is calculated as where we "crossed the threshold" in to scrolling territory.
                // so we figure out if they scrolled up, down, right, left (or a combination of that for 
                // the diagonal case).
                if (canScrollHorizontally && canScrollVertically)
                {
                    // diagonal case
                    var maxAxisDistance:Number = Math.max(Math.abs(mouseDownedDifference.x), Math.abs(mouseDownedDifference.y));
                    if (maxAxisDistance >= scrollSlop)
                    {
                        var scrollAnchorDiffX:int;
                        var scrollAnchorDiffY:int;
                        
                        // The anchor point is the point at which the line described by mouseDownedDifference
                        // intersects with the perimeter of the slop area.  The slop area is a square with sides
                        // of length scrollSlop*2. 
                        var normalizedDiff:Point = mouseDownedDifference.clone();
                        
                        // Use the ratio of scrollSlop to maxAxisDistance to determine the length of the line
                        // from the mouse down point to the anchor point.
                        var lineLength:Number = (scrollSlop / maxAxisDistance) * mouseDownedDifference.length;  
                        
                        // Normalize to create a line of that length with the same angle it had before.
                        normalizedDiff.normalize(lineLength);
                        
                        // 4 possibilities: top-right, top-left, bottom-right, bottom-left
                        scrollAnchorDiffX = Math.round(normalizedDiff.x);
                        scrollAnchorDiffY = Math.round(normalizedDiff.y);
                        
                        scrollGestureAnchorPoint = new Point(mouseDownedPoint.x + scrollAnchorDiffX, 
                            mouseDownedPoint.y + scrollAnchorDiffY);
                    }
                }
                else if (canScrollHorizontally)
                {
                    // horizontal case
                    if (mouseDownedDifference.x >= scrollSlop)
                        scrollGestureAnchorPoint = new Point(mouseDownedPoint.x + scrollSlop, mouseDownedPoint.y);
                    else
                        scrollGestureAnchorPoint = new Point(mouseDownedPoint.x - scrollSlop, mouseDownedPoint.y);
                }
                else if (canScrollVertically)
                {
                    // vertical case
                    if (mouseDownedDifference.y >= scrollSlop)
                        scrollGestureAnchorPoint = new Point(mouseDownedPoint.x, mouseDownedPoint.y + scrollSlop);
                    else
                        scrollGestureAnchorPoint = new Point(mouseDownedPoint.x, mouseDownedPoint.y - scrollSlop);
                }
                
                // velocity calculations come from mouseDownedPoint.  The drag ones com from scrollStartPoint.
                // This seems fine.
            }
        }
        
        // if we are scrolling (even if we just started scrolling)
        if (isScrolling)
        {
            // calculate the delta
            var dx:Number = event.stageX - scrollGestureAnchorPoint.x;
            var dy:Number = event.stageY - scrollGestureAnchorPoint.y;
            
            if (!dragTimer)
            {
                // The logic in this code requires that we create a timer with 
                // a valid rate even if the specified rate is NaN and the timer
                // won't actually be used.
                var rate:Number = isNaN(maxScrollRate) ? 30 : maxScrollRate; 
                dragTimer = new Timer(1000/rate, 0);
                dragTimer.addEventListener(TimerEvent.TIMER, dragTimerHandler);
            }
            
            if (!dragTimer.running)
            {
                // The drag timer is not running, so we record the event and scroll
                // the content immediately.
                addMouseEventHistory(event.stageX, event.stageY, GetTimerUtil.getTimer());
                if (dragFunction != null)
                    dragFunction(dx, dy);
                
                // Call updateAfterEvent() to make sure it looks smooth
                event.updateAfterEvent();
                
                // If event thinning is not enabled, we never start the timer so all subsequent
                // move event will continue to be handled right in this function.
                if (!isNaN(maxScrollRate))
                {
                    // Start the periodic timer that will do subsequent drag 
                    // scrolling if necessary. 
                    dragTimer.start();
                    
                    // No additional mouse events received yet, so no scrolling pending.
                    dragScrollPending = false;
                }
            }
            else
            {
                // The drag timer is running, so we just save the delta coordinates
                // and indicate that a scroll is pending.
                mostRecentDragDeltaX = dx;
                mostRecentDragDeltaY = dy;
                mostRecentDragTime = GetTimerUtil.getTimer();
                dragScrollPending = true;
            }
        }
    }
    
    /**
     *  @private
     *  Used to periodically scroll during a drag gesture
     */
    private function dragTimerHandler(event:TimerEvent):void
    {
        if (dragScrollPending)
        {
            // A scroll is pending, so record the mouse deltas and scroll the content. 
            addMouseEventHistory(
                mostRecentDragDeltaX + scrollGestureAnchorPoint.x,
                mostRecentDragDeltaY + scrollGestureAnchorPoint.y, mostRecentDragTime);
            if (dragFunction != null)
                dragFunction(mostRecentDragDeltaX, mostRecentDragDeltaY);
            
            // Call updateAfterEvent() to make sure it looks smooth
            event.updateAfterEvent();
            
            // No scroll is pending now. 
            dragScrollPending = false;
        }
        else
        {
            // The timer elapsed with no mouse events, so we'll
            // just turn the timer off for now.  It will get turned
            // back on if another mouse event comes in.
            dragTimer.stop();
        }
    }

    /**
     *  @private
     *  Called when the user releases the mouse/touches up
     */
    private function sbRoot_mouseUpHandler(event:Event):void
    {
        // We install this mouseUp handler on both the sandbox root and the stage.
        // This can result in receiving more than one event for a single up gesture.
        // So we use the mouseListenersInstalled flag to ignore redundant events.
        if (!mouseListenersInstalled)
            return;

        uninstallMouseListeners();

        // If we weren't already scrolling, then let's not start scrolling now
        if (!isScrolling)
            return;
        
        if (dragTimer)
        {
            if (dragScrollPending)
            {
                // A scroll is pending, so record the mouse deltas and scroll
                // the content.
                addMouseEventHistory(
                    mostRecentDragDeltaX + scrollGestureAnchorPoint.x,
                    mostRecentDragDeltaY + scrollGestureAnchorPoint.y, mostRecentDragTime);
                if (dragFunction != null)
                    dragFunction(mostRecentDragDeltaX, mostRecentDragDeltaY);
                
                // Call updateAfterEvent() to make sure it looks smooth
                if (event is MouseEvent)
                    MouseEvent(event).updateAfterEvent();
            }
            
            // The drag gesture is over, so we no longer need the timer.
            dragTimer.stop();
            dragTimer.removeEventListener(TimerEvent.TIMER, dragTimerHandler);
            dragTimer = null;
        }
        

        // Note that we do not add the time and position of the mouseUp event to 
        // our event history.  This is because the timing of this event is unreliable
        // and causes problems for our velocity calculation.
        
        // pad click and timeHistory if needed
        var currentTime:Number = GetTimerUtil.getTimer();
        
        // calculate average time b/w events and see if the last two (mouseMove and this mouseUp) 
        // were far apart.  If they were, then don't do anything if the velocity of them is small.
        var averageDt:Number = 0;
        var len:int = (mouseEventLength > EVENT_HISTORY_LENGTH ? EVENT_HISTORY_LENGTH : mouseEventLength);
        
        // if haven't wrapped around, then startIndex = 0.  If we've wrapped around, 
        // then startIndex = mouseEventLength % EVENT_HISTORY_LENGTH.  The equation 
        // below handles both of those cases
        const startIndex:int = ((mouseEventLength - len) % EVENT_HISTORY_LENGTH);
        const endIndex:int = ((mouseEventLength - 1) % EVENT_HISTORY_LENGTH);
        
        // gauranteed to have 2 mouse events b/c atleast a mousedown and a mousemove 
        // because if there was no mousemove, we definitely would not be scrolling and 
        // would have exited this function earlier
        var currentIndex:int = startIndex;
        while (currentIndex != endIndex)
        {
            // calculate nextIndex here so we can use it in the calculations
            var nextIndex:int = ((currentIndex + 1) % EVENT_HISTORY_LENGTH);
            
            averageDt += mouseEventTimeHistory[nextIndex] - mouseEventTimeHistory[currentIndex];
            
            currentIndex = nextIndex;
        }
        averageDt /= len-1;
        
        var minVelocityPixels:Number = MIN_START_VELOCITY_IPS * Capabilities.screenDPI / 1000;
        
        // calculate the velocity using a weighted average
        var throwVelocity:Point = calculateThrowVelocity();
        
        // Also calculate the effective velocity for the final 100ms of the drag.
        var finalDragVel:Point = calculateFinalDragVelocity(100);
        
        // On iOS, we use the final 100ms of the drag to determine the velocity.
        // TODO (eday): arrive at a velocity-calculation scheme that works across platforms. 
        if (isIOS)
            throwVelocity = finalDragVel; 
        
        if (throwVelocity.length <= minVelocityPixels)
        {
            throwVelocity.x = 0;
            throwVelocity.y = 0;
        }
        
        // If the gesture appears to have slowed or stopped prior to the mouse up, 
        // then force the velocity to zero.
        // Compare the final 100ms of the drag to the minimum value. 
        if ( finalDragVel.length <= minVelocityPixels)
        {
            throwVelocity.x = 0;
            throwVelocity.y = 0;
        }
        
        // Note that we always call the throw function - even when the velocity is zero.
        // This is needed because we may be past the end of the list and need an 
        // animation to get us back.
        if (throwFunction != null)
            throwFunction(throwVelocity.x, throwVelocity.y);
    }
    
    /**
     *  @private
     *  Helper function to calculate the current throwVelocity().
     *  
     *  <p>It calculates the velocities and then calculates a weighted 
     *  average from them.</p>
     */
    private function calculateThrowVelocity():Point
    {
        var len:int = (mouseEventLength > EVENT_HISTORY_LENGTH ? EVENT_HISTORY_LENGTH : mouseEventLength);
        
        // we are guarenteed to have 2 items here b/c of mouseDown and a mouseMove
        
        // if haven't wrapped around, then startIndex = 0.  If we've wrapped around, 
        // then startIndex = mouseEventLength % EVENT_HISTORY_LENGTH.  The equation 
        // below handles both of those cases
        const startIndex:int = ((mouseEventLength - len) % EVENT_HISTORY_LENGTH);
        const endIndex:int = ((mouseEventLength - 1) % EVENT_HISTORY_LENGTH);
        
        // variables to store a running average
        var weightedSumX:Number = 0;
        var weightedSumY:Number = 0;
        var totalWeight:Number = 0;
        
        var currentIndex:int = startIndex;
        var i:int = 0;
        while (currentIndex != endIndex)
        {
            // calculate nextIndex early so we can re-use it for these calculations
            var nextIndex:int = ((currentIndex + 1) % EVENT_HISTORY_LENGTH);
            
            // Get dx, dy, and dt
            var dt:Number = mouseEventTimeHistory[nextIndex] - mouseEventTimeHistory[currentIndex];
            var dx:Number = mouseEventCoordinatesHistory[nextIndex].x - mouseEventCoordinatesHistory[currentIndex].x;
            var dy:Number = mouseEventCoordinatesHistory[nextIndex].y - mouseEventCoordinatesHistory[currentIndex].y;
            
            if (dt != 0)
            {
                // calculate a weighted sum for velocities
                weightedSumX += (dx/dt) * VELOCITY_WEIGHTS[i];
                weightedSumY += (dy/dt) * VELOCITY_WEIGHTS[i];
                totalWeight += VELOCITY_WEIGHTS[i];
            }
            
            currentIndex = nextIndex;
            i++;
        }
        
        if (totalWeight == 0)
            return new Point(0, 0);
        
        // Limit the velocity to an absolute maximum
        var maxPixelsPerMS:Number = MAX_THROW_VELOCITY_IPS * Capabilities.screenDPI / 1000;
        var velX:Number = Math.min(maxPixelsPerMS, Math.max(-maxPixelsPerMS, weightedSumX/totalWeight));
        var velY:Number = Math.min(maxPixelsPerMS, Math.max(-maxPixelsPerMS, weightedSumY/totalWeight));
        
        return new Point(velX, velY);
    }
    
    /**
     *  @private
     *  Helper function to calculate the velocity of the touch drag
     *  for its final <code>time</code> milliseconds. 
     */
    private function calculateFinalDragVelocity(time:Number):Point
    {
        // This function is similar to calculateThrowVelocity with the 
        // following differences:
        // 1) It iterates backwards through the mouse events.
        // 2) It stops when the specified amount of time is accounted for.
        // 3) It calculates the velocities from the overall deltas with no
        //    weighting or averaging. 
        
        // Find the range of mouse events to consider
        var len:int = (mouseEventLength > EVENT_HISTORY_LENGTH ? EVENT_HISTORY_LENGTH : mouseEventLength);
        const startIndex:int = ((mouseEventLength - len) % EVENT_HISTORY_LENGTH);
        const endIndex:int = ((mouseEventLength - 1) % EVENT_HISTORY_LENGTH);
        
        // We're going to start at the last event of the drag and iterate 
        // backward toward the first.
        var currentIndex:int = endIndex;
        
        var dt:Number = 0;
        var dx:Number = 0;
        var dy:Number = 0;
        
        // Loop until we've accounted for the desired amount of time or run out of events. 
        while (time > 0 && currentIndex != startIndex)
        {
            // Find the index of the previous event
            var previousIndex:int = currentIndex - 1;
            if (previousIndex < 0)
                previousIndex += EVENT_HISTORY_LENGTH; 
            
            // Calculate time and position deltas between the two events
            var _dt:Number = mouseEventTimeHistory[currentIndex] - mouseEventTimeHistory[previousIndex];
            var _dx:Number = mouseEventCoordinatesHistory[currentIndex].x - mouseEventCoordinatesHistory[previousIndex].x;
            var _dy:Number = mouseEventCoordinatesHistory[currentIndex].y - mouseEventCoordinatesHistory[previousIndex].y;
            
            // If the deltas exceed our desired time range, interpolate by scaling them
            if (_dt > time)
            {
                var interpFraction:Number = time/_dt;
                _dx *= interpFraction; 
                _dy *= interpFraction;
                _dt = time;
            }
            
            // Subtract the current time delta from the overall desired time range 
            time -= _dt;
            
            // Accumulate the deltas
            dt += _dt;
            dx += _dx;
            dy += _dy;
            
            // Go to the previous event in the drag
            currentIndex = previousIndex;
        }
        
        if (dt == 0)
            return new Point(0, 0);
        
        if (isIOS)
        {
            // On iOS, we use this function to determine the throw velocity.  So we need to enforce
            // the same maximum velocity as calculateThrowVelocity.
            // TODO (eday): make all this stuff platform-independent.
            var maxPixelsPerMS:Number = MAX_THROW_VELOCITY_IPS * Capabilities.screenDPI / 1000;
            var velX:Number = Math.min(maxPixelsPerMS, Math.max(-maxPixelsPerMS, dx/dt));
            var velY:Number = Math.min(maxPixelsPerMS, Math.max(-maxPixelsPerMS, dy/dt));
            return new Point(velX, velY);
        }
        
        // Create the point representing the velocity values.
        return new Point(dx/dt, dy/dt);
    }
    
    /**
     *  @private
     *  Helper method to dispatch bubbling events on mouseDownDisplayObject.  Since this 
     *  object can be off the display list, this may be tricky.  Technically, we should 
     *  grab all the live objects at the time of mouseDown and dispatch events to them 
     *  manually, but instead, we just use this heuristic, which is dispatch it to 
     *  mouseDownedDisplayObject.  If it's not inside of target and off the display list,
     *  then dispatch to target as well.
     * 
     *  <p>If you absolutely need to know the touch event ended, add event listeners 
     *  to the mouseDownedDisplayObject directly and don't rely on event 
     *  bubbling.</p>
     */
    private function dispatchBubblingEventOnMouseDownedDisplayObject(event:Event):Boolean
    {
        var eventAccepted:Boolean = true;
        if (mouseDownedDisplayObject)
        {
            eventAccepted = eventAccepted && mouseDownedDisplayObject.dispatchEvent(event);
            if (!mouseDownedDisplayObject.stage)
            {
                if (target && !target.contains(mouseDownedDisplayObject))
                    eventAccepted = eventAccepted && target.dispatchEvent(event);
            }
        }
        else
        {
            eventAccepted = eventAccepted && target.dispatchEvent(event);
        }
        
        return eventAccepted;
    }
    
    /**
     *  @private
     *  When the touchScrollThrow is over, we should dispatch a touchInteractionEnd.
     */
    mx_internal function endTouchScroll():void
    {
        if (isScrolling)
        {
            isScrolling = false;
            
            var scrollEndEvent:TouchInteractionEvent = new TouchInteractionEvent(TouchInteractionEvent.TOUCH_INTERACTION_END, true);
            scrollEndEvent.relatedObject = target;
            scrollEndEvent.reason = TouchInteractionReason.SCROLL;
            dispatchBubblingEventOnMouseDownedDisplayObject(scrollEndEvent);
        }
    }
}
}