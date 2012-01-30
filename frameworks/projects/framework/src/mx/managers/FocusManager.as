////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2007 Adobe Systems Incorporated
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
import flash.display.InteractiveObject;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.IEventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.system.Capabilities;
import flash.text.TextField;
import flash.ui.Keyboard;
import flash.utils.Dictionary;

import mx.core.Application;
import mx.core.FlexSprite;
import mx.core.ISWFLoader;
import mx.core.IButton;
import mx.core.IChildList;
import mx.core.IRawChildrenContainer;
import mx.core.ISWFBridgeProvider;
import mx.core.IUIComponent;
import mx.core.mx_internal;
import mx.core.SWFBridgeGroup;
import mx.events.FlexEvent;
import mx.events.FocusRequestDirection;
import mx.events.SWFBridgeEvent;
import mx.events.SWFBridgeRequest;
import mx.utils.DisplayUtil;

use namespace mx_internal;

/**
 *  The FocusManager class manages the focus on components in response to mouse
 *  activity or keyboard activity (Tab key).  There can be several FocusManager
 *  instances in an application.  Each FocusManager instance 
 *  is responsible for a set of components that comprise a "tab loop".  If you
 *  hit Tab enough times, focus traverses through a set of components and
 *  eventually get back to the first component that had focus.  That is a "tab loop"
 *  and a FocusManager instance manages that loop.  If there are popup windows
 *  with their own set of components in a "tab loop" those popup windows will have
 *  their own FocusManager instances.  The main application always has a
 *  FocusManager instance.
 *
 *  <p>The FocusManager manages focus from the "component level".
 *  In Flex, a UITextField in a component is the only way to allow keyboard entry
 *  of text. To the Flash Player or AIR, that UITextField has focus. However, from the 
 *  FocusManager's perspective the component that parents the UITextField has focus.
 *  Thus there is a distinction between component-level focus and player-level focus.
 *  Application developers generally only have to deal with component-level focus while
 *  component developers must understand player-level focus.</p>
 *
 *  <p>All components that can be managed by the FocusManager must implement
 *  mx.managers.IFocusManagerComponent, whereas objects managed by player-level focus do not.</p>  
 *
 *  <p>The FocusManager also managers the concept of a defaultButton, which is
 *  the Button on a form that dispatches a click event when the Enter key is pressed
 *  depending on where focus is at that time.</p>
 */
public class FocusManager implements IFocusManager
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * 
	 * Default value of parameter, ignore. 
	 */
	private static const FROM_INDEX_UNSPECIFIED:int = -2;
	
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  <p>A FocusManager manages the focus within the children of an IFocusManagerContainer.
     *  It installs itself in the IFocusManagerContainer during execution
     *  of the constructor.</p>
     *
     *  @param container An IFocusManagerContainer that hosts the FocusManager.
     *
     *  @param popup If <code>true</code>, indicates that the container
     *  is a popup component and not the main application.
     */
    public function FocusManager(container:IFocusManagerContainer, popup:Boolean = false)
    {
        super();

		this.popup = popup;
		
        browserMode = Capabilities.playerType == "ActiveX" && !popup;

        container.focusManager = this; // this property name is reserved in the parent

        // trace("FocusManager constructor " + container + ".focusManager");
        
        _form = container;
        
        focusableObjects = [];

        focusPane = new FlexSprite();
        focusPane.name = "focusPane";

        addFocusables(DisplayObject(container));
        
        // Listen to the stage so we know when the root application is loaded.
        container.addEventListener(Event.ADDED, addedHandler);
        container.addEventListener(Event.REMOVED, removedHandler);
        container.addEventListener(FlexEvent.SHOW, showHandler);
        container.addEventListener(FlexEvent.HIDE, hideHandler);
        
        //special case application and window
        if (container.systemManager is SystemManager)
        {
            // special case application.  It shouldn't need to be made
            // active and because we defer appCreationComplete, this 
            // would steal focus back from any popups created during
            // instantiation
            if (container != SystemManager(container.systemManager).application)
                container.addEventListener(FlexEvent.CREATION_COMPLETE,
                                       creationCompleteHandler);
        }
        
        // Make sure the SystemManager is running so it can tell us about
        // mouse clicks and stage size changes.
		try
		{
        	container.systemManager.addFocusManager(container); // build a message that does the equal

            var sm:ISystemManager = form.systemManager;

            // Set up our swfBridgeGroup. If this is a pop up then the parent 
            // bridge is empty, otherwise its the form's system manager's bridge.
            swfBridgeGroup = new SWFBridgeGroup(sm);
            if (!popup)
                swfBridgeGroup.parentBridge = sm.swfBridgeGroup.parentBridge; 
            
			// add ourselves to our parent focus manager if this is a bridged 
			// application not a dialog or other popup.
			if (sm.useSWFBridge())
			{
			    sm.addEventListener(SWFBridgeEvent.BRIDGE_APPLICATION_UNLOADING, removeFromParentBridge);

				// have the child listen to move requests from the parent.
				var bridge:IEventDispatcher = swfBridgeGroup.parentBridge;
		       	if (bridge)
	    	   	{
	       			bridge.addEventListener(SWFBridgeRequest.MOVE_FOCUS_REQUEST, focusRequestMoveHandler);
                    bridge.addEventListener(SWFBridgeRequest.SET_SHOW_FOCUS_INDICATOR_REQUEST, 
                                            setShowFocusIndicatorRequestHandler);
	       		}
	    
	   			// add listener activate/deactivate requests
	   			if (bridge && !(form.systemManager is SystemManagerProxy))
	   			{
	   				bridge.addEventListener(SWFBridgeRequest.ACTIVATE_FOCUS_REQUEST, focusRequestActivateHandler);
	   				bridge.addEventListener(SWFBridgeRequest.DEACTIVATE_FOCUS_REQUEST, focusRequestDeactivateHandler);
			   		bridge.addEventListener(SWFBridgeEvent.BRIDGE_FOCUS_MANAGER_ACTIVATE, 
			   				    		    bridgeEventActivateHandler);
	   			}
	   			
	   			// listen when the container has been added to the stage so we can add the focusable
	   			// children
	   			container.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			}
		}
		catch (e:Error)
		{
			// ignore null pointer errors caused by container using a 
			// systemManager from another sandbox.
		}
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var LARGE_TAB_INDEX:int = 99999;

    private var calculateCandidates:Boolean = true;

    /**
     *  @private
     *  We track whether we've been last activated or saw a TAB
     *  This is used in browser tab management
     */
    private var lastAction:String;

    /**
     *  @private
     *  Tab management changes based on whether were in a browser or not
     *  This value is also affected by whether you are a modal dialog or not
     */
    public var browserMode:Boolean;

    /**
     *  @private
     *  Tab management changes based on whether were in a browser or not
     *  If non-null, this is the object that will
     *  lose focus to the browser
     */
    private var browserFocusComponent:InteractiveObject;

    /**
     *  @private
     *  Total set of all objects that can receive focus
     *  but might be disabled or invisible.
     */
    private var focusableObjects:Array;
    
    /**
     *  @private
     *  Filtered set of objects that can receive focus right now.
     */
    private var focusableCandidates:Array;

    /**
     *  @private
     */
    private var activated:Boolean = false;
    
    /**
    * 	@private
    * 
    * 	true if focus was changed to one of focusable objects. False if focus passed to 
    * 	the browser.
    */
	private var focusChanged:Boolean;

    /**
	 * 	@private
	 * 
	 * 	if non-null, the location to move focus from instead of the object 
	 *  that has focus in the stage.
	 */
	 private var fauxFocus:DisplayObject;
	 
	 /**
	  *  @private
	  * 
	  *  The focus manager maintains its own bridges so a focus manager in a pop
	  *  up can move focus to another focus manager in the same pop up. That is,
	  *  A pop ups can be a collection of focus managers working together just
	  *  as is done in the System Manager's document. 
	  */
	 private var swfBridgeGroup:SWFBridgeGroup;

	/**
	 * @private
	 * 
	 * bridge handle of the last active focus manager.
	 */
     private var lastActiveFocusManager:FocusManager;
	 
	 /** 
	 * @private
	 * 
	 * Test if the focus was set locally in this focus manager (true) or
	 * if focus was transfer to another focus manager (false)
	 */
	 private var focusSetLocally:Boolean;
	 
	 /**
	 * @private
	 * 
	 * True if this focus manager is a popup, false if it is a main application.
	 * 
	 */
	 private var popup:Boolean;
	 
	 /**
	  *  @private
	  * 
	  *  Used when a the skip parameter can't be passed into 
	  *  dispatchEventFromSWFBridges() because the caller doesn't take
	  *  a skip parameter.
	  */ 
	 private var skipBridge:IEventDispatcher;
	 
	//--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  showFocusIndicator
    //----------------------------------

    /**
     *  @private
     *  Storage for the showFocusIndicator property.
     */
    private var _showFocusIndicator:Boolean = false;
    
    /**
     *  @inheritDoc
     */
    public function get showFocusIndicator():Boolean
    {
        return _showFocusIndicator;
    }
    
    /**
     *  @private
     */
    public function set showFocusIndicator(value:Boolean):void
    {
        var changed:Boolean = _showFocusIndicator != value;
        
        _showFocusIndicator = value;
        
        if (changed && !popup && form.systemManager.swfBridgeGroup)
            dispatchSetShowFocusIndicatorRequest(value, null);
    }

    //----------------------------------
    //  defaultButton
    //----------------------------------

    /**
     *  @private
     *  The current default button.
     */
    private var defButton:IButton;

    /**
     *  @private
     */
    private var _defaultButton:IButton;

    /**
     *  @inheritDoc
     */
    public function get defaultButton():IButton
    {
		return _defaultButton;
    }

    /**
     *  @private
     *  We don't type the value as Button for dependency reasons
     */
    public function set defaultButton(value:IButton):void
    {
		var button:IButton = value ? IButton(value) : null;

        if (button != _defaultButton)
        {
            if (_defaultButton)
                _defaultButton.emphasized = false;
            
            if (defButton)  
                defButton.emphasized = false;
            
            _defaultButton = button;
            defButton = button;
            
            if (button)
                button.emphasized = true;
        }
    }

    //----------------------------------
    //  defaultButtonEnabled
    //----------------------------------

    /**
     *  @private
     *  Storage for the defaultButtonEnabled property.
     */
    private var _defaultButtonEnabled:Boolean = true;

    /**
     *  @inheritDoc
     */
    public function get defaultButtonEnabled():Boolean
    {
        return _defaultButtonEnabled;
    }
    
    /**
     *  @private
     */
    public function set defaultButtonEnabled(value:Boolean):void
    {
        _defaultButtonEnabled = value;
    }
    
    //----------------------------------
    //  focusPane
    //----------------------------------

    /**
     *  @private
     *  Storage for the focusPane property.
     */
    private var _focusPane:Sprite;

    /**
     *  @inheritDoc
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
        _focusPane = value;
    }

    //----------------------------------
    //  form
    //----------------------------------

    /**
     *  @private
     *  Storage for the form property.
     */
    private var _form:IFocusManagerContainer;
    
    /**
     *  @private
     *  The form is the property where we store the IFocusManagerContainer
     *  that hosts this FocusManager.
     */
    mx_internal function get form():IFocusManagerContainer
    {
        return _form;
    }
    
    /**
     *  @private
     */
    mx_internal function set form (value:IFocusManagerContainer):void
    {
        _form = value;
    }


    //----------------------------------
    //  _lastFocus
    //----------------------------------
    
    /**
     *  @private
     *  the object that last had focus
     */
    private var _lastFocus:IFocusManagerComponent;


	/**
	 * 	@private
	 */
	mx_internal function get lastFocus():IFocusManagerComponent
	{
		return _lastFocus;
	}
	 
    //----------------------------------
    //  nextTabIndex
    //----------------------------------

    /**
     *  @inheritDoc
     */
    public function get nextTabIndex():int
    {
        return getMaxTabIndex() + 1;
    }

    /**
     *  Gets the highest tab index currently used in this Focus Manager's form or subform.
     *
     *  @return Highest tab index currently used.
     */
    private function getMaxTabIndex():int
    {
        var z:Number = 0;

        var n:int = focusableObjects.length;
        for (var i:int = 0; i < n; i++)
        {
            var t:Number = focusableObjects[i].tabIndex;
            if (!isNaN(t))
                z = Math.max(z, t);
        }
        
        return z;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     */
    public function getFocus():IFocusManagerComponent
    {
        var o:InteractiveObject = form.systemManager.stage.focus;
        return findFocusManagerComponent(o);
    }

    /**
     *  @inheritDoc
     */
    public function setFocus(o:IFocusManagerComponent):void
    {
        // trace("FM " + this + " setting focus to " + o);

        o.setFocus();
        
        focusSetLocally = true;
        
        // trace("FM set focus");
    }

    /**
     *  @private
     */
    private function focusInHandler(event:FocusEvent):void
    {
        var target:InteractiveObject = InteractiveObject(event.target);
        // trace("FocusManager focusInHandler in  = " + this._form.systemManager.loaderInfo.url);
        // trace("FM " + this + " focusInHandler " + target);

		// if the target is in a bridged application, let it handle the click.
		var sm:ISystemManager = form.systemManager;
   		if (sm.isDisplayObjectInABridgedApplication(DisplayObject(event.target)))
   			return;

        if (isParent(DisplayObjectContainer(form), target))
        {
            // trace("FM " + this + " setting last focus " + target);
            _lastFocus = findFocusManagerComponent(InteractiveObject(target));

			// handle default button here
			// we can't check for Button because of cross-versioning so
			// for now we just check for an emphasized property
			if (_lastFocus is IButton)
			{
				var x:IButton = _lastFocus as IButton;
				// if we have marked some other button as a default button
				if (defButton)
				{
					// change it to be this button
					defButton.emphasized = false;
					defButton = x;
					x.emphasized = true;
				}
			}
			else
			{
				// restore the default button to be the original one
				if (defButton && defButton != _defaultButton)
				{
					defButton.emphasized = false;
					defButton = _defaultButton;
					_defaultButton.emphasized = true;
				}
			}
		}
    }

    /**
     *  @private  Useful for debugging
     */
    private function focusOutHandler(event:FocusEvent):void
    {
        var target:InteractiveObject = InteractiveObject(event.target);
        // trace("FocusManager focusOutHandler in  = " + this._form.systemManager.loaderInfo.url);
        // trace("FM " + this + " focusOutHandler " + target);
    }

    /**
     *  @private
     *  restore focus to whoever had it last
     */
    private function activateHandler(event:Event):void
    {
//        var target:InteractiveObject = InteractiveObject(event.target);
        // trace("FM " + this + " activateHandler ", _lastFocus);
		
		// restore focus if this focus manager had last focus
	    if (_lastFocus && !browserMode)
	    	_lastFocus.setFocus();
	    lastAction = "ACTIVATE";
    }

    /**
     *  @private  Useful for debugging
     */
    private function deactivateHandler(event:Event):void
    {
        // var target:InteractiveObject = InteractiveObject(event.target);
        // trace("FM " + this + " deactivateHandler ", _lastFocus);
    }

    /**
     *  @inheritDoc
     */
    public function showFocus():void
    {
        if (!showFocusIndicator)
        {
            showFocusIndicator = true;
            if (_lastFocus)
                _lastFocus.drawFocus(true);
        }
    }

    /**
     *  @inheritDoc
     */
    public function hideFocus():void
    {
        // trace("FOcusManger " + this + " Hide Focus");
        if (showFocusIndicator)
        {
            showFocusIndicator = false;
            if (_lastFocus)
                _lastFocus.drawFocus(false);
        }
        // trace("END FOcusManger Hide Focus");
    }
    
    /**
     *  The SystemManager activates and deactivates a FocusManager
     *  if more than one IFocusManagerContainer is visible at the same time.
     *  If the mouse is clicked in an IFocusManagerContainer with a deactivated
     *  FocusManager, the SystemManager will call 
     *  the <code>activate()</code> method on that FocusManager.
     *  The FocusManager that was activated will have its <code>deactivate()</code> method
     *  called prior to the activation of another FocusManager.
     *
     *  <p>The FocusManager adds event handlers that allow it to monitor
     *  focus related keyboard and mouse activity.</p>
     */
    public function activate():void
    {
        // we can get a double activation if we're popping up and becoming visible
        // like the second time a menu appears
        if (activated)
        {
        	// trace("FocusManager is already active " + this);
            return;
        }

        //trace("FocusManager activating = " + this._form.systemManager.loaderInfo.url);
        //trace("FocusManager activating " + this);

        // listen for focus changes, use weak references for the stage
		// form.systemManager can be null if the form is created in a sandbox and 
		// added as a child to the root system manager.
		var sm:ISystemManager = form.systemManager;
		if (sm)
		{
			if (sm.isTopLevelRoot())
			{
		        sm.stage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, mouseFocusChangeHandler, false, 0, true);
		        sm.stage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler, false, 0, true);
	    	    sm.stage.addEventListener(Event.ACTIVATE, activateHandler, false, 0, true);
	        	sm.stage.addEventListener(Event.DEACTIVATE, deactivateHandler, false, 0, true);
	  		}
	  		else
	  		{
		        sm.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, mouseFocusChangeHandler, false, 0, true);
		        sm.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler, false, 0, true);
	    	    sm.addEventListener(Event.ACTIVATE, activateHandler, false, 0, true);
	        	sm.addEventListener(Event.DEACTIVATE, deactivateHandler, false, 0, true);	  			
	  		}
		}      
	        
        form.addEventListener(FocusEvent.FOCUS_IN, focusInHandler, true);
        form.addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler, true);
        form.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler); 
        // listen for default button in Capture phase. Some components like TextInput 
        // and Accordion stop the Enter key from propagating in the Bubble phase. 
        form.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true);

        activated = true;

        // Restore focus to the last control that had it if there was one.
        if (_lastFocus)
            setFocus(_lastFocus);

		// activate children in compatibility mode or in sandboxes.
    	dispatchEventFromSWFBridges(new SWFBridgeRequest(SWFBridgeRequest.ACTIVATE_FOCUS_REQUEST), skipBridge);

    }

    /**
     *  The SystemManager activates and deactivates a FocusManager
     *  if more than one IFocusManagerContainer is visible at the same time.
     *  If the mouse is clicked in an IFocusManagerContainer with a deactivated
     *  FocusManager, the SystemManager will call 
     *  the <code>activate()</code> method on that FocusManager.
     *  The FocusManager that was activated will have its <code>deactivate()</code> method
     *  called prior to the activation of another FocusManager.
     *
     *  <p>The FocusManager removes event handlers that allow it to monitor
     *  focus related keyboard and mouse activity.</p>
     */
    public function deactivate():void
    {
        // trace("FocusManager deactivating " + this);
        //trace("FocusManager deactivating = " + this._form.systemManager.loaderInfo.url);
         
        // listen for focus changes
		var sm:ISystemManager = form.systemManager;
        if (sm)
        {
			if (sm.isTopLevelRoot())
			{
		        sm.stage.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, mouseFocusChangeHandler);
		        sm.stage.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler);
	    	    sm.stage.removeEventListener(Event.ACTIVATE, activateHandler);
	        	sm.stage.removeEventListener(Event.DEACTIVATE, deactivateHandler);
	  		}
	  		else
	  		{
		        sm.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, mouseFocusChangeHandler);
		        sm.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler);
	    	    sm.removeEventListener(Event.ACTIVATE, activateHandler);
	        	sm.removeEventListener(Event.DEACTIVATE, deactivateHandler);	  			
	  		}
        }

        form.removeEventListener(FocusEvent.FOCUS_IN, focusInHandler, true);
        form.removeEventListener(FocusEvent.FOCUS_OUT, focusOutHandler, true);
        form.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler); 
        // stop listening for default button in Capture phase
        form.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true);

        activated = false;

		// deactivate children in compatibility mode or in sandboxes.
		dispatchEventFromSWFBridges(new SWFBridgeRequest(SWFBridgeRequest.DEACTIVATE_FOCUS_REQUEST), skipBridge);
    }

    /**
     *  @inheritDoc
     */
    public function findFocusManagerComponent(
                            o:InteractiveObject):IFocusManagerComponent
    {
    	return findFocusManagerComponent2(o) as IFocusManagerComponent;
    }
    
    
    /**
    * @private
    * 
    * This version of the method differs from the old one to support SWFLoader
    * being in the focusableObjects list but not being a component that
    * gets focus. SWFLoader is in the list of focusable objects so
    * focus may be passed over a bridge to the components on the other
    * side of the bridge.
    */
    private function findFocusManagerComponent2(
                            o:InteractiveObject):DisplayObject

    {
    	try
    	{
	        while (o)
	        {
	            if ((o is IFocusManagerComponent && IFocusManagerComponent(o).focusEnabled) ||
	            	 o is ISWFLoader)
	                return o;
	            
	            o = o.parent;
	        }
	    }
	    catch (error:SecurityError)
	    {
	    	// can happen in a loaded child swf
	    	// trace("findFocusManagerComponent: handling security error");
	    }

        // tab was set somewhere else
        return null;
    }

	/**
	 *  @inheritDoc
	 */
	public function moveFocus(direction:String, fromDisplayObject:DisplayObject = null):void
	{
	    if (direction == FocusRequestDirection.TOP)
	    {
	        setFocusToTop();
	        return;
	    }

        if (direction == FocusRequestDirection.BOTTOM)
        {
            setFocusToBottom();
            return;
        }
        	    
		var keyboardEvent:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
		keyboardEvent.keyCode = Keyboard.TAB;
		keyboardEvent.shiftKey = (direction == FocusRequestDirection.FORWARD) ? false : true;
		fauxFocus = fromDisplayObject;
		keyDownHandler(keyboardEvent);
		
    	var focusEvent:FocusEvent = new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE);
    	focusEvent.keyCode = Keyboard.TAB;
    	focusEvent.shiftKey = (direction == FocusRequestDirection.FORWARD) ? false : true;
    
    	keyFocusChangeHandler(focusEvent);
    	
		fauxFocus = null;
	}
	
    /**
     *  @private
     *  Returns true if p is a parent of o.
     */
    private function isParent(p:DisplayObjectContainer, o:DisplayObject):Boolean
    {
        if (p is IRawChildrenContainer)
            return IRawChildrenContainer(p).rawChildren.contains(o);
        
        return p.contains(o);
    }
    
    private function isEnabledAndVisible(o:DisplayObject):Boolean
    {
        var formParent:DisplayObjectContainer = DisplayObject(form).parent;
        
        while (o != formParent)
        {
            if (o is IUIComponent)
                if (!IUIComponent(o).enabled)
                    return false;
            if (!o.visible) 
                return false;
            o = o.parent;
        }
        return true;
    }

    /**
     *  @private
     */
    private function sortByTabIndex(a:InteractiveObject, b:InteractiveObject):int
    {
        var aa:int = a.tabIndex;
        var bb:int = b.tabIndex;

        if (aa == -1)
            aa = int.MAX_VALUE;
        if (bb == -1)
            bb = int.MAX_VALUE;

        return (aa > bb ? 1 :
                aa < bb ? -1 : sortByDepth(DisplayObject(a), DisplayObject(b)));
    }

    /**
     *  @private
     */
    private function sortFocusableObjectsTabIndex():void
    {
        //trace("FocusableObjectsTabIndex");
        
        focusableCandidates = [];
        
        var n:int = focusableObjects.length;
        for (var i:int = 0; i < n; i++)
        {
            var c:IFocusManagerComponent = focusableObjects[i] as IFocusManagerComponent;
            if ((c && c.tabIndex && !isNaN(Number(c.tabIndex))) ||
                 focusableObjects[i] is ISWFLoader)
            {
                // if we get here, it is a candidate
                focusableCandidates.push(focusableObjects[i]);
            }
        }
        
        focusableCandidates.sort(sortByTabIndex);
    }

    /**
     *  @private
     */
    private function sortByDepth(aa:DisplayObject, bb:DisplayObject):Number
    {
        var val1:String = "";
        var val2:String = "";
        var index:int;
        var tmp:String;
        var tmp2:String;
        var zeros:String = "0000";

        var a:DisplayObject = DisplayObject(aa);
        var b:DisplayObject = DisplayObject(bb);

		//TODO esg:  If a component lives inside of a group, we care about not its display object index, but
		// its index within the group.
		
        while (a != DisplayObject(form) && a.parent)
        {
            index = getChildIndex(a.parent, a);
            tmp = index.toString(16);
            if (tmp.length < 4)
            {
                tmp2 = zeros.substring(0, 4 - tmp.length) + tmp;
            }
            val1 = tmp2 + val1;
            a = a.parent;
        }
        
        while (b != DisplayObject(form) && b.parent)
        {
            index = getChildIndex(b.parent, b);
            tmp = index.toString(16);
            if (tmp.length < 4)
            {
                tmp2 = zeros.substring(0, 4 - tmp.length) + tmp;
            }
            val2 = tmp2 + val2;
            b = b.parent;
        }

        return val1 > val2 ? 1 : val1 < val2 ? -1 : 0;
    }

    private function getChildIndex(parent:DisplayObjectContainer, child:DisplayObject):int
    {
        try 
        {
            return parent.getChildIndex(child);
        }
        catch(e:Error)
        {
            if (parent is IRawChildrenContainer)
                return IRawChildrenContainer(parent).rawChildren.getChildIndex(child);
            throw e;
        }
        throw new Error("FocusManager.getChildIndex failed");   // shouldn't ever get here
    }

    /**
     *  @private
     *  Calculate what focusableObjects are valid tab candidates.
     */
    private function sortFocusableObjects():void
    {
        // trace("FocusableObjects " + focusableObjects.length.toString());
        focusableCandidates = [];
        
        var n:int = focusableObjects.length;
        for (var i:int = 0; i < n; i++)
        {
            var c:InteractiveObject = focusableObjects[i];
            // trace("  " + c);
            if (c.tabIndex && !isNaN(Number(c.tabIndex)) && c.tabIndex > 0)
            {
                sortFocusableObjectsTabIndex();
                return;
            }
            focusableCandidates.push(c);
        }
        
        focusableCandidates.sort(sortByDepth);
    }

    /**
     *  Call this method to make the system
     *  think the Enter key was pressed and the defaultButton was clicked
     */
    mx_internal function sendDefaultButtonEvent():void
    {
        // trace("FocusManager.sendDefaultButtonEvent " + defButton);
        defButton.dispatchEvent(new MouseEvent("click"));
    }

    /**
     *  @private
     *  Do a tree walk and add all children you can find.
     */
    private function addFocusables(o:DisplayObject, skipTopLevel:Boolean = false):void
    {
        // trace(">>addFocusables " + o);
        if ((o is IFocusManagerComponent) && !skipTopLevel)
        {
			
			var addToFocusables:Boolean = false;
        	if (o is IFocusManagerComponent)
        	{
	            var focusable:IFocusManagerComponent = IFocusManagerComponent(o);
	            if (focusable.focusEnabled)
	            {
	                if (focusable.tabEnabled && isTabVisible(o))
	                {
						addToFocusables = true;	                	
	                }
                }
            }

			if (addToFocusables)
			{            
               	if (focusableObjects.indexOf(o) == -1)
            	{
                    focusableObjects.push(o);
	                calculateCandidates = true;
    	            // trace("FM added " + o);
    	        }
                o.addEventListener("tabEnabledChange", tabEnabledChangeHandler);
                o.addEventListener("tabIndexChange", tabIndexChangeHandler);
   			}

        }
        
        if (o is DisplayObjectContainer)
        {
            var doc:DisplayObjectContainer = DisplayObjectContainer(o);
            // Even if they aren't focusable now,
            // listen in case they become later.
            o.addEventListener("tabChildrenChange", tabChildrenChangeHandler);

            if (doc.tabChildren)
            {
                if (o is IRawChildrenContainer)
                {
                    // trace("using view rawChildren");
                    var rawChildren:IChildList = IRawChildrenContainer(o).rawChildren;
                    // recursively visit and add children of components
                    // we don't do this for containers because we get individual
                    // adds for the individual children
                    var i:int;
                    for (i = 0; i < rawChildren.numChildren; i++)
                    {
                        try
                        {
                            addFocusables(rawChildren.getChildAt(i));
                        }
                        catch(error:SecurityError)
                        {
                            // Ignore this child if we can't access it
                            // trace("addFocusables: ignoring security error getting child from rawChildren: " + error);
                        }
                    }

                }
                else
                {
                    // trace("using container's children");
                    // recursively visit and add children of components
                    // we don't do this for containers because we get individual
                    // adds for the individual children
                    for (i = 0; i < doc.numChildren; i++)
                    {
                        try
                        {
                            addFocusables(doc.getChildAt(i));
                        }
                        catch(error:SecurityError)
                        {
                            // Ignore this child if we can't access it
                            // trace("addFocusables: ignoring security error getting child at document." + error);
                        }
                    }
                }
            }
        }
        // trace("<<addFocusables " + o);
    }

    /**
     *  @private
     *  is it really tabbable?
     */
    private function isTabVisible(o:DisplayObject):Boolean
    {
        var s:DisplayObject = DisplayObject(form.systemManager);
        if (!s) return false;

        var p:DisplayObjectContainer = o.parent;
        while (p && p != s)
        {
            if (!p.tabChildren)
                return false;
            p = p.parent;
        }
        return true;
    }

    private function isValidFocusCandidate(o:DisplayObject, g:String):Boolean
    {
        if (!isEnabledAndVisible(o))
            return false;

        if (o is IFocusManagerGroup)
        {
            // reject if it is in the same tabgroup
            var tg:IFocusManagerGroup = IFocusManagerGroup(o);
            if (g == tg.groupName) return false;
        }
        return true;
    }
    
    private function getIndexOfFocusedObject(o:DisplayObject):int
    {
        if (!o)
            return -1;

        var n:int = focusableCandidates.length;
        // trace(" focusableCandidates " + n);
        var i:int = 0;
        for (i = 0; i < n; i++)
        {
            // trace(" comparing " + focusableCandidates[i]);
            if (focusableCandidates[i] == o)
                return i;
        }

        // no match?  try again with a slower match for certain
        // cases like DG editors
        for (i = 0; i < n; i++)
        {
            var iui:IUIComponent = focusableCandidates[i] as IUIComponent;
            if (iui && iui.owns(o))
                return i;
        }

        return -1;
    }


    private function getIndexOfNextObject(i:int, shiftKey:Boolean, bSearchAll:Boolean, groupName:String):int
    {
        var n:int = focusableCandidates.length;
        var start:int = i;

        while (true)
        {
            if (shiftKey)
                i--;
            else
                i++;
            if (bSearchAll)
            {
                if (shiftKey && i < 0)
                    break;
                if (!shiftKey && i == n)
                    break;
            }
            else
            {
                i = (i + n) % n;
                // came around and found the original
                if (start == i)
                    break;
            }
            // trace("testing " + focusableCandidates[i]);
            if (isValidFocusCandidate(focusableCandidates[i], groupName))
            {
                // trace(" stopped at " + i);
                var o:DisplayObject = DisplayObject(findFocusManagerComponent2(focusableCandidates[i]));     
                if (o is IFocusManagerGroup)
                {
                    // look around to see if there's a selected member in the tabgroup
                    // otherwise use the first one we found.
                    var tg1:IFocusManagerGroup = IFocusManagerGroup(o);
                    for (var j:int = 0; j < focusableCandidates.length; j++)
                    {
                        var obj:DisplayObject = focusableCandidates[j];
                        if (obj is IFocusManagerGroup)
                        {
                            var tg2:IFocusManagerGroup = IFocusManagerGroup(obj);
                            if (tg2.groupName == tg1.groupName && tg2.selected)
                            {
                                // if objects of same group have different tab index
                                // skip you aren't selected.
                                if (InteractiveObject(obj).tabIndex != InteractiveObject(o).tabIndex && !tg1.selected)
                                    return getIndexOfNextObject(i, shiftKey, bSearchAll, groupName);

                                i = j;
                                break;
                            }
                        }
                    }

                }
                return i;
            }
        }
        return i;
    }

    /**
     *  @private
     */
    private function setFocusToNextObject(event:FocusEvent):void
    {
     	focusChanged = false;
        if (focusableObjects.length == 0)
            return;

		var focusInfo:FocusInfo = getNextFocusManagerComponent2(event.shiftKey, fauxFocus);
		// trace("winner = ", o);

		// If we are about to wrap focus around, send focus back to the parent.
		if (!popup && focusInfo.wrapped)
		{
			if (getParentBridge())
			{
				moveFocusToParent(event.shiftKey);
				return;
			}
		}
		
		setFocusToComponent(focusInfo.displayObject, event.shiftKey);		
	}

	private function setFocusToComponent(o:Object, shiftKey:Boolean):void
	{
		focusChanged = false;
		if (o)
		{
			if (o is ISWFLoader && ISWFLoader(o).swfBridge)
			{
				// send message to child swf to move focus.
				// trace("pass focus from " + this.form.systemManager.loaderInfo.url + " to " + DisplayObject(o).loaderInfo.url);
	    		var request:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.MOVE_FOCUS_REQUEST, 
	    													false, true, null,
	    													shiftKey ? FocusRequestDirection.BOTTOM : 
																	   FocusRequestDirection.TOP);
				var sandboxBridge:IEventDispatcher = ISWFLoader(o).swfBridge;
				if (sandboxBridge)
				{
    				sandboxBridge.dispatchEvent(request);
					focusChanged = request.data;
				}
			}
			else if (o is IFocusManagerComplexComponent)
			{
				IFocusManagerComplexComponent(o).assignFocus(shiftKey ? "bottom" : "top");
				focusChanged = true;
			}
			else if (o is IFocusManagerComponent)
			{
				setFocus(IFocusManagerComponent(o));
				focusChanged = true;
			}
				
		}
		
	}

	/**
	 *  @private
	 */
	private function setFocusToTop():void
	{
		setFocusToNextIndex(-1, false);
	}
	
	/**
	 *  @private
	 */
	private function setFocusToBottom():void
	{
		setFocusToNextIndex(focusableObjects.length, true);
	} 
	
	/**
	 *  @private
	 */
	private function setFocusToNextIndex(index:int, shiftKey:Boolean):void
	{
		if (focusableObjects.length == 0)
			return;
			
        // I think we'll have time to do this here instead of at creation time
        // this makes and orders the focusableCandidates array
        if (calculateCandidates)
        {
            sortFocusableObjects();
            calculateCandidates = false;
        }

		var focusInfo:FocusInfo = getNextFocusManagerComponent2(shiftKey, null, index);			

		// If we are about to wrap focus around, send focus back to the parent.
		if (!popup && focusInfo.wrapped)
		{
			if (getParentBridge())
			{
				moveFocusToParent(shiftKey);
				return;
			}
		}
		
		setFocusToComponent(focusInfo.displayObject, shiftKey);
	} 
	
    /**
     *  @inheritDoc
     */
    public function getNextFocusManagerComponent(
                            backward:Boolean = false):IFocusManagerComponent
	{
		return getNextFocusManagerComponent2(false, fauxFocus) as IFocusManagerComponent;
	}
	
	/**
	 * Find the next object to set focus to.
	 * 
	 * @param backward true if moving in the backwards in the tab order, false if moving forward.
	 * @param fromObject object to move focus from, if null move from the current focus.
	 * @param formIndex index to move focus from, if specified use fromIndex to find the 
	 * 		   			object, not fromObject.
	 */
	private function getNextFocusManagerComponent2(
                            backward:Boolean = false, 
                            fromObject:DisplayObject = null,
                            fromIndex:int = FROM_INDEX_UNSPECIFIED):FocusInfo
                            
    {
        if (focusableObjects.length == 0)
            return null;

        // I think we'll have time to do this here instead of at creation time
        // this makes and orders the focusableCandidates array
        if (calculateCandidates)
        {
            sortFocusableObjects();
            calculateCandidates = false;
        }

        // trace("focus was at " + o);
        // trace("focusableObjects " + focusableObjects.length);
        var i:int = fromIndex;
        if (fromIndex == FROM_INDEX_UNSPECIFIED)
        {
	        // if there is no passed in object, then get the object that has the focus
    	    var o:DisplayObject = fromObject; 
        	if (!o)
        		o = form.systemManager.stage.focus;
        
	        o = DisplayObject(findFocusManagerComponent2(InteractiveObject(o)));
	
	        var g:String = "";
	        if (o is IFocusManagerGroup)
	        {
	            var tg:IFocusManagerGroup = IFocusManagerGroup(o);
	            g = tg.groupName;
	        }
	        i = getIndexOfFocusedObject(o);
        }
        
        // trace(" starting at " + i);
        var bSearchAll:Boolean = false;
        var start:int = i;
        if (i == -1) // we didn't find it
        {
            if (backward)
                i = focusableCandidates.length;
            bSearchAll = true;
            // trace("search all " + i);
        }

        var j:int = getIndexOfNextObject(i, backward, bSearchAll, g);

        // if we wrapped around, get if we have a parent we should pass
        // focus to.
        var wrapped:Boolean = false;
        if (backward)
        {
        	if (j >= i)
        		wrapped = true;
        }
        else if (j <= i)
      		wrapped = true;

		var focusInfo:FocusInfo = new FocusInfo();
		
		focusInfo.displayObject = findFocusManagerComponent2(focusableCandidates[j]);
		focusInfo.wrapped = wrapped;
		
        return focusInfo 
    }


    /**
     *  @private
     */
    private function getTopLevelFocusTarget(o:InteractiveObject):InteractiveObject
    {
        while (o != InteractiveObject(form))
        {
            if (o is IFocusManagerComponent &&
                IFocusManagerComponent(o).focusEnabled &&
                IFocusManagerComponent(o).mouseFocusEnabled &&
                (o is IUIComponent ? IUIComponent(o).enabled : true))
                return o;

			// if we cross a boundry into a bridged application, then return null so
			// the target is only processed at the lowest level
			if (o.parent is ISWFLoader)
			{
				if (ISWFLoader(o.parent).swfBridge)
					return null; 
			}
            o = o.parent;

            if (o == null)
                break;
        }

        return null;
    }

    /**
     *  Returns a String representation of the component hosting the FocusManager object, 
     *  with the String <code>".focusManager"</code> appended to the end of the String.
     *
     *  @return Returns a String representation of the component hosting the FocusManager object, 
     *  with the String <code>".focusManager"</code> appended to the end of the String.
     */
    public function toString():String
    {
        return Object(form).toString() + ".focusManager";
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Listen for children being added
     *  and see if they are focus candidates.
     */
    private function addedHandler(event:Event):void
    {
        var target:DisplayObject = DisplayObject(event.target);
        
        // trace("FM: addedHandler: got added for " + target);
        
        // if it is truly parented, add it, otherwise it will get added when the top of the tree
        // gets parented.
        if (target.stage)
        {
            // trace("FM: addedHandler: adding focusables");
            addFocusables(DisplayObject(event.target));
        }
    }

    /**
     *  @private
     *  Listen for children being removed.
     */
    private function removedHandler(event:Event):void
    {
        var i:int;
        var o:DisplayObject = DisplayObject(event.target);

        // trace("FM got added for " + event.target);

        if (o is IFocusManagerComponent)
        {
            for (i = 0; i < focusableObjects.length; i++)
            {
                if (o == focusableObjects[i])
                {
                    if (o == _lastFocus)
                    {
                        _lastFocus.drawFocus(false);
                        _lastFocus = null;
                    }
                    // trace("FM removed " + o);
                    o.removeEventListener("tabEnabledChange", tabEnabledChangeHandler);
                    o.removeEventListener("tabIndexChange", tabIndexChangeHandler);
                    focusableObjects.splice(i, 1);
                    calculateCandidates = true;                 
                    break;
                }
            }
        }
        removeFocusables(o, false);
    }

	/**
	 * After the form is added to the stage, if there are no focusable objects,
	 * add the form and its children to the list of focuable objects because 
	 * this application may have been loaded before the
	 * top-level system manager was added to the stage.
	 */
	private function addedToStageHandler(event:Event):void
	{
		_form.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		if (focusableObjects.length == 0)
		{
			addFocusables(DisplayObject(_form));
			calculateCandidates = true;
		}
	}
	
    /**
     *  @private
     */
    private function removeFocusables(o:DisplayObject, dontRemoveTabChildrenHandler:Boolean):void
    {
        var i:int;
        if (o is DisplayObjectContainer)
        {
            if (!dontRemoveTabChildrenHandler)
                o.removeEventListener("tabChildrenChange", tabChildrenChangeHandler);

            for (i = 0; i < focusableObjects.length; i++)
            {
                if (isParent(DisplayObjectContainer(o), focusableObjects[i]))
                {
                    if (focusableObjects[i] == _lastFocus)
                    {
                        _lastFocus.drawFocus(false);
                        _lastFocus = null;
                    }
                    // trace("FM removed " + focusableObjects[i]);
                    focusableObjects[i].removeEventListener(
                        "tabEnabledChange", tabEnabledChangeHandler);
                    focusableObjects[i].removeEventListener(
                        "tabIndexChange", tabIndexChangeHandler);
                    focusableObjects.splice(i, 1);
                    i = i - 1;  // because increment would skip one
                    calculateCandidates = true;                 
                }
            }
        }
    }

    /**
     *  @private
     */
    private function showHandler(event:Event):void
    {
        form.systemManager.activate(form);
    }

    /**
     *  @private
     */
    private function hideHandler(event:Event):void
    {
        form.systemManager.deactivate(form);
    }

    /**
     *  @private
     */
    private function creationCompleteHandler(event:FlexEvent):void
    {
        if (DisplayObject(form).visible && !activated)
            form.systemManager.activate(form);
    }

    /**
     *  @private
     *  Add or remove if tabbing properties change.
     */
    private function tabIndexChangeHandler(event:Event):void
    {
        calculateCandidates = true;
    }

    /**
     *  @private
     *  Add or remove if tabbing properties change.
     */
    private function tabEnabledChangeHandler(event:Event):void
    {
        calculateCandidates = true;

        var o:InteractiveObject = InteractiveObject(event.target);
        var n:int = focusableObjects.length;
        for (var i:int = 0; i < n; i++)
        {
            if (focusableObjects[i] == o)
                break;
        }
        if (o.tabEnabled)
        {
            if (i == n && isTabVisible(o))
            {
                // trace("FM tpc added " + o);
                // add it if were not already
               	if (focusableObjects.indexOf(o) == -1)
	                focusableObjects.push(o);
            }
        }
        else
        {
            // remove it
            if (i < n)
            {
                // trace("FM tpc removed " + o);
                focusableObjects.splice(i, 1);
            }
        }
    }

    /**
     *  @private
     *  Add or remove if tabbing properties change.
     */
    private function tabChildrenChangeHandler(event:Event):void
    {
        if (event.target != event.currentTarget)
            return;

        calculateCandidates = true;

        var o:DisplayObjectContainer = DisplayObjectContainer(event.target);
        if (o.tabChildren)
        {
            addFocusables(o, true);
        }
        else
        {
            removeFocusables(o, true);
        }
    }

    /**
     *  @private
     *  This gets called when mouse clicks on a focusable object.
     *  We block player behavior
     */
    private function mouseFocusChangeHandler(event:FocusEvent):void
    {
        // trace("FocusManager: mouseFocusChangeHandler  in  = " + this._form.systemManager.loaderInfo.url);
    	// trace("FocusManager: mouseFocusChangeHandler " + event);

        // If relatedObject is null because we don't have access to the 
        // object getting focus then allow the Player to set focus
        // to the object. The isRelatedObjectInaccessible property is 
        // Player 10 only so we have to test if it is available. We
        // will only see isRelatedObjectInaccessible if we are a version "10" swf
        // (-target-player=10). Version "9" swfs will not see the property
        // even if running in Player 10.
        if (event.relatedObject == null && 
            "isRelatedObjectInaccessible" in event &&
            event["isRelatedObjectInaccessible"] == true)
        {
            // lost focus to a control in different sandbox.
            return;
        }
        
        if (event.relatedObject is TextField)
        {
            var tf:TextField = event.relatedObject as TextField;
            if (tf.type == "input" || tf.selectable)
            {
                return; // pass it on
            }
        }

        event.preventDefault();
    }

    /**
     *  @private
     *  This gets called when the tab key is hit.
     */
    private function keyFocusChangeHandler(event:FocusEvent):void
    {
        // trace("keyFocusChangeHandler handled by " + this);
    	// trace("keyFocusChangeHandler event = " + event);
    	
    	var sm:ISystemManager = form.systemManager;

		// if the target is in a bridged application, let it handle the click.
   		if (sm.isDisplayObjectInABridgedApplication(DisplayObject(event.target)))
   			return;
   			
        showFocusIndicator = true;
		focusChanged = false;
        if (event.keyCode == Keyboard.TAB && !event.isDefaultPrevented())
        {
            if (browserFocusComponent)
            {
                if (browserFocusComponent.tabIndex == LARGE_TAB_INDEX)
                    browserFocusComponent.tabIndex = -1;

                browserFocusComponent = null;
				                
				if (SystemManager(form.systemManager).useSWFBridge())
				{
					// out of children, pass focus to parent
					moveFocusToParent(event.shiftKey);
					
					if (focusChanged)
		            	event.preventDefault();
				}
				
                return;
            }

            // trace("tabHandled by " + this);
            setFocusToNextObject(event);

			if (focusChanged)
            	event.preventDefault();
        }
    }

    /**
     *  @private
     *  Watch for Enter key.
     */
    private function keyDownHandler(event:KeyboardEvent):void
    {
        // trace("onKeyDown handled by " + this);
    	// trace("onKeyDown event = " + event);
		// if the target is in a bridged application, let it handle the click.
		var sm:ISystemManager = form.systemManager;
   		if (sm.isDisplayObjectInABridgedApplication(DisplayObject(event.target)))
   			return;

        if (sm is SystemManager)
            SystemManager(sm).idleCounter = 0;

        if (event.keyCode == Keyboard.TAB)
        {
            lastAction = "KEY";

            // I think we'll have time to do this here instead of at creation time
            // this makes and orders the focusableCandidates array
            if (calculateCandidates)
            {
                sortFocusableObjects();
                calculateCandidates = false;
            }
        }

        if (browserMode)
        {
            if (event.keyCode == Keyboard.TAB && focusableCandidates.length > 0)
            {
                // get the object that has the focus
                var o:DisplayObject = fauxFocus;
				if (!o)
				{
					o = form.systemManager.stage.focus;
				}
				
                // trace("focus was at " + o);
                // trace("focusableObjects " + focusableObjects.length);
                o = DisplayObject(findFocusManagerComponent2(InteractiveObject(o)));
                var g:String = "";
                if (o is IFocusManagerGroup)
                {
                    var tg:IFocusManagerGroup = IFocusManagerGroup(o);
                    g = tg.groupName;
                }

                var i:int = getIndexOfFocusedObject(o);
                var j:int = getIndexOfNextObject(i, event.shiftKey, false, g);
                if (event.shiftKey)
                {
                    if (j >= i)
                    {
                        // we wrapped so let browser have it
                        browserFocusComponent = getBrowserFocusComponent(event.shiftKey);
                        if (browserFocusComponent.tabIndex == -1)
                            browserFocusComponent.tabIndex = 0;
                    }
                }
                else
                {
                    if (j <= i)
                    {
                        // we wrapped so let browser have it
                        browserFocusComponent = getBrowserFocusComponent(event.shiftKey);
                        if (browserFocusComponent.tabIndex == -1)
                            browserFocusComponent.tabIndex = LARGE_TAB_INDEX;
                    }
                }
            }
        }

        if (defaultButtonEnabled &&
            event.keyCode == Keyboard.ENTER &&
            defaultButton && defButton.enabled)
            //sendDefaultButtonEvent();
            defButton.callLater(sendDefaultButtonEvent);
    }

    /**
     *  @private
     *  This gets called when the focus changes due to a mouse click.
     *
     *  Note: If the focus is changing to a TextField, we don't call
     *  setFocus() on it because the player handles it;
     *  calling setFocus() on a TextField which has scrollable text
     *  causes the text to autoscroll to the end, making the
     *  mouse click set the insertion point in the wrong place.
     */
    private function mouseDownHandler(event:MouseEvent):void
    {
        // trace("FocusManager mouseDownHandler in  = " + this._form.systemManager.loaderInfo.url);
        // trace("FocusManager mouseDownHandler target " + event.target);
        
        if (event.isDefaultPrevented())
            return;

		// if the target is in a bridged application, let it handle the click.
		var sm:ISystemManager = form.systemManager;
        var o:DisplayObject = getTopLevelFocusTarget(
            InteractiveObject(event.target));

        if (!o)
            return;

        showFocusIndicator = false;
        
        // trace("FocusManager mouseDownHandler on " + o);
        
        // Make sure the containing component gets notified.
        // As the note above says, we don't set focus to a TextField ever
        // because the player already did and took care of where
        // the insertion point is, and we also don't call setfocus
        // on a component that last the last focused object unless
        // the last action was just to activate the player and didn't
        // involve tabbing or clicking on a component
        if ((o != _lastFocus || lastAction == "ACTIVATE") && !(o is TextField))
            setFocus(IFocusManagerComponent(o));
		else if (_lastFocus)
			// trace("FM: skipped setting focus to " + _lastFocus);
			 
        // if in a sandbox, create a focus-in event and dispatch.
		if (!_lastFocus && o is IEventDispatcher &&	SystemManager(form.systemManager).useSWFBridge())
       		IEventDispatcher(o).dispatchEvent(new FocusEvent(FocusEvent.FOCUS_IN));

        lastAction = "MOUSEDOWN";

		dispatchActivatedFocusManagerEvent(null);
		
		lastActiveFocusManager = this;
		
    }
    
    
	/**
	 * @private
	 * 
	 * A request across a bridge from another FocusManager to change the 
	 * focus.
	 */
    private function focusRequestMoveHandler(event:Event):void
    {
    	// trace("focusRequestHandler in  = " + this._form.systemManager.loaderInfo.url);

		// ignore messages we send to ourselves.
		if (event is SWFBridgeRequest)
		{
			// trace("ignored focus in " + this._form.systemManager.loaderInfo.url);
			return;
		}

		focusSetLocally = false;
					
    	var request:SWFBridgeRequest = SWFBridgeRequest.marshal(event);
		if (request.data == FocusRequestDirection.TOP || request.data == FocusRequestDirection.BOTTOM)
		{
			// move focus to the top or bottom child. If there are no children then
			// send focus back up to the parent.
			if (focusableObjects.length == 0)
			{
				// trace("focusRequestMoveHandler: no focusable objects, setting focus back to parent");
				moveFocusToParent(request.data == FocusRequestDirection.TOP ? false : true);
				event["data"] = focusChanged;
				return;
			}

			if (request.data == FocusRequestDirection.TOP)
			{
				setFocusToTop();	
			}
			else
			{
				setFocusToBottom();
			}

			event["data"] = focusChanged;
		}
		else
		{
			// move forward or backward
			var startingPosition:DisplayObject = DisplayObject(_form.systemManager.
										          swfBridgeGroup.getChildBridgeProvider(IEventDispatcher(event.target)));
			moveFocus(request.data as String, startingPosition);
			event["data"] = focusChanged;
	  	}
	  	
		if (focusSetLocally)
		{
            dispatchActivatedFocusManagerEvent(null);
            lastActiveFocusManager = this;
		}
    }

    private function focusRequestActivateHandler(event:Event):void
	{
		// trace("FM focusRequestActivateHandler");
		skipBridge = IEventDispatcher(event.target);
		activate();
		skipBridge = null;
	}

    private function focusRequestDeactivateHandler(event:Event):void
	{
		// trace("FM focusRequestDeactivateHandler");
        skipBridge = IEventDispatcher(event.target);
		deactivate();
        skipBridge = null;
	}

    private function bridgeEventActivateHandler(event:Event):void
	{
		// ignore message to self
		if (event is SWFBridgeEvent)
			return;
			
		//trace("FM bridgeEventActivateHandler for " + form.systemManager.loaderInfo.url);
		
		// clear last focus if we aren't active.
		lastActiveFocusManager = null;
		_lastFocus = null;

		dispatchActivatedFocusManagerEvent(IEventDispatcher(event.target));			
	}

    /**
     *  @private
     * 
     *  A request across a bridge from another FocusManager to change the 
     *  value of the setShowFocusIndicator property.
     */
    private function setShowFocusIndicatorRequestHandler(event:Event):void
    {
        // ignore messages we send to ourselves.
        if (event is SWFBridgeRequest)
            return;

        var request:SWFBridgeRequest = SWFBridgeRequest.marshal(event);
        _showFocusIndicator = request.data;
        
        // relay the message to parent and children
        dispatchSetShowFocusIndicatorRequest(_showFocusIndicator, IEventDispatcher(event.target));
    }

	/**
	 * This is called on the top-level focus manager and the parent focus
	 * manager for each new bridge of focusable content created. 
	 * When the parent focus manager of the new focusable content is
	 * called, focusable content will become part of the tab order.
	 * When the top-level focus manager is called the bridge becomes
	 * one of the focus managers managed by the top-level focus manager.
	 */	
	public function addSWFBridge(bridge:IEventDispatcher, owner:DisplayObject):void
	{
//    	trace("FocusManager.addFocusManagerBridge: in  = " + this._form.systemManager.loaderInfo.url);
        if (!owner)
            return;
            
		var sm:ISystemManager = _form.systemManager;
       	if (focusableObjects.indexOf(owner) == -1)
		{
			focusableObjects.push(owner);
    	    calculateCandidates = true;
   		}	

		// listen for move requests from the bridge.
        swfBridgeGroup.addChildBridge(bridge, ISWFBridgeProvider(owner));
        
   		bridge.addEventListener(SWFBridgeRequest.MOVE_FOCUS_REQUEST, focusRequestMoveHandler);
        bridge.addEventListener(SWFBridgeRequest.SET_SHOW_FOCUS_INDICATOR_REQUEST, 
                                setShowFocusIndicatorRequestHandler);
  		bridge.addEventListener(SWFBridgeEvent.BRIDGE_FOCUS_MANAGER_ACTIVATE, 
   				    		    bridgeEventActivateHandler);
	}
	
	/**
	 * @inheritdoc
	 */
	public function removeSWFBridge(bridge:IEventDispatcher):void
	{
		var sm:ISystemManager = _form.systemManager;
		var displayObject:DisplayObject = DisplayObject(swfBridgeGroup.getChildBridgeProvider(bridge));
		if (displayObject)
		{
			var index:int = focusableObjects.indexOf(displayObject);
           	if (index != -1)
			{
				focusableObjects.splice(index, 1);
        	    calculateCandidates = true;

   			}	

		}
	    else
	    	throw new Error();		// should never get here.

   		bridge.removeEventListener(SWFBridgeRequest.MOVE_FOCUS_REQUEST, focusRequestMoveHandler);
        bridge.removeEventListener(SWFBridgeRequest.SET_SHOW_FOCUS_INDICATOR_REQUEST, 
                                    setShowFocusIndicatorRequestHandler);
  		bridge.removeEventListener(SWFBridgeEvent.BRIDGE_FOCUS_MANAGER_ACTIVATE, 
   					    		    bridgeEventActivateHandler);
        swfBridgeGroup.removeChildBridge(bridge);		
	}
	
	/**
	 */
	private function removeFromParentBridge(event:Event):void
	{
		// add ourselves to our parent focus manager if this is a bridged 
		// application not a dialog or other popup.
		var sm:ISystemManager = form.systemManager;
		if (sm.useSWFBridge())
		{
			sm.removeEventListener(SWFBridgeEvent.BRIDGE_APPLICATION_UNLOADING, removeFromParentBridge);

			// have the child listen to move requests from the parent.
			var bridge:IEventDispatcher = swfBridgeGroup.parentBridge;
		    if (bridge)
	    	{
	       		bridge.removeEventListener(SWFBridgeRequest.MOVE_FOCUS_REQUEST, focusRequestMoveHandler);
                bridge.removeEventListener(SWFBridgeRequest.SET_SHOW_FOCUS_INDICATOR_REQUEST, 
                                           setShowFocusIndicatorRequestHandler);
	       	}
	
	   		// add listener activate/deactivate requests
	   		if (bridge && !(form.systemManager is SystemManagerProxy))
	   		{
	   			bridge.removeEventListener(SWFBridgeRequest.ACTIVATE_FOCUS_REQUEST, focusRequestActivateHandler);
	   			bridge.removeEventListener(SWFBridgeRequest.DEACTIVATE_FOCUS_REQUEST, focusRequestDeactivateHandler);
			   	bridge.removeEventListener(SWFBridgeEvent.BRIDGE_FOCUS_MANAGER_ACTIVATE, 
			   				    		bridgeEventActivateHandler);
	   		}
		}
	}
	 
	/**
	 *  @private
	 * 
	 *  Send a message to the parent to move focus a component in the parent.
	 *  
	 *  @param shiftKey - if true move focus to a component 
	 * 
	 *  @return true if focus moved to parent, false otherwise.
	 */    
    private function moveFocusToParent(shiftKey:Boolean):Boolean
    {
    	// trace("pass focus from " + this.form.systemManager.loaderInfo.url + " to parent ");
		var request:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.MOVE_FOCUS_REQUEST,
													false, true, null,
													shiftKey ? FocusRequestDirection.BACKWARD :
													  		   FocusRequestDirection.FORWARD); 
		var sandboxBridge:IEventDispatcher = _form.systemManager.swfBridgeGroup.parentBridge;
		
		// the handler will set the data property to whether focus changed
		sandboxBridge.dispatchEvent(request);
		focusChanged = request.data;
		
		return focusChanged;
    }
    
    /**
     *  Get the bridge to the parent focus manager.
     * 
     *  @return parent bridge or null if there is no parent bridge.
     */ 
    private function getParentBridge():IEventDispatcher
    {
    	if (swfBridgeGroup)
    		return swfBridgeGroup.parentBridge;
    		
		return null;		
    }


    /**
     *  @private
     *   
     *  Send a request for all other focus managers to update
     *  their ShowFocusIndicator property.
     */
    private function dispatchSetShowFocusIndicatorRequest(value:Boolean, skip:IEventDispatcher):void
    {    
        var request:SWFBridgeRequest = new SWFBridgeRequest(
                                            SWFBridgeRequest.SET_SHOW_FOCUS_INDICATOR_REQUEST,
                                            false,
                                            false,
                                            null,   // bridge is set before it is dispatched
                                            value);
        dispatchEventFromSWFBridges(request, skip);
    }
    
	/**
	 *  @private
	 * 
	 *  Broadcast an ACTIVATED_FOCUS_MANAGER message.
	 * 
	 *  @param eObj if a SandboxBridgeEvent, then propagate the message,
	 * 			   if null, start a new message.
	 */
	private function dispatchActivatedFocusManagerEvent(skip:IEventDispatcher = null):void
	{

		// Don't send the ACTIVATED_FOCUS_MANAGER message if we are already
		// active.	       	
       	if (lastActiveFocusManager == this)
       	{
       		// trace("FM: dispatchActivatedFocusManagerEvent already active, skipping messages");
       		return;		// already active
       	}
	       		
    	var event:SWFBridgeEvent = new SWFBridgeEvent(SWFBridgeEvent.BRIDGE_FOCUS_MANAGER_ACTIVATE);
        dispatchEventFromSWFBridges(event, skip);			
	}
	
	/**
     *  A Focus Manager has its own set of child bridges that may be different from the child
     *  bridges of its System Manager if the Focus Manager is managing a pop up. In the case of
     *  a pop up don't send messages to the SM parent bridge because that will be the form. But
     *  do send the messages to the bridges in bridgeFocusManagers dictionary.
     */
    private function dispatchEventFromSWFBridges(event:Event, skip:IEventDispatcher = null):void
    {


        var clone:Event;
        // trace(">>dispatchEventFromSWFBridges", this, event.type);
        var sm:ISystemManager = form.systemManager;
        
        if (!popup)
        {
            var parentBridge:IEventDispatcher = swfBridgeGroup.parentBridge;
            
            if (parentBridge && parentBridge != skip)
            {
                // Ensure the requestor property has the correct bridge.
                clone = event.clone();
                if (clone is SWFBridgeRequest)
                    SWFBridgeRequest(clone).requestor = parentBridge;
         
                parentBridge.dispatchEvent(clone);
            }
        }
        
        var children:Array = swfBridgeGroup.getChildBridges();
        for (var i:int = 0; i < children.length; i++)
        {
            if (children[i] != skip)
            {
                // trace("send to child", i, event.type);
                clone = event.clone();
    
                // Ensure the requestor property has the correct bridge.
                if (clone is SWFBridgeRequest)
                    SWFBridgeRequest(clone).requestor = IEventDispatcher(children[i]);

                IEventDispatcher(children[i]).dispatchEvent(clone);
            }
        }

        // trace("<<dispatchEventFromSWFBridges", this, event.type);
    }
	
	private function getBrowserFocusComponent(shiftKey:Boolean):InteractiveObject
	{
    	var focusComponent:InteractiveObject = form.systemManager.stage.focus;
		
		// if the focus is null it means focus is in an application we
		// don't have access to. Use either the last object or the first
		// object in this focus manager's list.
		if (!focusComponent)
		{
			var index:int = shiftKey ? 0 : focusableCandidates.length - 1;
			focusComponent = focusableCandidates[index];
		}
		
		return focusComponent;
	}	
}

}

import flash.display.DisplayObject;

/** 
 * @private
 * 
 *  Plain old class to return multiple items of info about the potential
 *  change in focus.
 */
class FocusInfo
{
	public var displayObject:DisplayObject;	// object to get focus
	public var wrapped:Boolean;				// true if focus wrapped around
}
