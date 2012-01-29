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

package mx.managers
{
    
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.getClassByAlias;
import flash.net.registerClassAlias;
import flash.system.ApplicationDomain;
import flash.text.Font;
import flash.text.TextFormat;
import flash.ui.ContextMenu;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import mx.core.EventPriority;
import mx.core.FlexSprite;
import mx.core.IChildList;
import mx.core.IFlexDisplayObject;
import mx.core.IFlexModule;
import mx.core.IFlexModuleFactory;
import mx.core.IUIComponent;
import mx.core.Singleton;
import mx.core.IWindow;
import mx.core.mx_internal;
import mx.events.SandboxMouseEvent;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.events.EventListenerRequest;
import mx.events.Request;
import mx.managers.systemClasses.ChildManager;
import mx.styles.ISimpleStyleClient;
import mx.styles.IStyleClient;
import mx.utils.NameUtil;
import mx.utils.ObjectUtil;

use namespace mx_internal;

/**
 *  The WindowedSystemManager class manages any non-Application windows in a 
 *  Flex-based AIR application. This includes all windows that are instances of 
 *  the Window component or a Window subclass, but not a WindowedApplication 
 *  window. For those windows, the WindowedSystemManager serves the same role 
 *  that a SystemManager serves for a WindowedApplication instance or an 
 *  Application instance in a browser-based Flex application.
 * 
 *  <p>As this comparison suggests, the WindowedSystemManager class serves 
 *  many roles. For instance, it is the root display object of a Window, and 
 *  manages tooltips, cursors, popups, and other content for the Window.</p>
 * 
 *  @see mx.managers.SystemManager
 * 
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class WindowedSystemManager extends MovieClip implements ISystemManager
{
    
    public function WindowedSystemManager(rootObj:IUIComponent)
    {
        super();
        _topLevelSystemManager = this;
        topLevelWindow = rootObj;
        SystemManagerGlobals.topLevelSystemManagers.push(this);
        childManager = new ChildManager(this);
        //docFrameHandler(null);
        addEventListener(Event.ADDED, docFrameHandler);
    }
    
	mx_internal var topLevel:Boolean = true;
	
	private var initialized:Boolean = false;
	
	/**
	 *  @private
	 *  The top level window.
	 */
	mx_internal var topLevelWindow:IUIComponent;
	
	/**
	 *  @private
	 *  pointer to Window, for cleanup
	 */
	private var myWindow:IWindow;
	
	/**
	 *  @private
	 */
	private var _topLevelSystemManager:ISystemManager;
	
    /**
     *  @private
     *  The childAdded/removed code
     */
    mx_internal var childManager:ISystemManagerChildManager;

	/**
	 *  @private
	 *  Whether we are the stage root or not.
	 *  We are only the stage root if we were the root
	 *  of the first SWF that got loaded by the player.
	 *  Otherwise we could be top level but not stage root
	 *  if we are loaded by some other non-Flex shell
	 *  or are sandboxed.
	 */
	private var isStageRoot:Boolean = true;

    /**
     *  @private
     *  Number of frames since the last mouse or key activity.
     */
    mx_internal var idleCounter:int = 0;
    
    /**
     *  @private
     *  Whether we are the first SWF loaded into a bootstrap
     *  and therefore, the topLevelRoot
     */
    private var isBootstrapRoot:Boolean = false;

    /**
     *  Depth of this object in the containment hierarchy.
     *  This number is used by the measurement and layout code.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    mx_internal var nestLevel:int = 0;

	/**
	 *  @private
	 *  The mouseCatcher is the 0th child of the SystemManager,
	 *  behind the application, which is child 1.
	 *  It is the same size as the stage and is filled with
	 *  transparent pixels; i.e., they've been drawn, but with alpha 0.
	 *
	 *  Its purpose is to make every part of the stage
	 *  able to detect the mouse.
	 *  For example, a Button puts a mouseUp handler on the SystemManager
	 *  in order to capture mouseUp events that occur outside the Button.
	 *  But if the children of the SystemManager don't have "drawn-on"
	 *  pixels everywhere, the player won't dispatch the mouseUp.
	 *  We can't simply fill the SystemManager itself with
	 *  transparent pixels, because the player's pixel detection
	 *  logic doesn't look at pixels drawn into the root DisplayObject.
	 *
	 *  Here is an example of what would happen without the mouseCatcher:
	 *  Run a fixed-size Application (e.g. width="600" height="600")
	 *  in the standalone player. Make the player window larger
	 *  to reveal part of the stage. Press a Button, drag off it
	 *  into the stage area, and release the mouse button.
	 *  Without the mouseCatcher, the Button wouldn't return to its "up" state.
	 */
	private var mouseCatcher:Sprite;
	
    //----------------------------------
    //  applicationIndex
    //----------------------------------

    /**
     *  @private
     *  Storage for the applicationIndex property.
     */
    private var _applicationIndex:int = 1;

    /**
     *  @private
     *  The index of the main mx.core.Application window, which is
     *  effectively its z-order.
     */
    mx_internal function get applicationIndex():int
    {
        return _applicationIndex;
    }

    /**
     *  @private
     */
    mx_internal function set applicationIndex(value:int):void
    {
        _applicationIndex = value;
    }
    
    
    //-----------------------------------
    //  ISystemManager implementations
    //-----------------------------------
        
    //----------------------------------
    //  cursorChildren
    //----------------------------------

    /**
     *  @private
     *  Storage for the cursorChildren property.
     */
    private var _cursorChildren:WindowedSystemChildrenList;

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get cursorChildren():IChildList
    {
        if (!topLevel)
            return _topLevelSystemManager.cursorChildren;

        if (!_cursorChildren)
        {
            _cursorChildren = new WindowedSystemChildrenList(this,
                new QName(mx_internal, "toolTipIndex"),
                new QName(mx_internal, "cursorIndex"));
        }

        return _cursorChildren;
    }
    
    //----------------------------------
    //  cursorIndex
    //----------------------------------

    /**
     *  @private
     *  Storage for the toolTipIndex property.
     */
    private var _cursorIndex:int = 0;

    /**
     *  @private
     *  The index of the highest child that is a cursor.
     */
    mx_internal function get cursorIndex():int
    {
        return _cursorIndex;
    }

    /**
     *  @private
     */
    mx_internal function set cursorIndex(value:int):void
    {
        var delta:int = value - _cursorIndex;
        _cursorIndex = value;
    }
    
    //----------------------------------
    //  document
    //----------------------------------

    /**
     *  @private
     *  Storage for the document property.
     */
    private var _document:Object;

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get document():Object
    {
        return _document;
    }

    /**
     *  @private
     */
    public function set document(value:Object):void
    {
        _document = value;
    }
    
    //----------------------------------
    //  embeddedFontList
    //----------------------------------

    /**
     *  @private
     *  Storage for the fontList property.
     */
    private var _fontList:Object = null;

    /**
     *  A table of embedded fonts in this application.  The 
     *  object is a table indexed by the font name.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get embeddedFontList():Object
    {
        if (_fontList == null)
        {
            _fontList = {};

            var o:Object = info()["fonts"];

            var p:String;

            for (p in o)
            {
                _fontList[p] = o[p];
            }

            // FIXME: font rules across SWF boundaries have not been finalized!

            // Top level systemManager may not be defined if SWF is loaded
            // as a background image in download progress bar.
            if (!topLevel && _topLevelSystemManager)                   
            {
                var fl:Object = _topLevelSystemManager.embeddedFontList;
                for (p in fl)
                {
                    _fontList[p] = fl[p];
                }
            }
        }

        return _fontList;
    }
    
    //----------------------------------
    //  focusPane
    //----------------------------------

    /**
     *  @private
     */
    private var _focusPane:Sprite;

    /**
     *  @copy mx.core.UIComponent#focusPane
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get focusPane():Sprite
    {
        return _focusPane;
    }

    /**
     *  @private
     */
    public function set focusPane(value:Sprite):void
    {
        if (value)
        {
            addChild(value);

            value.x = 0;
            value.y = 0;
            value.scrollRect = null;

            _focusPane = value;
        }
        else
        {
            removeChild(_focusPane);

            _focusPane = null;
        }
    }

    //----------------------------------
    //  isProxy
    //----------------------------------

	/**
	 *  True if SystemManager is a proxy and not a root class
	 */
	public function get isProxy():Boolean
	{
		return false;
	}

	//----------------------------------
	//  $numChildren
	//----------------------------------

    /**
     *  @private
     *  This property allows access to the Player's native implementation
     *  of the numChildren property, which can be useful since components
     *  can override numChildren and thereby hide the native implementation.
     *  Note that this "base property" is final and cannot be overridden,
     *  so you can count on it to reflect what is happening at the player level.
     */
    mx_internal final function get $numChildren():int
    {
        return super.numChildren;
    }

    //----------------------------------
    //  numModalWindows
    //----------------------------------

    /**
     *  @private
     *  Storage for the numModalWindows property.
     */
    private var _numModalWindows:int = 0;

    /**
     *  The number of modal windows.  Modal windows don't allow
     *  clicking in another windows which would normally
     *  activate the FocusManager in that window.  The PopUpManager
     *  modifies this count as it creates and destroys modal windows.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get numModalWindows():int
    {
        return _numModalWindows;
    }

    /**
     *  @private
     */
    public function set numModalWindows(value:int):void
    {
        _numModalWindows = value;
    }
//----------------------------------
    //  popUpChildren
    //----------------------------------

    /**
     *  @private
     *  Storage for the popUpChildren property.
     */
    private var _popUpChildren:WindowedSystemChildrenList;

    //----------------------------------
    //  preloadedRSLs
    //----------------------------------
    
    /**
     *  @private
     * 
     *  This is a stub to satisfy the IFlexModuleFactory interface.
     * 
     *  The RSLs loaded by this system manager before the application 
     *  starts. RSLs loaded by the application are not included in this list.
     * 
     *  Information about preloadedRSLs is stored in a Dictionary. The key is
     *  the RSL's LoaderInfo. The value is the url the RSL was loaded from.
     */
    public function  get preloadedRSLs():Dictionary
    {
        return null;                
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get popUpChildren():IChildList
    {
        if (!topLevel)
            return _topLevelSystemManager.popUpChildren;

        if (!_popUpChildren)
        {
            _popUpChildren = new WindowedSystemChildrenList(this,
                new QName(mx_internal, "noTopMostIndex"),
                new QName(mx_internal, "topMostIndex"));
        }

        return _popUpChildren;
    }
    
    //----------------------------------
    //  noTopMostIndex
    //----------------------------------

    /**
     *  @private
     *  Storage for the noTopMostIndex property.
     */
    private var _noTopMostIndex:int = 0;

    /**
     *  @private
     *  The index of the highest child that isn't a topmost/popup window
     */
    mx_internal function get noTopMostIndex():int
    {
        return _noTopMostIndex;
    }

    /**
     *  @private
     */
    mx_internal function set noTopMostIndex(value:int):void
    {
        var delta:int = value - _noTopMostIndex;
        _noTopMostIndex = value;
        topMostIndex += delta;
    }
    //----------------------------------
    //  rawChildren
    //----------------------------------

    /**
     *  @private
     *  Storage for the rawChildren property.
     */
    private var _rawChildren:WindowedSystemRawChildrenList;

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get rawChildren():IChildList
    {
        if (!topLevel)
            return _topLevelSystemManager.rawChildren;

        if (!_rawChildren)
            _rawChildren = new WindowedSystemRawChildrenList(this);

        return _rawChildren;
    }

    //--------------------------------------------------------------------------
    //  screen
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Storage for the screen property.
     */
    mx_internal var _screen:Rectangle;

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get screen():Rectangle
    {
        if (!_screen)
            _screen = new Rectangle();
        _screen.x = 0;
        _screen.y = 0;
        _screen.width = stage.stageWidth; //Capabilities.screenResolutionX;
        _screen.height = stage.stageHeight; //Capabilities.screenResolutionY;


        return _screen;
    }
    
    //----------------------------------
    //  toolTipChildren
    //----------------------------------

    /**
     *  @private
     *  Storage for the toolTipChildren property.
     */
    private var _toolTipChildren:WindowedSystemChildrenList;

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get toolTipChildren():IChildList
    {
        if (!topLevel)
            return _topLevelSystemManager.toolTipChildren;

        if (!_toolTipChildren)
        {
            _toolTipChildren = new WindowedSystemChildrenList(this,
                new QName(mx_internal, "topMostIndex"),
                new QName(mx_internal, "toolTipIndex"));
        }

        return _toolTipChildren;
    }
    //----------------------------------
    //  toolTipIndex
    //----------------------------------

    /**
     *  @private
     *  Storage for the toolTipIndex property.
     */
    private var _toolTipIndex:int = 0;

    /**
     *  @private
     *  The index of the highest child that is a tooltip
     */
    mx_internal function get toolTipIndex():int
    {
        return _toolTipIndex;
    }

    /**
     *  @private
     */
    mx_internal function set toolTipIndex(value:int):void
    {
        var delta:int = value - _toolTipIndex;
        _toolTipIndex = value;
        cursorIndex += delta;
    }
    
    //----------------------------------
    //  topLevelSystemManager
    //----------------------------------

    /**
     *  Returns the SystemManager responsible for the application window.  This will be
     *  the same SystemManager unless this application has been loaded into another
     *  application.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get topLevelSystemManager():ISystemManager
    {
        if (topLevel)
            return this;

        return _topLevelSystemManager;
    }
    
    //----------------------------------
    //  topMostIndex
    //----------------------------------

    /**
     *  @private
     *  Storage for the topMostIndex property.
     */
    private var _topMostIndex:int = 0;

    /**
     *  @private
     *  The index of the highest child that is a topmost/popup window
     */
    mx_internal function get topMostIndex():int
    {
        return _topMostIndex;
    }

    mx_internal function set topMostIndex(value:int):void
    {
        var delta:int = value - _topMostIndex;
        _topMostIndex = value;
        toolTipIndex += delta;
    }
    
    //----------------------------------
    //  width
    //----------------------------------

    /**
     *  @private
     */
    private var _width:Number;

    /**
     *  The width of this object.  For the SystemManager
     *  this should always be the width of the stage unless the application was loaded
     *  into another application.  If the application was not loaded
     *  into another application, setting this value will have no effect.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function get width():Number
    {
        return _width;
    }
    
    //----------------------------------
    //  window
    //----------------------------------
    /**
     *  @private
     */ 
    private var _window:IWindow = null;
    
    mx_internal function get window():IWindow
    {
        return _window;
    }
    
    mx_internal function set window(value:IWindow):void
    {
        _window = value;
    }
    
    
     //----------------------------------
    //  height
    //----------------------------------

    /**
     *  @private
     */
    private var _height:Number;

    /**
     *  The height of this object.  For the SystemManager
     *  this should always be the width of the stage unless the application was loaded
     *  into another application.  If the application was not loaded
     *  into another application, setting this value has no effect.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function get height():Number
    {
        return _height;
    }

    /**
     * @inheritdoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */    
    public function get childAllowsParent():Boolean
    {
        try
        {
            return loaderInfo.childAllowsParent;
        }
        catch (error:Error)
        {
            //Error #2099: The loading object is not sufficiently loaded to provide this information.
        }
        
        return false;   // assume the worst
    }

    /**
     * @inheritdoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */    
    public function get parentAllowsChild():Boolean
    {
        try
        {
            return loaderInfo.parentAllowsChild;
        }
        catch (error:Error)
        {
            //Error #2099: The loading object is not sufficiently loaded to provide this information.
        }
        
        return false;   // assume the worst
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: Access to overridden methods of base classes
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  This method allows access to the Player's native implementation
     *  of addChild(), which can be useful since components
     *  can override addChild() and thereby hide the native implementation.
     *  Note that this "base method" is final and cannot be overridden,
     *  so you can count on it to reflect what is happening at the player level.
     */
    mx_internal final function $addChild(child:DisplayObject):DisplayObject
    {
        return super.addChild(child);
    }

    /**
     *  @private
     *  This method allows access to the Player's native implementation
     *  of addChildAt(), which can be useful since components
     *  can override addChildAt() and thereby hide the native implementation.
     *  Note that this "base method" is final and cannot be overridden,
     *  so you can count on it to reflect what is happening at the player level.
     */
    mx_internal final function $addChildAt(child:DisplayObject,
                                           index:int):DisplayObject
    {
        return super.addChildAt(child, index);
    }

    /**
     *  @private
     *  This method allows access to the Player's native implementation
     *  of removeChild(), which can be useful since components
     *  can override removeChild() and thereby hide the native implementation.
     *  Note that this "base method" is final and cannot be overridden,
     *  so you can count on it to reflect what is happening at the player level.
     */
    mx_internal final function $removeChild(child:DisplayObject):DisplayObject
    {
        return super.removeChild(child);
    }

    /**
     *  @private
     *  This method allows access to the Player's native implementation
     *  of removeChildAt(), which can be useful since components
     *  can override removeChildAt() and thereby hide the native implementation.
     *  Note that this "base method" is final and cannot be overridden,
     *  so you can count on it to reflect what is happening at the player level.
     */
    mx_internal final function $removeChildAt(index:int):DisplayObject
    {
        return super.removeChildAt(index);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods: Initialization
    //
    //--------------------------------------------------------------------------

    /**
	 *  This method should not be called on WindowedSystemManager.
	 *  It is here as part of the contract for IFlexModuleFactory.
   	 */
    public function callInContext(fn:Function, thisArg:Object, 
								  argArray:Array, returns:Boolean = true):*
    {
        if (returns)
            return fn.apply(thisArg, argArray);
        else
            fn.apply(thisArg, argArray);
    }

    /**
     *  This method is overridden in the autogenerated subclass.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function create(... params):Object
    {
        var mainClassName:String = String(params[0]);
        
        var mainClass:Class = Class(getDefinitionByName(mainClassName));
        if (!mainClass)
            throw new Error("Class '" + mainClassName + "' not found.");

		var instance:Object = new mainClass();
		if (instance is IFlexModule)
			(IFlexModule(instance)).moduleFactory = this;
		return instance;
	}
	
	/**
	 *  @private
	 *  This is attached as the framescript at the end of frame 2.
	 *  When this function is called, we know that the application
	 *  class has been defined and read in by the Player.
	 */
	protected function docFrameHandler(event:Event = null):void
	{
		removeEventListener(Event.ADDED, docFrameHandler);
		
        // Register singleton classes.
        // Note: getDefinitionByName() will return null
        // if the class can't be found.
        /*
        Singleton.registerClass("mx.managers::ICursorManager",
            Class(getDefinitionByName("mx.managers::CursorManagerImpl")));

        Singleton.registerClass("mx.managers::IDragManager",
            Class(getDefinitionByName("mx.managers::DragManagerImpl")));

        Singleton.registerClass("mx.managers::IHistoryManager",
            Class(getDefinitionByName("mx.managers::HistoryManagerImpl")));

        Singleton.registerClass("mx.managers::ILayoutManager",
            Class(getDefinitionByName("mx.managers::LayoutManager")));

        Singleton.registerClass("mx.managers::IPopUpManager",
            Class(getDefinitionByName("mx.managers::PopUpManagerImpl")));

        Singleton.registerClass("mx.styles::IStyleManager",
            Class(getDefinitionByName("mx.styles::StyleManagerImpl")));

        Singleton.registerClass("mx.styles::IStyleManager2",
            Class(getDefinitionByName("mx.styles::StyleManagerImpl")));

        Singleton.registerClass("mx.managers::IToolTipManager2",
            Class(getDefinitionByName("mx.managers::ToolTipManagerImpl")));*/

//      executeCallbacks();
//      doneExecutingInitCallbacks = true;

        // Loaded SWFs don't get a stage right away
        // and shouldn't override the main SWF's setting anyway.
        if (stage)
        {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
        }

        var mixinList:Array = info()["mixins"];
        if (mixinList && mixinList.length > 0)
        {
            var n:int = mixinList.length;
            for (var i:int = 0; i < n; ++i)
            {
                // trace("initializing mixin " + mixinList[i]);
                var c:Class = Class(getDefinitionByName(mixinList[i]));
                c["init"](this);
            }
        }
        
		c = Singleton.getClass("mx.managers::IActiveWindowManager");
		if (c)
		{
            registerImplementation("mx.managers::IActiveWindowManager", new c(this));
        }

        // depends on having IActiveWindowManager installed first
		c = Singleton.getClass("mx.managers::IMarshalSystemManager");
		if (c)
		{
            registerImplementation("mx.managers::IMarshalSystemManager", new c(this));
        }

    //  installCompiledResourceBundles();

        initializeTopLevelWindow(null);
        
        if (Singleton.getClass("mx.managers::IDragManager").getInstance() is NativeDragManagerImpl)
            NativeDragManagerImpl(Singleton.getClass("mx.managers::IDragManager").getInstance()).registerSystemManager(this);
    }
    
    /**
     *  @private
     *  Instantiates an instance of the top level window
     *  and adds it as a child of the SystemManager.
     */
    protected function initializeTopLevelWindow(event:Event):void
    {
        initialized = true;

        if (!parent)
            return;
        
        initContextMenu();
        if (!topLevel)
        {
            // We are not top-level and don't have a parent. This can happen
            // when the application has already been unloaded by the time
            // we get to this point.
            if (!parent)
                return;

            var obj:DisplayObjectContainer = parent.parent;

            // if there is no grandparent at this point, we might have been removed and
            // are about to be killed so just bail.  Other code that runs after
            // this point expects us to be grandparented.  Another scenario
            // is that someone loaded us but not into a parented loader, but that
            // is not allowed.
            if (!obj)
                return;
  
            while (obj)
            {
                if (obj is IUIComponent)
                {
                    _topLevelSystemManager = IUIComponent(obj).systemManager;
                    break;
                }
                obj = obj.parent;
            }
        }

        //  if (topLevel && stage)
            stage.addEventListener(Event.RESIZE, Stage_resizeHandler, false, 0, true);

        var app:IUIComponent;
        // Create a new instance of the toplevel class
        document = app = topLevelWindow;// = IUIComponent(create());

        if (document)
        {
            if (topLevel && stage)
            {
            //  LoaderConfig._url = loaderInfo.url;
            //  LoaderConfig._parameters = loaderInfo.parameters;
                
                // stageWidth/stageHeight may have changed between initialize() and now,
                // so refresh our _width and _height here. 
                _width = stage.stageWidth;
                _height = stage.stageHeight;
                //trace("width", _width);
                
                IFlexDisplayObject(app).setActualSize(stage.stageWidth, stage.stageHeight);
            }
            else
            {
                IFlexDisplayObject(app).setActualSize(loaderInfo.width, loaderInfo.height);
            }

            // Wait for the app to finish its initialization sequence
            // before doing an addChild(). 
            // Otherwise, the measurement/layout code will cause the
            // player to do a bunch of unnecessary screen repaints,
            // which slows application startup time.
            
            // Pass in the application instance to the preloader using registerApplication
        //  preloader.registerApplication(app);
                        
            // The Application doesn't get added to the SystemManager in the standard way.
            // We want to recursively create the entire application subtree and process
            // it with the LayoutManager before putting the Application on the display list.
            // So here we what would normally happen inside an override of addChild().
            // Leter, when we actually attach the Application instance,
            // we call super.addChild(), which is the bare player method.
            addingChild(DisplayObject(app));
            childAdded(DisplayObject(app)); // calls app.createChildren()
        }
        else
        {
            document = this;
        }
    
        // because we have no preload done handler, we need to 
        // do that work elsewhere
        addChildAndMouseCatcher();
    }
            
    /**
     *  @private
     *  Same as SystemManager's preload done handler.  It adds 
     *  the window to the application (and a mouse catcher)
     * 
     *  Called from initializeTopLevelWindow()
     */
    private function addChildAndMouseCatcher():void
    {
        var app:IUIComponent = topLevelWindow;
        // Add the mouseCatcher as child 0.
        mouseCatcher = new FlexSprite();
        mouseCatcher.name = "mouseCatcher";
        
        // Must use addChildAt because a creationComplete handler can create a
        // dialog and insert it at 0.
        noTopMostIndex++;
        super.addChildAt(mouseCatcher, 0);  
        resizeMouseCatcher();
        
        // topLevel seems to always be true, but keeping it here just in case
        if (!topLevel)
        {
            mouseCatcher.visible = false;
            mask = mouseCatcher;
        }
        
        noTopMostIndex++;
        super.addChild(DisplayObject(app));
    }

    
    //----------------------------------
    //  info
    //----------------------------------

    /**
     *  @private
     */
    public function info():Object
    {
        return {};
    }
    
    
    /**
     *  @private
     *  Disable all the built-in items except "Print...".
     */
    private function initContextMenu():void
    {
        var defaultMenu:ContextMenu = new ContextMenu();
        defaultMenu.hideBuiltInItems();
        defaultMenu.builtInItems.print = true;
        contextMenu = defaultMenu;
    }
        
    /**
     * @inheritdoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    public function isTopLevelRoot():Boolean
    {
        return isStageRoot || isBootstrapRoot;
    }

   
    /**
     * Go up our parent chain to get the top level system manager.
     * 
     * returns null if we are not on the display list or we don't have
     * access to the top level system manager.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getTopLevelRoot():DisplayObject
    {
        // work our say up the parent chain to the root. This way we
        // don't have to rely on this object being added to the stage.
        try
        {
            var sm:ISystemManager = this;
            if (sm.topLevelSystemManager)
                sm = ISystemManager(sm.topLevelSystemManager);
            var parent:DisplayObject = DisplayObject(sm).parent;
            var lastParent:DisplayObject = DisplayObject(sm);
            while (parent)
            {
                if (parent is Stage)
                    return lastParent;
                lastParent = parent; 
                parent = parent.parent;             
            }
        }
        catch (error:SecurityError)
        {
        }       
        
        return null;
    }

    /**
     * Go up our parent chain to get the top level system manager in this 
     * SecurityDomain
     * 
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getSandboxRoot():DisplayObject
    {
        // work our say up the parent chain to the root. This way we
        // don't have to rely on this object being added to the stage.
        var sm:ISystemManager = this;

        try
        {
            if (sm.topLevelSystemManager)
                sm = ISystemManager(sm.topLevelSystemManager);
            var parent:DisplayObject = DisplayObject(sm).parent;
            if (parent is Stage)
                return DisplayObject(sm);
            // test to see if parent is a Bootstrap
            if (parent && !parent.dispatchEvent(new Event("mx.managers.SystemManager.isBootstrapRoot", false, true)))
                return this;
            var lastParent:DisplayObject = this;
            while (parent)
            {
                if (parent is Stage)
                    return lastParent;
                // test to see if parent is a Bootstrap
                if (!parent.dispatchEvent(new Event("mx.managers.SystemManager.isBootstrapRoot", false, true)))
                    return lastParent;
                    
                // Test if the childAllowsParent so we know there is mutual trust between
                // the sandbox root and this sm.
                // The parentAllowsChild is taken care of by the player because it returns null
                // for the parent if we do not have access.
                if (parent is Loader)
                {
                    var loader:Loader = Loader(parent);
                    var loaderInfo:LoaderInfo = loader.contentLoaderInfo;
                    if (!loaderInfo.childAllowsParent)
                        return loaderInfo.content;
                }
                
                // If an object is listening for system manager request we assume it is a sandbox
                // root. If not, don't assign lastParent to this parent because it may be a
                // non-Flex application. We only want Flex apps to be returned as sandbox roots.
                if (parent.hasEventListener("systemManagerRequest"))
                    lastParent = parent; 
                parent = parent.parent;             
            }
        }
        catch (error:Error)
        {
            // Either we don't have security access to a parent or
            // the swf is unloaded and loaderInfo.childAllowsParent is throwing Error #2099.
        }       
        
        return lastParent != null ? lastParent : DisplayObject(sm);
    }
    
    /**
     *  @private
	 *  A map of fully-qualified interface names,
	 *  such as "mx.managers::IPopUpManager",
	 *  to implementation classes which produce singleton instances,
	 *  such as mx.managers.PopUpManagerImpl.
     */
    private var implMap:Object = {};

    /**
     *  @private
	 *  Adds an interface-name-to-implementation-class mapping to the registry,
	 *  if a class hasn't already been registered for the specified interface.
	 *  The class must implement a getInstance() method which returns
	 *  its singleton instance.
     */
    public function registerImplementation(interfaceName:String,
										 impl:Object):void
    {
        var c:Object = implMap[interfaceName];
		if (!c)
            implMap[interfaceName] = impl;
    }

    /**
     *  @private
	 *  Returns the singleton instance of the implementation class
	 *  that was registered for the specified interface,
	 *  by looking up the class in the registry
	 *  and calling its getInstance() method.
	 *
	 *  This method should not be called at static initialization time,
	 *  because the factory class may not have called registerClass() yet.
     */
    public function getImplementation(interfaceName:String):Object
    {
        var c:Object = implMap[interfaceName];
		return c;
    }

   /**
     *  @inheritdoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */  
    public function getVisibleApplicationRect(bounds:Rectangle = null):Rectangle
    {
		var request:Request = new Request("getVisibleApplicationRect", false, true);
		if (!dispatchEvent(request)) 
			return Rectangle(request.value);

        if (!bounds)
        {
            bounds = getBounds(DisplayObject(this));
            
            var s:Rectangle = screen;        
            var pt:Point = new Point(Math.max(0, bounds.x), Math.max(0, bounds.y));
            pt = localToGlobal(pt);
            bounds.x = pt.x;
            bounds.y = pt.y;
            bounds.width = s.width;
            bounds.height = s.height;
        }
        
        return bounds;
    }
 
   /**
    *  @inheritDoc
    *  
    *  @langversion 3.0
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */  
    public function deployMouseShields(deploy:Boolean):void
    {
		var dynamicEvent:DynamicEvent = new DynamicEvent("deployMouseShields");
		dynamicEvent.deploy = deploy;
		dispatchEvent(dynamicEvent);
    }
    
    /**
     *  @private
     * 
     *  This is a stub to satisfy the IFlexModuleFactory interface.
     * 
     *  Calls Security.allowDomain() for the SWF associated with this SystemManager
     *  plus all the SWFs assocatiated with RSLs preloaded by this SystemManager.
     * 
     */  
    public function allowDomain(... domains):void
    {
    }
    
    /**
     *  @private
     * 
     *  This is a stub to satisfy the IFlexModuleFactory interface.
     * 
     *  Calls Security.allowInsecureDomain() for the SWF associated with this SystemManager
     *  plus all the SWFs assocatiated with RSLs preloaded by this SystemManager.
     * 
     */  
    public function allowInsecureDomain(... domains):void
    {
    }

    /**
     *  Returns <code>true</code> if the given DisplayObject is the 
     *  top-level window.
     *
     *  @param object 
     *
     *  @return <code>true</code> if the given DisplayObject is the 
     *  top-level window.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function isTopLevelWindow(object:DisplayObject):Boolean
    {
        return object is IUIComponent &&
               IUIComponent(object) == topLevelWindow;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getDefinitionByName(name:String):Object
    {
        var domain:ApplicationDomain = ApplicationDomain.currentDomain;
            !topLevel && parent is Loader ?
            Loader(parent).contentLoaderInfo.applicationDomain :
            info()["currentDomain"] as ApplicationDomain;

        //trace("SysMgr.getDefinitionByName domain",domain,"currentDomain",info()["currentDomain"]);    

        var definition:Object;

        if (domain.hasDefinition(name))
        {
            definition = domain.getDefinition(name);
            //trace("SysMgr.getDefinitionByName got definition",definition,"name",name);
        }

        return definition;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function isTopLevel():Boolean
    {
        return topLevel;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function isFontFaceEmbedded(textFormat:TextFormat):Boolean
    {
        var fontName:String = textFormat.font;

        var fl:Array = Font.enumerateFonts();
        for (var f:int = 0; f < fl.length; ++f)
        {
            var font:Font = Font(fl[f]);
            if (font.fontName == fontName)
            {
                var style:String = "regular";
                if (textFormat.bold && textFormat.italic)
                    style = "boldItalic";
                else if (textFormat.bold)
                    style = "bold";
                else if (textFormat.italic)
                    style = "italic";

                if (font.fontStyle == style)
                    return true;
            }
        }

        if (!fontName ||
            !embeddedFontList ||
            !embeddedFontList[fontName])
        {
            return false;
        }

        var info:Object = embeddedFontList[fontName];

        return !((textFormat.bold && !info.bold) ||
                 (textFormat.italic && !info.italic) ||
                 (!textFormat.bold && !textFormat.italic &&
                 !info.regular));
    }
    
    
    /**
     *  @private
     *  Keep track of the size and position of the stage.
     */
    private function Stage_resizeHandler(event:Event = null):void
    {   
        var w:Number = stage.stageWidth;
        var h:Number = stage.stageHeight;
    
        var y:Number = 0;
        var x:Number = 0;
        
        if (!_screen)
            _screen = new Rectangle();
        _screen.x = x;
        _screen.y = y;
        _screen.width = w;
        _screen.height = h;

        
        _width = stage.stageWidth;
        _height = stage.stageHeight;
        
//trace(_width, event.type);
		if (event)
		{
			resizeMouseCatcher();
			dispatchEvent(event);
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
     *  @private
     *  Makes the mouseCatcher the same size as the stage,
     *  filling it with transparent pixels.
     */
    private function resizeMouseCatcher():void
    {
        if (mouseCatcher)
        {
            var g:Graphics = mouseCatcher.graphics;
            g.clear();
            g.beginFill(0x000000, 0);
            g.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            g.endFill();
        }
    }

	/**
	 * @private
	 * 
	 * true if redipatching a resize event.
	 */
	private var isDispatchingResizeEvent:Boolean;
	
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: EventDispatcher
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 *  allows marshal implementation to add events
	 */
	mx_internal final function $addEventListener(type:String, listener:Function,
											  useCapture:Boolean = false,
											  priority:int = 0,
											  useWeakReference:Boolean = false):void
	{	
		super.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}

	/**
	 *  @private
	 *  Only create idle events if someone is listening.
	 */
	override public function addEventListener(type:String, listener:Function,
											  useCapture:Boolean = false,
											  priority:int = 0,
											  useWeakReference:Boolean = false):void
	{
		if (type == MouseEvent.MOUSE_MOVE || type == MouseEvent.MOUSE_UP || type == MouseEvent.MOUSE_DOWN 
				|| type == Event.ACTIVATE || type == Event.DEACTIVATE)
		{
			// also listen to stage if allowed
			try
			{
				if (stage)
				{
                    // Use weak listener because we don't always know when we
                    // no longer need this listener
					stage.addEventListener(type, stageEventHandler, false, 0, true);
				}
			}
			catch (error:SecurityError)
			{
			}
		}

        if (hasEventListener("addEventListener"))
        {
            var request:DynamicEvent = new DynamicEvent("addEventListener", false, true);
            request.eventType = type;
            request.listener = listener;
            request.useCapture = useCapture;
            request.priority = priority;
            request.useWeakReference = useWeakReference;
		    if (!dispatchEvent(request))
			    return;
        }

        if (type == SandboxMouseEvent.MOUSE_UP_SOMEWHERE)
        {
            // If someone wants this event, also listen for mouseLeave.
            // Use weak listener because we don't always know when we
            // no longer need this listener
            try
            {
			    if (stage)
			    {
				    stage.addEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler, false, 0, true);
                }
                else
                {
					super.addEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler, false, 0, true);
                }
			}
			catch (error:SecurityError)
			{
				super.addEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler, false, 0, true);
			}
        }
		
		// These two events will dispatched to applications in sandboxes.
		if (type == FlexEvent.RENDER || type == FlexEvent.ENTER_FRAME)
		{
			if (type == FlexEvent.RENDER)
				type = Event.RENDER;
			else
				type = Event.ENTER_FRAME;
				
			try
			{
				if (stage)
					stage.addEventListener(type, listener, useCapture, priority, useWeakReference);
				else
					super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
			catch (error:SecurityError)
			{
				super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
		
			if (stage && type == Event.RENDER)
				stage.invalidate();

            return;
        }

		super.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}

	/**
	 *  @private
	 */
	mx_internal final function $removeEventListener(type:String, listener:Function,
												 useCapture:Boolean = false):void
	{
		super.removeEventListener(type, listener, useCapture);
	}

	/**
	 *  @private
	 */
	override public function removeEventListener(type:String, listener:Function,
												 useCapture:Boolean = false):void
	{
        if (hasEventListener("removeEventListener"))
        {
            var request:DynamicEvent = new DynamicEvent("removeEventListener", false, true);
            request.eventType = type;
            request.listener = listener;
            request.useCapture = useCapture;
		    if (!dispatchEvent(request))
			    return;
        }

		// These two events will dispatched to applications in sandboxes.
		if (type == FlexEvent.RENDER || type == FlexEvent.ENTER_FRAME)
		{
			if (type == FlexEvent.RENDER)
				type = Event.RENDER;
			else
				type = Event.ENTER_FRAME;
				
			try
			{
				if (stage)
					stage.removeEventListener(type, listener, useCapture);
            }
            catch (error:SecurityError)
            {
            }
			// Remove both listeners in case the system manager was added
			// or removed from the stage after the listener was added.
            super.removeEventListener(type, listener, useCapture);
        
            return;
        }

        super.removeEventListener(type, listener, useCapture);

		if (type == MouseEvent.MOUSE_MOVE || type == MouseEvent.MOUSE_UP || type == MouseEvent.MOUSE_DOWN 
				|| type == Event.ACTIVATE || type == Event.DEACTIVATE)
		{
            if (!hasEventListener(type))
            {
			    // also listen to stage if allowed
			    try
			    {
				    if (stage)
				    {
					    stage.removeEventListener(type, stageEventHandler, false);
				    }
			    }
			    catch (error:SecurityError)
			    {
			    }
            }
		}

        if (type == SandboxMouseEvent.MOUSE_UP_SOMEWHERE)
        {
            if (!hasEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE))
            {
                // nobody wants this event any more for now
                try
                {
			        if (stage)
			        {
				        stage.removeEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
                    }
			    }
			    catch (error:SecurityError)
			    {
			    }
			    // Remove both listeners in case the system manager was added
			    // or removed from the stage after the listener was added.
			    super.removeEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
            }
        }
	}

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: DisplayObjectContainer
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function addChild(child:DisplayObject):DisplayObject
    {
        // Adjust the partition indexes
        // before the "added" event is dispatched.
        noTopMostIndex++;

        return rawChildren_addChildAt(child, noTopMostIndex - 1);
    }
    
    //----------------------------------
    //  numChildren
    //----------------------------------

    /**
     *  The number of non-floating windows.  This is the main application window
     *  plus any other windows added to the SystemManager that are not popups,
     *  tooltips or cursors.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function get numChildren():int
    {
        return noTopMostIndex - applicationIndex;
    }
    
    /**
     *  @private
     */
    override public function addChildAt(child:DisplayObject,
                                        index:int):DisplayObject
    {
        // Adjust the partition indexes
        // before the "added" event is dispatched.
        noTopMostIndex++;

        return rawChildren_addChildAt(child, applicationIndex + index);
    }
    
    /**
     *  @private
     */
    override public function removeChild(child:DisplayObject):DisplayObject
    {
        // Adjust the partition indexes
        // before the "removed" event is dispatched.
        noTopMostIndex--;

        return rawChildren_removeChild(child);
    }

    /**
     *  @private
     */
    override public function removeChildAt(index:int):DisplayObject
    {
        // Adjust the partition indexes
        // before the "removed" event is dispatched.
        noTopMostIndex--;

        return rawChildren_removeChildAt(applicationIndex + index);
    }

    /**
     *  @private
     */
    override public function getChildAt(index:int):DisplayObject
    {
        return super.getChildAt(applicationIndex + index);
    }

    /**
     *  @private
     */
    override public function getChildByName(name:String):DisplayObject
    {
        return super.getChildByName(name);
    }

    /**
     *  @private
     */
    override public function getChildIndex(child:DisplayObject):int
    {
        return super.getChildIndex(child) - applicationIndex;
    }

    /**
     *  @private
     */
    override public function setChildIndex(child:DisplayObject, newIndex:int):void
    {
        super.setChildIndex(child, applicationIndex + newIndex);
    }

    /**
     *  @private
     */
    override public function getObjectsUnderPoint(point:Point):Array
    {
        var children:Array = [];

        // Get all the children that aren't tooltips and cursors.
        var n:int = topMostIndex;
        for (var i:int = 0; i < n; i++)
        {
            var child:DisplayObject = super.getChildAt(i);
            if (child is DisplayObjectContainer)
            {
                var temp:Array =
                    DisplayObjectContainer(child).getObjectsUnderPoint(point);

                if (temp)
                    children = children.concat(temp);
            }
        }

        return children;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: Child management
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    mx_internal function addingChild(child:DisplayObject):void
    {
        var newNestLevel:int = 1;
        if (!topLevel)
        {
            // non-topLevel SystemManagers are buried by Flash.display.Loader and
            // other non-framework layers so we have to figure out the nestlevel
            // by searching up the parent chain.
            var obj:DisplayObjectContainer = parent.parent;
            while (obj)
            {
                if (obj is ILayoutManagerClient)
                {
                    newNestLevel = ILayoutManagerClient(obj).nestLevel + 1;
                    break;
                }
                obj = obj.parent;
            }
        }
        nestLevel = newNestLevel;

        if (child is IUIComponent)
            IUIComponent(child).systemManager = this;

        // Local variables for certain classes we need to check against below.
        // This is the backdoor way around linking in the class in question.
        var uiComponentClassName:Class =
            Class(getDefinitionByName("mx.core.UIComponent"));

        // If the document property isn't already set on the child,
        // set it to be the same as this component's document.
        // The document setter will recursively set it on any
        // descendants of the child that exist.
        if (child is IUIComponent &&
            !IUIComponent(child).document)
        {
            IUIComponent(child).document = document;
        }

        // Set the nestLevel of the child to be one greater
        // than the nestLevel of this component.
        // The nestLevel setter will recursively set it on any
        // descendants of the child that exist.
        if (child is ILayoutManagerClient)
            ILayoutManagerClient(child).nestLevel = nestLevel + 1;

        if (child is InteractiveObject)
            if (doubleClickEnabled)
                InteractiveObject(child).doubleClickEnabled = true;

        if (child is IUIComponent)
            IUIComponent(child).parentChanged(this);

        // Sets up the inheritingStyles and nonInheritingStyles objects
        // and their proto chains so that getStyle() works.
        // If this object already has some children,
        // then reinitialize the children's proto chains.
        if (child is IStyleClient)
            IStyleClient(child).regenerateStyleCache(true);

        if (child is ISimpleStyleClient)
            ISimpleStyleClient(child).styleChanged(null);

        if (child is IStyleClient)
            IStyleClient(child).notifyStyleChangeInChildren(null, true);

        // Need to check to see if the child is an UIComponent
        // without actually linking in the UIComponent class.
        if (uiComponentClassName && child is uiComponentClassName)
            uiComponentClassName(child).initThemeColor();

        // Inform the component that it's style properties
        // have been fully initialized. Most components won't care,
        // but some need to react to even this early change.
        if (uiComponentClassName && child is uiComponentClassName)
            uiComponentClassName(child).stylesInitialized();
    }

    /**
     *  @private
     */
    mx_internal function childAdded(child:DisplayObject):void
    {
        if (child.hasEventListener(FlexEvent.ADD))
            child.dispatchEvent(new FlexEvent(FlexEvent.ADD));

        if (child is IUIComponent)
            IUIComponent(child).initialize(); // calls child.createChildren()
    }

    /**
     *  @private
     */
    mx_internal function removingChild(child:DisplayObject):void
    {
        if (child.hasEventListener(FlexEvent.REMOVE))
            child.dispatchEvent(new FlexEvent(FlexEvent.REMOVE));
    }

    /**
     *  @private
     */
    mx_internal function childRemoved(child:DisplayObject):void
    {
        if (child is IUIComponent)
            IUIComponent(child).parentChanged(null);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods: Support for rawChildren access
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    mx_internal function rawChildren_addChild(child:DisplayObject):DisplayObject
    {
        childManager.addingChild(child);

        super.addChild(child);

        childManager.childAdded(child); // calls child.createChildren()

        return child;
    }

    /**
     *  @private
     */
    mx_internal function rawChildren_addChildAt(child:DisplayObject,
                                                index:int):DisplayObject
    {
        // preloader goes through here before childManager is set up
        if (childManager) 
            childManager.addingChild(child);

        super.addChildAt(child, index);

        if (childManager) 
            childManager.childAdded(child); // calls child.createChildren()

        return child;
    }

    /**
     *  @private
     */
    mx_internal function rawChildren_removeChild(child:DisplayObject):DisplayObject
    {
        childManager.removingChild(child);
        super.removeChild(child);
        childManager.childRemoved(child);

        return child;
    }

    /**
     *  @private
     */
    mx_internal function rawChildren_removeChildAt(index:int):DisplayObject
    {
        var child:DisplayObject = super.getChildAt(index);

        childManager.removingChild(child);

        super.removeChildAt(index);

        childManager.childRemoved(child);

        return child;
    }

    /**
     *  @private
     */
    mx_internal function rawChildren_getChildAt(index:int):DisplayObject
    {
        return super.getChildAt(index);
    }

    /**
     *  @private
     */
    mx_internal function rawChildren_getChildByName(name:String):DisplayObject
    {
        return super.getChildByName(name);
    }

    /**
     *  @private
     */
    mx_internal function rawChildren_getChildIndex(child:DisplayObject):int
    {
        return super.getChildIndex(child);
    }

    /**
     *  @private
     */
    mx_internal function rawChildren_setChildIndex(child:DisplayObject, newIndex:int):void
    {
        super.setChildIndex(child, newIndex);
    }

    /**
     *  @private
     */
    mx_internal function rawChildren_getObjectsUnderPoint(pt:Point):Array
    {
        return super.getObjectsUnderPoint(pt);
    }

    /**
     *  @private
     */
    mx_internal function rawChildren_contains(child:DisplayObject):Boolean
    {
        return super.contains(child);
    }

	// fake out mouseX/mouseY
	mx_internal var _mouseX:*;
	mx_internal var _mouseY:*;

    
    /**
     *  @private
     */
    override public function get mouseX():Number
    {
        if (_mouseX === undefined)
            return super.mouseX;
        return _mouseX;
    }

    /**
     *  @private
     */
    override public function get mouseY():Number
    {
        if (_mouseY === undefined)
            return super.mouseY;
        return _mouseY;
    }

    /**
     * Return the object the player sees as having focus.
     * 
     * @return An object of type InteractiveObject that the
     *         player sees as having focus. If focus is currently
     *         in a sandbox the caller does not have access to
     *         null will be returned.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getFocus():InteractiveObject
    {
        try
        {
            return stage.focus;
        }   
        catch (e:SecurityError)
        {
            // trace("SM getFocus(): ignoring security error " + e);
        }

        return null;
    }   

    /**
     *  @private
     *  Cleans up references to Window. Also removes self from topLevelSystemManagers list. 
     */
    mx_internal function cleanup(e:Event):void
    {
        if (Singleton.getClass("mx.managers::IDragManager").getInstance()
                     is NativeDragManagerImpl)
            NativeDragManagerImpl(Singleton.getClass("mx.managers::IDragManager").getInstance()).unregisterSystemManager(this);
        SystemManagerGlobals.topLevelSystemManagers.splice(SystemManagerGlobals.topLevelSystemManagers.indexOf(this), 1);
        myWindow.nativeWindow.removeEventListener(Event.CLOSE, cleanup);
        myWindow = null;
    }

    /**
     *  @private
     *  only registers Window for later cleanup.
     */
    mx_internal function addWindow(win:IWindow):void
    {
        myWindow = win;
        myWindow.nativeWindow.addEventListener(Event.CLOSE, cleanup);
    }

    /**
     *  @private
     *  dispatch certain stage events from sandbox root
     */
    private function stageEventHandler(event:Event):void
    {
        if (event.target is Stage)
            dispatchEvent(event);
    }

    /**
     *  @private
     *  convert MOUSE_LEAVE to MOUSE_UP_SOMEWHERE
     */
    private function mouseLeaveHandler(event:Event):void
    {
        dispatchEvent(new SandboxMouseEvent(SandboxMouseEvent.MOUSE_UP_SOMEWHERE));
    }

    /**
     *  Attempts to notify the parent SWFLoader that the
     *  Application's size has may have changed.  Not needed
     *  for WindowedSystemManager so does nothing
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function invalidateParentSizeAndDisplayList():void
    {
    }

}
}
