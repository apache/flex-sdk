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
import flash.events.FocusEvent;

import spark.components.supportClasses.TextBase;
import spark.components.supportClasses.SkinnableComponent;
import spark.events.TextOperationEvent;

import flashx.textLayout.formats.LineBreak;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the user presses the Enter key.
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
//  Skin states
//--------------------------------------

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

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultProperty("text")]

[IconFile("TextInput.png")]

/**
 *  A text field that lets users enter and edit a single line
 *  of single-styled text. Can contain alphanumeric data, but
 *  input is interpreted as a String.
 *
 *  @includeExample examples/TextInputExample.mxml
 *
 *  @see spark.primitives.SimpleText
 *  @see spark.primitives.RichEditableText
 *  @see TextArea
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class TextInput extends TextBase
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
    public function TextInput()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  text
    //----------------------------------

    [Bindable("change")]
    [Bindable("textChanged")]
    
    // Compiler will strip leading and trailing whitespace from text string.
    [CollapseWhiteSpace]
       
    /**
     *  @private
     */
    override public function set text(value:String):void
    {
        super.text = value;
        
        // Trigger bindings to textChanged.
        dispatchEvent(new Event("textChanged"));
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);

        if (instance == textView)
        {
            // In default.css, the TextInput selector has a declaration
            // for lineBreak which sets it to "explicit".  It needs to be on
            // TextInput rather than RichEditableText so that if changed later it
            // will be inherited.
            textView.multiline = false;
            
            // TextInput should always be 1 line.
            textView.heightInLines = 1;
        }
    }
}

}

