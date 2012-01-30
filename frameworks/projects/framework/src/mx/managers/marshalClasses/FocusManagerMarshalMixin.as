////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.managers.marshalClasses
{

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.IEventDispatcher;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import mx.events.FlexEvent;
import mx.events.FocusRequestDirection;
import mx.events.SWFBridgeEvent;
import mx.events.SWFBridgeRequest;
import mx.managers.FocusManager;
import mx.managers.IMarshalSystemManager;
import mx.managers.ISystemManager;
import mx.managers.SystemManager;
import mx.managers.SystemManagerProxy;
import mx.core.IFlexModuleFactory;
import mx.core.ISWFBridgeProvider;
import mx.core.ISWFBridgeGroup;
import mx.core.ISWFLoader;
import mx.core.mx_internal;
import mx.core.SWFBridgeGroup;

use namespace mx_internal;

[ExcludeClass]

[Mixin]

/**
 *  @private
 *  MarshallingSupport for FocusManager
 */
public class FocusManagerMarshalMixin
{
    include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class Method
	//
	//--------------------------------------------------------------------------
	
	public static function init(fbs:IFlexModuleFactory):void
	{
		if (!FocusManager.mixins)
			FocusManager.mixins = [];
        if (FocusManager.mixins.indexOf(FocusManagerMarshalMixin) == -1)
		    FocusManager.mixins.push(FocusManagerMarshalMixin);
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function FocusManagerMarshalMixin(owner:FocusManager = null)
	{
		super();
        
        if (!owner)
            return;

		this.focusManager = owner;
		marshalSystemManager = 
			IMarshalSystemManager(focusManager.form.systemManager.getImplementation("mx.managers::IMarshalSystemManager"));

		focusManager.addEventListener("initialize", initializeHandler);
		focusManager.addEventListener("showFocusIndicator", showFocusIndicatorHandler);
		focusManager.addEventListener("setFocus", setFocusHandler);
		focusManager.addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
		focusManager.addEventListener("activateFM", activateHandler);
		focusManager.addEventListener("deactivateFM", deactivateHandler);
		focusManager.addEventListener("focusWrapping", focusWrappingHandler);
		focusManager.addEventListener("setFocusToComponent", setFocusToComponentHandler);
		focusManager.addEventListener("setFocusToNextIndex", focusWrappingHandler); // yes, this is the same code snippet so reuse handler
		focusManager.addEventListener("getTopLevelFocusTarget", getTopLevelFocusTargetHandler);
		focusManager.addEventListener("keyFocusChange", keyFocusChangeHandler);
		focusManager.addEventListener("browserFocusComponent", browserFocusComponentHandler);
		focusManager.addEventListener("keyDownFM", keyDownHandler);
		focusManager.addEventListener("defaultButtonKeyHandler", defaultButtonKeyHandler);
		focusManager.addEventListener("mouseDownFM", mouseDownHandler);
		focusManager.addEventListener("addChildBridge", addChildBridgeHandler);
		focusManager.addEventListener("removeChildBridge", removeChildBridgeHandler);
		focusManager.addEventListener(FlexEvent.FLEX_WINDOW_ACTIVATE, forwardWindowActivationEventsToChildrenHandler);
		focusManager.addEventListener(FlexEvent.FLEX_WINDOW_DEACTIVATE, forwardWindowActivationEventsToChildrenHandler);
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	/** 
	 * @private
	 * 
	 * Test if the focus was set locally in this focus manager (true) or
	 * if focus was transfer to another focus manager (false)
	 */
	private var focusSetLocally:Boolean;
	 
	/**
	 *  @private
	 */
	private var focusManager:FocusManager;

	/**
	 *  @private
	 */
	private var marshalSystemManager:IMarshalSystemManager;

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
	  *  @private
	  * 
	  *  Used when a the skip parameter can't be passed into 
	  *  dispatchEventFromSWFBridges() because the caller doesn't take
	  *  a skip parameter.
	  */ 
	 private var skipBridge:IEventDispatcher;

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	public function initializeHandler(event:Event):void
	{
		try
		{
            var sm:ISystemManager = focusManager.form.systemManager;

            // Set up our swfBridgeGroup. If this is a pop up then the parent 
            // bridge is empty, otherwise its the form's system manager's bridge.
            swfBridgeGroup = new SWFBridgeGroup(sm);
            if (!focusManager.popup)
                swfBridgeGroup.parentBridge = marshalSystemManager.swfBridgeGroup.parentBridge; 
            
			// add ourselves to our parent focus manager if this is a bridged 
			// application not a dialog or other popup.
			if (marshalSystemManager.useSWFBridge())
			{
			    sm.addEventListener(SWFBridgeEvent.BRIDGE_APPLICATION_UNLOADING, removeFromParentBridge);

				// have the child listen to move requests from the parent.
				var bridge:IEventDispatcher = swfBridgeGroup.parentBridge;
		       	if (bridge)
	    	   	{
	       			bridge.addEventListener(SWFBridgeRequest.MOVE_FOCUS_REQUEST, focusRequestMoveHandler);
                    bridge.addEventListener(SWFBridgeRequest.SET_SHOW_FOCUS_INDICATOR_REQUEST, 
                                            setShowFocusIndicatorRequestHandler);
            		bridge.addEventListener(SWFBridgeEvent.BRIDGE_AIR_WINDOW_ACTIVATE, windowActivationEventHandler);
            		bridge.addEventListener(SWFBridgeEvent.BRIDGE_AIR_WINDOW_DEACTIVATE, windowActivationEventHandler);
	       		}
	    
	   			// add listener activate/deactivate requests
	   			if (bridge && !(focusManager.form.systemManager is SystemManagerProxy))
	   			{
	   				bridge.addEventListener(SWFBridgeRequest.ACTIVATE_FOCUS_REQUEST, focusRequestActivateHandler);
	   				bridge.addEventListener(SWFBridgeRequest.DEACTIVATE_FOCUS_REQUEST, focusRequestDeactivateHandler);
			   		bridge.addEventListener(SWFBridgeEvent.BRIDGE_FOCUS_MANAGER_ACTIVATE, 
			   				    		    bridgeEventActivateHandler);
	   			}
	   			
	   			// listen when the container has been added to the stage so we can add the focusable
	   			// children
	   			focusManager.form.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			}
		}
		catch (e:Error)
		{
			// ignore null pointer errors caused by container using a 
			// systemManager from another sandbox.
		}

	}

	/**
	 * After the form is added to the stage, if there are no focusable objects,
	 * add the form and its children to the list of focuable objects because 
	 * this application may have been loaded before the
	 * top-level system manager was added to the stage.
	 */
	private function addedToStageHandler(event:Event):void
	{
		focusManager.form.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		if (focusManager.focusableObjects.length == 0)
		{
			focusManager.addFocusables(DisplayObject(focusManager.form));
			focusManager.calculateCandidates = true;
		}
	}
	
	private function setFocusHandler(event:Event):void
	{
        focusSetLocally = true;
	}
        
	public function showFocusIndicatorHandler(event:Event):void
	{
        if (!focusManager.popup && swfBridgeGroup)
            dispatchSetShowFocusIndicatorRequest(focusManager.showFocusIndicator, null);
	}

	public function focusInHandler(event:FocusEvent):void
	{
		// if the target is in a bridged application, let it handle the click.
   		if (marshalSystemManager.isDisplayObjectInABridgedApplication(DisplayObject(event.relatedObject)))
   			event.preventDefault();
	}

	public function activateHandler(event:Event):void
	{
		// activate children in compatibility mode or in sandboxes.
    	dispatchEventFromSWFBridges(new SWFBridgeRequest(SWFBridgeRequest.ACTIVATE_FOCUS_REQUEST), skipBridge);
	}

	public function deactivateHandler(event:Event):void
	{
		// deactivate children in compatibility mode or in sandboxes.
		dispatchEventFromSWFBridges(new SWFBridgeRequest(SWFBridgeRequest.DEACTIVATE_FOCUS_REQUEST), skipBridge);
	}

    // parameter is FocusEvent just so we don't have to define a class
    // to pass a object reference.  
	public function focusWrappingHandler(event:FocusEvent):void
	{
		if (getParentBridge())
		{
			moveFocusToParent(event.shiftKey);
			event.preventDefault();;
		}

	}

    // parameter is FocusEvent just so we don't have to define a class
    // to pass a object reference.  
	public function setFocusToComponentHandler(event:FocusEvent):void
	{
		var o:Object = event.relatedObject;

		if (o is ISWFLoader && ISWFLoader(o).swfBridge)
		{
			// send message to child swf to move focus.
			// trace("pass focus from " + this.form.systemManager.loaderInfo.url + " to " + DisplayObject(o).loaderInfo.url);
	    	var request:SWFBridgeRequest = new SWFBridgeRequest(SWFBridgeRequest.MOVE_FOCUS_REQUEST, 
	    												false, true, null,
	    												event.shiftKey ? FocusRequestDirection.BOTTOM : 
																   FocusRequestDirection.TOP);
			var sandboxBridge:IEventDispatcher = ISWFLoader(o).swfBridge;
			if (sandboxBridge)
			{
    			sandboxBridge.dispatchEvent(request);
				focusManager.focusChanged = request.data;
			}
			event.preventDefault();
		}
	}

    // parameter is FocusEvent just so we don't have to define a class
    // to pass a object reference.  
	public function getTopLevelFocusTargetHandler(event:FocusEvent):void
	{
		var o:Object = event.relatedObject;

		// if we cross a boundry into a bridged application, then return null so
		// the target is only processed at the lowest level
		if (o is ISWFLoader)
		{
			if (ISWFLoader(o).swfBridge)
		   		event.preventDefault();
		}
	}

    // parameter is FocusEvent just so we don't have to define a class
    // to pass a object reference.  
	public function keyFocusChangeHandler(event:FocusEvent):void
	{
		var o:Object = event.relatedObject;

		// if the target is in a bridged application, let it handle the click.
   		if (marshalSystemManager.isDisplayObjectInABridgedApplication(DisplayObject(o)))
   			event.preventDefault();
   			
	}

    // parameter is FocusEvent just so we don't have to define a class
    // to pass a object reference.  
	public function browserFocusComponentHandler(event:FocusEvent):void
	{
		if (marshalSystemManager.useSWFBridge())
		{
			// out of children, pass focus to parent
			moveFocusToParent(event.shiftKey);
			
			if (focusManager.focusChanged)
		        event.preventDefault();
		}
				
	}

    // parameter is FocusEvent just so we don't have to define a class
    // to pass a object reference.  
	public function keyDownHandler(event:FocusEvent):void
	{
   		if (marshalSystemManager.isDisplayObjectInABridgedApplication(DisplayObject(event.relatedObject)))
   			event.preventDefault();

	}

    // parameter is FocusEvent just so we don't have to define a class
    // to pass a object reference.  
	public function defaultButtonKeyHandler(event:FocusEvent):void
	{
		// if the target is in a bridged application, let it handle the click.
   		if (marshalSystemManager.isDisplayObjectInABridgedApplication(DisplayObject(event.relatedObject)))
   			event.preventDefault();
	}


    // parameter is FocusEvent just so we don't have to define a class
    // to pass a object reference.  
	public function mouseDownHandler(event:FocusEvent):void
	{
		var o:Object = event.relatedObject;

        // if in a sandbox, create a focus-in event and dispatch.
		if (!focusManager.lastFocus && o is IEventDispatcher &&	marshalSystemManager.useSWFBridge())
       		IEventDispatcher(o).dispatchEvent(new FocusEvent(FocusEvent.FOCUS_IN));

		dispatchActivatedFocusManagerEvent(null);
		
		lastActiveFocusManager = focusManager;
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
			if (focusManager.focusableObjects.length == 0)
			{
				// trace("focusRequestMoveHandler: no focusable objects, setting focus back to parent");
				moveFocusToParent(request.data == FocusRequestDirection.TOP ? false : true);
				event["data"] = focusManager.focusChanged;
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

			event["data"] = focusManager.focusChanged;
		}
		else
		{
			// move forward or backward
			var startingPosition:DisplayObject = 
				DisplayObject(swfBridgeGroup.getChildBridgeProvider(IEventDispatcher(event.target)));
			moveFocus(request.data as String, startingPosition);
			event["data"] = focusManager.focusChanged;
	  	}
	  	
		if (focusSetLocally)
		{
            dispatchActivatedFocusManagerEvent(null);
            lastActiveFocusManager = focusManager;
		}
    }

    private function focusRequestActivateHandler(event:Event):void
	{
		// trace("FM focusRequestActivateHandler");
		skipBridge = IEventDispatcher(event.target);
		focusManager.activate();
		skipBridge = null;
	}

    private function focusRequestDeactivateHandler(event:Event):void
	{
		// trace("FM focusRequestDeactivateHandler");
        skipBridge = IEventDispatcher(event.target);
		focusManager.deactivate();
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
		focusManager.lastFocus = null;

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
        focusManager._showFocusIndicator = request.data;
        
        // relay the message to parent and children
        dispatchSetShowFocusIndicatorRequest(focusManager.showFocusIndicator, IEventDispatcher(event.target));
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
            
		var sm:ISystemManager = focusManager.form.systemManager;
       	if (focusManager.focusableObjects.indexOf(owner) == -1)
		{
			focusManager.focusableObjects.push(owner);
    	    focusManager.calculateCandidates = true;
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
		var sm:ISystemManager = focusManager.form.systemManager;
		var displayObject:DisplayObject = DisplayObject(swfBridgeGroup.getChildBridgeProvider(bridge));
		if (displayObject)
		{
			var index:int = focusManager.focusableObjects.indexOf(displayObject);
           	if (index != -1)
			{
				focusManager.focusableObjects.splice(index, 1);
        	    focusManager.calculateCandidates = true;

   			}	

		}
	    else
	    	throw new Error();		// should never get here.

        bridge.removeEventListener(SWFBridgeEvent.BRIDGE_AIR_WINDOW_ACTIVATE, windowActivationEventHandler);
        bridge.removeEventListener(SWFBridgeEvent.BRIDGE_AIR_WINDOW_DEACTIVATE, windowActivationEventHandler);
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
		var sm:ISystemManager = focusManager.form.systemManager;
		if (marshalSystemManager.useSWFBridge())
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
	   		if (bridge && !(focusManager.form.systemManager is SystemManagerProxy))
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
		var sandboxBridge:IEventDispatcher = marshalSystemManager.swfBridgeGroup.parentBridge;
		
		// the handler will set the data property to whether focus changed
		sandboxBridge.dispatchEvent(request);
		focusManager.focusChanged = request.data;
		
		return focusManager.focusChanged;
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
       	if (lastActiveFocusManager == focusManager)
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
        var sm:ISystemManager = focusManager.form.systemManager;
        
        if (!focusManager.popup)
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

    /**
     *  Move focus from the current control
     *  to the previous or next control in the tab order.
     *  The direction of the move is specified
     *  with the <code>direction</code> argument.
     * 
     *  @param direction <code>FocusRequestDirection.FORWARD</code> moves to
     *  from the control that currently has focus to controls with a higher tab index.
     *  If more than one control has the same index, the next control
     *  in the flow of the document is visited.
     *  <code>FocusRequestDirection.BACKWARD</code> moves to controls with 
     *  a lower tab index.
     *  <code>FocusRequestDirection.TOP</code> move the focus to the control 
     *  with the lowest tab index. If more than one control has the same index,
     *  focus is moved to the first control in the flow of the document. 
     *  <code>FocusRequestDirection.BOTTOM</code> move the focus to the control 
     *  with the highest tab index. If more than one control has the same index,
     *  focus is moved to the last control in the flow of the document. 
     *
     *  @param fromDisplayObject The starting point from which focus is moved. 
     *  If an object is provided, this overrides the default behavior 
     *  where focus is moved from the object that currently has focus.
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
		focusManager.fauxFocus = fromDisplayObject;
		focusManager.keyDownHandler(keyboardEvent);
		
    	var focusEvent:FocusEvent = new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE);
    	focusEvent.keyCode = Keyboard.TAB;
    	focusEvent.shiftKey = (direction == FocusRequestDirection.FORWARD) ? false : true;
    
    	focusManager.keyFocusChangeHandler(focusEvent);
    	
		focusManager.fauxFocus = null;
	}
	
	/**
	 *  @private
	 */
	private function setFocusToTop():void
	{
		focusManager.setFocusToNextIndex(-1, false);
	}
	
	/**
	 *  @private
	 */
	private function setFocusToBottom():void
	{
		focusManager.setFocusToNextIndex(focusManager.focusableObjects.length, true);
	} 
	
	private function addChildBridgeHandler(event:Event):void
	{
		var bridge:IEventDispatcher = event["bridge"];

		addSWFBridge(bridge, event["owner"]);
	}
	
	private function removeChildBridgeHandler(event:Event):void
	{
		var bridge:IEventDispatcher = event["bridge"];

		removeSWFBridge(bridge);
	}

	private function forwardWindowActivationEventsToChildrenHandler(event:Event):void
	{
        var ourEvent:SWFBridgeEvent;

        if (event.type == FlexEvent.FLEX_WINDOW_ACTIVATE)
            ourEvent = new SWFBridgeEvent(SWFBridgeEvent.BRIDGE_AIR_WINDOW_ACTIVATE);
        else if (event.type == FlexEvent.FLEX_WINDOW_DEACTIVATE)
            ourEvent = new SWFBridgeEvent(SWFBridgeEvent.BRIDGE_AIR_WINDOW_DEACTIVATE);
        
        dispatchEventFromSWFBridges(ourEvent, swfBridgeGroup.parentBridge)
	}

	private function windowActivationEventHandler(event:Event):void
	{
        var ourEvent:FlexEvent;

        if (event.type == SWFBridgeEvent.BRIDGE_AIR_WINDOW_ACTIVATE)
            ourEvent = new FlexEvent(FlexEvent.FLEX_WINDOW_ACTIVATE);
        else if (event.type == SWFBridgeEvent.BRIDGE_AIR_WINDOW_DEACTIVATE)
            ourEvent = new FlexEvent(FlexEvent.FLEX_WINDOW_DEACTIVATE);
        
        focusManager.dispatchEvent(ourEvent);
		// restore focus if this focus manager had last focus
	    if (focusManager.lastFocus && !focusManager.browserMode)
	    	focusManager.lastFocus.setFocus();
	    focusManager.lastAction = "ACTIVATE";
	}
}

}
