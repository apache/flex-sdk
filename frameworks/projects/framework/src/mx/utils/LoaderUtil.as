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
import flash.system.Security;

  /**
   *  The LoaderUtil class defines a utility method for use with Flex RSLs.
   */
    public class LoaderUtil
    {
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
     */
    public static function normalizeURL(loaderInfo:LoaderInfo):String
    {
        var url:String = loaderInfo.url;
        var results:Array = url.split("/[[DYNAMIC]]/");
        
        return results[0];
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
     *  This is typically the url of the application loading the url.
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
        if (!(url.indexOf(":") > -1 || url.indexOf("/") == 0 || url.indexOf("\\") == 0))
        {
            if (rootURL)
            {
                var lastIndex:int = Math.max(rootURL.lastIndexOf("\\"), rootURL.lastIndexOf("/"));
                if (lastIndex <= 8)
                {
                    rootURL += "/";
                    lastIndex = rootURL.length - 1;  // adding one later
                }

                // If the url starts from the current directory, then just skip
                // over the "./".
                // If the url start from the parent directory, the we need to
                // modify the rootURL.
                if (url.indexOf("./") == 0)
                {
                    url = url.substring(2);
                }
                else
                {
                    while (url.indexOf("../") == 0)
                    {
                        url = url.substring(3);
                        var parentIndex:int = Math.max(rootURL.lastIndexOf("\\", lastIndex - 1), 
                                                       rootURL.lastIndexOf("/", lastIndex - 1));
                        if (parentIndex <= 8)
                            parentIndex = lastIndex;
                        lastIndex = parentIndex;
                    }
                }
                                            
                if (lastIndex != -1)
                    absoluteURL = rootURL.substr(0, lastIndex + 1) + url;
            }
        }

        return absoluteURL;
    }


    }
}