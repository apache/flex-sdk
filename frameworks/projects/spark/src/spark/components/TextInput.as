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
    
import flash.events.Event;
import flash.events.FocusEvent;

import mx.components.TextView;
import mx.components.baseClasses.FxTextBase;
import mx.components.baseClasses.FxComponent;
import mx.events.TextOperationEvent;

import flashx.textLayout.formats.LineBreak;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the user pressed the Enter key.
 *
 *  @eventType mx.events.FlexEvent.ENTER
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="enter", type="mx.events.FlexEvent")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultProperty("text")]

[IconFile("FxTextInput.png")]

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
 *  Documentation is not currently available.
 *
 *  @includeExample examples/FxTextInputExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class FxTextInput extends FxTextBase
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
    public function FxTextInput()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

	//----------------------------------
	//  widthInChars
    //----------------------------------

    /**
     *  @private
     */
    private var _widthInChars:Number = 15;

    /**
     *  @private
     */
    private var widthInCharsChanged:Boolean = false;
    
    /**
     *  The default width for the FxTextInput, measured in characters.
     *  The width of the "0" character is used for the calculation,
     *  since in most fonts the digits all have the same width.
     *  So if you set this property to 5, it will be wide enough
     *  to let the user enter 5 digits.
     *
     *  @default
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get widthInChars():Number
    {
        return _widthInChars;
    }

    /**
     *  @private
     */
    public function set widthInChars(value:Number):void
    {
        if (value == _widthInChars)
            return;

        _widthInChars = value;
        widthInCharsChanged = true;

        invalidateProperties();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
        
    /**
     *  @private
     *  Pushes various FxTextInput properties down into the TextView. 
     */
    override protected function commitProperties():void
    {
        super.commitProperties();

        if (widthInCharsChanged)
		{
			textView.widthInChars = _widthInChars;
			widthInCharsChanged = false;
		}
	}

    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);

        if (instance == textView)
        {
            // Set the TextView to allow only one line of input.
            // In default.css, the FxTextInput selector has a declaration
            // for lineBreak which sets it to "explicit".  It needs to be on
            // FxTextInput rather than TextView so that if changed later it
            // will be inherited.  It needs to be set with the default
            // before the possibility that it is changed when FxTextInput is
            // created.  In this case, setting it here, would overwrite
            // that change.
            textView.heightInLines = 1;
            textView.multiline = false;
            textView.autoSize = false;
        }
    }
}

}

