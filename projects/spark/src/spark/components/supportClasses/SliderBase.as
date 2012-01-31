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
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;

import mx.core.IDataRenderer;
import mx.core.IFactory;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.formatters.NumberFormatter;
import mx.managers.IFocusManagerComponent;

import spark.effects.SimpleMotionPath;
import spark.effects.animation.Animation;
import spark.effects.easing.Sine;
import spark.events.TrackBaseEvent;

use namespace mx_internal;

include "../../styles/metadata/BasicTextLayoutFormatStyles.as"

/**
 *  @copy spark.components.supportClasses.GroupBase#focusColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  When <code>true</code>, the thumb's value is
 *  committed as it is dragged along the track instead
 *  of when the thumb button is released.
 *  
 *  @default false
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="liveDragging", type="Boolean", inherit="no")]

/**
 *  The Slider class lets users select a value by moving a slider thumb between 
 *  the end points of the slider track. 
 *  The current value of the slider is determined by the relative location of 
 *  the thumb between the end points of the slider, 
 *  corresponding to the slider's minimum and maximum values. 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Slider extends TrackBase implements IFocusManagerComponent
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
    public function Slider():void
    {
        super();
    }

	//--------------------------------------------------------------------------
    //
    //  Skin Parts
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

    private var currValue:Number;
    
	private var dataFormatter:NumberFormatter;

    private var animator:Animation = null;
    
    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //-------------------------------------------------------------------------- 	

	/**
	 *  The dataTip instance used by subclasses to control its behavior. The instance
	 *  is non-null only when the dataTip has been popped up.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	protected var dataTipInstance:IDataRenderer;

	//--------------------------------- 
    // dataTipformatFunction
    //---------------------------------

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
     *  of a Slider Control named 'slide': </p>
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
	public function set dataTipFormatFunction(value:Function):void
	{
		_dataTipFormatFunction = value;
	}
	
	public function get dataTipFormatFunction():Function
	{
		return _dataTipFormatFunction;
	}
	
	/**
	 *  Starting position of the dataTip. Used by subclasses to 
	 *  position the dataTip. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	protected var dataTipOriginalPosition:Point;
	
	//--------------------------------- 
    // dataTipPrecision
    //---------------------------------
    /**
	 *  Number of decimal places to use for the data tip text.
	 *  A value of 0 means to round all values to an integer.
	 *  This value is ignored if dataTipFormatFunction is defined.
	 * 
	 *  @default 2
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
    public var dataTipPrecision:int = 2;
    
    //--------------------------------- 
    // showDataTip
    //---------------------------------
    
    /**
     *  If set to <code>true</code>, show a data tip during user interaction
     *  containing the current value of the slider. In addition, the skinPart
     *  <code>dataTipFactory</code> must be defined in the skin in order to 
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
    // Methods
    //
    //--------------------------------------------------------------------------

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
     */  
    override protected function partAdded(partName:String, instance:Object):void
    {
    	super.partAdded(partName, instance);
    	
    	// Prevent focus on our children so that focus remains with the Slider
        if (instance == thumb)
        	thumb.focusEnabled = false;
        else if (instance == track)
        	track.focusEnabled = false;
    }
    
    /**
     *  Converts a point retrieved from clicking on the track into a position. 
     *  This method lets subclasses center the thumb button when clicking on the track. 
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
    protected function pointClickToPosition(localX:Number, 
                                            localY:Number):Number
    {
        return 0;
    }   
   
    /**
     *  Used to position the data tip when it is visible. Subclasses must implement
     *  this function and can use the dataTipOriginalPosition and dataTipInstance
     *  properties. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function positionDataTip():void
    {
		// Override in the subclasses
    }

    //--------------------------------------------------------------------------
    // 
    // Event Handlers
    //
    //--------------------------------------------------------------------------
    
    //---------------------------------
    // Thumb dragging handlers
    //---------------------------------
    
    /**
     *  @private
     */
    override protected function thumb_mouseDownHandler(event:MouseEvent):void
    {
        super.thumb_mouseDownHandler(event);
        
        // Save the current value also.
        currValue = value;
        
        // Popup a dataTip only if we have a SkinPart and the boolean flag is true
        if (dataTip && showDataTip && enabled)
        {
	        dataTipInstance = IDataRenderer(createDynamicPartInstance("dataTip"));
	        systemManager.toolTipChildren.addChild(DisplayObject(dataTipInstance));
	        
	        dataTipInstance.data = formatDataTipText(currValue);
	        
	        // Force the dataTip to render so that we have the correct size since
	        // positionDataTip might need the size
	        var tipAsUIComponent:UIComponent = dataTipInstance as UIComponent; 
	        if (tipAsUIComponent)
	        {
	        	tipAsUIComponent.validateNow();
	        	tipAsUIComponent.setActualSize(tipAsUIComponent.getExplicitOrMeasuredWidth(),
	        								   tipAsUIComponent.getExplicitOrMeasuredHeight());
	        }
	        
	        dataTipOriginalPosition = new Point(DisplayObject(dataTipInstance).x, 
	        									DisplayObject(dataTipInstance).y);   
	        positionDataTip();
        }
    }

    /**
     *  @private
     */
    override protected function system_mouseMoveHandler(event:MouseEvent):void
    {
        // TODO (chaase): I think we can do this without a persistent
        // currValue property, and therefore just call super.mouseMove to
        // handle the main functionality, with extra code just for the
        // dataTipInstance case
        
        currValue = calculateNewValue(currValue, event);

        positionThumb(valueToPosition(currValue));
        
        if (getStyle("liveDragging") && currValue != value)
        {
            setValue(currValue)
            dispatchEvent(new Event(Event.CHANGE));
        }
        
        if (dataTipInstance && showDataTip)
        { 
	        dataTipInstance.data = formatDataTipText(currValue);
	        
	        // Force the dataTip to render so that we have the correct size since
	        // positionDataTip might need the size
	        var tipAsUIComponent:UIComponent = dataTipInstance as UIComponent; 
	        if (tipAsUIComponent)
	        {
	        	tipAsUIComponent.validateNow();
	        	tipAsUIComponent.setActualSize(tipAsUIComponent.getExplicitOrMeasuredWidth(),tipAsUIComponent.getExplicitOrMeasuredHeight());
	        }
	        
			positionDataTip();
        }
        
        event.updateAfterEvent();
    }
    
    /**
     *  @private
     */
    override protected function system_mouseUpHandler(event:MouseEvent):void
    {
        // TODO (chaase): get rid of currValue and just calculate the new
        // value here dynamically
        if (!getStyle("liveDragging") && currValue != value)
        {
            setValue(currValue);
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

    //---------------------------------
    // Keyboard handlers
    //---------------------------------

    /**
     *  @private
     *  Handle keyboard events. Left/Down decreases the value
     *  decreases the value by stepSize. The opposite for
     *  Right/Up arrows. The Home and End keys set the value
     *  to the min and max respectively.
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        super.keyDownHandler(event);
        
        // TODO: Provide a way to easily override the keyboard
        // behavior. This means having a callback in the subclasses
        // that tell the superclass all the positions in an array
        // but defaulting to the normal stepping behavior when no
        // array is returned. Consider reversed HSliders or VSliders.
        var prevValue:Number = this.value;
        var newValue:Number;
        var stopPropagation:Boolean = false;
        
        switch (event.keyCode)
        {
            case Keyboard.DOWN:
            case Keyboard.LEFT:
            {
                newValue = nearestValidValue(value - stepSize, valueInterval);
                positionThumb(valueToPosition(newValue));
                setValue(newValue);
                stopPropagation = true;
                break;
            }

            case Keyboard.UP:
            case Keyboard.RIGHT:
            {
                newValue = nearestValidValue(value + stepSize, valueInterval);
                positionThumb(valueToPosition(newValue));
                setValue(newValue);
                stopPropagation = true;
                break;
            }
            
            case Keyboard.HOME:
            {
                value = minimum;
                stopPropagation = true;
                break;
            }

            case Keyboard.END:
            {
                value = maximum;
                stopPropagation = true;
                break;
            }
        }

        if (value != prevValue)
            dispatchEvent(new Event(Event.CHANGE));
            
        if (stopPropagation)
        	event.stopPropagation();
    }

    //---------------------------------
    // Track down handlers
    //---------------------------------
    
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
        
        // Calculate the new value.
        var pt:Point = new Point(event.stageX, event.stageY);
        pt = track.globalToLocal(pt);
        var tempPosition:Number = pointClickToPosition(pt.x, pt.y);
        var tempValue:Number = positionToValue(tempPosition);
        var RtempValue:Number = nearestValidValue(tempValue, valueInterval);
        
        // Move the thumb to the new value
        positionThumb(valueToPosition(RtempValue));
        
        if (RtempValue != value)
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
                animator.stop();
                animator.duration = slideDuration * 
                    (Math.abs(value - RtempValue) / (maximum - minimum));
                animator.motionPaths = [
                    new SimpleMotionPath("value", value, RtempValue)];
                
                dispatchEvent(new FlexEvent(FlexEvent.CHANGING));
                animator.play();
            }
            else
            {
                setValue(RtempValue);
                dispatchEvent(new Event(Event.CHANGE));
            }
        }

        event.updateAfterEvent();
    }
    
    /**
     * @private
     * Handles events from the Animation that runs the animated slide.
     * We just call setValue() with the current animated value
     */
    private function animationUpdateHandler(animation:Animation):void
    {
        setValue(animation.currentValue["value"]);
    }
    
    /**
     * @private
     * Handles end event from the Animation that runs the animated slide.
     * We dispatch the "change" event at this time, after the animation
     * is done.
     */
    private function animationEndHandler(animation:Animation):void
    {
        dispatchEvent(new Event("change"));
    }
}
}
