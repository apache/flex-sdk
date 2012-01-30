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

import mx.managers.ISystemManager;

[ExcludeClass]

/**
 *  @private
 *  Interface to a registery of fonts embedded in SWF files.
 */
public interface IEmbeddedFontRegistry
{
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
	/**
     *  Registers a font and associates it with a moduleFactory.
     * 
     *  @param font Describes attributes of the font to register.
	 *
     *  @param moduleFactory The moduleFactory where the font is embedded.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	function registerFont(font:EmbeddedFont,
						  moduleFactory:IFlexModuleFactory):void;
	
	/**
	 *  Deregisters a font.
	 *
	 *  <p>The <code>moduleFactory</code> is provided to resolve the case
	 *  where multiple fonts are registered with the same attributes.</p>
	 * 
     *  @param font Describes attributes of the font to register.
	 *
     *  @param moduleFactory moduleFactory where the font is embedded.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	function deregisterFont(font:EmbeddedFont,
							moduleFactory:IFlexModuleFactory):void;

    /**
     *  Returns true if the embedded font with the given characteristics is
     *  in the <code>moduleFactory</code>, otherwise returns false.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function isFontRegistered(font:EmbeddedFont,
                              moduleFactory:IFlexModuleFactory):Boolean;

    /**
     *  Finds the <code>moduleFactory</code> associated with a font.
     *
     *  <p>The <code>moduleFactory</code> is used to resolve the case
     *  where multiple fonts are registered with the same attributes.</p>
     * 
     *  @param fontName FontFamily of the font
     *  @param bold true for bold fontWeight
     *  @param italic true for italic fontStyle
     *  @param object The Object using this font
     *
     *  @param defaultModuleFactory Used to resolve conflicts in the case
     *  where the same font is registered for multiple module factories.
     *  If one of the module factories of a font is associated with
     *  defaultModuleFactory, then that moduleFactory is returned.
     *  Otherwise the most recently registered moduleFactory will be chosen.
     *
     *  @param systemManager Optional ISystemManager instance to use to
     *  look for locally registered fonts that may not be present in our
     *  compile time registry.
     *
     *  @param embeddedCff Optional flag to request that the resolved font
     *  be tested for compatibilility. If true, we ensure the font is
     *  of type EMBEDDED_CFF, if false we ensure it is EMBEDDED.
     * 
     *  @return moduleFactory that can be used to create an object
     *  in the context of the font. 
     *  null if the font is not found in the registry.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getAssociatedModuleFactory(
                    fontName:String, bold:Boolean, italic:Boolean,
                    object:Object,
                    defaultModuleFactory:IFlexModuleFactory,
                    systemManager:ISystemManager,
                    embeddedCff:*=undefined):IFlexModuleFactory;

    /**
     *  Gets an array of all the fonts that have been registered.
	 *
	 *  <p>Each element in the array is of type EmbeddedFont.</p>
     * 
     *  @return Array of EmbeddedFont objects.
	 *  Fonts that have been registered multiple times will appear
	 *  multiple times in the array.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */		
	function getFonts():Array;

    /**
     *  Gets a string pattern based on the font attributes
	 *
     *  @return String describing font
     */		
	function getFontStyle(bold:Boolean, italic:Boolean):String

}

}
