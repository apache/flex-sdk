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
 *  @see spark.skins.spark.TextAreaSkin
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
     *  The TextFlow displayed by this component.
     * 
     *  <p>A TextFlow is the most important class
     *  in the Text Layout Framework.
     *  It is the root of a tree of FlowElements
     *  representing rich text content.</p>
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

    //----------------------------------
    //  widthInChars
    //----------------------------------

    /**
     *  Documentation is not currently available.
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
            
            textDisplay.addEventListener("styleChanged", 
                                         textDisplay_styleChangedHandler);
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

    /**
     *  @private
     */
    override protected function partRemoved(partName:String, 
                                            instance:Object):void
    {                
        super.partRemoved(partName, instance);
                
        if (instance == textDisplay)
        {
            textDisplay.removeEventListener("styleChanged", 
                                            textDisplay_styleChangedHandler);
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
     *  Documentation is not currently available.
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
     *  @copy flashx.textLayout.container.ContainerController#scrollToPosition() 
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

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Called when the RichEditableText dispatches a 'styleChanged' event.
     */
    private function textDisplay_styleChangedHandler(event:Event):void
    {
        if (!scroller)
            return;
            
        // If there is a scroller and line breaks are "toFit" turn off the 
        // horizontal scroll bar so the scroller will give us a consistent 
        // width and the text will wrap in the same place.           
        if (textDisplay.getStyle("lineBreak") == "toFit")
        {
            if (scroller.getStyle("horizontalScrollPolicy") != "off")
                scroller.setStyle("horizontalScrollPolicy", "off");
        }
        else
        {
            // This could potentially wipe out a user specified setting.
            // Workaround it by settting Scroller's horizontalScrollPolicy
            // after every RET style change.
            if (scroller.getStyle("horizontalScrollPolicy") == "off")
                scroller.setStyle("horizontalScrollPolicy", "auto");
        }
    }
}

}
