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

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;

import mx.core.IDataRenderer;
import mx.core.IFactory;
import mx.core.UIComponent;
import mx.formatters.NumberFormatter;
import mx.managers.IFocusManagerComponent;

include "../../styles/metadata/BasicTextLayoutFormatStyles.as"

/**
 *  @copy mx.components.baseClasses.GroupBase#focusColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes")]

/**
 *  The FxSlider class lets users select a value by moving a slider thumb between 
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
public class FxSlider extends FxTrackBase implements IFocusManagerComponent
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
    public function FxSlider():void
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
     *  of a FxSlider Control named 'slide': </p>
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
    // liveDragging
    //---------------------------------
    
    private var _liveDragging:Boolean = false;
    
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
    public function get liveDragging():Boolean
    {
        return _liveDragging;
    }
    
    /**
     *  @private
     */
    public function set liveDragging(value:Boolean):void
    {
        _liveDragging = value;
    }
    
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
    override public function setFocus():void
    {
        if (stage)
            stage.focus = thumb;
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
        
        if (instance == thumb)
        {
            thumb.addEventListener(KeyboardEvent.KEY_DOWN, 
                                   thumb_keyboardHandler);
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == thumb)
        {
            thumb.removeEventListener(KeyboardEvent.KEY_DOWN, 
                                      thumb_keyboardHandler);
        }
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
        currValue = calculateNewValue(currValue, event);

        positionThumb(valueToPosition(currValue));
        
        if (liveDragging && currValue != value)
        {
            setValue(currValue)
            dispatchEvent(new Event("change"));
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
        if (!liveDragging && currValue != value)
        {
            setValue(currValue);
            dispatchEvent(new Event("change"));
        }        
        
        if (dataTipInstance)
        {
            systemManager.toolTipChildren.removeChild(DisplayObject(dataTipInstance));
            dataTipInstance = null;
        }
        
        super.system_mouseUpHandler(event);
    }

    //---------------------------------
    // Thumb keyboard handlers
    //---------------------------------

    /**
     *  @private
     *  Handle keyboard events. Left/Down decreases the value
     *  decreases the value by stepSize. The opposite for
     *  Right/Up arrows. The Home and End keys set the value
     *  to the min and max respectively.
     */
    protected function thumb_keyboardHandler(event:KeyboardEvent):void
    {
        // TODO: Provide a way to easily override the keyboard
        // behavior. This means having a callback in the subclasses
        // that tell the superclass all the positions in an array
        // but defaulting to the normal stepping behavior when no
        // array is returned. Consider reversed HSliders or VSliders.
        var prevValue:Number = this.value;
        var newValue:Number;
        
        switch (event.keyCode)
        {
            case Keyboard.DOWN:
            case Keyboard.LEFT:
            {
                newValue = nearestValidValue(value - stepSize, valueInterval);
                positionThumb(valueToPosition(newValue));
                setValue(newValue);
                break;
            }

            case Keyboard.UP:
            case Keyboard.RIGHT:
            {
                newValue = nearestValidValue(value + stepSize, valueInterval);
                positionThumb(valueToPosition(newValue));
                setValue(newValue);
                break;
            }
            
            case Keyboard.HOME:
            {
                value = minimum;
                break;
            }

            case Keyboard.END:
            {
                value = maximum;
                break;
            }
        }

        if (value != prevValue)
            dispatchEvent(new Event("change"));
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
            setValue(RtempValue);
            dispatchEvent(new Event("change"));
        }

        event.updateAfterEvent();
    }
}

}
