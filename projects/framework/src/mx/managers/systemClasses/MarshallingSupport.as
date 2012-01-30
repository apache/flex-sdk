////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.managers.systemClasses
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.utils.Dictionary;

import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.events.FlexChangeEvent;
import mx.events.EventListenerRequest;
import mx.events.InterManagerRequest;
import mx.events.InvalidateRequestData;
import mx.events.Request;
import mx.events.SandboxMouseEvent;
import mx.events.SWFBridgeEvent;
import mx.events.SWFBridgeRequest;
import mx.core.EventPriority;
import mx.core.IChildList;
import mx.core.IFlexDisplayObject;
import mx.core.IFlexModuleFactory;
import mx.core.IRawChildrenContainer;
import mx.core.ISWFBridgeGroup;
import mx.core.ISWFBridgeProvider;
import mx.core.ISWFLoader;
import mx.core.IUIComponent;
import mx.core.mx_internal;
import mx.core.Singleton;
import mx.core.SWFBridgeGroup;
import mx.managers.IFocusManager;
import mx.managers.IFocusManagerContainer;
import mx.managers.IMarshalSystemManager;
import mx.managers.PopUpManagerChildList;
import mx.managers.ISystemManager;
import mx.managers.ISystemManagerChildManager;
import mx.managers.SystemManagerGlobals;
import mx.managers.SystemManagerProxy;
import mx.managers.marshalClasses.CursorManagerMarshalMixin;
import mx.managers.marshalClasses.DragManagerMarshalMixin;
import mx.managers.marshalClasses.FocusManagerMarshalMixin;
import mx.managers.marshalClasses.PopUpManagerMarshalMixin;
import mx.managers.marshalClasses.ToolTipManagerMarshalMixin;
import mx.utils.EventUtil;
import mx.utils.NameUtil;
import mx.utils.SecurityUtil;

use namespace mx_internal;

[ExcludeClass]
[Mixin]

public class MarshallingSupport implements IMarshalSystemManager, ISWFBridgeProvider
{
    include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class Method
	//
	//--------------------------------------------------------------------------
	
	public static function init(fbs:IFlexModuleFactory):void
	{
		Singleton.registerClass("mx.managers::IMarshalSystemManager", MarshallingSupport);
	}

    /**
     *  @private
     */
    private static function weakDependency():void { CursorManagerMarshalMixin};

    /**
     *  @private
     */
    private static function weakDependency2():void { DragManagerMarshalMixin };

    /**
     *  @private
     */
    private static function weakDependency3():void { FocusManagerMarshalMixin };

    /**
     *  @private
     */
    private static function weakDependency4():void { PopUpManagerMarshalMixin };

    /**
     *  @private
     */
    private static function weakDependency5():void { ToolTipManagerMarshalMixin };



	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 *
	 *  <p>This is the starting point for all Flex applications.
	 *  This class is set to be the root class of a Flex SWF file.
         *  Flash Player instantiates an instance of this class,
	 *  causing this constructor to be called.</p>
	 */
	public function MarshallingSupport(systemManager:ISystemManager = null)
	{
		super();

        if (!systemManager)
            return;

		this.systemManager = systemManager;

        systemManager.addEventListener("invalidateParentSizeAndDisplayList", invalidateParentSizeAndDisplayListHandler);

		systemManager.addEventListener("addEventListener", addEventListenerHandler);
		systemManager.addEventListener("removeEventListener", removeEventListenerHandler);
		systemManager.addEventListener("getVisibleApplicationRect", getVisibleApplicationRectHandler);
		systemManager.addEventListener("deployMouseShields", deployMouseShieldsHandler);
		systemManager.addEventListener("getScreen", Stage_resizeHandler);
		var awm:ActiveWindowManager = 
			ActiveWindowManager(systemManager.getImplementation("mx.managers::IActiveWindowManager"));
		awm.addEventListener("removeFocusManager", removeFocusManagerHandler);
		awm.addEventListener("activateForm", activateFormHandler);
		awm.addEventListener("activatedForm", activatedFormHandler);
		awm.addEventListener("deactivateForm", deactivateFormHandler);
		awm.addEventListener("deactivatedForm", deactivatedFormHandler);
		awm.addEventListener("canActivateForm", canActivateFormHandler);
		awm.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);


		childManager = 
			ISystemManagerChildManager(systemManager.getImplementation("mx.managers::ISystemManagerChildManager"));

		if (useSWFBridge())
		{
			// create a bridge so we can talk to our parent.
			swfBridgeGroup = new SWFBridgeGroup(systemManager);
			swfBridgeGroup.parentBridge = DisplayObject(systemManager).loaderInfo.sharedEvents;
			addParentBridgeListeners();

			// send message to parent that we are ready.
			// pass up the sandbox bridge to the parent so its knows who we are.
			var bridgeEvent:SWFBridgeEvent = new SWFBridgeEvent(SWFBridgeEvent.BRIDGE_NEW_APPLICATION);
			bridgeEvent.data = swfBridgeGroup.parentBridge;
			
			swfBridgeGroup.parentBridge.dispatchEvent(bridgeEvent);

			// placeholder popups are started locally
			addEventListener(SWFBridgeRequest.ADD_POP_UP_PLACE_HOLDER_REQUEST, addPlaceholderPopupRequestHandler);

			DisplayObject(systemManager).root.loaderInfo.addEventListener(Event.UNLOAD, unloadHandler, false, 0, true);
		}

        var sbRoot:DisplayObject = systemManager.getSandboxRoot();
		// every SM has to have this listener in case it is the SM for some child AD that contains a manager
		// and the parent ADs don't have that manager.
		sbRoot.addEventListener(InterManagerRequest.INIT_MANAGER_REQUEST, initManagerHandler, false, 0, true);
		// once managers get initialized, they bounce things off the sandbox root
		if (sbRoot == systemManager)
		{
			sbRoot.addEventListener(InterManagerRequest.SYSTEM_MANAGER_REQUEST, systemManagerHandler);
			sbRoot.addEventListener(InterManagerRequest.DRAG_MANAGER_REQUEST, multiWindowRedispatcher);
			// listened for w/o use of constants because of dependency issues
			//addEventListener(InterDragManagerEvent.DISPATCH_DRAG_EVENT, multiWindowRedispatcher);
			sbRoot.addEventListener("dispatchDragEvent", multiWindowRedispatcher);

            sbRoot.addEventListener(SWFBridgeRequest.ADD_POP_UP_REQUEST, addPopupRequestHandler);
            sbRoot.addEventListener(SWFBridgeRequest.REMOVE_POP_UP_REQUEST, removePopupRequestHandler);
			sbRoot.addEventListener(SWFBridgeRequest.ADD_POP_UP_PLACE_HOLDER_REQUEST, addPlaceholderPopupRequestHandler);
			sbRoot.addEventListener(SWFBridgeRequest.REMOVE_POP_UP_PLACE_HOLDER_REQUEST, removePlaceholderPopupRequestHandler);
			sbRoot.addEventListener(SWFBridgeEvent.BRIDGE_WINDOW_ACTIVATE, activateFormSandboxEventHandler);
			sbRoot.addEventListener(SWFBridgeEvent.BRIDGE_WINDOW_DEACTIVATE, deactivateFormSandboxEventHandler); 
			sbRoot.addEventListener(SWFBridgeRequest.HIDE_MOUSE_CURSOR_REQUEST, hideMouseCursorRequestHandler);
			sbRoot.addEventListener(SWFBridgeRequest.SHOW_MOUSE_CURSOR_REQUEST, showMouseCursorRequestHandler);
			sbRoot.addEventListener(SWFBridgeRequest.RESET_MOUSE_CURSOR_REQUEST, resetMouseCursorRequestHandler);
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private var systemManager:ISystemManager;

	/**
	 *  @private
	 */
	private var childManager:ISystemManagerChildManager;


	//----------------------------------
    //  bridgeToFocusManager
    //----------------------------------
    
    /** 
     *  @private
     *  Map a bridge to a FocusManager. 
     *  This dictionary contains both the focus managers for this document as 
     *  well as focus managers that are in documents contained inside of pop 
     *  ups, if the system manager in that pop up requires a bridge to 
     *  communicate with this system manager. 
     *  
     *  The returned object is an object of type IFocusManager.
     */
    private var _bridgeToFocusManager:Dictionary;

    /** 
     *   @private
     *  
     *   System Managers in child application domains use their parent's
     *   bridgeToFocusManager's Dictionary. The swfBridgeGroup property
     *   is maintained in the same way.
     */
    mx_internal function get bridgeToFocusManager():Dictionary
    {
        if (Object(systemManager).topLevel)
            return _bridgeToFocusManager;
        else if (systemManager.topLevelSystemManager)
        {
            var topMP:MarshallingSupport = MarshallingSupport(systemManager.topLevelSystemManager.
                        getImplementation("mx.managers::IMarshalSystemManager"));
            return topMP.bridgeToFocusManager;
        }
        return null;
    }
    
    mx_internal function set bridgeToFocusManager(bridgeToFMDictionary:Dictionary):void
    {
        if (Object(systemManager).topLevel)
            _bridgeToFocusManager = bridgeToFMDictionary;
        else if (systemManager.topLevelSystemManager)
        {
            var topMP:MarshallingSupport = MarshallingSupport(systemManager.topLevelSystemManager.
                        getImplementation("mx.managers::IMarshalSystemManager"));
            topMP.bridgeToFocusManager = bridgeToFMDictionary;
        }
    }

    //--------------------------------------------------------------------------
	//  swf bridge group
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 * 
	 * Represents the related parent and child sandboxs this SystemManager may 
	 * communicate with.
	 */
	private var _swfBridgeGroup:ISWFBridgeGroup;
	
	
	public function get swfBridgeGroup():ISWFBridgeGroup
	{
		if (systemManager.isTopLevel())
			return _swfBridgeGroup;
		else if (systemManager.topLevelSystemManager)
		{
			var mp:IMarshalSystemManager = 
				IMarshalSystemManager(systemManager.topLevelSystemManager.getImplementation("mx.managers::IMarshalSystemManager"));
			return mp.swfBridgeGroup;
		}	
		return null;
	}
	
	public function set swfBridgeGroup(bridgeGroup:ISWFBridgeGroup):void
	{
		if (systemManager.isTopLevel())
			_swfBridgeGroup = bridgeGroup;
		else if (systemManager.topLevelSystemManager)
		{
			var mp:IMarshalSystemManager = 
				IMarshalSystemManager(systemManager.topLevelSystemManager.getImplementation("mx.managers::IMarshalSystemManager"));
			mp.swfBridgeGroup = bridgeGroup;
		}					
	}
	

    //--------------------------------------------------------------------------
    //
    //  Properties: ISWFBridgeProvider
    //
    //--------------------------------------------------------------------------

    /**
     * @inheritDoc
     */    
    public function get swfBridge():IEventDispatcher
    {
        if (swfBridgeGroup)
            return swfBridgeGroup.parentBridge;
            
        return null;
    }
    
    /**
     * @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */    
    public function get childAllowsParent():Boolean
    {
        try
        {
            return DisplayObject(systemManager).loaderInfo.childAllowsParent;
        }
        catch (error:Error)
        {
            //Error #2099: The loading object is not sufficiently loaded to provide this information.
        }
        
        return false;   // assume the worst
    }

    /**
     * @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */    
    public function get parentAllowsChild():Boolean
    {
        try
        {
            return DisplayObject(systemManager).loaderInfo.parentAllowsChild;
        }
        catch (error:Error)
        {
            //Error #2099: The loading object is not sufficiently loaded to provide this information.
        }
        
        return false;   // assume the worst
    }

	/**
	 * @private
	 * 
	 * Used to locate untrusted forms. Maps string ids to Objects.
	 * The object make be the SystemManagerProxy of a form or it may be
	 * the bridge to the child application where the object lives.
	 */
	private var idToPlaceholder:Object;
	
	private var eventProxy:EventProxy;
    
    private var eventProxyRefCounts:Object = {};

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: EventDispatcher
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Only create idle events if someone is listening.
	 */
	public function addEventListener(type:String, listener:Function,
											  useCapture:Boolean = false,
											  priority:int = 0,
											  useWeakReference:Boolean = false):Boolean
	{
		if (hasSWFBridges() || SystemManagerGlobals.topLevelSystemManagers.length > 1)
		{
			if (!eventProxy)
			{
				eventProxy = new EventProxy(systemManager);
			}

			var actualType:String = EventUtil.sandboxMouseEventMap[type];
			if (actualType)
			{
				if (systemManager.isTopLevelRoot())
				{
				    systemManager.stage.addEventListener(MouseEvent.MOUSE_MOVE, resetMouseCursorTracking, true, EventPriority.CURSOR_MANAGEMENT + 1, true);
					addEventListenerToSandboxes(SandboxMouseEvent.MOUSE_MOVE_SOMEWHERE, resetMouseCursorTracking, true, EventPriority.CURSOR_MANAGEMENT + 1, true);
				}
				else
				{
                    Object(systemManager).$addEventListener(MouseEvent.MOUSE_MOVE, resetMouseCursorTracking, true, EventPriority.CURSOR_MANAGEMENT + 1, true);
				}
				
				addEventListenerToSandboxes(type, sandboxMouseListener, useCapture, priority, useWeakReference);
				if (!SystemManagerGlobals.changingListenersInOtherSystemManagers)
					addEventListenerToOtherSystemManagers(type, otherSystemManagerMouseListener, useCapture, priority, useWeakReference)
				if (systemManager.getSandboxRoot() == systemManager)
                {
                    if (eventProxyRefCounts[actualType] == null)
                        eventProxyRefCounts[actualType] = 1;                        
                    else
                        eventProxyRefCounts[actualType] ++;
                    Object(systemManager).$addEventListener(actualType, eventProxy.marshalListener,
                            useCapture, priority, useWeakReference);
                    if (actualType == MouseEvent.MOUSE_UP)
                    {
                        try
                        {
                            if (systemManager.stage)
                                systemManager.stage.addEventListener(Event.MOUSE_LEAVE, eventProxy.marshalListener,
                                    useCapture, priority, useWeakReference);
                            else
                                Object(systemManager).$addEventListener(Event.MOUSE_LEAVE, eventProxy.marshalListener,
                                    useCapture, priority, useWeakReference);
                        }
                        catch (e:SecurityError)
                        {
                            Object(systemManager).$addEventListener(Event.MOUSE_LEAVE, eventProxy.marshalListener,
                                useCapture, priority, useWeakReference);
                        }
                    }
                }
				
				// Set useCapture to false because we will never see an event 
				// marshalled in the capture phase.
                Object(systemManager).$addEventListener(type, listener, false, priority, useWeakReference);
                return false;
			}
		}
        return true;
	}

	/**
	 *  @private
	 * 
	 * Test if this system manager has any sandbox bridges.
	 * 
	 * @return true if there are sandbox bridges, false otherwise.
	 */
	private function hasSWFBridges():Boolean
	{
		return swfBridgeGroup != null;
	}
	
	/**
	 *  @private
	 */
	public function removeEventListener(type:String, listener:Function,
												 useCapture:Boolean = false):Boolean
	{
        if (hasSWFBridges() || SystemManagerGlobals.topLevelSystemManagers.length > 1)
		{
			var actualType:String = EventUtil.sandboxMouseEventMap[type];
			if (actualType)
			{
                if (systemManager.getSandboxRoot() == systemManager && eventProxy)
                {
                    if (eventProxyRefCounts[actualType] != null)
                        eventProxyRefCounts[actualType] --;
                    if (eventProxyRefCounts[actualType] == null || eventProxyRefCounts[actualType] == 0)
                    {
                        delete eventProxyRefCounts[actualType];                        
                        Object(systemManager).$removeEventListener(actualType, eventProxy.marshalListener,
                                useCapture);
                        if (actualType == MouseEvent.MOUSE_UP)
                        {
                            try
                            {
                                if (systemManager.stage)
                                    systemManager.stage.removeEventListener(Event.MOUSE_LEAVE, eventProxy.marshalListener,
                                        useCapture);
                            }
                            catch (e:SecurityError)
                            {
                            }
    			            // Remove both listeners in case the system manager was added
    			            // or removed from the stage after the listener was added.
                            Object(systemManager).$removeEventListener(Event.MOUSE_LEAVE, eventProxy.marshalListener,
                                useCapture);
                        }
                    }
                    else
                        return false; // if we didn't actually remove, don't remove on the following lines either
                }
				if (!SystemManagerGlobals.changingListenersInOtherSystemManagers)
					removeEventListenerFromOtherSystemManagers(type, otherSystemManagerMouseListener, useCapture);
				removeEventListenerFromSandboxes(type, sandboxMouseListener, useCapture);
                Object(systemManager).$removeEventListener(type, listener, false);
				return false;
			}
		}
        return true;
	}



	//--------------------------------------------------------------------------
	//
	//  Methods: Focus
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * 
	 * New version of activate that does not require a
	 * IFocusManagerContainer.
	 */
    private function activateFormHandler(event:DynamicEvent):void
	{
		var awm:ActiveWindowManager = 
			ActiveWindowManager(systemManager.getImplementation("mx.managers::IActiveWindowManager"));
		// trace("SM: activate " + f + " " + forms.length);

		if (awm.form)
		{
			if (awm.form != event.form && awm.forms.length > 1)
			{
				// Switch the active form.
				if (isRemotePopUp(awm.form))
				{
					if (!areRemotePopUpsEqual(awm.form, event.form))
						deactivateRemotePopUp(awm.form);
                    event.preventDefault();
				}
		    }
	    }
    }

    private function activatedFormHandler(event:DynamicEvent):void
    {
		
		// trace("f = " + f);
		if (isRemotePopUp(event.form))
		{
			activateRemotePopUp(event.form);
            event.preventDefault();
		}
	}

	/**
	 * @private
	 * 
	 * New version of deactivate that works with remote pop ups.
	 * 
	 */
    private function deactivateFormHandler(event:DynamicEvent):void
	{
		var awm:ActiveWindowManager = 
			ActiveWindowManager(systemManager.getImplementation("mx.managers::IActiveWindowManager"));

		// trace(">>SM: deactivate " + f);

		if (awm.form)
		{
			// If there's more than one form and this is it, find a new form.
			if (awm.form == event.form && awm.forms.length > 1)
			{
				if (isRemotePopUp(awm.form))
                {
					deactivateRemotePopUp(awm.form);
                    event.preventDefault();
                }
            }
        }
    }

    private function deactivatedFormHandler(event:DynamicEvent):void
    {
		if (isRemotePopUp(event.form))
        {
			activateRemotePopUp(event.form);					
            event.preventDefault();
        }
		// trace("<<SM: deactivate " + f);
	}


	/**
	 * @private
	 * 
	 * @return true if the form can be activated, false otherwise.
	 */
    private function canActivateFormHandler(request:Request):void
	 {
	 	if (isRemotePopUp(request.value))
	 	{
	 		var remotePopUp:RemotePopUp = RemotePopUp(request.value);
			var event:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.CAN_ACTIVATE_POP_UP_REQUEST, 
																  false, false, null,
																  remotePopUp.window);
			IEventDispatcher(remotePopUp.bridge).dispatchEvent(event);
			request.value = event.data;
            request.preventDefault();
	 	}
	 }
	 
	 
	/**
	 * @private
	 * 
	 * @return true if the form is a RemotePopUp, false if the form is IFocusManagerContainer.
	 *
	 */
	private static function isRemotePopUp(form:Object):Boolean
	{
		return !(form is IFocusManagerContainer);
	}

	/**
	 * @private
	 * 
	 * @return true if form1 and form2 are both of type RemotePopUp and are equal, false otherwise.
	 */
	private static function areRemotePopUpsEqual(form1:Object, form2:Object):Boolean
	{
		if (!(form1 is RemotePopUp))
			return false;
		
		if (!(form2 is RemotePopUp))
			return false;
		
		var remotePopUp1:RemotePopUp = RemotePopUp(form1);
		var remotePopUp2:RemotePopUp = RemotePopUp(form2);
		
		if (remotePopUp1.window == remotePopUp2.window && 
		    remotePopUp1.bridge && remotePopUp2.bridge)
			return true;
		
		return false;
	}


	/**
	 * @private
	 * 
	 * Find a remote form that is hosted by this system manager.
	 * 
	 * @param window unique id of popUp within a bridged application
	 * @param bridge bridge of owning application.
	 * 
	 * @return RemotePopUp if hosted by this system manager, false otherwise.
	 */
	private function findRemotePopUp(window:Object, bridge:IEventDispatcher):RemotePopUp
	{
		var awm:ActiveWindowManager = 
			ActiveWindowManager(systemManager.getImplementation("mx.managers::IActiveWindowManager"));

        // remove the placeholder from forms array
		var n:int = awm.forms.length;
		for (var i:int = 0; i < n; i++)
		{
			if (isRemotePopUp(awm.forms[i]))
			{
				var popUp:RemotePopUp = RemotePopUp(awm.forms[i]);
				if (popUp.window == window && 
				    popUp.bridge == bridge)
				    return popUp;
			}
		}
		
		return null;
	}
	
	/**
	 * Remote a remote form from the forms array.
	 * 
	 * form Locally created remote form.
	 */
	private function removeRemotePopUp(form:RemotePopUp):void
	{
		var awm:ActiveWindowManager = 
			ActiveWindowManager(systemManager.getImplementation("mx.managers::IActiveWindowManager"));

	    // remove popup from forms array
		var n:int = awm.forms.length;
		for (var i:int = 0; i < n; i++)
		{
			if (isRemotePopUp(awm.forms[i]))
			{
				if (awm.forms[i].window == form.window &&
				    awm.forms[i].bridge == form.bridge)
						{
					if (awm.forms[i] == form)
						awm.deactivate(IFocusManagerContainer(form));
					awm.forms.splice(i, 1);
					break;
				}
			}
		}
	}

	/**
	 * @private
	 * 
	 * Activate a form that belongs to a system manager in another
	 * sandbox or peer application domain.
	 * 
	 * @param form	a RemotePopUp object.
	 * */ 
	private function activateRemotePopUp(form:Object):void
	{
		var request:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.ACTIVATE_POP_UP_REQUEST, 
																	false, false,
																	form.bridge,
																	form.window);
		var bridge:Object = form.bridge;
		if (bridge)
			bridge.dispatchEvent(request);
	}
	
	
	private function deactivateRemotePopUp(form:Object):void
	{
		var request:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.DEACTIVATE_POP_UP_REQUEST,
																	false, false,
																	form.bridge,
																	form.window);
		var bridge:Object = form.bridge;
		if (bridge)
			bridge.dispatchEvent(request);
				}

	/**
	 * Test if two forms are equal.
	 * 
	 * @param form1 - may be of type a DisplayObjectContainer or a RemotePopUp
	 * @param form2 - may be of type a DisplayObjectContainer or a RemotePopUp
	 * 
	 * @return true if the forms are equal, false otherwise.
	 */
	private function areFormsEqual(form1:Object, form2:Object):Boolean
	{
		if (form1 == form2)
			return true;
			
		// if the forms are both remote forms, then compare them, otherwise
		// return false.
		if (form1 is RemotePopUp && form2 is RemotePopUp)
		{
			return areRemotePopUpsEqual(form1, form2);	
		}

		return false;
	}

	/**
	 *  @inheritDoc
	 */
	public function addFocusManager(f:IFocusManagerContainer):void
	{
		// trace("OLW: add focus manager" + f);
		var awm:ActiveWindowManager = 
			ActiveWindowManager(systemManager.getImplementation("mx.managers::IActiveWindowManager"));

		awm.forms.push(f);

		// trace("END OLW: add focus manager" + f);
	}

	/**
	 *  @inheritDoc
	 */
    public function removeFocusManagerHandler(event:FocusEvent):void
	{
		dispatchDeactivatedWindowEvent(DisplayObject(event.relatedObject));
	}

	//--------------------------------------------------------------------------
	//
	//  Methods: Other
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
     *  
     *  Dispatch an invalidate request to invalidate the size and
     *  display list of the parent application.
     */     
    private function dispatchInvalidateRequest():void
    {
        var bridge:IEventDispatcher = swfBridgeGroup.parentBridge;
        var request:SWFBridgeRequest = new SWFBridgeRequest(
                                                    SWFBridgeRequest.INVALIDATE_REQUEST,
                                                    false, false,
                                                    bridge,
                                                    InvalidateRequestData.SIZE |
                                                    InvalidateRequestData.DISPLAY_LIST);
         bridge.dispatchEvent(request);
    }
    
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------


	/**
	 *  @private
	 *  Track mouse clicks to see if we change top-level forms.
     *  Note that we get a FocusEvent here and not a MouseEvent because we
     *  use a FocusEvent to forward the MouseEvent to the mixin.  That's
     *  why we use event.relatedObject here and not MouseEvent
	 */
	private function mouseDownHandler(event:FocusEvent):void
	{
		var awm:ActiveWindowManager = 
			ActiveWindowManager(systemManager.getImplementation("mx.managers::IActiveWindowManager"));

           event.preventDefault();
		// trace("SM:mouseDownHandler " + this);
		
		// If an object was clicked that is inside another system manager 
		// in a bridged application, activate the current document because
		// the bridge application is considered part of the main application.
		// We also see mouse clicks on dialogs popped up from compatible applications.
        var bridge:IEventDispatcher = getSWFBridgeOfDisplayObject(event.relatedObject as DisplayObject);
        if (bridge && bridgeToFocusManager[bridge] == systemManager.document.focusManager)
		{
			// trace("SM:mouseDownHandler click in a bridged application");
			if (systemManager.isTopLevelRoot())
				awm.activate(IFocusManagerContainer(systemManager.document));
			else
				dispatchActivatedApplicationEvent();

			return;
		} 
		
		if (awm.numModalWindows == 0) // no modal windows are up
		{
			if (!systemManager.isTopLevelRoot() || awm.forms.length > 1)
			{
				var n:int = awm.forms.length;
				var p:DisplayObject = DisplayObject(event.relatedObject);
                var isApplication:Boolean = systemManager.document is IRawChildrenContainer ? 
                                            IRawChildrenContainer(systemManager.document).rawChildren.contains(p) :
                                            systemManager.document.contains(p);
				while (p)
				{
					for (var i:int = 0; i < n; i++)
					{
						var form_i:Object = isRemotePopUp(awm.forms[i]) ? awm.forms[i].window : awm.forms[i];
						if (form_i == p)
						{
							var j:int = 0;
							var index:int;
							var newIndex:int;
							var childList:IChildList;

							if (((p != awm.form) && p is IFocusManagerContainer) ||
							    (!systemManager.isTopLevelRoot() && p == awm.form))
							{
								if (systemManager.isTopLevelRoot())
								    awm.activate(IFocusManagerContainer(p));

								if (p == systemManager.document)
									dispatchActivatedApplicationEvent();
								else if (p is DisplayObject)
									dispatchActivatedWindowEvent(DisplayObject(p));
							}
							
							if (systemManager.popUpChildren.contains(p))
								childList = systemManager.popUpChildren;
							else
								childList = systemManager;

							index = childList.getChildIndex(p); 
							newIndex = index;
							
							//we need to reset n because activating p's 
							//FocusManager could have caused 
							//forms.length to have changed. 
							n = awm.forms.length;
							for (j = 0; j < n; j++)
							{
								var f:DisplayObject;
								var isRemotePopUp:Boolean = isRemotePopUp(awm.forms[j]);
								if (isRemotePopUp)
								{
									if (awm.forms[j].window is String)
										continue;
									f = awm.forms[j].window;
								}
								else 
									f = awm.forms[j];
								if (isRemotePopUp)
								{
									var fChildIndex:int = getChildListIndex(childList, f);
									if (fChildIndex > index)
										newIndex = Math.max(fChildIndex, newIndex);	
								}
								else if (childList.contains(f))
									if (childList.getChildIndex(f) > index)
										newIndex = Math.max(childList.getChildIndex(f), newIndex);
							}
							if (newIndex > index && !isApplication)
								childList.setChildIndex(p, newIndex);

							return;
						}
					}
					p = p.parent;
				}
			}
			else 
				dispatchActivatedApplicationEvent();
		}
	}

	/**
	 * @private
	 * 
	 * Get the index of an object in a given child list.
	 * 
	 * @return index of f in childList, -1 if f is not in childList.
	 */ 
	private static function getChildListIndex(childList:IChildList, f:Object):int
	{
		var index:int = -1;
		try
		{
			index = childList.getChildIndex(DisplayObject(f)); 
		}
		catch (e:ArgumentError)
		{
			// index has been preset to -1 so just continue.	
		}
		
		return index; 
	}

	/**
	 * @private
	 * 
	 * Handle request to unload
	 * Forward event, and do some cleanup
	 */
	private function beforeUnloadHandler(event:Event):void
	{
        if (systemManager.isTopLevel() && systemManager.stage)
        {
            var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
            if (sandboxRoot != DisplayObject(systemManager))
                sandboxRoot.removeEventListener(Event.RESIZE, Stage_resizeHandler);
        }
        
		removeParentBridgeListeners();
		systemManager.dispatchEvent(event);
	}

	//--------------------------------------------------------------------------
	//
	//  Sandbox Event handlers for messages from children
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * 
	 * Add a popup request handler for domain local request and 
	 * remote domain requests.
	 */
	private function addPopupRequestHandler(event:Event):void
	{
		if (event.target != systemManager && event is SWFBridgeRequest)
			return;

		var awm:ActiveWindowManager = 
			ActiveWindowManager(systemManager.getImplementation("mx.managers::IActiveWindowManager"));

		var popUpRequest:SWFBridgeRequest = SWFBridgeRequest.marshal(event);

		// If there is not for mutual trust between us an the child that wants the 
		// popup, then don't host the pop up.
		if (event.target != systemManager)
		{
    		var bridgeProvider:ISWFBridgeProvider = swfBridgeGroup.getChildBridgeProvider(
    		                                        IEventDispatcher(event.target));
		if (!SecurityUtil.hasMutualTrustBetweenParentAndChild(bridgeProvider))
		{
			return;
		}
		}
					
		var topMost:Boolean;

		// Need to have mutual trust between two application in order
		// for an application to host another application's popup.
		if (swfBridgeGroup.parentBridge &&
		    SecurityUtil.hasMutualTrustBetweenParentAndChild(this))
		{
			// ask the parent to host the popup
			popUpRequest.requestor = swfBridgeGroup.parentBridge;
			systemManager.getSandboxRoot().dispatchEvent(popUpRequest);
			return;
		}
		
		// add popup as a child of this system manager
        if (!popUpRequest.data.childList || popUpRequest.data.childList == PopUpManagerChildList.PARENT)
            topMost = popUpRequest.data.parent && systemManager.popUpChildren.contains(popUpRequest.data.parent);
        else
            topMost = (popUpRequest.data.childList == PopUpManagerChildList.POPUP);

        var children:IChildList;
        children = topMost ? systemManager.popUpChildren : systemManager;
        children.addChild(DisplayObject(popUpRequest.data.window));
        
        if (popUpRequest.data.modal)    
	        awm.numModalWindows++;
        
		// add popup to the list of managed forms
		var remoteForm:RemotePopUp = new RemotePopUp(popUpRequest.data.window, popUpRequest.requestor);
		awm.forms.push(remoteForm);
		
		if (!systemManager.isTopLevelRoot() && swfBridgeGroup)
		{
			// We've added the popup as far as it can go.
			// Add a placeholder to the top level root application
			var request:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.ADD_POP_UP_PLACE_HOLDER_REQUEST, 
			                                     false, false, 
			                                     popUpRequest.requestor,
														{ window: popUpRequest.data.window });
			request.data.placeHolderId = NameUtil.displayObjectToString(DisplayObject(popUpRequest.data.window));
			systemManager.dispatchEvent(request);
		}
	}
	
	/**
	 * @private
	 * 
	 * Message from a child system manager to 
	 * remove the popup that was added by using the
	 * addPopupRequestHandler.
	 */
	private function removePopupRequestHandler(event:Event):void
	{
		var awm:ActiveWindowManager = 
			ActiveWindowManager(systemManager.getImplementation("mx.managers::IActiveWindowManager"));

		var popUpRequest:SWFBridgeRequest = SWFBridgeRequest.marshal(event);

		if (swfBridgeGroup.parentBridge &&
		    SecurityUtil.hasMutualTrustBetweenParentAndChild(this))
		{
			// since there is mutual trust the popup is hosted by the parent.
            popUpRequest.requestor = swfBridgeGroup.parentBridge;
			systemManager.getSandboxRoot().dispatchEvent(popUpRequest);
			return;
		}
					
        if (systemManager.popUpChildren.contains(popUpRequest.data.window))
            systemManager.popUpChildren.removeChild(popUpRequest.data.window);
        else
            systemManager.removeChild(DisplayObject(popUpRequest.data.window));
        
        if (popUpRequest.data.modal)    
			awm.numModalWindows--;

		removeRemotePopUp(new RemotePopUp(popUpRequest.data.window, popUpRequest.requestor));
		
		if (!systemManager.isTopLevelRoot() && swfBridgeGroup)
		{
			// if we got here we know the parent is untrusted, so remove placeholders
			var request:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.REMOVE_POP_UP_PLACE_HOLDER_REQUEST, 
	                                            false, false, 
	                                            popUpRequest.requestor,
	                                            {placeHolderId: NameUtil.displayObjectToString(popUpRequest.data.window)
	                                            });
			systemManager.dispatchEvent(request);
		}
		            
	}
	
	/**
	 * @private
	 * 
	 * Handle request to add a popup placeholder.
	 * The placeholder represents an untrusted form that is hosted 
	 * elsewhere.
	 */
	 private function addPlaceholderPopupRequestHandler(event:Event):void
	 {
		var popUpRequest:SWFBridgeRequest = SWFBridgeRequest.marshal(event);

		var awm:ActiveWindowManager = 
			ActiveWindowManager(systemManager.getImplementation("mx.managers::IActiveWindowManager"));

		if (event.target != systemManager && event is SWFBridgeRequest)
			return;
	 	
		if (!forwardPlaceholderRequest(popUpRequest, true))
		{
			// Create a RemotePopUp and add it.
			var remoteForm:RemotePopUp = new RemotePopUp(popUpRequest.data.placeHolderId, popUpRequest.requestor);
			awm.forms.push(remoteForm);
		}

	 }

	/**
	 * @private
	 * 
	 * Handle request to add a popup placeholder.
	 * The placeholder represents an untrusted form that is hosted 
	 * elsewhere.
	 */
	 private function removePlaceholderPopupRequestHandler(event:Event):void
	 {
		var popUpRequest:SWFBridgeRequest = SWFBridgeRequest.marshal(event);
	 	
		var awm:ActiveWindowManager = 
			ActiveWindowManager(systemManager.getImplementation("mx.managers::IActiveWindowManager"));

		if (!forwardPlaceholderRequest(popUpRequest, false))
		{
	        // remove the placeholder from forms array
			var n:int = awm.forms.length;
			for (var i:int = 0; i < n; i++)
			{
				if (isRemotePopUp(awm.forms[i]))
				{
					if (awm.forms[i].window == popUpRequest.data.placeHolderId &&
					    awm.forms[i].bridge == popUpRequest.requestor)
					{
						awm.forms.splice(i, 1);
						break;
					}
				}
			}
		}			 	
		
	 }

	/**
	 * Forward a form event update the parent chain. 
	 * Takes care of removing object references and substituting
	 * ids when an untrusted boundry is crossed.
	 */
	private function forwardFormEvent(event:SWFBridgeEvent):Boolean
	{
		
		if (systemManager.isTopLevelRoot())
			return false;			
			
		var bridge:IEventDispatcher = swfBridgeGroup.parentBridge; 
		if (bridge)
		{
			var sbRoot:DisplayObject = systemManager.getSandboxRoot();
			event.data.notifier = bridge;
			if (sbRoot == systemManager)
			{
				if (!(event.data.window is String))
					event.data.window = NameUtil.displayObjectToString(DisplayObject(event.data.window));
				else
					event.data.window = NameUtil.displayObjectToString(DisplayObject(systemManager)) + "." + event.data.window;
				
				bridge.dispatchEvent(event);
			}
			else
			{
				if (event.data.window is String)
					event.data.window = NameUtil.displayObjectToString(DisplayObject(systemManager)) + "." + event.data.window;
 
				sbRoot.dispatchEvent(event);
			}
		}

		return true;
	}
	
	/**
	 * Forward an AddPlaceholder request up the parent chain, if needed.
	 * 
	 * @param request request to either add or remove a pop up placeholder.
	 * @param addPlaceholder true if adding a placeholder, false it removing a placeholder.
	 * @return true if the request was forwared, false otherwise
	 */
	private function forwardPlaceholderRequest(request:SWFBridgeRequest, addPlaceholder:Boolean):Boolean
	{
	 	// Only the top level root tracks the placeholders.
	 	// If we are not the top level root then keep passing
	 	// the message up the parent chain.
	 	if (systemManager.isTopLevelRoot())
	 		return false;
	 		
		// If the window object is passed, then this is the first
		// stop on the way up the parent chain.
		var refObj:Object = null;
		var oldId:String = null;
		if (request.data.window)
		{
			refObj = request.data.window;
			
			// null this ref out so untrusted parent cannot see
			request.data.window = null;
		}
		else
		{
			refObj = request.requestor;
			
			// prefix the existing id with the id of this object
			oldId = request.data.placeHolderId;
			request.data.placeHolderId = NameUtil.displayObjectToString(DisplayObject(systemManager)) + "." + request.data.placeHolderId;
		}

		if (addPlaceholder)
			addPlaceholderId(request.data.placeHolderId, oldId, request.requestor, refObj);
		else 
			removePlaceholderId(request.data.placeHolderId);
				
		
		var sbRoot:DisplayObject = systemManager.getSandboxRoot();
		var bridge:IEventDispatcher = swfBridgeGroup.parentBridge; 
		request.requestor =  bridge;
		if (sbRoot == systemManager)
			bridge.dispatchEvent(request);
		else 
			sbRoot.dispatchEvent(request);
			
		return true;
	}

	/**
	 * One of the system managers in another sandbox deactivated and sent a message
	 * to the top level system manager. In response the top-level system manager
	 * needs to find a new form to activate.
	 */
	private function deactivateFormSandboxEventHandler(event:Event):void
	{
		// trace("bridgeDeactivateFormEventHandler");
		var awm:ActiveWindowManager = 
			ActiveWindowManager(systemManager.getImplementation("mx.managers::IActiveWindowManager"));

		if (event is SWFBridgeRequest)
			return;

		var bridgeEvent:SWFBridgeEvent = SWFBridgeEvent.marshal(event);

		if (!forwardFormEvent(bridgeEvent))
		{
			// deactivate the form
			if (isRemotePopUp(awm.form) && 
				RemotePopUp(awm.form).window == bridgeEvent.data.window &&
				RemotePopUp(awm.form).bridge == bridgeEvent.data.notifier)
				awm.deactivate(awm.form);
		}
	}
	
	
	/**
	 * A form in one of the system managers in another sandbox has been activated. 
	 * The form being activate is identified. 
	 * In response the top-level system manager needs to activate the given form
	 * and deactivate the currently active form, if any.
	 */
	private function activateFormSandboxEventHandler(event:Event):void
	{
		// trace("bridgeDeactivateFormEventHandler");
		var awm:ActiveWindowManager = 
			ActiveWindowManager(systemManager.getImplementation("mx.managers::IActiveWindowManager"));

		// trace("bridgeActivateFormEventHandler");
        var bridgeEvent:SWFBridgeEvent = SWFBridgeEvent.marshal(event);

		if (!forwardFormEvent(bridgeEvent))
			// just call activate on the remote form.
			awm.activate(new RemotePopUp(bridgeEvent.data.window, bridgeEvent.data.notifier));			
	}
		
	/**
	 * One of the system managers in another sandbox activated and sent a message
	 * to the top level system manager to deactivate this form. In response the top-level system manager
	 * needs to deactivate all other forms except the top level system manager's.
	 */
	private function activateApplicationSandboxEventHandler(event:Event):void
	{
		// trace("bridgeDeactivateFormEventHandler");
		var awm:ActiveWindowManager = 
			ActiveWindowManager(systemManager.getImplementation("mx.managers::IActiveWindowManager"));

		// trace("bridgeActivateApplicationEventHandler");
		if (!systemManager.isTopLevelRoot())
		{
			swfBridgeGroup.parentBridge.dispatchEvent(event);
			return;    	
		}

		// An application was activated, active the main document.
		awm.activate(IFocusManagerContainer(systemManager.document));
	}


    /**
     *  @private
     * 
     *  Re-dispatch events sent over the bridge to listeners on this
     *  system manager. PopUpManager is expected to listen to these
     *  events.
     */  
    private function modalWindowRequestHandler(event:Event):void
    {
        if (event is SWFBridgeRequest)
            return;
        
        var request:SWFBridgeRequest = SWFBridgeRequest.marshal(event);
            
        if (!preProcessModalWindowRequest(request, systemManager.getSandboxRoot()))
            return;
                        
        // Ensure a PopUpManager exists and dispatch the request it is
        // listening for.
        Singleton.getInstance("mx.managers::IPopUpManager");
        systemManager.dispatchEvent(request);
    }

    /**
     *  @private
     * 
     *  Calculate the visible rectangle of the requesting application in this
     *  application. Forward the request to our parent to see this the rectangle
     *  is further reduced. Continue up the parent chain until the top level
     *  root parent is reached.
     */  
    private function getVisibleRectRequestHandler(event:Event):void
    {
        if (event is SWFBridgeRequest)
            return;
        
        var request:SWFBridgeRequest = SWFBridgeRequest.marshal(event);
        var rect:Rectangle = Rectangle(request.data);
        var owner:DisplayObject = DisplayObject(swfBridgeGroup.getChildBridgeProvider(request.requestor));
        var localRect:Rectangle;
        var forwardRequest:Boolean = true;
        
        // Check if the request in a pop up. If it is then don't 
        // forward the request to our parent because we don't want
        // to reduce the visible rect of the dialog base on the
        // visible rect of applications in the main app. 
        if (!DisplayObjectContainer(systemManager.document).contains(owner))
            forwardRequest = false;    
        
        if (owner is ISWFLoader)
            localRect = ISWFLoader(owner).getVisibleApplicationRect();
        else
        {
            localRect = owner.getBounds(DisplayObject(systemManager));
            var pt:Point = DisplayObject(systemManager).localToGlobal(localRect.topLeft);
            localRect.x = pt.x;
            localRect.y = pt.y;
        }        
           
        rect = rect.intersection(localRect); // update rect
        request.data = rect;
        
        // forward request 
        if (forwardRequest && useSWFBridge())
        { 
        var bridge:IEventDispatcher = swfBridgeGroup.parentBridge;
            request.requestor = bridge;
            bridge.dispatchEvent(request);
        }
        
        Object(event).data = request.data;           // update request
    }

    /**
     *  @private
     * 
     *  Notify the topLevelRoot that we don't want the mouseCursor shown
	 *  Forward upward if necessary.
     */  
    private function hideMouseCursorRequestHandler(event:Event):void
    {
        if (!systemManager.isTopLevelRoot() && event is SWFBridgeRequest)
            return;

        var request:SWFBridgeRequest = SWFBridgeRequest.marshal(event);
        
        // forward request 
        if (!systemManager.isTopLevelRoot())
        { 
			var bridge:IEventDispatcher = swfBridgeGroup.parentBridge;
            request.requestor = bridge;
            bridge.dispatchEvent(request);
        }
		else if (eventProxy)
			SystemManagerGlobals.showMouseCursor = false;
	}
	
    /**
     *  @private
     * 
     *  Ask the topLevelRoot if anybody don't want the mouseCursor shown
	 *  Forward upward if necessary.
     */  
    private function showMouseCursorRequestHandler(event:Event):void
    {
        if (!systemManager.isTopLevelRoot() && event is SWFBridgeRequest)
            return;
        
        var request:SWFBridgeRequest = SWFBridgeRequest.marshal(event);
        
        // forward request 
        if (!systemManager.isTopLevelRoot())
        { 
			var bridge:IEventDispatcher = swfBridgeGroup.parentBridge;
            request.requestor = bridge;
            bridge.dispatchEvent(request);
	        Object(event).data = request.data;           // update request
        }
		else if (eventProxy)
	        Object(event).data = SystemManagerGlobals.showMouseCursor;
        
    }

    /**
     *  @private
     * 
     *  Ask the topLevelRoot if anybody don't want the mouseCursor shown
	 *  Forward upward if necessary.
     */  
    private function resetMouseCursorRequestHandler(event:Event):void
    {
        if (!systemManager.isTopLevelRoot() && event is SWFBridgeRequest)
            return;
        
        var request:SWFBridgeRequest = SWFBridgeRequest.marshal(event);
        
        // forward request 
        if (!systemManager.isTopLevelRoot())
        { 
			var bridge:IEventDispatcher = swfBridgeGroup.parentBridge;
            request.requestor = bridge;
            bridge.dispatchEvent(request);
        }
		else if (eventProxy)
	        SystemManagerGlobals.showMouseCursor = true;
        
    }

	private function resetMouseCursorTracking(event:Event):void
	{
		if (systemManager.isTopLevelRoot())
		{
			SystemManagerGlobals.showMouseCursor = true;
		}
		else if (swfBridgeGroup.parentBridge)
		{
			var cursorRequest:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.RESET_MOUSE_CURSOR_REQUEST);
			var bridge:IEventDispatcher = swfBridgeGroup.parentBridge;
            cursorRequest.requestor = bridge;
            bridge.dispatchEvent(cursorRequest);
		}

	}

	//--------------------------------------------------------------------------
	//
	//  Sandbox Event handlers for messages from parent
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 * 
	 * Sent by the SWFLoader to change the size of the application it loaded.
	 */
	private function setActualSizeRequestHandler(event:Event):void
	{
		var eObj:Object = Object(event);
		IFlexDisplayObject(systemManager).setActualSize(eObj.data.width, eObj.data.height);
	}
	
	/**
	 * @private
	 * 
	 * Get the size of this System Manager.
	 * Sent by a SWFLoader.
	 */
	private function getSizeRequestHandler(event:Event):void
	{
		var eObj:Object = Object(event);
		eObj.data = { width: IFlexDisplayObject(systemManager).measuredWidth, height: IFlexDisplayObject(systemManager).measuredHeight};					
	}
	
	/**
	 * @private
	 * 
	 * Handle request to activate a particular form.
	 * 
	 */
	private function activateRequestHandler(event:Event):void
	{
        var request:SWFBridgeRequest = SWFBridgeRequest.marshal(event);

		// If data is a String, then we need to parse the id to find
		// the form or the next bridge to pass the message to.
		// If the data is a SystemMangerProxy we can just activate the
		// form.
		var child:Object = request.data; 
		var nextId:String = null;
		if (request.data is String)
		{
			var placeholder:PlaceholderData = idToPlaceholder[request.data];
			child = placeholder.data;
			nextId = placeholder.id;
			
			// check if the dialog is hosted on this system manager
			if (nextId == null)
			{
				var popUp:RemotePopUp = findRemotePopUp(child, placeholder.bridge); 
				
				if (popUp)
				{
					activateRemotePopUp(popUp);
					return;
				}
			}
		}
		
		if (child is SystemManagerProxy)
		{
			// activate request from the top-level system manager.
			var smp:SystemManagerProxy = SystemManagerProxy(child);
			var f:IFocusManagerContainer = findFocusManagerContainer(smp);
			if (smp && f)
				smp.activateByProxy(f);
		}	
		else if (child is IFocusManagerContainer)
			IFocusManagerContainer(child).focusManager.activate();
		else if (child is IEventDispatcher)
		{
				request.data = nextId;
				request.requestor = IEventDispatcher(child);
				IEventDispatcher(child).dispatchEvent(request);
		}
		else 
			throw new Error();	// should never get here
	}

	/**
	 * @private
	 * 
	 * Handle request to deactivate a particular form.
	 * 
	 */
	private function deactivateRequestHandler(event:Event):void
	{
        var request:SWFBridgeRequest = SWFBridgeRequest.marshal(event);
		var child:Object = request.data; 
		var nextId:String = null;
		if (request.data is String)
		{
			var placeholder:PlaceholderData = idToPlaceholder[request.data];
			child = placeholder.data;
			nextId = placeholder.id;

			// check if the dialog is hosted on this system manager
			if (nextId == null)
			{
				var popUp:RemotePopUp = findRemotePopUp(child, placeholder.bridge); 
				
				if (popUp)
				{
					deactivateRemotePopUp(popUp);
					return;
				}
			}
		}
		
		if (child is SystemManagerProxy)
		{
			// deactivate request from the top-level system manager.
			var smp:SystemManagerProxy = SystemManagerProxy(child);
			var f:IFocusManagerContainer = findFocusManagerContainer(smp);
			if (smp && f)
				smp.deactivateByProxy(f);
		}
		else if (child is IFocusManagerContainer)
			IFocusManagerContainer(child).focusManager.deactivate();
			
		else if (child is IEventDispatcher)
		{
			request.data = nextId;
			request.requestor = IEventDispatcher(child);
			IEventDispatcher(child).dispatchEvent(request);
			return;
		}
		else
			throw new Error();		
	}

	//--------------------------------------------------------------------------
	//
	//  Sandbox Event handlers for messages from either the
	//  parent or child
	//
	//--------------------------------------------------------------------------

	/**
	 * Is the child in event.data this system manager or a child of this 
	 * system manager?
	 *
	 * Set the data property to indicate if the display object is a child
	 */
	private function isBridgeChildHandler(event:Event):void
	{
		// if we are broadcasting messages, ignore the messages
		// we send to ourselves.
		if (event is SWFBridgeRequest)
			return;

		var eObj:Object = Object(event);

		eObj.data = eObj.data && systemManager.rawChildren.contains(eObj.data as DisplayObject);
	}
	
	/**
	 * Can this form be activated. The current test is if the given pop up 
	 * is visible and is enabled. 
	 *
	 * Set the data property to indicate if can be activated
	 */
	private function canActivateHandler(event:Event):void
	{
		var eObj:Object = Object(event);

		// If data is a String, then we need to parse the id to find
		// the form or the next bridge to pass the message to.
		// If the data is a SystemMangerProxy we can just activate the
		// form.
		var request:SWFBridgeRequest;
		var child:Object = eObj.data; 
		var nextId:String = null;
		if (eObj.data is String)
		{
			var placeholder:PlaceholderData = idToPlaceholder[eObj.data];
			child = placeholder.data;
			nextId = placeholder.id;
			
			// check if the dialog is hosted on this system manager
			if (nextId == null)
			{
				var popUp:RemotePopUp = findRemotePopUp(child, placeholder.bridge); 
				
				if (popUp)
				{
					request = new SWFBridgeRequest(SWFBridgeRequest.CAN_ACTIVATE_POP_UP_REQUEST,
																false, false, 
																IEventDispatcher(popUp.bridge), 
																popUp.window);
				 	if (popUp.bridge)
				 	{
				 		popUp.bridge.dispatchEvent(request);
				 		eObj.data = request.data;
				 	}
					return;
				}
			}
		}
		
		if (child is SystemManagerProxy)
		{
			var smp:SystemManagerProxy = SystemManagerProxy(child);
			var f:IFocusManagerContainer = findFocusManagerContainer(smp);
			eObj.data = smp && f && canActivateLocalComponent(f);
		}	
		else if (child is IFocusManagerContainer)
		{
			eObj.data = canActivateLocalComponent(child);
		}
		else if (child is IEventDispatcher)
		{
			var bridge:IEventDispatcher = IEventDispatcher(child);
		    request = new SWFBridgeRequest(SWFBridgeRequest.CAN_ACTIVATE_POP_UP_REQUEST,
															false, false, 
															bridge, 
															nextId);
			
			if (bridge)
			{
				bridge.dispatchEvent(request);
				eObj.data = request.data;
			}
		}
		else 
			throw new Error();	// should never get here
	}
	

    /**
	 * @private
	 * 
	 * Test is a local component can be activated.
	 */
	 private function canActivateLocalComponent(o:Object):Boolean
	 {
	 	
	 	if (o is Sprite && o is IUIComponent &&
	 	    Sprite(o).visible && IUIComponent(o).enabled)
			return true;
			
		return false;
	 }

    /**
	 * @private
	 * 
	 * Test if a display object is in an applcation we want to communicate with over a bridge.
	 * 
	 */
	public function isDisplayObjectInABridgedApplication(displayObject:DisplayObject):Boolean
	{
        return getSWFBridgeOfDisplayObject(displayObject) != null;
    }

    /**
     *  @private
     * 
     *  If a display object is in a bridged application, then return the SWFBridge
     *  that is used to communcation with that application. Otherwise return null.
     * 
     *  @param displayObject The object to test.
     * 
     *  @return The IEventDispather that represents the SWFBridge that should 
     *  be used to communicate with this object, if the display object is in a 
     *  bridge application. If the display object is not in a bridge application,
     *  then null is returned.
     * 
     */
    private function getSWFBridgeOfDisplayObject(displayObject:DisplayObject):IEventDispatcher
    {
		if (swfBridgeGroup)
		{
			var request:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.IS_BRIDGE_CHILD_REQUEST,
																		false, false, null, displayObject);
			var children:Array = swfBridgeGroup.getChildBridges();
			var n:int = children.length;
			for (var i:int = 0; i < n; i++)
			{
				var childBridge:IEventDispatcher = IEventDispatcher(children[i]);
				
				// No need to test a child if it does not trust us, we will never see
				// their display objects.
				// Also, if the we don't trust the child don't send them a display object.
				var bp:ISWFBridgeProvider = swfBridgeGroup.getChildBridgeProvider(childBridge);
				if (SecurityUtil.hasMutualTrustBetweenParentAndChild(bp))
				{
				childBridge.dispatchEvent(request);
                    if (request.data == true)
                        return childBridge;
	                   
	                // reset data property
	                request.data = displayObject;
				}
			}
		}
			
		return null;
	}

	/**
	 * redispatch certian events to other top-level windows
	 */
	private function multiWindowRedispatcher(event:Event):void
	{
		if (!SystemManagerGlobals.dispatchingEventToOtherSystemManagers)
		{
			dispatchEventToOtherSystemManagers(event);
		}
	}

	/**
         * Create the requested manager.
	 */
	private function initManagerHandler(event:Event):void
	{
		if (!SystemManagerGlobals.dispatchingEventToOtherSystemManagers)
		{
			dispatchEventToOtherSystemManagers(event);
		}
		// if we are broadcasting messages, ignore the messages
		// we send to ourselves.
		if (event is InterManagerRequest)
			return;

		// initialize the registered manager implementation
		var name:String = event["name"];
		try
		{
			Singleton.getInstance(name);
		}
		catch (e:Error)
		{
		}
	}

	/**
         *  Adds a child to the requested childList.
         *  
         *  @param layer The child list that the child should be added to. The valid choices are 
         *  "popUpChildren", "cursorChildren", and "toolTipChildren". The choices match the property 
         *  names of ISystemManager and that is the list where the child is added.
         *  
         *  @param child The child to add.
	 */
	public function addChildToSandboxRoot(layer:String, child:DisplayObject):void
	{
		if (systemManager.getSandboxRoot() == systemManager)
		{
			systemManager[layer].addChild(child);
		}
		else
		{
			childManager.addingChild(child);
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.SYSTEM_MANAGER_REQUEST);
			me.name = layer + ".addChild";
			me.value = child;
			systemManager.getSandboxRoot().dispatchEvent(me);
			childManager.childAdded(child);
		}
	}

	/**
         *  Removes a child from the requested childList.
         *  
         *  @param layer The child list that the child should be removed from. The valid choices are 
         *  "popUpChildren", "cursorChildren", and "toolTipChildren". The choices match the property 
         *  names of ISystemManager and that is the list where the child is removed from.
         *  
         *  @param child The child to remove.
	 */
	public function removeChildFromSandboxRoot(layer:String, child:DisplayObject):void
	{
		if (systemManager.getSandboxRoot() == systemManager)
		{
			systemManager[layer].removeChild(child);
		}
		else
		{
			childManager.removingChild(child);
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.SYSTEM_MANAGER_REQUEST);
			me.name = layer + ".removeChild";
			me.value = child;
			systemManager.getSandboxRoot().dispatchEvent(me);
			childManager.childRemoved(child);
		}
	}


	/**
         * Perform the requested action from a trusted dispatcher.
	 */
	private function systemManagerHandler(event:Event):void
	{
		if (event["name"] == "sameSandbox")
		{
			event["value"] = currentSandboxEvent == event["value"];
			return;
		}
                else if (event["name"] == "hasSWFBridges")
                {
                        event["value"] = hasSWFBridges();
                        return;
                }

		// if we are broadcasting messages, ignore the messages
		// we send to ourselves.
		if (event is InterManagerRequest)
			return;

		// initialize the registered manager implementation
		var name:String = event["name"];

		switch (name)
		{
		case "popUpChildren.addChild":
			systemManager.popUpChildren.addChild(event["value"]);
			break;
		case "popUpChildren.removeChild":
			systemManager.popUpChildren.removeChild(event["value"]);
			break;
		case "cursorChildren.addChild":
			systemManager.cursorChildren.addChild(event["value"]);
			break;
		case "cursorChildren.removeChild":
			systemManager.cursorChildren.removeChild(event["value"]);
			break;
		case "toolTipChildren.addChild":
			systemManager.toolTipChildren.addChild(event["value"]);
			break;
		case "toolTipChildren.removeChild":
			systemManager.toolTipChildren.removeChild(event["value"]);
			break;
		case "screen":
			event["value"] = systemManager.screen;
			break;
		case "application":
		    event["value"] = systemManager.document;
		    break;
		case "isTopLevelRoot":
		    event["value"] = systemManager.isTopLevelRoot();
		    break;
	    case "getVisibleApplicationRect":
	        event["value"] = getVisibleApplicationRect(); 
			break;
            case "bringToFront":
            if (event["value"].topMost)
                systemManager.popUpChildren.setChildIndex(DisplayObject(event["value"].popUp), 
										systemManager.popUpChildren.numChildren - 1);
            else
                systemManager.setChildIndex(DisplayObject(event["value"].popUp), systemManager.numChildren - 1);
            
                break;
		}
	}
	
	
	/**
	 * Get the size of our sandbox's screen property.
	 * 
	 * Only the screen property should need to call this function.
	 * 
	 * The function assumes the caller does not have access to the stage.
	 * 
	 */
	private function getSandboxScreen():Rectangle
	{
    	// If we don't have access to the stage, use the size of
    	// our sandbox root.
    	var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
    	var sandboxScreen:Rectangle;
    	
    	if (sandboxRoot == systemManager)
    		// we don't have access the stage so use the width and
    		// height of the application.
   			sandboxScreen = new Rectangle(0, 0, IFlexDisplayObject(systemManager).width, IFlexDisplayObject(systemManager).height);			
    	else if (sandboxRoot == systemManager.topLevelSystemManager)
    	{
    		var sm:DisplayObject = DisplayObject(systemManager.topLevelSystemManager);
    		sandboxScreen = new Rectangle(0, 0, sm.width, sm.height);
    	}
    	else
    	{
	    	var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.SYSTEM_MANAGER_REQUEST, false, false,
    											   "screen");
    		sandboxRoot.dispatchEvent(me);		
    	
    		// me.value now contains the screen property of the sandbox root.
    		sandboxScreen = Rectangle(me.value);
    	}

		return sandboxScreen;
	}	

	/**
	 * The system manager proxy has only one child that is a focus manager container.
	 * Iterate thru the children until we find it.
	 */
	mx_internal function findFocusManagerContainer(smp:SystemManagerProxy):IFocusManagerContainer
	{
		var children:IChildList = smp.rawChildren;
		var numChildren:int = children.numChildren;
		for (var i:int = 0; i < numChildren; i++)
		{
			var child:DisplayObject = children.getChildAt(i);
			if (child is IFocusManagerContainer)
			{
				return IFocusManagerContainer(child);
			}
		}
		
		return null;
	}

	/**
	 * @private
	 * 
	 * Listen to messages this System Manager needs to service from its children.
	 */	
	mx_internal function addChildBridgeListeners(bridge:IEventDispatcher):void
	{
		if (!systemManager.isTopLevel() && systemManager.topLevelSystemManager)
		{
			var mp:MarshallingSupport = 
				MarshallingSupport(systemManager.topLevelSystemManager.getImplementation("mx.managers::IMarshalSystemManager"));
			mp.addChildBridgeListeners(bridge);
			return;
		}
		
		bridge.addEventListener(SWFBridgeRequest.ADD_POP_UP_REQUEST, addPopupRequestHandler);
		bridge.addEventListener(SWFBridgeRequest.REMOVE_POP_UP_REQUEST, removePopupRequestHandler);
		bridge.addEventListener(SWFBridgeRequest.ADD_POP_UP_PLACE_HOLDER_REQUEST, addPlaceholderPopupRequestHandler);
		bridge.addEventListener(SWFBridgeRequest.REMOVE_POP_UP_PLACE_HOLDER_REQUEST, removePlaceholderPopupRequestHandler);
		bridge.addEventListener(SWFBridgeEvent.BRIDGE_WINDOW_ACTIVATE, activateFormSandboxEventHandler);
		bridge.addEventListener(SWFBridgeEvent.BRIDGE_WINDOW_DEACTIVATE, deactivateFormSandboxEventHandler); 
		bridge.addEventListener(SWFBridgeEvent.BRIDGE_APPLICATION_ACTIVATE, activateApplicationSandboxEventHandler);
		bridge.addEventListener(EventListenerRequest.ADD_EVENT_LISTENER_REQUEST, eventListenerRequestHandler, false, 0, true);
		bridge.addEventListener(EventListenerRequest.REMOVE_EVENT_LISTENER_REQUEST, eventListenerRequestHandler, false, 0, true);
        bridge.addEventListener(SWFBridgeRequest.CREATE_MODAL_WINDOW_REQUEST, modalWindowRequestHandler);
        bridge.addEventListener(SWFBridgeRequest.SHOW_MODAL_WINDOW_REQUEST, modalWindowRequestHandler);
        bridge.addEventListener(SWFBridgeRequest.HIDE_MODAL_WINDOW_REQUEST, modalWindowRequestHandler);
        bridge.addEventListener(SWFBridgeRequest.GET_VISIBLE_RECT_REQUEST, getVisibleRectRequestHandler);
        bridge.addEventListener(SWFBridgeRequest.HIDE_MOUSE_CURSOR_REQUEST, hideMouseCursorRequestHandler);
        bridge.addEventListener(SWFBridgeRequest.SHOW_MOUSE_CURSOR_REQUEST, showMouseCursorRequestHandler);
		bridge.addEventListener(SWFBridgeRequest.RESET_MOUSE_CURSOR_REQUEST, resetMouseCursorRequestHandler);
	}

	/**
	 * @private
	 * 
	 * Remove all child listeners.
	 */
	mx_internal function removeChildBridgeListeners(bridge:IEventDispatcher):void
	{
		if (!systemManager.isTopLevel() && systemManager.topLevelSystemManager)
		{
			var mp:MarshallingSupport = 
				MarshallingSupport(systemManager.topLevelSystemManager.getImplementation("mx.managers::IMarshalSystemManager"));

			mp.removeChildBridgeListeners(bridge);
			return;
		}
		
		bridge.removeEventListener(SWFBridgeRequest.ADD_POP_UP_REQUEST, addPopupRequestHandler);
		bridge.removeEventListener(SWFBridgeRequest.REMOVE_POP_UP_REQUEST, removePopupRequestHandler);
		bridge.removeEventListener(SWFBridgeRequest.ADD_POP_UP_PLACE_HOLDER_REQUEST, addPlaceholderPopupRequestHandler);
		bridge.removeEventListener(SWFBridgeRequest.REMOVE_POP_UP_PLACE_HOLDER_REQUEST, removePlaceholderPopupRequestHandler);
		bridge.removeEventListener(SWFBridgeEvent.BRIDGE_WINDOW_ACTIVATE, activateFormSandboxEventHandler);
		bridge.removeEventListener(SWFBridgeEvent.BRIDGE_WINDOW_DEACTIVATE, deactivateFormSandboxEventHandler); 
		bridge.removeEventListener(SWFBridgeEvent.BRIDGE_APPLICATION_ACTIVATE, activateApplicationSandboxEventHandler);
		bridge.removeEventListener(EventListenerRequest.ADD_EVENT_LISTENER_REQUEST, eventListenerRequestHandler);
		bridge.removeEventListener(EventListenerRequest.REMOVE_EVENT_LISTENER_REQUEST, eventListenerRequestHandler);
        bridge.removeEventListener(SWFBridgeRequest.CREATE_MODAL_WINDOW_REQUEST, modalWindowRequestHandler);
        bridge.removeEventListener(SWFBridgeRequest.SHOW_MODAL_WINDOW_REQUEST, modalWindowRequestHandler);
        bridge.removeEventListener(SWFBridgeRequest.HIDE_MODAL_WINDOW_REQUEST, modalWindowRequestHandler);
        bridge.removeEventListener(SWFBridgeRequest.GET_VISIBLE_RECT_REQUEST, getVisibleRectRequestHandler);
        bridge.removeEventListener(SWFBridgeRequest.HIDE_MOUSE_CURSOR_REQUEST, hideMouseCursorRequestHandler);
        bridge.removeEventListener(SWFBridgeRequest.SHOW_MOUSE_CURSOR_REQUEST, showMouseCursorRequestHandler);
		bridge.removeEventListener(SWFBridgeRequest.RESET_MOUSE_CURSOR_REQUEST, resetMouseCursorRequestHandler);
	}

	/**
	 * @private
	 * 
	 * Add listeners for events and requests we might receive from our parent if our
	 * parent is using a sandbox bridge to communicate with us.
	 */
	mx_internal function addParentBridgeListeners():void
	{
		if (!systemManager.isTopLevel() && systemManager.topLevelSystemManager)
		{
			var mp:MarshallingSupport = 
				MarshallingSupport(systemManager.topLevelSystemManager.getImplementation("mx.managers::IMarshalSystemManager"));

			mp.addParentBridgeListeners();
			return;
		}
		
		var bridge:IEventDispatcher = swfBridgeGroup.parentBridge;
		bridge.addEventListener(SWFBridgeRequest.SET_ACTUAL_SIZE_REQUEST, setActualSizeRequestHandler);
		bridge.addEventListener(SWFBridgeRequest.GET_SIZE_REQUEST, getSizeRequestHandler);

		// need to listener to parent system manager to get broadcast messages.
		bridge.addEventListener(SWFBridgeRequest.ACTIVATE_POP_UP_REQUEST, 
								activateRequestHandler); 
		bridge.addEventListener(SWFBridgeRequest.DEACTIVATE_POP_UP_REQUEST, 
								deactivateRequestHandler); 
		bridge.addEventListener(SWFBridgeRequest.IS_BRIDGE_CHILD_REQUEST, isBridgeChildHandler);
		bridge.addEventListener(EventListenerRequest.ADD_EVENT_LISTENER_REQUEST, eventListenerRequestHandler);
		bridge.addEventListener(EventListenerRequest.REMOVE_EVENT_LISTENER_REQUEST, eventListenerRequestHandler);
		bridge.addEventListener(SWFBridgeRequest.CAN_ACTIVATE_POP_UP_REQUEST, canActivateHandler);
		bridge.addEventListener(SWFBridgeEvent.BRIDGE_APPLICATION_UNLOADING, beforeUnloadHandler);
	}
	
	/**
	 * @private
	 * 
	 * remove listeners for events and requests we might receive from our parent if 
	 * our parent is using a sandbox bridge to communicate with us.
	 */
	mx_internal function removeParentBridgeListeners():void
	{
		if (!systemManager.isTopLevel() && systemManager.topLevelSystemManager)
		{
			var mp:MarshallingSupport = 
				MarshallingSupport(systemManager.topLevelSystemManager.getImplementation("mx.managers::IMarshalSystemManager"));

			mp.removeParentBridgeListeners();
			return;
		}
		
		var bridge:IEventDispatcher = swfBridgeGroup.parentBridge;
		bridge.removeEventListener(SWFBridgeRequest.SET_ACTUAL_SIZE_REQUEST, setActualSizeRequestHandler);
		bridge.removeEventListener(SWFBridgeRequest.GET_SIZE_REQUEST, getSizeRequestHandler);

		// need to listener to parent system manager to get broadcast messages.
		bridge.removeEventListener(SWFBridgeRequest.ACTIVATE_POP_UP_REQUEST, 
								activateRequestHandler); 
		bridge.removeEventListener(SWFBridgeRequest.DEACTIVATE_POP_UP_REQUEST, 
								deactivateRequestHandler); 
		bridge.removeEventListener(SWFBridgeRequest.IS_BRIDGE_CHILD_REQUEST, isBridgeChildHandler);
		bridge.removeEventListener(EventListenerRequest.ADD_EVENT_LISTENER_REQUEST, eventListenerRequestHandler);
		bridge.removeEventListener(EventListenerRequest.REMOVE_EVENT_LISTENER_REQUEST, eventListenerRequestHandler);
		bridge.removeEventListener(SWFBridgeRequest.CAN_ACTIVATE_POP_UP_REQUEST, canActivateHandler);
		bridge.removeEventListener(SWFBridgeEvent.BRIDGE_APPLICATION_UNLOADING, beforeUnloadHandler);
	}
	
	/**
	 * Add a bridge to talk to the child owned by <code>owner</code>.
	 * 
	 *  @param bridge The bridge used to talk to the parent. 
	 *  @param owner The display object that owns the bridge.
	 */	
	public function addChildBridge(bridge:IEventDispatcher, owner:DisplayObject):void
	{
            // Is the owner in a pop up? If so let the focus manager manage the
            // bridge instead of the system manager.
        var fm:IFocusManager = null;
        var o:DisplayObject = owner;

        while (o)
        {
            if (o is IFocusManagerContainer)
            {
                fm = IFocusManagerContainer(o).focusManager;
                break;
            }

            o = o.parent;
        }
        
        if (!fm)
            return;
            
		if (!swfBridgeGroup)
			swfBridgeGroup = new SWFBridgeGroup(systemManager);

		var event:DynamicEvent = new DynamicEvent("addChildBridge");
		event.bridge = bridge;
        event.owner = owner;
		fm.dispatchEvent(event);

   		swfBridgeGroup.addChildBridge(bridge, ISWFBridgeProvider(owner));
        
        if (!bridgeToFocusManager)
            bridgeToFocusManager = new Dictionary();
            
        bridgeToFocusManager[bridge] = fm;

        addChildBridgeListeners(bridge);
        
        // dispatch message that we are adding a bridge.
        systemManager.dispatchEvent(new FlexChangeEvent(FlexChangeEvent.ADD_CHILD_BRIDGE, false, false, bridge));
 	}

	/**
	 * Remove a child bridge.
         *  
         *  @param bridge The target bridge to remove.
	 */
	public function removeChildBridge(bridge:IEventDispatcher):void
	{
        // dispatch message that we are removing a bridge.
        systemManager.dispatchEvent(new FlexChangeEvent(FlexChangeEvent.REMOVE_CHILD_BRIDGE, false, false, bridge));

        var fm:IFocusManager = IFocusManager(bridgeToFocusManager[bridge]);

		var event:DynamicEvent = new DynamicEvent("removeChildBridge");
		event.bridge = bridge;
		fm.dispatchEvent(event);

   		swfBridgeGroup.removeChildBridge(bridge);

        delete bridgeToFocusManager[bridge];
        removeChildBridgeListeners(bridge);
	}

	/**
	 *  @inheritDoc
	 */
	public function useSWFBridge():Boolean
	{
		if (systemManager.isTopLevelRoot())
			return false;
			
		if (!systemManager.isTopLevel() && systemManager.topLevelSystemManager)
		{
			var mp:IMarshalSystemManager = 
				IMarshalSystemManager(systemManager.topLevelSystemManager.getImplementation("mx.managers::IMarshalSystemManager"));
			return mp.useSWFBridge();
		}

        var sbRoot:DisplayObject = systemManager.getSandboxRoot();
         
		// if we're toplevel and we aren't the sandbox root, we need a bridge
		if (systemManager.isTopLevel() && sbRoot != systemManager)
			return true;
		
		// we also need a bridge even if we're the sandbox root
		// but not a stage root, but our parent loader is a bootstrap
		// that is not the stage root
		if (sbRoot == systemManager)
		{
			try
			{
				if (parentAllowsChild && childAllowsParent)
				{
					try
					{
						if (!DisplayObject(systemManager).parent.dispatchEvent(new Event("mx.managers.SystemManager.isStageRoot", false, true)))
							return true;
					}
					catch (e:Error)
					{
					}
				}
				else
					return true;
			}
			catch (e1:Error)
			{
				// we seem to get here when a SWF is being unloaded, has been unparented, but still
				// has a stage and root property, but loaderInfo is invalid.
				return false;
			}
		}

		return false;
	}
	
    public function getVisibleApplicationRectHandler(event:Request):void
    {
		var skipToSandboxRoot:Boolean = event.value.skipToSandboxRoot;
		
        var sbRoot:DisplayObject = systemManager.getSandboxRoot();
        var screen:Rectangle;

        if (skipToSandboxRoot && systemManager != sbRoot)
        {
            var request:InterManagerRequest = new InterManagerRequest(InterManagerRequest.SYSTEM_MANAGER_REQUEST, 
                                    false, false,
                                    "getVisibleApplicationRect"); 
            if (!sbRoot.dispatchEvent(request))
            {
                event.value = Rectangle(request.value);
                event.preventDefault();
            }
        }
        else
        {
            event.value = getVisibleApplicationRect(event.value.bounds as Rectangle);
            event.preventDefault();
        }

    }

   /**
    *  @inheritDoc
    */  
    public function getVisibleApplicationRect(bounds:Rectangle = null):Rectangle
    {
        if (!bounds)
        {
            bounds = DisplayObject(systemManager).getBounds(DisplayObject(systemManager));
            
            var s:Rectangle = systemManager.screen;        
            var pt:Point = new Point(Math.max(0, bounds.x), Math.max(0, bounds.y));
            pt = DisplayObject(systemManager).localToGlobal(pt);
            bounds.x = pt.x;
            bounds.y = pt.y;
            bounds.width = s.width;
            bounds.height = s.height;
        }
        
        // send a message to parent for their visible rect.
        if (useSWFBridge())
        {
            var bridge:IEventDispatcher = swfBridgeGroup.parentBridge;
            var bridgeRequest:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.GET_VISIBLE_RECT_REQUEST,
                                                                    false, false,
                                                                    bridge,
                                                                    bounds);
            bridge.dispatchEvent(bridgeRequest);
            bounds = Rectangle(bridgeRequest.data);
        }
		else if (!systemManager.isTopLevel())
		{
			var obj:DisplayObjectContainer = DisplayObject(systemManager).parent.parent;
			
			if ("getVisibleApplicationRect" in obj)
			{
				var visibleRect:Rectangle = obj["getVisibleApplicationRect"](true);
				bounds = bounds.intersection(visibleRect);
			}
		}
        
        return bounds;
    }
 
   /**
    *  @inheritDoc
    */  
    public function deployMouseShieldsHandler(event:DynamicEvent):void
    {
        var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.DRAG_MANAGER_REQUEST, false, false,
                                    "mouseShield", event.deploy);
        systemManager.getSandboxRoot().dispatchEvent(me);           
    }
    
	/**
	 * @private
	 * 
	 * Notify parent that a new window has been activated.
	 * 
	 * @param window window that was activated.
	 */
	public function dispatchActivatedWindowEvent(window:DisplayObject):void
	{
		var bridge:IEventDispatcher = swfBridgeGroup ? swfBridgeGroup.parentBridge : null;
		if (bridge)
		{
			var sbRoot:DisplayObject = systemManager.getSandboxRoot();
			var sendToSbRoot:Boolean = sbRoot != systemManager;
			var bridgeEvent:SWFBridgeEvent = new SWFBridgeEvent(SWFBridgeEvent.BRIDGE_WINDOW_ACTIVATE,
																	    false, false,
														{ notifier: bridge,
														  window: sendToSbRoot ? window :
	       													      NameUtil.displayObjectToString(window)
	       												});
	        if (sendToSbRoot)
	        	sbRoot.dispatchEvent(bridgeEvent);
			else
				bridge.dispatchEvent(bridgeEvent);
		}
		
	}

	/**
	 * @private
	 * 
	 * Notify parent that a window has been deactivated.
	 * 
	 * @param id window display object or id string that was activated. Ids are used if
	 * 		  the message is going outside the security domain.
	 */
	private function dispatchDeactivatedWindowEvent(window:DisplayObject):void
	{
		var bridge:IEventDispatcher = swfBridgeGroup ? swfBridgeGroup.parentBridge : null;
		if (bridge)
		{
			var sbRoot:DisplayObject = systemManager.getSandboxRoot();
			var sendToSbRoot:Boolean = sbRoot != systemManager;
			var bridgeEvent:SWFBridgeEvent = new SWFBridgeEvent(SWFBridgeEvent.BRIDGE_WINDOW_DEACTIVATE,
																	    false, 
																	    false,
                                                        { notifier: bridge,
                                                          window: sendToSbRoot ? window :
                                                                  NameUtil.displayObjectToString(window)
                                                        });
	        if (sendToSbRoot)
	        	sbRoot.dispatchEvent(bridgeEvent);
			else
				bridge.dispatchEvent(bridgeEvent);
		}
		
	}
	
	
	/**
	 * @private
	 * 
	 * Notify parent that an application has been activated.
	 */
	private function dispatchActivatedApplicationEvent():void
	{
		// click on this system manager or one of its sub system managers
		// If in a sandbox tell the top-level system manager we are active.
		var bridge:IEventDispatcher = swfBridgeGroup ? swfBridgeGroup.parentBridge : null;
		if (bridge)
		{
			var bridgeEvent:SWFBridgeEvent = new SWFBridgeEvent(SWFBridgeEvent.BRIDGE_APPLICATION_ACTIVATE,
																		false, false);
			bridge.dispatchEvent(bridgeEvent);
		}
	}

	/**
	 * Adjust the forms array so it is sorted by last active. 
	 * The last active form will be at the end of the forms array.
	 * 
	 * This method assumes the form variable has been set before calling
	 * this function.
	 */
	private function updateLastActiveForm():void
	{
		var awm:ActiveWindowManager = 
			ActiveWindowManager(systemManager.getImplementation("mx.managers::IActiveWindowManager"));

		// find "form" in the forms array and move that entry to 
		// the end of the array.
		var n:int = awm.forms.length;
		if (n < 2)
			return;	// zero or one forms, no need to update
			
		var index:int = -1;
		for (var i:int = 0; i < n; i++)
		{
			if (areFormsEqual(awm.form, awm.forms[i]))
			{
				index = i;
				break;
			}
		}
		
		if (index >= 0)
		{
			awm.forms.splice(index, 1);
			awm.forms.push(awm.form);
		}
		
	}

	/**
	 * @private
	 * 
	 * Add placeholder information to this instance's list of placeholder data.
	 */ 	
	private function addPlaceholderId(id:String, previousId:String, bridge:IEventDispatcher, 
									  placeholder:Object):void
	{
		if (!bridge)
			throw new Error();	// bridge is required.
			
		if (!idToPlaceholder)
			idToPlaceholder = [];
			
		idToPlaceholder[id] = new PlaceholderData(previousId, bridge, placeholder);	
	}
	
	private function removePlaceholderId(id:String):void
	{
		delete idToPlaceholder[id];
	}

	private var currentSandboxEvent:Event;

	private function dispatchEventToOtherSystemManagers(event:Event):void
	{
		SystemManagerGlobals.dispatchingEventToOtherSystemManagers = true;
		var arr:Array = SystemManagerGlobals.topLevelSystemManagers;
		var n:int = arr.length;
		for (var i:int = 0; i < n; i++)
		{
			if (arr[i] != systemManager)
			{
				arr[i].dispatchEvent(event);
			}
		}
		SystemManagerGlobals.dispatchingEventToOtherSystemManagers = false;
	}

	/**
	 *  @inheritDoc
	 */
	public function dispatchEventFromSWFBridges(event:Event, skip:IEventDispatcher = null, 
						trackClones:Boolean = false, toOtherSystemManagers:Boolean = false):void
	{
		if (toOtherSystemManagers)
		{
			dispatchEventToOtherSystemManagers(event);
		}

		if (!swfBridgeGroup)
			return;

		var clone:Event;
		// trace(">>dispatchEventFromSWFBridges", this, event.type);
		clone = event.clone();
		if (trackClones)
			currentSandboxEvent = clone;
		var parentBridge:IEventDispatcher = swfBridgeGroup.parentBridge;
		if (parentBridge && parentBridge != skip)
		{
		    // Ensure the requestor property has the correct bridge.
            if (clone is SWFBridgeRequest)
                SWFBridgeRequest(clone).requestor = parentBridge;
                
			parentBridge.dispatchEvent(clone);
		}
		
		var children:Array = swfBridgeGroup.getChildBridges();
		for (var i:int = 0; i < children.length; i++)
		{
			if (children[i] != skip)
			{
				// trace("send to child", i, event.type);
				clone = event.clone();
				if (trackClones)
					currentSandboxEvent = clone;
    
                // Ensure the requestor property has the correct bridge.
    	        if (clone is SWFBridgeRequest)
                    SWFBridgeRequest(clone).requestor = IEventDispatcher(children[i]);

				IEventDispatcher(children[i]).dispatchEvent(clone);
			}
		}
		currentSandboxEvent = null;

		// trace("<<dispatchEventFromSWFBridges", this, event.type);
	}

	/**
	 * request the parent to add an event listener.
	 */
	private function addEventListenerToSandboxes(type:String, listener:Function, useCapture:Boolean = false, 
				priority:int=0, useWeakReference:Boolean=false, skip:IEventDispatcher = null):void
	{
		if (!swfBridgeGroup)
			return;

		// trace(">>addEventListenerToSandboxes", this, type);

		var request:EventListenerRequest = new EventListenerRequest(EventListenerRequest.ADD_EVENT_LISTENER_REQUEST, false, false,
													type, null,
													useCapture, 
													priority,
													useWeakReference);
		
		var parentBridge:IEventDispatcher = swfBridgeGroup.parentBridge;
		if (parentBridge && parentBridge != skip)
			parentBridge.addEventListener(type, listener, false, priority, useWeakReference);			
		
		var children:Array = swfBridgeGroup.getChildBridges();
		for (var i:int; i < children.length; i++)
		{
		 	var childBridge:IEventDispatcher = IEventDispatcher(children[i]);
		 	
		 	if (childBridge != skip) 
    		    childBridge.addEventListener(type, listener, false, priority, useWeakReference);			
		}
		
		dispatchEventFromSWFBridges(request, skip);
		// trace("<<addEventListenerToSandboxes", this, type);
	}

	/**
	 * request the parent to remove an event listener.
	 */	
	private function removeEventListenerFromSandboxes(type:String, listener:Function, 
	                                                  useCapture:Boolean = false,
	                                                  skip:IEventDispatcher = null):void 
	{
		if (!swfBridgeGroup)
			return;

		// trace(">>removeEventListenerToSandboxes", this, type);
		var request:EventListenerRequest = new EventListenerRequest(EventListenerRequest.REMOVE_EVENT_LISTENER_REQUEST, false, false,
																				type, null,
																				useCapture);
		var parentBridge:IEventDispatcher = swfBridgeGroup.parentBridge;
		if (parentBridge && parentBridge != skip)
			parentBridge.removeEventListener(type, listener, useCapture);
		
		var children:Array = swfBridgeGroup.getChildBridges();
		for (var i:int; i < children.length; i++)
		{
		    if (children[i] != skip)
		        IEventDispatcher(children[i]).removeEventListener(type, listener, useCapture);			
		}
		
		dispatchEventFromSWFBridges(request, skip);
		// trace("<<removeEventListenerToSandboxes", this, type);
	}

	/**
	 * request the parent to add an event listener.
	 */
	private function addEventListenerToOtherSystemManagers(type:String, listener:Function, useCapture:Boolean = false, 
				priority:int=0, useWeakReference:Boolean=false):void
	{
		var arr:Array = SystemManagerGlobals.topLevelSystemManagers;
		if (arr.length < 2)
			return;

		SystemManagerGlobals.changingListenersInOtherSystemManagers = true;
		var n:int = arr.length;
		for (var i:int = 0; i < n; i++)
		{
			if (arr[i] != systemManager)
			{
				arr[i].addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
		}
		SystemManagerGlobals.changingListenersInOtherSystemManagers = false;
	}

	/**
	 * request the parent to remove an event listener.
	 */	
	private function removeEventListenerFromOtherSystemManagers(type:String, listener:Function, 
	                                                  useCapture:Boolean = false):void 
	{
		var arr:Array = SystemManagerGlobals.topLevelSystemManagers;
		if (arr.length < 2)
			return;

		SystemManagerGlobals.changingListenersInOtherSystemManagers = true;
		var n:int = arr.length;
		for (var i:int = 0; i < n; i++)
		{
			if (arr[i] != systemManager)
			{
				arr[i].removeEventListener(type, listener, useCapture);
			}
		}
		SystemManagerGlobals.changingListenersInOtherSystemManagers = false;
	}

    /**
     *   @private
     * 
     *   @return true if the message should be processed, false if 
     *   no other action is required.
     */ 
    private function preProcessModalWindowRequest(request:SWFBridgeRequest, 
                                                  sbRoot:DisplayObject):Boolean
    {
        // should we process this message?
        if (request.data.skip)
        {
            // skipping this sandbox, 
            // but don't skip the next one.
            request.data.skip = false;
           
            if (useSWFBridge())
            {
                var bridge:IEventDispatcher = swfBridgeGroup.parentBridge;
                request.requestor = bridge;
                bridge.dispatchEvent(request);
            }
            return false;
        }
        
        // if we are not the sandbox root, dispatch the message to the sandbox root.
        if (systemManager != sbRoot)
        {
            // convert exclude component into a rectangle and forward to parent bridge.
            if (request.type == SWFBridgeRequest.CREATE_MODAL_WINDOW_REQUEST ||
                request.type == SWFBridgeRequest.SHOW_MODAL_WINDOW_REQUEST)
            {
                var exclude:ISWFLoader = swfBridgeGroup.getChildBridgeProvider(request.requestor) 
                                                 as ISWFLoader;
                
                // find the rectangle of the area to exclude                                                 
                if (exclude)
                {                    
                var excludeRect:Rectangle = ISWFLoader(exclude).getVisibleApplicationRect();
                request.data.excludeRect = excludeRect;

                    // If the area to exclude is not contain by our document then it is in a 
                    // pop up. From this point for set the useExclude flag to false to 
                    // tell our parent not to exclude use from their modal window, only
                    // the excludeRect we have just calculated.
                    if (!DisplayObjectContainer(systemManager.document).contains(DisplayObject(exclude)))
                        request.data.useExclude = false;  // keep the existing excludeRect
                }
            }
                
            bridge = swfBridgeGroup.parentBridge;
                request.requestor = bridge;
         
                // The HIDE request does not need to be processed by each
                // application, so dispatch it directly to the sandbox root.       
                if (request.type == SWFBridgeRequest.HIDE_MODAL_WINDOW_REQUEST)
                    sbRoot.dispatchEvent(request);
                else 
                    bridge.dispatchEvent(request);
                return false;
            }

        // skip aftering sending the message over a bridge.
        request.data.skip = false;
                
        return true;
    }    
    

	private function otherSystemManagerMouseListener(event:SandboxMouseEvent):void
	{
		if (SystemManagerGlobals.dispatchingEventToOtherSystemManagers)
			return;

		dispatchEventFromSWFBridges(event);

		// ask the sandbox root if it was the original dispatcher of this event
		// if it was then don't dispatch to ourselves because we could have
		// got this event by listening to sandboxRoot ourselves.
		var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.SYSTEM_MANAGER_REQUEST);
		me.name = "sameSandbox";
		me.value = event;
		systemManager.getSandboxRoot().dispatchEvent(me);

		if (!me.value)
			systemManager.dispatchEvent(event);
	}

	private function sandboxMouseListener(event:Event):void
	{
		// trace("sandboxMouseListener", this);
		if (event is SandboxMouseEvent)
			return;

		var marshaledEvent:Event = SandboxMouseEvent.marshal(event);
		dispatchEventFromSWFBridges(marshaledEvent, event.target as IEventDispatcher);

		// ask the sandbox root if it was the original dispatcher of this event
		// if it was then don't dispatch to ourselves because we could have
		// got this event by listening to sandboxRoot ourselves.
		var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.SYSTEM_MANAGER_REQUEST);
		me.name = "sameSandbox";
		me.value = event;
		systemManager.getSandboxRoot().dispatchEvent(me);

		if (!me.value)
			systemManager.dispatchEvent(marshaledEvent);
	}

	private function eventListenerRequestHandler(event:Event):void
	{
		if (event is EventListenerRequest)
			return;

        var actualType:String;
		var request:EventListenerRequest = EventListenerRequest.marshal(event);
		if (event.type == EventListenerRequest.ADD_EVENT_LISTENER_REQUEST)
		{
			if (!eventProxy)
			{
				eventProxy = new EventProxy(systemManager);
			}
			
			actualType = EventUtil.sandboxMouseEventMap[request.eventType];
			if (actualType)
			{
				if (systemManager.isTopLevelRoot())
				{
					systemManager.stage.addEventListener(MouseEvent.MOUSE_MOVE, resetMouseCursorTracking, true, EventPriority.CURSOR_MANAGEMENT + 1, true);
				}
				else
				{
                    Object(systemManager).$addEventListener(MouseEvent.MOUSE_MOVE, resetMouseCursorTracking, true, EventPriority.CURSOR_MANAGEMENT + 1, true);
				}

                // add listeners in other sandboxes in capture mode so we don't miss anything
				addEventListenerToSandboxes(request.eventType, sandboxMouseListener,
							true, request.priority, request.useWeakReference, event.target as IEventDispatcher);
				addEventListenerToOtherSystemManagers(request.eventType, otherSystemManagerMouseListener, 
							true, request.priority, request.useWeakReference);
				if (systemManager.getSandboxRoot() == systemManager)
				{
                    if (systemManager.isTopLevelRoot() &&
                       (actualType == MouseEvent.MOUSE_UP || actualType == MouseEvent.MOUSE_MOVE))
				    {
                        if (systemManager.stage)
				            systemManager.stage.addEventListener(actualType, eventProxy.marshalListener,
                                false, request.priority, request.useWeakReference);
				    }

                    Object(systemManager).$addEventListener(actualType, eventProxy.marshalListener,
                        true, request.priority, request.useWeakReference);
                }
			}
		}
		else if (event.type == EventListenerRequest.REMOVE_EVENT_LISTENER_REQUEST)
        {
            actualType = EventUtil.sandboxMouseEventMap[request.eventType];
            if (actualType)
            {
				removeEventListenerFromOtherSystemManagers(request.eventType, otherSystemManagerMouseListener, true);
                removeEventListenerFromSandboxes(request.eventType, sandboxMouseListener,
                            true, event.target as IEventDispatcher);
                if (systemManager.getSandboxRoot() == systemManager)
                {
                    if (systemManager.isTopLevelRoot() &&
                       (actualType == MouseEvent.MOUSE_UP || actualType == MouseEvent.MOUSE_MOVE))
                    {
                        if (systemManager.stage)
                            systemManager.stage.removeEventListener(actualType, eventProxy.marshalListener);
                    }
			        // Remove both listeners in case the system manager was added
			        // or removed from the stage after the listener was added.
                    Object(systemManager).$removeEventListener(actualType, eventProxy.marshalListener, true);
                }
            }
        }		
	}

	private function Stage_resizeHandler(event:Event = null):void
	{	
       	var sandboxScreen:Rectangle = getSandboxScreen();
        if (!Object(systemManager)._screen)
            Object(systemManager)._screen = new Rectangle();
       	Object(systemManager)._screen.width = sandboxScreen.width;
       	Object(systemManager)._screen.height = sandboxScreen.height;
	}

 	/**
	 *  Override this function if you want to perform any logic
	 *  when the application has finished initializing itself.
	 */
	private function invalidateParentSizeAndDisplayListHandler(event:Event):void
	{
		if (systemManager.isTopLevel() && useSWFBridge())
		   dispatchInvalidateRequest();
	}

	/**
	 * @private
	 * 
	 * Handle request to unload
	 * Forward event, and do some cleanup
	 */
	private function unloadHandler(event:Event):void
	{
		systemManager.dispatchEvent(event);
	}


	private function addEventListenerHandler(request:DynamicEvent):void
	{
        if (!addEventListener(request.eventType, request.listener, request.useCapture,
                                request.priority, request.useWeakReference))
            request.preventDefault();
    }


	private function removeEventListenerHandler(request:DynamicEvent):void
    {
        if (!removeEventListener(request.eventType, request.listener, request.useCapture))
            request.preventDefault();
        
    }
}

}


