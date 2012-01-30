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
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.ApplicationDomain;
import flash.system.Capabilities;
import flash.text.Font;
import flash.text.TextFormat;
import flash.utils.Dictionary;
import flash.utils.Timer;
import flash.utils.getQualifiedClassName;

import mx.core.FlexSprite;
import mx.core.IChildList;
import mx.core.IFlexDisplayObject;
import mx.core.IFlexModuleFactory;
import mx.core.mx_internal;
import mx.managers.ISystemManager;
import mx.events.SandboxBridgeEvent;
import mx.utils.NameUtil;
import mx.utils.SandboxUtil;

// NOTE: Minimize the non-Flash classes you import here.
// Any dependencies of SystemManager have to load in frame 1,
// before the preloader, or anything else, can be displayed.

use namespace mx_internal;


/**
 *  This class acts as the SystemManager for a popup window that is 
 *  added to a parent SystemManager from a compatible application.
 *  Instead of the popup window being a child of the host
 *  SystemManager as is normally done, the popup is a child of a
 *  SystemManagerProxy, created in the same application domain. 
 *  The SystemManagerProxy is the actual display object added to the
 *  host SystemManager.
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
	 *  @param systemManager the system manager that this class is a proxy for.
	 *  This is the system manager in the same application domain as the popup.
	 */
	public function SystemManagerProxy(systemManager:ISystemManager2)
	{
		super();
		_systemManager = systemManager;
		topLevel = true;		// we are a proxy for a popup - we are the hightest system manager
		addEventListener("startDragging", startDraggingHandler);
		addEventListener("stopDragging", stopDraggingHandler);
		
		// capture mouse down so we can switch top level windows and activate
		// the right focus manager before the components inside start
		// processing the event
		addEventListener(MouseEvent.MOUSE_DOWN, proxyMouseDownHandler, true); 

	}
	
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  systemManager
    //----------------------------------
    
	private var _systemManager:ISystemManager2;

    /**
    *   The SystemManager that is being proxied. This is the SystemManager of
    *   the application that created this proxy and the pop up window
    *   that is a child of this proxy.
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
		return false;		// proxy does not want to use the bridge
	}	
	

    /**
     *  Override to size mouse catcher to the size fo the system manager we
     *  are the proxy for.
     */
	override mx_internal function resizeMouseCatcher():void
	{
		if (mouseCatcher)
		{
			var g:Graphics = mouseCatcher.graphics;
			var screen:Rectangle = SystemManager(_systemManager).screen;
			g.clear();
			g.beginFill(0x000000, 0);
			g.drawRect(0, 0, screen.width, screen.height);
			g.endFill();
		}
	}

	/**
	 *  @inheritDoc
	 */
	override public function activate(f:IFocusManagerContainer):void
	{
		// trace("SM Proxy: activate " + f );
		
		// activate the proxied SystemManager.
		var bridge:IEventDispatcher = _systemManager.sandboxBridgeGroup ? 
									  _systemManager.sandboxBridgeGroup.parentBridge : null;
		if (bridge)
		{
			var mutualTrust:Boolean = SandboxUtil.hasMutualTrustWithParent(_systemManager);
			var bridgeEvent:SandboxBridgeEvent = new SandboxBridgeEvent(SandboxBridgeEvent.ACTIVATE_WINDOW,
																		false,
																		false,
																		bridge,
																		mutualTrust ? this : 
																		NameUtil.displayObjectToString(this));
			bridge.dispatchEvent(bridgeEvent);
		}
	}

    /**
     *  @inheritDoc
     */
	override public function deactivate(f:IFocusManagerContainer):void
	{
		// trace("SM Proxy: deactivate " + f );

        // deactivate the proxied SystemManager.
		var sm:ISystemManager2 = ISystemManager2(_systemManager);
		var bridge:IEventDispatcher = sm.sandboxBridgeGroup ? sm.sandboxBridgeGroup.parentBridge : null;
		if (bridge)
		{
			var mutualTrust:Boolean = SandboxUtil.hasMutualTrustWithParent(_systemManager);
			var bridgeEvent:SandboxBridgeEvent = new SandboxBridgeEvent(SandboxBridgeEvent.DEACTIVATE_WINDOW,
																	    false, 
																	    false,
																		bridge,
																		mutualTrust ? this : 
																		NameUtil.displayObjectToString(this));
			bridge.dispatchEvent(bridgeEvent);
		}
	}

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Activates the FocusManager in an IFocusManagerContainer for the 
     *  pop up window parented by this proxy.
     * 
     *  @param f IFocusManagerContainer the top-level window
     *  whose FocusManager should be activated.
     */
	public function activateProxy(f:IFocusManagerContainer):void
	{
		super.activate(f);	
	}

    /**
     *  Deactivates the focus manager for the pop up window parented by this 
     *  proxy.
     * 
     *  @param f IFocusManagerContainer the top-level window
     *  whose FocusManager should be deactivated.
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
     * 
     *  Handle mouse downs on the pop up window.
     */
    private function proxyMouseDownHandler(event:MouseEvent):void
    {
        // Tell our parent system manager we are active.
        SystemManager(_systemManager).fireActivatedWindowEvent(this);
    }
    
    /**
     *  Listen to when our popup has started dragging. Expand the mouse catcher to catch
     *  all the mouse moves when dragging.
     */
    private function startDraggingHandler(event:Event):void
    {
        // trace("startDraggingHandler");
        // Add the mouseCatcher as child 0.
        if (!mouseCatcher)
        {
            mouseCatcher = new FlexSprite();
            mouseCatcher.name = "mouseCatcher";
            // Must use addChildAt because a creationComplete handler can create a
            // dialog and insert it at 0.
            noTopMostIndex++;
            $addChildAt(mouseCatcher, 0);   
            resizeMouseCatcher();
            if (!topLevel)
            {
                mouseCatcher.visible = false;
                mask = mouseCatcher;
            }
        }

        var screen:Rectangle = SystemManager(_systemManager).screen;
        setActualSize(screen.width, screen.height);
    }
    
    /**
     *  Called when dragging has stopped. We not reduce the size of the mouse
     *  catcher so client area may be clicked on.
     */
    private function stopDraggingHandler(event:Event):void
    {
        // trace("stopDraggingHandler");
        if (mouseCatcher)
        {
            $removeChildAt(0);
            noTopMostIndex--;
            mouseCatcher = null;
        }
    }

}

}