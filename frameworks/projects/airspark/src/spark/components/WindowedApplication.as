////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.core
{

import flash.desktop.DockIcon;
import flash.desktop.NativeApplication;
import flash.desktop.SystemTrayIcon;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.NativeWindow;
import flash.display.NativeWindowDisplayState;
import flash.display.NativeWindowResize;
import flash.display.NativeWindowSystemChrome;
import flash.display.NativeWindowType;
import flash.display.Screen;
import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.FullScreenEvent;
import flash.events.InvokeEvent;
import flash.events.MouseEvent;
import flash.events.NativeWindowBoundsEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.filesystem.File;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.Capabilities;

import mx.components.FxApplication;
import mx.components.FxButton;
import mx.components.Group;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.FlexNativeMenu;
import mx.controls.HTML;
import mx.core.windowClasses.FxTitleBar;
import mx.core.windowClasses.StatusBar;
import mx.events.AIREvent;
import mx.events.FlexEvent;
import mx.events.FlexNativeWindowBoundsEvent;
import mx.graphics.TextBox;
import mx.managers.DragManager;
import mx.managers.NativeDragManagerImpl;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;
import mx.styles.StyleProxy;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when this application is activated.
 *
 *  @eventType mx.events.AIREvent.APPLICATION_ACTIVATE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="applicationActivate", type="mx.events.AIREvent")]

/**
 *  Dispatched when this application is deactivated.
 *
 *  @eventType mx.events.AIREvent.APPLICATION_DEACTIVATE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="applicationDeactivate", type="mx.events.AIREvent")]

/**
 *  Dispatched after this application window has been activated.
 *
 *  @eventType mx.events.AIREvent.WINDOW_ACTIVATE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="windowActivate", type="mx.events.AIREvent")]

/**
 *  Dispatched after this application window has been deactivated.
 *
 *  @eventType mx.events.AIREvent.WINDOW_DEACTIVATE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="windowDeactivate", type="mx.events.AIREvent")]
 
/**
 *  Dispatched after this application window has been closed.
 *
 *  @eventType flash.events.Event.CLOSE
 *
 *  @see flash.display.NativeWindow
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="close", type="flash.events.Event")]

/**
 *  Dispatched before the WindowedApplication window closes.
 *  Cancelable.
 *
 *  @eventType flash.events.Event.CLOSING
 *
 *  @see flash.display.NativeWindow
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="closing", type="flash.events.Event")]

/**
 *  Dispatched after the display state changes to minimize, maximize
 *  or restore.
 *
 *  @eventType flash.events.NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="displayStateChange", type="flash.events.NativeWindowDisplayStateEvent")]

/**
 *  Dispatched before the display state changes to minimize, maximize
 *  or restore.
 *
 *  @eventType flash.events.NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="displayStateChanging", type="flash.events.NativeWindowDisplayStateEvent")]

/**
 *  Dispatched when an application is invoked.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="invoke", type="flash.events.InvokeEvent")]

/**
 *  Dispatched before the WindowedApplication object moves,
 *  or while the WindowedApplication object is being dragged.
 *
 *  @eventType flash.events.NativeWindowBoundsEvent.MOVING
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="moving", type="flash.events.NativeWindowBoundsEvent")]

/**
 *  Dispatched when the computer connects to or disconnects from the network.
 *
 *  @eventType flash.events.Event.NETWORK_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="networkChange", type="flash.events.Event")]

/**
 *  Dispatched before the WindowedApplication object is resized,
 *  or while the WindowedApplication object boundaries are being dragged.
 *
 *  @eventType flash.events.NativeWindowBoundsEvent.RESIZING
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="resizing", type="flash.events.NativeWindowBoundsEvent")]

/**
 *  Dispatched when the WindowedApplication completes its initial layout.
 *  By default, the WindowedApplication will be visbile at this time.
 *
 *  @eventType mx.events.AIREvent.WINDOW_COMPLETE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="windowComplete", type="mx.events.AIREvent")]

/**
 *  Dispatched after the WindowedApplication object moves.
 *
 *  @eventType mx.events.FlexNativeWindowBoundsEvent.WINDOW_MOVE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="windowMove", type="mx.events.FlexNativeWindowBoundsEvent")]

/**
 *  Dispatched after the underlying NativeWindow object is resized.
 *
 *  @eventType mx.events.FlexNativeWindowBoundsEvent.WINDOW_RESIZE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="windowResize", type="mx.events.FlexNativeWindowBoundsEvent")]

//--------------------------------------
//  Effects
//--------------------------------------

/**
 *  Played when the window is closed.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Effect(name="closeEffect", event="windowClose")]

/**
 *  Played when the component is minimized.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Effect(name="minimizeEffect", event="windowMinimize")]

/**
 *  Played when the component is unminimized.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Effect(name="unminimizeEffect", event="windowUnminimize")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="moveEffect", kind="effect")]

//--------------------------------------
//  SkinStates
//--------------------------------------

/**
 *  Normal status using FlexChrome
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("flexChrome")]

/**
 *  normal status using SystemChrome
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("normal")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[ResourceBundle("core")]

/**
 *  The FxWindowedApplication defines the application container
 *  that you use to create Flex applications for AIR applications.
 *
 *  <p>The FxWindowedApplication serves two roles. It is a replacement for the &lt;mx:FxApplication&gt;
 *  tag, functioning as the entry point to a Flex-based AIR application. In addition,
 *  as a container the FxWindowedApplication defines the layout of the initial window
 *  of a Flex AIR application -- any visual controls defined in the FxWindowedApplication
 *  become the content of the initial window loaded by the AIR application.</p>
 *
 *  <p>Note that because
 *  the FxWindowedApplication only represents the visual content of a single window, and not
 *  all the windows in a multi-window application, a FxWindowedApplication instance only dispatches
 *  display-related events (events that the FxWindowedApplication class inherits from display object base
 *  classes such as InteractiveObject or UIComponent) for its own stage and window, and not for
 *  events that occur on other windows in the application. This differs from a browser-based application,
 *  where an FxApplication container dispatches events for all the windows in the application (because
 *  technically those windows are all display objects rendered on the single Application stage).</p>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;mx:FxWindowedApplication&gt;</code> tag inherits all of the tag
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;mx:FxWindowedApplication
 *    <strong>Properties</strong>
 *    alwaysInFront="false"
 *    autoExit="true"
 *    dockIconMenu="<i>null</i>"
 *    maxHeight="10000"
 *    maxWidth="10000"
 *    menu="<i>null</i>"
 *    minHeight="100"
 *    minWidth="100"
 *    showGripper="true"
 *    showStatusBar="true"
 *    showTitleBar="true"
 *    status=""
 *    systemTrayIconMenu="<i>null</i>"
 *    title=""
 *    titleIcon="<i>null</i>"
 * 
 *    <strong>Effects</strong>
 *    closeEffect="<i>No default</i>"
 *    minimizeEffect="<i>No default</i>"
 *    unminimizeEffect="<i>No default</i>"
 * 
 *    <strong>Events</strong>
 *    applicationActivate="<i>No default</i>"
 *    applicationDeactivate="<i>No default</i>"
 *    closing="<i>No default</i>"
 *    displayStateChange="<i>No default</i>"
 *    displayStateChanging="<i>No default</i>"
 *    invoke="<i>No default</i>"
 *    moving="<i>No default</i>"
 *    networkChange="<i>No default</i>"
 *    resizing="<i>No default</i>"
 *    windowComplete="<i>No default</i>"
 *    windowMove="<i>No default</i>"
 *    windowResize="<i>No default</i>"
 *  /&gt;
 *  </pre>
 * 
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class FxWindowedApplication extends FxApplication implements IWindow
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static const MOUSE_SLACK:Number = 5;

    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  This is here to force linkage of NativeDragManagerImpl.
     */
    private static var _forceLinkNDMI:NativeDragManagerImpl;

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function FxWindowedApplication()
    {
        super();

        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        addEventListener(FlexEvent.PREINITIALIZE, preinitializeHandler);
        addEventListener(FlexEvent.UPDATE_COMPLETE, updateComplete_handler);
        addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);

        var nativeApplication:NativeApplication = NativeApplication.nativeApplication;
        nativeApplication.addEventListener(Event.ACTIVATE, nativeApplication_activateHandler);
        nativeApplication.addEventListener(Event.DEACTIVATE, nativeApplication_deactivateHandler);
        nativeApplication.addEventListener(Event.NETWORK_CHANGE, dispatchEvent);

        nativeApplication.addEventListener(InvokeEvent.INVOKE, nativeApplication_invokeHandler);
        initialInvokes = new Array();

        //Force DragManager to instantiate so that it can handle drags from
        //outside the app.
        DragManager.isDragging;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private var _nativeWindow:NativeWindow;

    /**
     *  @private
     */
    private var _nativeWindowVisible:Boolean = true;
    
    /**
     *  @private
     */
    private var toMax:Boolean = false;

    /**
     *  @private
     */
    private var gripperHit:Sprite;

    /**
     *  @private
     */
    private var initialInvokes:Array;

    /**
     *  @private
     */
    private var invokesPending:Boolean = true;

    /**
     *  @private
     */
    private var lastDisplayState:String = StageDisplayState.NORMAL;

    /**
     *  @private
     */
    private var shouldShowTitleBar:Boolean;

    /**
    *  @private
    */
    private var oldX:Number;

    /**
    *  @private
    */
    private var oldY:Number;

    /**
     *  @private
     */
    private var prevX:Number;

    /**
     *  @private
     */
    private var prevY:Number;

    /**
     *  @private
     */
    private var windowBoundsChanged:Boolean = true;

    /**
     *  @private
     *  Determines whether the WindowedApplication opens in an active state.
     *  If you are opening up other windows at startup that should be active,
     *  this will ensure that the WindowedApplication does not steal focus.
     *
     *  @default true
     */
    private var activateOnOpen:Boolean = true;

    /**
     *  @private
     */
    private var ucCount:Number = 0;

    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------

    /**
     *  A skin part that defines the gripper button used to resize the window. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart (required="false")]
    public var gripper:FxButton;

    /**
     *  The SkinPart that displays the status bar.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart (required = "false")]
    public var statusBar:Group;

    //----------------------------------
    //  statusText
    //----------------------------------

    /**
     *  A reference to the UITextField that displays the status bar's text.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    [SkinPart (required="false")]
    public var statusText:TextBox;
    
    /**
     *  The UIComponent that displays the title bar.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart (required="false")]
    public var titleBar:FxTitleBar;

    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  height
    //----------------------------------

    [Bindable("heightChanged")]
    [Inspectable(category="General")]
    [PercentProxy("percentHeight")]

    /**
     *  @private
     */
    override public function get height():Number
    {
        return _bounds.height;
    }

    /**
     *  @private
     *  Also sets the stage's height.
     */
    override public function set height(value:Number):void
    {
        if (value < minHeight)
            value = minHeight;
        else if (value > maxHeight)
            value = maxHeight;

        _bounds.height = value;
        boundsChanged = true;

        invalidateProperties();
        invalidateSize();

        // the heightChanged event is dispatched in commitProperties instead of
        // here because it can change based on user-interaction with the window
        // size and _height is set in there so don't want to prematurely
        // dispatch here yet
    }

    //----------------------------------
    //  maxHeight
    //----------------------------------

    /**
     *  @private
     *  Storage for the maxHeight property.
     */
    private var _maxHeight:Number = 0;
    
    /**
     *  @private
     *  Keeps track of whether maxHeight property changed so we can
     *  handle it in commitProperties.
     */
    private var maxHeightChanged:Boolean = false;

    [Bindable("maxHeightChanged")]
    [Bindable("windowComplete")]

    /**
     *  @private
     */
    override public function get maxHeight():Number
    {
        if (nativeWindow && !maxHeightChanged)
            return nativeWindow.maxSize.y - chromeHeight();
        else
            return _maxHeight;
    }

    /**
     *  Specifies the maximum height of the application's window.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function set maxHeight(value:Number):void
    {
        _maxHeight = value;
        maxHeightChanged = true;
        invalidateProperties();
    }

    //----------------------------------
    //  maxWidth
    //----------------------------------

    /**
     *  @private
     *  Storage for the maxWidth property.
     */
    private var _maxWidth:Number = 0;
    
    /**
     *  @private
     *  Keeps track of whether maxWidth property changed so we can
     *  handle it in commitProperties.
     */
    private var maxWidthChanged:Boolean = false;

    [Bindable("maxWidthChanged")]
    [Bindable("windowComplete")]

    /**
     *  @private
     */
    override public function get maxWidth():Number
    {
        if (nativeWindow && !maxWidthChanged)
            return nativeWindow.maxSize.x - chromeWidth();
        else
            return _maxWidth;
    }

    /**
     *  Specifies the maximum width of the application's window.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function set maxWidth(value:Number):void
    {
        _maxWidth = value;
        maxWidthChanged = true;
        invalidateProperties();
    }

     //---------------------------------
     //  minHeight
     //---------------------------------

    /**
     *  @private
     */
    private var _minHeight:Number = 0;
    
    /**
     *  @private
     *  Keeps track of whether minHeight property changed so we can
     *  handle it in commitProperties.
     */
    private var minHeightChanged:Boolean = false;

    [Bindable("minHeightChanged")]
    [Bindable("windowComplete")]

    /**
     *  Specifies the minimum height of the application's window.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function get minHeight():Number
    {
        if (nativeWindow && !minHeightChanged)
            return nativeWindow.minSize.y - chromeHeight();
        else
            return _minHeight;
    }

    /**
     *  @private
     */
    override public function set minHeight(value:Number):void
    {
        _minHeight = value;
        minHeightChanged = true;
        invalidateProperties();
    }

     //---------------------------------
     //  minWidth
     //---------------------------------

    /**
     *  @private
     *  Storage for the minWidth property.
     */
    private var _minWidth:Number = 0;
    
   /**
     *  @private
     *  Keeps track of whether minWidth property changed so we can
     *  handle it in commitProperties.
     */
    private var minWidthChanged:Boolean = false;

    [Bindable("minWidthChanged")]
    [Bindable("windowComplete")]

    /**
     *  Specifies the minimum width of the application's window.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function get minWidth():Number
    {
        if (nativeWindow && !minWidthChanged)
            return nativeWindow.minSize.x - chromeWidth();
        else
            return _minWidth;
    }

    /**
     *  @private
     */
    override public function set minWidth(value:Number):void
    {
        _minWidth = value;
        minWidthChanged = true;
        invalidateProperties();
    }

    //----------------------------------
    //  visible
    //----------------------------------
    
    [Bindable("hide")]
    [Bindable("show")]
    [Bindable("windowComplete")]

    /**
     *  @private
     *  Also sets the NativeWindow's visibility.
     */ 
    override public function get visible():Boolean
    {
        if (nativeWindow && nativeWindow.closed)
            return false;
        if (nativeWindow)
            return nativeWindow.visible;
        else
            return _nativeWindowVisible;
    }

    /**
     *  @private
     */
    override public function set visible(value:Boolean):void
    {
        if (!nativeWindow)
        {
            _nativeWindowVisible = value;
            invalidateProperties();
        }
        else
        {
            if (!nativeWindow.closed)
            {
                var e:FlexEvent;
                if (value)
                {
                    e = new FlexEvent(FlexEvent.SHOW);
                    _nativeWindow.visible = value;
                    dispatchEvent(e);
                }
                else
                {
                    e = new FlexEvent(FlexEvent.HIDE);
                    if (getStyle("hideEffect"))
                    {
                        addEventListener("effectEnd", hideEffectEndHandler);
                    }
                    else
                    {
                        _nativeWindow.visible = value;
                        dispatchEvent(e);
                    }
                }
            }               
        }
    }

    //----------------------------------
    //  width
    //----------------------------------

    [Bindable("widthChanged")]
    [Inspectable(category="General")]
    [PercentProxy("percentWidth")]
    
    /**
     *  @private
     */
    override public function get width():Number
    {
        return _bounds.width;
    }

    /**
     *  @private
     *  Also sets the stage's width.
     */
     override public function set width(value:Number):void
     {
        if (value < minWidth)
            value = minWidth;
        else if (value > maxWidth)
            value = maxWidth;

        _bounds.width = value;
        boundsChanged = true;

        invalidateProperties();
        invalidateSize();

        // the widthChanged event is dispatched in commitProperties instead of
        // here because it can change based on user-interaction with the window
        // size and _width is set in there so don't want to prematurely
        // dispatch here yet
     }


    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  applicationID
    //----------------------------------

    /**
     *  The identifier that AIR uses to identify the application.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get applicationID():String
    {
        return nativeApplication.applicationID;
    }

    //----------------------------------
    //  alwaysInFront
    //----------------------------------

    /**
     *  @private
     *  Storage for the alwaysInFront property.
     */
    private var _alwaysInFront:Boolean = false;

    /**
     *  Determines whether the underlying NativeWindow is always in front of other windows.
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get alwaysInFront():Boolean
    {
        if (_nativeWindow && !_nativeWindow.closed)
            return nativeWindow.alwaysInFront;
        else
            return _alwaysInFront;
    }
    
    /**
     *  @private
     */
    public function set alwaysInFront(value:Boolean):void
    {
        _alwaysInFront = value;
        if (_nativeWindow && !_nativeWindow.closed)
            nativeWindow.alwaysInFront = value;
    }

    //----------------------------------
    //  autoExit
    //----------------------------------

    /**
     *  Specifies whether the AIR application will quit when the last
     *  window closes or will continue running in the background.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get autoExit():Boolean
    {
        return nativeApplication.autoExit;
    }
    
    /**
     *  @private
     */
    public function set autoExit(value:Boolean):void
    {
        nativeApplication.autoExit = value;
    }

    //----------------------------------
    //  bounds
    //----------------------------------

    /**
     *  @private
     *  Storage for the bounds property.
     */
    private var _bounds:Rectangle = new Rectangle(0,0,0,0);

    /**
     *  @private
     */
    private var boundsChanged:Boolean = false;

    /**
     *  @private
     *  Storage for the height and width
     */
    protected function get bounds():Rectangle
    {
        return nativeWindow.bounds;
    }

    /**
     *  @private
     */
    protected function set bounds(value:Rectangle):void
    {
        nativeWindow.bounds = value;
        boundsChanged = true;

        invalidateProperties();
        invalidateSize();
    }

    //----------------------------------
    //  closed
    //----------------------------------

    /**
     *  Returns true when the underlying window has been closed.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get closed():Boolean
    {
        return nativeWindow.closed;
    }

    //----------------------------------
    //  dockIconMenu
    //----------------------------------

    /**
     *  @private
     *  Storage for the dockIconMenu property.
     */
    private var _dockIconMenu:FlexNativeMenu;

    /**
     *  The dock icon menu. Some operating systems do not support dock icon menus.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get dockIconMenu():FlexNativeMenu
    {
        return _dockIconMenu;
    }

    /**
     *  @private
     */
    public function set dockIconMenu(value:FlexNativeMenu):void
    {
        _dockIconMenu = value;

        if (NativeApplication.supportsDockIcon)
        {
            if (nativeApplication.icon is DockIcon)
                DockIcon(nativeApplication.icon).menu = value.nativeMenu;
        }
    }

    //----------------------------------
    //  maximizable
    //----------------------------------

    /**
     *  Specifies whether the window can be maximized.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get maximizable():Boolean
    {
        if (!nativeWindow.closed)
            return nativeWindow.maximizable;
        else
            return false;
    }

    //----------------------------------
    //  minimizable
    //----------------------------------

    /**
     *  Specifies whether the window can be minimized.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get minimizable():Boolean
    {
        if (!nativeWindow.closed)
            return nativeWindow.minimizable;
        else
            return false;
    }

    //----------------------------------
    //  menu
    //----------------------------------

    /**
     *  @private
     *  Storage for the menu property.
     */
    private var _menu:FlexNativeMenu;

    /**
     *  @private
     */
    private var menuChanged:Boolean = false;

    /**
     *  The application menu for operating systems that support an application menu,
     *  or the window menu of the application's initial window for operating
     *  systems that support window menus.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get menu():FlexNativeMenu
    {
        return _menu;
    }

    /**
     *  @private
     */
    public function set menu(value:FlexNativeMenu):void
    {
        _menu = value;
        menuChanged = true;
    }

    //----------------------------------
    //  nativeWindow
    //----------------------------------

    /**
     *  The NativeWindow used by this WindowedApplication component (the initial
     *  native window of the application).
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get nativeWindow():NativeWindow
    {
        if ((systemManager != null) && (systemManager.stage != null))
            return systemManager.stage.nativeWindow;
    
        return null;
    }

    //---------------------------------
    //  resizable
    //---------------------------------

    /**
     *  Specifies whether the window can be resized.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get resizable():Boolean
    {
        if (nativeWindow.closed)
            return false;
        return nativeWindow.resizable;
    }

    //----------------------------------
    //  nativeApplication
    //----------------------------------

    /**
     *  The NativeApplication object representing the AIR application.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get nativeApplication():NativeApplication
    {
        return NativeApplication.nativeApplication;
    }

    //----------------------------------
    //  showGripper
    //----------------------------------

    /**
     *  @private
     *  Storage for the showGripper property.
     */
    private var _showGripper:Boolean = true;

    /**
     *  @private
     */
    private var showGripperChanged:Boolean = true;

    /**
     *  If <code>true</code>, the gripper is visible.
     *
     *  <p>On Mac OS X a window with <code>systemChrome</code>
     *  set to <code>"standard"</code>
     *  always has an operating system gripper, so this property is ignored
     *  in that case.</p>
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get showGripper():Boolean
    {
        return _showGripper;
    }

    /**
     *  @private
     */
    public function set showGripper(value:Boolean):void
    {
        if (_showGripper == value)
            return;

        _showGripper = value;
        showGripperChanged = true;

        invalidateProperties();
        invalidateDisplayList();
    }

     //---------------------------------
    //  showStatusBar
    //----------------------------------

    /**
     *  @private
     *  Storage for the showStatusBar property.
     */
    private var _showStatusBar:Boolean = true;

    /**
     *  @private
     */
    private var showStatusBarChanged:Boolean = true;

    /**
     *  If <code>true</code>, the status bar is visible.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get showStatusBar():Boolean
    {
        return _showStatusBar;
    }

    /**
     *  @private
     */
    public function set showStatusBar(value:Boolean):void
    {
        if (_showStatusBar == value)
            return;

        _showStatusBar = value;
        showStatusBarChanged = true;

        invalidateProperties();
        invalidateDisplayList();
    }

    //----------------------------------
    //  showTitleBar
    //----------------------------------

    /**
     *  @private
     *  Storage for the showTitleBar property.
     */
    private var _showTitleBar:Boolean = true;

    /**
     *  @private
     */
    private var showTitleBarChanged:Boolean = true;

    /**
     *  If <code>true</code>, the window's title bar is visible.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get showTitleBar():Boolean
    {
        return _showTitleBar;
    }

    /**
     *  @private
     */
    public function set showTitleBar(value:Boolean):void
    {
        if (_showTitleBar == value)
            return;

        _showTitleBar = value;
        showTitleBarChanged = true;
        
        invalidateProperties();
        invalidateDisplayList();
    }

    //----------------------------------
    //  status
    //----------------------------------

    /**
     *  @private
     *  Storage for the status property.
     */
    private var _status:String = "";

    /**
     *  @private
     */
    private var statusChanged:Boolean = false;

    [Bindable("statusChanged")]

    /**
     *  The string that appears in the status bar, if it is visible.
     *
     *  @default ""
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get status():String
    {
        return _status;
    }

    /**
     *  @private
     */
    public function set status(value:String):void
    {
        _status = value;
        statusChanged = true;

        invalidateProperties();
        invalidateSize();

        dispatchEvent(new Event("statusChanged"));
    }

    //----------------------------------
    //  systemChrome
    //----------------------------------

    /**
     *  Specifies the type of system chrome (if any) the window has.
     *  The set of possible values is defined by the constants
     *  in the NativeWindowSystemChrome class.
     *
     *  @see flash.display.NativeWindow#systemChrome
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get systemChrome():String
    {
        if (nativeWindow.closed)
            return "";
        return nativeWindow.systemChrome;
    }

    //----------------------------------
    //  systemTrayIconMenu
    //----------------------------------

    /**
     *  @private
     *  Storage for the systemTrayIconMenu property.
     */
    private var _systemTrayIconMenu:FlexNativeMenu;

    /**
     *  The system tray icon menu. Some operating systems do not support system tray icon menus.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get systemTrayIconMenu():FlexNativeMenu
    {
        return _systemTrayIconMenu;
    }

    /**
     *  @private
     */
    public function set systemTrayIconMenu(value:FlexNativeMenu):void
    {
        _systemTrayIconMenu = value;

        if (NativeApplication.supportsSystemTrayIcon)
        {
            if (nativeApplication.icon is SystemTrayIcon)
                SystemTrayIcon(nativeApplication.icon).menu = value.nativeMenu;
        }
    }

    //----------------------------------
    //  title
    //----------------------------------

    /**
     *  @private
     *  Storage for the title property.
     */
    private var _title:String = "";

    /**
     *  @private
     */
    private var titleChanged:Boolean = false;

    [Bindable("titleChanged")]

    /**
     *  The title that appears in the window title bar and
     *  the taskbar.
     *
     *  If you are using system chrome and you set this property to something
     *  different than the &lt;title&gt; tag in your application.xml,
     *  you may see the title from the XML file appear briefly first.
     *
     *  @default ""
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get title():String
    {
        return _title;
    }
    /**
     *  @private
     */
    public function set title(value:String):void
    {
        _title = value;
        titleChanged = true;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();

        dispatchEvent(new Event("titleChanged"));
    }

    //----------------------------------
    //  titleIcon
    //----------------------------------

    /**
     *  @private
     *  A reference to this container's title icon.
     */
    private var _titleIcon:Class;

    /**
     *  @private
     */
    private var titleIconChanged:Boolean = false;
        
    [Bindable("titleIconChanged")]

    /**
     *  The Class (usually an image) used to draw the title bar icon.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get titleIcon():Class
    {
        return _titleIcon;
    }

    /**
     *  @private
     */
    public function set titleIcon(value:Class):void
    {
        _titleIcon = value;
        titleIconChanged = true;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();

        dispatchEvent(new Event("titleIconChanged"));
    }

    //----------------------------------
    //  transparent
    //----------------------------------

    /**
     *  Specifies whether the window is transparent.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get transparent():Boolean
    {
        if (nativeWindow.closed)
            return false;
        return nativeWindow.transparent;
    }

    //----------------------------------
    //  type
    //----------------------------------

    /**
     *  Specifies the type of NativeWindow that this component
     *  represents. The set of possible values is defined by the constants
     *  in the NativeWindowType class.
     *
     *  @see flash.display.NativeWindowType
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get type():String
    {
        if (nativeWindow.closed)
            return "standard";

        return nativeWindow.type;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------


    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();

        // minimum width and height
        if (minWidthChanged || minHeightChanged)
        {
            var newMinWidth:Number = minWidthChanged ? _minWidth + chromeWidth() : nativeWindow.minSize.x;
            var newMinHeight:Number = minHeightChanged ? _minHeight + chromeHeight() : nativeWindow.minSize.y;
            
            nativeWindow.minSize = new Point(newMinWidth, newMinHeight);
            
            if (minWidthChanged)
            {
                minWidthChanged = false;
                if (width < minWidth)
                    width = minWidth;
                dispatchEvent(new Event("minWidthChanged"));
            }
            if (minHeightChanged)
            {
                minHeightChanged = false;
                if (height < minHeight)
                    height = minHeight;
                dispatchEvent(new Event("minHeightChanged"));
            }
        }
        
        // maximum width and height
        if (maxWidthChanged || maxHeightChanged)
        {
            var newMaxWidth:Number = maxWidthChanged ? _maxWidth + chromeWidth() : nativeWindow.maxSize.x;
            var newMaxHeight:Number = maxHeightChanged ? _maxHeight + chromeHeight() : nativeWindow.maxSize.y;
            
            nativeWindow.maxSize = new Point(newMaxWidth, newMaxHeight);
            
            if (maxWidthChanged)
            {
                maxWidthChanged = false;
                if (width > maxWidth)
                    width = maxWidth;
                dispatchEvent(new Event("maxWidthChanged"));
            }
            if (maxHeightChanged)
            {
                maxHeightChanged = false;
                if (height > maxHeight)
                    height = maxHeight;
                dispatchEvent(new Event("maxHeightChanged"));
            }
        }

        if (boundsChanged)
        {       
            systemManager.stage.stageWidth = _width = _bounds.width;
            systemManager.stage.stageHeight = _height =  _bounds.height;
            boundsChanged = false;
            
            // don't know whether height or width changed
            dispatchEvent(new Event("widthChanged"));
            dispatchEvent(new Event("heightChanged"));
        }

        if (windowBoundsChanged)
        {
            _bounds.width = _width = systemManager.stage.stageWidth;
            _bounds.height = _height = systemManager.stage.stageHeight;
            windowBoundsChanged = false;
            
            // don't know whether height or width changed
            dispatchEvent(new Event("widthChanged"));
            dispatchEvent(new Event("heightChanged"));
        }

        if (menuChanged && !nativeWindow.closed)
        {
            menuChanged = false;
            
            if (menu == null)
            {
                if (NativeApplication.supportsMenu)
                    nativeApplication.menu = null;
                else if (NativeWindow.supportsMenu)
                    nativeWindow.menu = null;
            }
            else if (menu.nativeMenu)
            {
                if (NativeApplication.supportsMenu)
                    nativeApplication.menu = menu.nativeMenu;
                else if (NativeWindow.supportsMenu)
                    nativeWindow.menu = menu.nativeMenu;
            }
            
            dispatchEvent(new Event("menuChanged"));
        }

        if (showTitleBarChanged)
        {
            if (titleBar) 
            {
                titleBar.visible = _showTitleBar;
                titleBar.includeInLayout = _showTitleBar;
            }
            showTitleBarChanged = false;
        }

        if (titleChanged)
        {
            if (!nativeWindow.closed)
                systemManager.stage.nativeWindow.title = _title;
            if (titleBar)
                titleBar.title = _title;
            titleChanged = false;
        }

        if (showStatusBarChanged)
        {
            if (statusBar)
            {
                statusBar.visible = _showStatusBar;
                statusBar.includeInLayout = _showStatusBar;
            }
            showStatusBarChanged = false;
        }

        if (statusChanged)
        {
            if (statusText)
                statusText.text = status;
            statusChanged = false;
        }

        if (showGripperChanged)
        {
            if (gripper)
            {
                gripper.visible = _showGripper;
                gripperHit.visible = _showGripper;
            }
            showGripperChanged = false;
        }

        if (toMax)
        {
            toMax = false;
            if (!nativeWindow.closed)
                nativeWindow.maximize();
        }
     }

    /**
     *  @private
     */
    override public function move(x:Number, y:Number):void
    {
        if (nativeWindow && !nativeWindow.closed)
        {
            var tmp:Rectangle = nativeWindow.bounds;
            tmp.x = x;
            tmp.y = y;
            nativeWindow.bounds = tmp;
        }
    }

    /**
     *  @private
     *  Called when the "View Source" item in the application's context menu
     *  is selected.
     *
     *  Opens the window where AIR decides, sized to the parent application.
     *  It will close when the parent WindowedApplication closes.
     */
    protected function menuItemSelectHandler(event:Event):void
    {
        const vsLoc:File = File.applicationDirectory.resolvePath(viewSourceURL);
        if (vsLoc.exists)
        {
            const screenRect:Rectangle = Screen.mainScreen.visibleBounds;
            const screenWidth:int = screenRect.width;
            const screenHeight:int = screenRect.height;

            // roughly golden-ratio based on 90% of the smaller screen dimension
            // should be pleasing to the eye...
            const minDim:Number = Math.min(screenWidth, screenHeight);
            const winWidth:int = minDim * 0.9;
            const winHeight:int = winWidth * 0.618;
            
            const winX:int = (screenWidth - winWidth) / 2;
            const winY:int = (screenHeight - winHeight) / 2;
            
            const html:HTML = new HTML();
            {
                html.width  = winWidth;
                html.height = winHeight;
                html.location = vsLoc.url;
            }
    
            const win:Window = new Window();
            {
                win.type = NativeWindowType.UTILITY;
                win.systemChrome = NativeWindowSystemChrome.STANDARD;
                
                win.title = resourceManager.getString("core", "viewSource");
                
                win.width  = winWidth;
                win.height = winHeight;
                
                win.addChild(html);
                
                // handle resizing since the HTML should take the whole stage
                win.addEventListener(
                    FlexNativeWindowBoundsEvent.WINDOW_RESIZE,
                    viewSourceResizeHandler(html),
                    false, 0, true);

                // links should open in the system web browser (e.g. the .zip links)
                html.htmlLoader.navigateInSystemBrowser = true;
                
                // close the View Source window when this WindowedApp closes
                addEventListener(Event.CLOSING, viewSourceCloseHandler(win), false, 0, true);
            }
            
            // make it so
            win.open();
            win.move(winX, winY);
        }
        else
        {
            Alert.show(resourceManager.getString("core", "badFile"));
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        if (instance == titleBar)
        {
            titleBar.title = _title;
        }
        else if (instance == statusText)
        {
            statusText.text = status;    
        }
        else if (instance == gripper)
        {
            gripper.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == gripper)
        {
            gripper.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Activates the underlying NativeWindow (even if this application is not the active one).
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function activate():void
    {
        if (!systemManager.stage.nativeWindow.closed)
            systemManager.stage.nativeWindow.activate();    
    }

    /**
     *  Closes the application's NativeWindow (the initial native window opened by the application). This action is cancelable.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function close():void
    {
        if (!nativeWindow.closed)
        {
            var e:Event = new Event("closing", true, true);
            stage.nativeWindow.dispatchEvent(e);
            if (!e.isDefaultPrevented())
                stage.nativeWindow.close();
        }
    }

    /**
     *  Closes the window and exits the application.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function exit():void
    {
        nativeApplication.exit();
    }

    /**
     *  Maximizes the window, or does nothing if it's already maximized.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function maximize():void
    {
        
        if (!nativeWindow || !nativeWindow.maximizable || nativeWindow.closed)
            return;
        if (systemManager.stage.nativeWindow.displayState!= NativeWindowDisplayState.MAXIMIZED)
        {
            var f:NativeWindowDisplayStateEvent = new NativeWindowDisplayStateEvent(
                        NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
                        false, true, systemManager.stage.nativeWindow.displayState,
                        NativeWindowDisplayState.MAXIMIZED);
            systemManager.stage.nativeWindow.dispatchEvent(f);
            if (!f.isDefaultPrevented())
            {
                invalidateProperties();
                invalidateSize();
                invalidateDisplayList();
                toMax = true;
            }
        }
    }

    /**
     *  Minimizes the window.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function minimize():void
    {
        if (!nativeWindow.closed)
        {
            var e:NativeWindowDisplayStateEvent = new NativeWindowDisplayStateEvent(
                    NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
                    false, true, nativeWindow.displayState,
                    NativeWindowDisplayState.MINIMIZED)
            stage.nativeWindow.dispatchEvent(e);
            if (!e.isDefaultPrevented())
                stage.nativeWindow.minimize();
        }
    }

    /**
     *  Restores the window (unmaximizes it if it's maximized, or
     *  unminimizes it if it's minimized).
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function restore():void
    {
        if (!nativeWindow.closed)
        {
            var e:NativeWindowDisplayStateEvent;
            if (stage.nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED)
            {
                e = new NativeWindowDisplayStateEvent(
                            NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
                            false, true, NativeWindowDisplayState.MAXIMIZED,
                            NativeWindowDisplayState.NORMAL);
                stage.nativeWindow.dispatchEvent(e);
                if (!e.isDefaultPrevented())
                    nativeWindow.restore();
            }
            else if (stage.nativeWindow.displayState == NativeWindowDisplayState.MINIMIZED)
            {
                e = new NativeWindowDisplayStateEvent(
                    NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
                    false, true, NativeWindowDisplayState.MINIMIZED,
                    NativeWindowDisplayState.NORMAL);
                stage.nativeWindow.dispatchEvent(e);
                if (!e.isDefaultPrevented())
                    nativeWindow.restore();
            }
        }
    }

    /**
     *  Orders the window just behind another. To order the window behind
     *  a NativeWindow that does not implement IWindow, use this window's
     *  NativeWindow's <code>orderInBackOf()</code> method.
     *
     *  @param window The IWindow (Window or WindowedAplication)
     *  to order this window behind.
     *
     *  @return <code>true</code> if the window was succesfully sent behind;
     *  <code>false</code> if the window is invisible or minimized.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
     public function orderInBackOf(window:IWindow):Boolean
     {
        if (nativeWindow && !nativeWindow.closed)
            return nativeWindow.orderInBackOf(window.nativeWindow);
        else
            return false;
     }

    /**
     *  Orders the window just in front of another. To order the window
     *  in front of a NativeWindow that does not implement IWindow, use this
     *  window's NativeWindow's <code>orderInFrontOf()</code> method.
     *
     *  @param window The IWindow (Window or WindowedAplication)
     *  to order this window in front of.
     *
     *  @return <code>true</code> if the window was succesfully sent in front;
     *  <code>false</code> if the window is invisible or minimized.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
     public function orderInFrontOf(window:IWindow):Boolean
     {
        if (nativeWindow && !nativeWindow.closed)
            return nativeWindow.orderInFrontOf(window.nativeWindow);
        else
            return false;
     }

     /**
      *  Orders the window behind all others in the same application.
      *
      *  @return <code>true</code> if the window was succesfully sent to the back;
      *  <code>false</code> if the window is invisible or minimized.
      *  
      *  @langversion 3.0
      *  @playerversion AIR 1.5
      *  @productversion Flex 4
      */
     public function orderToBack():Boolean
     {
        if (nativeWindow && !nativeWindow.closed)
            return nativeWindow.orderToBack();
        else
            return false;
     }

 /**
  *  Orders the window in front of all others in the same application.
  *
  *  @return <code>true</code> if the window was succesfully sent to the front;
  *  <code>false</code> if the window is invisible or minimized.
  *  
  *  @langversion 3.0
  *  @playerversion AIR 1.5
  *  @productversion Flex 4
  */
     public function orderToFront():Boolean
     {
        if (nativeWindow && !nativeWindow.closed)
            return nativeWindow.orderToFront();
        else
            return false;
     }
     
    //--------------------------------------------------------------------------
    //
    // Skin states support
    //
    //--------------------------------------------------------------------------

    /**
     *  Returns the name of the state to be applied to the skin. For example, a
     *  Button component could return the String "up", "down", "over", or "disabled" 
     *  to specify the state.
     * 
     *  <p>A subclass of FxComponent must override this method to return a value.</p>
     * 
     *  @return A string specifying the name of the state to apply to the skin.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function getCurrentSkinState():String 
    {
        if (nativeWindow.systemChrome == "none")
        {
            return "flexChrome";
        }
        
        return "normal";
    }    
    
    /**
     *  @private
     *  Returns the width of the chrome for the window
     */
    private function chromeWidth():Number
    {
        return nativeWindow.width - systemManager.stage.stageWidth;
    }
    
    /**
     *  @private
     *  Returns the height of the chrome for the window
     */
    private function chromeHeight():Number
    {
        return nativeWindow.height - systemManager.stage.stageHeight;
    }
        
    /**
     *  @private
     *  Starts a system move.
     */
    private function startMove(event:MouseEvent):void
    {
        addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
        addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);

        prevX = event.stageX;
        prevY = event.stageY;
    }

    /**
     *  @private
     *  Starts a system resize.
     */
    protected function startResize(start:String):void
    {
        if (!nativeWindow.closed)
            if (nativeWindow.resizable)
                stage.nativeWindow.startResize(start);
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function creationCompleteHandler(event:Event):void
    {
        addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        _nativeWindow = systemManager.stage.nativeWindow;
    }
    
    /**
     *  @private
     */
    private function enterFrameHandler(e:Event):void
    {
        removeEventListener(Event.ENTER_FRAME, enterFrameHandler);

        // If nativeApplication.nativeApplication.exit() has been called,
        // the window will already be closed.
        if (stage.nativeWindow.closed)
            return;

        //window properties that have been stored till window exists
        //now get applied to window
        stage.nativeWindow.visible = _nativeWindowVisible;
        dispatchEvent(new AIREvent(AIREvent.WINDOW_COMPLETE));
        
        // Now let any invoke events received from nativeApplication
        // during initialization, flow to our listeners.
        dispatchPendingInvokes();
        
        if (_nativeWindowVisible && activateOnOpen)
            stage.nativeWindow.activate();
        stage.nativeWindow.alwaysInFront = _alwaysInFront;
    }

    /**
     *  @private
     */
    private function dispatchPendingInvokes():void
    {
        invokesPending = false;
        for each (var event:InvokeEvent in initialInvokes)
            dispatchEvent(event);
        initialInvokes = null;
    }
    
    /**
     *  @private
     */
    private function hideEffectEndHandler(event:Event):void
    {
        _nativeWindow.visible = false;
        
        dispatchEvent(new FlexEvent(FlexEvent.HIDE));
    }

    /**
     *  @private
     */
    private function windowMinimizeHandler(event:Event):void
    {
        if (!nativeWindow.closed)
            stage.nativeWindow.minimize();
        removeEventListener("effectEnd", windowMinimizeHandler);
    }

    /**
     *  @private
     */
    private function windowUnminimizeHandler(event:Event):void
    {
        removeEventListener("effectEnd", windowUnminimizeHandler);
    }

    /**
     *  @private
     */
    private function window_moveHandler(event:NativeWindowBoundsEvent):void
    {
        dispatchEvent(new FlexNativeWindowBoundsEvent(FlexNativeWindowBoundsEvent.WINDOW_MOVE, event.bubbles, event.cancelable,
                    event.beforeBounds, event.afterBounds));
    }

    /**
     *  @private
     */
    private function window_displayStateChangeHandler(
                            event:NativeWindowDisplayStateEvent):void
    {
        // Redispatch event.
        dispatchEvent(event);
        height = systemManager.stage.stageHeight;
        width = systemManager.stage.stageWidth;
    }

    /**
     *  @private
     */
    private function window_displayStateChangingHandler(
                            event:NativeWindowDisplayStateEvent):void
    {
        //redispatch event for cancellation purposes
        dispatchEvent(event);
        if (event.isDefaultPrevented())
            return;
        if (event.afterDisplayState == NativeWindowDisplayState.MINIMIZED)
        {
            if (getStyle("minimizeEffect"))
            {
                event.preventDefault();
                addEventListener("effectEnd", windowMinimizeHandler);
                dispatchEvent(new Event("windowMinimize"));
            }
        }

        // After here, afterState is normal
        else if (event.beforeDisplayState == NativeWindowDisplayState.MINIMIZED)
        {
            addEventListener("effectEnd", windowUnminimizeHandler);
            dispatchEvent(new Event("windowUnminimize"));
        }
    }

    /**
     *  @private
     */
    private function windowMaximizeHandler(event:Event):void
    {
        removeEventListener("effectEnd", windowMaximizeHandler);
        if (!nativeWindow.closed)
            stage.nativeWindow.maximize();
    }

    /**
     *  @private
     */
    private function windowUnmaximizeHandler(event:Event):void
    {
        removeEventListener("effectEnd", windowUnmaximizeHandler);
        if (!nativeWindow.closed)
            stage.nativeWindow.restore();
    }

    /**
     *  Manages mouse down events on the window border.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function mouseDownHandler(event:MouseEvent):void
    {
        if (systemManager.stage.nativeWindow.systemChrome != "none")
            return;
        if (event.target == gripper)
        {
            startResize(NativeWindowResize.BOTTOM_RIGHT);
            event.stopPropagation();
        }
        else
        {
            var dragWidth:int = Number(getStyle("borderThickness")) + 6;
            var cornerSize:int = 12;
            // we short the top a little

            if (event.stageY < Number(getStyle("borderThickness")))
            {
                if (event.stageX < cornerSize)
                    startResize(NativeWindowResize.TOP_LEFT);
                else if (event.stageX > width - cornerSize)
                    startResize(NativeWindowResize.TOP_RIGHT);
                else
                    startResize(NativeWindowResize.TOP);
            }

            else if (event.stageY > (height - dragWidth))
            {
                if (event.stageX < cornerSize)
                     startResize(NativeWindowResize.BOTTOM_LEFT);
                else if (event.stageX > width - cornerSize)
                    startResize(NativeWindowResize.BOTTOM_RIGHT);
                else
                    startResize(NativeWindowResize.BOTTOM);
            }

            else if (event.stageX < dragWidth )
            {
                if (event.stageY < cornerSize)
                    startResize(NativeWindowResize.TOP_LEFT);
                else if (event.stageY > height - cornerSize)
                    startResize(NativeWindowResize.BOTTOM_LEFT);
                else
                    startResize(NativeWindowResize.LEFT);
                event.stopPropagation();
            }

            else if (event.stageX > width - dragWidth)
            {
                if (event.stageY < cornerSize)
                    startResize(NativeWindowResize.TOP_RIGHT);
                else if (event.stageY > height - cornerSize)
                    startResize(NativeWindowResize.BOTTOM_RIGHT);
                else
                    startResize(NativeWindowResize.RIGHT);
            }
        }
    }

    /**
     *  @private
     */
    private function closeButton_clickHandler(event:Event):void
    {
       stage.nativeWindow.close();
    }

    /**
     *  @private
     */
    private function preinitializeHandler(event:Event = null):void
    {
        systemManager.stage.nativeWindow.addEventListener(
            NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
            window_displayStateChangingHandler);
        systemManager.stage.nativeWindow.addEventListener(
            NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,
            window_displayStateChangeHandler)
        systemManager.stage.nativeWindow.addEventListener(
            "closing", window_closingHandler);
        systemManager.stage.nativeWindow.addEventListener(
            "close", window_closeHandler, false, 0, true);
            
        // For the edge case, e.g. visible is set to true in
        // AIR xml file, we fabricate an activate event, since Flex 
        // comes in late to the show.
        if (systemManager.stage.nativeWindow.active) 
            dispatchEvent(new AIREvent(AIREvent.WINDOW_ACTIVATE));
                        
        systemManager.stage.nativeWindow.addEventListener(
            "activate", nativeWindow_activateHandler, false, 0, true);
        systemManager.stage.nativeWindow.addEventListener(
            "deactivate", nativeWindow_deactivateHandler, false, 0, true);
                        
        systemManager.stage.nativeWindow.addEventListener(
            NativeWindowBoundsEvent.MOVING, window_boundsHandler);

        systemManager.stage.nativeWindow.addEventListener(
            NativeWindowBoundsEvent.MOVE, window_moveHandler);

        systemManager.stage.nativeWindow.addEventListener(
            NativeWindowBoundsEvent.RESIZING, window_boundsHandler);

        systemManager.stage.nativeWindow.addEventListener(
           NativeWindowBoundsEvent.RESIZE, window_resizeHandler);

        systemManager.stage.addEventListener(
            FullScreenEvent.FULL_SCREEN, stage_fullScreenHandler);
    }

    /**
     *  @private
     */
    private function mouseMoveHandler(event:MouseEvent):void
    {
        stage.nativeWindow.x += event.stageX - prevX;
        stage.nativeWindow.y += event.stageY - prevY;
    }

    /**
     *  @private
     */
    private function mouseUpHandler(event:MouseEvent):void
    {
        removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
        removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
    }

    /**
     *  @private
     */
    private function window_boundsHandler(event:NativeWindowBoundsEvent):void
    {

        var newBounds:Rectangle = event.afterBounds;
        var r:Rectangle;
        if (event.type == NativeWindowBoundsEvent.MOVING)
        {
            dispatchEvent(event);
            if (event.isDefaultPrevented())
                return;
        }
        else //event is resizing
        {
            dispatchEvent(event);
            if (event.isDefaultPrevented())
                return;
            var cancel:Boolean = false;
           if (newBounds.width < nativeWindow.minSize.x)
            {   
                cancel = true;
                if (newBounds.x != event.beforeBounds.x && !isNaN(oldX))
                    newBounds.x = oldX;
                newBounds.width = nativeWindow.minSize.x;
            }
            else if (newBounds.width > nativeWindow.maxSize.x)
            {
                cancel = true;
                if (newBounds.x != event.beforeBounds.x && !isNaN(oldX))
                    newBounds.x = oldX;
                newBounds.width = nativeWindow.maxSize.x;
            }
            if (newBounds.height < nativeWindow.minSize.y)
            {
                cancel = true;
                if (event.afterBounds.y != event.beforeBounds.y && !isNaN(oldY))
                    newBounds.y = oldY;
                newBounds.height = nativeWindow.minSize.y;
            }
            else if (newBounds.height > nativeWindow.maxSize.y)
            {
                cancel = true;
                if (event.afterBounds.y != event.beforeBounds.y && !isNaN(oldY))
                    newBounds.y = oldY;
                newBounds.height = nativeWindow.maxSize.y;
            }
            if (cancel)
            {
                event.preventDefault();
                stage.nativeWindow.bounds = newBounds;
                windowBoundsChanged = true;
                invalidateProperties();
            }
        }
        oldX = newBounds.x;
        oldY = newBounds.y;
    }

    /**
     *  @private
     */
    private function stage_fullScreenHandler(event:FullScreenEvent):void
    {
        //work around double events
        if (stage.displayState != lastDisplayState)
        {
            lastDisplayState = stage.displayState;
            if (stage.displayState == StageDisplayState.FULL_SCREEN ||
                stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE)
            {
                shouldShowTitleBar = showTitleBar;
                showTitleBar = false;
            }
            else
                showTitleBar = shouldShowTitleBar;
        }
    }       
        
    /**
     *  @private
     */
    private function window_closeEffectEndHandler(event:Event):void
    {
        removeEventListener("effectEnd", window_closeEffectEndHandler);
        if (!nativeWindow.closed)
            stage.nativeWindow.close();
    }

    /**
     *  @private
     */
    private function window_closingHandler(event:Event):void
    {
        var e:Event = new Event("closing", true, true);
        dispatchEvent(e);
        if (e.isDefaultPrevented())
        {
            event.preventDefault();
        }
        else if (getStyle("closeEffect") &&
                 stage.nativeWindow.transparent == true)
        {
            addEventListener("effectEnd", window_closeEffectEndHandler);
            dispatchEvent(new Event("windowClose"));
            event.preventDefault();
        }
    }

    /**
     *  @private
     */
    private function window_closeHandler(event:Event):void
    {
        dispatchEvent(new Event("close"));
    }
        
    /**
     *  @private
     */
    private function window_resizeHandler(event:NativeWindowBoundsEvent):void
    {
        // Only validateNow if we don't already have a window bounds
        // update pending. Otherwise, we'll miss a chance to layout with
        // the modified bounds.  ** We really should revisit why we call
        // validateNow here to begin with **.
        if (!windowBoundsChanged)
        {
            windowBoundsChanged= true;
            invalidateProperties();
            invalidateDisplayList();
            validateNow();
        }
        
        var e:FlexNativeWindowBoundsEvent =
                new FlexNativeWindowBoundsEvent(FlexNativeWindowBoundsEvent.WINDOW_RESIZE, event.bubbles, event.cancelable,
                event.beforeBounds, event.afterBounds);
        dispatchEvent(e);
     }

    /**
     *  @private
     */
    private function nativeApplication_activateHandler(event:Event):void
    {
        dispatchEvent(new AIREvent(AIREvent.APPLICATION_ACTIVATE));
    }

    /**
     *  @private
     */
    private function nativeApplication_deactivateHandler(event:Event):void
    {
        dispatchEvent(new AIREvent(AIREvent.APPLICATION_DEACTIVATE));
    }

    /**
     *  @private
     */
    private function nativeApplication_invokeHandler(event:InvokeEvent):void
    {
        // Because of the behavior with the nativeApplication invoke event
        // we queue events up until windowComplete
        if (invokesPending)
            initialInvokes.push(event);
        else
            dispatchEvent(event);
    }
    
    /**
     * @private
     */
    private function nativeWindow_activateHandler(event:Event):void
    {
        dispatchEvent(new AIREvent(AIREvent.WINDOW_ACTIVATE));
    }

    /**
     *  @private
     */
    private function nativeWindow_deactivateHandler(event:Event):void
    {
        dispatchEvent(new AIREvent(AIREvent.WINDOW_DEACTIVATE));
    }
    
    /**
     *  This is a temporary event handler which dispatches a initialLayoutComplete event after
     *  two updateCompletes. This event will only be dispatched after either setting the bounds or
     *  maximizing the window at startup.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private function updateComplete_handler(event:FlexEvent):void
    {
        if (ucCount == 1)
        {
            dispatchEvent(new Event("initialLayoutComplete"));
            removeEventListener(FlexEvent.UPDATE_COMPLETE, updateComplete_handler);
        }
        else
        {
            ucCount++;
        }
    }

    /**
     *  @private
     *  Returns a Function handler that resizes the view source HTML component with the stage.
     */
    private function viewSourceResizeHandler(html:HTML):Function
    {
        return function (e:FlexNativeWindowBoundsEvent):void
        {
            const win:DisplayObject = e.target;
            html.width  = win.width;
            html.height = win.height;
        };
    }

    /**
     *  @private
     *  Returns a Function handler that closes the View Source window when the parent closes.
     */
    private function viewSourceCloseHandler(win:Window):Function
    {
        return function ():void { win.close(); };
    }
    
   
}

}
