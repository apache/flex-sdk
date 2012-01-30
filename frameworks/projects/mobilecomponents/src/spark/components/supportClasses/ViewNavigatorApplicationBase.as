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
import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.display.StageOrientation;
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.StageOrientationEvent;
import flash.net.registerClassAlias;
import flash.system.Capabilities;
import flash.ui.Keyboard;

import mx.core.IFactory;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.FlexMouseEvent;
import mx.events.ResizeEvent;
import mx.managers.SystemManager;

import spark.components.Application;
import spark.components.View;
import spark.components.ViewMenu;
import spark.components.ViewMenuItem;
import spark.events.PopUpEvent;
import spark.managers.IPersistenceManager;
import spark.managers.PersistenceManager;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched before the application attempts
 *  to restore its previously saved state when the application is being 
 *  launched.  
 *  Calling <code>preventDefault</code> on this event 
 *  prevents the application state from being restored.
 * 
 *  @eventType mx.events.FlexEvent.NAVIGATOR_STATE_LOADING
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="navigatorStateLoading", type="mx.events.FlexEvent")]

/**
 *  Dispatched before the application attempts
 *  to persist its state when the application being suspended or exited.
 *  Calling <code>preventDefault</code> on this event prevents the
 *  application state from being saved.
 * 
 *  @eventType mx.events.FlexEvent.NAVIGATOR_STATE_SAVING
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="navigatorStateSaving", type="mx.events.FlexEvent")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------
[Exclude(name="controlBarContent", kind="property")]
[Exclude(name="controlBarGroup", kind="property")]
[Exclude(name="controlBarLayout", kind="property")]
[Exclude(name="controlBarVisible", kind="property")]
[Exclude(name="layout", kind="property")]
[Exclude(name="preloaderChromeColor", kind="property")]
[Exclude(name="backgroundAlpha", kind="style")]

/**
 *  The ViewNavigatorApplicationBase class is the base class used for all 
 *  view-based application types.
 *  This class provides the basic infrastructure for providing 
 *  access to the device application menu, hardware keys, orientation status
 *  and application session persistence.
 *
 *  @mxml <p>The <code>&lt;s:ViewNavigatorApplicationBase&gt;</code> tag inherits 
 *  all of the tag attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:ViewNavigatorApplicationBase
 *    <strong>Properties</strong>
 *    persistNavigatorState="false"
 *    viewMenuOpen="false"
 *  /&gt;
 *  </pre>
 *  
 *  @see spark.components.ViewNavigatorApplication
 *  @see spark.components.TabbedViewNavigatorApplication
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class ViewNavigatorApplicationBase extends Application
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
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function ViewNavigatorApplicationBase()
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
    
    /**
     *  @private
     */ 
    private var mouseShield:Sprite;
    
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
     *  The PersistenceManager object for the application.  
     *  The persistence manager is automatically created on demand 
     *  when accessed for the first time.  
     *  Override the <code>createPersistenceManager()</code>
     *  method to change the type of persistence manager that is created.
     * 
     *  <p>The persistence manager automatically saves and restores
     *  the current view navigator's view stack if the
     *  <code>persistNavigatorState</code> flag is set to <code>true</code>. 
     *  Data stored in the persistence manager is automatically flushed to disk 
     *  when the application is suspended or exited.</p>
     *  
     *  <p>The default implementation of the persistence manager uses
     *  a shared object as it's backing data store.  
     *  All information that is saved to this object must adhere to flash 
     *  AMF rules for object encoding.
     *  This means that custom classes must be registered through the use
     *  of <code>flash.net.registerClassAlias</code></p>
     * 
     *  <p>The default value is an instance of spark.core.managers.PersistenceManager.</p>
     *
     *  @see spark.managers.PersistenceManager
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get persistenceManager():IPersistenceManager
    {
        if (!_persistenceManager)
            initializePersistenceManager();
        
        return _persistenceManager;
    }
    
    //----------------------------------
    //  persistNavigatorState
    //----------------------------------
    
    private var _persistNavigatorState:Boolean = false;
    private var _persistenceInitialized:Boolean = false;
    
    /**
     *  Toggles the application session caching feature for the application.  
     *  When enabled, the application automatically saves the current
     *  view navigator's view stack 
     *  and navigation history to the persistence manager.  
     *  When the application is relaunched, this data is automatically read from 
     *  the persistence store and applied to the application's navigator.
     * 
     *  <p>When enabled, the application version will be added to the persistence object.  
     *  You can access this information by using the persistence manager's 
     *  <code>getProperty()</code> method and ask for the <code>versionNumber</code> key.</p>
     * 
     *  <p>When the persistence object is being created, the application dispatches
     *  a cancelable <code>FlexEvent.NAVIGATOR_STATE_SAVING</code> event when the process
     *  begins.  
     *  If you cancel the <code>NAVIGATOR_STATE_SAVING</code> event, 
     *  the persistence object is not created.
     *  Similarly, when this information is being restored to the application, a cancelable
     *  <code>FlexEvent.NAVIGATOR_STATE_LOADING</code> event is dispatched.  
     *  Canceling the <code>NAVIGATOR_STATE_LOADING</code> event prevents the navigation 
     *  data from being restored.</p>
     * 
     *  <p>The <code>persistNavigatorState</code> flag must be set to <code>true</code> before
     *  the application initializes itself for the navigator's state to be automatically
     *  restored.</p>
     *
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get persistNavigatorState():Boolean
    {
        return _persistNavigatorState;
    }
    
    /**
     * @private
     */ 
    public function set persistNavigatorState(value:Boolean):void
    {
        _persistNavigatorState = value;

        // If this flag is set to true at runtime, we will need to initialize
        // the persistence manager if it hasn't been already
        if (initialized && _persistNavigatorState && !_persistenceInitialized)
            initializePersistenceManager();
    }
    
    //----------------------------------
    //  viewMenuOpen
    //----------------------------------
    
    /**
     *  Opens the view menu if set to <code>true</code>,
     *  and closes it if set to <code>false</code>. 
     * 
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get viewMenuOpen():Boolean
    {
        return currentViewMenu && currentViewMenu.isOpen;
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
     *  operating system in response to 
     *  an <code>InvokeEvent.INVOKEevent</code> event.
     * 
     *  @param event The InvokeEvent object.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */  
    protected function invokeHandler(event:InvokeEvent):void
    {
        addDeactivateListeners();
    }
    
    
    /**
     *  @private
     *  Adds the deactivate handlers when the application is reactivated.
     */ 
    private function activateHandler(event:Event):void
    {
        addDeactivateListeners();
    }
    
    /**
     *  Called when the application is exiting or being
     *  sent to the background by the operating system.  
     *  If <code>persistNavigatorState</code> is <code>true</code>, 
     *  then the application begins the state saving process.
     *
     *  @param event The event object for the NAVIGATOR_STATE_SAVING event.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected function deactivateHandler(event:Event):void
    {
        // When the deactiveHandler is called, the application is being
        // suspended or exited.  Remove the deactivate listeners so that
        // we don't persist data multiple times in the case a deactivate
        // and exiting event are received in the same sequence
        removeDeactivateListeners();
        
        // Check if the application state should be persisted 
        if (persistNavigatorState)
        {
            // Dispatch event for saving persistence data
            var eventCanceled:Boolean = false;
            if (hasEventListener(FlexEvent.NAVIGATOR_STATE_SAVING))
                eventCanceled = !dispatchEvent(new FlexEvent(FlexEvent.NAVIGATOR_STATE_SAVING, 
                                                                false, true));
            
            if (!eventCanceled)
            {
                saveNavigatorState();
            }
        }

        // Always flush the persistence manager to disk if it exists
        if (_persistenceManager)
        {
            persistenceManager.save();
        }
    }
    
    /**
     *  Called when the application's hardware back key is pressed
     *  by the user.
     *
     *  @param event The event object generated by the key press.
     *   
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected function backKeyUpHandler(event:KeyboardEvent):void
    {
    }
    
    /**
     *  Called when the menu key is pressed. 
     *  By default, this method opens or closes the ViewMenu object.
     *
     *  @param event The KeyboardEvent object associated with the 
     *  menu key being pressed.
     *
     *  @see spark.components.ViewMenu
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected function menuKeyUpHandler(event:KeyboardEvent):void
    {
        if (activeView && !activeView.menuKeyHandledByView())
            viewMenuOpen = !viewMenuOpen;
    }
    
    /**
     *  Creates the persistence manager for the application.
     *  This method is called automatically when the persistence manager is
     *  accessed for the first time, or if the <code>persistNavigatorState</code> property
     *  is set to <code>true</code> on the application.
     *
     *  @return An IPersistenceManager manager object.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected function createPersistenceManager():IPersistenceManager
    {
        return new PersistenceManager();
    }
    
    /**
     *  Responsible for persisting the application state to the persistence manager.
     *  This method is called automatically when <code>persistNavigatorState</code>
     *  is set to <code>true</code>.  
     *  By default, this method saves the application version in the 
     *  <code>versionNumber</code> key of the PersistenceManager object.
     * 
     *  <p>This method is only called if the <code>FlexEvent.NAVIGATOR_STATE_SAVING</code>
     *  event is not canceled.</p>
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected function saveNavigatorState():void
    {
        // Save version number of application
        var appDescriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
        var ns:Namespace = appDescriptor.namespace();
        
        persistenceManager.setProperty("versionNumber", 
                                        appDescriptor.ns::versionNumber.toString());
    }
    
    /**
     *  Responsible for restoring the application's state when the
     *  <code>persistNavigatorState</code> property is set to <code>true</code>.
     * 
     *  <p>This method is only called if the <code>FlexEvent.NAVIGATOR_STATE_LOADING</code>
     *  event is not canceled.</p>
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    protected function loadNavigatorState():void
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
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    private function addApplicationListeners():void
    {
		// Listen for keyboard events at a lower priority so that developers
		// can cancel the default behavior
        systemManager.stage.addEventListener(KeyboardEvent.KEY_DOWN, deviceKeyDownHandler, false, -1);
        systemManager.stage.addEventListener(KeyboardEvent.KEY_UP, deviceKeyUpHandler, false, -1);
        systemManager.stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, orientationChangeHandler);
        NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, invokeHandler);
        NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, activateHandler);
    }
    
    /**
     *  @private
     *  Adds listeners for the deactivate event.
     */ 
    private function addDeactivateListeners():void
    {
        // The application listens for deactivate and exiting events to determine when
        // the persistenceManager should save its state to disk.  When the application
        // is being simulated in ADL on desktop, we don't want to listen for deactivate
        // because that event is dispatched whenever the window loses focus.  This
        // could cause persistence to run when a developer doesn't expect it to.  
        // So the DEACTIVATE event is ignored on desktop machines.
        var os:String = Capabilities.os;
        
        // TODO (chiedozi): If the framework ever supports Windows Mobile, we'll need to update this check.
        var runningOnDesktop:Boolean = (os.indexOf("Windows") != -1 || os.indexOf("Mac OS") != -1);
        if (!runningOnDesktop)
            NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, deactivateHandler);
        
        NativeApplication.nativeApplication.addEventListener(Event.EXITING, deactivateHandler);
    }
    
    /**
     *  @private
     *  Remove listeners for the deactivate and exiting events.
     */ 
    private function removeDeactivateListeners():void
    {
        var os:String = Capabilities.os;
        
        // TODO (chiedozi): If the framework ever supports Windows Mobile, we'll need to update this check.
        var runningOnDesktop:Boolean = (os.indexOf("Windows") != -1 || os.indexOf("Mac OS") != -1);
        if (!runningOnDesktop)
            NativeApplication.nativeApplication.removeEventListener(Event.DEACTIVATE, deactivateHandler);
        
        NativeApplication.nativeApplication.removeEventListener(Event.EXITING, deactivateHandler);
    }
    
    /**
     *  @private
     *  The key model employeed by ViewNavigatorApplication is to listen for the down
     *  event but run the back key handling logic on up.  The reasoning for this
     *  is that the down event is dispatched multiple times while the user
     *  presses it down.  But the desired back logic should only happen once.
     *  So when a down event is received, the application only tracks if it has been
     *  canceled by the developer.
     * 
     *  It is still necessary to listen to the down key because the application
     *  needs to cancel the device's default back logic at this stage.  For example,
     *  on android, when the back key is pressed, the default behavior is to
     *  suspend the application and return to the home screen.  This functionality
     *  can only be canceled when the down event is received.
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
            backKeyUpHandler(event);
        else if (key == Keyboard.MENU && !menuKeyEventPreventDefaulted)
            menuKeyUpHandler(event);
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
            
            // Remember the focus, we'll restore it when the menu closes
            lastFocus = getFocus();
            
            // If the softKeyboard is open, close it first
            if (isSoftKeyboardActive)
            {
                systemManager.stage.focus = null;
            }
            
            // Size the menu as big as the app
            currentViewMenu.width = getLayoutBoundsWidth();
            currentViewMenu.height = getLayoutBoundsHeight();
            
            currentViewMenu.setFocus();
            
            currentViewMenu.addEventListener(MouseEvent.CLICK, viewMenu_clickHandler);
            currentViewMenu.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, viewMenu_mouseDownOutsideHandler);
            currentViewMenu.addEventListener(PopUpEvent.CLOSE, viewMenuClose_handler);
            currentViewMenu.addEventListener(PopUpEvent.OPEN, viewMenuOpen_handler);
            addEventListener(ResizeEvent.RESIZE, resizeHandler);
        }
        
        
        // Block interaction with the rest of the application
        attachMouseShield();
        currentViewMenu.open(this, false /*modal*/);
    }

    /**
     *  @private
     */ 
    private function closeViewMenu():void
    {
        if (currentViewMenu)
        {
            currentViewMenu.close();
            removeMouseShield();
        }
    }
    
    /**
     *  @private
     */ 
    private function viewMenuOpen_handler(event:PopUpEvent):void
    {
        // Private event for testing
        if (activeView.hasEventListener("viewMenuOpen"))
            activeView.dispatchEvent(new Event("viewMenuOpen"));
    }

    /**
     *  @private
     */ 
    private function viewMenuClose_handler(event:PopUpEvent):void
    {
        currentViewMenu.removeEventListener(PopUpEvent.OPEN, viewMenuOpen_handler);
        currentViewMenu.removeEventListener(PopUpEvent.CLOSE, viewMenuClose_handler);
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
    
    /**
     *  @private
     *  Attaches a mouseShield to prevent interaction with the rest of the 
     *  application while the menu is open
     */ 
    mx_internal function attachMouseShield():void
    {
        if (skin)
        {
            mouseShield = new Sprite();
            
            var g:Graphics = mouseShield.graphics;
            g.beginFill(0,0);
            g.drawRect(0,0,getLayoutBoundsWidth(), getLayoutBoundsHeight());
            g.endFill();
            
            skin.addChild(mouseShield);
        }
    }
    
    /**
     *  @private
     *  Removes the mouseShield
     */ 
    mx_internal function removeMouseShield():void
    {
        if (mouseShield && skin)
        {
            skin.removeChild(mouseShield);
            mouseShield = null;
        }
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
        
        if (persistNavigatorState)
        {
            initializePersistenceManager();
            
            // Dispatch event for loading persistence data
            var eventDispatched:Boolean = true;
            if (hasEventListener(FlexEvent.NAVIGATOR_STATE_LOADING))
                eventDispatched = dispatchEvent(new FlexEvent(FlexEvent.NAVIGATOR_STATE_LOADING, 
                                                false, true));
            
            if (eventDispatched)
            {
                loadNavigatorState();
            }
        } 
    }
    
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Method initializes the persistence manager by registering the class
     *  aliases and loading the shared object.  This method is automatically
     *  called by the persistNavigatorState setter.
     */
    private function initializePersistenceManager():void
    {
        // Initialize and load the persisted data.
        _persistenceManager = createPersistenceManager();
        _persistenceManager.load();

        _persistenceInitialized = true;
    }
}
}







