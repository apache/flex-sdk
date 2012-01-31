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

package spark.components
{
import flash.display.DisplayObjectContainer;
import flash.events.Event;

import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

import spark.events.PopUpEvent;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched by the container when it's opened and ready for user interaction.
 * 
 *  This event is dispatched when the container switches from "closed" to "normal"
 *  state and the transition to that state completes.
 *
 *  @eventType spark.events.PopUpEvent.OPEN
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="open", type="spark.events.PopUpEvent")]

/**
 *  Dispatched by the container when it's closed.
 * 
 *  This event is dispatched when the container switches from "normal" to "closed"
 *  state and the transition to that state completes.
 * 
 *  <p>The event provides a mechanism to pass commit information from the container to
 *  a listener.  One typical usage scenario is building a multiple-choice dialog with a 
 *  cancel button.  When a valid option is selected, the developer closes the dialog
 *  with a call to the <code>SkinnablePopUpContainer.close()</code> method, passing
 *  <code>true</code> to the <code>commit</code> parameter and optionally passing in
 *  any relevant data.  When the <code>SkinnablePopUpContainer</code> has completed closing,
 *  it will dispatch this event.  Then, in the listener, the developer can check
 *  the <code>commit</code> parameter and perform the appropriate action.  </p>
 *
 *  @eventType spark.events.PopUpEvent.CLOSE
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="close", type="spark.events.PopUpEvent")]

//--------------------------------------
//  States
//--------------------------------------

/**
 *  Closed State
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[SkinState("closed")]

/**
 *  The SkinnablePopUpContainer class is a SkinnableContainer that also acts as a pop-up.
 *
 *  The SkinnablePopUpContainer is initially in its "closed" state and when it's opened
 *  it will add itself as a pop-up to the PopUpManager and transition to its "normal" state.
 *
 *  <p>When using SkinnablePopUpContainer the pop-up is defined in mxml as
 *  a SkinnablePopUpContainer component.  To show the component create an instance and
 *  call the <code>open()</code> method. The developers are responsible for the sizing and positioning
 *  of the component.  To close the component call the <code>close()</code>
 *  method.  If the pop-up needs to pass data back to a handler, you can add a listener for 
 *  the <code>PopUp.CLOSE</code> event and specify the data in the <code>close()</code> method.</p>
 *
 *  To define open and close animations, use a custom skin with transitions between the "closed"
 *  and "normal" states.
 *
 *  @see spark.skins.spark.SkinnablePopUpContainerSkin
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class SkinnablePopUpContainer extends SkinnableContainer
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function SkinnablePopUpContainer()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  Storage for the close event while waiting for the close transition to 
     *  complete before dispatching it.
     * 
     *  @private
     */    
    private var closeEvent:PopUpEvent;
    
    /**
     *  Track whether the container is added to the PopUpManager.
     *   
     *  @private
     */    
    private var addedToPopUpManager:Boolean = false;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  isOpen
    //----------------------------------
    
    /**
     *  Storage for the isOpen property.
     *
     *  @private
     */
    private var _isOpen:Boolean = false;
    
    [Inspectable(category="General", defaultValue="false")]

    /**
     *  True when the container is open and is currently showing as a pop-up.  
     *
     *  @see #open
     *  @see #close 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get isOpen():Boolean
    {
        return _isOpen;
    }
    
    /**
     *  Updates the isOpen flag to be reflected in the skin state
     *  without actually popping up the container through the PopUpManager.
     * 
     *  @private 
     */
    mx_internal function setIsOpen(value:Boolean):void
    {
        // NOTE: DesignView relies on this API, consult tooling before making changes.
        _isOpen = value;
        invalidateSkinState();
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Brings up the container as a pop-up and switches the state from "closed" to "normal",
     *  waits till any state transitions are finished playing and dispatches <code>FlexEvent.OPEN</code> event.
     *
     *  @param owner The owner of the container.
     *
     *  @param modal Whether the container should be modal.
     *
     *  @see #close 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function open(owner:DisplayObjectContainer, modal:Boolean = false):void
    {
        if (isOpen)
            return; 
        
        closeEvent = null; // Clear any pending close event
        this.owner = owner;
        
        // We track whether we've been added to the PopUpManager to handle the
        // scenario of state transition interrupton. For example we may be playing
        // a close transition and be interrupted with a call to open() in which
        // case we wouldn't have removed the container from the PopUpManager since
        // the close transition never reached its end.
        if (!addedToPopUpManager)
        {
            addedToPopUpManager = true;

            // This will create the skin and attach it
            PopUpManager.addPopUp(this, owner, modal);
        }

        // Change state *after* we pop up, as the skin needs to go be in the initial "closed"
        // state while being created above in order for transitions to detect state change and play. 
        _isOpen = true;
        invalidateSkinState();
        if (skin)
            skin.addEventListener(FlexEvent.STATE_CHANGE_COMPLETE, stateChangeComplete_handler);
        else
            stateChangeComplete_handler(null); // Call directly
    }
    
    /**
     *  Changes the current state to "closed", waits till any state transitions are finished playing,
     *  dispatches a <code>PopUpEvent.CLOSE</code> event and removes the container from the PopUpManager.
     *
     *  <p>The PopUpEvent provides a mechanism to pass commit information from the container to
     *  a listener.  One typical usage scenario is building a multiple-choice dialog with a 
     *  cancel button.  When a valid option is selected, the developer closes the dialog
     *  with a call to the <code>SkinnablePopUpContainer.close()</code> method, passing
     *  <code>true</code> to the <code>commit</code> parameter and optionally passing in
     *  any relevant data.  When the <code>SkinnablePopUpContainer</code> has completed closing,
     *  it will dispatch this event.  Then, in the listener, the developer can check
     *  the <code>commit</code> parameter and perform the appropriate actions.  </p>
     *
     *  @param commit The value for the <code>commit</code> property of the <code>PopUpEvent</code> event.
     *  @param data The value for the <code>data</code> property for the <code>PopUpEvent</code> event.
     *
     *  @see #open
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function close(commit:Boolean = false, data:* = undefined):void
    {
        if (!isOpen)
            return;
        
        // We will dispatch the event later, when the close transition is complete.
        closeEvent = new PopUpEvent(PopUpEvent.CLOSE, false, false, commit, data);

        // Change state
        _isOpen = false;
        invalidateSkinState();

        if (skin)
            skin.addEventListener(FlexEvent.STATE_CHANGE_COMPLETE, stateChangeComplete_handler);
        else
            stateChangeComplete_handler(null); // Call directly
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private 
     */
    override protected function getCurrentSkinState():String
    {
        // The states are:
        // "normal"
        // "disabled"
        // "closed"

        var state:String = super.getCurrentSkinState();
        if (!isOpen)
            return state == "normal" ? "closed" : state;
        return state;
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *
     *  Called when we have completed transitioning to opened/closed state.
     */
    private function stateChangeComplete_handler(event:Event):void
    {
        // We get called directly with null if there's no skin to listen to.
        if (event)
            event.target.removeEventListener(FlexEvent.STATE_CHANGE_COMPLETE, stateChangeComplete_handler);
        
        if (isOpen)
        {
            dispatchEvent(new PopUpEvent(PopUpEvent.OPEN, false, false));
        }
        else
        {
            // Dispatch the close event before removing from the PopUpManager.
            dispatchEvent(closeEvent);
            closeEvent = null;

            // We just finished closing, remove from the PopUpManager.
            PopUpManager.removePopUp(this);
            addedToPopUpManager = false;
            owner = null;
        }
    }
}
}