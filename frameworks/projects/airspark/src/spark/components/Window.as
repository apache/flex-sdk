////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{

import flash.desktop.NativeApplication;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.NativeWindow;
import flash.display.NativeWindowDisplayState;
import flash.display.NativeWindowInitOptions;
import flash.display.NativeWindowResize;
import flash.display.NativeWindowSystemChrome;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.NativeWindowBoundsEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.controls.FlexNativeMenu;
import mx.core.ContainerCreationPolicy;
import mx.core.FlexGlobals;
import mx.core.IVisualElement;
import mx.core.IWindow;
import mx.core.mx_internal;
import mx.core.UIComponent;
import mx.events.AIREvent;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.events.FlexNativeWindowBoundsEvent;
import mx.events.WindowExistenceEvent;
import mx.managers.CursorManagerImpl;
import mx.managers.DragManager;
import mx.managers.FocusManager;
import mx.managers.IActiveWindowManager;
import mx.managers.ICursorManager;
import mx.managers.ISystemManager;
import mx.managers.NativeDragManagerImpl;
import mx.managers.SystemManagerGlobals;
import mx.managers.WindowedSystemManager;
import mx.managers.systemClasses.ActiveWindowManager;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;

import spark.components.windowClasses.TitleBar;
import spark.components.supportClasses.TextBase;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  Alpha level of the color defined by the <code>backgroundColor</code>
 *  property.
 *   
 *  @default 1.0
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="backgroundAlpha", type="Number", inherit="no")]

/**
 *  The background color of the application. This color is used as the stage color for the
 *  application and the background color for the HTML embed tag.
 *   
 *  @default 0xFFFFFF
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="backgroundColor", type="uint", format="Color", inherit="no")]

/**
 *  Provides a margin of error around a window's border so a resize
 *  can be more easily started. A click on a window is considered a
 *  click on the window's border if the click occurs with the resizeAffordance
 *  number of pixels from the outside edge of the window.
 *  
 *  @default 6
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="resizeAffordanceWidth", type="Number", format="length", inherit="no")]

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when this application gets activated.
 *
 *  @eventType mx.events.AIREvent.APPLICATION_ACTIVATE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="applicationActivate", type="mx.events.AIREvent")]

/**
 *  Dispatched when this application gets deactivated.
 *
 *  @eventType mx.events.AIREvent.APPLICATION_DEACTIVATE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="applicationDeactivate", type="mx.events.AIREvent")]

/**
 *  Dispatched after the window has been activated.
 *
 *  @eventType mx.events.AIREvent.WINDOW_ACTIVATE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="windowActivate", type="mx.events.AIREvent")]

/**
 *  Dispatched after the window has been deactivated.
 *
 *  @eventType mx.events.AIREvent.WINDOW_DEACTIVATE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="windowDeactivate", type="mx.events.AIREvent")]

/**
 *  Dispatched after the window has been closed.
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
 *  Dispatched before the window closes.
 *  This event is cancelable.
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
 *  Dispatched after the display state changes
 *  to minimize, maximize or restore.
 *
 *  @eventType flash.events.NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="displayStateChange", type="flash.events.NativeWindowDisplayStateEvent")]

/**
 *  Dispatched before the display state changes
 *  to minimize, maximize or restore.
 *
 *  @eventType flash.events.NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="displayStateChanging", type="flash.events.NativeWindowDisplayStateEvent")]

/**
 *  Dispatched before the window moves,
 *  and while the window is being dragged.
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
 *  Dispatched before the underlying NativeWindow is resized, or
 *  while the Window object boundaries are being dragged.
 *
 *  @eventType flash.events.NativeWindowBoundsEvent.RESIZING
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="resizing", type="flash.events.NativeWindowBoundsEvent")]

/**
 *  Dispatched when the Window completes its initial layout
 *  and opens the underlying NativeWindow.
 *
 *  @eventType mx.events.AIREvent.WINDOW_COMPLETE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="windowComplete", type="mx.events.AIREvent")]

/**
 *  Dispatched after the window moves.
 *
 *  @eventType mx.events.FlexNativeWindowBoundsEvent.WINDOW_MOVE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="windowMove", type="mx.events.FlexNativeWindowBoundsEvent")]

/**
 *  Dispatched after the underlying NativeWindow is resized.
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
 *  The application is enabled and inactive.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("normalAndInactive")]

/**
 *  The application is disabled and inactive.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("disabledAndInactive")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[AccessibilityClass(implementation="spark.accessibility.WindowAccImpl")]

/**
 *  The frameworks must be initialized by WindowedSystemManager.
 *  This factoryClass will be automatically subclassed by any
 *  MXML applications that don't explicitly specify a different
 *  factoryClass.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Frame(factoryClass="mx.managers.WindowedSystemManager")]

[IconFile("../../mx/core/Window.png")]

[ResourceBundle("core")]

/**
 *  The Window is a top-level container for additional windows
 *  in an AIR desktop application.
 *
 *  <p>The Window container is a special kind of container in the sense
 *  that it cannot be used within other layout containers. An spark.components.Window
 *  component must be the top-level component in its MXML document.</p>
 *
 *  <p>The easiest way to use a Window component to define a native window is to
 *  create an MXML document with an <code>&lt;s:Window&gt;</code> tag
 *  as the top-level tag in the document. You use the Window component
 *  just as you do any other container, including specifying the layout
 *  type, defining child controls, and so forth. Like any other custom
 *  MXML component, when your application is compiled your MXML document
 *  is compiled into a custom class that is a subclass of the Window
 *  component.</p>
 *
 *  <p>In your application code, to make an instance of
 *  your Window subclass appear on the screen you first create an instance
 *  of the class in code (by defining a variable and calling the <code>new
 *  MyWindowClass()</code> constructor. Next you set any properties you wish
 *  to specify for the new window. Finally you call your Window component's
 *  <code>open()</code> method to open the window on the screen.</p>
 *
 *  <p>Note that several of the Window class's properties can only be set
 *  <strong>before</strong> calling the <code>open()</code> method to open
 *  the window. Once the underlying NativeWindow is created, these initialization
 *  properties can be read but cannot be changed. This restriction applies to
 *  the following properties:</p>
 *
 *  <ul>
 *    <li><code>maximizable</code></li>
 *    <li><code>minimizable</code></li>
 *    <li><code>resizable</code></li>
 *    <li><code>systemChrome</code></li>
 *    <li><code>transparent</code></li>
 *    <li><code>type</code></li>
 *  </ul>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:Window&gt;</code> tag inherits all of the tag
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:Window
 *    <strong>Properties</strong>
 *    alwaysInFront="false"
 *    backgroundColor="white"
 *    colorCorrection="default"
 *    maxHeight="2880 less the height of the system chrome"
 *    maximizable="true"
 *    maxWidth="2880 less the width of the system chrome"
 *    menu="<i>null</i>"
 *    minHeight="dependent on the operating system and the AIR systemChrome setting"
 *    minimizable="true"
 *    minWidth="dependent on the operating system and the AIR systemChrome setting"
 *    resizable="true"
 *    showStatusBar="true"
 *    status=""
 *    systemChrome="standard"
 *    title=""
 *    titleIcon="<i>null</i>"
 *    transparent="false"
 *    type="normal"
 *    visible="true"
 *    width="100"
 * 
 *    <strong>Effects</strong>
 *    closeEffect="<i>No default</i>"
 *    minimizeEffect="<i>No default</i>"
 *    unminimizeEffect="<i>No default</i>"
 * 
 *    <strong>Events</strong>
 *    applicationActivate="<i>No default</i>"
 *    applicationDeactivate="<i>No default</i>"
 *    close="<i>No default</i>"
 *    closing="<i>No default</i>"
 *    displayStateChange="<i>No default</i>"
 *    displayStateChanging="<i>No default</i>"
 *    moving="<i>No default</i>"
 *    networkChange="<i>No default</i>"
 *    resizing="<i>No default</i>"
 *    windowActivate="<i>No default</i>"
 *    windowComplete="<i>No default</i>"
 *    windowDeactivate="<i>No default</i>"
 *    windowMove="<i>No default</i>"
 *    windowResize="<i>No default</i>"
 *  /&gt;
 *  </pre>
 * 
 *  @see spark.components.WindowedApplication
 * 
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Window extends SkinnableContainer implements IWindow
{
    include "../../mx/core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class mixins
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Placeholder for mixin by WindowAccImpl.
     */
    mx_internal static var createAccessibilityImplementation:Function;

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
 
    /**
     *  The default height for a window (SDK-14399) 
     *  @private
     */
    private static const DEFAULT_WINDOW_HEIGHT:Number = 100;
    
    /**
     *  The default width for a window (SDK-14399) 
     *  @private
     */
    private static const DEFAULT_WINDOW_WIDTH:Number = 100;

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
     *  Returns the Window to which a component is parented.
     *
     *  @param component the component whose Window you wish to find.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static function getWindow(component:UIComponent):IWindow
    {
        if (component.systemManager is WindowedSystemManager)
            return WindowedSystemManager(component.systemManager).window;
        
        return null;
    }

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
    public function Window()
    {
        super();

        addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
        addEventListener(FlexEvent.PREINITIALIZE, preinitializeHandler);

        invalidateProperties();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var _nativeWindow:NativeWindow;

    /**
     *  @private
     */
    private var _nativeWindowVisible:Boolean = true;
    
    /**
     *  @private
     */
    private var maximized:Boolean = false;

    /**
     *  @private
     */
    private var _cursorManager:ICursorManager;
    
    
    /**
     *  @private
     */
    private var toMax:Boolean = false;

    /**
     *  @private
     *  Ensures that the Window has finished drawing
     *  before it becomes visible.
     */
    private var frameCounter:int = 0;

    /**
     *  @private
     */
    private var flagForOpen:Boolean = false;

    /**
     *   @private
     */
    private var openActive:Boolean = true;

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
     *  This flag indicates whether the width of the Application instance
     *  can change or has been explicitly set by the developer.
     *  When the stage is resized we use this flag to know whether the
     *  width of the Application should be modified.
     */
    private var resizeWidth:Boolean = true;

    /**
     *  @private
     *  This flag indicates whether the height of the Application instance
     *  can change or has been explicitly set by the developer.
     *  When the stage is resized we use this flag to know whether the
     *  height of the Application should be modified.
     */
    private var resizeHeight:Boolean = true;

    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  gripper
    //----------------------------------

    /**
     *  The skin part that defines the gripper button used to resize the window. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart (required="false")]
    public var gripper:Button;

    //----------------------------------
    //  statusBar
    //----------------------------------

    /**
     *  The skin part that defines the display of the status bar.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart (required = "false")]
    public var statusBar:IVisualElement;

    //----------------------------------
    //  statusText
    //----------------------------------

    /**
     *  The skin part that defines the display of the status bar's text.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart (required="false")]
    public var statusText:TextBase;
    
    //----------------------------------
    //  titleBar
    //----------------------------------

    /**
     *  The skin part that defines the title bar.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart (required="false")]
    public var titleBar:TitleBar;

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

        dispatchEvent(new Event("heightChanged"));
        // also dispatched in the resizeHandler
    }

    //----------------------------------
    //  maxHeight
    //----------------------------------

    /**
     *  @private
     *  Storage for the maxHeight property.
     */
    private var _maxHeight:Number = 2880;
    
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
     *  @private
     *  Specifies the maximum height of the application's window.
     *  
     *  @default dependent on the operating system and the AIR systemChrome setting. 
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
    private var _maxWidth:Number = 2880;
    
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
     *  @private
     *  Specifies the maximum width of the application's window.
     *  
     *  @default dependent on the operating system and the AIR systemChrome setting. 
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
     *  @private
     *  Specifies the minimum height of the application's window.
     *  
     *  @default dependent on the operating system and the AIR systemChrome setting. 
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
     *  @private
     *  Specifies the minimum width of the application's window.
     *  
     *  @default dependent on the operating system and the AIR systemChrome setting. 
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
     *  Controls the window's visibility. Unlike the
     *  <code>UIComponent.visible</code> property of most Flex
     *  visual components, this property affects the visibility
     *  of the underlying NativeWindow (including operating system
     *  chrome) as well as the visibility of the Window's child
     *  controls.
     *
     *  <p>When this property changes, Flex dispatches a <code>show</code>
     *  or <code>hide</code> event.</p>
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        setVisible(value);
    }
    
    /**
     *  @private
     *  We override setVisible because there's the flash display object concept 
     *  of visibility and also the nativeWindow concept of visibility.
     */
    override public function setVisible(value:Boolean,
                               noEvent:Boolean = false):void
    {
        // first handle the native window stuff
        if (!_nativeWindow)
        {
            _nativeWindowVisible = value;
            invalidateProperties();
        }
        else if (!_nativeWindow.closed)
        {
            if (value)
            {
                _nativeWindow.visible = value;
            }
            else
            {
                // in the conditions below we will play an effect
                if (getStyle("hideEffect") && initialized && $visible != value)
                    addEventListener(EffectEvent.EFFECT_END, hideEffectEndHandler);
                else
                    _nativeWindow.visible = value;
            }
        }
        
        // now call super.setVisible
        super.setVisible(value, noEvent);
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

        dispatchEvent(new Event("widthChanged"));
        // also dispatched in the resize handler
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    // alwaysInFront
    //----------------------------------

    /**
     *  @private
     *  Storage for the alwaysInFront property.
     */
    private var _alwaysInFront:Boolean = false;

    /**
     *  Determines whether the underlying NativeWindow is always in front
     *  of other windows (including those of other applications). Setting
     *  this property sets the <code>alwaysInFront</code> property of the
     *  underlying NativeWindow. See the <code>NativeWindow.alwaysInFront</code>
     *  property description for details of how this affects window stacking
     *  order.
     *
     *  @see flash.display.NativeWindow#alwaysInFront
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
    //  bounds
    //----------------------------------

    /**
     *  @private
     *  Storage for the bounds property.
     */
    private var _bounds:Rectangle = new Rectangle(0, 0, DEFAULT_WINDOW_WIDTH, DEFAULT_WINDOW_HEIGHT);

    /**
     *  @private
     */
    private var boundsChanged:Boolean = false;

    /**
     *  @private
     *  A Rectangle specifying the window's bounds
     *  relative to the screen.
     */
    protected function get bounds():Rectangle
    {
        return _bounds;
    }

    /**
     *  @private
     */
    protected function set bounds(value:Rectangle):void
    {
        _bounds = value;
        boundsChanged = true;

        invalidateProperties();
        invalidateSize();
    }

    //----------------------------------
    //  closed
    //----------------------------------

    /**
     *  A flag indicating whether the window has been closed.
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
    //  colorCorrection
    //----------------------------------
    
    [Inspectable(enumeration="default,off,on", defaultValue="default" )]
    
   /**
    *  The value of the stage's <code>colorCorrection</code> property. If this application
    *  does not have access to the stage's <code>colorCorrection</code> property, 
    *  the value of the <code>colorCorrection</code> property will be reported as 
    *  null. Only the main application is allowed to set the <code>colorCorrection</code>
    *  property. If a sub-application's needs to set the color correction property it will
    *  need to set it via the main application's instance, either directly using an object
    *  instance or via an event (there is no framework event for this purpose).  
    *
    *  @default ColorCorrection.DEFAULT
    *  
    *  @langversion 3.0
    *  @playerversion AIR 1.5
    *  @productversion Flex 4
    */
    public function get colorCorrection():String
    {
        try
        {
            var sm:ISystemManager = systemManager;
            if (sm && sm.stage)
                return sm.stage.colorCorrection;
        }
        catch (e:SecurityError)
        {
            // ignore error if this application is not allow
            // to view the colorCorrection property.
        }

        return null;
    }

    /**
     * @private
     */
    public function set colorCorrection(value:String):void
    {
        // Since only the main application is allowed to change the value this property, there
        // is no need to catch security violations like in the getter.
        var sm:ISystemManager = systemManager;
        if (sm && sm.stage && sm.isTopLevelRoot())
            sm.stage.colorCorrection = value;
    }
    
    //----------------------------------
    //  maximizable
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the maximizable property.
     */
    private var _maximizable:Boolean = true;
    
    /**
     *  Specifies whether the window can be maximized.
     *  This property's value is read-only after the window
     *  has been opened.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get maximizable():Boolean
    {
        return _maximizable;
    }
    
    /**
     *  @private
     */
    public function set maximizable(value:Boolean):void
    {
        if (!_nativeWindow)
        {
            _maximizable = value;

            invalidateProperties();
        }
    }
    
    //----------------------------------
    //  menu
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the menu property.
     */
    private var _menu:FlexNativeMenu;

    //----------------------------------
    //  cursorManager
    //----------------------------------
    /**
     *  @private
     *  Returns the cursor manager for this Window.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function get cursorManager():ICursorManager
    {
        return _cursorManager;
    }


    /**
     *  @private
     */
    private var menuChanged:Boolean = false;

    /**
     *  @private
     */
    public function get menu():FlexNativeMenu
    {
        return _menu;
    }

    /**
     *  The window menu for this window.
     *  Some operating systems do not support window menus,
     *  in which case this property is ignored.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function set menu(value:FlexNativeMenu):void
    {
        if (_menu)
        {
            _menu.automationParent = null;
            _menu.automationOwner = null;
        }
        
        _menu = value;
        menuChanged = true;
        
        if (_menu)
        {
            menu.automationParent = this;
            menu.automationOwner = this;
        }
    }
    
    //----------------------------------
    //  minimizable
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the minimizable property.
     */
    private var _minimizable:Boolean = true;
    
    /**
     *  Specifies whether the window can be minimized.
     *  This property is read-only after the window has
     *  been opened.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get minimizable():Boolean
    {
        return _minimizable;
    }

    /**
     *  @private
     */
    public function set minimizable(value:Boolean):void
    {
        if (!_nativeWindow)
        {
            _minimizable = value;

            invalidateProperties();
        }
    }
    
    //----------------------------------
    //  nativeWindow
    //----------------------------------

    /**
     *  The underlying NativeWindow that this Window component uses.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get nativeWindow():NativeWindow
    {
        if (systemManager && systemManager.stage)
            return systemManager.stage.nativeWindow;
        
        return null;
    }

    //----------------------------------
    //  resizable
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the resizable property.
     */
    private var _resizable:Boolean = true;
    
    /**
     *  Specifies whether the window can be resized.
     *  This property is read-only after the window
     *  has been opened.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get resizable():Boolean
    {
        return _resizable;
    }

    /**
     *  @private
     */
    public function set resizable(value:Boolean):void
    {

        if (!_nativeWindow)
        {
            _resizable = value;

            invalidateProperties();
        }
    }
    
    //----------------------------------
    //  showStatusBar
    //----------------------------------

    /**
     *  Storage for the showStatusBar property.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private var _showStatusBar:Boolean = true;

    /**
     *  @private
     */
    private var showStatusBarChanged:Boolean = true;

    /**
     *  If <code>true</code>, the status bar is visible.
     *
     *  <p>The status bar only appears when you use the WindowedApplicationSkin
     *  class or the SparkChromeWindowedApplicationSkin class as the skin for 
     *  your application or any of your application's windows.</p>
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
     *  @private
     *  Storage for the systemChrome property.
     */
    private var _systemChrome:String = NativeWindowSystemChrome.STANDARD;
    
    /**
     *  Specifies the type of system chrome (if any) the window has.
     *  The set of possible values is defined by the constants
     *  in the NativeWindowSystemChrome class.
     *
     *  <p>This property is read-only once the window has been opened.</p>
     *
     *  <p>The default value is <code>NativeWindowSystemChrome.STANDARD</code>.</p>
     *
     *  @see flash.display.NativeWindowSystemChrome
     *  @see flash.display.NativeWindowInitOptions#systemChrome
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get systemChrome():String
    {
        return _systemChrome;
    }

    /**
     *  @private
     */
    public function set systemChrome(value:String):void
    {
        if (!_nativeWindow)
        {
            _systemChrome = value;

            invalidateProperties();
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
     *  The title text that appears in the window title bar and
     *  the taskbar.
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
        titleChanged = true;
        _title = value;

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
     *  Storage for the titleIcon property.
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
     *  @private
     *  Storage for the transparent property.
     */
    private var _transparent:Boolean = false;
    
    /**
     *  Specifies whether the window is transparent. Setting this
     *  property to <code>true</code> for a window that uses
     *  system chrome is not supported.
     *
     *  <p>This property is read-only after the window has been opened.</p>
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get transparent():Boolean
    {
        return _transparent;
    }

    /**
     *  @private
     */
    public function set transparent(value:Boolean):void
    {
        if (!_nativeWindow)
        {
            _transparent = value;

            invalidateProperties();
        }
    }
    
    //----------------------------------
    //  type
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the type property.
     */
    private var _type:String = "normal";
    
    /**
     *  Specifies the type of NativeWindow that this component
     *  represents. The set of possible values is defined by the constants
     *  in the NativeWindowType class.
     *
     *  <p>This property is read-only once the window has been opened.</p>
     *
     *  <p>The default value is <code>NativeWindowType.NORMAL</code>.</p>
     *
     *  @see flash.display.NativeWindowType
     *  @see flash.display.NativeWindowInitOptions#type
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get type():String
    {
        return _type;
    }
    
    /**
     *  @private
     */
    public function set type(value:String):void
    {
        if (!_nativeWindow)
        {
            _type = value;

            invalidateProperties();
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
    override protected function initializeAccessibility():void
    {
        if (Window.createAccessibilityImplementation != null)
            Window.createAccessibilityImplementation(this);
    }

    /**
     *  @private
     */
    override protected function createChildren():void
    {
        // this is to help initialize the stage
        width = _bounds.width;
        height = _bounds.height;

        super.createChildren();
    }
    

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        // Create and open window.
        if (flagForOpen && !_nativeWindow)
        {
            flagForOpen = false;
            
            // Set up our module factory if we don't have one.
            if (moduleFactory == null)
                moduleFactory = SystemManagerGlobals.topLevelSystemManagers[0];

            var init:NativeWindowInitOptions = new NativeWindowInitOptions();
            init.maximizable = _maximizable;
            init.minimizable = _minimizable;
            init.resizable = _resizable;
            init.type = _type;
            init.systemChrome = _systemChrome;
            init.transparent = _transparent;
            
            _nativeWindow = new NativeWindow(init);
            var sm:WindowedSystemManager = new WindowedSystemManager(this);
            _nativeWindow.stage.addChild(sm);
            systemManager = sm;
            
            sm.window = this;
            
            _nativeWindow.alwaysInFront = _alwaysInFront;
            initManagers(sm);
            addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
    
            var nativeApplication:NativeApplication = NativeApplication.nativeApplication;
            nativeApplication.addEventListener(Event.ACTIVATE, nativeApplication_activateHandler, false, 0, true);
            nativeApplication.addEventListener(Event.DEACTIVATE, nativeApplication_deactivateHandler, false, 0, true);
            nativeApplication.addEventListener(Event.NETWORK_CHANGE, dispatchEvent, false, 0, true);
            _nativeWindow.addEventListener(Event.ACTIVATE, nativeWindow_activateHandler, false, 0, true);
            _nativeWindow.addEventListener(Event.DEACTIVATE, nativeWindow_deactivateHandler, false, 0, true);
            
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
            
            //'register' with WindowedSystemManager so it can cleanup when done.
            sm.addWindow(this);
        }
        
        // Moved the super.commitProperites() to here to allow the Window subclass to be
        // initialized. Part of the initialization is loading the skin of the Window subclass.
        // At this point we can call into SkinnableComponent.commitProperties without getting
        // a "skin was not found" error.
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
            // Work around an AIR issue setting the stageHeight to zero when 
            // using system chrome. The set of the stage.stageHeight property
            // is rejected unless the nativeWindow is first set to the proper
            // height. 
            // Don't perform this workaround if the window has zero height due 
            // to being minimized. Setting the nativeWindow height to non-zero 
            // causes AIR to restore the window.
            if (_bounds.height == 0 && 
                nativeWindow.displayState != NativeWindowDisplayState.MINIMIZED &&
                systemChrome == NativeWindowSystemChrome.STANDARD)
                nativeWindow.height = chromeHeight() + _bounds.height;
                
            // We use temporary variables because when we set stageWidth or 
            // stageHeight _bounds will be overwritten when we receive 
            // a RESIZE event.
            var newWidth:Number  = _bounds.width;
            var newHeight:Number = _bounds.height;
            systemManager.stage.stageWidth = newWidth;
            systemManager.stage.stageHeight = newHeight;
            boundsChanged = false;
        }

        if (menuChanged && !nativeWindow.closed)
        {
            menuChanged = false;
            
            if (menu == null)
            {
                if (NativeWindow.supportsMenu)
                    nativeWindow.menu = null;
            }
            else if (menu.nativeMenu)
            {
                if (NativeWindow.supportsMenu)
                    nativeWindow.menu = menu.nativeMenu;
            }
            
            dispatchEvent(new Event("menuChanged"));
        }

        if (titleIconChanged)
        {
            if (titleBar)
                titleBar.titleIcon = _titleIcon;
            titleIconChanged = false;
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
                statusBar.visible = _showStatusBar;
            showStatusBarChanged = false;
        }

        if (statusChanged)
        {
            if (statusText)
                statusText.text = _status;
            statusChanged = false;
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

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: SkinnableContainer
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == statusBar)
        {
            statusBar.visible = _showStatusBar;
            statusBar.includeInLayout = _showStatusBar;
            showStatusBarChanged = false;
        }
        else if (instance == titleBar)
        {
            if (!nativeWindow.closed)
            {
                // If the initial title is the default and the native window is set
                // from the initial window settings, 
                // then use the initial window settings title.
                if (_title == "" && systemManager.stage.nativeWindow.title != null)
                    _title = systemManager.stage.nativeWindow.title;
                else
                    systemManager.stage.nativeWindow.title = _title;                
            }

            titleBar.title = _title;
            titleChanged = false;
        }
        else if (instance == statusText)
        {
            statusText.text = status;
            statusChanged = false;    
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
        super.partRemoved(partName, instance);
        
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
     *  Closes the window. This action is cancelable.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function close():void
    {
        if (_nativeWindow && !nativeWindow.closed)
        {
            var e:Event = new Event("closing", false, true);
            stage.nativeWindow.dispatchEvent(e);
            if (!(e.isDefaultPrevented()))
            {
                stage.nativeWindow.close();
                _nativeWindow = null;
                systemManager.removeChild(this);
            }
        }
    }

    /**
     *  @private
     */
    private function initManagers(sm:ISystemManager):void
    {
        if (sm.isTopLevel())
        {
            focusManager = new FocusManager(this);
            var awm:IActiveWindowManager = 
                IActiveWindowManager(sm.getImplementation("mx.managers::IActiveWindowManager"));
            if (awm)
                awm.activate(this);
            else
                focusManager.activate();
            _cursorManager = new CursorManagerImpl(sm);
        }
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
        if (stage.nativeWindow.displayState!= NativeWindowDisplayState.MAXIMIZED)
        {
            var f:NativeWindowDisplayStateEvent = new NativeWindowDisplayStateEvent(
                        NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
                        false, true, stage.nativeWindow.displayState,
                        NativeWindowDisplayState.MAXIMIZED);
            stage.nativeWindow.dispatchEvent(f);
            if (!f.isDefaultPrevented())
            {
                toMax = true;
                invalidateProperties();
                invalidateSize();
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
        if (!minimizable)
            return;
            
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
     *  Activates the underlying NativeWindow (even if this Window's application
     *  is not currently active).
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function activate():void
    {
        if (!nativeWindow.closed)
            _nativeWindow.activate();   
    }

    /**
     *  Creates the underlying NativeWindow and opens it.
     * 
     *  After being closed, the Window object is still a valid reference, but 
     *  accessing most properties and methods will not work.
     *  Closed windows cannot be reopened.
     *
     *  @param  openWindowActive specifies whether the Window opens
     *  activated (that is, whether it has focus). The default value
     *  is <code>true</code>.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function open(openWindowActive:Boolean = true):void
    {
        // Event for Automation so we know when windows 
        // are created or destroyed.
        if (FlexGlobals.topLevelApplication)
        {
            FlexGlobals.topLevelApplication.dispatchEvent(
                new WindowExistenceEvent(WindowExistenceEvent.WINDOW_CREATING, 
                    false, false, this));
        }
        
        flagForOpen = true;
        openActive = openWindowActive;
        commitProperties();
    }
    
    /**
     *  Orders the window just behind another. To order the window behind
     *  a NativeWindow that does not implement IWindow, use this window's
     *  nativeWindow's <code>orderInBackOf()</code> method.
     *
     *  @param window The IWindow (Window or WindowedAplication)
     *  to order this window behind.
     *
     *  @return <code>true</code> if the window was successfully sent behind;
     *          <code>false</code> if the window is invisible or minimized.
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
     *  window's nativeWindow's  <code>orderInFrontOf()</code> method.
     *
     *  @param window The IWindow (Window or WindowedAplication)
     *  to order this window in front of.
     *
     *  @return <code>true</code> if the window was successfully sent in front;
     *          <code>false</code> if the window is invisible or minimized.
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
     *  @return <code>true</code> if the window was successfully sent to the back;
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
     *  @return <code>true</code> if the window was successfully sent to the front;
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
     *  @private
     *  Returns the name of the state to be applied to the skin. For example, a
     *  Button component could return the String "up", "down", "over", or "disabled" 
     *  to specify the state.
     * 
     *  <p>A subclass of SkinnableComponent must override this method to return a value.</p>
     * 
     *  @return A string specifying the name of the state to apply to the skin.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function getCurrentSkinState():String 
    {

        if (nativeWindow.closed)
            return "disabled";

        if (nativeWindow.active)
            return enabled ? "normal" : "disabled";
        else
            return enabled ? "normalAndInactive" : "disabledAndInactive";

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
     *  Starts a system resize.
     */
    private function startResize(start:String):void
    {
        if (resizable && !nativeWindow.closed)
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
    private function enterFrameHandler(e:Event):void
    {
        if (frameCounter == 2)
        {
            removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
            _nativeWindow.visible = _nativeWindowVisible;
            dispatchEvent(new AIREvent(AIREvent.WINDOW_COMPLETE));
            
            // Event for Automation so we know when windows 
            // are created or destroyed.
            if (FlexGlobals.topLevelApplication)
            {
                FlexGlobals.topLevelApplication.dispatchEvent(
                    new WindowExistenceEvent(WindowExistenceEvent.WINDOW_CREATE, 
                                             false, false, this));
            }
            
            if (_nativeWindow.visible)
            {
                if (openActive)
                    _nativeWindow.activate();
            }
        }
        frameCounter++;
    }

    /**
     *  @private
     */
    private function hideEffectEndHandler(event:Event):void
    {
        if (!_nativeWindow.closed)
            _nativeWindow.visible = false;
        removeEventListener(EffectEvent.EFFECT_END, hideEffectEndHandler);
    }

    /**
     *  @private
     */
    private function windowMinimizeHandler(event:Event):void
    {
        if (!nativeWindow.closed)
            stage.nativeWindow.minimize();
        removeEventListener(EffectEvent.EFFECT_END, windowMinimizeHandler);
    }

    /**
     *  @private
     */
    private function windowUnminimizeHandler(event:Event):void
    {
        removeEventListener(EffectEvent.EFFECT_END, windowUnminimizeHandler);
    }

    /**
     *  @private
     */
    private function window_moveHandler(event:NativeWindowBoundsEvent):void
    {
        var newEvent:FlexNativeWindowBoundsEvent =
            new FlexNativeWindowBoundsEvent(
                FlexNativeWindowBoundsEvent.WINDOW_MOVE,
                event.bubbles, event.cancelable,
                event.beforeBounds, event.afterBounds);
        dispatchEvent(newEvent);
    }

    /**
     *  @private
     */
    private function window_displayStateChangeHandler(
                            event:NativeWindowDisplayStateEvent):void
    {
        // Redispatch event .
        dispatchEvent(event);

        height = stage.stageHeight;
        width = stage.stageWidth;

        // Restored from a minimized state.
        if (event.beforeDisplayState == NativeWindowDisplayState.MINIMIZED)
        {
            addEventListener(EffectEvent.EFFECT_END, windowUnminimizeHandler);
            dispatchEvent(new Event("windowUnminimize"));
        }
    }

    /**
     *  @private
     */
    private function window_displayStateChangingHandler(
                            event:NativeWindowDisplayStateEvent):void
    {
        // Redispatch event for cancellation purposes.
        dispatchEvent(event);

        if (event.isDefaultPrevented())
            return;
        if (event.afterDisplayState == NativeWindowDisplayState.MINIMIZED)
        {
            if (getStyle("minimizeEffect"))
            {
                event.preventDefault();
                addEventListener(EffectEvent.EFFECT_END, windowMinimizeHandler);
                dispatchEvent(new Event("windowMinimize"));
            }
        }

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
        if (event.target == gripper)
        {
            startResize(NativeWindowResize.BOTTOM_RIGHT);
            event.stopPropagation();
            return;
        }

        if (systemManager.stage.nativeWindow.systemChrome != "none")
            return;

        var edgeOrCorner:String = hitTestResizeEdge(event);
        if (edgeOrCorner != NativeWindowResize.NONE)
        {
            startResize(edgeOrCorner);
            event.stopPropagation();
        }
    }

    /**
     *   @private
     *  
     *   Perform a hit test to determine if an edge or corner of the application
     *   was clicked.
     * 
     *   @param event The mouse event to hit test.
     *  
     *   @return If an edge or corner was click return one of the constants from
     *   the NativeWindowResize to indicate the edit or corner that was clicked. If
     *   no edge or corner were clicked then return NativeWindowResize.NONE.
     */
    mx_internal function hitTestResizeEdge(event:MouseEvent):String
    {
        // If we clicked on a child of the contentGroup, then don't resize
        if (event.target is DisplayObject && event.target != contentGroup)
        {
           var o:DisplayObject = DisplayObject(event.target);
            while (o != contentGroup && o != this)
                o = o.parent;
    
            if (o == contentGroup)
                return NativeWindowResize.NONE;
        }
            
        var hitTestResults:String = NativeWindowResize.NONE;
        var resizeAfforanceWidth:Number = getStyle("resizeAffordanceWidth");
        var borderWidth:int = resizeAfforanceWidth;
        var cornerSize:int = resizeAfforanceWidth * 2;
        
        if (event.stageY < borderWidth)
        {
            if (event.stageX < cornerSize)
                hitTestResults = NativeWindowResize.TOP_LEFT;
            else if (event.stageX > width - cornerSize)
                hitTestResults = NativeWindowResize.TOP_RIGHT;
            else
                hitTestResults = NativeWindowResize.TOP;
        }
        else if (event.stageY > (height - borderWidth))
        {
            if (event.stageX < cornerSize)
                hitTestResults = NativeWindowResize.BOTTOM_LEFT;
            else if (event.stageX > width - cornerSize)
                hitTestResults = NativeWindowResize.BOTTOM_RIGHT;
            else
                hitTestResults = NativeWindowResize.BOTTOM;
        }
        else if (event.stageX < borderWidth )
        {
            if (event.stageY < cornerSize)
                hitTestResults = NativeWindowResize.TOP_LEFT;
            else if (event.stageY > height - cornerSize)
                hitTestResults = NativeWindowResize.BOTTOM_LEFT;
            else
                hitTestResults = NativeWindowResize.LEFT;
        }
        else if (event.stageX > width - borderWidth)
        {
            if (event.stageY < cornerSize)
                hitTestResults = NativeWindowResize.TOP_RIGHT;
            else if (event.stageY > height - cornerSize)
                hitTestResults = NativeWindowResize.BOTTOM_RIGHT;
            else
                hitTestResults = NativeWindowResize.RIGHT;
        }
    
        return hitTestResults;
    }

    /**
     *  @private
     */
    private function creationCompleteHandler(event:Event = null):void
    {
        systemManager.stage.nativeWindow.addEventListener(
            "closing", window_closingHandler);

        systemManager.stage.nativeWindow.addEventListener(
            "close", window_closeHandler, false, 0, true);
                        
        systemManager.stage.nativeWindow.addEventListener(
            NativeWindowBoundsEvent.MOVING, window_boundsHandler);

        systemManager.stage.nativeWindow.addEventListener(
            NativeWindowBoundsEvent.MOVE, window_moveHandler);

        systemManager.stage.nativeWindow.addEventListener(
            NativeWindowBoundsEvent.RESIZING, window_boundsHandler);

        systemManager.stage.nativeWindow.addEventListener(
           NativeWindowBoundsEvent.RESIZE, window_resizeHandler);

    }

    /**
     *  @private
     */
    private function preinitializeHandler(event:FlexEvent):void
    {
        systemManager.stage.nativeWindow.addEventListener(
            NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
            window_displayStateChangingHandler);
        systemManager.stage.nativeWindow.addEventListener(
            NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,
            window_displayStateChangeHandler);
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
            }
        }
        oldX = newBounds.x;
        oldY = newBounds.y;
    }

    /**
     *  @private
     */
    private function window_closeEffectEndHandler(event:Event):void
    {
        removeEventListener(EffectEvent.EFFECT_END, window_closeEffectEndHandler);
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
            addEventListener(EffectEvent.EFFECT_END, window_closeEffectEndHandler);
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
        
        // Event for Automation so we know when windows 
        // are created or destroyed.
        if (FlexGlobals.topLevelApplication)
        {
            FlexGlobals.topLevelApplication.dispatchEvent(
                new WindowExistenceEvent(WindowExistenceEvent.WINDOW_CLOSE, 
                                         false, false, this));
        }
    }
    
    /**
     *  @private
     */
    private function window_resizeHandler(event:NativeWindowBoundsEvent):void
    {
        invalidateDisplayList();

        var dispatchWidthChangeEvent:Boolean = (bounds.width != stage.stageWidth);
        var dispatchHeightChangeEvent:Boolean = (bounds.height != stage.stageHeight);

        bounds.x = stage.x;
        bounds.y = stage.y;
        bounds.width = stage.stageWidth;
        bounds.height = stage.stageHeight;

        validateNow();
        var e:FlexNativeWindowBoundsEvent =
            new FlexNativeWindowBoundsEvent(FlexNativeWindowBoundsEvent.WINDOW_RESIZE, event.bubbles, event.cancelable,
                    event.beforeBounds, event.afterBounds);
        dispatchEvent(e);

        if (dispatchWidthChangeEvent)
            dispatchEvent(new Event("widthChanged"));
        if (dispatchHeightChangeEvent)
            dispatchEvent(new Event("heightChanged"));
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
    private function nativeWindow_activateHandler(event:Event):void
    {
        dispatchEvent(new AIREvent(AIREvent.WINDOW_ACTIVATE));
        invalidateSkinState();
    }   
    
    /**
     *  @private
     */
    private function nativeWindow_deactivateHandler(event:Event):void
    {
        dispatchEvent(new AIREvent(AIREvent.WINDOW_DEACTIVATE));
        invalidateSkinState();
    }
    
}

}
