////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.logging
{

import flash.events.EventDispatcher;
import mx.managers.ISystemManager;
import mx.managers.SystemManager;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

[ResourceBundle("logging")]

/**
 *  The logger that is used within the logging framework.
 *  This class dispatches events for each message logged using the <code>log()</code> method.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class LogLogger extends EventDispatcher implements ILogger
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
         *  @param category The category for which this log sends messages.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function LogLogger(category:String)
	{
		super();

		_category = category;
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Used for accessing localized Error messages.
	 */
	private var resourceManager:IResourceManager =
									ResourceManager.getInstance();

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  category
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the category property.
	 */
	private var _category:String;

	/**
	 *  The category this logger send messages for.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */	
	public function get category():String
	{
		return _category;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @inheritDoc
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */	
	public function log(level:int, msg:String, ... rest):void
	{
		// we don't want to allow people to log messages at the 
		// Log.Level.ALL level, so throw a RTE if they do
		if (level < LogEventLevel.DEBUG)
		{
			var message:String = resourceManager.getString(
				"logging", "levelLimit");
        	throw new ArgumentError(message);
		}
        	
		if (hasEventListener(LogEvent.LOG))
		{
			// replace all of the parameters in the msg string
			for (var i:int = 0; i < rest.length; i++)
			{
				msg = msg.replace(new RegExp("\\{"+i+"\\}", "g"), rest[i]);
			}

			dispatchEvent(new LogEvent(msg, level));
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
	public function debug(msg:String, ... rest):void
	{
		if (hasEventListener(LogEvent.LOG))
		{
			// replace all of the parameters in the msg string
			for (var i:int = 0; i < rest.length; i++)
			{
				msg = msg.replace(new RegExp("\\{"+i+"\\}", "g"), rest[i]);
			}

			dispatchEvent(new LogEvent(msg, LogEventLevel.DEBUG));
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
	public function error(msg:String, ... rest):void
	{
		if (hasEventListener(LogEvent.LOG))
		{
			// replace all of the parameters in the msg string
			for (var i:int = 0; i < rest.length; i++)
			{
				msg = msg.replace(new RegExp("\\{"+i+"\\}", "g"), rest[i]);
			}

			dispatchEvent(new LogEvent(msg, LogEventLevel.ERROR));
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
	public function fatal(msg:String, ... rest):void
	{
		if (hasEventListener(LogEvent.LOG))
		{
			// replace all of the parameters in the msg string
			for (var i:int = 0; i < rest.length; i++)
			{
				msg = msg.replace(new RegExp("\\{"+i+"\\}", "g"), rest[i]);
			}

			dispatchEvent(new LogEvent(msg, LogEventLevel.FATAL));
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
	public function info(msg:String, ... rest):void
	{
		if (hasEventListener(LogEvent.LOG))
		{
			// replace all of the parameters in the msg string
			for (var i:int = 0; i < rest.length; i++)
			{
				msg = msg.replace(new RegExp("\\{"+i+"\\}", "g"), rest[i]);
			}

			dispatchEvent(new LogEvent(msg, LogEventLevel.INFO));
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
	public function warn(msg:String, ... rest):void
	{
		if (hasEventListener(LogEvent.LOG))
		{
			// replace all of the parameters in the msg string
			for (var i:int = 0; i < rest.length; i++)
			{
				msg = msg.replace(new RegExp("\\{"+i+"\\}", "g"), rest[i]);
			}

			dispatchEvent(new LogEvent(msg, LogEventLevel.WARN));
		}
	}
}

}
