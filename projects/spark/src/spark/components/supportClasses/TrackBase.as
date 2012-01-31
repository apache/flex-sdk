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
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.geom.Point;

import spark.components.Button;
import spark.events.TrackBaseEvent;

/**
 *  Dispatched when the value of the control changes
 *  as a result of user interaction.
 *
 *  @eventType flash.events.Event.CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="change", type="flash.events.Event")]

/**
 *  Dispatched when the thumb is pressed and then moved by the mouse.
 *  This event is always preceded by a <code>thumbPress</code> event.
 * 
 *  @eventType spark.events.TrackBaseEvent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="thumbDrag", type="spark.events.TrackBaseEvent")]

/**
 *  Dispatched when the thumb is pressed, meaning
 *  the user presses the mouse button over the thumb.
 *
 *  @eventType mx.events.SliderEvent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="thumbPress", type="spark.events.TrackBaseEvent")]

/**
 *  Dispatched when the thumb is released, 
 *  meaning the user releases the mouse button after 
 *  a <code>thumbPress</code> event.
 *
 *  @eventType mx.events.SliderEvent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="thumbRelease", type="spark.events.TrackBaseEvent")]

/**
 *  Normal State
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("normal")]

/**
 *  Disabled State
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("disabled")]

/**
 *  Duration in milliseconds for a sliding animation
 *  when you click on the track to move a thumb. This style is
 *  used for both Sliders and Scrollbars. For Sliders, any click
 *  on the track will cause an animation using this style, as the thumb
 *  will move to the clicked position. For ScrollBars, this style is
 *  used only when shift-clicking on the track, which causes the thumb
 *  to move to the clicked position. Clicking on a ScrollBar track when
 *  the shift key is not pressed will result in paging behavior instead.
 *  The <code>smoothScrolling</code> style must also be set on the
 *  ScrollBar to get animated behavior when shift-clicking.
 *  
 * <p>This time is for an animation that covers the entire distance of the 
 * track; smaller distances will use a proportionally smaller duration.</p>
 *
 *  @default 300
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="slideDuration", type="Number", format="Time", inherit="no")]

/**
 *  The TrackBase class is a base class for components with a track
 *  and one or more thumb buttons, such as Slider and ScrollBar. It
 *  declares two required skin parts: <code>thumb</code> and
 *  <code>track</code>. 
 *  The TrackBase class also provides the code for
 *  dragging the thumb button, which is shared by the Slider and ScrollBar classes.
 * 
 *  @see mx.components.baseClasses.Slider
 *  @see mx.components.baseClasses.ScrollBar
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class TrackBase extends Range
{
    include "../../core/Version.as";

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
    public function TrackBase():void
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    // Skins
    //
    //--------------------------------------------------------------------------

    [SkinPart(required="true")]
    
    /**
     *  A skin part that defines a button
     *  that can be dragged along the track to increase or
     *  decrease the <code>value</code> property.
     *  Updates to the <code>value</code> property 
     *  automatically update the position of the thumb button
     *  with respect to the track.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var thumb:Button;
    
    [SkinPart(required="true")]
    
    /**
     *  A skin part that defines a button
     *  that when  pressed sets the <code>value</code> property
     *  to the value corresponding with the current button position on the track.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var track:Button; 

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var tempTrackSize:Number = NaN;

    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent, Range
    //
    //--------------------------------------------------------------------------
 
    //---------------------------------
    // enabled
    //---------------------------------     
    
    /**
     *  Enable (<code>true</code>) or disable (<code>false</code>) this component. 
     *  This property also enables and disables any of the 
     *  skin parts for this component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function get enabled():Boolean
    {
        return super.enabled;
    }
    
    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
    {
        if (value == super.enabled)
            return;
        
        super.enabled = value;
        enableSkinParts(value);
        invalidateSkinState();
    }
    
    //---------------------------------
    // maximum
    //---------------------------------     
    
    /**
     *  @private
     *  Overidden so that this property can be the source of a binding expression.
     */
     override public function get maximum():Number
     {
         return super.maximum;
     }
    
    /**
     *  @private
     */
    override public function set maximum(value:Number):void
    {
        if (value == super.maximum)
            return;
        
        super.maximum = value;
        invalidateDisplayList();
    }

    //---------------------------------
    // minimum
    //---------------------------------     

    /**
     *  @private
     *  Overidden so that this property can be the source of a binding expression.
     */
     override public function get minimum():Number
     {
         return super.minimum;
     }
     
    /**
     *  @private
     */
    override public function set minimum(value:Number):void
    {
        if (value == super.minimum)
            return;
        
        super.minimum = value;
        invalidateDisplayList();
    }
    
    //---------------------------------
    // value
    //---------------------------------     

    [Bindable(event="valueCommit")]  // Warning: must match the Bindable tag in Range
    
    /**
     *  @private 
     *  Overidden so that this property can be the source of a binding expression.
     */
    override public function get value():Number
    {
        return super.value;
    }

    /**
     *  @private
     */
    override public function set value(newValue:Number):void
    {
        if (newValue == super.value)
            return;
        
        super.value = newValue;
        invalidateDisplayList();
    }
  
    /**
     *  @private
     */
    override protected function setValue(value:Number):void
    {
        super.setValue(value);
        invalidateDisplayList();
    }
    
    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------

    //---------------------------------
    // clickOffset
    //---------------------------------
    
    private var _clickOffset:Point;
    
    /**
     *  The point in the local coordinates of 
     *  the thumb button where the last mouse down event occurred. 
     *  This property is used by the <code>calculateNewValue()</code> method 
     *  to determine the value that the thumb button has been dragged to.
     *
     *  @return Point object rerpresenting, in the local coordinates of 
     *  the thumb button, where the last mouse down event occurred. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function get clickOffset():Point
    {
        return _clickOffset;
    }

    //---------------------------------
    // trackSize
    //---------------------------------
    
    /**
     *  The size of the logical track. 
     *  Subclasses need to override this method to return 
     *  an appropriate value. 
     *
     *  <p>Note that this number can 
     *  represent any system of units, but those units must 
     *  be consistent with the values returned by the 
     *  <code>pointToPosition()</code>, <code>calculateThumbSize()</code>, 
     *  and <code>valueToPosition()</code> methods.</p>
     *
     *  @return The size of the logical track. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function get trackSize():Number
    {
        return 0;
    }
    
    //---------------------------------
    // thumbSize
    //---------------------------------
    
    private var _thumbSize:Number = 0;
    
    /**
     *  The size of the thumb button on the logical track in the 
     *  units of the subclass, which must be consistent with 
     *  <code>trackSize</code> property, and with 
     *  the <code>pointToPosition()</code> and <code>valueToPosition()</code> methods. 
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function get thumbSize():Number
    {
        return _thumbSize;
    }
    
    /**
     *  @private
     */
    protected function set thumbSize(value:Number):void
    {
        if (value == _thumbSize)
            return;

        _thumbSize = value;
    }
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function step(increase:Boolean = true):void
    {
        var prevValue:Number = this.value;
        
        super.step(increase);
        
        if (value != prevValue)
            dispatchEvent(new Event("change"));
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, 
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        if (thumb)
        {
            thumbSize = calculateThumbSize();
            sizeThumb(thumbSize);
    
            positionThumb(valueToPosition(value));
        }
    }

    /**
     *  @private   
     */
    override protected function getCurrentSkinState():String
    {
        return enabled ? "normal" : "disabled";
    }
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        if (instance == thumb)
        {
            thumb.addEventListener(MouseEvent.MOUSE_DOWN,
                                   thumb_mouseDownHandler);
            thumb.stickyHighlighting = true;
        }
        else if (instance == track)
        {
            track.addEventListener(MouseEvent.MOUSE_DOWN,
                                   track_mouseDownHandler);
            track.addEventListener("updateComplete", 
                                   track_updateCompleteHandler);
            
        }
        
        enableSkinParts(enabled);
    }

    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == thumb)
        {
            thumb.removeEventListener(MouseEvent.MOUSE_DOWN, 
                                      thumb_mouseDownHandler);
        }
        else if (instance == track)
        {
            track.removeEventListener(MouseEvent.MOUSE_DOWN, 
                                      track_mouseDownHandler);
            track.removeEventListener("updateComplete", 
                                      track_updateCompleteHandler);
            tempTrackSize = NaN;                                      
        }
    }

    /**
     *  Set the <code>enabled</code> property of the skins parts.
     *
     *  @param value <code>true</code> to enable the skin parts, 
     *  and <code>false</code> to disable them.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function enableSkinParts(value:Boolean):void
    {
        if (thumb)
            thumb.enabled = value;
        if (track)
            track.enabled = value;
    }
    
    /**
     *  Return the value corresponding to a position on the track. 
     *  The value is calculated by
     *  finding what fraction of the logical track the <code>position</code>
     *  represents, and then multiplying that by 
     *  the range of possible values for the track.
     *
     *  @param position A position on the track.
     *
     *  @return A value, between <code>minimum</code> and <code>maximum</code>, 
     *  corresponding to <code>position</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function positionToValue(position:Number):Number
    {
        var posRange:Number = trackSize - thumbSize;

        if (posRange == 0) // Divide by 0 error.
            return minimum;

        var range:Number = maximum - minimum;
        var value:Number = minimum + position * (range / posRange);
        return value;
    }
    
    /**
     *  Return the position of the thumb button on the track
     *  corresponding to a given value. 
     *  
     *  <p>Calculate the thumb button position by finding 
     *  the fraction of the range of possible values that 
     *  <code>value</code> represents, and then multiplying that by
     *  the logical track size, minus the logical thumb size.</p>
     *
     *  @param value A value, between <code>minimum</code> and <code>maximum</code>.
     *
     *  @return A position on the track corresponding to <code>value</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function valueToPosition(value:Number):Number
    {
        var range:Number = maximum - minimum;
        
        if (range == 0) // Divide by 0 error.
            return 0;
            
        var posRange:Number = trackSize - thumbSize;
        var thumbPos:Number = (value - minimum) * (posRange / range);
        
        return thumbPos;
    }
    
    /**
     *  Returns a position on the track. 
     *  The <code>localX</code> and <code>localY</code>
     *  values represent the location in the local coordinate system of the
     *  track. 
     *
     *  <p>Subclasses must override this method and return the
     *  appropriate value. Values should not be clamped to
     *  the ends of the track, as that clamping will happen later, prior
     *  to setting position of the thumb button.</p>
     *
     *  @param localX The X-location in the local coordinate system of the
     *  track.
     *
     *  @param localY The Y-location in the local coordinate system of the
     *  track.
     *
     *  @return The posisiton on the track.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function pointToPosition(localX:Number, localY:Number):Number
    {
        return 0;
    }

    /**
     *  Set the position of the thumb button. 
     *
     *  <p>Subclasses should override this method to position 
     *  the thumb button.</p>
     *
     *  @param thumbPos The new position of the thumb button.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function positionThumb(thumbPos:Number):void {}
    
    /**
     *  Sets the size of the thumb button.
     *  
     *  <p>Subclasses should override this method to size 
     *  the thumb button.</p>
     *
     *  @param thumbSize The new size of the thumb button.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function sizeThumb(thumbSize:Number):void {}

    /**
     *  Returns the size of the thumb button
     *  given the current setting of the range, 
     *  <code>trackSize</code>, or other settings.
     *  Subclasses should override this to calculate the correct size in
     *  the units of position.
     * 
     *  @return The size of the thumb button. 
     *  The default size is 0.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function calculateThumbSize():Number
    {
        return 0;
    }

    /**
     *  From a MouseEvent object that contains the 
     *  position where the thumb button was dragged to, and
     *  the previous position of the thumb button, 
     *  return the value corresponding to the new position. 
     *  The value is restricted to the range defined by the 
     *  <code>minimum</code> and <code>maximum</code> values. 
     *
     *  <p>This method usually should not be overridden.</p>
     *
     *  @param prevValue The previous position of the thumb button.
     *
     *  @param event A MouseEvent object.
     *
     *  @return The value that corresponds to the new track position
     *  as calculated by the <code>nearestValidValue()</code> method.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function calculateNewValue(prevValue:Number, event:MouseEvent):Number
    {
        var pt:Point = new Point(event.stageX, event.stageY);
        pt = track.globalToLocal(pt);
        var movePos:Number = pointToPosition(pt.x - clickOffset.x, 
                                             pt.y - clickOffset.y);
        var newValue:Number = positionToValue(movePos);
        var roundedValue:Number = nearestValidValue(newValue, valueInterval);
        return roundedValue;
    }
    
    /**
     *  @private
     */ 
    override protected function focusInHandler(event:FocusEvent):void
    {
    	 addSystemHandlers(MouseEvent.MOUSE_WHEEL, system_mouseWheelHandler, stage_mouseWheelHandler);
    }
    
    /**
     *  @private
     */
    override protected function focusOutHandler(event:FocusEvent):void
    {
    	removeSystemHandlers(MouseEvent.MOUSE_WHEEL, system_mouseWheelHandler, stage_mouseWheelHandler);
    }

    //--------------------------------------------------------------------------
    // 
    // Event Handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Force the component to set itself up correctly now that the
     *  track is completely loaded.
     */
    protected function track_updateCompleteHandler(event:Event):void
    {
        //TODO: Consider the case where the track moves (like the move
        //effect). Perhaps this handler should run every time... 
        if (trackSize != tempTrackSize)
        {
            thumbSize = calculateThumbSize();
            sizeThumb(thumbSize);
            positionThumb(valueToPosition(value));
            tempTrackSize = trackSize;
        }
    }
    
    /**
     *  Handles the mouseWheel event when the component is in focus. The thumb is 
     *  moved by the amount of the mouse event delta multiplied by the stepSize.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    protected function system_mouseWheelHandler(event:MouseEvent):void
    {
    	var newValue:Number = nearestValidValue(value + event.delta * stepSize, stepSize);
        positionThumb(valueToPosition(newValue));
        setValue(newValue);    	
    }
    
    /**
     *  @private
     *  Handles the mouseWheel event when the component is in focus. The thumb is 
     *  moved by the amount of the mouse event delta multiplied by the stepSize.  
     */ 
    protected function stage_mouseWheelHandler(event:MouseEvent):void
    {
    	if (event.target != stage)
            return;

        system_mouseWheelHandler(event);
    	
    }

    //---------------------------------
    // Thumb dragging handlers
    //---------------------------------
    
    /**
     *  @private
     *  Handle mouse-down events on the scroll thumb. Records 
     *  the mouse down point in clickOffset.
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
        var pt2:Point = track.globalToLocal(pt);
        pt = thumb.globalToLocal(pt);
        _clickOffset = pt;
        
        dispatchEvent(new TrackBaseEvent(TrackBaseEvent.THUMB_PRESS));
    }
    
    /**
     *  @private
     *  Capture mouse-move events on the thumb anywhere on the stage
     */
    private function stage_mouseMoveHandler(event:MouseEvent):void
    {
        if (event.target != stage)
            return;

        system_mouseMoveHandler(event);
    }

    /**
     *  @private
     *  Capture mouse-move events anywhere on or off the stage.
     *  First, we calculate the new value based on the new position
     *  using calculateNewValue(). Then, we move the thumb to 
     *  the new value's position. Last, we set the value and
     *  dispatch a "change" event if the value changes. 
     */
    protected function system_mouseMoveHandler(event:MouseEvent):void
    {
        var newValue:Number = calculateNewValue(value, event);

        positionThumb(valueToPosition(newValue));
        
        if (newValue != value)
        {
            setValue(newValue);
            dispatchEvent(new TrackBaseEvent(TrackBaseEvent.THUMB_DRAG));
            dispatchEvent(new Event("change"));   
        }
        
        event.updateAfterEvent();
    }
    
    /**
     *  @private
     *  Handle mouse-up events anywhere on the stage.
     */
    private function stage_mouseUpHandler(event:MouseEvent):void
    {
        if (event.target != stage)
            return;

        system_mouseUpHandler(event);
    }

    /**
     *  @private
     *  Handle mouse-up events anywhere on or off the stage.
     */
    protected function system_mouseUpHandler(event:MouseEvent):void
    {
        removeSystemHandlers(MouseEvent.MOUSE_MOVE, system_mouseMoveHandler, 
                stage_mouseMoveHandler);
        removeSystemHandlers(MouseEvent.MOUSE_UP, system_mouseUpHandler, 
                stage_mouseUpHandler);
                
        dispatchEvent(new TrackBaseEvent(TrackBaseEvent.THUMB_RELEASE));
    }

    //---------------------------------
    // Track down handlers
    //---------------------------------
    
    /**
     *  @private
     *  Handle mouse-down events for the scroll track. Subclasses
     *  should override this method if they want the track to
     *  recognize mouse clicks on the track.
     */
    protected function track_mouseDownHandler(event:MouseEvent):void {}
}

}
