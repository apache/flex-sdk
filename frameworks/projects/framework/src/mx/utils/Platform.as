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
	
import flash.system.Capabilities;

/**
 *  The Platform utility class constain several static methods to check what
 *  desktop or mobile platform the application is running on.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.12
 */
public class Platform
{
    include "../core/Version.as";
	
	protected static var _initilised:Boolean;
	protected static var _isAndroid:Boolean;
	protected static var _isIOS:Boolean;
	protected static var _isBlackBerry:Boolean;
	protected static var _isMobile:Boolean;
	protected static var _isMac:Boolean;
	protected static var _isWindows:Boolean;
	protected static var _isLinux:Boolean;
	protected static var _isDesktop:Boolean;
	protected static var _isBrowser:Boolean;
	protected static var _isAir:Boolean;
	
	/**
	 *  Returns true if the applciation is runing on IOS.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.0
	 *  @productversion Flex 4.12
	 */
	public static function get isIOS():Boolean
	{
		getPlatforms();
		
		return _isIOS;
	}
	
	/**
	 *  Returns true if the applciation is runing on a BlackBerry.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.0
	 *  @productversion Flex 4.12
	 */
	public static function get isBlackBerry():Boolean
	{
		getPlatforms();
		
		return _isBlackBerry;
	}
	
	/**
	 *  Returns true if the applciation is runing on Android.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.0
	 *  @productversion Flex 4.12
	 */
	public static function get isAndroid():Boolean
	{
		getPlatforms();
		
		return _isAndroid;
	}
	
	/**
	 *  Returns true if the applciation is runing on Windows.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.0
	 *  @productversion Flex 4.12
	 */
	public static function get isWindows():Boolean
	{
		getPlatforms();
		
		return _isWindows;
	}
	
	/**
	 *  Returns true if the applciation is runing on a Mac.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.0
	 *  @productversion Flex 4.12
	 */
	public static function get isMac():Boolean
	{
		getPlatforms();
		
		return _isMac;
	}
	
	/**
	 *  Returns true if the applciation is runing on Linux.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.0
	 *  @productversion Flex 4.12
	 */
	public static function get isLinux():Boolean
	{
		getPlatforms();
		
		return _isLinux;
	}
	
	/**
	 *  Returns true if the applciation is runing on a Desktop OS.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.0
	 *  @productversion Flex 4.12
	 */
	public static function get isDesktop():Boolean
	{
		getPlatforms();
		
		return _isDesktop;
	}
	
	/**
	 *  Returns true if the applciation is runing on a Mobile device.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.0
	 *  @productversion Flex 4.12
	 */
	public static function get isMobile():Boolean
	{
		getPlatforms();
		
		return _isMobile;
	}
	
	/**
	 *  Returns true if the applciation is runing on a desktop AIR.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.0
	 *  @productversion Flex 4.12
	 */
	public static function get isAir():Boolean
	{
		getPlatforms();
		
		return _isAir;
	}
	
	/**
	 *  Returns true if the applciation is runing in a browser.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.0
	 *  @productversion Flex 4.12
	 */
	public static function get isBrowser():Boolean
	{
		getPlatforms();
		
		return _isBrowser;
	}
	
	protected static function getPlatforms():void {
		if (!_initilised)
		{
			_isAndroid = Capabilities.version.indexOf("AND") > -1;
			_isIOS = Capabilities.version.indexOf('IOS') > -1;
			_isBlackBerry = Capabilities.version.indexOf('QNX') > -1;
			_isMobile = _isAndroid || _isIOS || _isBlackBerry;
			
			_isMac = Capabilities.os.indexOf("Mac OS") != -1;
			_isWindows = Capabilities.os.indexOf("Windows") != -1;
			_isLinux = Capabilities.os.indexOf("Linux") != -1; // note that Android is also Linux
			_isDesktop = !_isMobile;
			
			_isAir = Capabilities.playerType == "Desktop";
			_isBrowser = (Capabilities.playerType == "Plugin" || Capabilities.playerType == "ActiveX");
			
			_initilised = true;
		}
	}
}

}
