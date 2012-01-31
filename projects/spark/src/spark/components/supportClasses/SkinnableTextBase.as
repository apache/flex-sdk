////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.components.baseClasses
{
    
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;

import mx.components.TextView;
import mx.components.baseClasses.FxComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.TextOperationEvent;
import mx.managers.IFocusManagerComponent;

import flashx.textLayout.events.SelectionEvent;
import flashx.textLayout.formats.LineBreak;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispached after the <code>selectionAnchorPosition</code> and/or
 *  <code>selectionActivePosition</code> properties have changed
 *  due to a user interaction.
 *
 *  @eventType mx.events.FlexEvent.SELECTION_CHANGE
 */
[Event(name="selectionChange", type="mx.events.FlexEvent")]

/**
 *  Dispatched before a user editing operation occurs.
 *  You can alter the operation, or cancel the event
 *  to prevent the operation from being processed.
 *
 *  @eventType mx.events.TextOperationEvent.CHANGING
 */
[Event(name="changing", type="mx.events.TextOperationEvent")]

/**
 *  Dispatched after a user editing operation is complete.
 *
 *  @eventType mx.events.TextOperationEvent.CHANGE
 */
[Event(name="change", type="mx.events.TextOperationEvent")]

/**
 *  Documentation is not currently available.
 */
public class FxTextBase extends FxComponent implements IFocusManagerComponent
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */    
    public function FxTextBase()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  If true, pass calls to drawFocus() up to the parent.
     *  This is used when a component is part of a composite control
     *  like NumericStepper or ComboBox;
     */
    mx_internal var parentDrawsFocus:Boolean = false;

    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  enabled
    //----------------------------------

    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
    {
        if (value == enabled)
            return;
        
        super.enabled = value;
        
        invalidateSkinState();
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  displayAsPassword
    //----------------------------------

    /**
     *  @private
     */
    private var _displayAsPassword:Boolean = false;

    /**
     *  @private
     */
    private var displayAsPasswordChanged:Boolean = false;
    
    /**
     *  Documentation is not currently available.
     */
    public function get displayAsPassword():Boolean
    {
        return _displayAsPassword;
    }

    /**
     *  @private
     */
    public function set displayAsPassword(value:Boolean):void
    {
        if (value == _displayAsPassword)
            return;

        _displayAsPassword = value;
        displayAsPasswordChanged = true;

        invalidateProperties();
    }

    //----------------------------------
    //  maxChars
    //----------------------------------

    /**
     *  @private
     */
    private var _maxChars:int = 0;

    /**
     *  @private
     */
    private var maxCharsChanged:Boolean = false;

    /**
     *  The maximum number of characters that the TextView can contain,
     *  as entered by a user.
     *  A script can insert more text than maxChars allows;
     *  the maxChars property indicates only how much text a user can enter.
     *  If the value of this property is 0,
     *  a user can enter an unlimited amount of text. 
     * 
     *  @default 0
     */
    public function get maxChars():int 
    {
        return _maxChars;
    }
    
    /**
     *  @private
     */
    public function set maxChars(value:int):void
    {
        if (value == _maxChars)
            return;
        
        _maxChars = value;
        maxCharsChanged = true;

        invalidateProperties();
    }

    //----------------------------------
    //  restrict
    //----------------------------------

    /**
     *  @private
     */
    private var _restrict:String = null;

    /**
     *  @private
     */
    private var restrictChanged:Boolean = false;

    /**
     *  Documentation is not currently available.
     * 
     *  @default null
     */
    public function get restrict():String 
    {
        return _restrict;
    }
    
    /**
     *  @private
     */
    public function set restrict(value:String):void
    {
        if (value == _restrict)
            return;
        
        _restrict = value;
        restrictChanged = true;

        invalidateProperties();
    }

    //----------------------------------
    //  selectionActivePosition
    //----------------------------------

    /**
     *  @private
     */
    private var _selectionActivePosition:int = -1;

    [Bindable("selectionChange")]
    
    /**
     *  The active position of the selection.
     *  The "active" point is the end of the selection
     *  which is changed when the selection is extended.
     *  The active position may be either the start
     *  or the end of the selection. 
     *
     *  @default -1
     */
    public function get selectionActivePosition():int
    {
        return _selectionActivePosition;
    }

    //----------------------------------
    //  selectionAnchorPosition
    //----------------------------------

    /**
     *  @private
     */
    private var _selectionAnchorPosition:int = -1;

    [Bindable("selectionChange")]
    
    /**
     *  The anchor position of the selection.
     *  The "anchor" point is the stable end of the selection
     *  when the selection is extended.
     *  The anchor position may be either the start
     *  or the end of the selection.
     *
     *  @default -1
     */
    public function get selectionAnchorPosition():int
    {
        return _selectionAnchorPosition;
    }

    //----------------------------------
    //  text
    //----------------------------------

    /**
     *  @private
     */
    mx_internal var _text:String = "";

    /**
     *  @private
     */
    mx_internal var textChanged:Boolean = false;

    [Bindable("change")]
    [Bindable("textChanged")]
    
    /**
     *  The text String displayed by this component.
     */
    public function get text():String
    {
        return mx_internal::_text;
    }

    /**
     *  @private
     */
    public function set text(value:String):void
    {
        if (value == mx_internal::_text)
            return;

        mx_internal::_text = value;
        mx_internal::textChanged = true;

        invalidateProperties();
        
        dispatchEvent(new Event("textChanged"));
    }
    
    //----------------------------------
    //  textView
    //----------------------------------

    [SkinPart(required="true")]

    /**
     *  The TextView that must be present
     *  in any skin assigned to this component.
     */
    public var textView:TextView;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
        
    /**
     *  @private
     *  Pushes various properties down into the TextView. 
     */
    override protected function commitProperties():void
    {
        super.commitProperties();

		if (displayAsPasswordChanged)
        {
            textView.displayAsPassword = _displayAsPassword;
            displayAsPasswordChanged = false;
        }

        if (maxCharsChanged)
        {
            textView.maxChars = _maxChars;
            maxCharsChanged = false;
        }

        if (restrictChanged)
        {
            textView.restrict = _restrict;
            restrictChanged = false;
        }
        
        if (mx_internal::textChanged)
        {
            textView.text = mx_internal::_text;
            mx_internal::textChanged = false;
        }
    }

    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);

        if (instance == textView)
        {
            // Start listening for various events from the TextView.

            textView.addEventListener(SelectionEvent.SELECTION_CHANGE,
                                      textView_selectionChangeHandler);

            textView.addEventListener("changing",
                                      textView_changingHandler);

            textView.addEventListener("change",
                                      textView_changeHandler);
            
            textView.addEventListener(FlexEvent.ENTER,
                                      textView_enterHandler);
                                      
            // Set the initial text value
            textView.text = mx_internal::_text;
            
            // TODO: Remove this hard-coded styleName assignment
            // once all global text styles are moved to the global
            // stylesheet. This is a temporary workaround to support
            // inline text styles for Buttons and subclasses.
            textView.styleName = this;
        }
    }

    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);

        if (instance == textView)
        {
            // Stop listening for various events from the TextView.

            textView.removeEventListener(SelectionEvent.SELECTION_CHANGE,
                                         textView_selectionChangeHandler);

            textView.removeEventListener("changing",
                                         textView_changingHandler);

            textView.removeEventListener("change",
                                         textView_changeHandler);

            textView.removeEventListener(FlexEvent.ENTER,
                                         textView_enterHandler);
        }
    }
    
    /**
     *  @private
     *  Focus should always be on the internal TextView.
     */
    override public function setFocus():void
    {
        textView.setFocus();
    }

    /**
     *  @private
     */
    override protected function isOurFocus(target:DisplayObject):Boolean
    {
        return target == textView || super.isOurFocus(target);
    }

    /**
     *  @private
     *  Forward the drawFocus to the parent, if requested.
     */
    override public function drawFocus(isFocused:Boolean):void
    {
        if (mx_internal::parentDrawsFocus)
        {
            IFocusManagerComponent(parent).drawFocus(isFocused);
            return;
        }

        super.drawFocus(isFocused);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Documentation is not currently available.
     */
    public function setSelection(anchorIndex:int = 0,
                                 activeIndex:int = int.MAX_VALUE):void
    {
        if (!textView)
            return;

        textView.setSelection(anchorIndex, activeIndex);
    }

    /**
     *  Documentation is not currently available.
     */
    public function insertText(text:String):void
    {
        if (!textView)
            return;

        textView.insertText(text);
    }

    /**
     *  Documentation is not currently available.
     */
    public function appendText(text:String):void
    {
        if (!textView)
            return;

        textView.appendText(text);
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function focusInHandler(event:FocusEvent):void
    {
        // An editable TCAL Sprite has the concept of "no selection",
        // represented by (-1, -1), even when the Sprite has focus.
        // But then no insertion point blinks and you can't enter any text.
        // So if this component is in that state when it takes focus,
        // it changes the selection to (0, 0).
        if (selectionAnchorPosition == -1 && selectionActivePosition == -1)
            setSelection(int.MAX_VALUE, int.MAX_VALUE);
        
        super.focusInHandler(event);
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Called when the TextView dispatches a 'selectionChange' event.
     */
    private function textView_selectionChangeHandler(event:Event):void
    {
        // Update our storage variables for the selection indices.
        _selectionAnchorPosition = textView.selectionAnchorPosition;
        _selectionActivePosition = textView.selectionActivePosition;
        
        // Redispatch the event that came from the TextView.
        dispatchEvent(event);
    }

    /**
     *  Called when the TextView dispatches a 'change' event
     *  after an editing operation.
     */
    protected function textView_changeHandler(event:TextOperationEvent):void
    {
        // Update our storage variable for the text string.
        mx_internal::_text = textView.text;

        // Redispatch the event that came from the TextView.
        dispatchEvent(event);
    }

    /**
     *  @private
     *  Called when the TextView dispatches a 'changing' event
     *  before an editing operation.
     */
    private function textView_changingHandler(event:TextOperationEvent):void
    {
        // Redispatch the event that came from the TextView.
        var newEvent:Event = event.clone();
        dispatchEvent(newEvent);
        
        // If the event dispatched from this component is canceled,
        // cancel the one from the TextView, which will prevent
        // the editing operation from being processed.
        if (newEvent.isDefaultPrevented())
            event.preventDefault();
    }

    /**
     *  @private
     *  Called when the TextView dispatches an 'enter' event
     *  in response to the Enter key.
     */
    private function textView_enterHandler(event:Event):void
    {
        // Redispatch the event that came from the TextView.
        dispatchEvent(event);
    }
}

}
