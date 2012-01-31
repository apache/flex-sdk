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
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.SoftKeyboardEvent;
import flash.events.SoftKeyboardTrigger;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import flash.utils.Timer;

import mx.core.EventPriority;
import mx.core.FlexGlobals;
import mx.core.FlexVersion;
import mx.core.mx_internal;
import mx.effects.IEffect;
import mx.effects.Parallel;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.events.SandboxMouseEvent;
import mx.managers.PopUpManager;
import mx.managers.SystemManager;
import mx.styles.StyleProtoChain;

import spark.effects.Move;
import spark.effects.Resize;
import spark.effects.animation.Animation;
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
     *  Indicates the soft keyboard deactivate event was received but the
     *  deactivate effect is delayed.
     */
    private var deactivateEffectIsPending:Boolean = false;
    
    /**
     *  @private
     *  Number of milliseconds to wait for a mouseDown and mouseUp event
     *  sequence before playing the deactivate effect.
     */
    mx_internal var deactivateEffectDelay:Number = 100;
    
    /**
     *  @private
     */
    private var deactivateTimer:Timer;
    
    /**
     *  @private
     */
    private var orientationChanging:Boolean = false;
    
    /**
     *  @private
     *  Flag for iOS specific handling of orientation change.
     */
    private var isIOS:Boolean = false;
    
    /**
     *  @private
     *  Flag when orientation change handlers are installed to suppress
     *  excess soft keyboard effects during orientation change on iOS.
     */
    private var orientationHandlerAdded:Boolean = false;
    
    /**
     *  @private
     *  Flag when mouse listeners are installed to delay the soft keyboard
     *  deactivate effect.
     */
    private var deactiveTriggersAdded:Boolean = false;
    
    /**
     *  @private
     *  Flag when explicitHeight is set when the soft keyboard effect is
     *  active. When true, we prevent the original cached height from being
     *  modified.
     */
    private var softKeyboardEffectCachedHeightExplicit:Boolean = false;
    
    /**
     *  @private
     *  Flag when explicitHeightChanged listeners are installed after 
     *  the soft keyboard activate effect is played.
     */
    private var activeListenersInstalled:Boolean;

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
     *  The popup appears over this component. The owner must not be descendant
     *  of this container.
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
     *  Called by the soft keyboard <code>activate</code> and <code>deactive</code> event handlers, 
     *  this method is responsible for creating the Spark effect played on the pop-up.
     * 
     *  This method may be overridden by subclasses. By default, it
     *  creates a parellel move and resize effect on the pop-up.
     *
     *  @param yTo The new y-coordinate of the pop-up.
     *
     *  @param height The new height of the pop-up.
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
    //  softKeyboardEffectCachedHeight
    //----------------------------------
    
    private var _softKeyboardEffectCachedHeight:Number;
    
    /**
     *  @private
     *  The original pop-up height to restore to when the soft keyboard is 
     *  deactivated. If an explicitHeight was defined at activation, use it.
     *  If not, then use explicitMaxHeight or measuredHeight.
     */
    mx_internal function get softKeyboardEffectCachedHeight():Number
    {
        var heightTo:Number = _softKeyboardEffectCachedHeight;
        
        if (!softKeyboardEffectCachedHeightExplicit)
        {
            if (!isNaN(explicitMaxHeight) && (measuredHeight > explicitMaxHeight))
                heightTo = explicitMaxHeight;
            else
                heightTo = measuredHeight;
        }
        
        return heightTo;
    }
    
    /**
     *  @private
     */
    private function setSoftKeyboardEffectCachedHeight(value:Number):void
    {
        // Only allow changes to the cached height if it was not set explicitly
        // prior to and/or during the soft keyboard effect.
        if (!softKeyboardEffectCachedHeightExplicit)
            _softKeyboardEffectCachedHeight = value;
    }
    
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
    
    //----------------------------------
    //  isMouseDown
    //----------------------------------
    
    private var _isMouseDown:Boolean = false;
    
    /**
     *  @private
     */
    private function get isMouseDown():Boolean
    {
        return _isMouseDown;
    }
    
    /**
     *  @private
     */
    private function set isMouseDown(value:Boolean):void
    {
        _isMouseDown = value;
        
        // Play the deactivate effect on the first mouseUp after a deactivate
        if (deactivateEffectIsPending)
            playDeactivateEffect(true);
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
    
    /**
     *  @private 
     */
    override public function initialize():void
    {
        super.initialize();
        
        // Determine if we are running on an iOS device
        isIOS = Capabilities.version.indexOf("IOS") == 0;
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Play the soft keyboard effect.
     */
    private function startEffect(event:Event):void
    {
        removeEventListener(Event.ENTER_FRAME, startEffect);
        
        // Abort the deactivate effect if the pop-up is closed or closing.
        // The close transition state change handler will restore the original
        // size of the pop-up.
        if (!isOpen || !effect)
            return;
        
        // Clear the cached positions when the deactivate effect is complete.
        effect.addEventListener(EffectEvent.EFFECT_END, effectCleanup);
        effect.addEventListener(EffectEvent.EFFECT_STOP, effectCleanup);
        
        // Force the master clock of the animation engine to update its
        // current time so that the overhead of creating the effect is not 
        // included in our animation interpolation. See SDK-27793
        Animation.pulse();
        effect.play();
    }
    
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
        
        // Check for soft keyboard support
        var topLevelApp:Application = FlexGlobals.topLevelApplication as Application;
        var softKeyboardEffectEnabled:Boolean = (topLevelApp && Application.softKeyboardBehavior == "none");
        var smStage:Stage = systemManager.stage;
        
        if (isOpen)
        {
            dispatchEvent(new PopUpEvent(PopUpEvent.OPEN, false, false));
            
            if (softKeyboardEffectEnabled)
            {
                // Reset state
                _isSoftKeyboardEffectActive = false;
                
                if (smStage)
                {
                    // Install soft keyboard event handling on the stage
                    smStage.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, 
                        softKeyboardActivateHandler, true, EventPriority.DEFAULT, true);
                    smStage.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, 
                        softKeyboardDeactivateHandler, true, EventPriority.DEFAULT, true);
                    
                    // move and resize immediately if the soft keyboard is active
                    if (smStage.softKeyboardRect.height > 0)
                        softKeyboardActivateHandler();
                }
            }
        }
        else
        {
            // Dispatch the close event before removing from the PopUpManager.
            dispatchEvent(closeEvent);
            closeEvent = null;
            
            if (softKeyboardEffectEnabled && smStage)
            {
                // Uninstall soft keyboard event handling
                smStage.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, 
                    softKeyboardActivateHandler, true);
                smStage.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, 
                    softKeyboardDeactivateHandler, true);
            }

            // We just finished closing, remove from the PopUpManager.
            PopUpManager.removePopUp(this);
            addedToPopUpManager = false;
            owner = null;
            
            // Reset size and position if a deactivate effect was aborted while
            // the close transition was playing. This allows the pop-up to open
            // again later without any side effects from the aborted deactivate
            // effect. See SDK-31534.
            if (!isNaN(cachedYPosition))
                this.y = cachedYPosition;
            
            // If explicit height wasn't used originally, then set height=NaN
            // so that the next call to open() will re-measure.
            if (softKeyboardEffectCachedHeightExplicit)
                this.height = softKeyboardEffectCachedHeight;
            else
                this.height = NaN;
            
            if (!isNaN(cachedYPosition) || softKeyboardEffectCachedHeightExplicit)
                effectCleanup();
        }
    }
    
    /**
     *  @private
     */
    private function softKeyboardActivateHandler(event:SoftKeyboardEvent=null):void
    {
        var isFirstActivate:Boolean = false;
        
        // Save the original y-position and height if this is the first 
        // ACTIVATE event and an existing deactivate effect is not already in
        // progress.
        if (!isSoftKeyboardEffectActive && !effect)
        {
            cachedYPosition = this.y;
            setSoftKeyboardEffectCachedHeight(this.height);
            
            // Initialize softKeyboardEffectCachedHeightExplicit
            explicitHeightChangedHandler();
            
            // reset cached keyboard height
            cachedKeyboardHeight = 0;
            
            isFirstActivate = true;
        }
        
        var smStage:Stage = systemManager.stage;
        var softKeyboardRect:Rectangle = smStage.softKeyboardRect;
        
        // Do not update if the keyboard has no height or if the height
        // is unchanged
        if ((softKeyboardRect.height == 0) ||
            (cachedKeyboardHeight == softKeyboardRect.height))
            return;
        
        cachedKeyboardHeight = softKeyboardRect.height;
        
        var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
        var scaleFactor:Number = 1;
        
        if (systemManager as SystemManager)
            scaleFactor = SystemManager(systemManager).densityScale;
        
        // All calculations are done in stage coordinates and converted back to
        // application coordinates when playing effects. Also note that
        // softKeyboardRect is also in stage coordinates.
        var popUpY:Number = this.y * scaleFactor;
        var popUpHeight:Number = softKeyboardEffectCachedHeight * scaleFactor;
        var overlapGlobal:Number = (popUpY + popUpHeight) - softKeyboardRect.y;
        
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
            // update state
            _isSoftKeyboardEffectActive = true;
            
            // convert to application coordinates, move to pixel boundaries
            var yToLocal:Number = Math.floor(yToGlobal / scaleFactor);
            var heightToLocal:Number = Math.floor(heightToGlobal / scaleFactor);
            
            // preserve minimum height
            heightToLocal = Math.max(heightToLocal, getMinBoundsHeight());
            
            if (!deactiveTriggersAdded)
            {
                // Listen for mouseDown event on the pop-up and delay the soft 
                // keyboard deactivate effect. This allows button click events
                // to complete normally before the button is re-positioned. 
                // See SDK-31534.
                addEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
                
                // Listen for mouseUp events anywhere to play the deactivate effect.
                // See SDK-31534.
                sandboxRoot.addEventListener(MouseEvent.MOUSE_UP, 
                    mouseHandler, true /* useCapture */);
                sandboxRoot.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, 
                    systemManager_mouseUpHandler);
                
                deactiveTriggersAdded = true;
            }
            
            // Listen for orientationChanging and orientationChange to suspend
            // soft keyboard effects until the change is complete. On iOS, an
            // the keyboard is deactivated after orientationChanging, then
            // immediately activated after orientationChange is complete.
            if (isIOS && systemManager.isTopLevelRoot())
            {
                orientationHandlerAdded = true;
                orientationChanging = false;
                
                smStage.addEventListener("orientationChanging", stage_orientationHandler);
                smStage.addEventListener("orientationChange", stage_orientationHandler);
            }

            // Disable the effect and instead snap the pop-up position when 
            // the keyboard size changes after the first activation. This 
            // allows the StageText instance to stay active instead of being
            // hidden by a bitmap proxy. This solves an issue on Android
            // where a keyboard size change causes a pop-up resize, then the
            // resize effect and subsequent bitmap proxy cause the keyboard
            // size to revert, effectively killing auto correction.
            // See SDK-31834.
            prepareEffect(yToLocal, heightToLocal, !isFirstActivate);
        }
    }
    
    /**
     *  @private
     */
    private function stage_orientationHandler(event:Event):void
    {
        orientationChanging = (event.type == "orientationChanging");
    }
    /**
     *  @private
     *  Listens for mouse events while the soft keyboard effect is active.
     */
    private function mouseHandler(event:MouseEvent):void
    {
        isMouseDown = (event.type == MouseEvent.MOUSE_DOWN);
    }
    
    private function systemManager_mouseUpHandler(event:Event):void
    {
        isMouseDown = false;
    }
    
    /**
     *  @private
     */
    private function softKeyboardDeactivateHandler(event:SoftKeyboardEvent=null):void
    {
        // If the pop-up didn't move, do nothing. If we're in the middle of an
        // orientation change, also do nothing.
        if (!isSoftKeyboardEffectActive || orientationChanging)
            return;
        
        // Reset state
        deactivateEffectIsPending = false;
        
        if (event.triggerType == SoftKeyboardTrigger.USER_TRIGGERED)
        {
            // userTriggered indicates they keyboard was closed explicitly (soft
            // button on soft keyboard) or on Android, pressing the back button.
            // Play the deactivate effect immediately.
            playDeactivateEffect(false);
        }
        else // if (event.triggerType == SoftKeyboardTrigger.CONTENT_TRIGGERED)
        {
            // contentTriggered indicates focus was lost by tapping away from
            // StageText or a programmatic call. Unfortunately, this 
            // distinction isn't entirely intuitive. We only care about delaying
            // the deactivate effect when due to a mouse event. Delaying the 
            // effect allows the pop-up position and size to stay static until
            // any mouse interaction is complete (e.g. button click).
            // However, the softKeyboardDeactivate event is fired before 
            // the mouseDown event:
            //   deactivate -> mouseDown -> mouseUp
            
            // The approach here is to assume that a mouseDown was the trigger
            // for the softKeyboardDeactivate event. Continue to delay the
            // deactivate effect until a mouseDown and mouseUp sequence is 
            // received. In the event that the deactivation was due to a 
            // programmatic call, we'll stop this process after a specified
            // delay time.
            
            // If, in the future, the event order changes to either:
            //   (a) mouseDown -> deactivate -> mouseUp
            //   (b) mouseDown -> mouseUp -> deactivate
            // this approach will still work for the button click use case.
            // Sequence (b) would simply fire a normal button click and have
            // the consequence of a delayed deactivate effect only.
            deactivateEffectIsPending = true;
            
            // If mouseDown immediately precedes deactivate, don't create timer.
            // Need to wait indefinitely for mouseUp instead of using a timer.
            // Use the timer only when mouseDown has not occured yet
            if (!isMouseDown)
            {
                deactivateTimer = new Timer(deactivateEffectDelay, 1);
                deactivateTimer.addEventListener(TimerEvent.TIMER_COMPLETE, deactivateTimer_timerCompleteHandler);
                deactivateTimer.start();
            }
        }
    }
    
    /**
     *  @private
     */
    private function deactivateTimer_timerCompleteHandler(event:Event):void
    {
        // Timer completed and no mouseDown and mouseUp sequence was fired
        playDeactivateEffect(false);
    }
    
    /**
     *  @private
     *  Plays the deactivate effect to restore the original y-position and
     *  height. This is called directly by the deactivate handler when the
     *  keyboard is dismissed by hardware or explicitly by a soft keyboard 
     *  dismiss button. Otherwise, this effect is either delayed by a timer
     *  or is awaiting a mouseDown and mouseUp event sequence.
     */
    private function playDeactivateEffect(isMouseEvent:Boolean):void
    {
        var isTimerRunning:Boolean = deactivateTimer && deactivateTimer.running;
        
        // Received a mouseDown event while the timer is still running. Stop
        // the timer and wait for the next mouseUp.
        var mouseDownDuringTimer:Boolean = isTimerRunning && 
            (isMouseEvent && isMouseDown);
        
        // Cleanup the timer if we're (a) waiting for the next mouseUp or if 
        // (b) this function was called for a non-mouse event
        if (deactivateTimer && (mouseDownDuringTimer || !isMouseEvent))
        {
            deactivateTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, deactivateTimer_timerCompleteHandler);
            deactivateTimer.stop();
            deactivateTimer = null;
        }
        
        // Play the deactivate effect when (a) not triggered by a mouse event
        // or (b) triggered by a mouseUp event
        if (!isMouseEvent || (isMouseEvent && !isMouseDown))
        {
            // Uninstall mouse event handling and play the deactivate effect
            _isSoftKeyboardEffectActive = false;
            deactivateEffectIsPending = false;
            
            if (deactiveTriggersAdded)
            {
                removeEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
                
                var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
                sandboxRoot.removeEventListener(MouseEvent.MOUSE_UP, mouseHandler, true /* useCapture */);
                sandboxRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemManager_mouseUpHandler);
                
                deactiveTriggersAdded = false;
            }
            
            // Uninstall orientation change handling
            if (orientationHandlerAdded)
            {
                var smStage:Stage = systemManager.stage;
                smStage.removeEventListener("orientationChange", stage_orientationHandler);
                smStage.removeEventListener("orientationChanging", stage_orientationHandler);
                
                orientationHandlerAdded = false;
            }
            
            prepareEffect(cachedYPosition, softKeyboardEffectCachedHeight);
        }
    }
    
    /**
     *  @private
     */
    private function effectCleanup(event:EffectEvent=null):void
    {
        // Remove event listeners if we're listening to the deactivate effect
        if (event)
        {
            event.target.removeEventListener(EffectEvent.EFFECT_END, effectCleanup);
            event.target.removeEventListener(EffectEvent.EFFECT_STOP, effectCleanup);
        }
        
        // Cleanup effect
        effect = null;
        
        // Only clear the cached positions if the effect completed normally or
        // if this was called directly from the close state transtion completion.
        // The deactivate effect may stop preemtively if the keyboard is 
        // activated again while the deactivate effect is playing. In that case,
        // we want to save the cached positions from the first activation.
        var deactivateComplete:Boolean = 
            (!isSoftKeyboardEffectActive && (event && (event.type == EffectEvent.EFFECT_END)));
        
        if (!event || deactivateComplete)
        {
            // Resize and move is complete, but the resize effect modifies
            // explicitHeight. If the original height was not explicit, then 
            // restore it to NaN. This will cause 
            if (!softKeyboardEffectCachedHeightExplicit)
                this.height = NaN;
            
            cachedYPosition = NaN;
            softKeyboardEffectCachedHeightExplicit = false;
            setSoftKeyboardEffectCachedHeight(NaN);
            cachedKeyboardHeight = 0;
        }
        else if (event && isSoftKeyboardEffectActive)
        {
            // Flag changes to explicitHeight after the open effect has completed.
            // Stop listening for changes on deactivate before the effect starts.
            // See prepareEffect().
            installActiveListeners();
        }
    }
    
    /**
     *  @private
     */
    private function explicitHeightChangedHandler(event:Event=null):void
    {
        softKeyboardEffectCachedHeightExplicit = !isNaN(explicitHeight);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function prepareEffect(yTo:Number, heightTo:Number, snapPosition:Boolean=false):void
    {
        // stop the current effect
        if (effect && effect.isPlaying)
            effect.stop();
        
        var duration:Number = getStyle("softKeyboardEffectDuration");
        
        if ((duration > 0) && !snapPosition)
            effect = createSoftKeyboardEffect(yTo, heightTo);
        
        // Stop looking for explicitHeight changes. The Resize effect or
        // or explicit resize will modify explicitHeight.
        uninstallActiveListeners();
        
        if (effect)
        {
            effect.duration = duration;
            
            // Wait a frame so that any queued work can be completed by the framework
            // and runtime before the effect starts.
            addEventListener(Event.ENTER_FRAME, startEffect);
        }
        // Do not restore the callout size if the pop-up is closed or closing.
        else if (isOpen)
        {
            // No effect, set size and position explicitly
            this.y = yTo;
            this.height = heightTo;
            
            // Validate so that other listeners like Scroller get the updated dimensions
            validateNow();
            
            if (isSoftKeyboardEffectActive)
            {
                // Once the height is changed, begin looking for changes to 
                // explicitHeight that are not due to soft keyboard effects.
                installActiveListeners();
            }
            else
            {
                // Cleanup cached size and position
                effectCleanup();
            }
        }
    }
    
    /**
     *  @private
     *  Listeners installed during the phase after the initial activate effect
     *  is complete and before the deactive effect starts.
     */
    private function installActiveListeners():void
    {
        if (!activeListenersInstalled)
        {
            // Check for explicitHeight changes while the soft keyboard
            // effect is active (but not playing)
            addEventListener("explicitHeightChanged", explicitHeightChangedHandler);
            activeListenersInstalled = true;
        }
    }
    
    /**
     *  @private
     */
    private function uninstallActiveListeners():void
    {
        if (activeListenersInstalled)
        {
            removeEventListener("explicitHeightChanged", explicitHeightChangedHandler);
            activeListenersInstalled = false;
        }
    }
}
}