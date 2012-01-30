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

package mx.managers
{

import flash.display.Stage;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.external.ExternalInterface;
import flash.net.navigateToURL;
import flash.net.URLRequest;
import mx.core.FlexGlobals;
import mx.events.BrowserChangeEvent;

/**
 *  Dispatched when the fragment property is changed either
 *  by the user interacting with the browser, invoking an
 *  application in Apollo
 *  or by code setting the property.
 *
 *  @eventType mx.events.BrowserChangeEvent.URL_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="urlChange", type="flash.events.Event")]

/**
 *  Dispatched when the fragment property is changed
 *  by the browser.
 *
 *  @eventType mx.events.BrowserChangeEvent.BROWSER_URL_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="browserURLChange", type="mx.events.BrowserChangeEvent")]

/**
 *  Dispatched when the fragment property is changed
 *  by the application via setFragment
 *
 *  @eventType mx.events.BrowserChangeEvent.APPLICATION_URL_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="applicationURLChange", type="mx.events.BrowserChangeEvent")]

[ExcludeClass]

/**
 *  @private
 *  The BrowserManager is a Singleton manager that acts as
 *  a proxy between the browser and the application.
 *  It provides access to the URL in the browser address
 *  bar similar to accessing document.location in Javascript.
 *  Events are dispatched as the url property is changed. 
 *  Listeners can then respond, alter the url, and/or block others
 *  from getting the event. 
 * 
 *  For desktop applications, the BrowserManager
 *  provides access to the command-line parameters used to
 *  invoke the application.  The url property will be the concatenated
 *  string representing all of the command-line parameters separated
 *  by semi-colons.
 *
 */
public class BrowserManagerImpl extends EventDispatcher implements IBrowserManager
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static var instance:IBrowserManager;

    private var _defaultFragment:String = "";
    
    private var _browserUserAgent:String;
    
    private var _browserPlatform:String;
    
    private var _isFirefoxMac:Boolean;
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    public static function getInstance():IBrowserManager
    {
        if (!instance)
            instance = new BrowserManagerImpl();

        return instance;
    }

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function BrowserManagerImpl()
    {
        super();

		// we want to reduce dependencies for non-flex apps that use resources (e.g. rpc)
		var systemManager:Object = SystemManagerGlobals.topLevelSystemManagers;
		if (systemManager)
			systemManager = systemManager[0];

		if (systemManager)
		{
			// figure out if we're top level, even if bootstrapped
			var sandboxRoot:Object = systemManager.getSandboxRoot();
			if (!sandboxRoot.dispatchEvent(new Event("mx.managers::BrowserManager", false, true)))
			{
				// if someone answered, then we're not the first BM
				browserMode = false;
				return;
			}
			
			try
			{
				// see if we can walk to the stage
				var parent:Object = sandboxRoot.parent;
				while (parent)
				{
					if (sandboxRoot.parent is Stage)
					{
						break;
					}
					else
					{
						parent = parent.parent;
					}
				}
			}
			catch (e:Error)
			{
				browserMode = false;
				return;
			}
			sandboxRoot.addEventListener("mx.managers::BrowserManager", sandboxBrowserManagerHandler, false, 0, true);
		}    

        try
        {
            ExternalInterface.addCallback("browserURLChange", browserURLChangeBrowser);

            ExternalInterface.addCallback("debugTrace", debugTrace);
        }
        catch(e:Error)
        {
            // not supported in all environments
            browserMode = false;
        }
    }

    private var browserMode:Boolean = true;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  base
    //----------------------------------

    private var _base:String;

    [Bindable("urlChange")]
    /**
     *  The portion of current URL before the '#' as it appears 
     *  in the browser address bar.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get base():String
    {
        return _base;
    }

    //----------------------------------
    //  fragment
    //----------------------------------

    private var _fragment:String;

    [Bindable("urlChange")]
    /**
     *  The portion of current URL after the '#' as it appears 
     *  in the browser address bar, or the default fragment
	 *  used in setup() if there is nothing after the '#'.  
	 *  Use setFragment to change this value.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get fragment():String
    {
		if (_fragment && _fragment.length)
			return _fragment;

		return _defaultFragment;
    }

    //----------------------------------
    //  title
    //----------------------------------

    private var _title:String;

    [Bindable("urlChange")]
    /**
     *  The title of the app as it should appear in the
     *  browser history
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get title():String
    {
        return _title;
    }

    //----------------------------------
    //  url
    //----------------------------------

    private var _url:String;

    [Bindable("urlChange")]
    /**
     *  The current URL as it appears in the browser address bar.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get url():String
    {
        return _url;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /** 
     *  Initialize the BrowserManager.  The BrowserManager will get the initial URL.  If it
     *  has a fragment, it will dispatch BROWSER_URL_CHANGE, so add your event listener
	 *  before calling this method.
     *
     *  @param defaultFragment the fragment to use if no fragment in the initial URL.
     *  @param defaultTitle the title to use if no fragment in the initial URL.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function init(defaultFragment:String = "", defaultTitle:String = ""):void
    {
        if ("historyManagementEnabled" in FlexGlobals.topLevelApplication)
		  FlexGlobals.topLevelApplication.historyManagementEnabled = false;

		setup(defaultFragment, defaultTitle);
	}

    /** 
     *  Initialize the BrowserManager.  The HistoryManager calls this method to
	 *  prepare the BrowserManager for further calls from the HistoryManager.  Use
	 *  of HistoryManager and setFragment calls from the application is
	 *  not supported, so the init() method sets 
	 *  FlexGlobals.topLevelApplication.historyManagementEnabled to false to disable
	 *  the HistoryManager
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public function initForHistoryManager():void
	{
		setup("", "");
	}

	private function setup(defaultFragment:String, defaultTitle:String):void
	{
        if (!browserMode)
            return;

        _defaultFragment = defaultFragment;
        _url = ExternalInterface.call("BrowserHistory.getURL");
        
		// probably no support in html wrapper
		if (!_url)
		{
			browserMode = false;
			return;
		}

        _browserUserAgent = ExternalInterface.call("BrowserHistory.getUserAgent");
        _browserPlatform = ExternalInterface.call("BrowserHistory.getPlatform");
        
        // Unlike browser.js we specifically test for the Firefox browser (vs. other
        // Gecko or Mozilla derivatives), as the bug fix included in this file that
        // leverages this flag is very specific to Firefox/Mac.
        _isFirefoxMac = (_browserUserAgent && _browserPlatform && 
            _browserUserAgent.indexOf("Firefox") > -1 && _browserPlatform.indexOf("Mac") > -1);
        
        var pos:int = _url.indexOf('#');
        if (pos == -1 || pos == _url.length - 1)
        {
            _base = _url;
            _fragment = '';
            _title = defaultTitle;
            ExternalInterface.call("BrowserHistory.setDefaultURL", defaultFragment);
            setTitle(defaultTitle);
        }
        else
        {
            _base = _url.substring(0, pos);
            _fragment = _url.substring(pos + 1);
            _title = ExternalInterface.call("BrowserHistory.getTitle");
            ExternalInterface.call("BrowserHistory.setDefaultURL", _fragment);
            //have to force a refresh of the application.
            if (_fragment != _defaultFragment)
                browserURLChange(_fragment, true);
        }
    }

    /** 
     *  Change the fragment of the url after the '#' in the browser.
     *  An attempt will be made to track this URL in the browser's
     *  history.
     *
     *  If the title is set, the old title in the browser is replaced
     *  by the new title.
     *
     *  To actually store the URL, a JavaScript
     *  method named setBrowserURL() will be called.
     *  The application's HTML wrapper must have that method which
     *  must implement a mechanism for taking this
     *  value and registering it with the browser's history scheme
     *  and address bar.
     *
     *  When set, the APPLICATION_URL_CHANGE event is sent.  If the event
     *  is cancelled the setBrowserURL() will not be called.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function setFragment(value:String):void
    {
        if (!browserMode)
            return;

        //value = (value == "") ? _defaultFragment : value;

        var lastURL:String = _url;
        var lastFragment:String = _fragment;

        _url = base + '#' + value;
        _fragment = value;
        
        if (dispatchEvent(new BrowserChangeEvent(BrowserChangeEvent.APPLICATION_URL_CHANGE, false, true, _url, lastURL)))
        {
            if (!_isFirefoxMac)
            {
                ExternalInterface.call("BrowserHistory.setBrowserURL", value, ExternalInterface.objectID);
            }
            else
            {
                // We need to avoid updating our browser URL with ExternalInterface, when we are 
                // running within Firefox/Mac.  Player rendering bug logged 2276859. 
                var urlReq:URLRequest = new URLRequest("javascript:BrowserHistory.setBrowserURL('" + 
                    value + "','" + ExternalInterface.objectID + "');");
                navigateToURL( urlReq , "_self" );
            }
            
            dispatchEvent(new BrowserChangeEvent(BrowserChangeEvent.URL_CHANGE, false, false, _url, lastURL));
        }
        else
        {
            _fragment = lastFragment;
            _url = lastURL;
        }
    }

    /** 
     *  Change the title in the browser.
     *  Does not affect the browser's
     *  history.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function setTitle(value:String):void
    {
        if (!browserMode)
            return;

        ExternalInterface.call("BrowserHistory.setTitle", value);
        _title = ExternalInterface.call("BrowserHistory.getTitle");
    }

    //--------------------------------------------------------------------------
    //
    //  Event Listeners
    //
    //--------------------------------------------------------------------------

    /** 
     *  @private
     *  Callback from browser when the URL has been changed
     *  in the browser.
     */
    private function browserURLChangeBrowser(fragment:String):void
    {
        browserURLChange(fragment, false);
    }

    private function browserURLChange(fragment:String, force:Boolean = false):void
    {
        //trace("browserURLChange: |" + decodeURI(fragment) + "|, |" + decodeURI(_fragment) + "|" + ", " + force.toString());
        if (((fragment != null) && (decodeURI(_fragment) != decodeURI(fragment))) || force)
	{
            _fragment = fragment;

            var lastURL:String = url;
            
            _url = _base + '#' + fragment;

            dispatchEvent(new BrowserChangeEvent(BrowserChangeEvent.BROWSER_URL_CHANGE, false, false, url, lastURL));
            dispatchEvent(new BrowserChangeEvent(BrowserChangeEvent.URL_CHANGE, false, false, url, lastURL));
        }
    }

	private function sandboxBrowserManagerHandler(event:Event):void
	{
		// cancel event to indicate that the message was heard
		event.preventDefault();
	}

    //--------------------------------------------------------------------------
    //
    //  Diagnostics
    //
    //--------------------------------------------------------------------------

    private function debugTrace(s:String):void
    {
        trace(s);
    }
}

}
