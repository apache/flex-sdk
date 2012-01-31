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
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.formats.TextLayoutFormat;

import mx.core.mx_internal;
import mx.core.ScrollPolicy;
import mx.events.FlexEvent;

import spark.components.supportClasses.SkinnableTextBase;
import spark.events.TextOperationEvent;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  @copy spark.components.supportClasses.GroupBase#style:symbolColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.Scroller#style.horizontalScrollPolicy
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="horizontalScrollPolicy", type="String", inherit="no", enumeration="off,on,auto")]

/**
 *  @copy spark.components.Scroller#style.verticalScrollPolicy
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="verticalScrollPolicy", type="String", inherit="no", enumeration="off,on,auto")]

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

[DefaultProperty("content")]

[DefaultTriggerEvent("change")]

[IconFile("TextArea.png")]

/**
 *  TextArea is a text-entry control that lets users enter and edit
 *  multiple lines of richly-formatted text.
 *
 *  <p>It can display horizontal and vertical scrollbars
 *  for scrolling through the text,
 *  and also supports vertical scrolling with the mouse wheel.</p>
 *
 *  <p>It does not include any user interface for changing
 *  the formatting of the text.
 *  But it offers APIs which can do this programmatically;
 *  these make it possible, for example, for you to create 
 *  a Bold button that makes the selected text bold.</p>
 *
 *  <p>This Spark version of TextArea, which is new with Flex 4,
 *  makes use of the new Text Layout Framework (TLF) library,
 *  which in turn builds on the new Flash Text Engine (FTE)
 *  in Flash Player 10.
 *  In combination, these layers provide text editing with
 *  high-quality international typography and layout.
 *  The older MX version of TextArea displays text using the older
 *  TextField class.</p>
 *
 *  <p>The most important differences to understand are:
 *  <ul>
 *    <li>The Spark version offers better typography, better support
 *        for international languages, and better text layout.</li>
 *    <li>The Spark version has an object-oriented model of rich text,
 *        while the MX version does not.</li>
 *    <li>The Spark version has better support for displaying
 *        large amounts of text.</li>
 *    <li>The Spark version requires that fonts be embedded
 *        differently than the MX version.
 *        Consult the documentation regarding how to use the
 *        <code>embedAsCFF</code> attribute when you embed a font.</li>
 *  </ul></p>
 *
 *  <p>The Spark TextArea uses TLF's object-oriented model of rich text,
 *  in which text layout elements such as divisions, paragraphs, spans,
 *  hyperlinks, and images are represented at runtime by ActionScript
 *  objects which can be programmatically accessed and manipulated.
 *  The central object in TLF for representing rich text is a
 *  TextFlow, so you specify rich text for the Spark TextArea to display
 *  by setting its <code>textFlow</code> property to a TextFlow instance.
 *  Please see the description of the <code>textFlow</code>
 *  property for information about how to create one,
 *  such as by importing TLF markup.
 *  If you don't need to display text that has multiple formats,
 *  simply set the <code>text</code> property to a "plain text" String.
 *  See the description of the <code>text</code> and <code>textFlow</code>
 *  properties for information about how they interact;
 *  for example, you can set one and get the other.</p>
 *
 *  <p>At compile time, you can simply put TLF markup tags inside
 *  the TextArea tag, as in
 *  <pre>
 *  &lt;s:TextArea&gt;Hello &lt;s:span fontWeight="bold"&gt;World!&lt;/s:span&gt;&lt;/s:TextArea&gt;
 *  </pre>
 *  In this case, the MXML compiler sets the <code>content</code>
 *  property, causing a TextFlow to be automatically created
 *  from the FlowElements that you specify.</p>
 *
 *  <p>The default text formatting is determined by CSS styles
 *  such as <code>fontFamily</code>, <code>fontSize</code>.
 *  Any formatting information in the TextFlow overrides
 *  the default formatting provided by the CSS styles.</p>
 *
 *  <p>You can control the spacing between lines with the
 *  <code>lineHeight</code> style and the spacing between
 *  paragraphs with the <code>paragraphSpaceBefore</code>
 *  and <code>paragraphSpaceAfter</code> styles.
 *  You can align or justify the text using the <code>textAlign</code>
 *  and <code>textAlignLast</code> styles.
 *  You can inset the text from the controls border using the
 *  <code>paddingLeft</code>, <code>paddingTop</code>, 
 *  <code>paddingRight</code>, and <code>paddingBottom</code> styles.</p>
 *
 *  <p>By default, the text wraps at the right edge of the control
 *  and a vertical scrollbar appears automatically when there is more
 *  text than fits.
 *  If you set the <code>lineBreak</code> style to <code>"explicit"</code>,
 *  new lines will start only at explicit lines breaks, such as
 *  if you use CR (<code>"\r"</code>), LF (<code>"\n"</code>),
 *  or CR+LF (<code>"\r\n"</code>) in <code>text</code>
 *  or if you use <code>&lt;p&gt;</code> and <code>&lt;br/&gt;</code>
 *  in TLF markup.
 *  In that case, a horizontal scrollbar will automatically appear
 *  if any lines are wider than the control,</p>
 *
 *  <p>The <code>widthInChars</code> and <code>heightInChars</code>
 *  properties provide a convenient way to specify the width and height
 *  in a way that scales with the font size.
 *  Of course, you can also specify an explicit width or height in pixels,
 *  or use a percent width and height, or use constraints such as
 *  <code>left</code> and <code>right</code>
 *  or <code>top</code> and <code>bottom</code>.</p>
 *
 *  <p>You can use the <code>maxChars</code> property to limit the number
 *  of character that the user can enter, and the <code>restrict</code>
 *  to limit which characters the user can enter.</p>
 *
 *  <p>When the user presses the Enter key, a new paragraph is started;
 *  it does not cause a line break within the current paragraph.</p>
 *
 *  <p>If you don't want the text to be editable,
 *  set the <code>editable</code> property to <code>false</code>.
 *  If you don't even want it to be selectable,
 *  set the <code>selectable</code> property to <code>false</code>.</p>
 *
 *  <p>This control is a skinnable control whose skin uses a
 *  RichEditableText to display and edit the text,
 *  and a Scroller to provide scrollbars.
 *  The RichEditableText can be accessed as <code>textDisplay</code>
 *  and the Scroller as <code>scroller</code>.</p>
 *
 *  <p>Because its RichEditableText uses TLF, the Spark TextArea
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
 *  <p>Also as a result of using TLF, the Spark TextArea supports
 *  unlimited undo/redo within one editing session.
 *  An editing session starts when the control gets keyboard focus
 *  and ends when the control loses focus.</p>
 *
 *  <p>The TextArea control has the following default characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>188 pixels wide by 149 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Minimum size</td>
 *           <td>36 pixels wide and 36 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Maximum size</td>
 *           <td>10000 pixels wide and 10000 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Default skin class</td>
 *           <td>spark.skins.spark.TextAreaSkin</td>
 *        </tr>
 *     </table>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:TextArea&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:TextArea
 *    <strong>Properties</strong>
 *    heightInLines=""
 *    textFlow="24"
 *    widthInChars=""
 *  
 *    <strong>Styles</strong>
 *    horizontalScrollPolicy="<i>No default</i>"
 *    symbolColor=""
 *    verticalScrollPolicy="<i>No default</i>"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.components.TextInput
 *  @see spark.skins.spark.TextAreaSkin
 *  @see spark.primitives.RichText
 *  @see spark.primitives.RichEditableText
 *  @see spark.primitives.SimpleText
 *
 *  @includeExample examples/TextAreaExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class TextArea extends SkinnableTextBase
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
    public function TextArea()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var horizontalScrollPolicyChanged:Boolean = false;
    
    /**
     *  @private
     */
    private var verticalScrollPolicyChanged:Boolean = false;
            
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
        // Of 'text', 'textFlow', and 'content', the last one set wins.
        
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
    //  content
    //----------------------------------

    /**
     *  @private
     *  This metadata tells the MXML compiler to disable some of its default
     *  interpretation of the value specified for the 'content' property.
     *  Normally, for properties of type Object, it assumes that things
     *  looking like numbers are numbers and things looking like arrays
     *  are arrays. But <content>1</content> should generate code to set the
     *  content to  the String "1", not the int 1, and <content>[1]</content>
     *  should set it to the String "[1]", not the Array [ 1 ].
     *  However, {...} continues to be interpreted as a databinding
     *  expression, and @Resource(...), @Embed(...), etc.
     *  as compiler directives.
     *  Similar metadata on TLF classes causes the same rules to apply
     *  within <p>, <span>, etc.
     */
    [RichTextContent]
        
    /**
     *  This write-only property is for internal use by the MXML compiler.
     *  Please use the <code>textFlow</code> property to set
     *  rich text content.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function set content(value:Object):void
    {
        // Of 'text', 'textFlow', and 'content', the last one set wins.
        
        setContent(value);
    }
    
    //----------------------------------
    //  textFlow
    //----------------------------------

    // Note:
    // The 'textFlow' property is not bindable because you can't share a 
    // TextFlow between two editable components, due to the way that FTE and 
    // TLF work.

    /**
     *  @copy spark.primitives.RichEditableText#textFlow
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get textFlow():TextFlow
    {
        return getTextFlow();
    }

    /**
     *  @private
     */
    public function set textFlow(value:TextFlow):void
    {
        // Of 'text', 'textFlow', and 'content', the last one set wins.

        setTextFlow(value);
    }

    //----------------------------------
    //  heightInLines
    //----------------------------------

    /**
     *  @copy spark.primitives.RichEditableText#heightInLines
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get heightInLines():Number
    {
        return getHeightInLines();
    }

    /**
     *  @private
     */
    public function set heightInLines(value:Number):void
    {
        setHeightInLines(value);
    }
    
    //----------------------------------
    //  scroller
    //----------------------------------

    [SkinPart(required="false")]

    /**
     *  The optional Scroller in the skin,
	 *  used to scroll the RichEditableText.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var scroller:Scroller;

    //----------------------------------
    //  widthInChars
    //----------------------------------

    /**
     *  @copy spark.primitives.RichEditableText#widthInChars
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
    override public function styleChanged(styleProp:String):void
    {
        var allStyles:Boolean = (styleProp == null || styleProp == "styleName");
        super.styleChanged(styleProp);

        if (allStyles || styleProp == "horizontalScrollPolicy")
        {
            horizontalScrollPolicyChanged = true;
            invalidateProperties();
        }
        if (allStyles || styleProp == "verticalScrollPolicy")
        {
            verticalScrollPolicyChanged = true;
            invalidateProperties();
        }
    }
    
    /**
     *  @private
     *  Pushes various TextInput properties down into the RichEditableText. 
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (horizontalScrollPolicyChanged)
        {
            if (scroller)
                scroller.setStyle("horizontalScrollPolicy", getStyle("horizontalScrollPolicy"));
            horizontalScrollPolicyChanged = false;
        }

        if (verticalScrollPolicyChanged)
        {
            if (scroller)
                scroller.setStyle("verticalScrollPolicy", getStyle("verticalScrollPolicy"));
            verticalScrollPolicyChanged = false;
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
            // In default.css, the TextArea selector has a declaration
            // for lineBreak which sets it to "toFit".

            // The skin is loaded after the intial properties have been
            // set so these wipe out explicit sets.
            textDisplay.multiline = true;
        }
        
        // The scroller, between textDisplay and this in the chain, should not 
        // getFocus.
        if (instance == scroller)
        {
            scroller.focusEnabled = false;
            
            // TLF does scrolling in real numbers.  If the scroller doesn't
            // round to ints then the sets of verticalScrollPosition and
            // horizontalScrollPosition will be no-ops which is desirable.
            if (scroller.horizontalScrollBar)
                scroller.horizontalScrollBar.snapInterval = 0;
            if (scroller.verticalScrollBar)
                scroller.verticalScrollBar.snapInterval = 0;
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @copy spark.primitives.RichEditableText#getFormatOfRange()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getFormatOfRange(requestedFormats:Vector.<String>=null,
                                     anchorPosition:int=-1,
                                     activePosition:int=-1):TextLayoutFormat
    {
        if (!textDisplay)
            return null;

        return textDisplay.getFormatOfRange(requestedFormats, anchorPosition, 
                                            activePosition);
    }

    /**
     *  @copy spark.primitives.RichEditableText#setFormatOfRange()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setFormatOfRange(format:TextLayoutFormat,
                                     anchorPosition:int=-1, 
                                     activePosition:int=-1):void
    {
        if (!textDisplay)
            return;

        textDisplay.setFormatOfRange(format, anchorPosition, activePosition);
    }

    /**
     *  @copy spark.primitives.RichEditableText#scrollToRange()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function scrollToRange(anchorPosition:int = 0,
                                  activePosition:int = int.MAX_VALUE):void
    {
        if (!textDisplay)
            return;

        textDisplay.scrollToRange(anchorPosition, activePosition);
    }
}

}
