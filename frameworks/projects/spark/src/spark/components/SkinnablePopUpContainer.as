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
 *  <p>This event is dispatched when the container switches from the 
 *  <code>closed</code> to <code>normal</code> skin state and the transition 
 *  to that state completes.</p>
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
 *  <p>This event is dispatched when the container switches from the 
 *  <code>normal</code> to <code>closed</code> skin state and 
 *  the transition to that state completes.</p>
 * 
 *  <p>The event provides a mechanism to pass commit information from 
 *  the container to an event listener.  
 *  One typical usage scenario is building a multiple-choice dialog with a 
 *  cancel button.  
 *  When a valid option is selected, you close the pop up 
 *  with a call to the <code>close()</code> method, passing
 *  <code>true</code> to the <code>commit</code> parameter and optionally passing in
 *  any relevant data.  
 *  When the SkinnablePopUpContainer has completed closing,
 *  it dispatches this event.  
 *  Then, in the event listener, you can check the <code>commit</code> 
 *  property and perform the appropriate action.  </p>
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
 *  The closed state.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[SkinState("closed")]

/**
 *  The SkinnablePopUpContainer class is a SkinnableContainer that functions as a pop-up.
 *  One typical use for a SkinnablePopUpContainer container is to open a simple window 
 *  in an application, such as an alert window, to indicate that the user must perform some action.
 *
 *  <p>You do not create a SkinnablePopUpContainer container as part of the normal layout 
 *  of its parent container. 
 *  Instead, it appears as a pop-up window on top of its parent. 
 *  Therefore, you do not create it directly in the MXML code of your application.</p>
 *
 *  <p>Instead, you create is as an MXML component, often in a separate MXML file. 
 *  To show the component create an instance of the MXML component, and
 *  then call the <code>open()</code> method. 
 *  You can also set the size and position of the component when you open it.</p>  
 *
 *  <p>To close the component, call the <code>close()</code> method.  
 *  If the pop-up needs to return data to a handler, you can add an event listener for 
 *  the <code>PopUp.CLOSE</code> event, and specify the returned data in 
 *  the <code>close()</code> method.</p>
 *
 *  <p>The SkinnablePopUpContainer is initially in its <code>closed</code> skin state. 
 *  When it opens, it adds itself as a pop-up to the PopUpManager, 
 *  and transition to the <code>normal</code> skin state.
 *  To define open and close animations, use a custom skin with transitions between 
 *  the <code>closed</code> and <code>normal</code> skin states.</p>
 * 
 *  <p>The SkinnablePopUpContainer container has the following default characteristics:</p>
 *     <table class="innertable">
 *     <tr><th>Characteristic</th><th>Description</th></tr>
 *     <tr><td>Default size</td><td>Large enough to display its children</td></tr>
 *     <tr><td>Minimum size</td><td>0 pixels</td></tr>
 *     <tr><td>Maximum size</td><td>10000 pixels wide and 10000 pixels high</td></tr>
 *     <tr><td>Default skin class</td><td>spark.skins.spark.SkinnablePopUpContainerSkin</td></tr>
 *     </table>
 *
 *  @mxml <p>The <code>&lt;s:SkinnablePopUpContainer&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:SkinnablePopUpContainer 
 *    <strong>Events</strong>
 *    close="<i>No default</i>"
 *    open="<i>No default</i>"
 *  /&gt;
 *  </pre>
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
     *  Contains <code>true</code> when the container is open and is currently showing as a pop-up.  
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
     *  Opens the container as a pop-up, and switches the skin state from 
     *  <code>closed</code> to <code>normal</code>.
     *  After and transitions finish playing, it dispatches  the 
     *  <code>FlexEvent.OPEN</code> event.
     *
     *  @param owner The owner of the container. 
     *  The popup appears over this container.
     *
     *  @param modal Whether the container should be modal.
     *  A modal container takes all keyboard and mouse input until it is closed.
     *  A nonmodal container allows other components to accept input while the pop-up window is open.
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
     *  Changes the current skin state to <code>closed</code>, waits until any state transitions 
     *  finish playing, dispatches a <code>PopUpEvent.CLOSE</code> event, 
     *  and then removes the container from the PopUpManager.
     *
     *  <p>Use the <code>close()</code> method of the SkinnablePopUpContainer container 
     *  to pass data back to the main application from the pop up. 
     *  One typical usage scenario is building a dialog with a cancel button.  
     *  When a valid option is selected in the dialog box, you close the dialog
     *  with a call to the <code>close()</code> method, passing
     *  <code>true</code> to the <code>commit</code> parameter and optionally passing 
     *  any relevant data.  
     *  When the SkinnablePopUpContainer has completed closing,
     *  it dispatch the <code>close</code> event.  
     *  In the event listener for the <code>close</code> event, you can check
     *  the <code>commit</code> parameter and perform the appropriate actions.  </p>
     *
     *  @param commit Specifies if the return data should be committed by the application. 
     *  The value of this argument is written to the <code>commit</code> property of 
     *  the <code>PopUpEvent</code> event object.
     * 
     *  @param data Specifies any data returned to the application. 
     *  The value of this argument is written to the <code>data</code> property of 
     *  the <code>PopUpEvent</code> event object.
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