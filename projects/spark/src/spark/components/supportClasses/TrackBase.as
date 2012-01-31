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
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.events.FlexEvent;
import mx.events.ResizeEvent;
import mx.events.SandboxMouseEvent;

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
 *  Dispatched at the end of a user interaction 
 *  or when an animation ends.
 *
 *  @eventType mx.events.FlexEvent.CHANGE_END
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="changeEnd", type="mx.events.FlexEvent")]

/**
 *  Dispatched at the start of a user interaction 
 *  or when an animation starts.
 *
 *  @eventType mx.events.FlexEvent.CHANGE_START
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="changeStart", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the thumb is pressed and then moved by the mouse.
 *  This event is always preceded by a <code>thumbPress</code> event.
 * 
 *  @eventType spark.events.TrackBaseEvent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="thumbDrag", type="spark.events.TrackBaseEvent")]

/**
 *  Dispatched when the thumb is pressed, meaning
 *  the user presses the mouse button over the thumb.
 *
 *  @eventType mx.events.SliderEvent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
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
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
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
 * <p>This duration is for an animation that covers the entire distance of the 
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
 *  @mxml
 *
 *  <p>The <code>&lt;s:TrackBase&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:TrackBase
 *    <strong>Styles</strong>
 *    slideDuration="300"
 *
 *    <strong>Events</strong>
 *    change="<i>No default</i>"
 *    changing="<i>No default</i>"
 *    thumbDrag="<i>No default</i>"
 *    thumbPress="<i>No default</i>"
 *    thumbRelease="<i>No default</i>"
 *  /&gt;
 *  </pre> 
 * 
 *  @see spark.components.supportClasses.Slider
 *  @see spark.components.supportClasses.ScrollBar
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
        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
    }

    //--------------------------------------------------------------------------
    //
    // Skins
    //
    //--------------------------------------------------------------------------

    [SkinPart(required="false")]
    
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
    
    [SkinPart(required="false")]
    
    /**
     *  A skin part that defines a button
     *  that, when  pressed, sets the <code>value</code> property
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

    private var mouseDownTarget:DisplayObject;

    //--------------------------------------------------------------------------
    //
    //  Overridden properties: Range
    //
    //--------------------------------------------------------------------------
    
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
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Converts a track-relative x,y pixel location into a value between 
     *  the minimum and maximum, inclusive.  
     * 
     *  <p>TrackBase subclasses must override this method and perform conversions
     *  that take their own geometry into account.
     * 
     *  For example, a vertical slider might compute a value like this:
     *  <pre>
     *  return (y / track.height) * (maximum - minimum);
     *  </pre>
     *  </p>
     * 
     *  <p>By default, this method returns <code>minimum</code>.</p>
     * 
     *  @param x The x coordinate of the location relative to the track's origin.
     *  @param y The y coordinate of the location relative to the track's origin.
     *  @return A value between the minimum and maximum, inclusive.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function pointToValue(x:Number, y:Number):Number
    {
        return minimum;
    }

    /**
     *  @private
     */
    override public function changeValueByStep(increase:Boolean = true):void
    {
        var prevValue:Number = this.value;
        
        super.changeValueByStep(increase);
        
        if (value != prevValue)
            dispatchEvent(new Event(Event.CHANGE));
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
     *  Warning: the goal of the listeners added here (and removed below) is to 
     *  give the TrackBase a change to fixup the thumb's size and position
     *  after the skin's BasicLayout has run.   This particular implementation
     *  is a hack and it begs a solution to the general problem of what we've
     *  called "cooperative layout".   More about that here:
     *  http://opensource.adobe.com/wiki/display/flexsdk/Cooperative+Subtree+Layout
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        if (instance == thumb)
        {
            thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDownHandler);
            thumb.addEventListener(ResizeEvent.RESIZE, thumb_resizeHandler);
            thumb.addEventListener(FlexEvent.UPDATE_COMPLETE, thumb_updateCompleteHandler);
            thumb.stickyHighlighting = true;
        }
        else if (instance == track)
        {
            track.addEventListener(MouseEvent.MOUSE_DOWN, track_mouseDownHandler);
            track.addEventListener(ResizeEvent.RESIZE, track_resizeHandler);
        }
    }

    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == thumb)
        {
            thumb.removeEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDownHandler);
            thumb.removeEventListener(ResizeEvent.RESIZE, thumb_resizeHandler);            
            thumb.removeEventListener(FlexEvent.UPDATE_COMPLETE, thumb_updateCompleteHandler);            
        }
        else if (instance == track)
        {
            track.removeEventListener(MouseEvent.MOUSE_DOWN, track_mouseDownHandler);
            track.removeEventListener(ResizeEvent.RESIZE, track_resizeHandler);
        }
    }
    /**
     *  @private
     *  If the component is in focus, then it should respond to mouseWheel events. We listen to these
     *  events on systemManager in the capture phase because this behavior should have the highest priority. 
     */ 
    override protected function focusInHandler(event:FocusEvent):void
    {
        super.focusInHandler(event);
        systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_WHEEL, system_mouseWheelHandler, true);
    }
    
    /**
     *  @private
     */
    override protected function focusOutHandler(event:FocusEvent):void
    {
        super.focusOutHandler(event);
        systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_WHEEL, system_mouseWheelHandler, true);
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(w:Number, h:Number):void
    {
        super.updateDisplayList(w, h);
        updateSkinDisplayList();
    }

    //--------------------------------------------------------------------------
    // 
    // Event Handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Location of the mouse down event on the thumb, relative to the thumb's origin.
     *  Used to update the value property when the mouse is dragged. 
     */
    private var clickOffset:Point;
    
    /**
     *  Sets the bounds of skin parts - typically the thumb - whose geometry isn't fully
     *  specified by the skin's layout.
     * 
     *  <p>Most subclasses override this method to update the thumb's size, position, and 
     *  visibility, based on the <code>minimum</code>, <code>maximum</code>, and <code>value</code> properties. </p>
     * 
     *  <p>Does nothing by default.</p> 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     * 
     */
    protected function updateSkinDisplayList():void {}

    
    /**
     *  @private
     */
    private function track_resizeHandler(event:Event):void
    {
        updateSkinDisplayList();
    }

    /**
     *  @private
     */
    private function thumb_resizeHandler(event:Event):void
    {
        updateSkinDisplayList();
    }
    
    /**
     *  @private
     */
    private function thumb_updateCompleteHandler(event:Event):void
    {
        updateSkinDisplayList();
        thumb.removeEventListener(FlexEvent.UPDATE_COMPLETE, thumb_updateCompleteHandler);
    }
    
    /**
     *  Handles the <code>mouseWheel</code> event when the component is in focus. The thumb is 
     *  moved by the amount of the mouse event delta multiplied by the <code>stepSize</code>.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    protected function system_mouseWheelHandler(event:MouseEvent):void
    {
        if (!event.isDefaultPrevented())
        {
            var newValue:Number = nearestValidValue(value + event.delta * stepSize, stepSize);
            setValue(newValue);
            dispatchEvent(new Event(Event.CHANGE));
            event.preventDefault();
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
        systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_MOVE, 
            system_mouseMoveHandler, true);
        systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, 
            system_mouseUpHandler, true);
        systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, 
            system_mouseUpHandler);
        
        clickOffset = thumb.globalToLocal(new Point(event.stageX, event.stageY));
        
        dispatchEvent(new TrackBaseEvent(TrackBaseEvent.THUMB_PRESS));
        dispatchEvent(new FlexEvent(FlexEvent.CHANGE_START));
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
        var p:Point = track.globalToLocal(new Point(event.stageX, event.stageY));
        var newValue:Number = pointToValue(p.x - clickOffset.x, p.y - clickOffset.y);
        newValue = nearestValidValue(newValue, snapInterval);

        if (newValue != value)
        {
            setValue(newValue); 
            dispatchEvent(new TrackBaseEvent(TrackBaseEvent.THUMB_DRAG));
            dispatchEvent(new Event(Event.CHANGE));
        }
    
        event.updateAfterEvent();
    }
 
    /**
     *  @private
     *  Handle mouse-up events anywhere on or off the stage.
     */
    protected function system_mouseUpHandler(event:Event):void
    {
        systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_MOVE, 
            system_mouseMoveHandler, true);
        systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP, 
            system_mouseUpHandler, true);
        systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, 
            system_mouseUpHandler);
        
        dispatchEvent(new TrackBaseEvent(TrackBaseEvent.THUMB_RELEASE));
        dispatchEvent(new FlexEvent(FlexEvent.CHANGE_END));
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
    protected function track_mouseDownHandler(event:MouseEvent):void { }
    
    //---------------------------------
    // Mouse click handlers
    //---------------------------------
    
    /**
     *  @private
     *  Capture any mouse down event and listen for a mouse up event
     */  
    private function mouseDownHandler(event:MouseEvent):void
    {
        systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, 
                                                        system_mouseUpSomewhereHandler, true);
        systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, 
                                                        system_mouseUpSomewhereHandler);
        
        mouseDownTarget = DisplayObject(event.target);      
    }
    
    /**
     *  @private
     */
    private function system_mouseUpSomewhereHandler(event:Event):void
    {
        systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP, 
                                                           system_mouseUpSomewhereHandler, true);
        systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, 
                                                           system_mouseUpSomewhereHandler);
        
        // If we got a mouse down followed by a mouse up on a different target in the skin, 
        // we want to dispatch a click event. 
        if (mouseDownTarget != event.target && event is MouseEvent && contains(DisplayObject(event.target)))
        { 
            var mEvent:MouseEvent = event as MouseEvent;
            // Convert the mouse coordinates from the target to the TrackBase
            var mousePoint:Point = new Point(mEvent.localX, mEvent.localY);
            mousePoint = globalToLocal(DisplayObject(event.target).localToGlobal(mousePoint));
            
            dispatchEvent(new MouseEvent(MouseEvent.CLICK, mEvent.bubbles, mEvent.cancelable, mousePoint.x,
                                     mousePoint.y, mEvent.relatedObject, mEvent.ctrlKey, mEvent.altKey,
                                     mEvent.shiftKey, mEvent.buttonDown, mEvent.delta));
        }
        
        mouseDownTarget = null;
    }
}

}
