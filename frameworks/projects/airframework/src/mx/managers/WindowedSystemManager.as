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
import mx.core.IRawChildrenContainer;
import mx.core.ISWFBridgeGroup;
import mx.core.ISWFBridgeProvider;
import mx.core.ISWFLoader;
import mx.core.IChildList;
import mx.core.IFlexDisplayObject;
import mx.core.IFlexModule;
import mx.core.IUIComponent;
import mx.core.Singleton;
import mx.core.SWFBridgeGroup;
import mx.core.IWindow;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.FlexChangeEvent;
import mx.events.EventListenerRequest;
import mx.events.InvalidateRequestData;
import mx.events.InterManagerRequest;
import mx.events.SandboxMouseEvent;
import mx.events.SWFBridgeRequest;
import mx.events.SWFBridgeEvent;
import mx.managers.systemClasses.RemotePopUp;
import mx.managers.systemClasses.EventProxy;
import mx.managers.systemClasses.StageEventProxy;
import mx.managers.systemClasses.PlaceholderData;
import mx.styles.ISimpleStyleClient;
import mx.styles.IStyleClient;
import mx.utils.EventUtil;
import mx.utils.NameUtil;
import mx.utils.ObjectUtil;
import mx.utils.SecurityUtil;


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
public class WindowedSystemManager extends MovieClip implements ISystemManager, ISWFBridgeProvider
{
    
    public function WindowedSystemManager(rootObj:IUIComponent)
    {
        super();
        _topLevelSystemManager = this;
        topLevelWindow = rootObj;
        SystemManagerGlobals.topLevelSystemManagers.push(this);
        //docFrameHandler(null);
        addEventListener(Event.ADDED, docFrameHandler);
    }
    
        /**
     *  @private
     *  List of top level windows.
     */
    private var forms:Array = [];

    /**
     *  @private
     *  The current top level window.
     */
    private var form:Object;
    
    private var topLevel:Boolean = true;
    
    private var initialized:Boolean = false;
    
    /**
     *  @private
     *  Number of frames since the last mouse or key activity.
     */
    mx_internal var idleCounter:int = 0;
    
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
    private var originalSystemManager:SystemManager;
    
    /**
     *  @private
     */
    private var _topLevelSystemManager:ISystemManager;
    
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
        if (topLevel)
            return _bridgeToFocusManager;
        else if (topLevelSystemManager)
            return SystemManager(topLevelSystemManager).bridgeToFocusManager;
            
        return null;
    }
    
    mx_internal function set bridgeToFocusManager(bridgeToFMDictionary:Dictionary):void
    {
        if (topLevel)
            _bridgeToFocusManager = bridgeToFMDictionary;
        else if (topLevelSystemManager)
            SystemManager(topLevelSystemManager).bridgeToFocusManager = bridgeToFMDictionary;
                    
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
    //  sandbox bridge group
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
        if (topLevel)
            return _swfBridgeGroup;
        else if (topLevelSystemManager)
            return topLevelSystemManager.swfBridgeGroup;
            
        return null;
    }
    
    public function set swfBridgeGroup(bridgeGroup:ISWFBridgeGroup):void
    {
        if (topLevel)
            _swfBridgeGroup = bridgeGroup;
        else if (topLevelSystemManager)
            SystemManager(topLevelSystemManager).swfBridgeGroup = bridgeGroup;
                    
    }

    //--------------------------------------------------------------------------
    //  screen
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Storage for the screen property.
     */
    private var _screen:Rectangle;

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

    //--------------------------------------------------------------------------
    //
    //  Properties: ISWFBridgeProvider
    //
    //--------------------------------------------------------------------------

    /**
     * @inheritdoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */    
    public function get swfBridge():IEventDispatcher
    {
        if (swfBridgeGroup)
            return swfBridgeGroup.parentBridge;
            
        return null;
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
    //  Methods: Focus
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function activate(f:IFocusManagerContainer):void
    {
        activateForm(f);
    }

    /**
     * @private
     * 
     * New version of activate that does not require a
     * IFocusManagerContainer.
     */
    private function activateForm(f:Object):void
    {

        // trace("SM: activate " + f + " " + forms.length);
        if (form)
        {
            if (form != f && forms.length > 1)
            {
                // Switch the active form.
                if (isRemotePopUp(form))
                {
                    if (!areRemotePopUpsEqual(form, f))
                        deactivateRemotePopUp(form);                                                    
                }
                else
                {
                    var z:IFocusManagerContainer = IFocusManagerContainer(form);
                    // trace("OLW " + f + " deactivating old form " + z);
                    z.focusManager.deactivate();
                }
            }
        }

        form = f;

        // trace("f = " + f);
        if (isRemotePopUp(f))
        {
            activateRemotePopUp(f);
        }
        else if (f.focusManager)
        {
            // trace("has focus manager");
            f.focusManager.activate();
        }

        updateLastActiveForm();
        
        // trace("END SM: activate " + f);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function deactivate(f:IFocusManagerContainer):void
    {
        deactivateForm(Object(f));
    }
    
    /**
     * @private
     * 
     * New version of deactivate that works with remote pop ups.
     * 
     */
    private function deactivateForm(f:Object):void
    {
        // trace(">>SM: deactivate " + f);

        if (form)
        {
            // If there's more than one form and this is it, find a new form.
            if (form == f && forms.length > 1)
            {
                if (isRemotePopUp(form))
                    deactivateRemotePopUp(form);
                else
                    form.focusManager.deactivate();
                    
                form = findLastActiveForm(f);
                
                // make sure we have a valid top level window.
                // This can be null if top level window has been hidden for some reason.
                if (form)
                {
                    if (isRemotePopUp(form))
                        activateRemotePopUp(form);                  
                    else 
                        form.focusManager.activate();
                }
            }
        }

        // trace("<<SM: deactivate " + f);
    }


    /**
     * @private
     * 
     * @param f form being deactivated
     * 
     * @return the next form to activate, excluding the form being deactivated.
     */
    private function findLastActiveForm(f:Object):Object
    {
        var n:int = forms.length;
        for (var i:int = forms.length - 1; i >= 0; i--)
        {
            // Verify the form is visible and enabled
            if (forms[i] != f && canActivatePopUp(forms[i]))
                return forms[i];
        }
        
        return null;  // shouldn't get here     
    }
    
    
    /**
     * @private
     * 
     * @return true if the form can be activated, false otherwise.
     */
     private function canActivatePopUp(f:Object):Boolean
     {
        if (isRemotePopUp(f))
        {
            var remotePopUp:RemotePopUp = RemotePopUp(f);
            var event:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.CAN_ACTIVATE_POP_UP_REQUEST, 
                                                                  false, false, null,
                                                                  remotePopUp.window);
            IEventDispatcher(remotePopUp.bridge).dispatchEvent(event);
            return event.data;
        }
        else if (canActivateLocalComponent(f))
            return true;
            
        return false;
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
        // remove the placeholder from forms array
        var n:int = forms.length;
        for (var i:int = 0; i < n; i++)
        {
            if (isRemotePopUp(forms[i]))
            {
                var popUp:RemotePopUp = RemotePopUp(forms[i]);
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
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function removeRemotePopUp(form:RemotePopUp):void
    {   
        // remove popup from forms array
        var n:int = forms.length;
        for (var i:int = 0; i < n; i++)
        {
            if (isRemotePopUp(forms[i]))
            {
                if (forms[i].window == form.window &&
                    forms[i].bridge == form.bridge)
                {
                    if (forms[i] == form)
                        deactivateForm(form);
                    forms.splice(i, 1);
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
     * @param form  a RemotePopUp object.
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
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function addFocusManager(f:IFocusManagerContainer):void
    {
        // trace("OLW: add focus manager" + f);

        forms.push(f);

        // trace("END OLW: add focus manager" + f);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function removeFocusManager(f:IFocusManagerContainer):void
    {
        // trace("OLW: remove focus manager" + f);

        var n:int = forms.length;
        for (var i:int = 0; i < n; i++)
        {
            if (forms[i] == f)
            {
                if (form == f)
                    deactivate(f);
                forms.splice(i, 1);
                // trace("END OLW: successful remove focus manager" + f);
                return;
            }
        }

        // trace("END OLW: remove focus manager" + f);
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
        
        // every SM has to have this listener in case it is the SM for some child AD that contains a manager
        // and the parent ADs don't have that manager.
        getSandboxRoot().addEventListener(InterManagerRequest.INIT_MANAGER_REQUEST, initManagerHandler, false, 0, true);
        // once managers get initialized, they bounce things off the sandbox root
        if (getSandboxRoot() == this)
        {
            addEventListener(InterManagerRequest.SYSTEM_MANAGER_REQUEST, systemManagerHandler);
            addEventListener(InterManagerRequest.DRAG_MANAGER_REQUEST, multiWindowRedispatcher);
            // listened for w/o use of constants because of dependency issues
            //addEventListener(InterDragManagerEvent.DISPATCH_DRAG_EVENT, multiWindowRedispatcher);
            addEventListener("dispatchDragEvent", multiWindowRedispatcher);

            addEventListener(SWFBridgeRequest.ADD_POP_UP_REQUEST, addPopupRequestHandler);
            addEventListener(SWFBridgeRequest.REMOVE_POP_UP_REQUEST, removePopupRequestHandler);
            addEventListener(SWFBridgeRequest.ADD_POP_UP_PLACE_HOLDER_REQUEST, addPlaceholderPopupRequestHandler);
            addEventListener(SWFBridgeRequest.REMOVE_POP_UP_PLACE_HOLDER_REQUEST, removePlaceholderPopupRequestHandler);
            addEventListener(SWFBridgeEvent.BRIDGE_WINDOW_ACTIVATE, activateFormSandboxEventHandler);
            addEventListener(SWFBridgeEvent.BRIDGE_WINDOW_DEACTIVATE, deactivateFormSandboxEventHandler); 
            addEventListener(SWFBridgeRequest.HIDE_MOUSE_CURSOR_REQUEST, hideMouseCursorRequestHandler);
            addEventListener(SWFBridgeRequest.SHOW_MOUSE_CURSOR_REQUEST, showMouseCursorRequestHandler);
            addEventListener(SWFBridgeRequest.RESET_MOUSE_CURSOR_REQUEST, resetMouseCursorRequestHandler);
        }

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

        // capture mouse down so we can switch top level windows and activate
        // the right focus manager before the components inside start
        // processing the event
        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, true); 

    //  if (topLevel && stage)
            stage.addEventListener(Event.RESIZE, Stage_resizeHandler, false, 0, true);

        var app:IUIComponent;
        // Create a new instance of the toplevel class
        document = app = topLevelWindow;// = IUIComponent(create());

        if (document)
        {
            // Add listener for the creationComplete event
/*          IEventDispatcher(app).addEventListener(FlexEvent.CREATION_COMPLETE,
                                                   appCreationCompleteHandler);
*  
*  @langversion 3.0
*  @playerversion AIR 1.1
*  @productversion Flex 3
*/
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
    
    //--------------------------------------------------------------------------
    //
    //  Methods: Styles
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Call regenerateStyleCache() on all children of this SystemManager.
     *  If the recursive parameter is true, continue doing this
     *  for all descendants of these children.
     */
    mx_internal function regenerateStyleCache(recursive:Boolean):void
    {
        var foundTopLevelWindow:Boolean = false;

        var n:int = rawChildren.numChildren;
        for (var i:int = 0; i < n; i++)
        {
            var child:IStyleClient =
                rawChildren.getChildAt(i) as IStyleClient;

            if (child)
                child.regenerateStyleCache(recursive);

            if (isTopLevelWindow(DisplayObject(child)))
                foundTopLevelWindow = true;

            // Refetch numChildren because notifyStyleChangedInChildren()
            // can add/delete a child and therefore change numChildren.
            n = rawChildren.numChildren;
        }

        // During startup the top level window isn't added
        // to the child list until late into the startup sequence.
        // Make sure we call regenerateStyleCache()
        // on the top level window even if it isn't a child yet.
        if (!foundTopLevelWindow && topLevelWindow is IStyleClient)
            IStyleClient(topLevelWindow).regenerateStyleCache(recursive);
    }

    /**
     *  @private
     *  Call styleChanged() and notifyStyleChangeInChildren()
     *  on all children of this SystemManager.
     *  If the recursive parameter is true, continue doing this
     *  for all descendants of these children.
     */
    mx_internal function notifyStyleChangeInChildren(styleProp:String,
                                                     recursive:Boolean):void
    {
        var foundTopLevelWindow:Boolean = false;

        var n:int = rawChildren.numChildren;
        for (var i:int = 0; i < n; i++)
        {
            var child:IStyleClient =
                rawChildren.getChildAt(i) as IStyleClient;

            if (child)
            {
                child.styleChanged(styleProp);
                child.notifyStyleChangeInChildren(styleProp, recursive);
            }

            if (isTopLevelWindow(DisplayObject(child)))
                foundTopLevelWindow = true;

            // Refetch numChildren because notifyStyleChangedInChildren()
            // can add/delete a child and therefore change numChildren.
            n = rawChildren.numChildren;
        }

        // During startup the top level window isn't added
        // to the child list until late into the startup sequence.
        // Make sure we call notifyStyleChangeInChildren()
        // on the top level window even if it isn't a child yet.
        if (!foundTopLevelWindow && topLevelWindow is IStyleClient)
        {
            IStyleClient(topLevelWindow).styleChanged(styleProp);
            IStyleClient(topLevelWindow).notifyStyleChangeInChildren(
                styleProp, recursive);
        }
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
     * The system manager proxy has only one child that is a focus manager container.
     * Iterate thru the children until we find it.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
        if (!topLevel && topLevelSystemManager)
        {
            SystemManager(topLevelSystemManager).addChildBridgeListeners(bridge);
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
        if (!topLevel && topLevelSystemManager)
        {
            SystemManager(topLevelSystemManager).removeChildBridgeListeners(bridge);
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
        if (!topLevel && topLevelSystemManager)
        {
            SystemManager(topLevelSystemManager).addParentBridgeListeners();
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
    }
    
    /**
     * @private
     * 
     * remove listeners for events and requests we might receive from our parent if 
     * our parent is using a sandbox bridge to communicate with us.
     */
    mx_internal function removeParentBridgeListeners():void
    {
        if (!topLevel && topLevelSystemManager)
        {
            SystemManager(topLevelSystemManager).removeParentBridgeListeners();
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
    }

    /**
     * Add a bridge to talk to the child owned by <code>owner</code>.
     * 
     * @param bridge the bridge used to talk to the parent. 
     * @param owner the display object that owns the bridge.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
            swfBridgeGroup = new SWFBridgeGroup(this);

        swfBridgeGroup.addChildBridge(bridge, ISWFBridgeProvider(owner));
        fm.addSWFBridge(bridge, owner);
        
        if (!bridgeToFocusManager)
            bridgeToFocusManager = new Dictionary();
            
        bridgeToFocusManager[bridge] = fm;

        addChildBridgeListeners(bridge);
        
        // dispatch message that we are adding a bridge.
        dispatchEvent(new FlexChangeEvent(FlexChangeEvent.ADD_CHILD_BRIDGE, false, false, bridge));
    }

    /**
     * Remove a child bridge.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function removeChildBridge(bridge:IEventDispatcher):void
    {
        // dispatch message that we are removing a bridge.
        dispatchEvent(new FlexChangeEvent(FlexChangeEvent.REMOVE_CHILD_BRIDGE, false, false, bridge));
        
        var fm:IFocusManager = IFocusManager(bridgeToFocusManager[bridge]);
        fm.removeSWFBridge(bridge);
        swfBridgeGroup.removeChildBridge(bridge);

        delete bridgeToFocusManager[bridge];
        removeChildBridgeListeners(bridge);
    }

    /**
     * @inheritdoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function useSWFBridge():Boolean
    {
        if (isStageRoot)
            return false;
            
        if (!topLevel && topLevelSystemManager)
            return topLevelSystemManager.useSWFBridge();
            
        var sbRoot:DisplayObject = getSandboxRoot();
        
        // if we're toplevel and we aren't the sandbox root, we need a bridge
        if (topLevel && sbRoot != this)
            return true;
        
        // we also need a bridge even if we're the sandbox root
        // but not a stage root, but our parent loader is a bootstrap
        // that is not the stage root
        if (sbRoot == this)
        {
            try
            {
                // check if the loader info is valid.
                root.loaderInfo.parentAllowsChild;
                
                if (parentAllowsChild && childAllowsParent)
                {
                    try
                    {
                        if (!parent.dispatchEvent(new Event("mx.managers.SystemManager.isStageRoot", false, true)))
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
            var lastParent:DisplayObject = parent;
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
                if (parent.hasEventListener(InterManagerRequest.SYSTEM_MANAGER_REQUEST))
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
     *  @inheritdoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */  
    public function getVisibleApplicationRect(bounds:Rectangle = null):Rectangle
    {
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
        
        // send a message to parent for their visible rect.
        if (useSWFBridge())
        {
            var bridge:IEventDispatcher = swfBridgeGroup.parentBridge;
            var request:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.GET_VISIBLE_RECT_REQUEST,
                                                                    false, false,
                                                                    bridge,
                                                                    bounds);
            bridge.dispatchEvent(request);
            bounds = Rectangle(request.data);
        }
        
        return bounds;
    }
 
   /**
    *  @inheritdoc
    *  
    *  @langversion 3.0
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */  
    public function deployMouseShields(deploy:Boolean):void
    {
        var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.DRAG_MANAGER_REQUEST, false, false,
                                    "mouseShield", deploy);
        getSandboxRoot().dispatchEvent(me);           
    }
    
    /**
     * @private
     * 
     * Notify parent that a new window has been activated.
     * 
     * @param window window that was activated.
     */
    mx_internal function dispatchActivatedWindowEvent(window:DisplayObject):void
    {
        var bridge:IEventDispatcher = swfBridgeGroup ? swfBridgeGroup.parentBridge : null;
        if (bridge)
        {
            var sbRoot:DisplayObject = getSandboxRoot();
            var sendToSbRoot:Boolean = sbRoot != this;
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
     *        the message is going outside the security domain.
     */
    private function dispatchDeactivatedWindowEvent(window:DisplayObject):void
    {
        var bridge:IEventDispatcher = swfBridgeGroup ? swfBridgeGroup.parentBridge : null;
        if (bridge)
        {
            var sbRoot:DisplayObject = getSandboxRoot();
            var sendToSbRoot:Boolean = sbRoot != this;
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
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function updateLastActiveForm():void
    {
        // find "form" in the forms array and move that entry to 
        // the end of the array.
        var n:int = forms.length;
        if (n < 2)
            return; // zero or one forms, no need to update
            
        var index:int = -1;
        for (var i:int = 0; i < n; i++)
        {
            if (areFormsEqual(form, forms[i]))
            {
                index = i;
                break;
            }
        }
        
        if (index >= 0)
        {
            forms.splice(index, 1);
            forms.push(form);
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
            throw new Error();  // bridge is required.
            
        if (!idToPlaceholder)
            idToPlaceholder = [];
            
        idToPlaceholder[id] = new PlaceholderData(previousId, bridge, placeholder); 
    }
    
    private function removePlaceholderId(id:String):void
    {
        delete idToPlaceholder[id];
    }

    private var currentSandboxEvent:Event;

    /**
     * request the parent to add an event listener.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
            if (arr[i] != this)
            {
                arr[i].addEventListener(type, listener, useCapture, priority, useWeakReference);
            }
        }
        SystemManagerGlobals.changingListenersInOtherSystemManagers = false;
    }

    /**
     * request the parent to remove an event listener.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
            if (arr[i] != this)
            {
                arr[i].removeEventListener(type, listener, useCapture);
            }
        }
        SystemManagerGlobals.changingListenersInOtherSystemManagers = false;
    }

    private var dispatchingToSystemManagers:Boolean = false;

    private function dispatchEventToOtherSystemManagers(event:Event):void
    {
        dispatchingToSystemManagers = true;
        var arr:Array = SystemManagerGlobals.topLevelSystemManagers;
        var n:int = arr.length;
        for (var i:int = 0; i < n; i++)
        {
            if (arr[i] != this)
            {
                arr[i].dispatchEvent(event);
            }
        }
        dispatchingToSystemManagers = false;
    }

    /**
     *  dispatch the event to all sandboxes except the specified one
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function addEventListenerToSandboxes(type:String, listener:Function, useCapture:Boolean = false, 
                priority:int=0, useWeakReference:Boolean=false, skip:IEventDispatcher = null):void
    {
        if (!swfBridgeGroup)
            return;

        // trace(">>addEventListenerToSandboxes", this, type);

        var request:EventListenerRequest = new EventListenerRequest(EventListenerRequest.ADD_EVENT_LISTENER_REQUEST, false, false,
                                                    type, 
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
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    private function removeEventListenerFromSandboxes(type:String, listener:Function, 
                                                      useCapture:Boolean = false,
                                                      skip:IEventDispatcher = null):void 
    {
        if (!swfBridgeGroup)
            return;

        // trace(">>removeEventListenerToSandboxes", this, type);
        var request:EventListenerRequest = new EventListenerRequest(EventListenerRequest.REMOVE_EVENT_LISTENER_REQUEST, false, false,
                                                                                type, 
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
        if (this != sbRoot)
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
                    if (!DisplayObjectContainer(document).contains(DisplayObject(exclude)))
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
        if (dispatchingToSystemManagers)
            return;

        dispatchEventFromSWFBridges(event);

        // ask the sandbox root if it was the original dispatcher of this event
        // if it was then don't dispatch to ourselves because we could have
        // got this event by listening to sandboxRoot ourselves.
        var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.SYSTEM_MANAGER_REQUEST);
        me.name = "sameSandbox";
        me.value = event;
        getSandboxRoot().dispatchEvent(me);

        if (!me.value)
            dispatchEvent(event);
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
        getSandboxRoot().dispatchEvent(me);

        if (!me.value)
            dispatchEvent(marshaledEvent);
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
                eventProxy = new EventProxy(this);
            }
            
            actualType = EventUtil.sandboxMouseEventMap[request.eventType];
            if (actualType)
            {
                if (isTopLevelRoot())
                {
                    stage.addEventListener(MouseEvent.MOUSE_MOVE, resetMouseCursorTracking, true, EventPriority.CURSOR_MANAGEMENT + 1, true);
                }
                else
                {
                    super.addEventListener(MouseEvent.MOUSE_MOVE, resetMouseCursorTracking, true, EventPriority.CURSOR_MANAGEMENT + 1, true);
                }

                // add listeners in other sandboxes in capture mode so we don't miss anything
                addEventListenerToSandboxes(request.eventType, sandboxMouseListener,
                            true, request.priority, request.useWeakReference, event.target as IEventDispatcher);
                addEventListenerToOtherSystemManagers(request.eventType, otherSystemManagerMouseListener, 
                            true, request.priority, request.useWeakReference);
                if (getSandboxRoot() == this)
                {
                    if (isTopLevelRoot() &&
                       (actualType == MouseEvent.MOUSE_UP || actualType == MouseEvent.MOUSE_MOVE))
                    {
                        stage.addEventListener(actualType, eventProxy.marshalListener,
                            false, request.priority, request.useWeakReference);
                    }

                    super.addEventListener(actualType, eventProxy.marshalListener,
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
                if (getSandboxRoot() == this)
                {
                    if (isTopLevelRoot() &&
                       (actualType == MouseEvent.MOUSE_UP || actualType == MouseEvent.MOUSE_MOVE))
                    {
                        stage.removeEventListener(actualType, eventProxy.marshalListener);
                    }
    
                    super.removeEventListener(actualType, eventProxy.marshalListener, true);
                }
            }
        }       
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
    /*      !topLevel && parent is Loader ?
            Loader(parent).contentLoaderInfo.applicationDomain :
            info()["currentDomain"] as ApplicationDomain;
*  
*  @langversion 3.0
*  @playerversion AIR 1.1
*  @productversion Flex 3
*/
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
     *  @private
     *  Track mouse clicks to see if we change top-level forms.
     */
    private function mouseDownHandler(event:MouseEvent):void
    {
        // Reset the idle counter.
        idleCounter = 0;

        // If an object was clicked that is inside another system manager 
        // in a bridged application, activate the current document because
        // the bridge application is considered part of the main application.
        // We also see mouse clicks on dialogs popped up from compatible applications.
        if (isDisplayObjectInABridgedApplication(event.target as DisplayObject))
        {
            // trace("SM:mouseDownHandler click in a bridged application");
            if (isTopLevelRoot())
                activateForm(document);
            else
                dispatchActivatedApplicationEvent();

            return;
        } 

        if (numModalWindows == 0) // no modal windows are up
        {
            // Activate a window if we need to.
            if (forms.length > 1)
            {
                var n:int = forms.length;
                var p:DisplayObject = DisplayObject(event.target);
                var isApplication:Boolean = document is IRawChildrenContainer ? 
                                            IRawChildrenContainer(document).rawChildren.contains(p) :
                                            document.contains(p);
                while (p)
                {
                    for (var i:int = 0; i < n; i++)
                    {
                        var form_i:Object = isRemotePopUp(forms[i]) ? forms[i].window : forms[i];
                        if (form_i == p)
                        {
                            var j:int = 0;
                            var index:int;
                            var newIndex:int;
                            var childList:IChildList;

                            if (p != form && p is IFocusManagerContainer)
                                activate(IFocusManagerContainer(p));
                            if (popUpChildren.contains(p))
                                childList = popUpChildren;
                            else
                                childList = this;

                            index = childList.getChildIndex(p); 
                            newIndex = index;
                            
                            //we need to reset n because activating p's 
                            //FocusManager could have caused 
                            //forms.length to have changed. 
                            n = forms.length;
                            for (j = 0; j < n; j++)
                            {
                                var f:DisplayObject;
                                var isRemotePopUp:Boolean = isRemotePopUp(forms[j]);
                                if (isRemotePopUp)
                                {
                                    if (forms[j].window is String)
                                        continue;
                                    f = forms[j].window;
                                }
                                else 
                                    f = forms[j];
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
    
    /**
     * @private
     * 
     * Used to locate untrusted forms. Maps string ids to Objects.
     * The object make be the SystemManagerProxy of a form or it may be
     * the bridge to the child application where the object lives.
     */
    private var idToPlaceholder:Object;

    private var eventProxy:EventProxy;
    private var weakReferenceProxies:Dictionary = new Dictionary(true);
    private var strongReferenceProxies:Dictionary = new Dictionary(false);

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: EventDispatcher
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Only create idle events if someone is listening.
     */
    override public function addEventListener(type:String, listener:Function,
                                              useCapture:Boolean = false,
                                              priority:int = 0,
                                              useWeakReference:Boolean = false):void
    {
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

        if (type == MouseEvent.MOUSE_MOVE || type == MouseEvent.MOUSE_UP || type == MouseEvent.MOUSE_DOWN 
                || type == Event.ACTIVATE || type == Event.DEACTIVATE)
        {
            // also listen to stage if allowed
            try
            {
                if (stage)
                {
                    var newListener:StageEventProxy = new StageEventProxy(listener);
                    stage.addEventListener(type, newListener.stageListener, false, priority, useWeakReference);
                    if (useWeakReference)
                        weakReferenceProxies[listener] = newListener;
                    else
                        strongReferenceProxies[listener] = newListener;
                }
            }
            catch (error:SecurityError)
            {
            }
        }
        
        if (hasSWFBridges() || SystemManagerGlobals.topLevelSystemManagers.length > 1)
        {
            if (!eventProxy)
            {
                eventProxy = new EventProxy(this);
            }

            var actualType:String = EventUtil.sandboxMouseEventMap[type];
            if (actualType)
            {
                if (isTopLevelRoot())
                {
                    stage.addEventListener(MouseEvent.MOUSE_MOVE, resetMouseCursorTracking, true, EventPriority.CURSOR_MANAGEMENT + 1, true);
                    addEventListenerToSandboxes(SandboxMouseEvent.MOUSE_MOVE_SOMEWHERE, resetMouseCursorTracking, true, EventPriority.CURSOR_MANAGEMENT + 1, true);
                }
                else
                {
                    super.addEventListener(MouseEvent.MOUSE_MOVE, resetMouseCursorTracking, true, EventPriority.CURSOR_MANAGEMENT + 1, true);
                }
                
                addEventListenerToSandboxes(type, sandboxMouseListener, useCapture, priority, useWeakReference);
                if (!SystemManagerGlobals.changingListenersInOtherSystemManagers)
                    addEventListenerToOtherSystemManagers(type, otherSystemManagerMouseListener, useCapture, priority, useWeakReference)
                if (getSandboxRoot() == this)
                    super.addEventListener(actualType, eventProxy.marshalListener,
                            useCapture, priority, useWeakReference);
                
                // Set useCapture to false because we will never see an event 
                // marshalled in the capture phase.
                super.addEventListener(type, listener, false, priority, useWeakReference);
                return;
            }
        }
        
        
        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }
    
    /**
     * @private
     * 
     * Test if this system manager has any sandbox bridges.
     * 
     * @return true if there are sandbox bridges, false otherwise.
     */
    private function hasSWFBridges():Boolean
    {
        if (swfBridgeGroup)
            return true;
        
        return false;
    }
    
    /**
     *  @private
     */
    override public function removeEventListener(type:String, listener:Function,
                                                 useCapture:Boolean = false):void
    {
        // These two events will dispatched to applications in sandboxes.
        if (type == FlexEvent.RENDER || type == FlexEvent.ENTER_FRAME)
        {
            if (type == FlexEvent.RENDER)
                type = Event.RENDER;
            else
                type = Event.ENTER_FRAME;
                
            try
            {
                // Remove both listeners in case the system manager was added
                // or removed from the stage after the listener was added.
                if (stage)
                    stage.removeEventListener(type, listener, useCapture);

                super.removeEventListener(type, listener, useCapture);
            }
            catch (error:SecurityError)
            {
                super.removeEventListener(type, listener, useCapture);
            }
        
            return;
        }

        if (type == MouseEvent.MOUSE_MOVE || type == MouseEvent.MOUSE_UP || type == MouseEvent.MOUSE_DOWN 
                || type == Event.ACTIVATE || type == Event.DEACTIVATE)
        {
            // also listen to stage if allowed
            try
            {
                if (stage)
                {
                    var newListener:StageEventProxy = weakReferenceProxies[listener];
                    if (!newListener)
                    {
                        newListener = strongReferenceProxies[listener];
                        if (newListener)
                            delete strongReferenceProxies[listener];
                    }
                    if (newListener)
                        stage.removeEventListener(type, newListener.stageListener, false);
                }
            }
            catch (error:SecurityError)
            {
            }
        }

        if (hasSWFBridges() || SystemManagerGlobals.topLevelSystemManagers.length > 1)
        {
            var actualType:String = EventUtil.sandboxMouseEventMap[type];
            if (actualType)
            {
                if (getSandboxRoot() == this && eventProxy)
                    super.removeEventListener(actualType, eventProxy.marshalListener,
                            useCapture);
                if (!SystemManagerGlobals.changingListenersInOtherSystemManagers)
                    removeEventListenerFromOtherSystemManagers(type, otherSystemManagerMouseListener, useCapture);
                removeEventListenerFromSandboxes(type, sandboxMouseListener, useCapture);
                super.removeEventListener(type, listener, false);
                return;
            }
        }
        
        super.removeEventListener(type, listener, useCapture);
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
        child.dispatchEvent(new FlexEvent(FlexEvent.ADD));

        if (child is IUIComponent)
            IUIComponent(child).initialize(); // calls child.createChildren()
    }

    /**
     *  @private
     */
    mx_internal function removingChild(child:DisplayObject):void
    {
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
        addingChild(child);

        super.addChild(child);

        childAdded(child); // calls child.createChildren()

        return child;
    }

    /**
     *  @private
     */
    mx_internal function rawChildren_addChildAt(child:DisplayObject,
                                                index:int):DisplayObject
    {
        addingChild(child);

        super.addChildAt(child, index);

        childAdded(child); // calls child.createChildren()

        return child;
    }

    /**
     *  @private
     */
    mx_internal function rawChildren_removeChild(child:DisplayObject):DisplayObject
    {
        removingChild(child);

        super.removeChild(child);

        childRemoved(child);

        return child;
    }

    /**
     *  @private
     */
    mx_internal function rawChildren_removeChildAt(index:int):DisplayObject
    {
        var child:DisplayObject = super.getChildAt(index);

        removingChild(child);

        super.removeChildAt(index);

        childRemoved(child);

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
        if (event.target != this && event is SWFBridgeRequest)
            return;

        var popUpRequest:SWFBridgeRequest = SWFBridgeRequest.marshal(event);

        // If there is not for mutual trust between us an the child that wants the 
        // popup, then don't host the pop up.
        if (event.target != this)
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
            getSandboxRoot().dispatchEvent(popUpRequest);
            return;
        }
        
        // add popup as a child of this system manager
        if (!popUpRequest.data.childList || popUpRequest.data.childList == PopUpManagerChildList.PARENT)
            topMost = popUpRequest.data.parent && popUpChildren.contains(popUpRequest.data.parent);
        else
            topMost = (popUpRequest.data.childList == PopUpManagerChildList.POPUP);

        var children:IChildList;
        children = topMost ? popUpChildren : this;
        children.addChild(DisplayObject(popUpRequest.data.window));
        
        if (popUpRequest.data.modal)    
            numModalWindows++;
        
        // add popup to the list of managed forms
        var remoteForm:RemotePopUp = new RemotePopUp(popUpRequest.data.window, popUpRequest.requestor);
        forms.push(remoteForm);
        
        if (!isTopLevelRoot() && swfBridgeGroup)
        {
            // We've added the popup as far as it can go.
            // Add a placeholder to the top level root application
            var request:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.ADD_POP_UP_PLACE_HOLDER_REQUEST, 
                                                 false, false, 
                                                 popUpRequest.requestor,
                                                 { window: popUpRequest.data.window });
            request.data.placeHolderId = NameUtil.displayObjectToString(DisplayObject(popUpRequest.data.window));
            dispatchEvent(request);
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
        var popUpRequest:SWFBridgeRequest = SWFBridgeRequest.marshal(event);

        if (swfBridgeGroup.parentBridge &&
            SecurityUtil.hasMutualTrustBetweenParentAndChild(this))
        {
            // since there is mutual trust the popup is hosted by the parent.
            popUpRequest.requestor = swfBridgeGroup.parentBridge;
            getSandboxRoot().dispatchEvent(popUpRequest);
            return;
        }
                    
        if (popUpChildren.contains(popUpRequest.data.window))
            popUpChildren.removeChild(popUpRequest.data.window);
        else
            removeChild(DisplayObject(popUpRequest.data.window));
        
        if (popUpRequest.data.modal)    
            numModalWindows--;

        removeRemotePopUp(new RemotePopUp(popUpRequest.data.window, popUpRequest.requestor));
        
        if (!isTopLevelRoot() && swfBridgeGroup)
        {
            // if we got here we know the parent is untrusted, so remove placeholders
            var request:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.REMOVE_POP_UP_PLACE_HOLDER_REQUEST, 
                                                false, false, 
                                                popUpRequest.requestor,
                                                {placeHolderId: NameUtil.displayObjectToString(popUpRequest.data.window)
                                                });
            dispatchEvent(request);
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

        if (event.target != this && event is SWFBridgeRequest)
            return;
        
        if (!forwardPlaceholderRequest(popUpRequest, true))
        {
            // Create a RemotePopUp and add it.
            var remoteForm:RemotePopUp = new RemotePopUp(popUpRequest.data.placeHolderId, popUpRequest.requestor);
            forms.push(remoteForm);
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
        
        if (!forwardPlaceholderRequest(popUpRequest, false))
        {
            // remove the placeholder from forms array
            var n:int = forms.length;
            for (var i:int = 0; i < n; i++)
            {
                if (isRemotePopUp(forms[i]))
                {
                    if (forms[i].window == popUpRequest.data.placeHolderId &&
                        forms[i].bridge == popUpRequest.requestor)
                    {
                        forms.splice(i, 1);
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
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function forwardFormEvent(event:SWFBridgeEvent):Boolean
    {
        
        if (isTopLevelRoot())
            return false;           
            
        var bridge:IEventDispatcher = swfBridgeGroup.parentBridge; 
        if (bridge)
        {
            var sbRoot:DisplayObject = getSandboxRoot();
            event.data.notifier = bridge;
            if (sbRoot == this)
            {
                if (!(event.data.window is String))
                    event.data.window = NameUtil.displayObjectToString(DisplayObject(event.data.window));
                else
                    event.data.window = NameUtil.displayObjectToString(DisplayObject(this)) + "." + event.data.window;
                
                bridge.dispatchEvent(event);
            }
            else
            {
                if (event.data.window is String)
                    event.data.window = NameUtil.displayObjectToString(DisplayObject(this)) + "." + event.data.window;
 
                sbRoot.dispatchEvent(event);
            }
        }

        return true;
    }
    
    /**
     * Forward an AddPlaceholder request up the parent chain, if needed.
     * 
     * @param eObj PopupRequest as and Object.
     * @param addPlaceholder true if adding a placeholder, false it removing a placeholder.
     * @return true if the request was forwared, false otherwise
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function forwardPlaceholderRequest(request:SWFBridgeRequest, addPlaceholder:Boolean):Boolean
    {
        // Only the top level root tracks the placeholders.
        // If we are not the top level root then keep passing
        // the message up the parent chain.
        if (isTopLevelRoot())
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
            request.data.placeHolderId = NameUtil.displayObjectToString(this) + "." + request.data.placeHolderId;
        }

        if (addPlaceholder)
            addPlaceholderId(request.data.placeHolderId, oldId, request.requestor, refObj);
        else 
            removePlaceholderId(request.data.placeHolderId);
                
        
        var sbRoot:DisplayObject = getSandboxRoot();
        var bridge:IEventDispatcher = swfBridgeGroup.parentBridge; 
        request.requestor =  bridge;
        if (sbRoot == this)
            bridge.dispatchEvent(request);
        else 
            sbRoot.dispatchEvent(request);
            
        return true;
    }

    /**
     * One of the system managers in another sandbox deactivated and sent a message
     * to the top level system manager. In response the top-level system manager
     * needs to find a new form to activate.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function deactivateFormSandboxEventHandler(event:Event):void
    {
        // trace("bridgeDeactivateFormEventHandler");

        if (event is SWFBridgeRequest)
            return;

        var bridgeEvent:SWFBridgeEvent = SWFBridgeEvent.marshal(event);

        if (!forwardFormEvent(bridgeEvent))
        {
            // deactivate the form
            if (isRemotePopUp(form) && 
                RemotePopUp(form).window == bridgeEvent.data.window &&
                RemotePopUp(form).bridge == bridgeEvent.data.notifier)
                deactivateForm(form);
        }
    }
    
    /**
     * A form in one of the system managers in another sandbox has been activated. 
     * The form being activate is identified. 
     * In response the top-level system manager needs to activate the given form
     * and deactivate the currently active form, if any.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function activateFormSandboxEventHandler(event:Event):void
    {
        // trace("bridgeActivateFormEventHandler");
        var bridgeEvent:SWFBridgeEvent = SWFBridgeEvent.marshal(event);

        if (!forwardFormEvent(bridgeEvent))
            // just call activate on the remote form.
            activateForm(new RemotePopUp(bridgeEvent.data.window, bridgeEvent.data.notifier));          
    }
        
    /**
     * One of the system managers in another sandbox activated and sent a message
     * to the top level system manager to deactivate this form. In response the top-level system manager
     * needs to deactivate all other forms except the top level system manager's.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function activateApplicationSandboxEventHandler(event:Event):void
    {
        // trace("bridgeActivateApplicationEventHandler");
        if (!isTopLevelRoot())
        {
            swfBridgeGroup.parentBridge.dispatchEvent(event);
            return;     
        }

        // An application was activated, active the main document.
        activateForm(document);
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
            
        if (!preProcessModalWindowRequest(request, getSandboxRoot()))
            return;
                        
        // Ensure a PopUpManager exists and dispatch the request it is
        // listening for.
        Singleton.getInstance("mx.managers::IPopUpManager");
        dispatchEvent(request);
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
        if (!DisplayObjectContainer(document).contains(owner))
            forwardRequest = false;    
                    
        if (owner is ISWFLoader)
            localRect = ISWFLoader(owner).getVisibleApplicationRect();
        else
        {
            localRect = owner.getBounds(this);
            var pt:Point = localToGlobal(localRect.topLeft);
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
        if (!isTopLevelRoot() && event is SWFBridgeRequest)
            return;

        var request:SWFBridgeRequest = SWFBridgeRequest.marshal(event);
        
        // forward request 
        if (!isTopLevelRoot())
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
        if (!isTopLevelRoot() && event is SWFBridgeRequest)
            return;
        
        var request:SWFBridgeRequest = SWFBridgeRequest.marshal(event);
        
        // forward request 
        if (!isTopLevelRoot())
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
        if (!isTopLevelRoot() && event is SWFBridgeRequest)
            return;
        
        var request:SWFBridgeRequest = SWFBridgeRequest.marshal(event);
        
        // forward request 
        if (!isTopLevelRoot())
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
        if (isTopLevelRoot())
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
        // empty.  This should never be the root of a SWF
    }
    
    /**
     * @private
     * 
     * Get the size of this System Manager.
     * Sent by a SWFLoader.
     */
    private function getSizeRequestHandler(event:Event):void
    {
        // empty.  This should never be the root of a SWF
    }
    
    /**
     *  @private
     * 
     *  Handle request to activate a particular form.
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
            throw new Error();  // should never get here
    }

    /**
     *  @private
     * 
     *  Handle request to deactivate a particular form.
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
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function isBridgeChildHandler(event:Event):void
    {
        // if we are broadcasting messages, ignore the messages
        // we send to ourselves.
        if (event is SWFBridgeRequest)
            return;

        var eObj:Object = Object(event);

        eObj.data = eObj.data && rawChildren.contains(eObj.data as DisplayObject);
    }
    
    /**
     * Can this form be activated. The current test is if the given pop up 
     * is visible and is enabled. 
     *
     * Set the data property to indicate if can be activated
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
            throw new Error();  // should never get here
    }

    /**
     * @private
     * 
     * Test if a display object is in an applcation we want to communicate with over a bridge.
     * 
     */
    public function isDisplayObjectInABridgedApplication(displayObject:DisplayObject):Boolean
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
                       return true;
                       
                    // reset data property
                    request.data = displayObject;
                }
            }
        }
            
        return false;
    }

    /**
     * redispatch certian events to other top-level windows
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function multiWindowRedispatcher(event:Event):void
    {
        if (!dispatchingToSystemManagers)
        {
            dispatchEventToOtherSystemManagers(event);
        }
    }

    /**
     * Create the requested manager
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function initManagerHandler(event:Event):void
    {
        if (!dispatchingToSystemManagers)
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
     *  Add child to requested childList
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function addChildToSandboxRoot(layer:String, child:DisplayObject):void
    {
        if (getSandboxRoot() == this)
        {
            this[layer].addChild(child);
        }
        else
        {
            addingChild(child);
            var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.SYSTEM_MANAGER_REQUEST);
            me.name = layer + ".addChild";
            me.value = child;
            getSandboxRoot().dispatchEvent(me);
            childAdded(child);
        }
    }

    /**
     *  Remove child from requested childList
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function removeChildFromSandboxRoot(layer:String, child:DisplayObject):void
    {
        if (getSandboxRoot() == this)
        {
            this[layer].removeChild(child);
        }
        else
        {
            removingChild(child);
            var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.SYSTEM_MANAGER_REQUEST);
            me.name = layer + ".removeChild";
            me.value = child;
            getSandboxRoot().dispatchEvent(me);
            childRemoved(child);
        }
    }


    /**
     * perform the requested action from a trusted dispatcher
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
            popUpChildren.addChild(event["value"]);
            break;
        case "popUpChildren.removeChild":
            popUpChildren.removeChild(event["value"]);
            break;
        case "cursorChildren.addChild":
            cursorChildren.addChild(event["value"]);
            break;
        case "cursorChildren.removeChild":
            cursorChildren.removeChild(event["value"]);
            break;
        case "toolTipChildren.addChild":
            toolTipChildren.addChild(event["value"]);
            break;
        case "toolTipChildren.removeChild":
            toolTipChildren.removeChild(event["value"]);
            break;
        case "screen":
            event["value"] = screen;
            break;
        case "application":
            event["value"] = document;
            break;
        case "isTopLevelRoot":
            event["value"] = isTopLevelRoot();
            break;
        case "getVisibleApplicationRect":
            event["value"] = getVisibleApplicationRect(); 
            break;
        case "bringToFront":
            if (event["value"].topMost)
                popUpChildren.setChildIndex(DisplayObject(event["value"].popUp), popUpChildren.numChildren - 1);
            else
                setChildIndex(DisplayObject(event["value"].popUp), numChildren - 1);
        
            break;
        }
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
        myWindow.nativeWindow.removeEventListener("close", cleanup);
        myWindow = null;
    }

    /**
     *  @private
     *  only registers Window for later cleanup.
     */
    mx_internal function addWindow(win:IWindow):void
    {
        myWindow = win;
        myWindow.nativeWindow.addEventListener("close", cleanup);
    }
}
}
