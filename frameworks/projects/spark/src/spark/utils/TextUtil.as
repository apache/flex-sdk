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

package spark.utils
{

import flash.text.engine.FontDescription;
import flash.text.engine.FontLookup;
import flash.text.engine.TextLine;
import flash.text.engine.TextLineValidity;

import flashx.textLayout.compose.ISWFContext;
import flashx.textLayout.compose.TextLineRecycler;
import flashx.textLayout.formats.ITextLayoutFormat;

import mx.core.EmbeddedFont;
import mx.core.IEmbeddedFontRegistry;
import mx.core.IFlexModuleFactory;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

use namespace mx_internal;

[ExcludeClass]

[ResourceBundle("textLayout")]

/**
 *  @private
 */
public class TextUtil
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
	public static function getResourceString(resourceName:String,
											 args:Array = null):String
	{
		var resourceManager:IResourceManager = ResourceManager.getInstance();
		return resourceManager.getString("textLayout", resourceName, args);
	}
    
    /** 
     * @private
     * The callback used for changing the FontLookup based on SWFcontext.  
     * The function will be called each time a TLF ElementFormat is computed.
     * It gives us the opportunity to modify the FontLookup setting. 
     * 
     * There will only be a swfContext if the component-level font was
     * embedded. 
     */
    public static function resolveFontLookup(
                    swfContext:ISWFContext, format:ITextLayoutFormat):String
    {
        // If the font isn't embedded as advertised, first fall back to 
        // corresponding device font and, only if that fails, fail back to the
        // player's default font.
        if (swfContext as IFlexModuleFactory &&
            format.fontLookup == FontLookup.EMBEDDED_CFF)
        {
            var name:String = format.fontFamily;
            var bold:Boolean = format.fontWeight == "bold";
            var italic:Boolean = format.fontStyle == "italic";
            var font:EmbeddedFont = new EmbeddedFont(name, bold, italic);
            
            var registry:IEmbeddedFontRegistry = 
                UIComponent.embeddedFontRegistry;
            
            if (registry && 
                registry.isFontRegistered(font, IFlexModuleFactory(swfContext)))
            {
                return FontLookup.EMBEDDED_CFF;
            }
			if (swfContext.callInContext( FontDescription.isFontCompatible, FontDescription, [name, format.fontWeight, format.fontStyle]))
				return FontLookup.EMBEDDED_CFF;
		}
		else if (FontDescription.isFontCompatible(format. fontFamily, format.fontWeight, format.fontStyle))
			return FontLookup.EMBEDDED_CFF;
        
        return FontLookup.DEVICE; 
    }    
    
    /** 
     * @private
     */
    public static function recycleTextLine(textLine:TextLine):void
    {
        if (textLine)
        {
            // Throws an ArgumentError if validity set to INVALID in
            // either of these cases.
            if (textLine.validity != TextLineValidity.INVALID && 
                textLine.validity != TextLineValidity.STATIC)
            {
                textLine.validity = TextLineValidity.INVALID;
            }
            
            textLine.userData = null;	// clear any userData
            TextLineRecycler.addLineForReuse(textLine);
        }
    }
}

}
