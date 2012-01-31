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

package spark.components
{

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import spark.components.supportClasses.Range;
import mx.events.FlexEvent;
import mx.managers.IFocusManagerComponent;

/**
 *  Dispatched when the value of the Spinner control changes
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
 *  @copy spark.components.supportClasses.GroupBase#focusColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes")]

/**
 *  @copy spark.components.supportClasses.GroupBase#symbolColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes")]

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

[IconFile("Spinner.png")]

/**
 *  A Spinner component selects a value from an
 *  ordered set. It uses two buttons that increase or
 *  decrease the current value based on the current
 *  value of the <code>stepSize</code> property.
 *  
 *  <p>A Spinner consists of two required buttons,
 *  one to increase the current value and one to decrease the 
 *  current value.</p>
 *
 *  <p>The scale of an Spinner component is the set of 
 *  allowed values for the <code>value</code> property. 
 *  The allowed values are the multiples of 
 *  the <code>valueInterval</code> property between 
 *  the <code>maximum</code> and <code>minimum</code> values, 
 *  including the <code>maximum</code> and <code>minimum</code> values. 
 *  For example:</p>
 *  
 *  <ul>
 *    <li><code>minimum</code> = -1</li>
 *    <li><code>maximum</code> = 10</li>
 *    <li><code>valueInterval</code> = 3</li>
 *  </ul>
 *  
 *  Therefore the scale is {-1,3,6,9,10}.
 *
 *  @see mx.components.NumericStepper
 *
 *  @includeExample examples/SpinnerExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Spinner extends Range implements IFocusManagerComponent
{
    include "../core/Version.as";

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
    public function Spinner():void
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    // SkinParts
    //
    //--------------------------------------------------------------------------
    
    [SkinPart(required="true")]
    
    /**
     *  A skin part that defines the  button that, 
     *  when pressed, increments the <code>value</code> property
     *  by <code>stepSize</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var incrementButton:Button;
    
    [SkinPart(required="true")]
    
    /**
     *  A skin part that defines the  button that, 
     *  when pressed, decrements the <code>value</code> property
     *  by <code>stepSize</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var decrementButton:Button;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  enabled
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function set enabled(value:Boolean):void
    {
        super.enabled = value;
        enableSkinParts(value);
        invalidateSkinState();
    }

    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  valueWrap
    //----------------------------------
    
    /**
     *  @private
     */
    private var _valueWrap:Boolean = false;
    
    /**
     *  Determines the behavior of the control for a step when the current 
     *  <code>value</code> is either the <code>maximum</code> 
     *  or <code>minimum</code> value.  
     *  If <code>valueWrap</code> is <code>true</code>, then the 
     *  <code>value</code> property wraps from the <code>maximum</code> 
     *  to the <code>minimum</code> value, or from 
     *  the <code>minimum</code> to the <code>maximum</code> value.
     * 
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get valueWrap():Boolean
    {
        return _valueWrap;
    }

    public function set valueWrap(value:Boolean):void
    {
        _valueWrap = value;
    }
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        // TODO: autoRepeat as a property on Spinner?        
        if (instance == incrementButton)
        {
            incrementButton.focusEnabled = false;
            incrementButton.addEventListener(FlexEvent.BUTTON_DOWN,
                                        incrementButton_buttonDownHandler);
            incrementButton.autoRepeat = true;
        }
        else if (instance == decrementButton)
        {
            decrementButton.focusEnabled = false;
            decrementButton.addEventListener(FlexEvent.BUTTON_DOWN,
                                        decrementButton_buttonDownHandler);
            decrementButton.autoRepeat = true;
        }
        
        enableSkinParts(enabled);
    }

    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == incrementButton)
        {
            incrementButton.removeEventListener(FlexEvent.BUTTON_DOWN, 
                                           incrementButton_buttonDownHandler);
        }
        else if (instance == decrementButton)
        {
            decrementButton.removeEventListener(FlexEvent.BUTTON_DOWN, 
                                           decrementButton_buttonDownHandler);
        }
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function enableSkinParts(value:Boolean):void
    {
        if (incrementButton)
            incrementButton.enabled = value;
        if (decrementButton)
            decrementButton.enabled = value;
    }
    
    /**
     *  @private
     */
    override public function step(increase:Boolean = true):void
    {
		if (valueWrap)
		{
			if (increase && (value == maximum))
				value = minimum;
			else if (!increase && (value == minimum))
				value = maximum;
			else 
				super.step(increase);
		}
		else
			super.step(increase);
    }
    
    //--------------------------------------------------------------------------
    // 
    // Event Handlers
    //
    //--------------------------------------------------------------------------
    
    //--------------------------------- 
    // Mouse handlers
    //---------------------------------
   
    /**
     *  @private
     *  Handle a click on the incrementButton. This should
     *  increment <code>value</code> by <code>stepSize</code>.
     */
    protected function incrementButton_buttonDownHandler(event:Event):void
    {
        var prevValue:Number = this.value;
        
        step(true);
        
        if (value != prevValue)
            dispatchEvent(new Event("change"));
    }
    
    /**
     *  @private
     *  Handle a click on the decrementButton. This should
     *  decrement <code>value</code> by <code>stepSize</code>.
     */
    protected function decrementButton_buttonDownHandler(event:Event):void
    {
        var prevValue:Number = this.value;
        
        step(false);
        
        if (value != prevValue)
            dispatchEvent(new Event("change"));
    }   
    
    /**
     *  @private
     *  Handles keyboard input. Up arrow increments. Down arrow
     *  decrements. Home and End keys set the value to maximum
     *  and minimum respectively.
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        var prevValue:Number = this.value;
        var stopPropagation:Boolean = false;
                
        switch (event.keyCode)
        {
            case Keyboard.DOWN:
            //case Keyboard.LEFT:
            {
                step(false);
                stopPropagation = true;
                break;
            }

            case Keyboard.UP:
            //case Keyboard.RIGHT:
            {
                step(true);
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
            
            default:
            {
                super.keyDownHandler(event);
                break;
            }
        }

        if (value != prevValue)
            dispatchEvent(new Event("change"));

		if (stopPropagation)
        	event.stopPropagation();
    }
}

}