////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
