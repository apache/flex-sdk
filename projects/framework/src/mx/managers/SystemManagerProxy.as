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

import flash.display.Graphics;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import mx.core.FlexSprite;
import mx.core.IFlexModuleFactory;
import mx.core.mx_internal;
import mx.events.SandboxBridgeEvent;
import mx.utils.NameUtil;
import mx.utils.SandboxUtil;

use namespace mx_internal;

/**
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
	 */
	public function SystemManagerProxy(systemManager:ISystemManager2)
	{
		super();

		_systemManager = systemManager;

		// We are a proxy for a popup - we are the hightest system manager.
        topLevel = true; 
		
		// Capture mouseDown so we can switch top level windows and activate
		// the right focus manager before the components inside start
		// processing the event.
		addEventListener(MouseEvent.MOUSE_DOWN, proxyMouseDownHandler, true); 
	}
	
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
     */
    override public function get screen():Rectangle
    {
        return _systemManager.screen;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  systemManager
    //----------------------------------
    
	/**
     *  @private
     */
    private var _systemManager:ISystemManager2;

    /**
     *  The SystemManager that is being proxied.
     *  This is the SystemManager of the application that created this proxy
     *  and the pop up window that is a child of this proxy.
     */	
	public function get systemManager():ISystemManager2
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
	 */
	override public function getDefinitionByName(name:String):Object
	{
		return _systemManager.getDefinitionByName(name);
	}

    /**
     *  @inheritDoc
     */
	override public function create(... params):Object
	{
		return IFlexModuleFactory(_systemManager).create.apply(this, params);
	}

    /**
     *  @inheritDoc
     */
	override public function useBridge():Boolean
	{
		return false; // proxy does not want to use the bridge
	}	
	
	/**
	 *  @inheritDoc
	 */
	override public function activate(f:IFocusManagerContainer):void
	{
		// trace("SM Proxy: activate " + f );
		
		// Activate the proxied SystemManager.

		var bridge:IEventDispatcher =
            _systemManager.sandboxBridgeGroup ? 
			_systemManager.sandboxBridgeGroup.parentBridge :
            null;

		if (bridge)
		{
			var mutualTrust:Boolean =
                SandboxUtil.hasMutualTrustWithParent(_systemManager);

			var bridgeEvent:SandboxBridgeEvent = new SandboxBridgeEvent(
                SandboxBridgeEvent.ACTIVATE_WINDOW,
                false, false, bridge,
				mutualTrust ? this : NameUtil.displayObjectToString(this));
			
            bridge.dispatchEvent(bridgeEvent);
		}
	}

    /**
     *  @inheritDoc
     */
	override public function deactivate(f:IFocusManagerContainer):void
	{
		// trace("SM Proxy: deactivate " + f );

        // Deactivate the proxied SystemManager.

		var sm:ISystemManager2 = ISystemManager2(_systemManager);
		
        var bridge:IEventDispatcher =
            sm.sandboxBridgeGroup ? sm.sandboxBridgeGroup.parentBridge : null;
		
        if (bridge)
		{
			var mutualTrust:Boolean =
                SandboxUtil.hasMutualTrustWithParent(_systemManager);
			
            var bridgeEvent:SandboxBridgeEvent = new SandboxBridgeEvent(
                SandboxBridgeEvent.DEACTIVATE_WINDOW,
				false, false, bridge,
				mutualTrust ? this : NameUtil.displayObjectToString(this));

			bridge.dispatchEvent(bridgeEvent);
		}
	}
	
    /**
     *  @inheritdoc
     * 
     *  proxy to real system manager.
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
     */
	public function activateProxy(f:IFocusManagerContainer):void
	{
		super.activate(f);	
	}

    /**
     *  Deactivates the focus manager for the popup window
     *  parented by this proxy.
     * 
     *  @param f The top-level window whose FocusManager should be deactivated.
     */
	public function deactivateProxy(f:IFocusManagerContainer):void
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
        if (findFocusManagerContainer(this))
            SystemManager(_systemManager).fireActivatedWindowEvent(this);
    }
}

}
