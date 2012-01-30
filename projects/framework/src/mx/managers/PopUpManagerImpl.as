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
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.Stage;
import flash.utils.Proxy;

import mx.automation.IAutomationObject;
import mx.containers.Canvas;
import mx.controls.Alert;
import mx.core.FlexGlobals;
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
import mx.events.DynamicEvent;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.events.FlexMouseEvent;
import mx.events.MoveEvent;
import mx.events.Request;
import mx.managers.ISystemManager;
import mx.managers.SystemManager;
import mx.managers.systemClasses.ActiveWindowManager;
import mx.styles.IStyleClient;
import mx.utils.NameUtil;
import mx.core.UIComponent;

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
public class PopUpManagerImpl extends EventDispatcher implements IPopUpManager
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
    
	/**
	 * @private
	 * 
	 * Place to hook in additional classes
	 */
	public static var mixins:Array;

    mx_internal static var popUpInfoClass:Class;

	mx_internal static function createPopUpData():PopUpData
    {
        if (!popUpInfoClass)
            return new PopUpData();
        return new popUpInfoClass() as PopUpData;
    }

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static function weakDependency():void { ActiveWindowManager };
    
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

		if (mixins)
		{
			var n:int = mixins.length;
			for (var i:int = 0; i < n; i++)
			{
				new mixins[i](this);
			}
		}

        if (hasEventListener("initialize"))
    		dispatchEvent(new Event("initialize"));
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
    mx_internal var popupInfo:Array = [];

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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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

        // smp is the actual systemManager that will parent the popup
        // it might get changed by the request
        var smp:ISystemManager = sm;

        if (hasEventListener("addPopUp"))
        {
            var request:Request = new Request("addPopUp", false, true, { parent: parent, sm: sm, modal: modal, childList: childList} );
            if (!dispatchEvent(request))
                smp = request.value as ISystemManager;
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
        
        const o:PopUpData = createPopUpData();
        o.owner = DisplayObject(window);
        o.topMost = topMost;
        o.systemManager = smp;
        popupInfo.push(o);

        var awm:IActiveWindowManager = 
              IActiveWindowManager(smp.getImplementation("mx.managers::IActiveWindowManager"));

        if (window is IFocusManagerContainer)
        {
            if (IFocusManagerContainer(window).focusManager)
            {
                awm.addFocusManager(IFocusManagerContainer(window));
            }
            else
                // Popups get their own focus loop
                IFocusManagerContainer(window).focusManager =
                    new FocusManager(IFocusManagerContainer(window), true);
        }

        if (hasEventListener("addPlaceHolder"))
        {
            var event:DynamicEvent = new DynamicEvent("addPlaceHolder");
            event.sm = sm;
            event.window = window;
            dispatchEvent(event);
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
            createModalWindow(parent, o, children, visibleFlag, smp, smp.getSandboxRoot());
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
            if (hasEventListener("addedPopUp"))
            {
                event = new DynamicEvent("addedPopUp", false, true);
                event.window = window;
                event.systemManager = smp;
                dispatchEvent(event);
            }
            else
                awm.activate(IFocusManagerContainer(window));
        }

        // trace("END POPUP: addPopUp" + parent);
    }


	mx_internal function getTopLevelSystemManager(parent:DisplayObject):ISystemManager
	{
	    var localRoot:DisplayObjectContainer;
		var sm:ISystemManager;
	
        if (hasEventListener("topLevelSystemManager"))
        {
		    var request:Request = new Request("topLevelSystemManager", false, true);
		    request.value = parent;
		    if (!dispatchEvent(request))
		        localRoot = request.value as DisplayObjectContainer;
        }
		if (!localRoot)
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
            var rect:Rectangle;
            var clippingOffset:Point = new Point();
            var pt:Point;
            var isTopLevelRoot:Boolean;
            var sbRoot:DisplayObject = systemManager.getSandboxRoot();

            var request:Request;
            if (hasEventListener("isTopLevelRoot"))
            {
    			request = new Request("isTopLevelRoot", false, true);
            }
			if (request && !dispatchEvent(request))
				isTopLevelRoot = Boolean(request.value);
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function bringToFront(popUp:IFlexDisplayObject):void
    {
        if (popUp && popUp.parent)
        {
            const o:PopUpData = findPopupInfoByOwner(popUp);
            if (o)
            {
                if (hasEventListener("bringToFront"))
                {
				    var dynamicEvent:DynamicEvent = new DynamicEvent("bringToFront", false, true);
				    dynamicEvent.popUpData = o;
				    dynamicEvent.popUp = popUp;
				    if (!dispatchEvent(dynamicEvent))
					    return;
                }
                const sm:ISystemManager = ISystemManager(popUp.parent);
                if (o.topMost)
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
    mx_internal function createModalWindow(parentReference:DisplayObject,
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

		var awm:IActiveWindowManager = 
			IActiveWindowManager(sm.getImplementation("mx.managers::IActiveWindowManager"));
    	awm.numModalWindows++;

        // Add it to the collection just below the popup
        if (popup)
            childrenList.addChildAt(modalWindow,
                childrenList.getChildIndex(DisplayObject(popup)));
        else 
            childrenList.addChild(modalWindow);
        
        // force into the automation hierarchy
        if (popup is IAutomationObject)
            IAutomationObject(popup).showInAutomationHierarchy = true;
        
        o.modalWindow = modalWindow;

        if (popupStyleClient)
            modalWindow.alpha = popupStyleClient.getStyle("modalTransparency");
		else
			modalWindow.alpha = 0;
		
        modalWindow.tabEnabled = false;
        
        const s:Rectangle = sm.screen;
        const g:Graphics = modalWindow.graphics;
        
        var c:Number = 0xFFFFFF;
        if (popupStyleClient)
        {
            c = popupStyleClient.getStyle("modalTransparencyColor");
        }
        
        if (hasEventListener("createModalWindow"))
        {
		    var dynamicEvent:DynamicEvent = new DynamicEvent("createModalWindow", false, true);
		    dynamicEvent.popUpData = o;
		    dynamicEvent.popUp = popup;
		    dynamicEvent.color = c;
            dynamicEvent.visibleFlag = visibleFlag;
		    dynamicEvent.childrenList = childrenList;
		    if (!dispatchEvent(dynamicEvent))
			    c = dynamicEvent.color;
        }

        // trace("createModalWindow: drawing modal " + s);
        g.clear();
        g.beginFill(c, 100);
        g.drawRect(s.x, s.y, s.width, s.height);
        g.endFill();

        if (hasEventListener("updateModalMask"))
        {
		    dynamicEvent = new DynamicEvent("updateModalMask");
		    dynamicEvent.popUpData = o;
		    dynamicEvent.popUp = popup;
		    dynamicEvent.childrenList = childrenList;
		    dispatchEvent(dynamicEvent);
        }

        // a modal mousedownoutside handler just dispatches the event
        o._mouseDownOutsideHandler  = dispatchMouseDownOutsideEvent;
        o._mouseWheelOutsideHandler = dispatchMouseWheelOutsideEvent;
        
        // the following handlers all get removed in REMOVED on the popup
        
        // Set the resize handler so the modal can stay the size of the screen
       	sm.addEventListener(Event.RESIZE, o.resizeHandler);

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

        if (hasEventListener("createdModalWindow"))
        {
		    dynamicEvent = new DynamicEvent("createdModalWindow");
		    dynamicEvent.popUpData = o;
		    dynamicEvent.popUp = popup;
            dynamicEvent.visibleFlag = visibleFlag;
		    dynamicEvent.childrenList = childrenList;
		    dispatchEvent(dynamicEvent);
        }
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
    
    mx_internal function showModalWindow(o:PopUpData, sm:ISystemManager, sendRequest:Boolean = true):void
    {
    	const popUpStyleClient:IStyleClient = o.owner as IStyleClient;
        var duration:Number = 0;
        var alpha:Number = 0;
        
        if (popUpStyleClient)
        {
            duration = popUpStyleClient.getStyle("modalTransparencyDuration");
        }
        
        if (popUpStyleClient)
        {
            alpha = popUpStyleClient.getStyle("modalTransparency");
        }
            
	    var blurAmount:Number = 0;
	    
	    if (popUpStyleClient)
	    {
	    	blurAmount = popUpStyleClient.getStyle("modalTransparencyBlur");
	    }

		var transparencyColor:Number = 0xFFFFFF;
	    if (popUpStyleClient)
	    {
	    	transparencyColor = popUpStyleClient.getStyle("modalTransparencyColor");
	    }
   
        var sbRoot:DisplayObject = sm.getSandboxRoot();

        if (hasEventListener("showModalWindow"))
        {
		    var dynamicEvent:DynamicEvent = new DynamicEvent("showModalWindow", false, true);
		    dynamicEvent.popUpData = o;
		    dynamicEvent.sendRequest = sendRequest;
		    dynamicEvent.alpha = alpha;
		    dynamicEvent.blurAmount = blurAmount;
		    dynamicEvent.duration = duration;
            dynamicEvent.systemManager = sm;
		    dynamicEvent.transparencyColor = transparencyColor;
		    if (!dispatchEvent(dynamicEvent))
		    {
			    alpha = dynamicEvent.alpha;
			    blurAmount = dynamicEvent.blurAmount;
			    duration = dynamicEvent.duration;
			    transparencyColor = dynamicEvent.transparencyColor;
		    }
        }
		o.modalWindow.alpha = alpha;
			
        showModalWindowInternal(o, duration, alpha, transparencyColor, blurAmount, sm, sbRoot);
        
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
                    var sbRootApp:Object;   // sbRoot.application;

                    if (hasEventListener("blurTarget"))
                    {
				        var request:Request = new Request("blurTarget", false, true, { popUpData: o });
                        if (!dispatchEvent(request))
                        {
					        o.blurTarget = request.value;
                        }
                    }
                }
				else
                    o.blurTarget = FlexGlobals.topLevelApplication;

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
    mx_internal function hideModalWindow(o:PopUpData, destroy:Boolean = false):void
    {
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
        
        if (hasEventListener("hideModalWindow"))
        {
		    var dynamicEvent:DynamicEvent = new DynamicEvent("hideModalWindow", false, false);
		    dynamicEvent.popUpData = o;
		    dynamicEvent.destroy = destroy;
		    dispatchEvent(dynamicEvent);
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
        
        if (hasEventListener("addMouseOutEventListeners"))
        {
		    var dynamicEvent:DynamicEvent = new DynamicEvent("addMouseOutEventListeners", false, false);
		    dynamicEvent.popUpData = o;
		    dispatchEvent(dynamicEvent);
        }
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

        if (hasEventListener("removeMouseOutEventListeners"))
        {
		    var dynamicEvent:DynamicEvent = new DynamicEvent("removeMouseOutEventListeners", false, false);
		    dynamicEvent.popUpData = o;
		    dispatchEvent(dynamicEvent);
        }
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
                
				if (!sm.isTopLevel())
					sm = sm.topLevelSystemManager;

                if (popUp is IUIComponent)
                    IUIComponent(popUp).isPopUp = false;
                
				var awm:IActiveWindowManager = 
					IActiveWindowManager(sm.getImplementation("mx.managers::IActiveWindowManager"));
                if (popUp is IFocusManagerContainer)
				{
                    awm.removeFocusManager(IFocusManagerContainer(popUp));
				}
                
                popUp.removeEventListener(Event.REMOVED,  popupRemovedHandler);

                if (hasEventListener("removeMouseOutEventListeners"))
                {
				    var event2:DynamicEvent = new DynamicEvent("popUpRemoved");
				    event2.popUpData = o;
                    dispatchEvent(event2);
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
                    sm.removeEventListener(Event.RESIZE, o.resizeHandler);
                    
                    popUp.removeEventListener(FlexEvent.SHOW, popupShowHandler);
                    popUp.removeEventListener(FlexEvent.HIDE, popupHideHandler);
                    
                    hideModalWindow(o, true);
    				awm.numModalWindows--;
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
