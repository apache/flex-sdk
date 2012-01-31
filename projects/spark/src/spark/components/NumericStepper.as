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

/**
 *  The NumericStepper control lets the user select
 *  a number from an ordered set.
 *  The NumericStepper control consists of a single-line
 *  input text field and a pair of arrow buttons
 *  for stepping through the possible values.
 *  The Up Arrow and Down Arrow keys also cycle through 
 *  the values. An inputted value is committed whenever
 *  the user presses enter, focuses out of the
 *  NumericStepper, or steps the NumericStepper.
 * 
 *  @see mx.components.Spinner
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
    // SkinParts
    //
    //--------------------------------------------------------------------------

    [SkinPart]
    
    /**
     *  <code>textInput</code> is a SkinPart that defines a
     *  TextInput which allows a user to edit the value of
     *  the NumericStepper. The value is rounded and committed
     *  when the user presses enter, focuses out of
     *  the NumericStepper, or steps the NumericStepper.
     */
    public var textInput:FxTextInput;

    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var valueChanged:Boolean = false;
    
    /**
     *  @private
     */
    override public function set value(newValue:Number):void
    {
    	if (newValue == value)
    	   return;
    	   
    	super.value = newValue;
    	
    	valueChanged = true;
    	invalidateProperties();
    }
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function setValue(value:Number):void
    {
    	super.setValue(value);
    	
    	valueChanged = true;
    	invalidateProperties();
    }

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
    	super.commitProperties();
    	
    	if (valueChanged)
    	{
    		valueChanged = false;
    		textInput.text = value.toString();
    	}
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
    
    /**
     *  Commits the current text of <code>textInput</code> as
     *  <code>value</code> after rounding the new value using
     *  <code>nearestValidValue</code>.
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
    // Event Handlers
    //
    //--------------------------------------------------------------------------
    
    //--------------------------------- 
    // Keyboard handlers
    //---------------------------------
    
    /**
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