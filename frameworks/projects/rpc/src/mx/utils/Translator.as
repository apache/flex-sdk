////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2006-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.utils
{

import flash.utils.getQualifiedClassName;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;
import mx.utils.StringUtil;

[ExcludeClass]
[ResourceBundle("messaging")]
[ResourceBundle("rpc")]

/**
 *  @private
 */
public class Translator
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private static const TRANSLATORS:Object = {};
 
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Assumes the bundle name is the name of the second package
	 *  (e.g foo in mx.foo).
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function getDefaultInstanceFor(source:Class):Translator
    {
        var qualifiedName:String = getQualifiedClassName(source);
        var firstSeparator:int = qualifiedName.indexOf(".");
        var startIndex:int = firstSeparator + 1;
        var secondSeparator:int = qualifiedName.indexOf(".", startIndex);
        if (secondSeparator < 0)
            secondSeparator = qualifiedName.indexOf(":", startIndex);
        var bundleName:String =
            qualifiedName.slice(startIndex, secondSeparator);
        return getInstanceFor(bundleName);
    }

 	/**
	 *  @private
	 */
   public static function getInstanceFor(bundleName:String):Translator
    {
        var result:Translator = TRANSLATORS[bundleName];
        if (!result)
        {
            result = new Translator(bundleName);
            TRANSLATORS[bundleName] = result;
        }
        return result;
    }

	/**
	 *  @private
	 */
    public static function getMessagingInstance():Translator
    {
        return getInstanceFor("messaging");
    }

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

	/**
	 *  Constructor
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
    public function Translator(bundleName:String)
    {
        super();

        this.bundleName = bundleName;
    }

    //----------------------------------
    //  resourceManager
    //----------------------------------

    /**
     *  @private
     *  Storage for the resourceManager instance.
     */
    private var _resourceManager:IResourceManager = ResourceManager.getInstance();

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 */
    private var bundleName:String;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 */
    public function textOf(key:String, ... rest):String
    {
        return _resourceManager.getString(bundleName, key, rest);
    }
}

}
