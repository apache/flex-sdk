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

import flash.system.Capabilities;
import flash.text.FontStyle;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.engine.FontDescription;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

import mx.managers.ISystemManager;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 *  A singleton to contain a list of all the embeded fonts in use
 *  and the associated SWF/moduleFactory where the fonts are defined.
 */
public class EmbeddedFontRegistry implements IEmbeddedFontRegistry
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static var fonts:Object = {};

    /**
     *  @private
     */
    private static var cachedFontsForObjects:Dictionary = new Dictionary(true);

    /**
     *  @private
     */
    private static var instance:IEmbeddedFontRegistry;

    /**
     *  @private
     *  Used for accessing localized Error messages.
     */
    private var resourceManager:IResourceManager = ResourceManager.getInstance();
    
    /**
     *  @private
     */  
    private static var staticTextFormat:TextFormat = new TextFormat();
    
    /**
     *  @private
     */
    private static var flaggedObjects:Dictionary = new Dictionary(true);
    
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public static function getInstance():IEmbeddedFontRegistry
	{
		if (!instance)
			instance = new EmbeddedFontRegistry();

		return instance;
	}
	
	/**
	 *  @private
	 *	Creates a key for the embedded font.
	 * 
	 *  @param font	FlexFont object, may not be null.
	 *
	 *  @return String key
	 */
	private static function createFontKey(font:EmbeddedFont):String
	{
		return font.fontName + font.fontStyle;
	}

	/**
	 *  Creates an EmbeddedFont from a font key.
	 *
	 *  @param key A string that represents a key
	 *  created by createFontKey(); may not be null.
	 * 
	 *  @return An EmbeddedFont with the attributes from the key.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	 private static function createEmbeddedFont(key:String):EmbeddedFont
	 {
		var fontName:String;
		var fontBold:Boolean;
		var fontItalic:Boolean;
		
		var index:int = endsWith(key,FontStyle.REGULAR);
		if (index > 0)
		{
			fontName = key.substring(0, index);
			return new EmbeddedFont(fontName, false, false);
		}
		
		index = endsWith(key, FontStyle.BOLD);
		if (index > 0)
		{
			fontName = key.substring(0, index);
			return new EmbeddedFont(fontName, true, false);
		}

		index = endsWith(key, FontStyle.BOLD_ITALIC);
		if (index > 0)
		{
			fontName = key.substring(0, index);
			return new EmbeddedFont(fontName, true, true);
		}
		
		index = endsWith(key, FontStyle.ITALIC);
		if (index > 0)
		{
			fontName = key.substring(0, index);
			return new EmbeddedFont(fontName, false, true);
		}
		
		return new EmbeddedFont("", false, false);
	 }

	/**
	 *  Tests if a string ends with another string.
	 * 
	 *  @returns index into string if it ends with the matching string, otherwise returns -1.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	private static function endsWith(s:String, match:String):int
	{
		var index:int = s.lastIndexOf(match);
		
		if (index > 0 && (index + match.length == s.length))
		{
			return index;
		}
		
		return -1;
	}	

	/**
	 *  @private
	 *  Registers fonts from the info["fonts"] startup information.
	 * 
	 *  @param fonts Object obtained from the info["fonts"] call
	 *  on a moduleFactory object.
	 *
	 *  @param moduleFactory The module factory of the caller.
	 */
	public static function registerFonts(fonts:Object,
										 moduleFactory:IFlexModuleFactory):void
	{
		var fontRegistry:IEmbeddedFontRegistry;
        try
        {
            fontRegistry = IEmbeddedFontRegistry(
			Singleton.getInstance("mx.core::IEmbeddedFontRegistry"));
        }
        catch (e:Error)
        {
            Singleton.registerClass("mx.core::IEmbeddedFontRegistry", EmbeddedFontRegistry);
            fontRegistry = IEmbeddedFontRegistry(
			Singleton.getInstance("mx.core::IEmbeddedFontRegistry"));
        }
		
		// Loop thru all the font objects and put them in the registry
		for (var f:Object in fonts)
		{
			var fontObj:Object = fonts[f];

			 // For each value of "regular", "bold", "italic", and "boldItalic"
			 // register the font name.
			 for (var fieldIter:String in fontObj)
			 {
			 	if (fontObj[fieldIter] == false)
			 		continue; // no font to register
			 	
			 	var bold:Boolean;
			 	var italic:Boolean;
			 	if (fieldIter == "regular")
			 	{
			 		bold = false;
			 		italic = false;
			 	}
			 	else if (fieldIter == "boldItalic")
			 	{
			 		bold = true;
			 		italic = true;
			 	} 
			 	else if (fieldIter == "bold")
				{
					bold = true;
					italic = false;			 		
			 	}
			 	else if (fieldIter == "italic")
				{
					bold = false;
					italic = true;			 		
			 	}

				fontRegistry.registerFont(
					new EmbeddedFont(String(f), bold, italic), moduleFactory);									
			 }
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  Convert a font styles into a String as using by flash.text.FontStyle.
	 * 
	 *  @param bold true if the font is bold, false otherwise.
	 *
	 *  @param italic true if the font is italic, false otherwise.
	 *
	 *  @return A String that matches one of the values in flash.text.FontStyle.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function getFontStyle(bold:Boolean, italic:Boolean):String
	{
        var style:String = FontStyle.REGULAR;

        if (bold && italic)
            style = FontStyle.BOLD_ITALIC;
        else if (bold)
            style = FontStyle.BOLD;
        else if (italic)
            style = FontStyle.ITALIC;
		
		return style;
	}	
	
	/**
     *  @inheritDoc
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function registerFont(font:EmbeddedFont,
								 moduleFactory:IFlexModuleFactory):void
	{
		var fontKey:String = createFontKey(font);
		var fontDictionary:Dictionary = fonts[fontKey];
		if (!fontDictionary)
		{
			fontDictionary = new Dictionary(true); // use weak ref for keys
			fonts[fontKey] = fontDictionary;
		}
		fontDictionary[moduleFactory] = 1;
	}
	
	/**
     *  @inheritDoc
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function deregisterFont(font:EmbeddedFont,
								   moduleFactory:IFlexModuleFactory):void
	{
		var fontKey:String = createFontKey(font);
		var fontDictionary:Dictionary = fonts[fontKey];
		if (fontDictionary != null)
		{
			delete fontDictionary[moduleFactory];
			
			var count:int = 0;
			for (var obj:Object in fontDictionary)
			{
			    count++;
			}
			
			if (count == 0)
    			delete fonts[fontKey];
		}
	}
	
	/**
     *  @inheritDoc
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function getFonts():Array
	{
		var fontArray:Array = [];
		
		for (var key:String in fonts)
		{
			fontArray.push(createEmbeddedFont(key));
		}
		
		return fontArray;
	}
	
	/**
     *  @inheritDoc
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
    public function getAssociatedModuleFactory(
                        fontName:String, bold:Boolean, italic:Boolean,
                        object:Object,
                        defaultModuleFactory:IFlexModuleFactory,
                        systemManager:ISystemManager,
                        embeddedCff:*=undefined):
                        IFlexModuleFactory
    {

        var font:EmbeddedFont;
        font = cachedFontsForObjects[object];
        if (!font)
        {
            font = new EmbeddedFont(fontName, bold, italic);
            cachedFontsForObjects[object] = font;
        }
        else
        {
            // replace if not the same
            if (font.fontName != fontName ||
                font.bold != bold ||
                font.italic != italic)
            {
                font = new EmbeddedFont(fontName, bold, italic);
                cachedFontsForObjects[object] = font;
            }

        }
        var result:IFlexModuleFactory;
        var fontDictionary:Dictionary = fonts[createFontKey(font)];
        if (fontDictionary)
        {
            // First lookup in the dictionary. If not found, then
            // take the first moduleFactory in the dictionary.
            // A module can register a font that is not unique and still
            // use that font as long as its components specify the moduleFactory.
            // A module can use fonts in other modules but
            // to get consistent behavior the font should be unique.
            var found:int = fontDictionary[defaultModuleFactory];

            if (found)
                result = defaultModuleFactory;
            else
            {
                for (var iter:Object in fontDictionary)
                {
                    result =  iter as IFlexModuleFactory;
                    break;
                }
            }
        }
        
        if (!result && systemManager)
        {
            // If we found the font, then it is embedded. Some fonts are not 
            // listed in info() and are therefore not resolvable with our
            // registry, so we call isFontFaceEmbedded() which gets the list
            // of embedded fonts from the player.
            staticTextFormat.font = fontName;
            staticTextFormat.bold = bold;
            staticTextFormat.italic = italic;
            
            if (systemManager.isFontFaceEmbedded(staticTextFormat))
                result = systemManager;
        }
        
        // We must ensure that the requested font is in fact valid for our
        // given usage and context.
        if (result && embeddedCff != undefined && Capabilities.isDebugger)
        {                        
            var compatible:Boolean = embeddedCff ? 
                result.callInContext(FontDescription.isFontCompatible, null,
                    [fontName, bold ? "bold" : "normal", italic ? "italic" : "normal"]) :
                result.callInContext(TextField.isFontCompatible, null,
                    [fontName, getFontStyle(bold, italic)]);
            
            if (!compatible)
            {
                // We want to avoid reporting redundant warnings so we keep tabs
                // on which instances we've already flagged as incompatible.
                if (!flaggedObjects[object])
                {    
                    var objName:String = getQualifiedClassName(object);
                    objName += "name" in object && object.name != null ? " ("+object.name+") " : "";
                    trace(resourceManager.getString( "core", "fontIncompatible", 
                        [fontName, objName, embeddedCff]));
                    flaggedObjects[object] = true;
                }
            }
        }
        
        return result;
    }
}

}
