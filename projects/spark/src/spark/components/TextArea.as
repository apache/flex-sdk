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

import spark.components.supportClasses.TextBase;
import mx.core.ScrollPolicy;
import mx.events.FlexEvent;
import spark.events.TextOperationEvent;

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
 *  The TextArea component is a text field that lets users enter
 *  and edit multiple lines of rich text. TextArea supports horizontal
 *  and vertical scrolling.
 *
 *  <p>The text content in TextArea can contain multiple paragraphs, 
 *  spans, inline graphics, multiple columns, and so on. Formatting 
 *  is preserved as the user edits. TextArea does not include any UI
 *  for changing the formatting of text; text can be changed programmatically
 *  only.</p>
 *
 *  @see spark.primitives.RichText
 *  @see spark.primitives.RichEditableText
 *  @see spark.primitives.SimpleText
 *  @see TextInput TextInput class
 *
 *  @includeExample examples/TextAreaExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class TextArea extends TextBase
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
        // Setting 'text' temporarily causes 'content' to become null.
        // Later, after the 'text' has been committed into the TextFlow,
        // getting 'content' will return the TextFlow.
        setContent(null);
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
     *  Once the text or content is composed initially, the content getter
     *  will return the TextFlow, rather than the initial content.
     */
    private var useTextFlowForContent:Boolean = false;
    
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
     *  Documentation is not currently available.
     * 
     *  A TextFlow object is not shareable.  To clone a TextFlow use
     *  TextFlow.deepCopy().
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get content():Object
    {
        return textView && useTextFlowForContent ? textView.textFlow : 
                                                   getContent();
    }

    /**
     *  @private
     */
    public function set content(value:Object):void
    {
        if (value == getContent())
            return;

        // Setting 'content' temporarily causes 'text' to become null.
        // Later, after the 'content' has been committed into the TextFlow,
        // getting 'text' will extract the text from the TextFlow.
        super.text = null;
        setContent(value);

        useTextFlowForContent = false;
    }
    
    //----------------------------------
    //  heightInLines
    //----------------------------------

    /**
     *  Documentation is not currently available.
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
     *  The optional Scroller used to scroll the RichEditableText.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var scroller:Scroller;

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

        if (instance == textView)
        {
            // In default.css, the TextArea selector has a declaration
            // for lineBreak which sets it to "toFit".  It needs to be on
            // TextArea rather than RichEditableText so that if changed later it
            // will be inherited.

            // The skin is loaded after the intial properties have been
            // set so these wipe out explicit sets.
			textView.multiline = true;
        }
        
        // The scroller, between textView and this in the chain, should not 
        // getFocus.
        if (instance == scroller)
        {
            scroller.focusEnabled = false;
            
            // TLF does scrolling in real numbers.  If the scroller doesn't
            // round to ints then the sets of verticalScrollPosition and
            // horizontalScrollPosition will be no-ops which is desirable.
            if (scroller.horizontalScrollBar)
                scroller.horizontalScrollBar.valueInterval = 0;
            if (scroller.verticalScrollBar)
                scroller.verticalScrollBar.valueInterval = 0;
        }            
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function export():XML
    {
        if (!textView)
            return null;

        return textView.export();
    }

    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getSelectionFormat(names:Array = null):Object
    {
        if (!textView)
            return null;

        return textView.getSelectionFormat(names);
    }

    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setSelectionFormat(attributes:Object):void
    {
        if (!textView)
            return;

        textView.setSelectionFormat(attributes);
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers: TextBase
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Dispatched when there is an editing operation in RichEditableText.
     */
    override protected function textView_changeHandler(
                                        event:TextOperationEvent):void
    {
        //trace("TextArea.textView_changeHandler");

        // A compose has been done so switch from the user's specified content
        // (or null if text was specified) to the textFlow.
        useTextFlowForContent = true;

        super.textView_changeHandler(event);                       
    }

}

}
