////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.managers
{

import flash.display.DisplayObject;
import flash.display.InteractiveObject; 
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.geom.Rectangle;
import flash.text.TextFormat;
import mx.core.IChildList;
import mx.core.IFlexModuleFactory;
import mx.core.ISWFBridgeGroup;  
import mx.managers.IFocusManagerContainer;

/**
 *  An ISystemManager manages an "application window".
 *  Every application that runs on the desktop or in a browser
 *  has an area where the visuals of the application will be
 *  displayed.  It may be a window in the operating system
 *  or an area within the browser.  That is an "application window"
 *  and different from an instance of <code>mx.core.Application</code>, which
 *  is the main "top-level" window within an application.
 *
 *  <p>Every application has an ISystemManager.  
 *  The ISystemManager  sends an event if
 *  the size of the application window changes (you cannot change it from
 *  within the application, but only through interaction with the operating
 *  system window or browser).  It parents all displayable items within the
 *  application, such as the main mx.core.Application instance and all popups, 
 *  tooltips, cursors, an so on.  Any object parented by the ISystemManager is
 *  considered to be a "top-level" window, even tooltips and cursors.</p>
 *
 *  <p>The ISystemManager also switches focus between top-level windows
 *  if there  are more than one IFocusManagerContainer displayed and users
 *  are interacting with components within the IFocusManagerContainers.</p>
 *
 *  <p>All keyboard and mouse activity that is not expressly trapped is seen
 *  by the ISystemManager, making it a good place to monitor activity
 *  should you need to do so.</p>
 *
 *  <p>If an application is loaded into another application, an ISystemManager
 *  will still be created, but will not manage an "application window",
 *  depending on security and domain rules.
 *  Instead, it will be the <code>content</code> of the <code>Loader</code> 
 *  that loaded it and simply serve as the parent of the sub-application</p>
 *
 *  <p>The ISystemManager maintains multiple lists of children, one each for
 *  tooltips, cursors, popup windows.
 *  This is how it ensures that popup windows "float" above the main
 *  application windows and that tooltips "float" above that
 *  and cursors above that.
 *  If you examine the <code>numChildren</code> property 
 *  or <code>getChildAt()</code> method on the ISystemManager
 *  you are accessing the main application window and any other windows
 *  that aren't popped up.
 *  To get the list of all windows, including popups, tooltips and cursors,
 *  use the <code>rawChildren</code> property.</p>
 */
public interface ISystemManager extends IEventDispatcher, IChildList, IFlexModuleFactory
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

    //----------------------------------
    //  cursorChildren
    //----------------------------------

	/**
	 *  An list of the custom cursors
	 *  being parented by this ISystemManager.
	 *
	 *  <p>An ISystemManager has various types of children,
	 *  such as the Application, popups, top-most windows,
	 *  tooltips, and custom cursors.
	 *  You can access the custom cursors through
	 *  the <code>cursorChildren</code> property.</p>
	 *
	 *  <p>The IChildList object has methods like <code>getChildAt()</code>
	 *  and properties like <code>numChildren</code>.
	 *  For example, <code>cursorChildren.numChildren</code> gives
	 *  the number of custom cursors (which will be either 0 or 1)
	 *  and, if a custom cursor exists, you can access it as
	 *  <code>cursorChildren.getChildAt(0)</code>.</p>
	 */
	function get cursorChildren():IChildList;
	
    //----------------------------------
    //  document
    //----------------------------------

	/**
	 *  A reference to the document object. 
	 *  A document object is an Object at the top of the hierarchy of a 
	 *  Flex application, MXML component, or AS component.
	 */
	function get document():Object;

	/**
	 *  @private
	 */
	function set document(value:Object):void;

    //----------------------------------
    //  embeddedFontList
    //----------------------------------

	/**
     *  @private
	 */
	function get embeddedFontList():Object;

    //----------------------------------
    //  focusPane
    //----------------------------------

	/**
	 *  A single Sprite shared among components used as an overlay for drawing focus.
	 *  You share it if you parent a focused component, not if you are IFocusManagerComponent.
	 */
	function get focusPane():Sprite;

	/**
	 *  @private
	 */
	function set focusPane(value:Sprite):void;

    //----------------------------------
    //  loaderInfo
    //----------------------------------

	/**
	 *  The LoaderInfo object that represents information about the application.
	 */
	function get loaderInfo():LoaderInfo;

    //----------------------------------
    //  numModalWindows
    //----------------------------------

	/**
	 *  The number of modal windows.  
	 *
	 *  <p>Modal windows don't allow
	 *  clicking in another windows which would normally 
	 *  activate the FocusManager in that window.  The PopUpManager
	 *  modifies this count as it creates and destroy modal windows.</p>
	 */
	function get numModalWindows():int;

	/**
	 *  @private
	 */
	function set numModalWindows(value:int):void;

    //----------------------------------
    //  popUpChildren
    //----------------------------------

	/**
	 *  An list of the topMost (popup)
	 *  windows being parented by this ISystemManager.
	 *
	 *  <p>An ISystemManager has various types of children,
	 *  such as the Application, popups,
	 *  tooltips, and custom cursors.
	 *  You can access the top-most windows through
	 *  the <code>popUpChildren</code> property.</p>
	 *
	 *  <p>The IChildList object has methods like <code>getChildAt()</code>
	 *  and properties like <code>numChildren</code>.
	 *  For example, <code>popUpChildren.numChildren</code> gives
	 *  the number of topmost windows and you can access them as
	 *  <code>popUpChildren.getChildAt(i)</code>.</p>
	 *
	 */
	function get popUpChildren():IChildList;

    //----------------------------------
    //  rawChildren
    //----------------------------------

	/**
	 *  A list of all children
	 *  being parented by this ISystemManager.
	 *
	 *  <p>An ISystemManager has various types of children,
	 *  such as the Application, popups, 
	 *  tooltips, and custom cursors.</p>
	 * 
	 *  <p>The IChildList object has methods like <code>getChildAt()</code>
	 *  and properties like <code>numChildren</code>.</p>
	 */
	function get rawChildren():IChildList;
	
    //----------------------------------
    //  swfBridgeGroup
    //----------------------------------

    /**
     *  Contains all the bridges to other applications
     *  that this application is connected to.
     */
    function get swfBridgeGroup():ISWFBridgeGroup;
    
    //----------------------------------
    //  screen
    //----------------------------------

	/**
	 *  The size and position of the application window.
	 *
	 *  The Rectangle object contains <code>x</code>, <code>y</code>,
	 *  <code>width</code>, and <code>height</code> properties.
	 */
	function get screen():Rectangle

    //----------------------------------
    //  stage
    //----------------------------------

	/**
	 *  The flash.display.Stage that represents the application window
	 *  mapped to this SystemManager
	 */
	function get stage():Stage

    //----------------------------------
    //  toolTipChildren
    //----------------------------------

	/**
	 *  A list of the tooltips
	 *  being parented by this ISystemManager.
	 *
	 *  <p>An ISystemManager has various types of children,
	 *  such as the Application, popups, topmost windows,
	 *  tooltips, and custom cursors.</p>
	 *
	 *  <p>The IChildList object has methods like <code>getChildAt()</code>
	 *  and properties like <code>numChildren</code>.
	 *  For example, <code>toolTipChildren.numChildren</code> gives
	 *  the number of tooltips (which will be either 0 or 1)
	 *  and, if a tooltip exists, you can access it as
	 *  <code>toolTipChildren.getChildAt(0)</code>.</p>
	 */
	function get toolTipChildren():IChildList;
	
    //----------------------------------
    //  topLevelSystemManager
    //----------------------------------

	/**
	 *  The ISystemManager responsible for the application window.
	 *  This will be the same ISystemManager unless this application
	 *  has been loaded into another application.
	 */
	function get topLevelSystemManager():ISystemManager;

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Registers a top-level window containing a FocusManager.
	 *  Called by the FocusManager, generally not called by application code.
	 *
	 *  @param f The top-level window in the application.
	 */
	function addFocusManager(f:IFocusManagerContainer):void;

	/**
	 *  Unregisters a top-level window containing a FocusManager.
	 *  Called by the FocusManager, generally not called by application code.
	 *
	 *  @param f The top-level window in the application.
	 */
	function removeFocusManager(f:IFocusManagerContainer):void;

	/**
	 *  Activates the FocusManager in an IFocusManagerContainer.
	 * 
	 *  @param f IFocusManagerContainer the top-level window
	 *  whose FocusManager should be activated.
	 */
	function activate(f:IFocusManagerContainer):void;
	
	/**
	 *  Deactivates the FocusManager in an IFocusManagerContainer, and activate
	 *  the FocusManager of the next highest window that is an IFocusManagerContainer.
	 * 
	 *  @param f IFocusManagerContainer the top-level window
	 *  whose FocusManager should be deactivated.
	 */
	function deactivate(f:IFocusManagerContainer):void;

	/**
	 *  Converts the given String to a Class or package-level Function.
	 *  Calls the appropriate <code>ApplicationDomain.getDefinition()</code> 
	 *  method based on
	 *  whether you are loaded into another application or not.
	 *
	 *  @param name Name of class, for example "mx.video.VideoManager".
	 * 
	 *  @return The Class represented by the <code>name</code>, or null.
	 */
	function getDefinitionByName(name:String):Object;

	/**
	 *  Returns <code>true</code> if this ISystemManager is responsible
	 *  for an application window, and <code>false</code> if this
	 *  application has been loaded into another application.
	 *
	 *  @return <code>true</code> if this ISystemManager is responsible
	 *  for an application window.
	 */
	function isTopLevel():Boolean;

    /**
     *  Returns <code>true</code> if the required font face is embedded
	 *  in this application, or has been registered globally by using the 
	 *  <code>Font.registerFont()</code> method.
	 *
	 *  @param tf The TextFormat class representing character formatting information.
	 *
	 *  @return <code>true</code> if the required font face is embedded
	 *  in this application, or has been registered globally by using the 
	 *  <code>Font.registerFont()</code> method.
     */
    function isFontFaceEmbedded(tf:TextFormat):Boolean;

    /**
     *  Tests if this system manager is the root of all
     *  top level system managers.
     * 
     *  @return <code>true</code> if the SystemManager
     *  is the root of all SystemManagers on the display list,
     *  and <code>false</code> otherwise.
     */
    function isTopLevelRoot():Boolean;
    
    /**
     *  Attempts to get the system manager that is the in the main application.
     *
     *  @return The main application's systemManager if allowed by
	 *  security restrictions or null if it is in a different SecurityDomain.
     */
    function getTopLevelRoot():DisplayObject;

    /**
     *  Gets the system manager is the root of all
     *  top level system managers in this SecurityDomain
     *
     *  @return the highest-level systemManager in the sandbox
     */
    function getSandboxRoot():DisplayObject;

    /** 
     *  Adds a child bridge to the system manager.
     *  Each child bridge represents components in another sandbox
     *  or compiled with a different version of Flex.
     *
     *  @param bridge The bridge for the child.
     *
     *  @param owner The SWFLoader for the child.
     */
    function addChildBridge(bridge:IEventDispatcher, owner:DisplayObject):void;

    /** 
     *  Adds a child bridge to the system manager.
     *  Each child bridge represents components in another sandbox
     *  or compiled with a different version of Flex.
     *
     *  @param bridge The bridge for the child
     */
    function removeChildBridge(bridge:IEventDispatcher):void;
    
	/**
	 *  Dispatch a message to all parent and child applications in this SystemManager's SWF bridge group, regardless of
	 *  whether they are in the same SecurityDomain or not. You can optionally exclude an application with this method's parameters.
	 *
     	 *  @param event The event to dispatch.
     	 *  
     	 *  @param skip Specifies an IEventDispatcher that you do not want to dispatch a message to. This is typically used to skip the
     	 *  IEventDispatcher that originated the event.
	 * 
     	 *  @param trackClones Whether to keep a reference to the events as they are dispatched.
     	 *  
     	 *  @param toOtherSystemManagers Whether to dispatch the event to other top-level SystemManagers in AIR.
	 */
	function dispatchEventFromSWFBridges(event:Event, skip:IEventDispatcher = null, trackClones:Boolean = false, toOtherSystemManagers:Boolean = false):void

    /**
     *  Determines if the caller using this system manager
     *  should should communicate directly with other managers
     *  or if it should communicate with a bridge.
     * 
     *  @return <code>true</code> if the caller using this system manager
     *  should  communicate using sandbox bridges.
     *  If <code>false</code> the system manager may directly call
     *  other managers directly via references.
     */
    function useSWFBridge():Boolean;
    
    /** 
     *  Adds child to sandbox root in the layer requested.
     *
     *  @param layer Name of IChildList in SystemManager
     *
     *  @param child DisplayObject to add
     */
    function addChildToSandboxRoot(layer:String, child:DisplayObject):void;

    /** 
     *  Removes child from sandbox root in the layer requested.
     *
     *  @param layer Name of IChildList in SystemManager
     *
     *  @param child DisplayObject to add
     */
    function removeChildFromSandboxRoot(layer:String, child:DisplayObject):void;
    
    /**
     *  Tests if a display object is in a child application
     *  that is loaded in compatibility mode or in an untrusted sandbox.
     * 
     *  @param displayObject The DisplayObject to test.
     * 
     *  @return <code>true</code> if <code>displayObject</code>
     *  is in a child application that is loaded in compatibility mode
     *  or in an untrusted sandbox, and <code>false</code> otherwise.
     */
    function isDisplayObjectInABridgedApplication(
                        displayObject:DisplayObject):Boolean;

    /**
     *  Get the bounds of the loaded application that are visible to the user
     *  on the screen.
     * 
     *  @param bounds Optional. The starting bounds for the visible rect. The
     *  bounds are in global coordinates. If <code>bounds</code> is null the 
     *  starting bounds is defined by the <code>screen</code> property of the 
     *  system manager. 
     * 
     *  @return a <code>Rectangle</code> including the visible portion of the this 
     *  object. The rectangle is in global coordinates.
     */  
    function getVisibleApplicationRect(bounds:Rectangle = null):Rectangle;
    
    /**
     *  Deploy or remove mouse shields. Mouse shields block mouse input to untrusted
     *  applications. The reason you would want to block mouse input is because
     *  when you are dragging over an untrusted application you would normally not
     *  receive any mouse move events. The Flash Player does not send events
     *  across trusted/untrusted boundries due to security concerns. By covering
     *  the untrusted application with a mouse shield (assuming you are its parent)
     *  you can get mouse move message and the drag operation will work as expected. 
     * 
     *  @param deploy <code>true</code> to deploy the mouse shields, <code>false</code>
     *  to remove the mouse shields.
     */
    function deployMouseShields(deploy:Boolean):void; 

}

}
