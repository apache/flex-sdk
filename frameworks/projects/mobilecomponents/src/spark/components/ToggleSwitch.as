////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

package spark.components
{

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.Timer;

import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.supportClasses.ToggleButtonBase;
import spark.core.IDisplayText;
import spark.effects.Animate;
import spark.effects.animation.Animation;
import spark.effects.animation.IAnimationTarget;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.effects.easing.Sine;
import spark.utils.MouseEventUtil;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  The duration in milleseconds for an animating the thumb between
 *  the selected and unselected sides of the track. Animating between
 *  two arbitrary positions on the track, for example after a drag
 *  gesture, will take a proportionally shorter amount of time. 
 */
[Style(name="slideDuration", type="Number", format="Time", inherit="no")]


//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="textAlign", kind="style")]

/**
 *  The Spark ToggleSwitch component is a component that can flip between
 *  a selected and non selected state. The ToggleSwitch has a <code>thumb</code>
 *  skin part that moves between the two ends of the <code>track</code> skin part,
 *  similar to a Spark <code>Slider</code>.
 *
 *  Clicking on the component will flip it from non-selected to selected,
 *  and vice-versa. A user can also drag the thumb along the track. When released,
 *  the thumb will move to the closest end of the track, and the <code>ToggleSwitch</code>
 *  will change to be either selected or non-selected, according to the thumb's
 *  position.
 *
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 *
 *  @see spark.components.ToggleButton
 *  @see spark.components.HSlider
 */
public class ToggleSwitch extends ToggleButtonBase
{
    
    //----------------------------------------------------------------------------------------------
    //
    //  Constructor
    //
    //----------------------------------------------------------------------------------------------
    
    /**
     *  Constructor. 
     *  
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public function ToggleSwitch()
    {
        super();
        stickyHighlighting = true;
        animator = new Animation();
        animator.easer = new Sine(0);
    }
    
    //----------------------------------------------------------------------------------------------
    //
    //  Variables
    //
    //----------------------------------------------------------------------------------------------
    
    /**
     *  The last position of the mouse during a drag gesture
     */
    private var lastMouseX:Number;
    
    /**
     *  Controls the mouse events driving a drag gesture on a
     *  ToggleSwitch
     */
    private var mouseDragUtil:MouseDragUtil;
    
    /**
     *  Whether the mouse has moved during the current drag
     *  gesture
     */
    private var mouseMoved:Boolean;
    
    /**
     *  Where the thumb should be after the current animation ends
     */
    private var slideToPosition:Number;
    
    /**
     *  The point where the current mouse gesture began
     */
    private var stageOffset:Point;
    
    /**
     *  The thumbPosition when the current mouse gesture began
     */
    private var positionOffset:Number = 0;
    
    //----------------------------------------------------------------------------------------------
    //
    //  Skin parts
    //
    //----------------------------------------------------------------------------------------------
    
    [SkinPart(required="false")]
    
    /**
     *  A skin part that can be dragged along the track. The thumb's
     *  current position along the track is given by 
     *  <code>thumbPosition</code>.
     *  
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */ 
    public var thumb:IVisualElement;
    
    [SkinPart(required="false")]
    
    /**
     *  A skin part that defines the bounds along which the thumb can
     *  be dragged.
     *  
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public var track:IVisualElement;
    
    //----------------------------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //----------------------------------------------------------------------------------------------
    
    //----------------------------------
    //  selected
    //----------------------------------
    override public function set selected(value:Boolean):void 
    {
        super.selected = value;
        var newValue:Number = selectedToPosition(value);
        slideToPosition = newValue;
        setThumbPosition(newValue);
    }
    
    //----------------------------------------------------------------------------------------------
    //
    //  Properties
    //
    //----------------------------------------------------------------------------------------------
    
    //----------------------------------
    //  thumbPosition
    //----------------------------------
    
    /**
     *  The animation between thumbPosition and slideToPosition, which
     *  drives the thumb's position. exposed for testing.
     */
    private var _animator:Animation = null;
    
    /**
     *  @private
     */
    mx_internal function get animator():Animation 
    {
        return _animator;
    }
    
    /**
     *  @private
     */
    mx_internal function set animator(value:Animation): void 
    {
        _animator = value;
        var animTarget:IAnimationTarget = new AnimationTargetHelper(animationUpdateHandler, animationEndHandler);
        animator.animationTarget = animTarget;
    }
    
    //----------------------------------
    //  thumbPosition
    //----------------------------------
    
    /**
     *  Storage for thumbPosition
     */
    private var _thumbPosition:Number = 0.0;
    
    [Bindable(event="thumbPositionChanged")]
    
    /**
     *  The thumb's current position, ranging from <code>0</code>, unselected,
     *  to <code>1</code>, selected.
     *  
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */ 
    public function get thumbPosition():Number 
    {
        return _thumbPosition;
    }
    
    //----------------------------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //----------------------------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function updateDisplayList(w:Number, h:Number):void
    {
        super.updateDisplayList(w, h);
        updateSkinDisplayList();
    }
    
    /**
     *  @private
     */
    override protected function addHandlers():void 
    {
        super.addHandlers();
        mouseDragUtil = new MouseDragUtil(this, mouseDownHandler, 
            mouseDragHandler, thinnedMouseDragHandler, mouseUpHandler);
        mouseDragUtil.setupHandlers();
    }
    
    //----------------------------------------------------------------------------------------------
    //
    //  Methods
    //
    //----------------------------------------------------------------------------------------------
    
    /**
     *  Convert the given thumb position to a selected value
     */
    private function positionToSelected(value:Number):Boolean 
    {
        return value > 0.5;	
    }
    
    /**
     *  Convert the selected value to a thumb position
     */
    private function selectedToPosition(value:Boolean):Number 
    {
        return value ? 1.0 : 0.0;	
    }
    
    /**
     *  Specify the new position the toggle switch should animate to
     *  at the end of the animation, selection will update
     */
    private function moveToPosition(newPosition:Number):void 
    {
        var slideDuration:Number = getStyle("slideDuration");
        if (newPosition != thumbPosition && slideDuration > 0)
        {
            // Finish any current animation before we start the next one.
            if (animator.isPlaying)
                stopAnimation();
            
            // holds the final value to be set when animation ends
            slideToPosition = newPosition;
            animator.duration = slideDuration *  
                (Math.abs(thumbPosition - slideToPosition));
            animator.motionPaths = new <MotionPath>[
                new SimpleMotionPath("position", thumbPosition, slideToPosition)];
            animator.play();
        } 
        else 
        {
            // we are either at the destination position, 
            // or we should update immediately
            selected = positionToSelected(newPosition);
        }
        
    }
    
    /**
     *  Set the thumb position and update the component
     */
    private function setThumbPosition(value:Number):void 
    {
        if (value == _thumbPosition)
            return;
        value = Math.min(value, 1.0);
        value = Math.max(value, 0.0);
        if (value == _thumbPosition)
            return;
        _thumbPosition = value;
        invalidateDisplayList();
        if (hasEventListener("thumbPositionChanged"))
            dispatchEvent(new Event("thumbPositionChanged"));
    }
    
    /**
     *  Stops a running animation prematurely
     */
    private function stopAnimation():void
    {
        animator.stop();
    }
    
    /**
     *  Position the thumb along the track based on thumbPosition.
     *  The usable width of the track is equal to the track's layout width
     *  less the thumb's width, as the thumb should always be contained by
     *  the track.
     */
    private function updateSkinDisplayList():void 
    {
        if (!thumb || !track || !thumb.parent || !track.parent)
            return;
        
        // Perform calculations in global space, since track & thumb may have different coordinate spaces
        var globalThumbXOffset:Number = getGlobalTrackRange() *  thumbPosition;
        var globalThumbPos:Point = track.parent.localToGlobal(new Point(track.getLayoutBoundsX()));
        globalThumbPos.x += globalThumbXOffset;
        
        var localThumbPos:Point = thumb.parent.globalToLocal(globalThumbPos);
        thumb.setLayoutBoundsPosition(Math.round(localThumbPos.x), thumb.getLayoutBoundsY());
    }
    
    /**
     *  Determine the global range of motion for the thumb on the track
     */
    private function getGlobalTrackRange():Number 
    {
        var globalTrackDims:Point = track.parent.localToGlobal(new Point(track.getLayoutBoundsWidth()));
        var globalThumbDims:Point = thumb.parent.localToGlobal(new Point(thumb.getLayoutBoundsWidth()));
        return globalTrackDims.x - globalThumbDims.x;
    }
    
    //----------------------------------------------------------------------------------------------
    //
    //  Overridden Event handlers
    //
    //----------------------------------------------------------------------------------------------
    
    /**
     *  @private
     *  ignore mouse events while animating
     */
    override protected function mouseEventHandler(event:Event):void 
    {
        if (animator && animator.isPlaying)
            return;
        super.mouseEventHandler(event);
    }
    
    /**
     *  @private
     *  If the thumb has moved, snap the it to the closest
     *  end of the track. If not, move it to the opposite end
     *  of where it is or was animating to.
     */
    override protected function buttonReleased():void 
    {
        if (animator && animator.isPlaying)
            return;
        var newPosition:Number;
        
        if (mouseMoved)
            // the result of a drag is the nearest current position
            newPosition = selectedToPosition(thumbPosition >= .5);
        else
            // the result of a click is the opposite side of the current
            // destination (not always the current value, as when animating)
            newPosition = selectedToPosition(slideToPosition < .5);
        
        moveToPosition(newPosition);
        mouseMoved = false;
    }
    
    //----------------------------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //----------------------------------------------------------------------------------------------
    
    /**
     *  These mouse handlers are responsible for ToggleSwitch's dragging
     *  behavior. The toggling behavior is handled by buttonReleased and
     *  ToggleButtonBase. 
     */
    private function mouseDownHandler(event:MouseEvent):void 
    {
        if (animator && animator.isPlaying)
            return;
        mouseMoved = false;
        stageOffset = new Point(event.stageX, event.stageY);
        positionOffset = thumbPosition;
    }
    
    /**
     *  Cache the most recent mouse position for use when the thinning code
     *  is called
     */
    private function mouseDragHandler(event:MouseEvent):void 
    {
        lastMouseX = event.stageX;
    }
    
    private function thinnedMouseDragHandler():void 
    {
        if (mouseCaptured && track && thumb) 
        {
            mouseMoved = true;
            var deltaX:Number = (lastMouseX - stageOffset.x) / getGlobalTrackRange();
            setThumbPosition(positionOffset + deltaX);
        }
    }
    
    /**
     *  We need to force a buttonRelease when mouse up occurs outside of
     *  the component, and the button has already released mouseCaptured
     */
    private function mouseUpHandler(event:Event):void 
    {
        // mouseCaptured unset from ButtonBase.systemManager_mouseUpHandler
        if (event.target != this && !mouseCaptured)
            buttonReleased();
    }
    
    /**
     *  Handles events from the Animation that runs the animated slide.
     *  We just update thumbPosition with the current animated value
     */
    private function animationUpdateHandler(animation:Animation):void
    {
        setThumbPosition(animation.currentValue["position"]);
    }
    
    /**
     *  Handles end event from the Animation that runs the animated slide.
     *  We update selected once the animation ends
     */
    private function animationEndHandler(animation:Animation):void
    {
        selected = positionToSelected(slideToPosition);
    }
    
}

}

//----------------------------------------------------------------------------------------------
//
//  Out-of-package Helper Classes
//
//----------------------------------------------------------------------------------------------

import spark.effects.animation.Animation;
import spark.effects.animation.IAnimationTarget;

/**
 *  @private
 *  simple helper implementation of IAnimationTarget
 */
class AnimationTargetHelper implements IAnimationTarget 
{
    public var updateFunction:Function;
    public var endFunction:Function;
    
    public function AnimationTargetHelper(updateFunction:Function, endFunction:Function)
    {
        this.updateFunction = updateFunction;
        this.endFunction = endFunction;
    }
    
    public function animationStart(animation:Animation):void
    {
    }
    
    public function animationEnd(animation:Animation):void
    {
        if (endFunction != null)
            endFunction(animation);
    }
    
    public function animationStop(animation:Animation):void
    {
    }
    
    public function animationRepeat(animation:Animation):void
    {
    }
    
    public function animationUpdate(animation:Animation):void
    {
        if (updateFunction != null)
            updateFunction(animation);
    }
}

import spark.utils.MouseEventUtil;
import flash.events.MouseEvent;
import flash.utils.Timer;
import mx.core.UIComponent;
import flash.events.TimerEvent;
import flash.events.Event;

/**
 *  @private
 *  A helper class responsible for handling mouse drag gestures,
 *  and ensuring we do not update on every mouse move event
 */
class MouseDragUtil 
{
    private var mouseDownHandler:Function;
    private var mouseMoveEveryHandler:Function;
    private var mouseMoveThinnedHandler:Function;
    private var mouseUpHandler:Function;
    private var target:UIComponent;
    
    private var dragPending:Boolean;
    private var dragTimer:Timer;
    
    private static const MAX_DRAG_RATE:Number = 30;
    
    public function MouseDragUtil(target:UIComponent, handleDown:Function, handleMove:Function,
                                  handleThinnedMove:Function, handleUp:Function) 
    {
        this.target = target;
        this.mouseDownHandler = handleDown;
        this.mouseMoveEveryHandler = handleMove;
        this.mouseMoveThinnedHandler = handleThinnedMove;
        this.mouseUpHandler = handleUp;
    }
    
    public function setupHandlers():void 
    {
        MouseEventUtil.addDownDragUpListeners(target, mouseDownHandlerWrapper, mouseDragHandlerWrapper, 
            mouseUpHandlerWrapper);
    }
    
    public function removeHandlers():void 
    {
        MouseEventUtil.removeDownDragUpListeners(target, mouseDownHandlerWrapper, mouseDragHandlerWrapper,
            mouseUpHandlerWrapper);
        if (dragTimer) {
            dragTimer.stop();
            dragTimer.removeEventListener(TimerEvent.TIMER, dragTimerHandler);
            dragTimer = null;
        }
    }
    
    private function mouseDownHandlerWrapper(event:MouseEvent):void 
    {
        mouseDownHandler(event);
    }
    
    private function mouseDragHandlerWrapper(event:MouseEvent):void 
    {
        mouseMoveEveryHandler(event);
        
        if (!dragTimer) 
        {
            dragTimer = new Timer(1000 / MAX_DRAG_RATE, 0);
            dragTimer.addEventListener(TimerEvent.TIMER, dragTimerHandler);
        }
        
        if (!dragTimer.running) 
        {
            mouseMoveThinnedHandler();
            event.updateAfterEvent();
            
            dragPending = false;
            dragTimer.start();
        } 
        else 
        {
            dragPending = true;
        }
    }
    
    private function dragTimerHandler(event:TimerEvent):void 
    {
        if (dragPending) 
        {
            mouseMoveThinnedHandler();
            event.updateAfterEvent();
            dragPending = false;
        } 
        else 
        {
            dragTimer.stop();
        }
    }
    
    private function mouseUpHandlerWrapper(event:Event):void 
    {
        if (dragTimer) 
        {
            if (dragPending) 
            {
                mouseMoveThinnedHandler();
                if (event is MouseEvent)
                    MouseEvent(event).updateAfterEvent();
                dragPending = false;
            }
            dragTimer.stop();
            dragTimer.removeEventListener(TimerEvent.TIMER, dragTimerHandler);
            dragTimer = null;
        }
        
        mouseUpHandler(event);
    }
}