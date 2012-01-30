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
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.geom.Rectangle;
import flash.geom.Point;

import mx.core.FlexGlobals;
import mx.core.IFlexDisplayObject;
import mx.core.IFlexModuleFactory;
import mx.core.ISWFLoader;
import mx.core.IUIComponent;
import mx.core.mx_internal;
import mx.events.DynamicEvent;
import mx.events.InterManagerRequest;
import mx.events.MoveEvent;
import mx.events.Request;
import mx.events.SandboxMouseEvent;
import mx.events.SWFBridgeRequest;
import mx.managers.IActiveWindowManager;
import mx.managers.IFocusManagerContainer;
import mx.managers.IMarshalSystemManager;
import mx.managers.ISystemManager;
import mx.managers.PopUpManagerImpl;
import mx.managers.PopUpData;
import mx.managers.SystemManager;
import mx.managers.SystemManagerGlobals;
import mx.managers.SystemManagerProxy;
import mx.styles.IStyleClient;
import mx.utils.NameUtil;

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
public class PopUpManagerMarshalMixin
{
    include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class Method
	//
	//--------------------------------------------------------------------------
	
	public static function init(fbs:IFlexModuleFactory):void
	{
		if (!PopUpManagerImpl.mixins)
			PopUpManagerImpl.mixins = [];
        if (PopUpManagerImpl.mixins.indexOf(PopUpManagerMarshalMixin) == -1)
        {
		    PopUpManagerImpl.mixins.push(PopUpManagerMarshalMixin);
		    PopUpManagerImpl.popUpInfoClass = MarshalPopUpData;
        }
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function PopUpManagerMarshalMixin(owner:PopUpManagerImpl = null)
	{
		super();

        if (!owner)
            return;
      
		this.popUpManager = owner;
		sm = ISystemManager(SystemManagerGlobals.topLevelSystemManagers[0]);
		popUpManager.addEventListener("initialize", initializeHandler);
		popUpManager.addEventListener("addPopUp", addPopUpHandler);
		popUpManager.addEventListener("addPlaceHolder", addPlaceHolderHandler);
		popUpManager.addEventListener("addedPopUp", addedPopUpHandler);
		popUpManager.addEventListener("topLevelSystemManager", topLevelSystemManagerHandler);
		popUpManager.addEventListener("isTopLevelRoot", isTopLevelRootHandler);
		popUpManager.addEventListener("bringToFront", bringToFrontHandler);
		popUpManager.addEventListener("createModalWindow", createModalWindowHandler);
		popUpManager.addEventListener("updateModalMask", updateModalMaskHandler);
		popUpManager.addEventListener("createdModalWindow", createdModalWindowHandler);
		popUpManager.addEventListener("showModalWindow", showModalWindowHandler);
		popUpManager.addEventListener("blurTarget", blurTargetHandler);
		popUpManager.addEventListener("hideModalWindow", hideModalWindowHandler);
		popUpManager.addEventListener("addMouseOutEventListeners", addMouseOutEventListenersHandler);
		popUpManager.addEventListener("removeMouseOutEventListeners", removeMouseOutEventListenersHandler);
		popUpManager.addEventListener("popUpRemoved", popUpRemovedHandler);
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private var popUpManager:PopUpManagerImpl;

    private var sm:ISystemManager;

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------


	public function initializeHandler(event:Event):void
	{
        sm.addEventListener(SWFBridgeRequest.CREATE_MODAL_WINDOW_REQUEST, createModalWindowRequestHandler, false, 0, true);
        sm.addEventListener(SWFBridgeRequest.SHOW_MODAL_WINDOW_REQUEST, showModalWindowRequest, false, 0, true);
        sm.addEventListener(SWFBridgeRequest.HIDE_MODAL_WINDOW_REQUEST, hideModalWindowRequest, false, 0, true);
	}


	public function addPopUpHandler(event:Request):void
	{
		var sm:ISystemManager = event.value.sm as ISystemManager;
		var parent:DisplayObjectContainer = event.value.parent as DisplayObjectContainer;
        if (!sm)
        {
            // check if parent is our sandbox root
            sm = ISystemManager(SystemManagerGlobals.topLevelSystemManagers[0]);
            if (sm.getSandboxRoot() != parent)
            {
                //trace("error: popup root was not SystemManager");
                return; // and maybe a nice error message
            }
        }

		// if using a bridge, then create a System Manager Proxy to host
		// the popup. The System Manager Proxy is the display object
		// added to the top-level system manager's children, not
		// the popup itself.
		var sbRoot:DisplayObject = sm.getSandboxRoot();
		var request:SWFBridgeRequest = null;
		var mp:IMarshalSystemManager = 
			IMarshalSystemManager(sm.getImplementation("mx.managers::IMarshalSystemManager"));
		if (mp.useSWFBridge())
		{
			if (sbRoot != sm)
			{
				var smp:SystemManagerProxy = new SystemManagerProxy(sm);
				request = new SWFBridgeRequest(SWFBridgeRequest.ADD_POP_UP_REQUEST, false, false,
				                                    mp.swfBridgeGroup.parentBridge,
													{ window: DisplayObject(smp),
														parent: parent,
														modal: event.value.modal,
														childList: event.value.childList});
				sbRoot.dispatchEvent(request);
				event.value = smp;
				event.preventDefault();
			}
		}
	}

	public function addPlaceHolderHandler(event:DynamicEvent):void
	{
		var sm:ISystemManager = event.sm as ISystemManager;
		var window:IFlexDisplayObject = event.window as IFlexDisplayObject
		var sbRoot:DisplayObject = sm.getSandboxRoot();
		var mp:IMarshalSystemManager = 
			IMarshalSystemManager(sm.getImplementation("mx.managers::IMarshalSystemManager"));

		// add a placeholder for an untrusted popup if this system manager
		// is hosting the popup.
		if (!sm.isTopLevelRoot() && sbRoot && DisplayObject(sm) == sbRoot)
		{
			var request:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.ADD_POP_UP_PLACE_HOLDER_REQUEST, false, false, null, { window: DisplayObject(window)});
			request.requestor = mp.swfBridgeGroup.parentBridge;
			request.data.placeHolderId = NameUtil.displayObjectToString(DisplayObject(window));
			sm.dispatchEvent(request);
		} 
	}

	public function addedPopUpHandler(event:DynamicEvent):void
	{
		var smp:ISystemManager = ISystemManager(event.systemManager);

		var awm:IActiveWindowManager = 
			IActiveWindowManager(smp.getImplementation("mx.managers::IActiveWindowManager"));

		var mp:IMarshalSystemManager = 
			IMarshalSystemManager(smp.getImplementation("mx.managers::IMarshalSystemManager"));

        if (!(smp is SystemManagerProxy) && mp.useSWFBridge())
         	// We want the top-level root to activate the window.
         	mp.dispatchActivatedWindowEvent(DisplayObject(event.window));
        else
            awm.activate(IFocusManagerContainer(event.window));
	}

	public function topLevelSystemManagerHandler(event:Request):void
	{
		var parent:DisplayObjectContainer = event.value as DisplayObjectContainer;
		var localRoot:DisplayObjectContainer;

		if (parent.parent is SystemManagerProxy)
			localRoot = DisplayObjectContainer(SystemManagerProxy(parent.parent).systemManager);
		else if (parent is IUIComponent && IUIComponent(parent).systemManager is SystemManagerProxy)
			localRoot = DisplayObjectContainer(SystemManagerProxy(IUIComponent(parent).systemManager).systemManager);

		if (localRoot)
		{
			event.value = localRoot;
			event.preventDefault();
		}
	}


	public function isTopLevelRootHandler(event:Request):void
	{
        // Only need to calc the visible rect when the sandbox root is an untrusted application.
        // Otherwise the alert will float over the entire application.
        if (sm != sm.getSandboxRoot())
        {
            var request:InterManagerRequest = new InterManagerRequest(InterManagerRequest.SYSTEM_MANAGER_REQUEST, false, false,
                                                        "isTopLevelRoot");
            sm.getSandboxRoot().dispatchEvent(request);
            event.value = Boolean(request.value);
			event.preventDefault();
        }
	}

	public function bringToFrontHandler(event:DynamicEvent):void
	{
		var o:PopUpData = event.popUpData;
		var popUp:IFlexDisplayObject = event.popUp;
        const sm:ISystemManager = ISystemManager(popUp.parent);
        if (sm is SystemManagerProxy)
        {
            // Since the proxy is parented to the SystemManager we need to 
            // be it to the front, not the pop up.
            var request:InterManagerRequest = new InterManagerRequest(InterManagerRequest.SYSTEM_MANAGER_REQUEST, 
                                    false, false,
                                    "bringToFront", 
                                    {topMost: o.topMost, popUp: sm}); 
            sm.getSandboxRoot().dispatchEvent(request);
            event.preventDefault();
        }
	}

	public function createModalWindowHandler(event:DynamicEvent):void
	{
		var o:MarshalPopUpData = event.popUpData;
		var popUp:IFlexDisplayObject = event.popUp;
		var popupStyleClient:IStyleClient = popUp as IStyleClient;

        // set alpha of the popup and get it out of the focus loop
        if (!isNaN(o.modalTransparency))
            o.modalWindow.alpha = o.modalTransparency;
		o.modalTransparency = o.modalWindow.alpha;
			
        if (!isNaN(o.modalTransparencyColor))
            event.color = o.modalTransparencyColor;
        o.modalTransparencyColor = event.color;

		event.preventDefault();
    }

	public function updateModalMaskHandler(event:DynamicEvent):void
	{
		var o:MarshalPopUpData = event.popUpData;
        if (o.exclude)
        {
            o.modalMask = new Sprite();
            updateModalMask(sm, o.modalWindow, 
                            o.useExclude ? o.exclude : null, 
                            o.excludeRect, o.modalMask);    
            o.modalWindow.mask = o.modalMask;
            event.childrenList.addChild(o.modalMask);
            
            // update the modal window mask when the size or position of the area 
            // we are excluding changes.
            o.exclude.addEventListener(Event.RESIZE, o.resizeHandler);
            o.exclude.addEventListener(MoveEvent.MOVE, o.resizeHandler);
        }
    }
    
    public function createdModalWindowHandler(event:DynamicEvent):void
    {
		var o:MarshalPopUpData = event.popUpData;
		var popUp:IFlexDisplayObject = event.popUp;
		var popupStyleClient:IStyleClient = popUp as IStyleClient;

        var mp:IMarshalSystemManager = 
			IMarshalSystemManager(sm.getImplementation("mx.managers::IMarshalSystemManager"));

        if (mp.useSWFBridge())
        {
            if (popupStyleClient)
            {
                o.modalTransparencyDuration = popupStyleClient.getStyle("modalTransparencyDuration");
                o.modalTransparencyBlur = popupStyleClient.getStyle("modalTransparencyBlur");
            }

            dispatchModalWindowRequest(SWFBridgeRequest.CREATE_MODAL_WINDOW_REQUEST, sm, sm.getSandboxRoot(), o, event.visibleFlag);
        }            
	}

    /**
     *  @private
     * 
     *  Update a mask to exclude the area of the exclude parameter from the area 
     *  of the modal window parameter.
     * 
     *  @param sm The system manager that hosts the modal window
     *  @param modalWindow The base area of the mask
     *  @param exclude The area to exlude from the mask, may be null.
     *  @param excludeRect An optionally rectangle that is included in the area
     *  to exclude. The rectangle is in global coordinates.
     *  @param mask A non-null sprite. The mask is rewritten for each call.
     * 
     */  
    mx_internal static function updateModalMask(sm:ISystemManager,
                                     modalWindow:DisplayObject, 
                                     exclude:IUIComponent, 
                                     excludeRect:Rectangle,
                                     mask:Sprite):void
    {
        var modalBounds:Rectangle = modalWindow.getBounds(DisplayObject(sm));
        var excludeBounds:Rectangle;
        var pt:Point;
            
        if (exclude is ISWFLoader) 
        {
            excludeBounds = ISWFLoader(exclude).getVisibleApplicationRect();
            pt = new Point(excludeBounds.x, excludeBounds.y);
            pt = DisplayObject(sm).globalToLocal(pt);
            excludeBounds.x = pt.x;
            excludeBounds.y = pt.y;    
        }
        else if (!exclude)
            excludeBounds = modalBounds.clone();    // don't exclude anything extra
        else 
            excludeBounds = DisplayObject(exclude).getBounds(DisplayObject(sm));
        
        // apply excludeRect to the result
        if (excludeRect)
        {
            pt = new Point(excludeRect.x, excludeRect.y);
            pt = DisplayObject(sm).globalToLocal(pt);
            var rect:Rectangle = new Rectangle(pt.x, pt.y, excludeRect.width, excludeRect.height);
            excludeBounds = excludeBounds.intersection(rect);
        }
        
        mask.graphics.clear();
        mask.graphics.beginFill(0x000000);
        
        // Fill the mask in three logical rows
        // 1. Above the exclude bounds
        if (excludeBounds.y > modalBounds.y)
            mask.graphics.drawRect(modalBounds.x, modalBounds.y, 
                                   modalBounds.width, excludeBounds.y - modalBounds.y);
                     
        // 2. Left and right of the exclude bounds
        if (modalBounds.x < excludeBounds.x)              
            mask.graphics.drawRect(modalBounds.x, excludeBounds.y, 
                                   excludeBounds.x - modalBounds.x, excludeBounds.height);
                                   
        if ((modalBounds.x + modalBounds.width) > (excludeBounds.x + excludeBounds.width))
            mask.graphics.drawRect(excludeBounds.x + excludeBounds.width, 
                                   excludeBounds.y, 
                                   modalBounds.x + modalBounds.width - excludeBounds.x - excludeBounds.width, 
                                   excludeBounds.height);
                                   
        // 3. Below the exclude bounds
        if ((excludeBounds.y + excludeBounds.height) < (modalBounds.y + modalBounds.height))
            mask.graphics.drawRect(modalBounds.x, excludeBounds.y + excludeBounds.height, 
                                   modalBounds.width, 
                                   modalBounds.y + modalBounds.height - excludeBounds.y - excludeBounds.height);
        mask.graphics.endFill();
                         
    }                                     

    private function dispatchModalWindowRequest(type:String, 
                                                sm:ISystemManager, 
                                                sbRoot:DisplayObject, 
                                                o:MarshalPopUpData,
                                                visibleFlag:Boolean):void
    {
        // if our first target is a sandbox root that is the top level root,
        // then we don't need to send a modal request. 
        if (!o.isRemoteModalWindow && sm != sbRoot)
        {
            var request:InterManagerRequest = new InterManagerRequest(InterManagerRequest.SYSTEM_MANAGER_REQUEST, false, false,
                                                        "isTopLevelRoot");
            sbRoot.dispatchEvent(request);
            if (Boolean(request.value))
                return;
        }
        
		var mp:IMarshalSystemManager = 
			IMarshalSystemManager(sm.getImplementation("mx.managers::IMarshalSystemManager"));

        var modalRequest:SWFBridgeRequest = new SWFBridgeRequest(type, false, false, null,
												{ skip: !o.isRemoteModalWindow && sm != sbRoot,
												  useExclude: o.useExclude,   
												  show: visibleFlag,
												  remove: false,
												  transparencyDuration: o.modalTransparencyDuration,
												  transparency: o.modalTransparency,
												  transparencyColor: o.modalTransparencyColor,
												  transparencyBlur: o.modalTransparencyBlur});
        var bridge:IEventDispatcher = mp.swfBridgeGroup.parentBridge;; 
        modalRequest.requestor = bridge;
        bridge.dispatchEvent(modalRequest);
    }
    
	public function showModalWindowHandler(event:DynamicEvent):void
	{
		event.preventDefault();

		var o:MarshalPopUpData = event.popUpData;
		var popUp:IFlexDisplayObject = o.owner as IFlexDisplayObject;
        var sm:ISystemManager = event.systemManager;

        if (!isNaN(o.modalTransparencyDuration))
            event.duration = o.modalTransparencyDuration;
        o.modalTransparencyDuration = event.duration;

        if (!isNaN(o.modalTransparency))
            event.alpha = o.modalTransparency;
        o.modalTransparency = event.alpha;

        if (!isNaN(o.modalTransparencyBlur))
            event.blurAmount = o.modalTransparencyBlur;
    	o.modalTransparencyBlur = event.blurAmount;

		if (!isNaN(o.modalTransparencyColor))
	        event.transparencyColor = o.modalTransparencyColor;
    	o.modalTransparencyColor = event.transparencyColor;

		var mp:IMarshalSystemManager = 
			IMarshalSystemManager(sm.getImplementation("mx.managers::IMarshalSystemManager"));

        if (sm is SystemManagerProxy)
            sm = SystemManagerProxy(sm).systemManager;
        if (event.sendRequest && mp.useSWFBridge())
            dispatchModalWindowRequest(SWFBridgeRequest.SHOW_MODAL_WINDOW_REQUEST, sm, sm.getSandboxRoot(), o, true);
	}


	public function blurTargetHandler(event:Request):void
	{
		var o:PopUpData = event.value.popUpData;
		var popUp:IFlexDisplayObject = o.owner as IFlexDisplayObject;
        const sm:ISystemManager = ISystemManager(popUp.parent);

		var sbRoot:DisplayObject = sm.getSandboxRoot();

        var applicationRequest:InterManagerRequest = new InterManagerRequest(InterManagerRequest.SYSTEM_MANAGER_REQUEST,
                                                           false, false,
                                                           "application",
                                                           sbRoot);
        sbRoot.dispatchEvent(applicationRequest);
        event.value = applicationRequest.value;
		event.preventDefault();
	}

	public function hideModalWindowHandler(event:DynamicEvent):void
	{
		var o:MarshalPopUpData = event.popUpData;
		var destroy:Boolean = event.destroy;

        if (destroy && o.exclude)
        {
            o.exclude.removeEventListener(Event.RESIZE, o.resizeHandler);
            o.exclude.removeEventListener(MoveEvent.MOVE, o.resizeHandler);
        }

        var sm:ISystemManager = ISystemManager(FlexGlobals.topLevelApplication.systemManager);

		var mp:IMarshalSystemManager = 
			IMarshalSystemManager(sm.getImplementation("mx.managers::IMarshalSystemManager"));

        if (mp.useSWFBridge())
        {
            var sbRoot:DisplayObject = sm.getSandboxRoot();
            
            // if our first target is a sandbox root that is the top level root,
            // then we don't need to send a modal request. 
            if (!o.isRemoteModalWindow && sm != sbRoot)
            {
                var request:InterManagerRequest = new InterManagerRequest(InterManagerRequest.SYSTEM_MANAGER_REQUEST, false, false,
                                                            "isTopLevelRoot");
                sbRoot.dispatchEvent(request);
                if (Boolean(request.value))
                    return;
            }
            
            var modalRequest:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.HIDE_MODAL_WINDOW_REQUEST, false, false, null,
														{ skip: !o.isRemoteModalWindow && sm != sbRoot, 
															show: false,
															remove: destroy});
            var bridge:IEventDispatcher = mp.swfBridgeGroup.parentBridge;
            var target:IEventDispatcher;
            modalRequest.requestor = bridge;

            bridge.dispatchEvent(modalRequest);
        }
	}

    /**
     *  @private
     *  
     *  Create a modal window and optionally show it.
     */ 
    private function createModalWindowRequestHandler(event:Event):void
    {
        var request:SWFBridgeRequest;

        if (event is SWFBridgeRequest)
            request = SWFBridgeRequest(event);
        else
            request = SWFBridgeRequest.marshal(event);

        var sm:ISystemManager = popUpManager.getTopLevelSystemManager(DisplayObject(FlexGlobals.topLevelApplication));
		var mp:IMarshalSystemManager = 
			IMarshalSystemManager(sm.getImplementation("mx.managers::IMarshalSystemManager"));

        var sbRoot:DisplayObject = sm.getSandboxRoot();

        // process the message
        var popUpData:MarshalPopUpData = MarshalPopUpData(PopUpManagerImpl.createPopUpData());
        popUpData.isRemoteModalWindow = true;
        popUpData.systemManager = sm;
        popUpData.modalTransparency = request.data.transparency;
        
        // disable blur because we can mask the application and blur is not
        // working if we blur the modalWindow.
        popUpData.modalTransparencyBlur = 0; //request.transparencyBlur;
        popUpData.modalTransparencyColor = request.data.transparencyColor;
        popUpData.modalTransparencyDuration = request.data.transparencyDuration;

        // Get the SWFLoader to exclude.
        // The requestor may be a real SWFLoader or a sandbox bridge that 
        // requires a look up to get the SWFLoader. 
        popUpData.exclude = mp.swfBridgeGroup.getChildBridgeProvider(request.requestor) as IUIComponent;
        popUpData.useExclude = request.data.useExclude;
        popUpData.excludeRect = Rectangle(request.data.excludeRect);
        
        popUpManager.popupInfo.push(popUpData);
        
        popUpManager.createModalWindow(null, popUpData, sm.popUpChildren, request.data.show, sm, sbRoot);
    }
    
    /**
     *  @private
     *  
     *  Show a modal window.
     */ 
    private function showModalWindowRequest(event:Event):void
    {
        var request:SWFBridgeRequest = SWFBridgeRequest.marshal(event);

        if (event is SWFBridgeRequest)
            request = SWFBridgeRequest(event);
        else
            request = SWFBridgeRequest.marshal(event);

        var sm:ISystemManager = popUpManager.getTopLevelSystemManager(DisplayObject(FlexGlobals.topLevelApplication));
		var mp:IMarshalSystemManager = 
			IMarshalSystemManager(sm.getImplementation("mx.managers::IMarshalSystemManager"));
        var sbRoot:DisplayObject = sm.getSandboxRoot();
        
        // the highest popUpData in the list is the most recent modal window.
        // sanity check that the popupdata is really a modal window with a null
        // parent and popup window.
        var popUpData:MarshalPopUpData = findHighestRemoteModalPopupInfo();
        popUpData.excludeRect = Rectangle(request.data);
        popUpData.modalTransparency = request.data.transparency;
        
        // disable blur because we can mask the application and blur is not
        // working if we blur the modalWindow.
        popUpData.modalTransparencyBlur = 0; //request.transparencyBlur;
        popUpData.modalTransparencyColor = request.data.transparencyColor;
        popUpData.modalTransparencyDuration = request.data.transparencyDuration;

        if (popUpData.owner || popUpData.parent)
            throw new Error();              // not popUpData for a modal window
        
        popUpManager.showModalWindow(popUpData, sm);
    }
    
    /**
     *  @private
     *  
     *  Hide a modal window and optionally remove it.
     */ 
    private function hideModalWindowRequest(event:Event):void
    {
        var request:SWFBridgeRequest;
        
        // If the event is redispatched from the SystemManger it will be
        // marshalled. If the PopUpManager dispatches the event using
        // the sandbox root it will come here directly.
        if (event is SWFBridgeRequest)
            request = SWFBridgeRequest(event);
        else
            request = SWFBridgeRequest.marshal(event);

        var sm:ISystemManager = popUpManager.getTopLevelSystemManager(DisplayObject(FlexGlobals.topLevelApplication));
        var sbRoot:DisplayObject = sm.getSandboxRoot();
        
        // the highest popUpData in the list is the most recent modal window.
        // sanity check that the popupdata is really a modal window with a null
        // parent and popup window.
        var popUpData:MarshalPopUpData = findHighestRemoteModalPopupInfo();
        if (!popUpData || popUpData.owner || popUpData.parent)
            throw new Error();              // not popUpData for a modal window
                    
        popUpManager.hideModalWindow(popUpData, request.data.remove);
        
        // handle removing popup window 
        if (request.data.remove)
        {
            popUpManager.popupInfo.splice(popUpManager.popupInfo.indexOf(popUpData), 1);
			var awm:IActiveWindowManager = 
				IActiveWindowManager(sm.getImplementation("mx.managers::IActiveWindowManager"));
            awm.numModalWindows--;
        }
    }

    private function popUpRemovedHandler(event:DynamicEvent):void
    {

		var o:PopUpData = event.popUpData;
		var popUp:IFlexDisplayObject = o.owner as IFlexDisplayObject;
		var sm:ISystemManager = o.systemManager;
		var mp:IMarshalSystemManager = 
			IMarshalSystemManager(sm.getImplementation("mx.managers::IMarshalSystemManager"));

		// remove the focus manager from a bridged system manager, if any                
		if (sm is SystemManagerProxy)
		{

			var parentBridge:IEventDispatcher = mp.swfBridgeGroup.parentBridge;
			var request:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.REMOVE_POP_UP_REQUEST, false, false,
  					                            parentBridge,
        										{ window: DisplayObject(sm),
        										  parent:	o.parent,
        										  modal: o.modalWindow != null});
			sm.getSandboxRoot().dispatchEvent(request);
		}
		else if (mp.useSWFBridge())
		{
			// Must be locally hosted popup.
			// We need to remove the placeholder at the top level root
			request = new SWFBridgeRequest(SWFBridgeRequest.REMOVE_POP_UP_PLACE_HOLDER_REQUEST, false, false, null,
															{ window: DisplayObject(popUp)});
			request.requestor = mp.swfBridgeGroup.parentBridge;
			request.data.placeHolderId = NameUtil.displayObjectToString(DisplayObject(popUp));
			sm.dispatchEvent(request);
		}                    
	}

    public function addMouseOutEventListenersHandler(event:DynamicEvent):void
	{
		var o:MarshalPopUpData = event.popUpData;
		var sbRoot:DisplayObject = o.systemManager.getSandboxRoot();

        sbRoot.addEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE,  o.marshalMouseOutsideHandler);
        sbRoot.addEventListener(SandboxMouseEvent.MOUSE_WHEEL_SOMEWHERE, o.marshalMouseOutsideHandler, true);
	}

    public function removeMouseOutEventListenersHandler(event:DynamicEvent):void
	{
		var o:MarshalPopUpData = event.popUpData;
		var sbRoot:DisplayObject = o.systemManager.getSandboxRoot();

        sbRoot.removeEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE,  o.marshalMouseOutsideHandler);
        sbRoot.removeEventListener(SandboxMouseEvent.MOUSE_WHEEL_SOMEWHERE, o.marshalMouseOutsideHandler, true);
	}

    /**
     *  @private
     *  Returns the PopUpData for the highest remote modal window on display.
     */
    private function findHighestRemoteModalPopupInfo():MarshalPopUpData
    {
        const n:int = popUpManager.popupInfo.length - 1;
        for (var i:int = n; i >= 0; i--)
        {
            var o:MarshalPopUpData = popUpManager.popupInfo[i];
            if (o.isRemoteModalWindow)
                return o;
        }
        return null;
    }

}

}
