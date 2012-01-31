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

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;

import mx.core.IIMESupport;
import mx.events.FlexEvent;
import mx.managers.IFocusManagerComponent;

include "../styles/metadata/AdvancedTextLayoutFormatStyles.as"
include "../styles/metadata/BasicTextLayoutFormatStyles.as"
include "../styles/metadata/SelectionFormatTextStyles.as"

/**
 *  @copy spark.components.supportClasses.GroupBase#style:contentBackgroundColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes", theme="spark")]


[IconFile("NumericStepper.png")]
/**
 *  The NumericStepper control lets you select
 *  a number from an ordered set.
 *  The NumericStepper provides the same functionality as
 *  the Spinner component, but adds a TextInput control
 *  so that you can directly edit the value of the component,
 *  rather than modifying it by using the control's arrow buttons.
 *
 *  <p>The NumericStepper control consists of a single-line
 *  input text field and a pair of arrow buttons
 *  for stepping through the possible values.
 *  The Up Arrow and Down Arrow keys also cycle through 
 *  the values. 
 *  An input value is committed when
 *  the user presses the Enter key, removes focus from the
 *  component, or steps the NumericStepper by pressing an arrow button
 *  or by calling the <code>step()</code> method.</p>
 *
 *  @see mx.components.Spinner
 * 
 *  @includeExample examples/NumericStepperExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class NumericStepper extends Spinner 
    implements IFocusManagerComponent, IIMESupport
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */  
    public function NumericStepper()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  SkinParts
    //
    //--------------------------------------------------------------------------

    [SkinPart(required="true")]
    
    /**
     *  A skin part that defines a TextInput control 
     *  which allows a user to edit the value of
     *  the NumericStepper component. 
     *  The value is rounded and committed
     *  when the user presses enter, focuses out of
     *  the NumericStepper, or steps the NumericStepper.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var textInput:TextInput;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  maxChars
    //----------------------------------

    /**
     *  @private
     *  Storage for the maxChars property.
     */
    private var _maxChars:int = 0;

    /**
     *  @private
     */
    private var maxCharsChanged:Boolean = false;

    /**
     *  The maximum number of characters that can be entered in the field.
     *  A value of 0 means that any number of characters can be entered.
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get maxChars():int
    {
        return _maxChars;
    }

    /**
     *  @private
     */
    public function set maxChars(value:int):void
    {
        if (value == _maxChars)
            return;
            
        _maxChars = value;
        maxCharsChanged = true;
        
        invalidateProperties();
    }
    
    //--------------------------------- 
    // displayFormatFunction
    //---------------------------------

    private var _displayFormatFunction:Function;
    private var displayFormatFunctionChanged:Boolean;
    
     /**
     *  Callback function that formats the value displayed
     *  in the textInput field.
     *  The function takes a single Number as an argument
     *  and returns a formatted String.
     *
     *  <p>The function has the following signature:</p>
     *  <pre>
     *  funcName(value:Number):String
     *  </pre>
     
     *  @default undefined   
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get displayFormatFunction():Function
    {
        return _displayFormatFunction;
    }
    
    /**
     *  @private
     */
    public function set displayFormatFunction(value:Function):void
    {
        _displayFormatFunction = value;
        displayFormatFunctionChanged = true;
        invalidateProperties();
    }
    
    //--------------------------------- 
    // extractValueFunction
    //---------------------------------

    private var _extractValueFunction:Function;
    private var extractValueFunctionChanged:Boolean;
    
     /**
     *  Callback function that extracts the numeric 
     *  value from the displayed value in the 
     *  textInput field.  
     * 
     *  The function takes a single String as an argument
     *  and returns a Number.
     *
     *  <p>The function has the following signature:</p>
     *  <pre>
     *  funcName(value:String):Number
     *  </pre>
     
     *  @default undefined   
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get extractValueFunction():Function
    {
        return _extractValueFunction;
    }
    
    /**
     *  @private
     */
    public function set extractValueFunction(value:Function):void
    {
        _extractValueFunction = value;
        extractValueFunctionChanged = true;
        invalidateProperties();
    }

    //----------------------------------
    //  imeMode
    //----------------------------------

    /**
     *  @private
     */
    private var _imeMode:String = null;

    [Inspectable(defaultValue="")]

    /**
     *  @private
     */
    private var imeModeChanged:Boolean = false;

    /**
     *  Specifies the IME (Input Method Editor) mode.
     *  The IME enables users to enter text in Chinese, Japanese, and Korean.
     *  Flex sets the specified IME mode when the control gets the focus
     *  and sets it back to previous value when the control loses the focus.
     *
     * <p>The flash.system.IMEConversionMode class defines constants for the
     *  valid values for this property.
     *  You can also specify <code>null</code> to specify no IME.</p>
     *
     *  @see flash.system.IMEConversionMode
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get imeMode():String
    {
        return _imeMode;
    }

    /**
     *  @private
     */
    public function set imeMode(value:String):void
    {
        _imeMode = value;
        imeModeChanged = true;
        invalidateProperties();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  baselinePosition
    //----------------------------------

    /**
     *  @private
     */
    override public function get baselinePosition():Number
    {
        return getBaselinePositionForPart(textInput);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Properties: Range
    //
    //--------------------------------------------------------------------------
    
    //---------------------------------
    // maximum
    //---------------------------------   
    
    private var _maximum:Number = 10;
    private var maxChanged:Boolean = false;
    
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
        return _maximum;
    }
    
    override public function set maximum(value:Number):void
    {
        if (value == _maximum)
            return;

        _maximum = value;
        maxChanged = true;

        invalidateProperties();
    }
    
    //---------------------------------
    // stepSize
    //---------------------------------   
    
    private var stepSizeChanged:Boolean = false;
    
    /**
     *  @private
     */
    override public function set stepSize(value:Number):void
    {
        stepSizeChanged = true;
        super.stepSize = value;       
    }   
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function commitProperties():void
    {   
        super.commitProperties();
        
        if (maxChanged || stepSizeChanged || displayFormatFunctionChanged)
        {
            textInput.widthInChars = calculateWidestValue();
            maxChanged = false;
            stepSizeChanged = false;
            
            if (displayFormatFunctionChanged)
            {
                applyDisplayFormatFunction();
               
                displayFormatFunctionChanged = false;
            }
        }
        
        if (extractValueFunctionChanged)
        {
            commitTextInput(false);
            extractValueFunctionChanged = false;
        }
            
        if (maxCharsChanged)
        {
            textInput.maxChars = _maxChars;
            maxCharsChanged = false;
        }
        
        if (imeModeChanged)
        {
            textInput.imeMode = _imeMode;
            imeModeChanged = false;
        }
    } 
    
    /**
     *  @private
     */
    override protected function setValue(newValue:Number):void
    {
        super.setValue(newValue);
        
        applyDisplayFormatFunction();
    }
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == textInput)
        {
            textInput.addEventListener(FlexEvent.ENTER,
                                       textInput_enterHandler);
            textInput.addEventListener(FocusEvent.FOCUS_OUT, 
                                       textInput_focusOutHandler); 
            textInput.focusEnabled = false;
            textInput.maxChars = _maxChars;
            // Restrict to digits, minus sign, decimal point, and comma
            textInput.restrict = "0-9\\-\\.\\,";
            textInput.text = value.toString();
            // Set the the textInput to be wide enough to display
            // widest possible value. 
            textInput.widthInChars = calculateWidestValue(); 
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == textInput)
        {
            textInput.removeEventListener(FlexEvent.ENTER, 
                                          textInput_enterHandler);
        }
    }

    /**
     *  @private
     */
    override public function setFocus():void
    {
        if (stage)
        {
            stage.focus = textInput.textView;
            textInput.textView.setSelection();
        }
    }
    
    /**
     *  @private
     */
    override protected function isOurFocus(target:DisplayObject):Boolean
    {
        return target == textInput.textView;
    }

    /**
     *  @private
     *  Calls commitTextInput() before stepping.
     */
    override public function step(increase:Boolean = true):void
    {
        commitTextInput();
        
        super.step(increase);
    }
    
    //--------------------------------------------------------------------------
    // 
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Commits the current text of <code>textInput</code> 
     *  to the <code>value</code> property. 
     *  This method uses the <code>nearestValidValue()</code> method 
     *  to round the input value to the closest multiple of 
     *  the <code>valueInterval</code> property, 
     *  and constrains the value to the range defined by the 
     *  <code>maximum</code> and <code>minimum</code> properties.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function commitTextInput(dispatchChange:Boolean = false):void
    {
        var inputValue:Number;
        var prevValue:Number = value;
        
        if (extractValueFunction != null)
            inputValue = extractValueFunction(textInput.text);
        else 
            inputValue = Number(textInput.text);
        
        if (textInput.text == "" || (inputValue != value && 
            (Math.abs(inputValue - value) >= 0.000001 || isNaN(inputValue))))
        {
            setValue(nearestValidValue(inputValue, valueInterval));
            
            // Dispatch valueCommit if the display needs to change.
            if (value == prevValue && inputValue != prevValue)
                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
        }
        
        if (dispatchChange)
        {
            if (value != prevValue)
                dispatchEvent(new Event(Event.CHANGE));
        }
    }
    
    //--------------------------------------------------------------------------
    // 
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Helper method that returns a number corresponding
     *  to the length of the maximum value displayable in 
     *  the textInput.  
     */
    private function calculateWidestValue():Number
    {
        var widestNumber:Number = minimum.toString().length >
                              maximum.toString().length ?
                              minimum :
                              maximum;
        widestNumber += stepSize;
        
        if (displayFormatFunction != null)
            return displayFormatFunction(widestNumber).length;
        else 
           return widestNumber.toString().length;
    }
    
    /**
     *  @private
     *  Helper method that applies the displayFormatFunction  
     */
    private function applyDisplayFormatFunction():void
    {
        if (displayFormatFunction != null)
            textInput.text = displayFormatFunction(value);
        else
            textInput.text = value.toString();
    }
    
    //--------------------------------------------------------------------------
    // 
    //  Event handlers
    //
    //--------------------------------------------------------------------------
        
    /**
     *  @private
     *  When the enter key is pressed, NumericStepper commits the
     *  text currently displayed.
     */
    private function textInput_enterHandler(event:Event):void
    {
        commitTextInput(true);
    }
    
    /**
     *  @private
     *  When the enter key is pressed, NumericStepper commits the
     *  text currently displayed.
     */
    private function textInput_focusOutHandler(event:Event):void
    {
        commitTextInput(true);
    }
}

}
