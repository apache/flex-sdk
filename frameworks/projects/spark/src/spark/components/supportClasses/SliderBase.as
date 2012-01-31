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

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.utils.Timer;

import mx.core.IDataRenderer;
import mx.core.IFactory;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.formatters.NumberFormatter;
import mx.managers.IFocusManagerComponent;

import spark.effects.animation.Animation;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.effects.easing.Sine;
import spark.events.TrackBaseEvent;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

include "../../styles/metadata/BasicInheritingTextStyles.as"

/**
 *  The alpha of the focus ring for this component.
 *
 *  @default 0.55
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="focusAlpha", type="Number", inherit="no", theme="spark, mobile", minValue="0.0", maxValue="1.0")]

/**
 *  @copy spark.components.supportClasses.GroupBase#focusColor
 *
 *  @default 0xFFFFFF
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  When <code>true</code>, the thumb's value is
 *  committed as it is dragged along the track instead
 *  of when the thumb button is released.
 *  
 *  @default true
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="liveDragging", type="Boolean", inherit="no")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="color", kind="style")]
[Exclude(name="fontSize", kind="style")]
[Exclude(name="fontWeight", kind="style")]
[Exclude(name="textAlign", kind="style")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[AccessibilityClass(implementation="spark.accessibility.SliderBaseAccImpl")]

/**
 *  The SliderBase class lets users select a value by moving a slider thumb between 
 *  the end points of the slider track. 
 *  The current value of the slider is determined by the relative location of 
 *  the thumb between the end points of the slider, 
 *  corresponding to the slider's minimum and maximum values.
 *
 *  The SliderBase class is a base class for HSlider and VSlider.
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:SliderBase&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:SliderBase
 *    <strong>Properties</strong>
 *    dataTipFormatFunction="20"
 *    dataTipPrecision="2"
 *    maximum="10"
 *    showDataTip="true"
 * 
 *    <strong>Styles</strong>
 *    alignmentBaseline="USE_DOMINANT_BASELINE"
 *    baselineShift="0.0"
 *    cffHinting="HORIZONTAL_STEM"
 *    color="0"
 *    digitCase="DEFAULT"
 *    digitWidth="DEFAULT"
 *    direction="LTR"
 *    dominantBaseline="AUTO"
 *    focusAlph="0.55"
 *    focusColor="0xFFFFFF"
 *    fontFamily="Arial"
 *    fontLookup="DEVICE"
 *    fontSize="12"
 *    fontStyle="NORMAL"
 *    fontWeight="NORMAL"
 *    justificationRule="AUTO"
 *    justificationStyle="AUTO"
 *    kerning="AUTO"
 *    ligatureLevel="COMMON"
 *    lineHeight="120%"
 *    lineThrough="false"
 *    liveDragging="true"
 *    local="en"
 *    renderingMode="CFF"
 *    textAlignLast="START"
 *    textAlpha="1"
 *    textDecoration="NONE"
 *    textJustify="INTER_WORD"
 *    trackingLeft="0"
 *    trackingRight="0"
 *    typographicCase="DEFAULT"
 *  /&gt;
 *  </pre> 
 *  
 *  @see spark.components.HSlider
 *  @see spark.components.VSlider
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class SliderBase extends TrackBase implements IFocusManagerComponent
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class mixins
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Placeholder for mixin by SliderBaseAccImpl.
     */
    mx_internal static var createAccessibilityImplementation:Function;

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
    public function SliderBase():void
    {
        super();

        maximum = 10;
    }

    //--------------------------------------------------------------------------
    //
    //  Skin parts
    //
    //--------------------------------------------------------------------------

    [SkinPart(required="false", type="mx.core.IDataRenderer")]
    
    /**
     *  A skin part that defines a dataTip that displays a formatted version of 
     *  the current value. The dataTip appears while the thumb is being dragged.
     *  This is a dynamic skin part and must be of type IFactory.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var dataTip:IFactory; 

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var dataFormatter:NumberFormatter;

    /**
     *  @private
     */
    private var animator:Animation = null;
    
    /**
     *  @private
     */
    private var dataTipInitialPosition:Point;
    
    /**
     *  @private
     */
    private var dataTipInstance:IDataRenderer;

    /**
     *  @private
     */
    private var slideToValue:Number;
    
    /**
     *  @private
     */
    private var isKeyDown:Boolean = false;

    /**
     *  @private
     *  Location of the mouse down event on the thumb, relative to the thumb's origin.
     *  Used to update the value property when the mouse is dragged. 
     */
    private var clickOffset:Point;  
        
    /**
     *  @private
     *  Local coordinates of most recent mouse move.
     */
    private var mostRecentMousePoint:Point;
    
    /**
     *  @private
     *  Timer used to do drag scrolling.
     */
    private var dragTimer:Timer = null;
    
    /**
     *  @private
     *  True when there's a pending mouse move (stored in mostRecentMousePoint)
     *  that needs to be handled in the dragTimer handler. 
     */
    private var dragPending:Boolean = false;

    /**
     *  @private
     *  Maximum number of times per second we will change the slider position 
     *  and update the display while dragging.
     */
    private static const MAX_DRAG_RATE:Number = 30;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------    

    //---------------------------------
    //  maximum
    //---------------------------------   

    [Inspectable(category="General", defaultValue="10.0")]
    
    /**
     *  Number which represents the maximum value possible for 
     *  <code>value</code>. If the values for either 
     *  <code>minimum</code> or <code>value</code> are greater
     *  than <code>maximum</code>, they will be changed to 
     *  reflect the new <code>maximum</code>
     *
     *  @default 10
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function get maximum():Number
    {
        return super.maximum;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------    

    //--------------------------------- 
    //  dataTipformatFunction
    //---------------------------------

    /**
     *  @private
     */
    private var _dataTipFormatFunction:Function;
    
    /**
     *  Callback function that formats the data tip text.
     *  The function takes a single Number as an argument
     *  and returns a formatted String.
     *
     *  <p>The function has the following signature:</p>
     *  <pre>
     *  funcName(value:Number):Object
     *  </pre>
     *
     *  <p>The following example prefixes the data tip text with a dollar sign and 
     *  formats the text using the <code>dataTipPrecision</code> 
     *  of a SliderBase Control named 'slide': </p>
     *
     *  <pre>
     *  import mx.formatters.NumberBase;
     *  function myDataTipFormatter(value:Number):Object { 
     *      var dataFormatter:NumberBase = new NumberBase(".", ",", ".", ""); 
     *      return   "$ " + dataFormatter.formatPrecision(String(value), slide.dataTipPrecision); 
     *  }
     *  </pre>
     *
     *  @default undefined   
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get dataTipFormatFunction():Function
    {
        return _dataTipFormatFunction;
    }

    /**
     *  @private
     */
    public function set dataTipFormatFunction(value:Function):void
    {
        _dataTipFormatFunction = value;
    }
    
    //--------------------------------- 
    //  dataTipPrecision
    //---------------------------------

    [Inspectable(defaultValue="2", minValue="0")]
    
    /**
     *  Number of decimal places to use for the data tip text.
     *  A value of 0 means to round all values to an integer.
     *  This value is ignored if <code>dataTipFormatFunction</code> is defined.
     * 
     *  @default 2
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var dataTipPrecision:int = 2;
    
    //----------------------------------
    //  pendingValue
    //----------------------------------
    
    /**
     *  @private
     */
    private var _pendingValue:Number = 0;
    
    /**
     *  The value the slider will have when the mouse button is released. This property
     *  also holds the temporary values set during an animation of the thumb if
     *  the <code>liveDragging</code> style is true; the real value is only set
     *  when the animation ends.
     * 
     *  <p>If the <code>liveDragging</code> style is false, then the slider's value is only set
     *  when the mouse button is released. The value is not updated while the slider thumb is
     *  being dragged.</p>
     * 
     *  <p>This property is updated when the slider thumb moves, even if 
     *  <code>liveDragging</code> is false.</p>
     *  
     *  @default 0
     *  @return The value implied by the thumb position. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function get pendingValue():Number
    {
        return _pendingValue;
    }
    
    /**
     *  @private
     */
    protected function set pendingValue(value:Number):void
    {
        if (value == _pendingValue)
            return;
        _pendingValue = value;
        invalidateDisplayList();
    }
    
    //--------------------------------- 
    //  showDataTip
    //---------------------------------
    
    /**
     *  If set to <code>true</code>, shows a data tip during user interaction
     *  containing the current value of the slider. In addition, the skinPart,
     *  <code>dataTip</code>, must be defined in the skin in order to 
     *  display a data tip. 
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var showDataTip:Boolean = true;

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function initializeAccessibility():void
    {
        if (SliderBase.createAccessibilityImplementation != null)
            SliderBase.createAccessibilityImplementation(this);
    }

    /**
     *  @private
     */  
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        // Prevent focus on our children so that focus remains with the SliderBase
        if (instance == thumb)
            thumb.focusEnabled = false;
        else if (instance == track)
            track.focusEnabled = false;
    }
    
    /**
     *  @private
     */
    override public function drawFocus(isFocused:Boolean):void
    {
        // if there's a thumb, just draw focus on the thumb; 
        // otherwise, draw it on the whole component
        if (thumb)
        {
            thumb.drawFocusAnyway = true;
            thumb.drawFocus(isFocused);
        }
        else
        {
            super.drawFocus(isFocused);
        }
    }
    
    /**
     *  @private
     *  Keep the pendingValue in sync with the actual value so that updateSkinDisplayList()
     *  overrides can just use pendingValue.
     */
    override protected function setValue(value:Number):void
    {
        _pendingValue = value;

        super.setValue(value);
    }

    /**
     *  @private
     */
    override mx_internal function updateErrorSkin():void
    {
        // Don't draw the error skin
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Used to position the data tip when it is visible. Subclasses must implement
     *  this function. 
     *  
     *  @param dataTipInstance The <code>dataTip</code> instance to update and position
     *  @param initialPosition The initial position of the <code>dataTip</code> in the skin
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function updateDataTip(dataTipInstance:IDataRenderer, initialPosition:Point):void
    {
        // Override in the subclasses
    }

    /**
     *  @private
     *  Returns a formatted version of the value
     */
    private function formatDataTipText(value:Number):Object
    {
        var formattedValue:Object;
            
        if (dataTipFormatFunction != null)
        {
            formattedValue = dataTipFormatFunction(value); 
        }
        else
        {
            if (dataFormatter == null)
                dataFormatter = new NumberFormatter();
                
            dataFormatter.precision = dataTipPrecision;
            
            formattedValue = dataFormatter.format(value);   
        }
        
        return formattedValue;
    }
  
    /**
     *  @private
     *  Handles events from the Animation that runs the animated slide.
     *  We just call setValue() with the current animated value
     */
    private function animationUpdateHandler(animation:Animation):void
    {
        pendingValue = animation.currentValue["value"];
    }
    
    /**
     *  @private
     *  Handles end event from the Animation that runs the animated slide.
     *  We dispatch the "changeEnd" event at this time, after the animation
     *  is done since each animation occurs after a user interaction.
     */
    private function animationEndHandler(animation:Animation):void
    {
        setValue(slideToValue);
        
        dispatchEvent(new Event(Event.CHANGE));
        dispatchEvent(new FlexEvent(FlexEvent.CHANGE_END));
    }
    
    /**
     *  @private
     *  Stops a running animation prematurely and sets the value
     *  of the slider to the current pendingValue. We also dispatch
     *  a "changeEnd" event since the user has started another interaction.
     */
    private function stopAnimation():void
    {
        animator.stop();
        
        setValue(nearestValidValue(pendingValue, snapInterval));
        
        dispatchEvent(new Event(Event.CHANGE));
        dispatchEvent(new FlexEvent(FlexEvent.CHANGE_END));
    }
    
    //--------------------------------------------------------------------------
    // 
    //  Overridden event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function thumb_mouseDownHandler(event:MouseEvent):void
    {
        // finish previous animation
        if (animator && animator.isPlaying)
            stopAnimation();
        
        super.thumb_mouseDownHandler(event);
        clickOffset = thumb.globalToLocal(new Point(event.stageX, event.stageY));
                
        // Popup a dataTip only if we have a SkinPart and the boolean flag is true
        if (dataTip && showDataTip && enabled)
        {
            dataTipInstance = IDataRenderer(createDynamicPartInstance("dataTip"));
            
            dataTipInstance.data = formatDataTipText(
                nearestValidValue(pendingValue, snapInterval));
            
            var tipAsUIComponent:UIComponent = dataTipInstance as UIComponent;
            
            // Allow styles to be inherited from SliderBase.
            if (tipAsUIComponent)
            {
                tipAsUIComponent.owner = this;
                tipAsUIComponent.isPopUp = true;
            }

            systemManager.toolTipChildren.addChild(DisplayObject(dataTipInstance));
            
            // Force the dataTip to render so that we have the correct size since
            // updateDataTip might need the size
            if (tipAsUIComponent)
            {
                tipAsUIComponent.validateNow();
                tipAsUIComponent.setActualSize(tipAsUIComponent.getExplicitOrMeasuredWidth(),
                                               tipAsUIComponent.getExplicitOrMeasuredHeight());
            }
            
            dataTipInitialPosition = new Point(DisplayObject(dataTipInstance).x, 
                                                DisplayObject(dataTipInstance).y);   
            updateDataTip(dataTipInstance, dataTipInitialPosition);
        }
    }
    
    /**
     *  @private
     */
    private function handleMousePoint(p:Point):void
    {
        var newValue:Number = pointToValue(p.x - clickOffset.x, p.y - clickOffset.y);
        newValue = nearestValidValue(newValue, snapInterval);
        
        if (newValue != pendingValue)
        {
            dispatchEvent(new TrackBaseEvent(TrackBaseEvent.THUMB_DRAG));
            if (getStyle("liveDragging") === true)
            {
                setValue(newValue);
                dispatchEvent(new Event(Event.CHANGE));
            }
            else
            {
                pendingValue = newValue;
            }
        }
        
        if (dataTipInstance && showDataTip)
        { 
            dataTipInstance.data = formatDataTipText(pendingValue);
            
            // Force the dataTip to render so that we have the correct size since
            // updateDataTip might need the size
            var tipAsUIComponent:UIComponent = dataTipInstance as UIComponent; 
            if (tipAsUIComponent)
            {
                tipAsUIComponent.validateNow();
                tipAsUIComponent.setActualSize(tipAsUIComponent.getExplicitOrMeasuredWidth(),tipAsUIComponent.getExplicitOrMeasuredHeight());
            }

            updateDataTip(dataTipInstance, dataTipInitialPosition);
        }
    }

    /**
     *  @private
     */
    override protected function system_mouseMoveHandler(event:MouseEvent):void
    {      
        if (!track)
            return;

        mostRecentMousePoint = track.globalToLocal(new Point(event.stageX, event.stageY));
        if (!dragTimer)
        {
            dragTimer = new Timer(1000/MAX_DRAG_RATE, 0);
            dragTimer.addEventListener(TimerEvent.TIMER, dragTimerHandler);
        }
        
        if (!dragTimer.running)
        {
            // This changes the slider value and invalidates the display list.
            handleMousePoint(mostRecentMousePoint);
            event.updateAfterEvent();

            // Start the periodic timer that will do subsequent drag 
            // scrolling if necessary. 
            dragTimer.start();
            
            // No additional mouse events received yet, so no scrolling pending.
            dragPending = false;
        }
        else
        {
            dragPending = true;
        }
    }
        
    /**
     *  @private
     *  Used to periodically change the slider value during a drag gesture.
     */
    private function dragTimerHandler(event:TimerEvent):void
    {
        if (dragPending)
        {
            // This changes the slider value and invalidates the display list.
            handleMousePoint(mostRecentMousePoint);

            // Call updateAfterEvent() to make sure it looks smooth
            event.updateAfterEvent();
            
            // No scroll is pending now. 
            dragPending = false;
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
     */
    override protected function system_mouseUpHandler(event:Event):void
    {
        if (dragTimer)
        {
            if (dragPending)
            {
                // This changes the slider value and invalidates the display list.
                handleMousePoint(mostRecentMousePoint);
                
                // Call updateAfterEvent() to make sure it looks smooth
                if (event is MouseEvent)
                    MouseEvent(event).updateAfterEvent();
            }
            // The drag gesture is over, so we no longer need the timer.
            dragTimer.stop();
            dragTimer.removeEventListener(TimerEvent.TIMER, dragTimerHandler);
            dragTimer = null;
        }
        
        if ((getStyle("liveDragging") === false) && (value != pendingValue))
        {
            setValue(pendingValue);
            dispatchEvent(new Event(Event.CHANGE));
        }

        if (dataTipInstance)
        {
            removeDynamicPartInstance("dataTip", dataTipInstance);
            systemManager.toolTipChildren.removeChild(DisplayObject(dataTipInstance));
            dataTipInstance = null;
        }
        
        super.system_mouseUpHandler(event);
    }
    
    /**
     *  @private
     *  Handle keyboard events. Left/Down decreases the value
     *  decreases the value by stepSize. The opposite for
     *  Right/Up arrows. The Home and End keys set the value
     *  to the min and max respectively.
     *  
     *  We dispatch changing events when the keystroke 
     *  may both repeat and alter the value.
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        super.keyDownHandler(event);
       
        if (event.isDefaultPrevented())
            return;

        if (animator && animator.isPlaying)
            stopAnimation();
        
        var prevValue:Number = this.value;
        var newValue:Number;

        // If rtl layout, need to swap LEFT/UP and RIGHT/DOWN so correct action
        // is done.
        var keyCode:uint = mapKeycodeForLayoutDirection(event, true);
                                
        switch (keyCode)
        {
            case Keyboard.DOWN:
            case Keyboard.LEFT:
            {
                newValue = nearestValidValue(pendingValue - stepSize, snapInterval);
                
                if (prevValue != newValue)
                {
                    if (!isKeyDown)
                    {
                        dispatchEvent(new FlexEvent(FlexEvent.CHANGE_START));
                        isKeyDown = true;
                    }
                    setValue(newValue);
                    dispatchEvent(new Event(Event.CHANGE));
                }
                event.preventDefault();
                break;
            }

            case Keyboard.UP:
            case Keyboard.RIGHT:
            {
                newValue = nearestValidValue(pendingValue + stepSize, snapInterval);
                
                if (prevValue != newValue)
                {
                    if (!isKeyDown)
                    {
                        dispatchEvent(new FlexEvent(FlexEvent.CHANGE_START));
                        isKeyDown = true;
                    }
                    setValue(newValue);
                    dispatchEvent(new Event(Event.CHANGE));
                }
                event.preventDefault();
                break;
            }
            
            case Keyboard.HOME:
            {
                value = minimum;
                if (value != prevValue)
                    dispatchEvent(new Event(Event.CHANGE));
                event.preventDefault();
                break;
            }

            case Keyboard.END:
            {
                value = maximum;
                if (value != prevValue)
                    dispatchEvent(new Event(Event.CHANGE));
                event.preventDefault();
                break;
            }
        }
    }
    
    /**
     *  @private
     *  Handle keyboard release events. Allows us to send out changeEnd
     *  event.
     */
    override protected function keyUpHandler(event:KeyboardEvent) : void
    {
        switch (event.keyCode)
        {
            case Keyboard.DOWN:
            case Keyboard.LEFT:
            case Keyboard.UP:
            case Keyboard.RIGHT:
            {
                if (isKeyDown)
                {
                    // Dispatch "change" event only after a repeat occurs.
                    dispatchEvent(new FlexEvent(FlexEvent.CHANGE_END));
                    isKeyDown = false;
                }
                event.preventDefault();
                break;
            }
        }
    }
        
    /**
     *  @private
     *  Handle mouse-down events for the slider track. We
     *  calculate the value based on the new position and then
     *  move the thumb to the correct location as well as
     *  commit the value.
     */
    override protected function track_mouseDownHandler(event:MouseEvent):void
    {
        if (!enabled)
            return;
         
        // Offset the track-relative coordinates of this event so that
        // the thumb will end up centered over the mouse down location.
        var thumbW:Number = (thumb) ? thumb.width : 0;
        var thumbH:Number = (thumb) ? thumb.height : 0;
        var offsetX:Number = event.stageX - (thumbW / 2);
        var offsetY:Number = event.stageY - (thumbH / 2);
        var p:Point = track.globalToLocal(new Point(offsetX, offsetY));

        var newValue:Number = pointToValue(p.x, p.y);
        newValue = nearestValidValue(newValue, snapInterval);

        if (newValue != pendingValue)
        {
            var slideDuration:Number = getStyle("slideDuration");
            if (slideDuration != 0)
            {
                if (!animator)
                {
                    animator = new Animation();
                    var animTarget:AnimationTarget = new AnimationTarget(animationUpdateHandler);
                    animTarget.endFunction = animationEndHandler;
                    animator.animationTarget = animTarget;                    
                    // TODO (chaase): hard-coding easer for now - how to style it?
                    animator.easer = new Sine(0);
                }
                
                // Finish any current animation before we start the next one.
                if (animator.isPlaying)
                    stopAnimation();
                
                // holds the final value to be set when animation ends
                slideToValue = newValue;
                animator.duration = slideDuration * 
                    (Math.abs(pendingValue - slideToValue) / (maximum - minimum));
                animator.motionPaths = new <MotionPath>[
                    new SimpleMotionPath("value", pendingValue, slideToValue)];
                
                dispatchEvent(new FlexEvent(FlexEvent.CHANGE_START));
                animator.play();
            }
            else
            {
                setValue(newValue);
                dispatchEvent(new Event(Event.CHANGE));
            }
        }

        event.updateAfterEvent();
    }
}

}
