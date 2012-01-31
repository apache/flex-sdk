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

package spark.components.supportClasses
{
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;

import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;
import mx.events.ResizeEvent;
import mx.events.SandboxMouseEvent;

import spark.components.Button;
import spark.core.IViewport;
import spark.effects.animation.Animation;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.effects.easing.IEaser;
import spark.effects.easing.Linear;
import spark.effects.easing.Sine;

use namespace mx_internal;

/**
 *  The inactive state.
 *  This is the state when there is no content to scroll,
 *  which means <code>maximum</code> &lt;= <code>minimum</code>.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("inactive")]

/**
 *  @copy spark.components.supportClasses.GroupBase#symbolColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  If true, the thumb's size along the scrollbar's axis will be
 *  its preferred size.
 *  
 *  @default false
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="fixedThumbSize", type="Boolean", inherit="no")]

/**
 *  If true (the default), the thumb's visibility will be reset
 *  whenever its size is updated.  
 * 
 *  Overrides of <code>sizeThumb()</code> in <code>HScrollBar</code> and 
 *  <code>VScrollBar</code> make the thumb visible if it's smaller than
 *  the track, unless this style is false.   
 * 
 *  Set this style to false to control thumb visiblity directly.  
 * 
 *  @default true
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="autoThumbVisibility", type="Boolean", inherit="no")]

/**
 *  Number of milliseconds after the first page event
 *  until subsequent page events occur.
 * 
 *  @default 500
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="repeatDelay", type="Number", format="Time", inherit="no", minValue="0.0")]

/**
 *  Number of milliseconds between page events
 *  if the user presses and holds the mouse on the track.
 *  
 *  @default 35
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="repeatInterval", type="Number", format="Time", inherit="no", minValueExclusive="0.0")]

/**
 * This style determines whether the scrollbar will animate
 * smoothly when paging and stepping. When false, page and step
 * operations will jump directly to the paged/stepped locations. 
 * When true, the scrollbar, and any content it is scrolling, will
 * animate to that location.
 *  
 *  @default true
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="smoothScrolling", type="Boolean", inherit="no")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="focusBlendMode", kind="style")]
[Exclude(name="focusThickness", kind="style")]

/**
 *  The ScrollBar class helps to position
 *  the portion of data that is displayed when there is too much data
 *  to fit in a display area. 
 *  The ScrollBar class displays a pair of scrollbars and a viewport. 
 *  A viewport is a UIComponent that implements IViewport, such as Group.
 *  
 *  <p>This control extends the TrackBase class and
 *  is the base class for the HScrollBar and VScrollBar
 *  controls.</p> 
 * 
 *  <p>A scroll bar consists of a track, a variable-size scroll thumb, and 
 *  two optional arrow buttons. The ScrollBar class uses four parameters 
 *  to calculate its display state:</p>
 *
 *  <ul>
 *    <li><code>minimum</code>: Minimum range value.</li>
 *    <li><code>maximum</code>:Maximum range value.</li>
 *    <li><code>value</code>: Current position, which must be within the
 *    minimum and maximum range values.</li>
 *    <li>Viewport size: Represents the number of items
 *    in the range that you can display at one time. The
 *    number of items must be less than or equal to the 
 *    range, where the range is the set of values between
 *    the minimum range value and the maximum range value.</li>
 *  </ul>
 *
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:ScrollBar&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:ScrollBar
 *    <strong>Properties</strong>
 *    pageSize="20"
 *    snapInterval=""
 *    viewport="null"
 *
 *    <strong>Styles</strong>
 *    autoThumbVisibility="true"
 *    fixedThumbSize="false"
 *    repeatDelay="500"
 *    repeatInterval="35"
 *    smoothScrolling="true"
 *    symbolColor=""
 *  /&gt;
 *  </pre> 
 *  @see spark.core.IViewport
 *  @see spark.skins.spark.ScrollerSkin
 *  @see spark.skins.spark.ScrollBarDownButtonSkin
 *  @see spark.skins.spark.ScrollBarLeftButtonSkin
 *  @see spark.skins.spark.ScrollBarRightButtonSkin
 *  @see spark.skins.spark.ScrollBarUpButtonSkin
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ScrollBar extends TrackBase
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

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
     *  An optional skin part that defines a button 
     *  that, when pressed, steps the scrollbar up. 
     *  This is equivalent to a decreasing step to the <code>value</code> property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var decrementButton:Button;
    
    [SkinPart(required="false")]
    
    /**
     *  An optional skin part that defines a button 
     *  that, when pressed, steps the scrollbar down.
     *  This is equivalent
     *  to an increasing step to the <code>value</code> property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var incrementButton:Button;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     * this one animator is used by both paging and stepping animations. It
     * is responsible for running the repeated operation (animating from the beginning
     * of the repeat to whenever it ends or the user stops the repeating action).
     */
    private var _animator:Animation = null;
    private function get animator():Animation
    {
        if (_animator)
            return _animator;
        _animator = new Animation();
        var animTarget:AnimationTarget = new AnimationTarget(animationUpdateHandler);
        animTarget.endFunction = animationEndHandler;
        _animator.animationTarget = animTarget;
        return _animator;
    }
    
    /**
     * @private
     * These variables track whether we are currently involved in a stepping
     * animation, and which direction we are stepping
     */
    private var steppingDown:Boolean;
    private var steppingUp:Boolean;
    
    /**
     * @private
     * This variable tracks whether we are currently stepping the ScrollBar
     */
    private var isStepping:Boolean;

    /**
     * @private
     * This variable tracks whether we are currently running an animation to
     * do a single changeValueByPage() operation. This is used to end that operation properly
     * if another operation interrupts it.
     */ 
    private var animatingOnce:Boolean;
    
    /**
     * @private
     * Easers used in animated scrolling operations
     */
    private static var linearEaser:IEaser = new Linear();
    private static var easyInLinearEaser:IEaser = new Linear(.1);
    private static var deceleratingSineEaser:IEaser = new Sine(0);
    
    // FIXME (hmuller): transient?    
    // Direction indicator for current track-scrolling operations
    private var trackScrollDown:Boolean;
    
    // Timer used for repeated scrolling when mouse is held down on track
    private var trackScrollTimer:Timer;
    
    // FIXME (hmuller): transient?    
    // Cache current position on track for scrolling operations
    private var trackPosition:Point = new Point();
    
    // FIXME (hmuller): transient?    
    // Flag to indicate whether track-scrolling is in process
    private var trackScrolling:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties: Range
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Invalidate the skin state when minimum is changed.
     */
    override public function set minimum(value:Number):void
    {
        if (value == super.minimum)
            return;
        
        super.minimum = value;
        invalidateSkinState();
    }
    
    /**
     *  @private
     *  Invalidate the skin state when maximum is changed.
     */
    override public function set maximum(value:Number):void
    {
        if (value == super.maximum)
            return;
        
        super.maximum = value;
        invalidateSkinState();
    }
    
    [Inspectable(minValue="0.0")]
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
     override public function set snapInterval(value:Number):void
    {
        super.snapInterval = value;
        
        // setting snapInterval may change the pageSize
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

    [Inspectable(minValue="0.0")]

    /**
     *  The change in the value of the <code>value</code> property 
     *  when you call the <code>changeValueByPage()</code> method.
     *
     *  @default 20
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get pageSize():Number
    {
        return _pageSize;
    }

    /**
     *  @private
     */
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
    
    /**
     *  The viewport controlled by this scrollbar.
     * 
     *  If a viewport is specified, then changes to its actual size, content 
     *  size, and scroll position cause the corresponding ScrollBar methods to
     *  run:
     *  <ul>
     *  <li><code>viewportResizeHandler()</code></li>
     *  <li><code>contentWidthChangeHandler()</code></li>
     *  <li><code>contentHeightChangeHandler()</code></li>
     *  <li><code>viewportVerticalScrollPositionChangeHandler()</code></li>
     *  <li><code>viewportHorizontalScrollPositionChangeHandler()</code></li>
     *  </ul>
     * 
     *  <p>The VScrollBar and HScrollBar classes override these methods to 
     *  keep their <code>pageSize</code>, <code>maximum</code>, and <code>value</code> properties in sync with the
     *  viewport. Similarly, they override their <code>changeValueByPage()</code> and <code>changeValueByStep()</code> methods to
     *  use the viewport's <code>scrollPositionDelta</code> methods to compute page and
     *  and step offsets.</p>
     *    
     *  @default null
     *  @see spark.components.VScrollBar
     *  @see spark.components.HScrollBar
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get viewport():IViewport
    {
        return _viewport;
    }
    
    /**
     *  @private
     */
    public function set viewport(value:IViewport):void
    {
        if (value == _viewport)
            return;
            
        if (_viewport)  // old _viewport
        {
            _viewport.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
            _viewport.removeEventListener(ResizeEvent.RESIZE, viewportResizeHandler);
            _viewport.clipAndEnableScrolling = false;
        }

        _viewport = value;

        if (_viewport)  // new _viewport
        {
            _viewport.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
            _viewport.addEventListener(ResizeEvent.RESIZE, viewportResizeHandler);
            _viewport.clipAndEnableScrolling = true;
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
    private function startAnimation(duration:Number, valueTo:Number, 
        easer:IEaser, startDelay:Number = 0):void
    {
        animator.stop();
        animator.duration = duration;
        animator.easer = easer;
        animator.motionPaths = new <MotionPath>[
            new SimpleMotionPath("value", value, valueTo)];
        animator.startDelay = startDelay;
        animator.play();
    }
    
    /**
     *  @private
     *  Returns the integer multiple of snapInterval that's closest to size.
     * 
     *  <p>If snapInterval is 0, which means that values are only constrained
     *  by the minimum and maximum properties, then size is returned unchanged.</p>
     * 
     *  <p>This method is used by commitProperties() to validate the 
     *  pageSize.  There's a copy of this method in Range.as</p>
     * 
     *  @param size The input size.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private function nearestValidSize(size:Number):Number
    {
        var interval:Number = snapInterval;
        if (interval == 0)
            return size;
        
        var validSize:Number = Math.round(size / interval) * interval
        return (Math.abs(validSize) < interval) ? interval : validSize;
    }

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (pageSizeChanged)
        {
            _pageSize = nearestValidSize(_pageSize);
            pageSizeChanged = false;
        }
    }
        
    /**
     *  @private
     */
    override protected function getCurrentSkinState():String
    {
        if (maximum <= minimum)
            return "inactive";
        
        return super.getCurrentSkinState();
    }
    
    /**
     *  @private
     */    
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == decrementButton)
        {
            decrementButton.addEventListener(FlexEvent.BUTTON_DOWN,
                                             button_buttonDownHandler);
            decrementButton.addEventListener(MouseEvent.ROLL_OVER,
                                             button_rollOverHandler);
            decrementButton.addEventListener(MouseEvent.ROLL_OUT,
                                             button_rollOutHandler);
            decrementButton.autoRepeat = true;
        }
        else if (instance == incrementButton)
        {
            incrementButton.addEventListener(FlexEvent.BUTTON_DOWN,
                                             button_buttonDownHandler);
            incrementButton.addEventListener(MouseEvent.ROLL_OVER,
                                             button_rollOverHandler);
            incrementButton.addEventListener(MouseEvent.ROLL_OUT,
                                             button_rollOutHandler);
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
            decrementButton.removeEventListener(FlexEvent.BUTTON_DOWN,
                                                button_buttonDownHandler);
            decrementButton.removeEventListener(MouseEvent.ROLL_OVER,
                                                button_rollOverHandler);
            decrementButton.removeEventListener(MouseEvent.ROLL_OUT,
                                                button_rollOutHandler);
        }
        else if (instance == incrementButton)
        {
            incrementButton.removeEventListener(FlexEvent.BUTTON_DOWN,
                                                button_buttonDownHandler);
            incrementButton.removeEventListener(MouseEvent.ROLL_OVER,
                                                button_rollOverHandler);
            incrementButton.removeEventListener(MouseEvent.ROLL_OUT,
                                                button_rollOutHandler);
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
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);
        if (styleProp == "autoThumbVisibility")
            invalidateDisplayList();
    }

    /**
     *  Adds or subtracts <code>pageSize</code> from <code>value</code>.
     *  For an addition, the new <code>value</code> is the closest multiple of <code>pageSize</code> 
     *  that is larger than the current <code>value</code>.
     *  For a subtraction, the new <code>value</code> 
     *  is the closest multiple of <code>pageSize</code> that is 
     *  smaller than the current value. 
     *  The minimum value of <code>value</code> is <code>pageSize</code>. 
     *
     *  @param increase Whether the paging action adds (<code>true</code>) or
     *  decreases (<code>false</code>) <code>value</code>. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function changeValueByPage(increase:Boolean = true):void
    {
        var val:Number;
        if (increase)
            val = Math.min(value + pageSize, maximum);
        else
            val = Math.max(value - pageSize, minimum);
        if (getStyle("smoothScrolling"))
        {
            startAnimation(getStyle("repeatInterval"), val, linearEaser);
        }
        else
        {
            setValue(val);
            dispatchEvent(new Event(Event.CHANGE));
        }
    }

    //--------------------------------------------------------------------------
    // 
    // Event Handlers
    //
    //--------------------------------------------------------------------------

    //---------------------------------
    // Viewport property changes
    //---------------------------------
     
    private function viewport_propertyChangeHandler(event:PropertyChangeEvent):void
    {
        switch(event.property) 
        {
            case "contentWidth": 
                viewportContentWidthChangeHandler(event);
                break;
                
            case "contentHeight": 
                viewportContentHeightChangeHandler(event);
                break;
                
            case "horizontalScrollPosition":
                viewportHorizontalScrollPositionChangeHandler(event);
                break;

            case "verticalScrollPosition":
                viewportVerticalScrollPositionChangeHandler(event);
                break;
        }
    }
    
    
   /**
    *  @private
    *  Called when the viewport's width or height value changes. Does nothing by default.
    */
    mx_internal function viewportResizeHandler(event:ResizeEvent):void
    {
    }
    
   /**
    *  @private
    *  Called when the viewport's <code>contentWidth</code> value changes. Does nothing by default.
    */
    mx_internal function viewportContentWidthChangeHandler(event:PropertyChangeEvent):void
    {
    }
    
    /**
     *  @private 
     *  Called when the viewport's <code>contentHeight</code> value changes. Does nothing by default.
     */
    mx_internal function viewportContentHeightChangeHandler(event:PropertyChangeEvent):void
    {
    }
    
    /**
     *  @private
     *  Called when the viewport's <code>horizontalScrollPosition</code> value changes. Does nothing by default.
     */
    mx_internal function viewportHorizontalScrollPositionChangeHandler(event:PropertyChangeEvent):void
    {
    }  
    
    /**
     *  @private
     *  Called when the viewport's <code>verticalScrollPosition</code> value changes. Does nothing by default. 
     */
    mx_internal function viewportVerticalScrollPositionChangeHandler(event:PropertyChangeEvent):void
    {
    }   
    
    //---------------------------------
    // Thumb dragging handlers
    //---------------------------------
    
    /**
     *  @private
     */
    override protected function thumb_mouseDownHandler(event:MouseEvent) : void
    {
        // Stop animation before thumb dragging
        stopAnimation();
        
        super.thumb_mouseDownHandler(event);
    }
    
    //---------------------------------
    // Mouse up/down handlers
    //---------------------------------
     
    /**
     *  Handles a click on the increment or decrement button of the scroll bar. 
     *  This should cause a stepping operation, which is repeated if held down.
     *  The delay before repetition begins and the delay between repeated events
     *  are determined by the <code>repeatDelay</code> and 
     *  <code>repeatInterval</code> styles of the underlying Button objects.
     * 
     *  @see spark.components.Button
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4  
     */
    protected function button_buttonDownHandler(event:Event):void
    {
        // Make sure we finish any running page animation before starting
        // to step.
        if (!isStepping)
            stopAnimation();
        
        var increment:Boolean = (event.target == incrementButton);
        
        // Dispatch changeStart for the first step if we can make a step.
        if (!isStepping && 
            ((increment && value < maximum) ||
                (!increment && value > minimum)))
        {
            dispatchEvent(new FlexEvent(FlexEvent.CHANGE_START));
            isStepping = true;
            systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, 
                button_buttonUpHandler, true);
            systemManager.getSandboxRoot().addEventListener(
                SandboxMouseEvent.MOUSE_UP_SOMEWHERE, button_buttonUpHandler);
        }
        
        // Noop if we're currently running a stepping animation. We get
        // called repeatedly here due to the button's autoRepeat
        if (!steppingDown && !steppingUp)
        {
            // FIXME (chaase): first step is non-animated, just to simplify the delayed
            // start of the animated stepping. Seems okay, but worth thinking
            // about whether we should animate the first step too
            changeValueByStep(increment);
            
            // Only animate if smoothScrolling enabled and we're not at the end already
            if (getStyle("smoothScrolling") &&
                ((increment && value < maximum) ||
                 (!increment && value > minimum)))
            {
                // FIXME (chaase): what's a reasonable stepSize? Can't use viewport's because
                // it can vary widely depending on what items are in the view. Can't use
                // default stepSize because it can be quite small if not changed by
                // the scroller. 1/10th of pageSize seems reasonable, but will result
                // in a different total duration with animated vs. non-animated stepping
                animateStepping(increment ? maximum : minimum, pageSize/10);
            }
            return;
        }
    }
    
    /**
     *  Handles releasing the increment or decrement button of the scrollbar. 
     *  This ends the stepping operation started by the original buttonDown
     *  event on the button.
     *
     *  @see spark.components.Button
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4  
     
     */
    protected function button_buttonUpHandler(event:Event):void
    {
        if (steppingDown || steppingUp)
        {
        	// stopAnimation will not dispatch a changeEnd.
            stopAnimation();
            
            dispatchEvent(new FlexEvent(FlexEvent.CHANGE_END));
            
            steppingUp = steppingDown = false;
            isStepping = false;
        }
        else if (isStepping)
        {
            // Dispatch changeEnd event for no animation case
            dispatchEvent(new FlexEvent(FlexEvent.CHANGE_END));
            isStepping = false;
        }
        
        systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP, 
            button_buttonUpHandler, true);
        systemManager.getSandboxRoot().removeEventListener(
            SandboxMouseEvent.MOUSE_UP_SOMEWHERE, button_buttonUpHandler);
    }
    
    //---------------------------------
    // Track dragging handlers
    //---------------------------------
    
    /**
     *  @private
     *  Handle mouse-down events for the scroll track. In our handler,
     *  we figure out where the event occurred on the track and begin
     *  paging the scroll position toward that location. We start a 
     *  timer to handle repeating events if the user keeps the button
     *  pressed on the track.
     */
    override protected function track_mouseDownHandler(event:MouseEvent):void
    {
        // FIXME (chaase): We might want a different event mechanism eventually
        // which would push this enabled check into the child/skin components
        if (!enabled)
            return;

        // Make sure we finish any running page animation before starting
        // a new one.
        stopAnimation();
        
        // Cache original event location for use on later repeating events
        trackPosition = track.globalToLocal(new Point(event.stageX, event.stageY));
        
        // If the user shift-clicks on the track, then offset the event coordinates so 
        // that the thumb ends up centered under the mouse.
        if (event.shiftKey)
        {
            var thumbW:Number = (thumb) ? thumb.getLayoutBoundsWidth() : 0;
            var thumbH:Number = (thumb) ? thumb.getLayoutBoundsHeight() : 0;
            trackPosition.x -= (thumbW / 2);
            trackPosition.y -= (thumbH / 2);        
        }

        var newScrollValue:Number = pointToValue(trackPosition.x, trackPosition.y);
        trackScrollDown = (newScrollValue > value);
        
        if (event.shiftKey)
        {
            // shift-click positions jumps to the clicked location instead
            // of incrementally paging
            var slideDuration:Number = getStyle("slideDuration");
            var adjustedValue:Number = nearestValidValue(newScrollValue, snapInterval);
            if (getStyle("smoothScrolling") && 
                slideDuration != 0 && 
                (maximum - minimum) != 0)
            {
                dispatchEvent(new FlexEvent(FlexEvent.CHANGE_START));
                // Animate the shift-click operation
                startAnimation(slideDuration * 
                    (Math.abs(value - newScrollValue) / (maximum - minimum)),
                    adjustedValue, deceleratingSineEaser);
                animatingOnce = true;
            }
            else
            {
                setValue(adjustedValue);
                dispatchEvent(new Event(Event.CHANGE));
            }
            return;
        }
        
        dispatchEvent(new FlexEvent(FlexEvent.CHANGE_START));
        // Assume we're repeating unless user releases 
        animatingOnce = false;
        
        changeValueByPage(trackScrollDown);
        
        trackScrolling = true;

        // Add event handlers for drag and up events        
        systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_MOVE, 
            track_mouseMoveHandler, true);      
        systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, 
            track_mouseUpHandler, true);
        systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, 
            track_mouseUpHandler);

        // FIXME (chaase): consider using the repeat behavior of Button
        // to handle track-down repetition, instead of doing it with a
        // custom Timer. As long as we can distinguish the first
        // down event from subsequent ones, we may be able to just let
        // Button do most of this work.
        // Start a timer to handle repeating events if the user
        // continues to hold the mouse button down
        if (!trackScrollTimer)
        {
            trackScrollTimer = new Timer(getStyle("repeatDelay"), 1);
            trackScrollTimer.addEventListener(TimerEvent.TIMER, 
                                              trackScrollTimerHandler);
        } 
        else
        {
            // Note that this behavior, resetting the initial delay, differs 
            // from Flex3 but is more consistent with general application
            // scrollbar behavior
            trackScrollTimer.delay = getStyle("repeatDelay");
            trackScrollTimer.repeatCount = 1;
        }
        trackScrollTimer.start();
    }

    /**
     * Animates the operation to move to <code>newValue</code>.
     * The <code>pageSize</code> parameter is used to compute the amount 
     * of time taken to get to that value, so that the time taken to animate
     * a paging operation is roughly the same as the non-animated version; 
     * both operations should end up at the same place at about the same time.
     *
     * @param newValue The final value being paged to.
     * @param pageSize The amount of horizontal or vertical movement requested.
     * This value is used to compute, with the <code>repeatInterval</code> style,
     * the total time taken to move to the new value. <code>pageSize</code>
     * is usually set dynamically by the containing Scroller to the value required
     * to view content at a logical content boundary.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function animatePaging(newValue:Number, pageSize:Number):void
    {
        animatingOnce = false;
        // FIXME (chaase): hard-coding easing behavior, how to style it?
        startAnimation(
            getStyle("repeatInterval") * (Math.abs(newValue - value) / pageSize),
            newValue, linearEaser);
    }

    /**
     * Animates the operation to step to <code>newValue</code>.
     * The <code>stepSize</code> parameter is used to compute the amount 
     * of time taken to get to that value, so that the time taken to animate
     * a stepping operation is roughly the same as the non-animated version; 
     * both operations should end up at the same place at about the same time.
     *
     * @param newValue The final value being stepped to.
     * @param stepSize The amount of stepping requested.
     * This value is used to compute, with the <code>repeatInterval</code> style,
     * the total time taken to step to the new value. <code>stepSize</code>
     * is usually set dynamically by the containing Scroller to the value required
     * to view content at a logical content boundary.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    
    protected function animateStepping(newValue:Number, stepSize:Number):void
    {
        steppingDown = (newValue > value);
        steppingUp = !steppingDown;
        var denominator:Number = (stepSize != 0) ? stepSize : 1; // avoid div-by-0 below
        var duration:Number = getStyle("repeatInterval") * 
            (Math.abs(newValue - value) / denominator);
        // Cap ease-in factor to 500 ms on long-duration animations
        var easer:IEaser;
        if (duration > 5000)
            easer = new Linear(500/duration);
        else
            easer = easyInLinearEaser;
        // FIXME (chaase): we're using ScrollBar's repeatInterval for animated
        // stepping, but Button's repeatInterval for non-animated stepping
        // FIXME (chaase): think about the total duration for the animation.
        // FIXME (chaase): hard-coding easing behavior, how to style it?
        startAnimation(duration, newValue, easer, getStyle("repeatDelay"));
    }

    /**
     * @private
     * Handles events from the Animation that runs the page, step,
     * and shift-click smooth-scrolling operations.
     * Just call setValue() with the current animated value.
     */
    private function animationUpdateHandler(animation:Animation):void
    {
        // TODO (klin): Add support to send change events at the right intervals.
        setValue(animation.currentValue["value"]);
    }
    
    /**
     * @private
     * Handles end event from the Animation that runs the page, step,
     * and shift-click animations.
     * We dispatch the "change" event at this time, after the animation
     * is done.
     */
    private function animationEndHandler(animation:Animation):void
    {
        if (trackScrolling)
            trackScrolling = false;

        // End stepping animation
        if (steppingDown || steppingUp)
        {
            // If we're animating stepping, end on a final real step call in the
            // appropriate direction, ensuring that we stop on a content 
            // item boundary 
            changeValueByStep(steppingDown);

            animator.startDelay = 0;
            return;
        }
        
        // End paging or shift-click animation.
        setValue(nearestValidValue(this.value, snapInterval));
        dispatchEvent(new Event(Event.CHANGE));
        
        // We only dispatch the changeEnd event in the endHandler
        // for paging when we are not repeating.
        if (animatingOnce)
        {
            dispatchEvent(new FlexEvent(FlexEvent.CHANGE_END));
            animatingOnce = false;
        }
    }
    
    /**
     *  @private
     *  Stops a running animation prematurely and calls the 
     *  animationEndHandler.
     */
    private function stopAnimation():void
    {
        if (animator.isPlaying)
            animationEndHandler(animator);
        
        // Stop it regardless, in case the animation is startDelayed and
        // thus not 'playing', but still active
        animator.stop();
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
        var newScrollValue:Number = pointToValue(trackPosition.x, trackPosition.y);
        var fixedThumbSize:Boolean = getStyle("fixedThumbSize") !== false;

        // The end result we want, with either animated or non-animated paging,
        // is for the thumb to end up under the click point.
        // For the fixedThumbSize case, where the thumb may be much smaller
        // than the pageSize, we instead want the thumb to end up
        // where it would in the variable size case (on a lower value than the 
        // clicked value), but to end up at the end of the track if it is
        // "close enough" to the end. The heuristic for "close enough" is
        // if the end of the track is the nearestValidValue on pageSize
        // boundaries.
        if (trackScrollDown)
        {
            var range:Number = maximum - minimum;
            if (range == 0)
                return;
            
            if ((value + pageSize) > newScrollValue &&
                (!fixedThumbSize || nearestValidValue(newScrollValue, pageSize) != maximum))
                    return;
        }
        else if (newScrollValue > value)
        {
            return;
        }

        if (getStyle("smoothScrolling"))
        {
            // This gets called after an initial repeateDelay on a paging
            // operation, but after that we're just running the animation. This
            // function is only called repeatedly in the non-smoothScrolling case.
            var valueDelta:Number = Math.abs(value - newScrollValue);
            var pages:int;
            var pageToVal:Number;
            if (newScrollValue > value)
            {
                pages = pageSize != 0 ? 
                    int(valueDelta / pageSize) :
                    valueDelta;
                if (fixedThumbSize && nearestValidValue(newScrollValue, pageSize) == maximum)
                    pageToVal = maximum;
                else
                    pageToVal = value + (pages * pageSize);
            }
            else
            {
                pages = pageSize != 0 ? 
                    int(Math.ceil(valueDelta / pageSize)) :
                    valueDelta;
                pageToVal = Math.max(minimum, value - (pages * pageSize));
            }
            animatePaging(pageToVal, pageSize);
            return;
        }

        var oldValue:Number = value;
        
        changeValueByPage(trackScrollDown);

        if (trackScrollTimer && trackScrollTimer.repeatCount == 1)
        {
            // If this was the first time repeating, set the Timer to
            // repeat indefinitely with an appropriate interval delay
            trackScrollTimer.delay = getStyle("repeatInterval");
            trackScrollTimer.repeatCount = 0;
        }
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
    private function track_mouseUpHandler(event:Event):void
    {
        trackScrolling = false;
        
        systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_MOVE, 
            track_mouseMoveHandler, true);      
        systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP, 
            track_mouseUpHandler, true);
        systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, 
            track_mouseUpHandler);

        // First, we check for smoothScrolling and also if we are
        // in the non-repeating case.
        if (getStyle("smoothScrolling"))
        {
            if (!animatingOnce)
            {
                // We check the timer to see if the user released the mouse
                // before the repeat delay has expired.
                if (trackScrollTimer && trackScrollTimer.running)
                {
                    // If the animation has not yet finished before the repeat delay
                    // we set animatingOnce to true. Otherwise, the animation
                    // is done but repeating has not begun so we dispatch a changeEnd
                    // event.
                    if (animator.isPlaying)
                        animatingOnce = true;
                    else
                        dispatchEvent(new FlexEvent(FlexEvent.CHANGE_END));
                }
                else
                {
                    // repeating case
                    stopAnimation();
                    dispatchEvent(new FlexEvent(FlexEvent.CHANGE_END));
                }
            }
        }
        else
        {
            // Dispatch changeEnd if there's no animation.
            dispatchEvent(new FlexEvent(FlexEvent.CHANGE_END));
        }
        
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
        // TODO (klin): Fix up roll over/roll out handling so that
        // it works with animation.
        if (trackScrolling && trackScrollTimer)
            trackScrollTimer.start();
    }
    
    /**
     *  @private
     *  Stop the track-scrolling repeat events if the mouse leaves
     *  the track area.
     */
    private function track_rollOutHandler(event:MouseEvent):void
    {
        if (trackScrolling && trackScrollTimer)
            trackScrollTimer.stop();
    }
    
    /**
     *  @private
     *  Resume the increment/decrement animation if the mouse enters the
     *  button area
     */
    private function button_rollOverHandler(event:MouseEvent):void
    {
        if (steppingUp || steppingDown)
            animator.resume();
    }
    
    /**
     *  @private
     *  Pause the increment/decrement animation if the mouse leaves the
     *  button area
     */
    private function button_rollOutHandler(event:MouseEvent):void
    {
        if (steppingUp || steppingDown)
            animator.pause();
    }
}

}