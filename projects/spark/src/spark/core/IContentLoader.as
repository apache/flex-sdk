////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.core
{
	
import flash.events.IEventDispatcher;
import spark.core.ContentRequest;

/**
 *  Provides custom image/content loader for BitmapImage instances.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
public interface IContentLoader extends IEventDispatcher
{
    /**
     *  Initiates a content request for the resource identified
     *  by the key specified.
     *
     *  @param source Unique key used to represent the requested content resource. 
     *  This parameter is typically an URL or URLRequest.
     *
     *  @param contentLoaderGrouping - (Optional) grouping identifier for the loaded resource.
     *  ContentLoader instances supporting content groups generally allow for 
     *  resources within the same named grouping to be addressed as a whole. For 
     *  example the ContentCache's loader queue allows requests to be prioritized
     *  by contentLoaderGrouping.  
     *
     *  @return A ContentRequest instance representing the requested resource.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    function load(source:Object, contentLoaderGrouping:String=null):ContentRequest;       
}
}
