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
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.SoftKeyboardEvent;
import flash.geom.Rectangle;

import mx.core.FlexGlobals;
import mx.core.FlexVersion;
import mx.core.mx_internal;
import mx.effects.IEffect;
import mx.effects.Parallel;
import mx.events.FlexEvent;
import mx.managers.ISystemManager;
import mx.managers.PopUpManager;
import mx.managers.SystemManager;
import mx.styles.StyleProtoChain;

import spark.effects.Move;
import spark.effects.Resize;
import spark.effects.easing.IEaser;
import spark.effects.easing.Power;
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
 *  <p>Note: As of Flex 4.6, SkinnablePopUp container inherits its styles
 *  from the stage and not its owner.</p>
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
//  Styles
//--------------------------------------

/**
 *  Duration of the soft keyboard move and resize effect in milliseconds.
 * 
 *  @default 150
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.1
 *  @productversion Flex 4.6
 */ 
[Style(name="softKeyboardEffectDuration", type="Number", format="Time", inherit="no", minValue="0.0")]

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
    
    /**
     *  @private
     *  Soft keyboard effect.
     */
    private var effect:IEffect;
    
    /**
     *  @private
     *  Track keyboard height to avoid unnecessary transitions.
     */
    private var cachedKeyboardHeight:Number;
    
    /**
     *  @private
     *  Original pop-up y-position.
     */
    private var cachedYPosition:Number;
    
    /**
     *  @private
     *  Original pop-up height.
     */
    private var cachedHeight:Number;

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
    
    //----------------------------------
    //  resizeForSoftKeyboard
    //----------------------------------
    
    private var _resizeForSoftKeyboard:Boolean = true;
    
    /**
     *  Enables resizing the pop-up when the soft keyboard 
     *  on a mobile device is active. 
     *  
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function get resizeForSoftKeyboard():Boolean
    {
        return _resizeForSoftKeyboard;
    }
    
    /**
     *  @private
     */
    public function set resizeForSoftKeyboard(value:Boolean):void
    {
        if (_resizeForSoftKeyboard == value)
            return;
        
        _resizeForSoftKeyboard = value;
    }
    
    //----------------------------------
    //  moveForSoftKeyboard
    //----------------------------------
    
    private var _moveForSoftKeyboard:Boolean = true;
    
    /**
     *  Enables moving the pop-up when the soft keyboard 
     *  on a mobile device is active. 
     *  
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function get moveForSoftKeyboard():Boolean
    {
        return _moveForSoftKeyboard;
    }
    
    /**
     *  @private
     */
    public function set moveForSoftKeyboard(value:Boolean):void
    {
        if (_moveForSoftKeyboard == value)
            return;
        
        _moveForSoftKeyboard = value;
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
            
            updatePopUpPosition();
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
     *  Positions the pop-up after the pop-up is added to PopUpManager but
     *  before any state transitions occur. The base implementation of open()
     *  calls updatePopUpPosition() immediately after the pop-up is added.
     * 
     *  This method may also be called at any time to update the pop-up's
     *  position. Pop-ups that are positioned relative to their owner should
     *  call this method after position or size changes occur on the owner or
     *  it's ancestors.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function updatePopUpPosition():void
    {
        // subclasses will implement custom positioning
        // e.g. PopUpManager.centerPopUp()
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
    
    /**
     *  @private
     */
    private function playEffect(yTo:Number, heightTo:Number):void
    {
        // stop the current effect
        if (effect && effect.isPlaying)
            effect.stop();
        
        var duration:Number = getStyle("softKeyboardEffectDuration");
        
        if (duration > 0)
            effect = createSoftKeyboardEffect(yTo, heightTo);
        
        if (effect)
        {
            effect.duration = duration;
            effect.play();
        }
        else
        {
            this.y = yTo;
            this.height = heightTo;
        }
    }
    
    /**
     *  Called by the soft keyboard activate and deactive event handlers, this
     *  method is responsible for creating the Spark effect played on the pop-up.
     * 
     *  This method may be overridden by subclasses. By default, it
     *  creates a parellel move and resize effect on the pop-up.
     * 
     *  @return An IEffect instance serving as the move and/or resize transition
     *  for the pop-up. This effect is played after the soft keyboard is
     *  activated or deactivated.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected function createSoftKeyboardEffect(yTo:Number, heightTo:Number):IEffect
    {
        var move:Move;
        var resize:Resize;
        var easer:IEaser = new Power(0, 5);
        
        if (yTo != this.y)
        {
            move = new Move();
            move.target = this;
            move.yTo = yTo;
            move.disableLayout = true;
            move.easer = easer;
        }
        
        if (heightTo != this.height)
        {
            resize = new Resize();
            resize.target = this;
            resize.heightTo = heightTo;
            resize.disableLayout = true;
            resize.easer = easer;
        }
        
        if (move && resize)
        {
            var parallel:Parallel = new Parallel();
            parallel.addChild(move);
            parallel.addChild(resize);
            
            return parallel;
        }
        else if (move || resize)
        {
            return (move) ? move : resize;
        }
        
        return null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  mx_internal properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  isSoftKeyboardEffectActive
    //----------------------------------
    
    private var _isSoftKeyboardEffectActive:Boolean;
    
    /**
     *  @private
     *  Returns true if the soft keyboard is active and the pop-up is moved
     *  and/or resized.
     */
    mx_internal function get isSoftKeyboardEffectActive():Boolean
    {
        return _isSoftKeyboardEffectActive;
    }
    
    //----------------------------------
    //  marginTop
    //----------------------------------
    
    private var _marginTop:Number = 0;
    
    /**
     *  @private
     *  Defines a margin at the top of the screen where the pop-up cannot be 
     *  resized or moved to.
     */
    mx_internal function get softKeyboardEffectMarginTop():Number
    {
        return _marginTop;
    }
    
    /**
     *  @private
     */
    mx_internal function set softKeyboardEffectMarginTop(value:Number):void
    {
        _marginTop = value;
    }
    
    //----------------------------------
    //  marginBottom
    //----------------------------------
    
    private var _marginBottom:Number = 0;
    
    /**
     *  @private
     *  Defines a margin at the bottom of the screen where the pop-up cannot be 
     *  resized or moved to.
     */
    mx_internal function get softKeyboardEffectMarginBottom():Number
    {
        return _marginBottom;
    }
    
    /**
     *  @private
     */
    mx_internal function set softKeyboardEffectMarginBottom(value:Number):void
    {
        _marginBottom = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Force callout inheritance chain to start at the style root.
     */
    override mx_internal function initProtoChain():void
    {
        // Maintain backwards compatibility of popup style inheritance 
        if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_6)
            super.initProtoChain();
        else
            StyleProtoChain.initProtoChain(this, false);
    }
    
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
        
        var topLevelApp:Application = FlexGlobals.topLevelApplication as Application;
        var softKeyboardEffectEnabled:Boolean = (topLevelApp && Application.softKeyboardBehavior == "none");
        
        if (isOpen)
        {
            dispatchEvent(new PopUpEvent(PopUpEvent.OPEN, false, false));
            
            if (softKeyboardEffectEnabled)
            {
                // Install soft keyboard event handling on the stage
                stage.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, softKeyboardActivatingHandler);
                stage.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, softKeyboardActivateHandler);
                stage.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, softKeyboardDeactivateHandler);
                
                // move and resize immediately if the soft keyboard is active
                if (stage.softKeyboardRect.height > 0)
                {
                    softKeyboardActivatingHandler();
                    softKeyboardActivateHandler();
                }
            }
        }
        else
        {
            // Dispatch the close event before removing from the PopUpManager.
            dispatchEvent(closeEvent);
            closeEvent = null;
            
            if (softKeyboardEffectEnabled)
            {
                // Uninstall soft keyboard event handling
                stage.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, softKeyboardActivatingHandler);
                stage.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, softKeyboardActivateHandler);
                stage.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, softKeyboardDeactivateHandler);
                
                _isSoftKeyboardEffectActive = false;
            }

            // We just finished closing, remove from the PopUpManager.
            PopUpManager.removePopUp(this);
            addedToPopUpManager = false;
            owner = null;
        }
    }
    
    /**
     *  @private
     */
    private function softKeyboardActivatingHandler(event:SoftKeyboardEvent=null):void
    {
        if (isSoftKeyboardEffectActive)
            return;
        
        // save the original y-position and height
        cachedYPosition = this.y;
        cachedHeight = this.height;
        
        // reset cached keyboard height
        cachedKeyboardHeight = 0;
    }
    
    /**
     *  @private
     */
    private function softKeyboardActivateHandler(event:SoftKeyboardEvent=null):void
    {
        var softKeyboardRect:Rectangle = this.stage.softKeyboardRect;
        
        // do not update if the keyboard has no height or if the height
        // is unchanged
        if ((softKeyboardRect.height == 0) ||
            (cachedKeyboardHeight == softKeyboardRect.height))
            return;
        
        _isSoftKeyboardEffectActive = true;
        
        cachedKeyboardHeight = softKeyboardRect.height;
        
        var systemManager:ISystemManager = this.parent as ISystemManager;
        var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
        var scaleFactor:Number = 1;
        
        if (systemManager as SystemManager)
            scaleFactor = SystemManager(systemManager).densityScale;
        
        // All calculations are done in stage coordinates and converted back to
        // application coordinates when playing effects. Also note that
        // softKeyboardRect is also in stage coordinates.
        var overlapGlobal:Number = ((this.y + this.height) * scaleFactor) - softKeyboardRect.y;
        
        var popUpY:Number = this.y * scaleFactor;
        var popUpHeight:Number = this.height * scaleFactor;
        
        var yToGlobal:Number = popUpY;
        var heightToGlobal:Number = popUpHeight;
        
        if (overlapGlobal > 0)
        {
            // shift y-position up to remove offset overlap
            if (moveForSoftKeyboard)
                yToGlobal = Math.max((softKeyboardEffectMarginTop * scaleFactor), (popUpY - overlapGlobal));
            
            // adjust height based on new y-position
            if (resizeForSoftKeyboard)
            {
                // compute new overlap
                overlapGlobal = (yToGlobal + popUpHeight) - softKeyboardRect.y;
                
                // adjust height if there is overlap
                if (overlapGlobal > 0)
                    heightToGlobal = popUpHeight - overlapGlobal - (softKeyboardEffectMarginBottom * scaleFactor);
            }
        }
        
        // only play the effect if y-position or height changes
        if ((yToGlobal != popUpY) || 
            (heightToGlobal != popUpHeight))
        {
            // convert to application coordinates, move to pixel boundaries
            var yToLocal:Number = Math.floor(yToGlobal / scaleFactor);
            var heightToLocal:Number = Math.floor(heightToGlobal / scaleFactor);
            
            // preserve minimum height
            heightToLocal = Math.max(heightToLocal, getMinBoundsHeight());
            
            playEffect(yToLocal, heightToLocal);
        }
    }
    
    /**
     *  @private
     */
    private function softKeyboardDeactivateHandler(event:SoftKeyboardEvent=null):void
    {
        if (isSoftKeyboardEffectActive)
        {
            _isSoftKeyboardEffectActive = false;
            playEffect(cachedYPosition, cachedHeight);
        }
    }
}
}