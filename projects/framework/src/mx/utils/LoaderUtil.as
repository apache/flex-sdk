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

package mx.utils
{

import flash.display.LoaderInfo;

import mx.core.mx_internal;

use namespace mx_internal;

  /**
   *  The LoaderUtil class defines a utility method for use with Flex RSLs.
   *  
   *  @langversion 3.0
   *  @playerversion Flash 9
   *  @playerversion AIR 1.1
   *  @productversion Flex 3
   */
    public class LoaderUtil
    {
        
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *   @private
     * 
     *   An array of search strings and filters. These are used in the normalizeURL
     *   method. normalizeURL is used to remove special Flash Player markup from 
     *   urls, but the array could be appended to by the user to modify urls in other
     *   ways.
     *  
     *   Each object in the array has two fields:
     * 
     *   1. searchString - the string to search the url
     *   2. filterFunction - a function that accepts an url and an index to the first
     *   occurrence of the search string in the url. The function may modify the url
     *   and return a new url. A filterFunction is only called once, for the first
     *   occurrence of where the searchString was found. If there
     *   are multiple strings in the url that need to be processed the filterFunction
     *   should handle all of them on the call. A filter function should 
     *   be defined as follows:
     * 
     *   @param url the url to process.
     *   @param index the index of the first occurrence of the seachString in the url.
     *   @return the new url.
     * 
     *   function filterFunction(url:String, index:int):String
     * 
     */
    mx_internal static var urlFilters:Array = 
            [
                { searchString: "/[[DYNAMIC]]/", filterFunction: dynamicURLFilter}, 
                { searchString: "/[[IMPORT]]/",  filterFunction: importURLFilter}
            ];
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------
        
    /**
     *  The root URL of a cross-domain RSL contains special text 
     *  appended to the end of the URL. 
     *  This method normalizes the URL specified in the specified LoaderInfo instance 
     *  to remove the appended text, if present. 
     *  Classes accessing <code>LoaderInfo.url</code> should call this method 
     *  to normalize the URL before using it.
     *
     *  @param loaderInfo A LoaderInfo instance.
     *
     *  @return A normalized <code>LoaderInfo.url</code> property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function normalizeURL(loaderInfo:LoaderInfo):String
    {
        var url:String = loaderInfo.url;
        var index:int;
        var searchString:String;
        var urlFilter:Function;
        var n:uint = LoaderUtil.urlFilters.length;
        
        for (var i:uint = 0; i < n; i++)
        {
            searchString = LoaderUtil.urlFilters[i].searchString;
            if ((index = url.indexOf(searchString)) != -1)
            {
                urlFilter = LoaderUtil.urlFilters[i].filterFunction;
                url = urlFilter(url, index);
            }
        }
        
        return url;
    }

    /**
     *  @private 
     * 
     *  Use this method when you want to load resources with relative URLs.
     * 
     *  Combine a root url with a possibly relative url to get a absolute url.
     *  Use this method to convert a relative url to an absolute URL that is 
     *  relative to a root URL.
     * 
     *  @param rootURL An url that will form the root of the absolute url.
     *  If the <code>rootURL</code> does not specify a file name it must be 
     *  terminated with a slash. For example, "http://a.com" is incorrect, it
     *  should be terminated with a slash, "http://a.com/". If the rootURL is
     *  taken from loaderInfo, it must be passed thru <code>normalizeURL</code>
     *  before being passed to this function.
     * 
     *  When loading resources relative to an application, the rootURL is 
     *  typically the loaderInfo.url of the application.
     * 
     *  @param url The url of the resource to load (may be relative).
     * 
     *  @return If <code>url</code> is already an absolute URL, then it is 
     *  returned as is. If <code>url</code> is relative, then an absolute URL is
     *  returned where <code>url</code> is relative to <code>rootURL</code>. 
     */ 
    public static function createAbsoluteURL(rootURL:String, url:String):String
    {
        var absoluteURL:String = url;

        // make relative paths relative to the SWF loading it, not the top-level SWF
        if (rootURL &&
            !(url.indexOf(":") > -1 || url.indexOf("/") == 0 || url.indexOf("\\") == 0))
        {
            // First strip off the search string and then any url fragments.
            var index:int;
            
            if ((index = rootURL.indexOf("?")) != -1 )
                rootURL = rootURL.substring(0, index);

            if ((index = rootURL.indexOf("#")) != -1 )
                rootURL = rootURL.substring(0, index);
            
            // If the url starts from the current directory, then just skip
            // over the "./".
            // If the url start from the parent directory, the we need to
            // modify the rootURL.
            var lastIndex:int = Math.max(rootURL.lastIndexOf("\\"), rootURL.lastIndexOf("/"));
            if (url.indexOf("./") == 0)
            {
                url = url.substring(2);
            }
            else
            {
                while (url.indexOf("../") == 0)
                {
                    url = url.substring(3);
                    lastIndex = Math.max(rootURL.lastIndexOf("\\", lastIndex - 1), 
                                                   rootURL.lastIndexOf("/", lastIndex - 1));
                }
            }
                                        
            if (lastIndex != -1)
                absoluteURL = rootURL.substr(0, lastIndex + 1) + url;
        }

        return absoluteURL;
    }

    /**
     *  @private
     * 
     *  Strip off the DYNAMIC string(s) appended to the url.
     */
    private static function dynamicURLFilter(url:String, index:int):String
    {
        return url.substring(0, index);
    }

    /**
     *  @private
     * 
     *  Add together the protocol plus everything after "/[[IMPORT]]/".
     */
    private static function importURLFilter(url:String, index:int):String
    {
        var protocolIndex:int = url.indexOf("://");
        return url.substring(0,protocolIndex + 3) + url.substring(index + 12);
    }

    }
}