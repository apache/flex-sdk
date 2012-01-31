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

package spark.components.supportClasses
{
    
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;

import flashx.textLayout.events.SelectionEvent;
import flashx.textLayout.formats.LineBreak;

import mx.core.IIMESupport;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.managers.IFocusManagerComponent;

import spark.components.supportClasses.SkinnableComponent;
import spark.components.TextSelectionVisibility;
import spark.components.RichEditableText;
import spark.events.TextOperationEvent;
import spark.utils.MouseShieldUtil;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispached after the <code>selectionAnchorPosition</code> and/or
 *  <code>selectionActivePosition</code> properties have changed
 *  due to a user interaction.
 *
 *  @eventType mx.events.FlexEvent.SELECTION_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="selectionChange", type="mx.events.FlexEvent")]

/**
 *  Dispatched before a user editing operation occurs.
 *  You can alter the operation, or cancel the event
 *  to prevent the operation from being processed.
 *
 *  @eventType spark.events.TextOperationEvent.CHANGING
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="changing", type="spark.events.TextOperationEvent")]

/**
 *  Dispatched after a user editing operation is complete.
 *
 *  @eventType spark.events.TextOperationEvent.CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="change", type="spark.events.TextOperationEvent")]

include "../../styles/metadata/AdvancedTextLayoutFormatStyles.as"
include "../../styles/metadata/BasicTextLayoutFormatStyles.as"
include "../../styles/metadata/SelectionFormatTextStyles.as"

/**
 *  @copy spark.components.supportClasses.GroupBase#contentBackgroundColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes")]

/**
 *  @copy spark.components.supportClasses.GroupBase#focusColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes")]


/**
 *  Documentation is not currently available.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class TextBase extends SkinnableComponent 
    implements IFocusManagerComponent, IIMESupport
{
    include "../../core/Version.as";

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
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */    
    public function TextBase()
    {
        super();
        
        // Push this down to the textView by using the setter.
        autoSize = false;
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

    /**
     *  @private
     *  Mouse shield that is put up when this component is disabled.
     */
    private var mouseShield:DisplayObject;

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
    private var enabledChanged:Boolean = false;

    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
    {
        if (value == enabled)
            return;
        
        super.enabled = value;
        enabledChanged = true;
        
        invalidateSkinState();
        
        // We update the mouseShield that prevents clicks to propagate to
        // children in our updateDisplayList.
        invalidateDisplayList();
    }
    
    //----------------------------------
    //  baselinePosition
    //----------------------------------

    /**
     *  @private
     */
    override public function get baselinePosition():Number
    {
        return getBaselinePositionForPart(textView);
    }
    

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  autoSize
    //----------------------------------

    /**
     *  @private
     *  This must match the initial value in the textView.  autoSize will be 
     *  set to false by the constructor.
     */
    private var _autoSize:Boolean = true;

    /**
     *  @private
     */
    private var autoSizeChanged:Boolean = false;
    
    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get autoSize():Boolean
    {
        return _autoSize;
    }

    /**
     *  @private
     */
    public function set autoSize(value:Boolean):void
    {
        if (value == _autoSize)
            return;

        _autoSize = value;
        autoSizeChanged = true;

        invalidateProperties();
    }

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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    //  editable
    //----------------------------------

    /**
     *  @private
     */
    private var _editable:Boolean = true;

    /**
     *  @private
     */
    private var editableChanged:Boolean = false;

    /**
     *  Specifies whether the user is allowed to edit the text in this control.
     *
     *  @default true;
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get editable():Boolean
    {
        return _editable;
    }

    /**
     *  @private
     */
    public function set editable(value:Boolean):void
    {
        if (value == _editable)
            return;

        _editable = value;
        editableChanged = true;

        invalidateProperties();
    }

    //----------------------------------
    //  imeMode
    //----------------------------------

    /**
     *  @private
     */
    private var _imeMode:String = null;

    /**
     *  @private
     */
    private var imeModeChanged:Boolean = false;

    /**
     *  Specifies the IME (input method editor) mode.
     *  The IME enables users to enter text in Chinese, Japanese, and Korean.
     *  Flex sets the specified IME mode when the control gets the focus,
     *  and sets it back to the previous value when the control loses the focus.
     *
     *  <p>The flash.system.IMEConversionMode class defines constants for the
     *  valid values for this property.
     *  You can also specify <code>null</code> to specify no IME.</p>
     *
     *  @default null
     * 
     *  @see flash.system.IMEConversionMode
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
     public function get imeMode():String
    {
        return _imeMode;
    }

    /**
     *  @private
     */
    public function set imeMode(value:String):void
    {
        if (value == _imeMode)
            return;

        _imeMode = value;
        imeModeChanged = true;

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
     *  The maximum number of characters that the RichEditableText can contain,
     *  as entered by a user.
     *  A script can insert more text than maxChars allows;
     *  the maxChars property indicates only how much text a user can enter.
     *  If the value of this property is 0,
     *  a user can enter an unlimited amount of text. 
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    //  percentWidth
    //----------------------------------

    /**
     *  @private
     */
    private var percentWidthChanged:Boolean = false;
    
    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function get percentWidth():Number
    {
        return super.percentWidth;
    }

    //----------------------------------
    //  maxWidth
    //----------------------------------

    /**
     *  @private
     */
    private var maxWidthChanged:Boolean = false;

    /**
     *  @private
     */
    override public function set maxWidth(value:Number):void
    {
        if (value == super.maxWidth)
            return;

        super.maxWidth = value;
        maxWidthChanged = true;

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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    //  selectable
    //----------------------------------

    /**
     *  @private
     */
    private var _selectable:Boolean = true;

    /**
     *  @private
     */
    private var selectableChanged:Boolean = false;

    /**
     *  Specifies whether the text can be selected.
     *  Making the text selectable lets you copy text from the control.
     *
     *  @default true;
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectable():Boolean
    {
        return _selectable;
    }

    /**
     *  @private
     */
    public function set selectable(value:Boolean):void
    {
        if (value == _selectable)
            return;

        _selectable = value;
        selectableChanged = true;

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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectionAnchorPosition():int
    {
        return _selectionAnchorPosition;
    }

    //----------------------------------
    //  selectionVisibility
    //----------------------------------

    /**
     *  @private
     */
    private var _selectionVisibility:String =
        TextSelectionVisibility.WHEN_FOCUSED;

    /**
     *  @private
     */
    private var selectionVisibilityChanged:Boolean = false;

    /**
     *  Documentation is not currently available.
     * 
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectionVisibility():String 
    {
        return _selectionVisibility;
    }
    
    /**
     *  @private
     */
    public function set selectionVisibility(value:String):void
    {
        if (value == _selectionVisibility)
            return;
        
        _selectionVisibility = value;
        selectionVisibilityChanged = true;

        invalidateProperties();
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

    // Compiler will strip leading and trailing whitespace from text string.
    [CollapseWhiteSpace]
       
    /**
     *  The text String displayed by this component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  The RichEditableText that must be present
     *  in any skin assigned to this component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var textView:RichEditableText;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
        
    /**
     *  @private
     *  Pushes various properties down into the RichEditableText. 
     */
    override protected function commitProperties():void
    {
        super.commitProperties();

        if (autoSizeChanged)
        {
            textView.autoSize = _autoSize;
            autoSizeChanged = false;
        }

		if (displayAsPasswordChanged)
        {
            textView.displayAsPassword = _displayAsPassword;
            displayAsPasswordChanged = false;
        }

        if (enabledChanged)
        {
            textView.enabled = super.enabled;
            enabledChanged = false;
        }
        
        if (editableChanged)
        {
            textView.editable = _editable;
            editableChanged = false;
        }

        if (imeModeChanged)
        {
            textView.imeMode = _imeMode;
            imeModeChanged = false;
        }

        if (maxCharsChanged)
        {
            textView.maxChars = _maxChars;
            maxCharsChanged = false;
        }

        if (maxWidthChanged)
        {
            textView.maxWidth = super.maxWidth;
            maxWidthChanged = false;
        }

        if (percentWidthChanged)
        {
            textView.percentWidth = super.percentWidth;
            percentWidthChanged = false;
        }

        if (restrictChanged)
        {
            textView.restrict = _restrict;
            restrictChanged = false;
        }

        if (selectableChanged)
        {
            textView.selectable = _selectable;
            selectableChanged = false;
        }

        if (selectionVisibilityChanged)
        {
            textView.selectionVisibility = _selectionVisibility;
            selectionVisibilityChanged = false;
        }
        
        if (mx_internal::textChanged)
        {
            textView.text = mx_internal::_text;
            mx_internal::textChanged = false;
        }
    }
    
    override protected function updateDisplayList(width:Number, height:Number):void
    {
        super.updateDisplayList(width, height);
        mouseShield = MouseShieldUtil.updateMouseShield(this, mouseShield);
    }

    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);

        if (instance == textView)
        {
            // Start listening for various events from the RichEditableText.

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
            // Stop listening for various events from the RichEditableText.

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
	 */
	override protected function getCurrentSkinState():String
	{
        return enabled ? "normal" : "disabled";
	}

    /**
     *  @private
     *  Focus should always be on the internal RichEditableText.
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function insertText(text:String):void
    {
        if (!textView)
            return;

        // Make sure all properties are committed (i.e. pushed down to textView)
        // before doing the insert.
        validateNow();

        textView.insertText(text);
    }

    /**
     *  Documentation is not currently available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function appendText(text:String):void
    {
        if (!textView)
            return;

        // Make sure all properties are committed (i.e. pushed down to textView)
        // before doing the append.
        validateNow();

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
        // it changes the selection to the end of the text.
        if (enabled && editable)
        {
            if (selectionAnchorPosition == -1 && selectionActivePosition == -1)
            {
                setSelection(
                    mx_internal::_text.length, mx_internal::_text.length);
            }
            
            // Only editable text should have a focus ring.
            if (focusManager)
                focusManager.showFocusIndicator = true;
        }
                 
        super.focusInHandler(event);
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Called when the RichEditableText dispatches a 'selectionChange' event.
     */
    private function textView_selectionChangeHandler(event:Event):void
    {
        // Update our storage variables for the selection indices.
        _selectionAnchorPosition = textView.selectionAnchorPosition;
        _selectionActivePosition = textView.selectionActivePosition;
        
        // Redispatch the event that came from the RichEditableText.
        dispatchEvent(event);
    }

    /**
     *  Called when the RichEditableText dispatches a 'change' event
     *  after an editing operation.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function textView_changeHandler(event:TextOperationEvent):void
    {        
        // Update our storage variable for the text string.  Use the setter
        // so that the textChanged event is dispatched which will maintain
        // compatibility with the TextInput control.
        text = textView.text;
                
        // Kill any programmatic change, including binding firing, that we 
        // might be looking at.
        mx_internal::textChanged = false;

        // Redispatch the event that came from the RichEditableText.
        dispatchEvent(event);
    }

    /**
     *  @private
     *  Called when the RichEditableText dispatches a 'changing' event
     *  before an editing operation.
     */
    private function textView_changingHandler(event:TextOperationEvent):void
    {
        // Redispatch the event that came from the RichEditableText.
        var newEvent:Event = event.clone();
        dispatchEvent(newEvent);
        
        // If the event dispatched from this component is canceled,
        // cancel the one from the RichEditableText, which will prevent
        // the editing operation from being processed.
        if (newEvent.isDefaultPrevented())
            event.preventDefault();
    }

    /**
     *  @private
     *  Called when the RichEditableText dispatches an 'enter' event
     *  in response to the Enter key.
     */
    private function textView_enterHandler(event:Event):void
    {
        // Redispatch the event that came from the RichEditableText.
        dispatchEvent(event);
    }
}

}
