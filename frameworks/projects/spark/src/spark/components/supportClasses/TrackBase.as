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
import flash.geom.Point;
import mx.components.FxButton;

/**
 *  Dispatched when the value of the control changes
 *  as a result of user interaction.
 *
 *  @eventType flash.events.Event.CHANGE
 */
[Event(name="change", type="flash.events.Event")]

/**
 *  Skin states for this component.
 */
[SkinStates("normal", "disabled")]

/**
 *  The FxTrackBase class is a base class for components with a track
 *  and one or more thumb buttons, such as FxSlider and FxScrollBar. It
 *  declares two required skin parts: <code>thumb</code> and
 *  <code>track</code>. 
 *  The FxTrackBase class also provides the code for
 *  dragging the thumb button, which is shared by the FxSlider and FxScrollBar classes.
 * 
 *  @see mx.components.baseClasses.FxSlider
 *  @see mx.components.baseClasses.FxScrollBar
 */
public class FxTrackBase extends FxRange
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */
    public function FxTrackBase():void
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    // Skins
    //
    //--------------------------------------------------------------------------

    [SkinPart]
    
    /**
     *  A skin part that defines a button
     *  that can be dragged along the track to increase or
     *  decrease the <code>value</code> property.
     *  Updates to the <code>value</code> property 
     *  automatically update the position of the thumb button
     *  with respect to the track.
     */
    public var thumb:FxButton;
    
    [SkinPart]
    
    /**
     *  A skin part that defines a button
     *  that when  pressed sets the <code>value</code> property
     *  to the value corresponding with the current button position on the track.
     */
    public var track:FxButton; 


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
    
    /**
     *  Enable (<code>true</code>) or disable (<code>false</code>) this component. 
     *  This property also enables and disables any of the 
     *  skin parts for this component.
     */
    override public function set enabled(value:Boolean):void
    {
        super.enabled = value;
        enableSkinParts(value);
        invalidateSkinState();
    }
    
    /**
     *  @inheritDoc
     */
    override public function set maximum(value:Number):void
    {
        super.maximum = value;
        invalidateDisplayList();
    }

    /**
     *  @inheritDoc
     */
    override public function set minimum(value:Number):void
    {
        super.minimum = value;
        invalidateDisplayList();
    }
    
    /**
     *  @inheritDoc
     */
    override public function set value(newValue:Number):void
    {
        super.value = newValue;
        invalidateDisplayList();
    }
    
    /**
     *  @inheritDoc
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
    override protected function updateDisplayList(unscaledWidth:Number, 
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        thumbSize = calculateThumbSize();
        sizeThumb(thumbSize);

        positionThumb(valueToPosition(value));
    }

    /**
     *  @inheritDoc
     */
    override protected function getUpdatedSkinState():String
    {
        return enabled ? "normal" : "disabled";
    }
    
    /**
     *  @inheritDoc
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
     *  @inheritDoc
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
        }
    }

    /**
     *  Set the <code>enabled</code> property of the skins parts.
     *
     *  @param value <code>true</code> to enable the skin parts, 
     *  and <code>false</code> to disable them.
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
     */
    protected function positionThumb(thumbPos:Number):void {}
    
    /**
     *  Sets the size of the thumb button.
     *  
     *  <p>Subclasses should override this method to size 
     *  the thumb button.</p>
     *
     *  @param thembSize The new size of the thumb button.
     */
    protected function sizeThumb(thumbSize:Number):void {}

    /**
     *  Returns the size of the thumb button
     *  given the current range, pageSize, and trackSize settings.
     *  Subclasses should override this to calculate the correct size in
     *  the units of position.
     * 
     *  @default 0
     */
    protected function calculateThumbSize():Number
    {
        return 0;
    }

    /**
     *  From a MouseEvent object that contains the position where the thumb was dragged to, and
     *  the previous value of the thumb position, return a new
     *  value based on the difference calculated in the MouseDown event 
     *  and the new position. The value is also restricted to the allowed
     *  values here. This method usually should not be overridden.
     */
    protected function calculateNewValue(prevValue:Number, event:MouseEvent):Number
    {
        var pt:Point = new Point(event.stageX, event.stageY);
        pt = track.globalToLocal(pt);
        var movePos:Number = pointToPosition(pt.x - _clickOffset.x, 
                                             pt.y - _clickOffset.y);
        var newValue:Number = positionToValue(movePos);
        var roundedValue:Number = nearestValidValue(newValue, stepSize);
        return roundedValue;
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