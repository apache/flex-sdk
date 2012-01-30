////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.managers.marshalClasses
{
import flash.display.DisplayObject;
import flash.events.Event;

import mx.core.IFlexModuleFactory;
import mx.core.IToolTip;
import mx.events.DynamicEvent;
import mx.events.InterManagerRequest;
import mx.events.ToolTipEvent;
import mx.managers.IMarshalSystemManager;
import mx.managers.ISystemManager;
import mx.managers.SystemManagerGlobals;
import mx.managers.ToolTipManagerImpl;
import mx.core.mx_internal;

use namespace mx_internal;

[ExcludeClass]

[Mixin]

/**
 *  @private
 *  A SystemManager has various types of children,
 *  such as the Application, popups, 
 *  tooltips, and custom cursors.
 *  You can access the just the custom cursors through
 *  the <code>cursors</code> property,
 *  the tooltips via <code>toolTips</code>, and
 *  the popups via <code>popUpChildren</code>.  Each one returns
 *  a SystemChildrenList which implements IChildList.  The SystemManager's
 *  IChildList methods return the set of children that aren't popups, tooltips
 *  or cursors.  To get the list of all children regardless of type, you
 *  use the rawChildrenList property which returns this SystemRawChildrenList.
 */
public class ToolTipManagerMarshalMixin
{
    include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class Method
	//
	//--------------------------------------------------------------------------
	
	public static function init(fbs:IFlexModuleFactory):void
	{
		if (!ToolTipManagerImpl.mixins)
			ToolTipManagerImpl.mixins = [];
        if (ToolTipManagerImpl.mixins.indexOf(ToolTipManagerMarshalMixin) == -1)
    		ToolTipManagerImpl.mixins.push(ToolTipManagerMarshalMixin);
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function ToolTipManagerMarshalMixin(owner:ToolTipManagerImpl = null)
	{
		super();
        
        if (!owner)
            return;

		this.toolTipManager = owner;
		toolTipManager.addEventListener("initialize", initializeHandler);
		toolTipManager.addEventListener("currentToolTip", currentToolTipHandler);
		toolTipManager.addEventListener(ToolTipEvent.TOOL_TIP_HIDE, toolTipHideHandler);
		toolTipManager.addEventListener("createTip", createTipHandler);
		toolTipManager.addEventListener("removeChild", removeChildHandler);
		toolTipManager.addEventListener("addChild", addChildHandler);
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private var toolTipManager:ToolTipManagerImpl;

	private var systemManager:ISystemManager;

	private var sandboxRoot:DisplayObject;

	private var mp:IMarshalSystemManager;

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------


	public function initializeHandler(event:Event):void
	{
		this.systemManager = SystemManagerGlobals.topLevelSystemManagers[0] as ISystemManager;
		mp = IMarshalSystemManager(systemManager.getImplementation("mx.managers::IMarshalSystemManager"));
		sandboxRoot = this.systemManager.getSandboxRoot();
		sandboxRoot.addEventListener(InterManagerRequest.TOOLTIP_MANAGER_REQUEST, marshalToolTipManagerHandler, false, 0, true);
		var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.TOOLTIP_MANAGER_REQUEST);
		me.name = "update";
		// trace("--->update request for ToolTipManagerImpl", systemManager);
		sandboxRoot.dispatchEvent(me);
		// trace("<---update request for ToolTipManagerImpl", systemManager);
	}


	public function currentToolTipHandler(event:Event):void
	{
		var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.TOOLTIP_MANAGER_REQUEST);
		me.name = "currentToolTip";
		me.value = toolTipManager.currentToolTip;
		// trace("-->dispatched currentToolTip for ToolTipManagerImpl", systemManager, value);
		sandboxRoot.dispatchEvent(me);
	}

	public function toolTipHideHandler(event:Event):void
	{
		var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.TOOLTIP_MANAGER_REQUEST);
		me.name = ToolTipEvent.TOOL_TIP_HIDE;
		// trace("-->dispatched hide for ToolTipManagerImpl", systemManager);
		sandboxRoot.dispatchEvent(me);
	}

	public function createTipHandler(event:Event):void
	{
        var sm:ISystemManager = toolTipManager.getSystemManager(toolTipManager.currentTarget) as ISystemManager;
		mp = IMarshalSystemManager(sm.topLevelSystemManager.getImplementation("mx.managers::IMarshalSystemManager"));	
       	mp.addChildToSandboxRoot("toolTipChildren", toolTipManager.currentToolTip as DisplayObject);
        event.preventDefault();
	}

	public function removeChildHandler(event:DynamicEvent):void
	{
        // Remove it.
        var sm:ISystemManager = event.sm;
		mp = IMarshalSystemManager(sm.topLevelSystemManager.getImplementation("mx.managers::IMarshalSystemManager"));	
		mp.removeChildFromSandboxRoot("toolTipChildren", event.toolTip as DisplayObject);
        event.preventDefault();
	}

	public function addChildHandler(event:DynamicEvent):void
	{
        var sm:ISystemManager = event.sm;
		mp = IMarshalSystemManager(sm.topLevelSystemManager.getImplementation("mx.managers::IMarshalSystemManager"));	
		mp.addChildToSandboxRoot("toolTipChildren", event.toolTip as DisplayObject);
        event.preventDefault();
	}

	/**
	 *  Marshal dragManager
     *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	private function marshalToolTipManagerHandler(event:Event):void
	{
		if (event is InterManagerRequest)
			return;

		var me:InterManagerRequest;

		var marshalEvent:Object = event;
		switch (marshalEvent.name)
		{
		case "currentToolTip":
			// trace("--marshaled currentToolTip for ToolTipManagerImpl", systemManager, marshalEvent.value);
			toolTipManager._currentToolTip = marshalEvent.value;
			break;
		case ToolTipEvent.TOOL_TIP_HIDE:
			// trace("--handled hide for ToolTipManagerImpl", systemManager);
			if (toolTipManager._currentToolTip is IToolTip)
				toolTipManager.hideTip()
			break;
		case "update":
			// anyone can answer so prevent others from responding as well
			event.stopImmediatePropagation();
			// update the others
			// trace("-->marshaled update for ToolTipManagerImpl", systemManager);
			me = new InterManagerRequest(InterManagerRequest.TOOLTIP_MANAGER_REQUEST);
			me.name = "currentToolTip";
			me.value = toolTipManager._currentToolTip;
			// trace("-->dispatched currentToolTip for ToolTipManagerImpl", systemManager, true);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatched currentToolTip for ToolTipManagerImpl", systemManager, true);
			// trace("<--marshaled update for ToolTipManagerImpl", systemManager);
		}
	}

}

}
