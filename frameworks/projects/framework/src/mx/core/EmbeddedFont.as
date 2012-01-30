////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.core
{

import flash.text.FontStyle;

[ExcludeClass]

/**
 *  @private
 *  Describes the properties that make an embedded font unique.
 */
public class EmbeddedFont
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Create a new EmbeddedFont object.
	 * 
	 *  @param fontName The name of the font.
	 *
	 *  @param bold true if the font is bold, false otherwise.
	 *
	 *  @param italic true if the font is italic, false otherwise,
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */ 
	public function EmbeddedFont(fontName:String, bold:Boolean, italic:Boolean)
	{
		super();

		initialize(fontName, bold, italic);
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

    //----------------------------------
    //  bold
    //----------------------------------

	/**
	 *  @private
	 *  Storage for the bold property.
	 */
	private var _bold:Boolean;
	
	/**
	 *  True if the font is bold
	 *  
	 *  @langversion 4.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get bold():Boolean
	{
		return _bold;	
	}

    //----------------------------------
    //  fontName
    //----------------------------------

	/**
	 *  @private
	 *  Storage for the fontName property.
	 */
	private var _fontName:String;
	
	/**
	 *  The name of the font.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get fontName():String
	{
		return _fontName;	
	}

    //----------------------------------
    //  fontStyle
    //----------------------------------

	/**
	 *  @private
	 *  Storage for the fontStyle property.
	 */
	private var _fontStyle:String;
	
	/**
	 *  The style of the font.
	 *  The value is one of the values in flash.text.FontStyle.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get fontStyle():String
	{
		return _fontStyle;	
	}
	
    //----------------------------------
    //  italic
    //----------------------------------

	/**
	 *  @private
	 *  Storage for the italic property.
	 */
	private var _italic:Boolean;
	
	/**
	 *  True if the font is italic
	 *  
	 *  @langversion 4.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get italic():Boolean
	{
		return _italic;	
	}
	
	//--------------------------------------------------------------------------
	//
	//  Initialize
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @private
	 */
	public function initialize(fontName:String, bold:Boolean,
							   italic:Boolean):void
	{
        _bold = bold;
        _italic = italic;
		_fontName = fontName;
		_fontStyle = EmbeddedFontRegistry.getInstance().getFontStyle(bold, italic);
}
}

}
