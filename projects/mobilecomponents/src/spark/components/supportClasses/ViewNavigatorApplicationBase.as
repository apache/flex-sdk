////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.supportClasses
{
import flash.desktop.NativeApplication;
import flash.display.InteractiveObject;
import flash.display.StageOrientation;
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.StageOrientationEvent;
import flash.system.Capabilities;
import flash.ui.Keyboard;

import mx.core.IFactory;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.FlexMouseEvent;
import mx.events.ResizeEvent;
import mx.managers.PopUpManager;

import spark.components.Application;
import spark.components.View;
import spark.components.ViewMenu;
import spark.components.ViewMenuItem;
import spark.core.managers.IPersistenceManager;
import spark.core.managers.PersistenceManager;

[Exclude(name="controlBarContent", kind="property")]
[Exclude(name="controlBarGroup", kind="property")]
[Exclude(name="controlBarLayout", kind="property")]
[Exclude(name="controlBarVisible", kind="property")]
[Exclude(name="layout", kind="property")]
[Exclude(name="preloaderChromeColor", kind="property")]
[Exclude(name="backgroundAlpha", kind="style")]

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  
 */
[Event(name="applicationPersist", type="mx.events.FlexEvent")]

/**
 *  
 */
[Event(name="applicationPersisting", type="mx.events.FlexEvent")]

/**
 *  
 */
[Event(name="applicationRestore", type="mx.events.FlexEvent")]

/**
 *  
 */
[Event(name="applicationRestoring", type="mx.events.FlexEvent")]

/**
 * 
 */
public class MobileApplicationBase extends Application
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    /**
     *
     */ 
    public function MobileApplicationBase()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    [SkinPart(required="false")]
    /**
     *  Dynamic skin part that defines the ViewMenu used to display the
     *  view menu when the menu button is pressed. The default skin uses 
     *  a factory that generates an ViewMenu instance. 
     */ 
    public var viewMenu:IFactory;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  This flag indicates when a user has called preventDefault on the
     *  KeyboardEvent dispatched when the back key is pressed.
     */
    private var backKeyEventPreventDefaulted:Boolean = false;
    
    /**
     *  @private
     *  This flag indicates when a user has called preventDefault on the
     *  KeyboardEvent dispatched when the menu key is pressed.
     */
    private var menuKeyEventPreventDefaulted:Boolean = false;
    
    private var currentViewMenu:ViewMenu; 
    private var lastFocus:InteractiveObject;
    
    //----------------------------------
    //  activeView
    //----------------------------------
    
    /**
     *  @private
     */ 
    mx_internal function get activeView():View
    {
        return null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    private var _viewMenuOpen:Boolean = false;
    
    /**
     *  Opens the view menu if set to true and closes it if set to false. 
     * 
     *  @default false
     */
    public function get viewMenuOpen():Boolean
    {
        return _viewMenuOpen;
    }
    
    public function set viewMenuOpen(value:Boolean):void
    {
        if (value == _viewMenuOpen)
            return;
        
        if (!viewMenu || !activeView.viewMenuItems || activeView.viewMenuItems.length == 0)
            return;
        
        _viewMenuOpen = value;
        
        if (_viewMenuOpen)
            openViewMenu();
        else
            closeViewMenu();
    }
    
    //----------------------------------
    //  persistenceManager
    //----------------------------------
    private var _persistenceManager:IPersistenceManager;
    
    /**
     *  
     */
    // FIXME (chiedozi): PARB whether this should be a method or a getter because of side effect
    public function get persistenceManager():IPersistenceManager
    {
        if (!_persistenceManager)
        {
            registerPersistenceClassAliases();
            _persistenceManager = createPersistenceManager();
        }
        
        return _persistenceManager;
    }
    
    //----------------------------------
    //  sessionCachingEnabled
    //----------------------------------
    
    private var _sessionCachingEnabled:Boolean = false;
    
    /**
     *  
     */
    public function get sessionCachingEnabled():Boolean
    {
        return _sessionCachingEnabled;
    }
    
    /**
     * @private
     */ 
    public function set sessionCachingEnabled(value:Boolean):void
    {
        _sessionCachingEnabled = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    private function addApplicationListeners():void
    {
        // Add device event listeners
        systemManager.stage.addEventListener(KeyboardEvent.KEY_DOWN, deviceKeyDownHandler);
        systemManager.stage.addEventListener(KeyboardEvent.KEY_UP, deviceKeyUpHandler);
        systemManager.stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, 
                                             orientationChangeHandler);
        NativeApplication.nativeApplication.
            addEventListener(InvokeEvent.INVOKE, nativeApplication_invokeHandler);
        
        // We need to listen to different events on desktop and mobile because
        // on desktop, the deactivate event is dispatched whenever the window loses
        // focus.  This could cause persistence to run when the developer doesn't
        // expect it to on desktop.
        var os:String = Capabilities.os;
        
        if (os.indexOf("Windows") != -1 || os.indexOf("Mac OS") != -1)
            NativeApplication.nativeApplication.
                addEventListener(Event.EXITING, nativeApplication_deactivateHandler);
        else
            NativeApplication.nativeApplication.
                addEventListener(Event.DEACTIVATE, nativeApplication_deactivateHandler);
    }
    
    /**
     *  This method is called when the application is invoked by the
     *  OS.  This method is called in response to a InvokeEvent.INVOKE
     *  event.
     * 
     *  @param event The InvokeEvent object
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */  
    protected function nativeApplication_invokeHandler(event:InvokeEvent):void
    {
    }
    
    /**
     *  This method is called when the application is exiting or being
     *  sent to the background by the OS.  If sessionCachingEnabled is
     *  set to true, the application will begin the state saving process
     *  here.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected function nativeApplication_deactivateHandler(event:Event):void
    {
        // Check if the application state should be persisted 
        if (sessionCachingEnabled)
        {
            // Dispatch event for saving persistence data
            var eventCanceled:Boolean = false;
            if (hasEventListener(FlexEvent.APPLICATION_PERSISTING))
                eventCanceled = !dispatchEvent(new FlexEvent(FlexEvent.APPLICATION_PERSISTING, 
                                                                false, true));
            
            if (!eventCanceled)
            {
                persistApplicationState();
                
                if (hasEventListener(FlexEvent.APPLICATION_PERSIST))
                    dispatchEvent(new FlexEvent(FlexEvent.APPLICATION_PERSIST));
            }
        }

        // Always flush the persistence manager to disk if it exists
        if (_persistenceManager)
        {
            persistenceManager.flush();
        }
    }
    
    /**
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected function backKeyHandler():void
    {
        
    }
    
    /**
     *  @private
     *  This property is used to determine whether the application should 
     *  exit when the back key is pressed.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    mx_internal function get exitApplicationOnBackKey():Boolean
    {
        return true;   
    }
    
    /**
     *  Called when the menu key is pressed. By default, this opens or closes
     *  the ViewMenu. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected function menuKeyHandler(event:KeyboardEvent):void
    {
        viewMenuOpen = !viewMenuOpen;
    }
    
    /**
     *  @private
     */
    // FIXME (chiedozi): Maybe use a singleton for persistence, PARB (GLENN)
    protected function createPersistenceManager():IPersistenceManager
    {
        return new PersistenceManager();
    }
    
    /**
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */  
    private function orientationChangeHandler(event:StageOrientationEvent):void
    {   
        if (viewMenuOpen)
        {
            // Change the width
            // Reposition
            currentViewMenu.width = getLayoutBoundsWidth();
            
            
            currentViewMenu.validateNow();
            
            currentViewMenu.x = 0;
            currentViewMenu.y = Math.ceil(getLayoutBoundsHeight() - currentViewMenu.getLayoutBoundsHeight());
        }
    } 
    
    /**
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected function persistApplicationState():void
    {
        // Save version number of application
        var appDescriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
        var ns:Namespace = appDescriptor.namespace();
        
        // TODO (chiedozi): See if reserving these keys is bad
        persistenceManager.setProperty("timestamp", new Date().getTime());
        persistenceManager.setProperty("applicationVersion", 
                                        appDescriptor.ns::versionNumber.toString());
    }
    
    /**
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected function registerPersistenceClassAliases():void
    {
    }
    
    /**
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected function restoreApplicationState():void
    {
    }
    
    /**
     *  @private
     */ 
    private function deviceKeyDownHandler(event:KeyboardEvent):void
    {
        var key:uint = event.keyCode;
        
        // We want to prevent the default down behavior for back key if 
        // the navigator has a view to pop back to
        if (key == Keyboard.BACK)
        {
            backKeyEventPreventDefaulted = event.isDefaultPrevented();
            
            if (!exitApplicationOnBackKey)
                event.preventDefault();
        }
        else if (key == Keyboard.MENU)
        {
            menuKeyEventPreventDefaulted = event.isDefaultPrevented();
            
            if (menuKeyEventPreventDefaulted)
                event.preventDefault();
        }
        
    }
    
    /**
     *  @private
     */ 
    private function deviceKeyUpHandler(event:KeyboardEvent):void
    {
        var key:uint = event.keyCode;

        // If preventDefault() wasn't called on the initial keyDown event
        // and the application thinks it can cancel the native back behavior,
        // call the backKeyHandler() method.  Otherwise, the runtime will
        // handle the back key function.
        
        // The backKeyEventPreventDefaulted key is always set in the
        // deviceKeyDownHandler method and so doesn't need to be reset.
        if (key == Keyboard.BACK && !backKeyEventPreventDefaulted && !exitApplicationOnBackKey)
            backKeyHandler();
        else if (key == Keyboard.MENU && !menuKeyEventPreventDefaulted)
            menuKeyHandler(event);
    }
    
    private function viewMenu_clickHandler(event:MouseEvent):void
    {
        if (event.target is ViewMenuItem)
            viewMenuOpen = false;
    }
    
    private function viewMenu_mouseDownOutsideHandler(event:FlexMouseEvent):void
    {
        viewMenuOpen = false;
    }
    
    private function viewMenu_resizeHandler(event:ResizeEvent):void
    {
        // Reposition the view menu?
        currentViewMenu.y = Math.ceil(getLayoutBoundsHeight() - currentViewMenu.getLayoutBoundsHeight());
    }
    
    private function openViewMenu():void
    {
        currentViewMenu = ViewMenu(viewMenu.newInstance());
        currentViewMenu.items = activeView.viewMenuItems;
        currentViewMenu.owner = this;
        currentViewMenu.addEventListener(MouseEvent.CLICK, viewMenu_clickHandler);
        currentViewMenu.width = getLayoutBoundsWidth();
        
        PopUpManager.addPopUp(currentViewMenu, this, true);   
        // Force a layout pass so we can properly position the viewMenu
        currentViewMenu.validateNow();
        
        currentViewMenu.x = 0;
        currentViewMenu.y = Math.ceil(getLayoutBoundsHeight() - currentViewMenu.getLayoutBoundsHeight());
        
        lastFocus = getFocus();
        
        currentViewMenu.setFocus();
        currentViewMenu.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, viewMenu_mouseDownOutsideHandler);
        
        // Listen for resize if the icon is loaded from disk or via URL
        currentViewMenu.addEventListener(ResizeEvent.RESIZE, viewMenu_resizeHandler);
        
        // Private event for testing
        if (activeView.hasEventListener("viewMenuOpen"))
            activeView.dispatchEvent(new Event("viewMenuOpen"));
    }
    
    private function closeViewMenu():void
    {
        currentViewMenu.removeEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, viewMenu_mouseDownOutsideHandler);
        PopUpManager.removePopUp(currentViewMenu);
        
        // Private event for testing
        if (activeView.hasEventListener("viewMenuClose"))
            activeView.dispatchEvent(new Event("viewMenuClose"));
        
        currentViewMenu.caretIndex = -1;
        currentViewMenu.validateProperties();
        currentViewMenu.removeEventListener(MouseEvent.CLICK, viewMenu_clickHandler);
        currentViewMenu.removeEventListener(ResizeEvent.RESIZE, viewMenu_resizeHandler);
        currentViewMenu.items = null;
        currentViewMenu = null;
        
        systemManager.stage.focus = lastFocus;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     */ 
    override public function initialize():void
    {
        super.initialize();
        
        addApplicationListeners();
        
        if (sessionCachingEnabled)
        {
            registerPersistenceClassAliases();
            
            persistenceManager.initialize();
            
            // Dispatch event for loading persistence data
            var eventDispatched:Boolean = true;
            if (hasEventListener(FlexEvent.APPLICATION_RESTORING))
                eventDispatched = dispatchEvent(new FlexEvent(FlexEvent.APPLICATION_RESTORING, 
                                                false, true));
            
            if (eventDispatched)
            {
                restoreApplicationState();
                
                if (hasEventListener(FlexEvent.APPLICATION_RESTORE))
                    eventDispatched = dispatchEvent(new FlexEvent(FlexEvent.APPLICATION_RESTORE));
            }
        } 
    }
}
}







