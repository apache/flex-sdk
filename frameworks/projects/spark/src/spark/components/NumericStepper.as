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
import flash.events.KeyboardEvent;

import mx.core.mx_internal;
import mx.core.IIMESupport;
import mx.events.FlexEvent;
import mx.managers.IFocusManagerComponent;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/BasicInheritingTextStyles.as"
include "../styles/metadata/AdvancedInheritingTextStyles.as"
include "../styles/metadata/SelectionFormatTextStyles.as"

/**
 *  The alpha of the content background for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="contentBackgroundAlpha", type="Number", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:contentBackgroundColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes", theme="spark")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[AccessibilityClass(implementation="spark.accessibility.SpinnerAccImpl")]

[DefaultTriggerEvent("change")]

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
 *  The Up Arrow and Down Arrow keys and the mouse wheel also cycle through 
 *  the values. 
 *  An input value is committed when
 *  the user presses the Enter key, removes focus from the
 *  component, or steps the NumericStepper by pressing an arrow button
 *  or by calling the <code>changeValueByStep()</code> method.</p>
 *
 *  <p>The NumericStepper control has the following default characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>53 pixels wide by 23 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Minimum size</td>
 *           <td>40 pixels wide and 40 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Maximum size</td>
 *           <td>10000 pixels wide and 10000 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Default skin classes</td>
 *           <td>spark.skins.spark.NumericStepperSkin
 *              <p>spark.skins.spark.NumericStepperTextInputSkin</p></td>
 *        </tr>
 *     </table>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:NumericStepper&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:NumericStepper
 *
 *    <strong>Properties</strong>
 *    imeMode="null"
 *    maxChars="0"
 *    maximum="10"
 *    valueFormatFunction=""
 *    valueParseFunction=""
 *
 *    <strong>Styles</strong>
 *
*    alignmentBaseline="USE_DOMINANT_BASELINE"
*    baselineShift="0.0"
*    blockProgression="TB"
*    breakOpportunity="AUTO"
*    cffHinting="HORIZONTAL_STEM"
*    color="0"
*    contentBackgroundColor=""
*    digitCase="DEFAULT"
*    digitWidth="DEFAULT"
*    direction="LTR"
*    dominantBaseline="AUTO"
*    firstBaselineOffset="AUTO"
*    focusedTextSelectionColor=""
*    fontFamily="Times New Roman"
*    fontLookup="DEVICE"
*    fontSize="12"
*    fontStyle="NORMAL"
*    fontWeight="NORMAL"
*    inactiveTextSelection=""
*    justificationRule="AUTO"
*    justificationStyle="AUTO"
*    kerning="AUTO"
*    leadingModel="AUTO"
*    ligatureLevel="COMMON"
*    lineHeight="120%"
*    lineThrough="false"
*    locale="en"
*    paragraphEndIndent="0"
*    paragraphSpaceAfter="0"
*    paragraphSpaceBefore="0"
*    paragraphStartIndent="0"
*    renderingMode="CFF"
*    tabStops="null"
*    textAlign="START"
*    textAlignLast="START"
*    textAlpha="1"
*    textDecoration="NONE"
*    textIndent="0"
*    textJustify="INTER_WORD"
*    textRotation="AUTO"
*    trackingLeft="0"
*    trackingRight="0"
*    typographicCase="DEFAULT"
*    unfocusedTextSelectionColor=""
*    whiteSpaceCollapse="COLLAPSE"
*  /&gt;
*  </pre>
*
 *  @see spark.components.Spinner
 *  @see spark.skins.spark.NumericStepperSkin
 *  @see spark.skins.spark.NumericStepperTextInputSkin
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
    //  Class mixins
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Placeholder for mixin by SpinnerAccImpl.
     */
    mx_internal static var createAccessibilityImplementation:Function;
    
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
        maximum = 10;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts
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
    public var textDisplay:TextInput;

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
        return getBaselinePositionForPart(textDisplay);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Properties: Range
    //
    //--------------------------------------------------------------------------
    
    //---------------------------------
    // maximum
    //---------------------------------   
    
    /**
     *  @private
     */
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
    override public function set maximum(value:Number):void
    {
        maxChanged = true;
        super.maximum = value;
    }
    
    //---------------------------------
    // stepSize
    //---------------------------------   
    
    /**
     *  @private
     */
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
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  enableIME
    //----------------------------------

    /**
     *  A flag that indicates whether the IME should
     *  be enabled when the component receives focus.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get enableIME():Boolean
    {
        if (textDisplay && textDisplay.textDisplay)
            return textDisplay.textDisplay.editable;
        // most numeric steppers will be editable
        return true;
    }

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
    // valueFormatFunction
    //---------------------------------

    /**
     *  @private
     */
    private var _valueFormatFunction:Function;
    
    /**
     *  @private
     */
	private var valueFormatFunctionChanged:Boolean;
    
    /**
     *  Callback function that formats the value displayed
     *  in the skin's <code>textDisplay</code> property.
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
    public function get valueFormatFunction():Function
    {
        return _valueFormatFunction;
    }
    
    /**
     *  @private
     */
    public function set valueFormatFunction(value:Function):void
    {
        _valueFormatFunction = value;
        valueFormatFunctionChanged = true;
        invalidateProperties();
    }
    
    //--------------------------------- 
    // valueParseFunction
    //---------------------------------

    /**
     *  @private
     */
    private var _valueParseFunction:Function;
    
    /**
     *  @private
     */
	private var valueParseFunctionChanged:Boolean;
    
    /**
     *  Callback function that extracts the numeric 
     *  value from the displayed value in the 
     *  skin's <code>textDisplay</code> field.  
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
    public function get valueParseFunction():Function
    {
        return _valueParseFunction;
    }
    
    /**
     *  @private
     */
    public function set valueParseFunction(value:Function):void
    {
        _valueParseFunction = value;
        valueParseFunctionChanged = true;
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
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

     /**
     *  @private
     */
    override protected function initializeAccessibility():void
    {
        if (NumericStepper.createAccessibilityImplementation != null)
            NumericStepper.createAccessibilityImplementation(this);
    }

    /**
     *  @private
     */
    override protected function commitProperties():void
    {   
        super.commitProperties();
        
        if (maxChanged || stepSizeChanged || valueFormatFunctionChanged)
        {
            textDisplay.widthInChars = calculateWidestValue();
            maxChanged = false;
            stepSizeChanged = false;
            
            if (valueFormatFunctionChanged)
            {
                applyDisplayFormatFunction();
               
                valueFormatFunctionChanged = false;
            }
        }
        
        if (valueParseFunctionChanged)
        {
            commitTextInput(false);
            valueParseFunctionChanged = false;
        }
            
        if (maxCharsChanged)
        {
            textDisplay.maxChars = _maxChars;
            maxCharsChanged = false;
        }
        
        if (imeModeChanged)
        {
            textDisplay.imeMode = _imeMode;
            imeModeChanged = false;
        }
    } 
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == textDisplay)
        {
            textDisplay.addEventListener(FlexEvent.ENTER,
                                       textDisplay_enterHandler);
            textDisplay.addEventListener(FocusEvent.FOCUS_OUT, 
                                       textDisplay_focusOutHandler); 
            textDisplay.focusEnabled = false;
            textDisplay.maxChars = _maxChars;
            // Restrict to digits, minus sign, decimal point, and comma
            textDisplay.restrict = "0-9\\-\\.\\,";
            textDisplay.text = value.toString();
            // Set the the textDisplay to be wide enough to display
            // widest possible value. 
            textDisplay.widthInChars = calculateWidestValue(); 
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == textDisplay)
        {
            textDisplay.removeEventListener(FlexEvent.ENTER, 
                                          textDisplay_enterHandler);
        }
    }

    /**
     *  @private
     */
    override public function setFocus():void
    {
        if (stage)
        {
            stage.focus = textDisplay.textDisplay;
            
            // Since the API ignores the visual editable and selectable 
            // properties make sure the selection should be set first.
            if (textDisplay.textDisplay && 
               (textDisplay.textDisplay.editable || textDisplay.textDisplay.selectable))
            {
                textDisplay.textDisplay.selectAll();
            }
        }
    }
    
    /**
     *  @private
     */
    override protected function isOurFocus(target:DisplayObject):Boolean
    {
        return target == textDisplay.textDisplay;
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
     *  Calls commitTextInput() before stepping.
     */
    override public function changeValueByStep(increase:Boolean = true):void
    {
        commitTextInput();
        
        super.changeValueByStep(increase);
    }
    
    //--------------------------------------------------------------------------
    // 
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Commits the current text of <code>textDisplay</code> 
     *  to the <code>value</code> property. 
     *  This method uses the <code>nearestValidValue()</code> method 
     *  to round the input value to the closest multiple of 
     *  the <code>snapInterval</code> property, 
     *  and constrains the value to the range defined by the 
     *  <code>maximum</code> and <code>minimum</code> properties.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private function commitTextInput(dispatchChange:Boolean = false):void
    {
        var inputValue:Number;
        var prevValue:Number = value;
        
        if (valueParseFunction != null)
            inputValue = valueParseFunction(textDisplay.text);
        else 
            inputValue = Number(textDisplay.text);
        
        if ((textDisplay.text && textDisplay.text.length != value.toString().length)
            || textDisplay.text == "" || (inputValue != value && 
            (Math.abs(inputValue - value) >= 0.000001 || isNaN(inputValue))))
        {
            setValue(nearestValidValue(inputValue, snapInterval));
            
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
        
    /**
     *  @private
     *  Helper method that returns a number corresponding
     *  to the length of the maximum value displayable in 
     *  the textDisplay.  
     */
    private function calculateWidestValue():Number
    {
        var widestNumber:Number = minimum.toString().length >
                              maximum.toString().length ?
                              minimum :
                              maximum;
        widestNumber += stepSize;
        
        if (valueFormatFunction != null)
            return valueFormatFunction(widestNumber).length;
        else 
           return widestNumber.toString().length;
    }
    
    /**
     *  @private
     *  Helper method that applies the valueFormatFunction  
     */
    private function applyDisplayFormatFunction():void
    {
        if (valueFormatFunction != null)
            textDisplay.text = valueFormatFunction(value);
        else
            textDisplay.text = value.toString();
    }
    
    //--------------------------------------------------------------------------
    // 
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */  
    override protected function focusInHandler(event:FocusEvent):void
    {
        super.focusInHandler(event);

        addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true);
    }
    
    /**
     *  @private
     */  
    override protected function focusOutHandler(event:FocusEvent):void
    {
        super.focusOutHandler(event);

        removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true);
    }
   
        
    /**
     *  @private
     *  When the enter key is pressed, NumericStepper commits the
     *  text currently displayed.
     */
    private function textDisplay_enterHandler(event:Event):void
    {
        commitTextInput(true);
    }
    
    /**
     *  @private
     *  When the enter key is pressed, NumericStepper commits the
     *  text currently displayed.
     */
    private function textDisplay_focusOutHandler(event:Event):void
    {
        commitTextInput(true);
    }
}

}
