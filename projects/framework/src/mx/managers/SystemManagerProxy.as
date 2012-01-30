////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.managers
{

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import mx.core.FlexSprite;
import mx.core.IFlexModuleFactory;
import mx.core.ISWFBridgeGroup;
import mx.core.ISWFBridgeProvider;
import mx.core.mx_internal;
import mx.events.SWFBridgeEvent;
import mx.utils.NameUtil;
import mx.utils.SecurityUtil;
import mx.events.SWFBridgeRequest;
import mx.managers.systemClasses.MarshallingSupport;
import mx.managers.systemClasses.ChildManager;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 *  This class acts as the SystemManager for a popup window that is 
 *  added to a parent SystemManager from a compatible application.
 *  Instead of the popup window being a child of the host
 *  SystemManager as is normally done, the popup is a child of a
 *  SystemManagerProxy, created in the same application domain. 
 *  The SystemManagerProxy is the actual display object
 *  added to the host SystemManager.
 *  The scheme is done to give the popup window a SystemManager,
 *  with the same version of Flex and created in the same application domain,
 *  that the pop up window will be able to talk to. 
 */
public class SystemManagerProxy extends SystemManager
{
    include "../core/Version.as";

    /**
     *  Constructor.
     * 
     *  @param systemManager The system manager that this class is a proxy for.
     *  This is the system manager in the same application domain as the popup.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
     */
    public function SystemManagerProxy(systemManager:ISystemManager)
    {
        super();

        _systemManager = systemManager;

		mp = MarshallingSupport(systemManager.getImplementation("mx.managers::IMarshalSystemManager"));

        // We are a proxy for a popup - we are the hightest system manager.
        topLevel = true; 
                
        // Capture mouseDown so we can switch top level windows and activate
        // the right focus manager before the components inside start
        // processing the event.
        super.addEventListener(MouseEvent.MOUSE_DOWN, proxyMouseDownHandler, true);

        registerImplementation("mx.managers::IActiveWindowManager", new SystemManagerProxyActivePopUpManager(this));

        childManager = new ChildManager(this);
    }
        
	private var mp:MarshallingSupport;

    //--------------------------------------------------------------------------
    //
    //  Overriden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  screen
    //----------------------------------
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function get isProxy():Boolean
    {
        return true;
    }

    //----------------------------------
    //  screen
    //----------------------------------
    /**
     *  @inheritDoc
     */
    override public function get screen():Rectangle
    {
        // This is called to center an Alert over the systemManager
        // this proxy represents.
        return _systemManager.screen;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
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
    override public function get topLevelSystemManager():ISystemManager
    {
        // The document of this proxy is its pop up.
        return systemManager.topLevelSystemManager;
    }

    /**
     *  @inheritDoc
     */
    override public function get document():Object
    {
        // The document of this proxy is its pop up.
        return mp.findFocusManagerContainer(this);
    }

    /**
     *  @private
     */
    override public function set document(value:Object):void
    {
    }

    //----------------------------------
    //  systemManager
    //----------------------------------
    
    /**
     *  @private
     */
    private var _systemManager:ISystemManager;

    /**
     *  The SystemManager that is being proxied.
     *  This is the SystemManager of the application that created this proxy
     *  and the pop up window that is a child of this proxy.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    public function get systemManager():ISystemManager
    {
        return _systemManager;
    }
        
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: SystemManager
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
    override public function getDefinitionByName(name:String):Object
    {
        return _systemManager.getDefinitionByName(name);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function create(... params):Object
    {
        return IFlexModuleFactory(_systemManager).create.apply(this, params);
    }

	override public function getImplementation(interfaceName:String):Object
	{
        var obj:Object = super.getImplementation(interfaceName);
        if (obj) return obj;

		return _systemManager.getImplementation(interfaceName);
	}

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, 
                                            priority:int=0, useWeakReference:Boolean=false):void
    {
        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
        _systemManager.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void 
    {
        super.removeEventListener(type, listener, useCapture);
        _systemManager.removeEventListener(type, listener, useCapture);     
    }
    
	/**
	 *  @private
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
	 */
	override public function isTopLevel():Boolean
	{
		return systemManager.isTopLevel();
	}

       
    /**
     *  @inheritdoc
     * 
     *  proxy to real system manager.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */  
    override public function getVisibleApplicationRect(bounds:Rectangle = null):Rectangle
    {
        return _systemManager.getVisibleApplicationRect(bounds);    
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Activates the FocusManager in an IFocusManagerContainer for the 
     *  popup window parented by this proxy.
     * 
     *  @param f The top-level window whose FocusManager should be activated.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function activateByProxy(f:IFocusManagerContainer):void
    {
		var awm:IActiveWindowManager = 
			IActiveWindowManager(systemManager.getImplementation("mx.managers::IActiveWindowManager"));
        awm.activate(f);      
    }

    /**
     *  Deactivates the focus manager for the popup window
     *  parented by this proxy.
     * 
     *  @param f The top-level window whose FocusManager should be deactivated.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function deactivateByProxy(f:IFocusManagerContainer):void
    {
        if (f)
	        f.focusManager.deactivate();
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Handles mouse downs on the pop up window.
     */
    private function proxyMouseDownHandler(event:MouseEvent):void
    {
        // Tell our parent system manager we are active if our child
        // is a focus container. If our child is not a focus manager
        // container we will not be able to activate pop up in this proxy. 
        if (mp.findFocusManagerContainer(this))
            mp.dispatchActivatedWindowEvent(this);
    }


}

}


import flash.display.DisplayObject;
import flash.events.IEventDispatcher;
import mx.core.ISWFBridgeProvider;
import mx.events.SWFBridgeEvent;
import mx.managers.IActiveWindowManager;
import mx.managers.IFocusManagerContainer;
import mx.managers.IMarshalSystemManager;
import mx.managers.ISystemManager;
import mx.utils.NameUtil;
import mx.utils.SecurityUtil;

class SystemManagerProxyActivePopUpManager implements IActiveWindowManager
{

	private var systemManager:ISystemManager;

	public function SystemManagerProxyActivePopUpManager(systemManager:ISystemManager)
	{
		this.systemManager = systemManager;
	}

    /**
     *  @inheritDoc
     */
    public function activate(f:Object):void
    {
        // trace("SM Proxy: activate " + f );
        
        // Activate the proxied SystemManager.
		var mp:IMarshalSystemManager = 
			IMarshalSystemManager(systemManager.getImplementation("mx.managers::IMarshalSystemManager"));

        var bridge:IEventDispatcher =
	        mp.swfBridgeGroup ? mp.swfBridgeGroup.parentBridge : null;

        if (bridge)
        {
            var mutualTrust:Boolean =
		        SecurityUtil.hasMutualTrustBetweenParentAndChild(ISWFBridgeProvider(mp));

            var bridgeEvent:SWFBridgeEvent = new SWFBridgeEvent(
		        SWFBridgeEvent.BRIDGE_WINDOW_ACTIVATE,
				false, false,
				{ notifier: bridge,
					window: mutualTrust ? systemManager : NameUtil.displayObjectToString(DisplayObject(systemManager))
				});
                    
			systemManager.getSandboxRoot().dispatchEvent(bridgeEvent);
        }
    }

	/**
	 *  @inheritDoc
	 */
    public function deactivate(f:Object):void
    {
        // trace("SM Proxy: deactivate " + f );

	    // Deactivate the proxied SystemManager.

		var mp:IMarshalSystemManager = 
			IMarshalSystemManager (systemManager.getImplementation("mx.managers::IMarshalSystemManager"));
            
		var bridge:IEventDispatcher =
			mp.swfBridgeGroup ? mp.swfBridgeGroup.parentBridge : null;
            
	    if (bridge)
        {
            var mutualTrust:Boolean =
		        SecurityUtil.hasMutualTrustBetweenParentAndChild(ISWFBridgeProvider(mp));
                    
			var bridgeEvent:SWFBridgeEvent = new SWFBridgeEvent(
				SWFBridgeEvent.BRIDGE_WINDOW_DEACTIVATE,
                false, false,
				{ notifier: bridge,
				    window: mutualTrust ? systemManager : NameUtil.displayObjectToString(DisplayObject(systemManager))
				});

             systemManager.getSandboxRoot().dispatchEvent(bridgeEvent);
         }
    }

	public function get numModalWindows():int
	{
		return systemManager.numModalWindows;
	}

	/**
	 *  @private
	 */
	public function set numModalWindows(value:int):void
	{
        systemManager.numModalWindows = value;
	}

	/**
	 *  @inheritDoc
	 */
	public function addFocusManager(f:IFocusManagerContainer):void
	{
	}

	/**
	 *  @inheritDoc
	 */
	public function removeFocusManager(f:IFocusManagerContainer):void
	{
    }

}
