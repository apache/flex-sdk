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

import spark.components.Application;
import spark.components.View;
import spark.components.ViewMenu;
import spark.components.ViewMenuItem;
import spark.core.managers.IPersistenceManager;
import spark.core.managers.PersistenceManager;
import spark.events.PopUpCloseEvent;

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
 *  Dispatched after the application state data has been written
 *  to the application's persistence manager.  This event is only 
 *  dispatched if the <code>sessionCachingEnabled</code>
 *  property is set to true on the application.
 * 
 *  @eventType mx.events.FlexEvent.APPLICATION_PERSIST
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="applicationPersist", type="mx.events.FlexEvent")]

/**
 *  This cancelable event dispatched before the application attempts
 *  to persist its state when the application being suspended or exitted.
 *  Calling <code>preventDefault</code> on this event will prevent the
 *  application state from being saved.
 * 
 *  @eventType mx.events.FlexEvent.APPLICATION_PERSISTING
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="applicationPersisting", type="mx.events.FlexEvent")]

/**
 *  Dispatched after the application state data has been restored
 *  from disk by the application's persistence manager.  At the point
 *  this event is dispatched, all data related to the application state
 *  should be valid.  This event is only dispatched if the 
 *  <code>sessionCachingEnabled</code> property is set to true when
 *  the application is initialized.
 * 
 *  @eventType mx.events.FlexEvent.APPLICATION_RESTORE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="applicationRestore", type="mx.events.FlexEvent")]

/**
 *  This cancelable event dispatched before the application attempts
 *  to restore its previously saved state when the application is being 
 *  launched.  Calling <code>preventDefault</code> on this event will 
 *  prevent the application state from being restored.
 * 
 *  @eventType mx.events.FlexEvent.APPLICATION_RESTORING
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="applicationRestoring", type="mx.events.FlexEvent")]

/**
 *  The base application class used for all view based application types.
 *  This includes MobileApplication and TabbedMobileApplication.  This class
 *  provides the basic infrastructure for providing these types of applications
 *  access to the device application menu, hardware keys, orientation status
 *  and application session persistence.
 *  
 *  @see spark.components.MobileApplication
 *  @see spark.components.TabbedMobileApplication
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class MobileApplicationBase extends Application
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
     *  Provides access to the active view of the current navigator. This was
     *  added to provide the ViewMenu access to the active view's viewMenuItems 
     *  property.
     */ 
    mx_internal function get activeView():View
    {
        return null;
    }
    
    /**
     *  @private
     *  This flag indicates when a user has called preventDefault on the
     *  KeyboardEvent dispatched when the back key is pressed.
     */
    private var backKeyEventPreventDefaulted:Boolean = false;
    
    /**
     *  @private
     */
    private var currentViewMenu:ViewMenu;
    
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
     *  @private
     */ 
    private var lastFocus:InteractiveObject;
    
    /**
     *  @private
     *  This flag indicates when a user has called preventDefault on the
     *  KeyboardEvent dispatched when the menu key is pressed.
     */
    private var menuKeyEventPreventDefaulted:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  persistenceManager
    //----------------------------------
    private var _persistenceManager:IPersistenceManager;
    
    /**
     *  The persistenceManager for the application.  The persistence
     *  manager is automatically created on demand when accessed for the
     *  first time.  Override the <code>createPersistenceManager()</code>
     *  method to change the type of persistence manager that is created.
     * 
     *  <p>The persistence manager will automatically save and restore
     *  the main navigator's persistence stack if the
     *  <code>sessionCachingEnabled</code> flag is set to true. Data stored 
     *  in the persistence manager will automatically be flushed to disk 
     *  when the application is suspended or exited.</p>
     *  
     *  <p>The default implementation of the persistence manager uses
     *  a shared object as it's backing data store.  All information that is
     *  saved to this object must adhere to flash AMF rules for object encoding.
     *  This means that custom classes will need to be registered through the use
     *  of <code>flash.net.registerClassAlias</code></p>
     * 
     *  @default Instance of a spark.core.managers.PersistenceManager
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
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
     *  Toggles the application session caching feature for the application.  When
     *  enabled, the application will automatically save the main navigator's view 
     *  data and navigation history to the persistence manager.  When the application 
     *  is relaunched, this data will automatically be read from the persistence store
     *  and applied to the application's navigator.
     * 
     *  <p>When enabled, the application version and time the persistence data was 
     *  generated will also be added to the persistence object.  These can be
     *  accessed by using the persistence manager's <code>getProperty()</code> method
     *  using either the <code>applicationVersion</code> or <code>timestamp</code> key.</p>
     * 
     *  <p>When the persistence object is being created, the application will dispatch
     *  a cancelable <code>FlexEvent.APPLICATION_PERSISTING</code> event when the process
     *  begins and a <code>FlexEvent.APPLICATION_PERSIST</code> event when it completes.  
     *  If the APPLICATION_PERSISTING event is canceled, the persistence object is not created.
     *  Similarily, when this information is being restored to the application, a cancelable
     *  <code>FlexEvent.APPLICATION_RESTORING</code> is dispatched followed by a
     *  <code>FlexEvent.APPLICATION_RESTORE</code> event.  Canceling the APPLICATION_RESTORING
     *  event will prevent the navigation data from being restored.</p>
     * 
     *  <p>The <code>sessionCachingEnabled</code> flag must be set to true before
     *  the application initializes itself for the navigator's state to be automatically
     *  restored.</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
    
    //----------------------------------
    //  viewMenuOpen
    //----------------------------------
    
    /**
     *  Opens the view menu if set to true and closes it if set to false. 
     * 
     *  @default false
     */
    public function get viewMenuOpen():Boolean
    {
        return currentViewMenu && currentViewMenu.opened;
    }
    
    /**
     *  @private
     */ 
    public function set viewMenuOpen(value:Boolean):void
    {
        if (value == viewMenuOpen)
            return;
        
        if (!viewMenu || !activeView.viewMenuItems || activeView.viewMenuItems.length == 0)
            return;
        
        if (value)
            openViewMenu();
        else
            closeViewMenu();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
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
     *  sent to the background by the OS.  If <code>sessionCachingEnabled</code>
     *  is set to true, the application will begin the state saving process
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
     *  This method is called when the Application's hardware back key is pressed
     *  by the user.
     *   
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected function backKeyHandler(event:KeyboardEvent):void
    {
        
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
        if (activeView && !activeView.menuKeyHandledByView())
            viewMenuOpen = !viewMenuOpen;
    }
    
    /**
     *  Method is responsible for create the persistence manager for the application.
     *  This method will automatically be called when the persistence manager is
     *  accessed for the first time or if the <code>sessionCachingEnabled</code> flag
     *  is set to true on the application.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function createPersistenceManager():IPersistenceManager
    {
        return new PersistenceManager();
    }
    
    /**
     *  Responsible for persisting the application state to the persistence manager.
     *  This method is automatically called when <code>sessionCachingEnabled</code>
     *  is set to true.  By default, this method will save the application version 
     *  and the time the persistence object was created to the "timestamp" and 
     *  "applicationVersion" keys.
     * 
     *  <p>This method will only be called if the <code>FlexEvent.APPLICATION_PERSISTING</code>
     *  event is not canceled.</p>
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
        
        persistenceManager.setProperty("applicationVersion", 
                                        appDescriptor.ns::versionNumber.toString());
    }
    
    /**
     *  Method is responsible for registering the class types that may be
     *  saved to a persistence manager that uses a shared object as its data store.  
     *  Since shared objects use the standard AMF encoding rules, custom class types
     *  must be registered with the runtime so that they are properly read in.  This 
     *  method is called before the persistence manager is initialized so that the 
     *  application has a chance to use <code>flash.net.registerClassAlias()</code> 
     *  before the persistence data is loaded.
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
     *  Responsible for restoring the application's state when the
     *  <code>sessionCachingEnabled</code> flag is set to true.
     * 
     *  <p>This method will only be called if the <code>FlexEvent.APPLICATION_RESTORING</code>
     *  event is not canceled.</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected function restoreApplicationState():void
    {
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
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
        
        // FIXME (chiedozi): enumerate all possible os values
        if (os.indexOf("Windows") != -1 || os.indexOf("Mac OS") != -1)
            NativeApplication.nativeApplication.
                addEventListener(Event.EXITING, nativeApplication_deactivateHandler);
        else
            NativeApplication.nativeApplication.
                addEventListener(Event.DEACTIVATE, nativeApplication_deactivateHandler);
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
            backKeyHandler(event);
        else if (key == Keyboard.MENU && !menuKeyEventPreventDefaulted)
            menuKeyHandler(event);
    }
    
    /**
     *  @private
     */  
    private function orientationChangeHandler(event:StageOrientationEvent):void
    {   
        if (currentViewMenu)
        {
            // Update size, the position stays at (0,0)
            currentViewMenu.width = getLayoutBoundsWidth();
            currentViewMenu.height = getLayoutBoundsHeight();
        }
    } 

    /**
     *  @private
     */ 
    private function viewMenu_clickHandler(event:MouseEvent):void
    {
        if (event.target is ViewMenuItem)
            viewMenuOpen = false;
    }
    
    /**
     *  @private
     */ 
    private function viewMenu_mouseDownOutsideHandler(event:FlexMouseEvent):void
    {
        viewMenuOpen = false;
    }
    
    /**
     *  @private
     */ 
    private function openViewMenu():void
    {
        if (!currentViewMenu)
        {
            currentViewMenu = ViewMenu(viewMenu.newInstance());
            currentViewMenu.items = activeView.viewMenuItems;
            
            // Size the menu as big as the app
            currentViewMenu.width = getLayoutBoundsWidth();
            currentViewMenu.height = getLayoutBoundsHeight();
            
            // Remember the focus, we'll restore it when the menu closes
            lastFocus = getFocus();
            currentViewMenu.setFocus();
            
            currentViewMenu.addEventListener(MouseEvent.CLICK, viewMenu_clickHandler);
            currentViewMenu.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, viewMenu_mouseDownOutsideHandler);
            currentViewMenu.addEventListener(PopUpCloseEvent.CLOSE, viewMenuClose_handler);
            currentViewMenu.addEventListener(FlexEvent.OPEN, viewMenuOpen_handler);
            addEventListener(ResizeEvent.RESIZE, resizeHandler);
        }
        
        currentViewMenu.open(this, false /*modal*/);
    }

    /**
     *  @private
     */ 
    private function closeViewMenu():void
    {
        if (currentViewMenu)
            currentViewMenu.close();
    }
    
    /**
     *  @private
     */ 
    private function viewMenuOpen_handler(event:FlexEvent):void
    {
        // Private event for testing
        if (activeView.hasEventListener("viewMenuOpen"))
            activeView.dispatchEvent(new Event("viewMenuOpen"));
    }

    /**
     *  @private
     */ 
    private function viewMenuClose_handler(event:PopUpCloseEvent):void
    {
        currentViewMenu.removeEventListener(FlexEvent.OPEN, viewMenuOpen_handler);
        currentViewMenu.removeEventListener(PopUpCloseEvent.CLOSE, viewMenuClose_handler);
        currentViewMenu.removeEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, viewMenu_mouseDownOutsideHandler);
        currentViewMenu.removeEventListener(MouseEvent.CLICK, viewMenu_clickHandler);
        removeEventListener(ResizeEvent.RESIZE, resizeHandler);
        
        // Private event for testing
        if (activeView.hasEventListener("viewMenuClose"))
            activeView.dispatchEvent(new Event("viewMenuClose"));
        
        // Clear the caret and validate properties to put back the viewMenu items
        // in their default state so that next time we open the menu we don't
        // see an item in a stale "caret" state.
        currentViewMenu.caretIndex = -1;
        currentViewMenu.validateProperties();
        
        currentViewMenu.items = null;
        currentViewMenu = null;
        
        // Restore focus
        systemManager.stage.focus = lastFocus;
    }
    
    private function resizeHandler(event:ResizeEvent):void
    {
        // Size the menu as big as the app
        currentViewMenu.width = getLayoutBoundsWidth();
        currentViewMenu.height = getLayoutBoundsHeight();
        currentViewMenu.invalidateSkinState();
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







