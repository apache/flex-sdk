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

package mx.components
{

import flash.display.DisplayObject;
import flash.events.Event;

import mx.events.FlexEvent;
import mx.managers.IFocusManagerComponent;

[IconFile("FxNumericStepper.png")]

/**
 *  The FxNumericStepper control lets you select
 *  a number from an ordered set.
 *  The FxNumericStepper provides the same functionality as
 *  the FxSpinner component, but adds a TextInput control
 *  so that you can directly edit the value of the component,
 *  rather than modifying it by using the control's arrow buttons.
 *
 *  <p>The FxNumericStepper control consists of a single-line
 *  input text field and a pair of arrow buttons
 *  for stepping through the possible values.
 *  The Up Arrow and Down Arrow keys also cycle through 
 *  the values. 
 *  An input value is committed when
 *  the user presses the Enter key, removes focus from the
 *  component, or steps the FxNumericStepper by pressing an arrow button
 *  or by calling the <code>step()</code> method.</p>
 *
 *  @see mx.components.FxSpinner
 * 
 *  @includeExample examples/FxNumericStepperExample.mxml
 */
public class FxNumericStepper extends FxSpinner implements IFocusManagerComponent
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor
     */  
    public function FxNumericStepper()
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
     *  the FxNumericStepper component. 
     *  The value is rounded and committed
     *  when the user presses enter, focuses out of
     *  the FxNumericStepper, or steps the FxNumericStepper.
     */
    public var textInput:FxTextInput;

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
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();

        if (maxCharsChanged)
        {
            textInput.maxChars = _maxChars;
            maxCharsChanged = false;
        }
    }
    
    /**
     *  @private
     */
    override protected function setValue(newValue:Number):void
    {
        super.setValue(newValue);
        textInput.text = value.toString();        
    }
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == textInput)
        {
            textInput.focusEnabled = false;
            textInput.maxChars = _maxChars;
            // restrict to digits, minus sign, decimal point, and comma
            textInput.restrict = "0-9\\-\\.\\,";
            textInput.addEventListener(FlexEvent.ENTER,
                                       textInput_enterHandler);
            textInput.text = value.toString();
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
    override protected function enableSkinParts(value:Boolean):void
    {
        super.enableSkinParts(value);
        if (textInput)
            textInput.enabled = value;
    }   

    /**
     *  @private
     */
    override public function setFocus():void
    {
        if (stage)
            stage.focus = textInput.textView;
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
     */
    protected function commitTextInput():void
    {
        var inputValue:Number = Number(textInput.text);
        var prevValue:Number = value;
        
        if (textInput.text == "" || (inputValue != value && 
            (Math.abs(inputValue - value) >= 0.000001 || isNaN(inputValue))))
        {
            setValue(nearestValidValue(inputValue, valueInterval));
            
            // Dispatch valueCommit if the display needs to change.
            if (value == prevValue && inputValue != prevValue)
                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
        }
        
        // Select all the text.
        textInput.setSelection();
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
    protected function textInput_enterHandler(event:Event):void
    {
        var prevValue:Number = value;
        
        commitTextInput();
        
        if (value != prevValue)
            dispatchEvent(new Event("change"));
    }
}

}