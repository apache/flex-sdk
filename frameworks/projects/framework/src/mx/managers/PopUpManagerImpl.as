////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2006-2007 Adobe Systems Incorporated
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
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.Stage;
import flash.utils.Proxy;

import mx.automation.IAutomationObject;
import mx.containers.Canvas;
import mx.controls.Alert;
import mx.core.ApplicationGlobals;
import mx.core.FlexSprite;
import mx.core.IChildList;
import mx.core.IFlexDisplayObject;
import mx.core.IFlexModule;
import mx.core.IInvalidating;
import mx.core.ISWFLoader;
import mx.core.IUIComponent;
import mx.core.UIComponentGlobals;
import mx.core.mx_internal;
import mx.effects.Blur;
import mx.effects.IEffect;
import mx.effects.Fade;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.events.FlexMouseEvent;
import mx.events.MoveEvent;
import mx.events.SWFBridgeRequest;
import mx.managers.ISystemManager;
import mx.managers.SystemManager;
import mx.managers.SystemManagerProxy;
import mx.styles.IStyleClient;
import mx.utils.NameUtil;
import mx.events.InterManagerRequest;
import mx.core.UIComponent;
import mx.events.SandboxMouseEvent;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 *  The PopUpManager singleton class creates new top-level windows and
 *  places or removes those windows from the layer on top of all other
 *  visible windows.  See the SystemManager for a description of the layering.
 *  It is used for popup dialogs, menus, and dropdowns in the ComboBox control 
 *  and in similar components.
 * 
 *  <p>The PopUpManager also provides modality, so that windows below the popup
 *  cannot receive mouse events, and also provides an event if the user clicks
 *  the mouse outside the window so the developer can choose to dismiss
 *  the window or warn the user.</p>
 * 
 *  @see PopUpManagerChildList
 */
public class PopUpManagerImpl implements IPopUpManager
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
    private static var instance:IPopUpManager;
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    public static function getInstance():IPopUpManager
    {
        if (!instance)
            instance = new PopUpManagerImpl();

        return instance;
    }

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    public function PopUpManagerImpl()
    {
        super();
        
        var sm:ISystemManager = ISystemManager(SystemManagerGlobals.topLevelSystemManagers[0]);
        
        sm.addEventListener(SWFBridgeRequest.CREATE_MODAL_WINDOW_REQUEST, createModalWindowRequestHandler, false, 0, true);
        sm.addEventListener(SWFBridgeRequest.SHOW_MODAL_WINDOW_REQUEST, showModalWindowRequest, false, 0, true);
        sm.addEventListener(SWFBridgeRequest.HIDE_MODAL_WINDOW_REQUEST, hideModalWindowRequest, false, 0, true);
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  The class used to create the shield that makes a window appear modal.
     */
    mx_internal var modalWindowClass:Class;

    /**
     *  @private
     *  An array of information about currently active popups
     */
    private var popupInfo:Array;

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Creates a top-level window and places it above other windows in the
     *  z-order.
     *  It is good practice to call the <code>removePopUp()</code> method 
     *  to remove popups created by using the <code>createPopUp()</code> method.
     *
     *  If the class implements IFocusManagerContainer, the window will have its
     *  own FocusManager so that, if the user uses the TAB key to navigate between
     *  controls, only the controls in the window will be accessed.
     *
     *  <p><b>Example</b></p> 
     *
     *  <pre>pop = mx.managers.PopUpManager.createPopUp(pnl, TitleWindow, false); </pre>
     *  
     *  <p>Creates a popup window based on the TitleWindow class, using <code>pnl</code> as the MovieClip 
     *  for determining where to place the popup. It is defined to be a non-modal window 
     *  meaning that other windows can receive mouse events</p>
     *
     *  @param parent DisplayObject to be used for determining which SystemManager's layers
     *  to use and optionally the reference point for centering the new
     *  top level window.  It may not be the actual parent of the popup as all popups
     *  are parented by the SystemManager.
     * 
     *  @param className Class of object that is to be created for the popup.
     *  The class must implement IFlexDisplayObject.
     *
     *  @param modal If <code>true</code>, the window is modal which means that
     *  the user will not be able to interact with other popups until the window
     *  is removed.
     *
     *  @param childList The child list in which to add the popup.
     *  One of <code>PopUpManagerChildList.APPLICATION</code>, 
     *  <code>PopUpManagerChildList.POPUP</code>, 
     *  or <code>PopUpManagerChildList.PARENT</code> (default).
     *
     *  @return Reference to new top-level window.
     *
     *  @see PopUpManagerChildList
     */
    public function createPopUp(parent:DisplayObject,
                                className:Class,
                                modal:Boolean = false,
                                childList:String = null):IFlexDisplayObject
    {   
        const window:IUIComponent = new className();
        addPopUp(window, parent, modal, childList);
        return window;
    }
    
    /**
     *  Pops up a top-level window.
     *  It is good practice to call <code>removePopUp()</code> to remove popups
     *  created by using the <code>createPopUp()</code> method.
     *  If the class implements IFocusManagerContainer, the window will have its
     *  own FocusManager so that, if the user uses the TAB key to navigate between
     *  controls, only the controls in the window will be accessed.
     *
     *  <p><b>Example</b></p> 
     *
     *  <pre>var tw = new TitleWindow();
     *    tw.title = "My Title";
     *    mx.managers.PopUpManager.addPopUp(tw, pnl, false);</pre>
     *
     *  <p>Creates a popup window using the <code>tw</code> instance of the 
     *  TitleWindow class and <code>pnl</code> as the Sprite for determining
     *  where to place the popup.
     *  It is defined to be a non-modal window.</p>
     *  
     *  @param window The IFlexDisplayObject to be popped up.
     *
     *  @param parent DisplayObject to be used for determining which SystemManager's layers
     *  to use and optionally  the reference point for centering the new
     *  top level window.  It may not be the actual parent of the popup as all popups
     *  are parented by the SystemManager.
     *
     *  @param modal If <code>true</code>, the window is modal which means that
     *  the user will not be able to interact with other popups until the window
     *  is removed.
     *
     *  @param childList The child list in which to add the pop-up.
     *  One of <code>PopUpManagerChildList.APPLICATION</code>, 
     *  <code>PopUpManagerChildList.POPUP</code>, 
     *  or <code>PopUpManagerChildList.PARENT</code> (default).
     *
     *  @see PopUpManagerChildList
     */
    public function addPopUp(window:IFlexDisplayObject,
                             parent:DisplayObject,
                             modal:Boolean = false,
                             childList:String = null):void
    {
        // trace("POPUP: window is " + window);
        // All popups go on the local root.
        // trace("POPUP: root is " + parent.root);
        // trace("POPUP: initial parent is " + parent);
        
        const visibleFlag:Boolean = window.visible;
        
		if (parent is IUIComponent && window is IUIComponent &&
			IUIComponent(window).document == null)
			IUIComponent(window).document = IUIComponent(parent).document;

		if (parent is IUIComponent && IUIComponent(parent).document is IFlexModule &&
			window is UIComponent && UIComponent(window).moduleFactory == null)
			UIComponent(window).moduleFactory = IFlexModule(IUIComponent(parent).document).moduleFactory;

        var sm:ISystemManager = getTopLevelSystemManager(parent);
        var children:IChildList;
        var topMost:Boolean;

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

		var smp:ISystemManager = sm;
		
		// if using a bridge, then create a System Manager Proxy to host
		// the popup. The System Manager Proxy is the display object
		// added to the top-level system manager's children, not
		// the popup itself.
		var sbRoot:DisplayObject = sm.getSandboxRoot();
		var request:SWFBridgeRequest = null;
		if (sm.useSWFBridge())
		{
			if (sbRoot != sm)
			{
				smp = new SystemManagerProxy(sm);
				request = new SWFBridgeRequest(SWFBridgeRequest.ADD_POP_UP_REQUEST, false, false,
				                                    sm.swfBridgeGroup.parentBridge,
													{ window: DisplayObject(smp),
														parent: parent,
														modal: modal,
														childList: childList});
				sbRoot.dispatchEvent(request);
			}
			else 
				smp = sm;		// host w/o system manager proxy.
		}
		
        if (window is IUIComponent)
            IUIComponent(window).isPopUp = true;
        
        if (!childList || childList == PopUpManagerChildList.PARENT)
            topMost = smp.popUpChildren.contains(parent);
        else
            topMost = (childList == PopUpManagerChildList.POPUP);
        
        children = topMost ? smp.popUpChildren : smp;
        children.addChild(DisplayObject(window));

        window.visible = false;
        
        if (!popupInfo)
            popupInfo = [];

        const o:PopUpData = new PopUpData();
        o.owner = DisplayObject(window);
        o.topMost = topMost;
        o.systemManager = smp;
        popupInfo.push(o);

        if (window is IFocusManagerContainer)
        {
			if (IFocusManagerContainer(window).focusManager)
                smp.addFocusManager(IFocusManagerContainer(window));
            else
                // Popups get their own focus loop
                IFocusManagerContainer(window).focusManager =
                    new FocusManager(IFocusManagerContainer(window), true);
        }

		// add a placeholder for an untrusted popup if this system manager
		// is hosting the popup.
		if (!sm.isTopLevelRoot() && sbRoot && sm == sbRoot)
		{
			request = new SWFBridgeRequest(SWFBridgeRequest.ADD_POP_UP_PLACE_HOLDER_REQUEST, false, false, null, { window: DisplayObject(window)});
			request.requestor = sm.swfBridgeGroup.parentBridge;
			request.data.placeHolderId = NameUtil.displayObjectToString(DisplayObject(window));
			sm.dispatchEvent(request);
		} 
		
        // force into automation hierarchy
        if (window is IAutomationObject)
            IAutomationObject(window).showInAutomationHierarchy = true;

        if (window is ILayoutManagerClient )
            UIComponentGlobals.layoutManager.validateClient(ILayoutManagerClient (window), true);
        
        o.parent = parent;
        
        if (window is IUIComponent)
        {
            IUIComponent(window).setActualSize(
                IUIComponent(window).getExplicitOrMeasuredWidth(),
                IUIComponent(window).getExplicitOrMeasuredHeight());
        }

        if (modal)
        {
            // create a modal window shield which blocks input and sets up mouseDownOutside logic
            createModalWindow(parent, o, children, visibleFlag, smp, sbRoot);
        }
        else
        {
            o._mouseDownOutsideHandler  = nonmodalMouseDownOutsideHandler;
            o._mouseWheelOutsideHandler = nonmodalMouseWheelOutsideHandler;

            window.visible = visibleFlag;
        }

        // Add show/hide listener so mouse out listeners can be added when
        // a pop up is shown because applications can be launched and 
        // terminated between the time a pop up is hidden to when it is
        // shown again.         
        o.owner.addEventListener(FlexEvent.SHOW, showOwnerHandler);
        o.owner.addEventListener(FlexEvent.HIDE, hideOwnerHandler);

        addMouseOutEventListeners(o);
        
        // Listen for unload so we know to kill the window (and the modalWindow if modal)
        // this handles _all_ cleanup
        window.addEventListener(Event.REMOVED, popupRemovedHandler);
            
        if (window is IFocusManagerContainer && visibleFlag)
        {
         	if (!(smp is SystemManagerProxy) && smp.useSWFBridge())
         		// We want the top-level root to activate the window.
         		SystemManager(smp).dispatchActivatedWindowEvent(DisplayObject(window));
         	else
            	smp.activate(IFocusManagerContainer(window));
        }

        // trace("END POPUP: addPopUp" + parent);
    }


	private function getTopLevelSystemManager(parent:DisplayObject):ISystemManager
	{
	    var localRoot:DisplayObjectContainer;
		var sm:ISystemManager;
	
		if (parent.parent is SystemManagerProxy)
			localRoot = DisplayObjectContainer(SystemManagerProxy(parent.parent).systemManager);
		else if (parent is IUIComponent && IUIComponent(parent).systemManager is SystemManagerProxy)
			localRoot = DisplayObjectContainer(SystemManagerProxy(IUIComponent(parent).systemManager).systemManager);
		else
			localRoot = DisplayObjectContainer(parent.root);
			
        // If the parent isn't rooted yet,
        // Or the root is the stage (which is the case in a second AIR window)
        // use the global system manager instance.
        if ((!localRoot || localRoot is Stage) && parent is IUIComponent)
            localRoot = DisplayObjectContainer(IUIComponent(parent).systemManager);
        if (localRoot is ISystemManager)
        {
            sm = ISystemManager(localRoot);
            if (!sm.isTopLevel())
                sm = sm.topLevelSystemManager;
        }

		return sm;
	}

    /**
     *  Centers a popup window over whatever window was used in the call 
     *  to the <code>createPopUp()</code> or <code>addPopUp()</code> method.
     *
     *  <p>Note that the position of the popup window may not
     *  change immediately after this call since Flex may wait to measure and layout the
     *  popup window before centering it.</p>
     *
     *  @param The IFlexDisplayObject representing the popup.
     */
    public function centerPopUp(popUp:IFlexDisplayObject):void
    {
        if (popUp is IInvalidating)
            IInvalidating(popUp).validateNow();

        const o:PopUpData = findPopupInfoByOwner(popUp);
        
        // If we don't find the pop owner or if the owner's parent is not specified or is not on the
        // stage, then center based on the popUp's current parent.
        var popUpParent:DisplayObject = (o && o.parent && o.parent.stage) ? o.parent : popUp.parent;
        if (popUpParent)
        {
            var systemManager:ISystemManager = o.systemManager;
            var x:Number;
            var y:Number;
            var appWidth:Number;
            var appHeight:Number;
            var parentWidth:Number;
            var parentHeight:Number;
            var s:Rectangle;            // the screen
            var rect:Rectangle
            var clippingOffset:Point = new Point();
            var pt:Point;
            var isTopLevelRoot:Boolean;
            var sbRoot:DisplayObject = systemManager.getSandboxRoot();
                                                         
            // Only need to calc the visible rect when the sandbox root is an untrusted application.
            // Otherwise the alert will float over the entire application.
            if (systemManager != sbRoot)
            {
                var request:InterManagerRequest = new InterManagerRequest(InterManagerRequest.SYSTEM_MANAGER_REQUEST, false, false,
                                                            "isTopLevelRoot");
                sbRoot.dispatchEvent(request);
                isTopLevelRoot = Boolean(request.value);
            }
            else
                isTopLevelRoot = systemManager.isTopLevelRoot();
                        
            if (isTopLevelRoot)
            {
                // The sandbox root is the top level root.
                // The application width is just the screen width.
                s = systemManager.screen;
                appWidth = s.width;
                appHeight = s.height;
            }            
            else
            {
                if (systemManager != sbRoot)
                {
                    request = new InterManagerRequest(InterManagerRequest.SYSTEM_MANAGER_REQUEST, false, false,
                                            "getVisibleApplicationRect"); 
                    sbRoot.dispatchEvent(request);
                    rect = Rectangle(request.value);
                }
                else
                    rect = systemManager.getVisibleApplicationRect();
            
                // Offset the top, left of the window to bring it into view.        
                clippingOffset = new Point(rect.x, rect.y);
                clippingOffset = DisplayObject(systemManager).globalToLocal(clippingOffset);
                appWidth = rect.width;
                appHeight = rect.height;
            } 

            // If parent is a UIComponent, check for clipping between
            // the object and its SystemManager
            if (popUpParent is UIComponent)
            {
                rect = UIComponent(popUpParent).getVisibleRect();
                var offset:Point = popUpParent.globalToLocal(rect.topLeft);
                clippingOffset.x += offset.x;
                clippingOffset.y += offset.y;
                parentWidth = rect.width;
                parentHeight = rect.height;              
            }   
            else
            {          
                parentWidth = popUpParent.width;
                parentHeight = popUpParent.height;
            }

            // The appWidth may smaller than parentWidth if the application is
            // clipped by the parent application.
            x = Math.max(0, (Math.min(appWidth, parentWidth) - popUp.width) / 2);
            y = Math.max(0, (Math.min(appHeight, parentHeight) - popUp.height) / 2);
            
            pt = new Point(clippingOffset.x, clippingOffset.y);
            pt = popUpParent.localToGlobal(pt);
            pt = popUp.parent.globalToLocal(pt);
            popUp.move(Math.round(x) + pt.x, Math.round(y) + pt.y);
        }
    }

    /**
     *  Removes a popup window popped up by 
     *  the <code>createPopUp()</code> or <code>addPopUp()</code> method.
     *  
     *  @param window The IFlexDisplayObject representing the popup window.
     */
    public function removePopUp(popUp:IFlexDisplayObject):void
    {
        // all we want to do here is verify that this popup is one of ours
        // and remove it from the display list; the REMOVED handler will do the rest
        // (this is so that we never leak memory, popups will self-manage even if
        //  removePopUp is not called).
        if (popUp && popUp.parent)
        {
            const o:PopUpData = findPopupInfoByOwner(popUp);
            if (o)
            {
                var sm:ISystemManager = o.systemManager;
                if (!sm)
				{
					var iui:IUIComponent = popUp as IUIComponent;
					// cross-versioning error sometimes returns wrong parent
					if (iui)
						sm = ISystemManager(iui.systemManager);
					else
						return;
				}

                if (o.topMost)
                    sm.popUpChildren.removeChild(DisplayObject(popUp));
                else
                    sm.removeChild(DisplayObject(popUp));
            }
        }
    }
    
    /**
     *  Makes sure a popup window is higher than other objects in its child list
     *  The SystemManager does this automatically if the popup is a top level window
     *  and is moused on, 
     *  but otherwise you have to take care of this yourself.
     *
     *  @param The IFlexDisplayObject representing the popup.
     */
    public function bringToFront(popUp:IFlexDisplayObject):void
    {
        if (popUp && popUp.parent)
        {
            const o:PopUpData = findPopupInfoByOwner(popUp);
            if (o)
            {
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
                }
                else if (o.topMost)
                    sm.popUpChildren.setChildIndex(DisplayObject(popUp), sm.popUpChildren.numChildren - 1);
                else
                    sm.setChildIndex(DisplayObject(popUp), sm.numChildren - 1);
            }
        }
    }
    
    /**
     *  @private
     * 
     *  Create the modal window. 
     *  This is called in two different cases.
     *      1. Create a modal window for a local pop up.
     *      2. Create a modal window for a remote pop up. In this case o.owner will be null.
     */
    private function createModalWindow(parentReference:DisplayObject,
                                       o:PopUpData,
                                       childrenList:IChildList,
                                       visibleFlag:Boolean,
                                       sm:ISystemManager,
                                       sbRoot:DisplayObject):void
    {
        const popup:IFlexDisplayObject = IFlexDisplayObject(o.owner);

        const popupStyleClient:IStyleClient = popup as IStyleClient;
        var duration:Number = 0;
      
        // Create a modalWindow the size of the stage
        // that eats all mouse clicks.
        var modalWindow:Sprite;
        if (modalWindowClass)
        {
            modalWindow = new modalWindowClass();
        }
        else
        {
            modalWindow = new FlexSprite();
            modalWindow.name = "modalWindow";
        }
    
    	if (!sm && parentReference)
	        sm = IUIComponent(parentReference).systemManager;

		var smp:SystemManagerProxy;
		var realSm:ISystemManager;
		if (sm is SystemManagerProxy)
		{
			smp = SystemManagerProxy(sm);
			realSm = smp.systemManager;
		}
		else
		    realSm = sm;
        
    	realSm.numModalWindows++;

        // Add it to the collection just below the popup
        if (popup)
            childrenList.addChildAt(modalWindow,
                childrenList.getChildIndex(DisplayObject(popup)));
        else 
            childrenList.addChild(modalWindow);
        
        // force into the automation hierarchy
        if (popup is IAutomationObject)
            IAutomationObject(popup).showInAutomationHierarchy = true;
        
        // set alpha of the popup and get it out of the focus loop
        if (!isNaN(o.modalTransparency))
            modalWindow.alpha = o.modalTransparency;
        else if (popupStyleClient)
            modalWindow.alpha = popupStyleClient.getStyle("modalTransparency");
		else
			modalWindow.alpha = 0;
		
		o.modalTransparency = modalWindow.alpha;
			
        modalWindow.tabEnabled = false;
        
        const s:Rectangle = realSm.screen;
        const g:Graphics = modalWindow.graphics;
        
        var c:Number = 0xFFFFFF;
        if (!isNaN(o.modalTransparencyColor))
            c = o.modalTransparencyColor;
        else if (popupStyleClient)
        {
            c = popupStyleClient.getStyle("modalTransparencyColor");
            o.modalTransparencyColor = c;
        }
        
        // trace("createModalWindow: drawing modal " + s);
        g.clear();
        g.beginFill(c, 100);
        g.drawRect(s.x, s.y, s.width, s.height);
        g.endFill();

        o.modalWindow = modalWindow;

        if (o.exclude)
        {
            o.modalMask = new Sprite();
            updateModalMask(realSm, modalWindow, 
                            o.useExclude ? o.exclude : null, 
                            o.excludeRect, o.modalMask);    
            modalWindow.mask = o.modalMask;
            childrenList.addChild(o.modalMask);
            
            // update the modal window mask when the size or position of the area 
            // we are excluding changes.
            o.exclude.addEventListener(Event.RESIZE, o.resizeHandler);
            o.exclude.addEventListener(MoveEvent.MOVE, o.resizeHandler);
        }
        
        // a modal mousedownoutside handler just dispatches the event
        o._mouseDownOutsideHandler  = dispatchMouseDownOutsideEvent;
        o._mouseWheelOutsideHandler = dispatchMouseWheelOutsideEvent;
        
        // the following handlers all get removed in REMOVED on the popup
        
        // Set the resize handler so the modal can stay the size of the screen
       	realSm.addEventListener(Event.RESIZE, o.resizeHandler);

        if (popup)
        {
            // Listen for show so we know to show the modal window
            popup.addEventListener(FlexEvent.SHOW, popupShowHandler);
        
            // Listen for hide so we know to hide the modal window
            popup.addEventListener(FlexEvent.HIDE, popupHideHandler);
        }
        
        if (visibleFlag)
            showModalWindow(o, sm, false);
        else
            popup.visible = visibleFlag;

        if (realSm.useSWFBridge())
        {
            if (popupStyleClient)
            {
                o.modalTransparencyDuration = popupStyleClient.getStyle("modalTransparencyDuration");
                o.modalTransparencyBlur = popupStyleClient.getStyle("modalTransparencyBlur");
            }

            dispatchModalWindowRequest(SWFBridgeRequest.CREATE_MODAL_WINDOW_REQUEST, realSm, sbRoot, o, visibleFlag);
        }            
    }
    
    
    private function dispatchModalWindowRequest(type:String, 
                                                sm:ISystemManager, 
                                                sbRoot:DisplayObject, 
                                                o:PopUpData,
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
        
        var modalRequest:SWFBridgeRequest = new SWFBridgeRequest(type, false, false, null,
												{ skip: !o.isRemoteModalWindow && sm != sbRoot,
												  useExclude: o.useExclude,   
												  show: visibleFlag,
												  remove: false,
												  transparencyDuration: o.modalTransparencyDuration,
												  transparency: o.modalTransparency,
												  transparencyColor: o.modalTransparencyColor,
												  transparencyBlur: o.modalTransparencyBlur});
        var bridge:IEventDispatcher = sm.swfBridgeGroup.parentBridge;; 
        modalRequest.requestor = bridge;
        bridge.dispatchEvent(modalRequest);
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
    
    /**
     *  @private
     */
    private function endEffects(o:PopUpData):void
    {
        if (o.fade)
        {
            o.fade.end();
            o.fade = null;
        }
        
        if (o.blur)
        {
            o.blur.end();
            o.blur = null;
        }
    }
    
    private function showModalWindow(o:PopUpData, sm:ISystemManager, sendRequest:Boolean = true):void
    {
    	const popUpStyleClient:IStyleClient = o.owner as IStyleClient;
        var duration:Number = 0;
        var alpha:Number = 0;
        
        if (!isNaN(o.modalTransparencyDuration))
            duration = o.modalTransparencyDuration;
        else if (popUpStyleClient)
        {
            duration = popUpStyleClient.getStyle("modalTransparencyDuration");
            o.modalTransparencyDuration = duration;
        }
        
        if (!isNaN(o.modalTransparency))
            alpha = o.modalTransparency;
        else if (popUpStyleClient)
        {
            alpha = popUpStyleClient.getStyle("modalTransparency");
            o.modalTransparency = alpha;
        }
            
		o.modalWindow.alpha = alpha;
			
	    var blurAmount:Number = 0;
	    
        if (!isNaN(o.modalTransparencyBlur))
            blurAmount = o.modalTransparencyBlur;
	    else if (popUpStyleClient)
	    {
	    	blurAmount = popUpStyleClient.getStyle("modalTransparencyBlur");
	    	o.modalTransparencyBlur = blurAmount;
	    }

		var transparencyColor:Number = 0xFFFFFF;
        if (!isNaN(o.modalTransparencyColor))
            transparencyColor = o.modalTransparencyColor;
	    else if (popUpStyleClient)
	    {
	    	transparencyColor = popUpStyleClient.getStyle("modalTransparencyColor");
	    	o.modalTransparencyColor = transparencyColor;
	    }
   
        if (sm is SystemManagerProxy)
            sm = SystemManagerProxy(sm).systemManager;
        var sbRoot:DisplayObject = sm.getSandboxRoot();

        showModalWindowInternal(o, duration, alpha, transparencyColor, blurAmount, sm, sbRoot);
        
        if (sendRequest && sm.useSWFBridge())
            dispatchModalWindowRequest(SWFBridgeRequest.SHOW_MODAL_WINDOW_REQUEST, sm, sbRoot, o, true);
    }
    
    /**
     *  @private
     *  Show the modal transparency blocker, playing effects if needed.
     */
    private function showModalWindowInternal(o:PopUpData, 
    										 transparencyDuration:Number, 
    										 transparency:Number, 
    										 transparencyColor:Number,
    										 transparencyBlur:Number, 
    										 sm:ISystemManager,
    										 sbRoot:DisplayObject):void
    {
        // NO POPUP Data
        // End any effects that are currently playing for this popup.
        endEffects(o);

        if (transparencyDuration)
        {
            // Fade effect on the modal transparency blocker
            const fade:Fade = new Fade(o.modalWindow);

            fade.alphaFrom = 0;
            fade.alphaTo = transparency;
            fade.duration = transparencyDuration;
            fade.addEventListener(EffectEvent.EFFECT_END, fadeInEffectEndHandler);

            o.modalWindow.alpha = 0;
            o.modalWindow.visible = true;
            o.fade = fade;
            
            if (o.owner)
                IUIComponent(o.owner).setVisible(false, true);
            
            fade.play();
            
            // Blur effect on the application
            var blurAmount:Number = transparencyBlur;
            
            if (blurAmount)
            {
                // Ensure we blur the appropriate top level document.
                if (DisplayObject(sm).parent is Stage)
                {
                    // Checking this case first allows WindowedSystemManagers be the blur target.
                    o.blurTarget = sm.document;
                }
                else if (sm != sbRoot)
                {
                    // Get the application document of the sandbox root.
                    // Use a request to get the document so APIs may change
                    // between Flex versions.
                    var sbRootApp:Object;
                    var applicationRequest:InterManagerRequest = new InterManagerRequest(InterManagerRequest.SYSTEM_MANAGER_REQUEST,
                                                                       false, false,
                                                                       "application",
                                                                       sbRootApp);
                    sbRoot.dispatchEvent(applicationRequest);
                    o.blurTarget = applicationRequest.value;
                }
                else
                    o.blurTarget = ApplicationGlobals.application;

                const blur:Blur = new Blur(o.blurTarget);
                blur.blurXFrom = blur.blurYFrom = 0;
                blur.blurXTo = blur.blurYTo = blurAmount;
                blur.duration = transparencyDuration;
                blur.addEventListener(EffectEvent.EFFECT_END, effectEndHandler);
                o.blur = blur;
                
                blur.play();
            }
        }
        else
        {
            if (o.owner)
                IUIComponent(o.owner).setVisible(true, true);
            o.modalWindow.visible = true;
        }
    }
    
    /**
     *  @private
     *  Hide the modal transparency blocker, playing effects if needed.
     * 
     */
    private function hideModalWindow(o:PopUpData, destroy:Boolean = false):void
    {
        if (destroy && o.exclude)
        {
            o.exclude.removeEventListener(Event.RESIZE, o.resizeHandler);
            o.exclude.removeEventListener(MoveEvent.MOVE, o.resizeHandler);
        }

        const popUpStyleClient:IStyleClient = o.owner as IStyleClient;

        var duration:Number = 0;
        if (popUpStyleClient)
            duration = popUpStyleClient.getStyle("modalTransparencyDuration");
        
        // end any effects that are current playing for this popup
        endEffects(o);
        
        if (duration)
        {
            // Fade effect on the modal transparency blocker
            const fade:Fade = new Fade(o.modalWindow);

            fade.alphaFrom = o.modalWindow.alpha;
            fade.alphaTo = 0;
            fade.duration = duration;
            fade.addEventListener(EffectEvent.EFFECT_END, 
                destroy ? fadeOutDestroyEffectEndHandler : fadeOutCloseEffectEndHandler);

            o.modalWindow.visible = true;
            o.fade = fade;
            fade.play();
            
            // Blur effect on the application
            const blurAmount:Number = popUpStyleClient.getStyle("modalTransparencyBlur");
            
            if (blurAmount)
            {
                const blur:Blur = new Blur(o.blurTarget);
                blur.blurXFrom = blur.blurYFrom = blurAmount;
                blur.blurXTo = blur.blurYTo = 0;
                blur.duration = duration;
                blur.addEventListener(EffectEvent.EFFECT_END, effectEndHandler);
                o.blur = blur;
                
                blur.play();
            }
        }
        else
        {
            o.modalWindow.visible = false;
        }
        
        var sm:ISystemManager = ISystemManager(ApplicationGlobals.application.systemManager);
        if (sm.useSWFBridge())
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
            var bridge:IEventDispatcher = sm.swfBridgeGroup.parentBridge;
            var target:IEventDispatcher;
            modalRequest.requestor = bridge;

            bridge.dispatchEvent(modalRequest);
        }

    }
    
    /**
     *  @private
     *  Returns the PopUpData (or null) for a given popupInfo.owner
     */
    private function findPopupInfoByOwner(owner:Object):PopUpData
    {
        const n:int = popupInfo.length;
        for (var i:int = 0; i < n; i++)
        {
            var o:PopUpData = popupInfo[i];
            if (o.owner == owner)
                return o;
        }
        return null;
    }

    /**
     *  @private
     *  Returns the PopUpData for the highest remote modal window on display.
     */
    private function findHighestRemoteModalPopupInfo():PopUpData
    {
        const n:int = popupInfo.length - 1;
        for (var i:int = n; i >= 0; i--)
        {
            var o:PopUpData = popupInfo[i];
            if (o.isRemoteModalWindow)
                return o;
        }
        return null;
    }

    /**
     *  @private
     *  Add mouse out listeners for modal and non-modal windows.
     */
    private function addMouseOutEventListeners(o:PopUpData):void
    {
        var sbRoot:DisplayObject = o.systemManager.getSandboxRoot();
        if (o.modalWindow)
        {
            o.modalWindow.addEventListener(MouseEvent.MOUSE_DOWN,  o.mouseDownOutsideHandler);
            o.modalWindow.addEventListener(MouseEvent.MOUSE_WHEEL, o.mouseWheelOutsideHandler, true);
        }
        else
        {
            sbRoot.addEventListener(MouseEvent.MOUSE_DOWN,  o.mouseDownOutsideHandler);
            sbRoot.addEventListener(MouseEvent.MOUSE_WHEEL, o.mouseWheelOutsideHandler, true);
        }
        
        sbRoot.addEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE,  o.marshalMouseOutsideHandler);
        sbRoot.addEventListener(SandboxMouseEvent.MOUSE_WHEEL_SOMEWHERE, o.marshalMouseOutsideHandler, true);
    }
    
    /**
     *  @private
     *  Remove mouse out listeners for modal and non-modal windows.
     */
    private function removeMouseOutEventListeners(o:PopUpData):void
    {
        var sbRoot:DisplayObject = o.systemManager.getSandboxRoot();
        if (o.modalWindow)
        {
            o.modalWindow.removeEventListener(MouseEvent.MOUSE_DOWN,  o.mouseDownOutsideHandler);
            o.modalWindow.removeEventListener(MouseEvent.MOUSE_WHEEL, o.mouseWheelOutsideHandler, true);
        }
        else 
        {
            sbRoot.removeEventListener(MouseEvent.MOUSE_DOWN,  o.mouseDownOutsideHandler);
            sbRoot.removeEventListener(MouseEvent.MOUSE_WHEEL, o.mouseWheelOutsideHandler, true);
        }

        sbRoot.removeEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE,  o.marshalMouseOutsideHandler);
        sbRoot.removeEventListener(SandboxMouseEvent.MOUSE_WHEEL_SOMEWHERE, o.marshalMouseOutsideHandler, true);
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Set by PopUpManager on modal windows so they show when the parent shows.
     */
    private function popupShowHandler(event:FlexEvent):void
    {
        const o:PopUpData = findPopupInfoByOwner(event.target);
        if (o)
            showModalWindow(o, getTopLevelSystemManager(o.parent));
    }

    /**
     *  @private
     *  Set by PopUpManager on modal windows so they hide when the parent hide
     */
    private function popupHideHandler(event:FlexEvent):void
    {
        const o:PopUpData = findPopupInfoByOwner(event.target);
        if (o)
            hideModalWindow(o);
    }

    /**
     *  @private
     */
    private function showOwnerHandler(event:FlexEvent):void
    {
        const o:PopUpData = findPopupInfoByOwner(event.target);
        if (o)
        {
            // add mouse out listeners.
            addMouseOutEventListeners(o);            
        }
    }

    /**
     *  @private
     */
    private function hideOwnerHandler(event:FlexEvent):void
    {
        const o:PopUpData = findPopupInfoByOwner(event.target);
        if (o)
        {
            // remove mouse out listeners
            removeMouseOutEventListeners(o);
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

        var sm:ISystemManager = getTopLevelSystemManager(DisplayObject(ApplicationGlobals.application));
        var sbRoot:DisplayObject = sm.getSandboxRoot();

        // process the message
        var popUpData:PopUpData = new PopUpData();
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
        popUpData.exclude = sm.swfBridgeGroup.getChildBridgeProvider(request.requestor) as IUIComponent;
        popUpData.useExclude = request.data.useExclude;
        popUpData.excludeRect = Rectangle(request.data.excludeRect);
        
        if (!popupInfo)
            popupInfo = [];

        popupInfo.push(popUpData);
        
        createModalWindow(null, popUpData, sm.popUpChildren, request.data.show, sm, sbRoot);
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

        var sm:ISystemManager = getTopLevelSystemManager(DisplayObject(ApplicationGlobals.application));
        var sbRoot:DisplayObject = sm.getSandboxRoot();
        
        // the highest popUpData in the list is the most recent modal window.
        // sanity check that the popupdata is really a modal window with a null
        // parent and popup window.
        var popUpData:PopUpData = findHighestRemoteModalPopupInfo();
        popUpData.excludeRect = Rectangle(request.data);
        popUpData.modalTransparency = request.data.transparency;
        
        // disable blur because we can mask the application and blur is not
        // working if we blur the modalWindow.
        popUpData.modalTransparencyBlur = 0; //request.transparencyBlur;
        popUpData.modalTransparencyColor = request.data.transparencyColor;
        popUpData.modalTransparencyDuration = request.data.transparencyDuration;

        if (popUpData.owner || popUpData.parent)
            throw new Error();              // not popUpData for a modal window
        
        showModalWindow(popUpData, sm);
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

        var sm:ISystemManager = getTopLevelSystemManager(DisplayObject(ApplicationGlobals.application));
        var sbRoot:DisplayObject = sm.getSandboxRoot();
        
        // the highest popUpData in the list is the most recent modal window.
        // sanity check that the popupdata is really a modal window with a null
        // parent and popup window.
        var popUpData:PopUpData = findHighestRemoteModalPopupInfo();
        if (!popUpData || popUpData.owner || popUpData.parent)
            throw new Error();              // not popUpData for a modal window
                    
        hideModalWindow(popUpData, request.data.remove);
        
        // handle removing popup window 
        if (request.data.remove)
        {
            popupInfo.splice(popupInfo.indexOf(popUpData), 1);
            sm.numModalWindows--;
        }
    }
    
    /**
     *  @private
     *  Set by PopUpManager on modal windows to monitor when the parent window gets killed.
     *  PopUps self-manage their memory -- when they are removed using removePopUp OR
     *  manually removed with removeChild, they will clean themselves up when they leave the
     *  display list (including all references to PopUpManager).
     */
    private function popupRemovedHandler(event:Event):void
    {
        const n:int = popupInfo.length;
        for (var i:int = 0; i < n; i++)
        {
            var o:PopUpData               = popupInfo[i],
                popUp:DisplayObject       = o.owner;
                  
            if (popUp == event.target)
            {
                var popUpParent:DisplayObject = o.parent,
                    modalWindow:DisplayObject = o.modalWindow,
                    sm:ISystemManager         = o.systemManager;
                var realSm:ISystemManager;
                
                if (sm is SystemManagerProxy)
                    realSm = SystemManagerProxy(sm).systemManager;
                else
                    realSm = sm;
                                             
				if (!sm.isTopLevel())
					sm = sm.topLevelSystemManager;

                if (popUp is IUIComponent)
                    IUIComponent(popUp).isPopUp = false;
                
                if (popUp is IFocusManagerContainer)
                    sm.removeFocusManager(IFocusManagerContainer(popUp));
                
                popUp.removeEventListener(Event.REMOVED,  popupRemovedHandler);

				// remove the focus manager from a bridged system manager, if any                
				if (sm is SystemManagerProxy)
				{
					var parentBridge:IEventDispatcher = realSm.swfBridgeGroup.parentBridge;
					var request:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.REMOVE_POP_UP_REQUEST, false, false,
  					                                    parentBridge,
        												{ window: DisplayObject(sm),
        												  parent:	o.parent,
        												  modal: o.modalWindow != null});
					realSm.getSandboxRoot().dispatchEvent(request);
				}
				else if (sm.useSWFBridge())
				{
					// Must be locally hosted popup.
					// We need to remove the placeholder at the top level root
					request = new SWFBridgeRequest(SWFBridgeRequest.REMOVE_POP_UP_PLACE_HOLDER_REQUEST, false, false, null,
																	{ window: DisplayObject(popUp)});
					request.requestor = sm.swfBridgeGroup.parentBridge;
					request.data.placeHolderId = NameUtil.displayObjectToString(DisplayObject(popUp));
					sm.dispatchEvent(request);
				}                    

                if (o.owner)
                {
                    o.owner.removeEventListener(FlexEvent.SHOW, showOwnerHandler);
                    o.owner.removeEventListener(FlexEvent.HIDE, hideOwnerHandler);
                }

                removeMouseOutEventListeners(o);
                
                // modal
                if (modalWindow)
                {
                    // clean up all handlers
                    realSm.removeEventListener(Event.RESIZE, o.resizeHandler);
                    
                    popUp.removeEventListener(FlexEvent.SHOW, popupShowHandler);
                    popUp.removeEventListener(FlexEvent.HIDE, popupHideHandler);
                    
                    hideModalWindow(o, true);
                    realSm.numModalWindows--;
                }

                popupInfo.splice(i, 1);
                break;
            }
        }
    }
    
 
    /**
     *  @private
     *  Show the modal window after the fade effect finishes
     */
    private function fadeInEffectEndHandler(event:EffectEvent):void
    {
        effectEndHandler(event);
        
        const n:int = popupInfo.length;
        for (var i:int = 0; i < n; i++)
        {
            var o:PopUpData = popupInfo[i];
            if (o.owner && o.modalWindow == event.effectInstance.target)
            {
                IUIComponent(o.owner).setVisible(true, true);
                break;
            }
        }
    }
    
    /**
     *  @private
     *  Remove the modal window after the fade effect finishes
     */
    private function fadeOutDestroyEffectEndHandler(event:EffectEvent):void
    {
        effectEndHandler(event);

        const obj:DisplayObject = DisplayObject(event.effectInstance.target);

        var modalMask:DisplayObject = obj.mask;
        if (modalMask)
        {
            // modal mask is always added to the popupChildren list.
            obj.mask = null;
            sm.popUpChildren.removeChild(modalMask);
        }   

        if (obj.parent is ISystemManager)
        {
            const sm:ISystemManager = ISystemManager(obj.parent)
            if (sm.popUpChildren.contains(obj))
                sm.popUpChildren.removeChild(obj);
            else
                sm.removeChild(obj);
        }
        else
		{
			if (obj.parent)	// Mustella can already take you off stage
				obj.parent.removeChild(obj);
		}
		
    }
    
    /**
     *  @private
     *  Remove the modal window after the fade effect finishes
     */
    private function fadeOutCloseEffectEndHandler(event:EffectEvent):void
    {
        effectEndHandler(event);
        DisplayObject(event.effectInstance.target).visible = false;
    }
    
    /**
     *  @private
     */
    private function effectEndHandler(event:EffectEvent):void
    {
        const n:int = popupInfo.length;
        for (var i:int = 0; i < n; i++)
        {
            var o:PopUpData = popupInfo[i];
            var e:IEffect = event.effectInstance.effect;
            
            if (e == o.fade)
                o.fade = null;
            else if (e == o.blur)
                o.blur = null;
        }
    }
    
    /**
     *  @private
     *  If not modal, use this kind of mouseDownOutside logic
     */
    private static function nonmodalMouseDownOutsideHandler(owner:DisplayObject, evt:MouseEvent):void
    {
        // shapeFlag is false here for performance reasons
        if (owner.hitTestPoint(evt.stageX, evt.stageY, true))
		{
		}
        else
		{
			if (owner is IUIComponent)
				if (IUIComponent(owner).owns(DisplayObject(evt.target)))
					return;

            dispatchMouseDownOutsideEvent(owner, evt);
		}
    }
    
    /**
     *  @private
     *  If not modal, use this kind of mouseWheelOutside logic
     */
    private static function nonmodalMouseWheelOutsideHandler(owner:DisplayObject, evt:MouseEvent):void
    {
        // shapeFlag is false here for performance reasons
        if (owner.hitTestPoint(evt.stageX, evt.stageY, true))
        {
		}
        else
		{
			if (owner is IUIComponent)
				if (IUIComponent(owner).owns(DisplayObject(evt.target)))
					return;

            dispatchMouseWheelOutsideEvent(owner, evt);
		}
    }
    
    /**
     *  @private
     *  This mouseWheelOutside handler just dispatches the event.
     */
    private static function dispatchMouseWheelOutsideEvent(owner:DisplayObject, evt:MouseEvent):void
    {
        // this is a modal window without a popup owner to dispatch the message to. 
        if (!owner)
            return;
            
        const event:MouseEvent = new FlexMouseEvent(FlexMouseEvent.MOUSE_WHEEL_OUTSIDE);
        const pt:Point = owner.globalToLocal(new Point(evt.stageX, evt.stageY));
        event.localX = pt.x;
        event.localY = pt.y;
        event.buttonDown = evt.buttonDown;
        event.shiftKey = evt.shiftKey;
        event.altKey = evt.altKey;
        event.ctrlKey = evt.ctrlKey;
        event.delta = evt.delta;
        event.relatedObject = InteractiveObject(evt.target);
        owner.dispatchEvent(event);
    }
    
    /**
     *  @private
     *  This mouseDownOutside handler just dispatches the event.
     */
    private static function dispatchMouseDownOutsideEvent(owner:DisplayObject, evt:MouseEvent):void
    {
        
        // this is a modal window without a popup owner to dispatch the message to. 
        if (!owner)
            return;
        
        const event:MouseEvent = new FlexMouseEvent(FlexMouseEvent.MOUSE_DOWN_OUTSIDE);
        const pt:Point = owner.globalToLocal(new Point(evt.stageX, evt.stageY));
        event.localX = pt.x;
        event.localY = pt.y;
        event.buttonDown = evt.buttonDown;
        event.shiftKey = evt.shiftKey;
        event.altKey = evt.altKey;
        event.ctrlKey = evt.ctrlKey;
        event.delta = evt.delta;
        event.relatedObject = InteractiveObject(evt.target);
        owner.dispatchEvent(event);
    }
    
}

}

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;
import flash.display.Stage;
import flash.geom.Point;

import mx.core.IUIComponent;
import mx.core.mx_internal;
import mx.effects.Effect;
import mx.events.SandboxMouseEvent;
import mx.managers.ISystemManager;
import mx.managers.PopUpManagerImpl;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: PopUpData
//
////////////////////////////////////////////////////////////////////////////////

/**
 *  @private
 */
class PopUpData
{
 
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function PopUpData()
    {
        super();
        useExclude = true;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     * 
     *  The popup in the normal case but will null in the case where only a 
     *  modal window is displayed over an application.
     */
    public var owner:DisplayObject;

    /**
     *  @private
     */
    public var parent:DisplayObject;

    /**
     *  @private
     */
    public var topMost:Boolean;

    /**
     *  @private
     */
    public var modalWindow:DisplayObject;

    /**
     *  @private
     */
    public var _mouseDownOutsideHandler:Function;

    /**
     *  @private
     */
    public var _mouseWheelOutsideHandler:Function;

    /**
     *  @private
     */
    public var fade:Effect;

    /**
     *  @private
     */
    public var blur:Effect;
    
    /**
     *  @private
     * 
     */
    public var blurTarget:Object;
     
    /**
     *   @private
     * 
     *   The host of the modal dialog.
     */
    public var systemManager:ISystemManager;
    
    //--------------------------------------
    //  fields only for remote modal windows
    //--------------------------------------

    /**
     *   @private
     * 
     *   Is this popup just a modal window for a popup 
     *   in an untrusted sandbox?
     */
    public var isRemoteModalWindow:Boolean;
    
    /**
     *   @private
     */
    public var modalTransparencyDuration:Number;
    
    /**
     *   @private
     */
    public var modalTransparency:Number;
    
    /**
     *   @private
     */
    public var modalTransparencyBlur:Number;
    
    /**
     *   @private
     */
    public var modalTransparencyColor:Number;
    
    /**
     *   @private
     * 
     *   Object to exclude from the modal dialog. The area of the 
     *   display object will be excluded from the modal dialog.
     */  
    public var exclude:IUIComponent;
    
    /**
     *   @private
     * 
     *   Flag to determine if the exclude property should be used
     *   or ignored. Typically the exclude field is used when a
     *   SystemManager contains its exclude child. But this isn't
     *   true when the child is in a pop up window. In this case
     *   useExclude is false.
     */  
    public var useExclude:Boolean;
     
    /**
     *   @private
     * 
     *   Rectangle to exclude from the <code>exclude</code> component
     *   which is in turn excluded from the modal dialog.
     *   This is passed within a sandbox so A.2 can tell A what
     *   the size of A.2.3 was. Each top-level application
     *   calculates excludeRect if there is mutual trust with its parent. 
     *   If there is no trust this property will be null.
     */  
    public var excludeRect:Rectangle;
     
    /**
     *   @private
     * 
     *   Mask created from the modalWindow and exclude fields.
     */  
    public var modalMask:Sprite;

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    public function mouseDownOutsideHandler(event:MouseEvent):void
    {
        _mouseDownOutsideHandler(owner, event);
    }

    /**
     *  @private
     */
    public function mouseWheelOutsideHandler(event:MouseEvent):void
    {
        _mouseWheelOutsideHandler(owner, event);
    }

    /**
     *  @private
     */
    public function marshalMouseOutsideHandler(event:Event):void
    {
        if (!(event is SandboxMouseEvent))
            event = SandboxMouseEvent.marshal(event);
            
        if (owner)
            owner.dispatchEvent(event);
    }

    /**
     *  @private
     *  Set by PopUpManager on modal windows to make sure they cover the whole screen
     */
    public function resizeHandler(event:Event):void
    {
        // Resize the modal window if either the popup or the modal window are on the
        // same stage as the resize event target.
        // A modal window may have no popup in the case where the popup originated
        // from an untrusted application.
        if ((owner && owner.stage == DisplayObject(event.target).stage) ||
            (modalWindow && modalWindow.stage == DisplayObject(event.target).stage))
        {
            var s:Rectangle = systemManager.screen;  
        
            modalWindow.width = s.width;
            modalWindow.height = s.height;
            modalWindow.x = s.x;
            modalWindow.y = s.y;
            if (modalMask)
                PopUpManagerImpl.mx_internal::updateModalMask(systemManager, modalWindow, 
                                                              exclude, excludeRect, modalMask);    
        }
    }
}
