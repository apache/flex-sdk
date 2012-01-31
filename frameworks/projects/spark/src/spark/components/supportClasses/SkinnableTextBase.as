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
import mx.utils.BitFlagUtil;

import spark.components.supportClasses.SkinnableComponent;
import spark.components.TextSelectionVisibility;
import spark.events.TextOperationEvent;
import spark.primitives.RichEditableText;

use namespace mx_internal;

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
[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.supportClasses.GroupBase#focusColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark")]


/**
 *  The base class for skinnable components that include RichEditableText
 *  in their skin.
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
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private static const AUTO_SIZE_PROPERTY_FLAG:uint = 1 << 0;
    
    /**
     *  @private
     */
    private static const CONTENT_PROPERTY_FLAG:uint = 1 << 1;

    /**
     *  @private
     */
    private static const DISPLAY_AS_PASSWORD_PROPERTY_FLAG:uint = 1 << 2;
    
    /**
     *  @private
     */
    private static const EDITABLE_PROPERTY_FLAG:uint = 1 << 3;
        
    /**
     *  @private
     */
    private static const HEIGHT_IN_LINES_PROPERTY_FLAG:uint = 1 << 4;
    
    /**
     *  @private
     */
    private static const IME_MODE_PROPERTY_FLAG:uint = 1 << 5;
    
    /**
     *  @private
     */
    private static const MAX_CHARS_PROPERTY_FLAG:uint = 1 << 6;
       
    /**
     *  @private
     */
    private static const MAX_WIDTH_PROPERTY_FLAG:uint = 1 << 7;
    
    /**
     *  @private
     */
    private static const RESTRICT_PROPERTY_FLAG:uint = 1 << 8;

    /**
     *  @private
     */
    private static const SELECTABLE_PROPERTY_FLAG:uint = 1 << 9;

    /**
     *  @private
     */
    private static const SELECTION_VISIBILITY_PROPERTY_FLAG:uint = 1 << 10;

    /**
     *  @private
     */
    private static const TEXT_PROPERTY_FLAG:uint = 1 << 11;

    /**
     *  @private
     */
    private static const WIDTH_IN_CHARS_PROPERTY_FLAG:uint = 1 << 12;

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

    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------

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

    //--------------------------------------------------------------------------
    //
    //  Properties proxied to textView
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  autoSize
    //----------------------------------

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
        if (textView)
            return textView.autoSize;
            
        // want the default to be true
        var v:* = textViewProperties.autoSize;        
        return (v === undefined) ? true : v;
    }

    /**
     *  @private
     */
    public function set autoSize(value:Boolean):void
    {
        if (textView)
        {
            textView.autoSize = value;
            textViewProperties = BitFlagUtil.update(
                uint(textViewProperties), AUTO_SIZE_PROPERTY_FLAG, true);
        }
        else
        {
            textViewProperties.autoSize = value;
        }
            
        invalidateProperties();            
    }

    //----------------------------------
    //  displayAsPassword
    //----------------------------------
    
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
        if (textView)
            return textView.displayAsPassword;

        // want the default to be false
        var v:* = textViewProperties.displayAsPassword
        return (v === undefined) ? false : v;
    }

    /**
     *  @private
     */
    public function set displayAsPassword(value:Boolean):void
    {
        if (textView)
        {
            textView.displayAsPassword = value;
            textViewProperties = BitFlagUtil.update(
                                    uint(textViewProperties), 
                                    DISPLAY_AS_PASSWORD_PROPERTY_FLAG, true);
        }
        else
        {
            textViewProperties.displayAsPassword = value;
        }

        invalidateProperties();                    
    }

    //----------------------------------
    //  editable
    //----------------------------------

    /**
     *  Specifies whether the user is allowed to edit the text in this control.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get editable():Boolean
    {
        if (textView)
            return textView.editable;
            
        // want the default to be true
        var v:* = textViewProperties.editable;
        return (v === undefined) ? true : v;
    }

    /**
     *  @private
     */
    public function set editable(value:Boolean):void
    {
        if (textView)
        {
            textView.editable = value;
            textViewProperties = BitFlagUtil.update(
                uint(textViewProperties), EDITABLE_PROPERTY_FLAG, true);
        }
        else
        {
            textViewProperties.editable = value;
        }

        invalidateProperties();            
    }

    //----------------------------------
    //  imeMode
    //----------------------------------

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
        if (textView)        
            return textView.imeMode;
            
        // want the default to be null
        var v:* = textViewProperties.imeMode;
        return (v === undefined) ? null : v;
    }

    /**
     *  @private
     */
    public function set imeMode(value:String):void
    {
        if (textView)
        {
            textView.imeMode = value;
            textViewProperties = BitFlagUtil.update(
                uint(textViewProperties), IME_MODE_PROPERTY_FLAG, true);
        }
        else
        {
            textViewProperties.imeMode = value;
        }

        invalidateProperties();            
    }

    //----------------------------------
    //  maxChars
    //----------------------------------

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
        if (textView)
            return textView.maxChars;
            
        // want the default to be 0
        var v:* = textViewProperties.maxChars;
        return (v === undefined) ? 0 : v;
    }
    
    /**
     *  @private
     */
    public function set maxChars(value:int):void
    {
        if (textView)
        {
            textView.maxChars = value;
            textViewProperties = BitFlagUtil.update(
                uint(textViewProperties), MAX_CHARS_PROPERTY_FLAG, true);
        }
        else
        {
            textViewProperties.maxChars = value;
        }

        invalidateProperties();            
    }

    //----------------------------------
    //  maxWidth
    //----------------------------------

    /**
     *  @private
     */
    override public function get maxWidth():Number
    {
        if (textView)
            return textView.maxWidth;
            
        // want the default to be default max width for UIComponent
        var v:* = textViewProperties.maxWidth;
        return (v === undefined) ? super.maxWidth : v;        
    }

    /**
     *  @private
     */
    override public function set maxWidth(value:Number):void
    {
        if (textView)
        {
            textView.maxWidth = value;
            textViewProperties = BitFlagUtil.update(
                uint(textViewProperties), MAX_WIDTH_PROPERTY_FLAG, true);
        }
        else
        {
            textViewProperties.maxWidth = value;
        }

        invalidateProperties();            
    }

    //----------------------------------
    //  restrict
    //----------------------------------

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
        if (textView)
            return textView.restrict;
            
        // want the default to be null
        var v:* = textViewProperties.restrict;
        return (v === undefined) ? null : v;
    }
    
    /**
     *  @private
     */
    public function set restrict(value:String):void
    {
        if (textView)
        {
            textView.restrict = value;
            textViewProperties = BitFlagUtil.update(
                uint(textViewProperties), RESTRICT_PROPERTY_FLAG, true);
        }
        else
        {
            textViewProperties.restrict = value;
        }

        invalidateProperties();            
    }

    //----------------------------------
    //  selectable
    //----------------------------------

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
        if (textView)
            return textView.selectable;
            
        // want the default to be true
        var v:* = textViewProperties.selectable;
        return (v === undefined) ? true : v;
    }

    /**
     *  @private
     */
    public function set selectable(value:Boolean):void
    {
        if (textView)
        {
            textView.selectable = value;
            textViewProperties = BitFlagUtil.update(
                uint(textViewProperties), SELECTABLE_PROPERTY_FLAG, true);
        }
        else
        {
            textViewProperties.selectable = value;
        }
        
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
        if (textView)
            return textView.selectionVisibility;
            
        // want the default to be "when focused"
        var v:* = textViewProperties.selectionVisibility;
        return (v === undefined) ? TextSelectionVisibility.WHEN_FOCUSED : v;
    }
    
    /**
     *  @private
     */
    public function set selectionVisibility(value:String):void
    {
        if (textView)
        {
            textView.selectionVisibility = value;
            textViewProperties = BitFlagUtil.update(
                                    uint(textViewProperties), 
                                    SELECTION_VISIBILITY_PROPERTY_FLAG, true);
        }
        else
        {
            textViewProperties.selectionVisibility = value;
        }

        invalidateProperties();            
    }

    //----------------------------------
    //  text
    //----------------------------------

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
        if (textView)
            return textView.text;
            
        // want the default to be the empty string
        var v:* = textViewProperties.text;
        return (v === undefined) ? "" : v;
    }

    /**
     *  @private
     */
    public function set text(value:String):void
    {
        if (textView)
        {
            textView.text = value;
            textViewProperties = BitFlagUtil.update(
                uint(textViewProperties), TEXT_PROPERTY_FLAG, true);
        }
        else
        {
            textViewProperties.text = value;
        }

        invalidateProperties(); 

        // The default event to trigger a validator.
        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));                   
     }

    //----------------------------------
    //  widthInChars
    //----------------------------------
    
    /**
     *  The default width for the Text components, measured in characters.
     *  The width of the "M" character is used for the calculation.
     *  So if you set this property to 5, it will be wide enough
     *  to let the user enter 5 ems.
     *
     *  @default
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get widthInChars():Number
    {
        if (textView)
            return textView.widthInChars
            
        // want the default to be 15 characters
        var v:* = textViewProperties.widthInChars;
        return (v === undefined) ? 15 : v;
    }

    /**
     *  @private
     */
    public function set widthInChars(value:Number):void
    {
        if (textView)
        {
            textView.widthInChars = value;
            textViewProperties = BitFlagUtil.update(
                uint(textViewProperties), WIDTH_IN_CHARS_PROPERTY_FLAG, true);
        }
        else
        {
            textViewProperties.widthInChars = value;
        }

        invalidateProperties();            
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

    /**
     *  @private
     *  Several properties are proxied to textView.  However, when textView
     *  is not around, we need to store values set on TextBase.  This object 
     *  stores those values.  If textView is around, the values are stored 
     *  on the textView directly.  However, we need to know what values 
     *  have been set by the developer on TextInput/TextArea (versus set on 
     *  the textView or defaults of the textView) as those are values 
     *  we want to carry around if the textView changes (via a new skin). 
     *  In order to store this info effeciently, textViewProperties becomes 
     *  a uint to store a series of BitFlags.  These bits represent whether a 
     *  property has been explicitly set on this TextBase.  When the 
     *  textView is not around, textViewProperties is a typeless 
     *  object to store these proxied properties.  When textView is around,
     *  textViewProperties stores booleans as to whether these properties 
     *  have been explicitly set or not.
     */
    private var textViewProperties:Object = {};
   
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);

        if (instance == textView)
        {
            // TODO: Remove this hard-coded styleName assignment
            // once all global text styles are moved to the global
            // stylesheet. This is a temporary workaround to support
            // inline text styles for Buttons and subclasses.
            textView.styleName = this;
                                      
            // Copy proxied values from textViewProperties (if set) to textView.
            textViewAdded();            
            
            // Start listening for various events from the RichEditableText.

            textView.addEventListener(SelectionEvent.SELECTION_CHANGE,
                                      textView_selectionChangeHandler);

            textView.addEventListener(TextOperationEvent.CHANGING, 
                                      textView_changingHandler);

            textView.addEventListener(TextOperationEvent.CHANGE,
                                      textView_changeHandler);

            textView.addEventListener(FlexEvent.ENTER,
                                      textView_enterHandler);
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
            // Copy proxied values from textView (if explicitly set) to 
            // textViewProperties.                        
            textViewRemoved();            
            
            // Stop listening for various events from the RichEditableText.

            textView.removeEventListener(SelectionEvent.SELECTION_CHANGE,
                                         textView_selectionChangeHandler);

            textView.removeEventListener(TextOperationEvent.CHANGING,
                                         textView_changingHandler);

            textView.removeEventListener(TextOperationEvent.CHANGE,
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
        if (textView)
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
        if (parentDrawsFocus)
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

    //----------------------------------
    //  content
    //----------------------------------

    // TextArea has this, TextInput does not.
    
    /**
     *  @private
     */
    protected function getContent():Object
    {
        if (textView)
            return textView.content;
            
        // want the default to be null
        var v:* = textViewProperties.content;        
        return (v === undefined) ? null : v;
    }

    /**
     *  @private
     */
    protected function setContent(value:Object):void
    {        
        if (textView)
        {
            textView.content = value;
            textViewProperties = BitFlagUtil.update(
                uint(textViewProperties), CONTENT_PROPERTY_FLAG, true);
        }
        else
        {
            textViewProperties.content = value;
        }

        invalidateProperties();            
     }

    //----------------------------------
    //  heightInLines
    //----------------------------------

    // TextArea has this, TextInput does not.
    
    /**
     *  @private
     */
    protected function getHeightInLines():Number
    {
        if (textView)
            return textView.heightInLines;
            
        // want the default to be 10 lines
        var v:* = textViewProperties.heightInLines;        
        return (v === undefined) ? 10 : v;
    }

    /**
     *  @private
     */
    protected function setHeightInLines(value:Number):void
    {
        if (textView)
        {
            textView.heightInLines = value;
            textViewProperties = BitFlagUtil.update(
                uint(textViewProperties), HEIGHT_IN_LINES_PROPERTY_FLAG, true);
        }
        else
        {
            textViewProperties.heightInLines = value;
        }

        invalidateProperties();            
    }

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
    
    /**
     *  @private
     *  Copy values stored locally into textView now that textView has been
     *  added.
     */
    private function textViewAdded():void
    {        
        var newTextViewProperties:uint = 0;
        
        if (textViewProperties.autoSize !== undefined)
        {
            textView.autoSize = textViewProperties.autoSize;
            newTextViewProperties = BitFlagUtil.update(
                uint(newTextViewProperties), AUTO_SIZE_PROPERTY_FLAG, true);
        }

        if (textViewProperties.content !== undefined)
        {
            textView.content = textViewProperties.content;
            newTextViewProperties = BitFlagUtil.update(
                uint(newTextViewProperties), CONTENT_PROPERTY_FLAG, true);
        }
 
        if (textViewProperties.displayAsPassword !== undefined)
        {
            textView.displayAsPassword = textViewProperties.displayAsPassword
            newTextViewProperties = BitFlagUtil.update(
                uint(newTextViewProperties), 
                DISPLAY_AS_PASSWORD_PROPERTY_FLAG, true);
        }

        if (textViewProperties.editable !== undefined)
        {
            textView.editable = textViewProperties.editable;
             newTextViewProperties = BitFlagUtil.update(
                uint(newTextViewProperties), EDITABLE_PROPERTY_FLAG, true);
        }

        if (textViewProperties.heightInLines !== undefined)
        {
            textView.heightInLines = textViewProperties.heightInLines;
             newTextViewProperties = BitFlagUtil.update(
                uint(newTextViewProperties), 
                HEIGHT_IN_LINES_PROPERTY_FLAG, true);
        }

        if (textViewProperties.imeMode !== undefined)
        {
            textView.imeMode = textViewProperties.imeMode;
             newTextViewProperties = BitFlagUtil.update(
                uint(newTextViewProperties), IME_MODE_PROPERTY_FLAG, true);
        }

        if (textViewProperties.maxChars !== undefined)
        {
            textView.maxChars = textViewProperties.maxChars;
             newTextViewProperties = BitFlagUtil.update(
                uint(newTextViewProperties), MAX_CHARS_PROPERTY_FLAG, true);
        }

        if (textViewProperties.maxWidth !== undefined)
        {
            textView.maxWidth = textViewProperties.maxWidth;
             newTextViewProperties = BitFlagUtil.update(
                uint(newTextViewProperties), MAX_WIDTH_PROPERTY_FLAG, true);
        }

        if (textViewProperties.restrict !== undefined)
        {
            textView.restrict = textViewProperties.restrict;
             newTextViewProperties = BitFlagUtil.update(
                uint(newTextViewProperties), RESTRICT_PROPERTY_FLAG, true);
        }

        if (textViewProperties.selectable !== undefined)
        {
            textView.selectable = textViewProperties.selectable;
             newTextViewProperties = BitFlagUtil.update(
                uint(newTextViewProperties), SELECTABLE_PROPERTY_FLAG, true);
        }

        if (textViewProperties.selectionVisibility !== undefined)
        {
            textView.selectionVisibility = textViewProperties.selectionVisibility;
             newTextViewProperties = BitFlagUtil.update(
                uint(newTextViewProperties), 
                SELECTION_VISIBILITY_PROPERTY_FLAG, true);
        }
            
        if (textViewProperties.text != null)
        {
            textView.text = textViewProperties.text;
            newTextViewProperties = BitFlagUtil.update(
                uint(newTextViewProperties), TEXT_PROPERTY_FLAG, true);
        }

        if (textViewProperties.widthInChars !== undefined)
        {
            textView.widthInChars = textViewProperties.widthInChars;
             newTextViewProperties = BitFlagUtil.update(
                uint(newTextViewProperties), 
                WIDTH_IN_CHARS_PROPERTY_FLAG, true);
        }
            
        // Switch from storing properties to bit mask of stored properties.
         textViewProperties = newTextViewProperties;    
    }
    
    /**
     *  @private
     *  Copy values stored in textView back to local storage since textView is
     *  about to be removed.
     */
    private function textViewRemoved():void
    {        
        var newTextViewProperties:Object = {};
        
        if (BitFlagUtil.isSet(uint(textViewProperties), AUTO_SIZE_PROPERTY_FLAG))
            newTextViewProperties.autoSize = textView.autoSize;

        if (BitFlagUtil.isSet(uint(textViewProperties), CONTENT_PROPERTY_FLAG))
            newTextViewProperties.content = textView.content;
 
        if (BitFlagUtil.isSet(uint(textViewProperties), 
            DISPLAY_AS_PASSWORD_PROPERTY_FLAG))
        {
            newTextViewProperties.displayAsPassword = textView.displayAsPassword;
        }

        if (BitFlagUtil.isSet(uint(textViewProperties), EDITABLE_PROPERTY_FLAG))
            newTextViewProperties.editable = textView.editable;

        if (BitFlagUtil.isSet(uint(textViewProperties), 
            HEIGHT_IN_LINES_PROPERTY_FLAG))
        {
            newTextViewProperties.heightInLines = textView.heightInLines;
        }

        if (BitFlagUtil.isSet(uint(textViewProperties), IME_MODE_PROPERTY_FLAG))
            newTextViewProperties.imeMode = textView.imeMode;

        if (BitFlagUtil.isSet(uint(textViewProperties), 
            MAX_CHARS_PROPERTY_FLAG))
        {
            newTextViewProperties.maxChars = textView.maxChars;
        }

        if (BitFlagUtil.isSet(uint(textViewProperties), 
            MAX_WIDTH_PROPERTY_FLAG))
        {
            newTextViewProperties.maxWidth = textView.maxWidth;
        }

        if (BitFlagUtil.isSet(uint(textViewProperties), RESTRICT_PROPERTY_FLAG))
            newTextViewProperties.restrict = textView.restrict;

        if (BitFlagUtil.isSet(uint(textViewProperties), 
            SELECTABLE_PROPERTY_FLAG))
        {
            newTextViewProperties.selectable = textView.selectable;
        }

        if (BitFlagUtil.isSet(uint(textViewProperties), 
            SELECTION_VISIBILITY_PROPERTY_FLAG))
        {
            newTextViewProperties.selectionVisibility = 
                textView.selectionVisibility;
        }
            
        // Text is special.            
        if (BitFlagUtil.isSet(uint(textViewProperties), TEXT_PROPERTY_FLAG))
            newTextViewProperties.text = textView.text;

        if (BitFlagUtil.isSet(uint(textViewProperties), 
            WIDTH_IN_CHARS_PROPERTY_FLAG))
        {
            newTextViewProperties.widthInChars = textView.widthInChars;
        }
            
        // Switch from storing bit mask to storing properties.
        textViewProperties = newTextViewProperties;
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
        // Only editable text should have a focus ring.
        if (enabled && editable && focusManager)
            focusManager.showFocusIndicator = true;

        super.focusInHandler(event);
    }
    
    /**
     *  @private
     */
    override protected function focusOutHandler(event:FocusEvent):void
    {        
        super.focusOutHandler(event);

        // Trigger validation when leaving the field to test for required
        // fields and invalid values.
        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
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
        //trace(id, "textView_changeHandler", textView.text);
        
        // Redispatch the event that came from the RichEditableText.
        dispatchEvent(event);
        
        // The default event to trigger a validator.
        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
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
