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

import flash.display.Loader;
import flash.events.Event;
import flash.events.ErrorEvent;
import flash.events.ProgressEvent;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.system.LoaderContext;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.Security;
import flash.system.SecurityDomain;
import flash.utils.ByteArray;
//import flash.utils.getTimer;        // PERFORMANCE_INFO

import mx.core.RSLData;
import mx.events.RSLEvent;
import mx.utils.SHA256;
import mx.utils.LoaderUtil;

[ExcludeClass]

/**
 *  @private
 *  Cross-domain RSL Item Class.
 * 
 *  The rsls are typically located on a different host than the loader. 
 *  There are signed and unsigned Rsls, both have a digest to confirm the 
 *  correct rsl is loaded.
 *  Signed Rsls are loaded by setting the digest of the URLRequest.
 *  Unsigned Rsls are check using actionScript to calculate a sha-256 hash of 
 *  the loaded bytes and compare them to the expected digest.
 * 
 */
public class CrossDomainRSLItem extends RSLItem
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var rsls:Array = [];     // of type RSLInstanceData
//    private var rslUrls:Array;  // first url is the primary url in the url parameter, others are failovers
//    private var policyFileUrls:Array; // optional policy files, parallel array to rslUrls
//    private var digests:Array;      // option rsl digest, parallel array to rslUrls
//    private var isSigned:Array;     // each entry is a boolean value. "true" if the rsl in the parallel array is signed
//    private var hashTypes:Array;     //  type of hash used to create the digest
    private var urlIndex:int = 0;   // index into url being loaded in rslsUrls and other parallel arrays

    // this reference to the loader keeps the loader from being garbage 
    // collected before the complete event can be sent. 
    private var loadBytesLoader:Loader; 
    
//    private var startTime:int;      // PERFORMANCE_INFO
        
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
    *  Create a cross-domain RSL item to load.
    * 
    *  @param rsls Array of Objects. Each Object describes and RSL to load. 
    *  The first Object in the Array is the primary RSL and the others are
    *  failover RSLs.
    *  @param rootURL provides the url used to locate relative RSL urls. 
    *  @param moduleFactory The module factory that is loading the RSLs. The
    *  RSLs will be loaded into the application domain of the given module factory.
    *  If a module factory is not specified, then the RSLs will be loaded into the 
    *  application domain of where the CrossDomainRSLItem class was first loaded.
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */  
    public function CrossDomainRSLItem(rsls:Array,
                             rootURL:String = null,
                             moduleFactory:IFlexModuleFactory = null)
    {
        super(rsls[0].rslURL, rootURL, moduleFactory);

        this.rsls = rsls;
        
        // startTime = getTimer(); // PERFORMANCE_INFO
    }


    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    

    /**
     *  Get the RSLData for the current RSL. This could be the primary RSL or one
     *  of the failover RSLs.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function get currentRSLData():RSLData
    {
        return RSLData(rsls[urlIndex]);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    
   /**
    * 
    * Load an RSL. 
    * 
    * @param progressHandler       receives ProgressEvent.PROGRESS events, may be null
    * @param completeHandler       receives Event.COMPLETE events, may be null
    * @param ioErrorHandler        receives IOErrorEvent.IO_ERROR events, may be null
    * @param securityErrorHandler  receives SecurityErrorEvent.SECURITY_ERROR events, may be null
    * @param rslErrorHandler       receives RSLEvent.RSL_ERROR events, may be null
    * 
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    override public function load(progressHandler:Function,
                                  completeHandler:Function,
                                  ioErrorHandler:Function,
                                  securityErrorHandler:Function,
                                  rslErrorHandler:Function):void 
    {
        chainedProgressHandler = progressHandler;
        chainedCompleteHandler = completeHandler;
        chainedIOErrorHandler = ioErrorHandler;
        chainedSecurityErrorHandler = securityErrorHandler;
        chainedRSLErrorHandler = rslErrorHandler;


/*      
        // Debug loading of swf files

        trace("begin load of " + url);
                if (Security.sandboxType == Security.REMOTE)
        {
            trace(" in REMOTE sandbox");    
        }
        else if (Security.sandboxType == Security.LOCAL_TRUSTED)
        {
            trace(" in LOCAL_TRUSTED sandbox");                 
        }
        else if (Security.sandboxType == Security.LOCAL_WITH_FILE)
        {
            trace(" in LOCAL_WITH_FILE sandbox");                   
        }
        else if (Security.sandboxType == Security.LOCAL_WITH_NETWORK)
        {
            trace(" in LOCAL_WITH_NETWORK sandbox");                    
        }
*  
*  @langversion 3.0
*  @playerversion Flash 9
*  @playerversion AIR 1.1
*  @productversion Flex 3
*/

        var rslData:RSLData = currentRSLData;
        urlRequest = new URLRequest(LoaderUtil.createAbsoluteURL(rootURL, rslData.rslURL));
        
        var loader:URLLoader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;

        // We needs to listen to certain events.
            
        loader.addEventListener(
            ProgressEvent.PROGRESS, itemProgressHandler);
            
        loader.addEventListener(
            Event.COMPLETE, itemCompleteHandler);
            
        loader.addEventListener(
            IOErrorEvent.IO_ERROR, itemErrorHandler);
            
        loader.addEventListener(
            SecurityErrorEvent.SECURITY_ERROR, itemErrorHandler);

        if (rslData.policyFileURL != "")
        {
            Security.loadPolicyFile(rslData.policyFileURL);
        }
        
        if (rslData.isSigned)
        {
            // load a signed rsl by specifying the digest
            urlRequest.digest = rslData.digest;
        }
        
//        trace("start load of " + urlRequest.url + " at " + (getTimer() - startTime)); // PERFORMANCE_INFO
        
        loader.load(urlRequest);
    }
    
    

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Complete the load of the cross-domain rsl by loading it into the current
     *  application domain. The load was started by loadCdRSL.
     * 
     *  @param - urlLoader from the complete event.
     * 
     *  @return - true if the load was completed successfully or unsuccessfully, 
     *            false if the load of a failover rsl was started
     */
    private function completeCdRslLoad(urlLoader:URLLoader):Boolean
    {
        // handle player bug #204244, complete event without data after an error
        if (urlLoader == null || urlLoader.data == null || ByteArray(urlLoader.data).bytesAvailable == 0)
        {
            return true;
        }
        
        // load the bytes into the current application domain.
        loadBytesLoader = new Loader();
        var context:LoaderContext = new LoaderContext();
        var rslData:RSLData = currentRSLData;

        if (rslData.moduleFactory)
        {
            context.applicationDomain = rslData.moduleFactory.info()["currentDomain"];            
        }
        else if (moduleFactory)
        {
            context.applicationDomain = moduleFactory.info()["currentDomain"];
        }
        else
        {
            context.applicationDomain = ApplicationDomain.currentDomain;
        }
        
        context.securityDomain = null;
        
        // Set the allowCodeImport flag so we can load the RSL without a security error.
        context.allowCodeImport = true;

        // verify the digest, if any, is correct
        if (rslData.digest != null && rslData.verifyDigest)
        {
            var verifiedDigest:Boolean = false;
            if (!rslData.isSigned)
            {
                // verify an unsigned rsl
                if (rslData.hashType == SHA256.TYPE_ID)
                {
                    // get the bytes from the rsl and calculate the hash
                    var rslDigest:String = null;
                    if (urlLoader.data != null)
                    {
                        rslDigest = SHA256.computeDigest(urlLoader.data);
                    }

                    if (rslDigest == rslData.digest)
                    {
                        verifiedDigest = true;
                    }
                }
            }
            else
            {
                // signed rsls are verified by the player
                verifiedDigest = true;
            }           
            
            if (!verifiedDigest)
            {
                // failover to the next rsl, if one exists
                // no failover to load, all the rsls have failed to load
                // report an error.
                 // B Feature: externalize error message
                var hasFailover:Boolean = hasFailover();
                var rslError:ErrorEvent = new ErrorEvent(RSLEvent.RSL_ERROR);
                rslError.text = "Flex Error #1001: Digest mismatch with RSL " +
                                urlRequest.url + 
                                ". Redeploy the matching RSL or relink your application with the matching library.";
                itemErrorHandler(rslError);
                
                return !hasFailover;
            }
        }

        // load the rsl into memory
        loadBytesLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadBytesCompleteHandler);
        loadBytesLoader.loadBytes(urlLoader.data, context);
        return true;
    }


    /**
    *  Does the current url being processed have a failover?
    * 
    * @return true if a failover url exists, false otherwise.
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public function hasFailover():Boolean
    {
        return (rsls.length > (urlIndex + 1));
    }
    
    
    /**
    *  Load the next url from the list of failover urls.
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public function loadFailover():void
    {
        // try to load the failover from the same node again
        if (urlIndex < rsls.length)
        {
            trace("Failed to load RSL " + currentRSLData.rslURL);
            trace("Failing over to RSL " + RSLData(rsls[urlIndex+1]).rslURL);
            urlIndex++;        // move to failover url
            url = currentRSLData.rslURL;
            load(chainedProgressHandler,
                 chainedCompleteHandler,
                 chainedIOErrorHandler,
                 chainedSecurityErrorHandler,
                 chainedRSLErrorHandler);    
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden Event Handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function itemCompleteHandler(event:Event):void
    {
//        trace("complete load of " + url + " at " + (getTimer() - startTime)); // PERFORMANCE_INFO

        // complete loading the cross-domain rsl by calling loadBytes.
        completeCdRslLoad(event.target as URLLoader);
    }
    
    /**
     *  @private
     */
    override public function itemErrorHandler(event:ErrorEvent):void
    {
//        trace("error loading " + url + " at " + (getTimer() - startTime)); // PERFORMANCE_INFO

        // if a failover exists, try to load it. Otherwise call super()
        // for default error handling.
        if (hasFailover())
        {
            trace(decodeURI(event.text));
            loadFailover();
        }
        else 
        {
            super.itemErrorHandler(event);
        }
    }
    
    
    /**
     * loader.loadBytes() has a complete event.
     * Done loading this rsl into memory. Call the completeHandler
     * to start loading the next rsl.
     * 
     *  @private
     */ 
    private function loadBytesCompleteHandler(event:Event):void
    {
        loadBytesLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadBytesCompleteHandler);
        loadBytesLoader = null;
        super.itemCompleteHandler(event);           
    }
    
}
}