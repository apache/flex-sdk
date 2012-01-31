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
import mx.core.mx_internal;
import mx.core.ScrollPolicy;
import spark.events.TextOperationEvent;

//--------------------------------------
//  Other metadata
//--------------------------------------

/**
 *  @copy spark.components.supportClasses.GroupBase#symbolColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes")]

[DefaultProperty("content")]

[IconFile("TextArea.png")]

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
    private var textInvalid:Boolean = false;

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
    override public function get text():String
    {
        if (textInvalid)
        {
            mx_internal::_text = textView.text;
            textInvalid = false;
        }

        return mx_internal::_text;
    }

	/**
	 *  @private
	 */
    override public function set text(value:String):void
    {
        // Setting 'text' temporarily causes 'content' to become null.
        // Later, after the 'text' has been committed into the TextFlow,
        // getting 'content' will return the TextFlow.
        _content = null;
        contentChanged = false;
        
        super.text = value;
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
	 */
	private var _content:Object;

	/**
	 *  @private
	 */
	private var contentChanged:Boolean = false;

	[Bindable("change")]
	[Bindable("contentChanged")]
	[Bindable("textChanged")]
	
	/**
	 *  Documentation is not currently available.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get content():Object
	{
		return _content;
	}

	/**
	 *  @private
	 */
	public function set content(value:Object):void
	{
		if (value == _content)
			return;

        // Setting 'content' temporarily causes 'text' to become null.
        // Later, after the 'content' has been committed into the TextFlow,
        // getting 'text' will extract the text from the TextFlow.
        mx_internal::_text = null;
        mx_internal::textChanged = false;

		_content = value;
		contentChanged = true;

		invalidateProperties();
		
		dispatchEvent(new Event("contentChanged"));
	}
    
	//----------------------------------
	//  heightInLines
    //----------------------------------

	/**
	 *  @private
	 */
	private var _heightInLines:Number = 10;

	/**
	 *  @private
	 */
	private var heightInLinesChanged:Boolean = false;
	
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
		return _heightInLines;
	}

	/**
	 *  @private
	 */
	public function set heightInLines(value:Number):void
	{
		if (value == _heightInLines)
			return;

		_heightInLines = value;
		heightInLinesChanged = true;

		invalidateProperties();
	}
    
	//----------------------------------
	//  horizontalScrollPolicy
    //----------------------------------

	/**
	 *  @private
	 */
	private var _horizontalScrollPolicy:String = ScrollPolicy.AUTO;

    /**
     *  @private
     */
    private var horizontalScrollPolicyChanged:Boolean = false;
	
	/**
	 *  Documentation is not currently available.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get horizontalScrollPolicy():String
	{
		return _horizontalScrollPolicy;
	}

	/**
	 *  @private
	 */
	public function set horizontalScrollPolicy(value:String):void
	{
		if (value == _horizontalScrollPolicy)
			return;

		_horizontalScrollPolicy = value;
        horizontalScrollPolicyChanged = true;

		invalidateProperties();
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
	//  verticalScrollPolicy
    //----------------------------------

	/**
	 *  @private
	 */
	private var _verticalScrollPolicy:String = ScrollPolicy.AUTO;

    /**
     *  @private
     */
    private var verticalScrollPolicyChanged:Boolean = false;
	
	/**
	 *  Documentation is not currently available.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get verticalScrollPolicy():String
	{
		return _verticalScrollPolicy;
	}

	/**
	 *  @private
	 */
	public function set verticalScrollPolicy(value:String):void
	{
		if (value == _verticalScrollPolicy)
			return;

		_verticalScrollPolicy = value;
        verticalScrollPolicyChanged = true;

		invalidateProperties();
	}
    
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
	 *  The default width for the TextInput, measured in characters.
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
	 *  Pushes various TextInput properties down into the RichEditableText. 
	 */
    override protected function commitProperties():void
	{
        super.commitProperties();
        
        if (horizontalScrollPolicyChanged)
        {
            if (scroller)
                scroller.horizontalScrollPolicy = _horizontalScrollPolicy;
            horizontalScrollPolicyChanged = false;
        }

        if (verticalScrollPolicyChanged)
        {
            if (scroller)
                scroller.verticalScrollPolicy = _verticalScrollPolicy;
            verticalScrollPolicyChanged = false;
        }

        if (widthInCharsChanged)
		{
			textView.widthInChars = _widthInChars;
			widthInCharsChanged = false;
		}

        if (heightInLinesChanged)
		{
			textView.heightInLines = _heightInLines;
			heightInLinesChanged = false;
		}

        if (contentChanged)
        {
            textView.content = _content;
            contentChanged = false;
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
			// Set the RichEditableText to allow multiple lines of input.  
			// In default.css, the TextArea selector has a declaration
			// for lineBreak which sets it to "toFit".  It needs to be on
			// TextArea rather than RichEditableText so that if changed later it
			// will be inherited.  It needs to be set with the default
			// before the possibility that it is changed when TextArea is
			// created.  In this case, setting it here, would overwrite
			// that change.
			textView.heightInLines = 10;
			textView.multiline = true;
            textView.autoSize = false;

            textView.addEventListener("textInvalid",
									  textView_textInvalidHandler);

        }
        
        // The scroller, between textView and this in the chain, should not 
        // getFocus.
        if (instance == scroller)
            scroller.focusEnabled = false;
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
     */
    override protected function textView_changeHandler(
                                        event:TextOperationEvent):void
	{
		// Note: We don't call the superhandler here
        // because it immediately fetches textView.text
        // to extract the text from the TextFlow.
        // That's too expensive for an TextArea,
        // which might have a lot of leaf nodes.
        
        // Update our storage variable for the content.
		_content = textView.content;
        textInvalid = true;

		// Redispatch the event that came from the RichEditableText.
		dispatchEvent(event);
	}

	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function textView_textInvalidHandler(event:Event):void
    {
        textInvalid = true;
    }
}

}
