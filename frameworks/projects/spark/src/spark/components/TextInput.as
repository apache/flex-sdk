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

import flashx.textLayout.formats.LineBreak;

import mx.core.mx_internal;
import mx.events.FlexEvent;
    
import spark.components.supportClasses.SkinnableTextBase;
import spark.components.supportClasses.SkinnableComponent;
import spark.events.TextOperationEvent;

use namespace mx_internal;

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
//  Excluded APIs
//--------------------------------------

[Exclude(name="verticalAlign", kind="style")]
[Exclude(name="lineBreak", kind="style")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[AccessibilityClass(implementation="spark.accessibility.TextInputAccImpl")]

[DefaultProperty("text")]

[DefaultTriggerEvent("change")]

[IconFile("TextInput.png")]

/**
 *  TextInput is a text-entry control that lets users enter and edit
 *  a single line of uniformly-formatted text.
 *
 *  <p>This Spark version of TextInput, which is new with Flex 4,
 *  makes use of the new Text Layout Framework (TLF) library,
 *  which in turn builds on the new Flash Text Engine (FTE) in Flash Player 10.
 *  In combination, they provide text editing with
 *  high-quality international typography.
 *  The MX version of TextInput displays text using the older
 *  TextField class.</p>
 *
 *  <p>You can set the text to be displayed, or get the text that the user
 *  has entered, using the <code>text</code> property.
 *  This property is a String, so if the user enter a numeric value
 *  it will be reported, for example, as "123.45" rather than 123.45.</p>
 *
 *  <p>The text is formatted using CSS styles such as <code>fontFamily</code>
 *  and <code>fontSize</code>.</p>
 *
 *  <p>The <code>widthInChars</code> property provides a convenient way
 *  to specify the width in a way that scales with the font size.
 *  Of course, you can also specify an explicit width in pixels,
 *  a percent width, or use constraints such as <code>left</code>
 *  and <code>right</code>.
 *  You do not normally do anything to specify the height;
 *  the control's default height is sufficient to display
 *  one line of text.</p>
 *
 *  <p>You can use the <code>maxChars</code> property to limit the number
 *  of character that the user can enter, and the <code>restrict</code>
 *  to limit which characters the user can enter.
 *  To use this control for password input, set the
 *  <code>displayAsPassword</code> property to <code>true</code>.</p>
 *
 *  <p>This control dispatches a <code>FlexEvent.ENTER</code> event
 *  when the user pressed the Enter key rather than inserting a line
 *  break, because this control does not support entering multiple
 *  lines of text.</p>
 *
 *  <p>This control is a skinnable control whose skin contains a
 *  RichEditableText instance that handles displaying and editing the text.
 *  (The skin also handles drawing the border and background.)
 *  This RichEditableText can be accessed as the <code>textDisplay</code>
 *  object.</p>
 *
 *  <p>As a result of its RichEditableText using TLF, the Spark TextInput
 *  supports displaying left-to-right (LTR) text such as French,
 *  right-to-left (RTL) text such as Arabic, and bidirectional text
 *  such as a French phrase inside of an Arabic one.
 *  If the predominant text direction is right-to-left,
 *  set the <code>direction</code> style to <code>"rtl"</code>.
 *  The <code>textAlign</code> style defaults to <code>"start"</code>,
 *  which makes the text left-aligned when <code>direction</code>
 *  is <code>"ltr"</code> and right-aligned when <code>direction</code>
 *  is <code>"rtl"</code>.
 *  To get the opposite alignment,
 *  set <code>textAlign</code> to <code>"end"</code>.</p>
 *
 *  <p>Also as a result of using TLF, the Spark TextInput supports
 *  unlimited undo/redo within one editing session.
 *  An editing session starts when the control gets keyboard focus
 *  and ends when the control loses focus.</p>
 *
 *  <p>The TextInput control has the following default characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>188 pixels wide by 22 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Minimum size</td>
 *           <td>2 pixels wide and 2 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Maximum size</td>
 *           <td>10000 pixels wide and 10000 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Default skin class</td>
 *           <td>spark.skins.spark.TextInputSkin</td>
 *        </tr>
 *     </table>
 *
 *  @includeExample examples/TextInputExample.mxml
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:TextInput&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:TextInput
 *    <strong>Properties</strong>
 *    widthInChars=""
 *  
 *    <strong>Events</strong>
 *    enter="<i>No default</i>"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.skins.spark.TextInputSkin
 *  @see spark.components.Label
 *  @see spark.components.RichEditableText
 *  @see TextArea
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class TextInput extends SkinnableTextBase
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class mixins
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Placeholder for mixin by TextInputAccImpl.
     */
    mx_internal static var createAccessibilityImplementation:Function;

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
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  widthInChars
    //----------------------------------
    
    [Inspectable(minValue="0.0")]    

    /**
     *  The default width of the control, measured in em units.
	 *
	 *  <p>An em is a unit of typographic measurement
	 *  equal to the point size.
	 *  It is not necessarily exactly the width of the "M" character,
	 *  but in many fonts the "M" is about one em wide.
     *  The control's <code>fontSize</code> style is used,
	 *  to calculate the em unit in pixels.</p>
	 *
	 *  <p>You would, for example, set this property to 20 if you want
	 *  the width of the TextInput to be sufficient
	 *  to input about 20 characters of text.</p>
	 *
	 *  <p>This property will be ignored if you specify an explicit width,
	 *  a percent width, or both <code>left</code> and <code>right</code>
	 *  constraints.</p>
	 *
	 *  @default 10
	 *
	 *  @see spark.primitives.heightInLines
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get widthInChars():Number
    {
        return getWidthInChars();
    }

    /**
     *  @private
     */
    public function set widthInChars(value:Number):void
    {
        setWidthInChars(value);
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
        if (TextInput.createAccessibilityImplementation != null)
            TextInput.createAccessibilityImplementation(this);
    }


    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);

        if (instance == textDisplay)
        {
            textDisplay.multiline = false;
            
            // TextInput should always be 1 line.
            textDisplay.heightInLines = 1;
        }
    }
}

}
