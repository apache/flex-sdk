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
 * This class acts as the SystemManager for a popup that is 
 * added to the top-level SystemManager from a sandboxed application.
 * Instead of the popup being a child of the top-level
 * SystemManager as is normally done, the popup is a child of a
 * SystemManagerProxy, created in the same sandbox. The SystemManagerProxy
 * is the actual display object added to the top-level SystemManager.
 * The scheme is done to give the popup a "friendly" SystemManager
 * it can talk to. Otherwise the popup would not be able to access the
 * SystemManager that is its parent. 
 */
public class SystemManagerProxy extends SystemManager
{
	include "../core/Version.as";


	/**
	 * Create a new SystemManagerProxy.
	 * 
	 * @param systemManager the system manager that this class is a proxy for.
	 *        This is the system manager in the same sandbox as the popup
	 * 		  that will eventually be added as a child of this class.
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
	
	private function proxyMouseDownHandler(event:MouseEvent):void
	{
		// Tell our parent system manager we are active.
	 	SystemManager(_systemManager).fireActivatedWindowEvent(this);
	}
	
	private var _systemManager:ISystemManager2;
	
	public function get systemManager():ISystemManager2
	{
		return _systemManager;
	}
	
		/**
	 *  @inheritDoc
	 */
	override public function getDefinitionByName(name:String):Object
	{
		return _systemManager.getDefinitionByName(name);
	}


	override public function create(... params):Object
	{
		return IFlexModuleFactory(_systemManager).create.apply(this, params);
	}

	override public function useBridge():Boolean
	{
		return false;		// proxy does not want to use the bridge
	}	
	

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
	 * Listen to when our popup has started dragging. Expand the mouse catcher to catch
	 * all the mouse moves when dragging.
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
	 * Called when dragging has stopped. We not reduce the size of the mouse
	 * catcher so client area may be clicked on.
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

	override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, 
											priority:int=0, useWeakReference:Boolean=false):void
	{
		super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		_systemManager.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}
	
	override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void 
	{
		super.removeEventListener(type, listener, useCapture);
		_systemManager.removeEventListener(type, listener, useCapture);		
	}
	
	/**
	 *  @inheritDoc
	 */
	override public function activate(f:IFocusManagerContainer):void
	{
		// trace("SM Proxy: activate " + f );
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

	override public function deactivate(f:IFocusManagerContainer):void
	{
		// trace("SM Proxy: deactivate " + f );

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

	public function activateProxy(f:IFocusManagerContainer):void
	{
		super.activate(f);	
	}

	public function deactivateProxy(f:IFocusManagerContainer):void
	{
		if (f)
			f.focusManager.deactivate();
	}
		
}

}