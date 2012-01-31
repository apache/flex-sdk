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

import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.SelectionEvent;

import mx.core.IIMESupport;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.managers.IFocusManagerComponent;
import mx.utils.BitFlagUtil;

import spark.components.TextSelectionHighlighting;
import spark.events.TextOperationEvent;
import spark.components.RichEditableText;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

include "../../styles/metadata/BasicNonInheritingTextStyles.as"
include "../../styles/metadata/BasicInheritingTextStyles.as"
include "../../styles/metadata/AdvancedInheritingTextStyles.as"
include "../../styles/metadata/SelectionFormatTextStyles.as"

/**
 *  The alpha of the border for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderAlpha", type="Number", inherit="no", theme="spark")]

/**
 *  The color of the border for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderColor", type="uint", format="Color", inherit="no", theme="spark")]

/**
 *  Controls the visibility of the border for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderVisible", type="Boolean", inherit="no", theme="spark")]

/**
 *  The alpha of the content background for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="contentBackgroundAlpha", type="Number", inherit="yes", theme="spark")]

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
 *  The alpha of the focus ring for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="focusAlpha", type="Number", inherit="no", theme="spark")]

/**
 *  @copy spark.components.supportClasses.GroupBase#focusColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark")]

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispached after the <code>selectionAnchorPosition</code> and/or
 *  <code>selectionActivePosition</code> properties have changed
 *  for any reason.
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

//--------------------------------------
//  Other metadata
//--------------------------------------

[AccessibilityClass(implementation="spark.accessibility.SkinnableTextBaseAccImpl")]

/**
 *  The base class for skinnable components, such as the Spark TextInput
 *  and TextArea, that include an instance of RichEditableText in their skin
 *  to provide rich text display, scrolling, selection, and editing.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class SkinnableTextBase extends SkinnableComponent 
    implements IFocusManagerComponent, IIMESupport
{
    include "../../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class mixins
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Placeholder for mixin by ListBaseAccImpl.
     */
    mx_internal static var createAccessibilityImplementation:Function;

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private static const CONTENT_PROPERTY_FLAG:uint = 1 << 0;

    /**
     *  @private
     */
    private static const DISPLAY_AS_PASSWORD_PROPERTY_FLAG:uint = 1 << 1;
    
    /**
     *  @private
     */
    private static const EDITABLE_PROPERTY_FLAG:uint = 1 << 2;
        
    /**
     *  @private
     */
    private static const HEIGHT_IN_LINES_PROPERTY_FLAG:uint = 1 << 3;
    
    /**
     *  @private
     */
    private static const IME_MODE_PROPERTY_FLAG:uint = 1 << 4;
    
    /**
     *  @private
     */
    private static const MAX_CHARS_PROPERTY_FLAG:uint = 1 << 5;
       
    /**
     *  @private
     */
    private static const MAX_WIDTH_PROPERTY_FLAG:uint = 1 << 6;
    
    /**
     *  @private
     */
    private static const RESTRICT_PROPERTY_FLAG:uint = 1 << 7;

    /**
     *  @private
     */
    private static const SELECTABLE_PROPERTY_FLAG:uint = 1 << 8;

    /**
     *  @private
     */
    private static const SELECTION_HIGHLIGHTING_FLAG:uint = 1 << 9;

    /**
     *  @private
     */
    private static const TEXT_PROPERTY_FLAG:uint = 1 << 10;

    /**
     *  @private
     */
    private static const TEXT_FLOW_PROPERTY_FLAG:uint = 1 << 11;

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
    public function SkinnableTextBase()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Skin parts
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  textDisplay
    //----------------------------------

    [SkinPart(required="false")]

    /**
     *  The RichEditableText that may be present
     *  in any skin assigned to this component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var textDisplay:RichEditableText;

    /**
     *  @private
     *  Several properties are proxied to textDisplay.  However, when 
     *  textDisplay is not around, we need to store values set on 
     *  SkinnableTextBase.  This object stores those values.  If textDisplay is 
     *  around, the values are  stored  on the textDisplay directly.  However, 
     *  we need to know what values have been set by the developer on 
     *  TextInput/TextArea (versus set on the textDisplay or defaults of the 
     *  textDisplay) as those are values we want to carry around if the 
     *  textDisplay changes (via a new skin). In order to store this info 
     *  efficiently, textDisplayProperties becomes a uint to store a series of 
     *  BitFlags.  These bits represent whether a property has been explicitly 
     *  set on this SkinnableTextBase.  When the  textDisplay is not around, 
     *  textDisplayProperties is a typeless object to store these proxied 
     *  properties.  When textDisplay is around, textDisplayProperties stores 
     *  booleans as to whether these properties have been explicitly set or not.
     */
    private var textDisplayProperties:Object = {};
   
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
        return getBaselinePositionForPart(textDisplay);
    }
    
    //----------------------------------
    //  maxWidth
    //----------------------------------

    /**
     *  @private
     */
    override public function get maxWidth():Number
    {
        if (textDisplay)
            return textDisplay.maxWidth;
            
        // want the default to be default max width for UIComponent
        var v:* = textDisplayProperties.maxWidth;
        return (v === undefined) ? super.maxWidth : v;        
    }

    /**
     *  @private
     */
    override public function set maxWidth(value:Number):void
    {
        if (textDisplay)
        {
            textDisplay.maxWidth = value;
            textDisplayProperties = BitFlagUtil.update(
                uint(textDisplayProperties), MAX_WIDTH_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.maxWidth = value;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }

    //--------------------------------------------------------------------------
    //
    //  Properties proxied to textDisplay
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  displayAsPassword
    //----------------------------------
    
    /**
     *  @copy spark.components.RichEditableText#displayAsPassword
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get displayAsPassword():Boolean
    {
        if (textDisplay)
            return textDisplay.displayAsPassword;

        // want the default to be false
        var v:* = textDisplayProperties.displayAsPassword
        return (v === undefined) ? false : v;
    }

    /**
     *  @private
     */
    public function set displayAsPassword(value:Boolean):void
    {
        if (textDisplay)
        {
            textDisplay.displayAsPassword = value;
            textDisplayProperties = BitFlagUtil.update(
                                    uint(textDisplayProperties), 
                                    DISPLAY_AS_PASSWORD_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.displayAsPassword = value;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }

    //----------------------------------
    //  editable
    //----------------------------------

    /**
     *  @copy spark.components.RichEditableText#editable
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get editable():Boolean
    {
        if (textDisplay)
            return textDisplay.editable;
            
        // want the default to be true
        var v:* = textDisplayProperties.editable;
        return (v === undefined) ? true : v;
    }

    /**
     *  @private
     */
    public function set editable(value:Boolean):void
    {
        if (textDisplay)
        {
            textDisplay.editable = value;
            textDisplayProperties = BitFlagUtil.update(
                uint(textDisplayProperties), EDITABLE_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.editable = value;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }

    //----------------------------------
    //  enableIME
    //----------------------------------

    /**
     *  @copy spark.components.RichEditableText#enableIME
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get enableIME():Boolean
    {
        return editable;
    }

    //----------------------------------
    //  imeMode
    //----------------------------------

    /**
     *  @copy spark.components.RichEditableText#imeMode
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
     public function get imeMode():String
    {
        if (textDisplay)        
            return textDisplay.imeMode;
            
        // want the default to be null
        var v:* = textDisplayProperties.imeMode;
        return (v === undefined) ? null : v;
    }

    /**
     *  @private
     */
    public function set imeMode(value:String):void
    {
        if (textDisplay)
        {
            textDisplay.imeMode = value;
            textDisplayProperties = BitFlagUtil.update(
                uint(textDisplayProperties), IME_MODE_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.imeMode = value;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }

    //----------------------------------
    //  maxChars
    //----------------------------------

    /**
     *  @copy spark.components.RichEditableText#maxChars
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get maxChars():int 
    {
        if (textDisplay)
            return textDisplay.maxChars;
            
        // want the default to be 0
        var v:* = textDisplayProperties.maxChars;
        return (v === undefined) ? 0 : v;
    }
    
    /**
     *  @private
     */
    public function set maxChars(value:int):void
    {
        if (textDisplay)
        {
            textDisplay.maxChars = value;
            textDisplayProperties = BitFlagUtil.update(
                uint(textDisplayProperties), MAX_CHARS_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.maxChars = value;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }

    //----------------------------------
    //  restrict
    //----------------------------------

    /**
     *  @copy spark.components.RichEditableText#restrict
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
        if (textDisplay)
            return textDisplay.restrict;
            
        // want the default to be null
        var v:* = textDisplayProperties.restrict;
        return (v === undefined) ? null : v;
    }
    
    /**
     *  @private
     */
    public function set restrict(value:String):void
    {
        if (textDisplay)
        {
            textDisplay.restrict = value;
            textDisplayProperties = BitFlagUtil.update(
                uint(textDisplayProperties), RESTRICT_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.restrict = value;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }

    //----------------------------------
    //  selectable
    //----------------------------------

    /**
     *  @copy spark.components.RichEditableText#selectable
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectable():Boolean
    {
        if (textDisplay)
            return textDisplay.selectable;
            
        // want the default to be true
        var v:* = textDisplayProperties.selectable;
        return (v === undefined) ? true : v;
    }

    /**
     *  @private
     */
    public function set selectable(value:Boolean):void
    {
        if (textDisplay)
        {
            textDisplay.selectable = value;
            textDisplayProperties = BitFlagUtil.update(
                uint(textDisplayProperties), SELECTABLE_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.selectable = value;
        }
        
        // Generate an UPDATE_COMPLETE event.
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
     *  @copy spark.components.RichEditableText#selectionActivePosition
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
     *  @copy spark.components.RichEditableText#selectionAnchorPosition
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
    //  selectionHighlighting
    //----------------------------------

    /**
     *  @copy spark.components.RichEditableText#selectionHighlighting
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectionHighlighting():String 
    {
        if (textDisplay)
            return textDisplay.selectionHighlighting;
            
        // want the default to be "when focused"
        var v:* = textDisplayProperties.selectionHighlighting;
        return (v === undefined) ? TextSelectionHighlighting.WHEN_FOCUSED : v;
    }
    
    /**
     *  @private
     */
    public function set selectionHighlighting(value:String):void
    {
        if (textDisplay)
        {
            textDisplay.selectionHighlighting = value;
            textDisplayProperties = BitFlagUtil.update(
                                    uint(textDisplayProperties), 
                                    SELECTION_HIGHLIGHTING_FLAG, true);
        }
        else
        {
            textDisplayProperties.selectionHighlighting = value;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }

    //----------------------------------
    //  text
    //----------------------------------

    /**
     *  @copy spark.components.RichEditableText#text
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get text():String
    {
        if (textDisplay)
            return textDisplay.text;
            
        // If there is no textDisplay, it isn't possible to set one of
        // text, textFlow or content and then get it in another form.
                    
        // want the default to be the empty string
        var v:* = textDisplayProperties.text;
        return (v === undefined) ? "" : v;
    }

    /**
     *  @private
     */
    public function set text(value:String):void
    {
        if (textDisplay)
        {
            textDisplay.text = value;
            textDisplayProperties = BitFlagUtil.update(
                uint(textDisplayProperties), TEXT_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.text = value;

            // Of 'text', 'textFlow', and 'content', the last one set wins.  So
            // if we're holding onto the properties until the skin is loaded
            // make sure only the last one set is defined.
            textDisplayProperties.content = undefined;
            textDisplayProperties.textFlow = undefined;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
     }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function initializeAccessibility():void
    {
        if (SkinnableTextBase.createAccessibilityImplementation != null)
            SkinnableTextBase.createAccessibilityImplementation(this);
    }

    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);

        if (instance == textDisplay)
        {
            // Copy proxied values from textDisplayProperties (if set) to 
            //textDisplay.
            textDisplayAdded();            

            // Focus on this, rather than the inner RET component.
            textDisplay.focusEnabled = false;

            // Start listening for various events from the RichEditableText.

            textDisplay.addEventListener(SelectionEvent.SELECTION_CHANGE,
                                         textDisplay_selectionChangeHandler);

            textDisplay.addEventListener(TextOperationEvent.CHANGING, 
                                         textDisplay_changingHandler);

            textDisplay.addEventListener(TextOperationEvent.CHANGE,
                                         textDisplay_changeHandler);

            textDisplay.addEventListener(FlexEvent.ENTER,
                                         textDisplay_enterHandler);

            textDisplay.addEventListener(FlexEvent.VALUE_COMMIT,
                                         textDisplay_valueCommitHandler);
        }
    }

    /**
     *  @private
     */
    override protected function partRemoved(partName:String, 
                                            instance:Object):void
    {
        super.partRemoved(partName, instance);

        if (instance == textDisplay)
        {
            // Copy proxied values from textDisplay (if explicitly set) to 
            // textDisplayProperties.                        
            textDisplayRemoved();            
            
            // Stop listening for various events from the RichEditableText.

            textDisplay.removeEventListener(SelectionEvent.SELECTION_CHANGE,
                                            textDisplay_selectionChangeHandler);

            textDisplay.removeEventListener(TextOperationEvent.CHANGING,
                                            textDisplay_changingHandler);

            textDisplay.removeEventListener(TextOperationEvent.CHANGE,
                                            textDisplay_changeHandler);

            textDisplay.removeEventListener(FlexEvent.ENTER,
                                            textDisplay_enterHandler);

            textDisplay.removeEventListener(FlexEvent.VALUE_COMMIT,
                                            textDisplay_valueCommitHandler);
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
        if (textDisplay)
            textDisplay.setFocus();
    }

    /**
     *  @private
     */
    override protected function isOurFocus(target:DisplayObject):Boolean
    {
        return target == textDisplay || super.isOurFocus(target);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @copy spark.components.RichEditableText#insertText()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function insertText(text:String):void
    {
        if (!textDisplay)
            return;

        textDisplay.insertText(text);
        
        // This changes text so generate an UPDATE_COMPLETE event.
        invalidateProperties();
    }

    /**
     *  @copy spark.components.RichEditableText#appendText()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function appendText(text:String):void
    {
        if (!textDisplay)
            return;

        textDisplay.appendText(text);
        
        // This changes text so generate an UPDATE_COMPLETE event.
        invalidateProperties();
    }
    
    /**
     *  @copy spark.components.RichEditableText#selectRange()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function selectRange(anchorIndex:int, activeIndex:int):void
    {
        if (!textDisplay)
            return;

        textDisplay.selectRange(anchorIndex, activeIndex);

        // This changes the selection so generate an UPDATE_COMPLETE event.
        invalidateProperties();
    }

    /**
     *  @copy spark.components.RichEditableText#selectAll()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function selectAll():void
    {
        if (!textDisplay)
            return;

        textDisplay.selectAll();

        // This changes the selection so generate an UPDATE_COMPLETE event.
        invalidateProperties();
    }

    /**
     *  @private
     */
    mx_internal function setContent(value:Object):void
    {        
        if (textDisplay)
        {
            textDisplay.content = value;
            textDisplayProperties = BitFlagUtil.update(
                uint(textDisplayProperties), CONTENT_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.content = value;
            
            // Of 'text', 'textFlow', and 'content', the last one set wins.  So
            // if we're holding onto the properties until the skin is loaded
            // make sure only the last one set is defined.
            textDisplayProperties.text = undefined;
            textDisplayProperties.textFlow = undefined;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
     }

    /**
     *  @private
     */
    mx_internal function getHeightInLines():Number
    {
        if (textDisplay)
            return textDisplay.heightInLines;
            
        // want the default to be NaN
        var v:* = textDisplayProperties.heightInLines;        
        return (v === undefined) ? NaN : v;
    }

    /**
     *  @private
     */
    mx_internal function setHeightInLines(value:Number):void
    {
        if (textDisplay)
        {
            textDisplay.heightInLines = value;
            textDisplayProperties = BitFlagUtil.update(
                uint(textDisplayProperties), 
                HEIGHT_IN_LINES_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.heightInLines = value;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }

    /**
     *  @private  
     */
    mx_internal function getTextFlow():TextFlow 
    {
        if (textDisplay)
            return textDisplay.textFlow;
            
        // If there is no textDisplay, it isn't possible to set one of
        // text, textFlow or content and then get it in another form.

        // want the default to be null
        var v:* = textDisplayProperties.textFlow;
        return (v === undefined) ? null : v;
    }
    
    /**
     *  @private
     */
    mx_internal function setTextFlow(value:TextFlow):void
    {
        if (textDisplay)
        {
            textDisplay.textFlow = value;
            textDisplayProperties = BitFlagUtil.update(
                                    uint(textDisplayProperties), 
                                    TEXT_FLOW_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.textFlow = value;

            // Of 'text', 'textFlow', and 'content', the last one set wins.  So
            // if we're holding onto the properties until the skin is loaded
            // make sure only the last one set is defined.
            textDisplayProperties.text = undefined;
            textDisplayProperties.content = undefined;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }

    /**
     *  The default width for the Text components, measured in characters.
     *  The width of the "M" character is used for the calculation.
     *  So if you set this property to 5, it will be wide enough
     *  to let the user enter 5 ems.
     *
     *  @private
     */
    mx_internal function getWidthInChars():Number
    {
        if (textDisplay)
            return textDisplay.widthInChars
            
        // want the default to be NaN
        var v:* = textDisplayProperties.widthInChars;
        return (v === undefined) ? NaN : v;
    }

    /**
     *  @private
     */
    mx_internal function setWidthInChars(value:Number):void
    {
        if (textDisplay)
        {
            textDisplay.widthInChars = value;
            textDisplayProperties = BitFlagUtil.update(
                uint(textDisplayProperties), 
                WIDTH_IN_CHARS_PROPERTY_FLAG, true);
        }
        else
        {
            textDisplayProperties.widthInChars = value;
        }

        // Generate an UPDATE_COMPLETE event.
        invalidateProperties();                    
    }
    
    /**
     *  @private
     *  Copy values stored locally into textDisplay now that textDisplay 
     *  has been added.
     */
    private function textDisplayAdded():void
    {        
        var newTextDisplayProperties:uint = 0;
        
        if (textDisplayProperties.content !== undefined)
        {
            textDisplay.content = textDisplayProperties.content;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), CONTENT_PROPERTY_FLAG, true);
        }
 
        if (textDisplayProperties.displayAsPassword !== undefined)
        {
            textDisplay.displayAsPassword = 
                textDisplayProperties.displayAsPassword
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), 
                DISPLAY_AS_PASSWORD_PROPERTY_FLAG, true);
        }

        if (textDisplayProperties.editable !== undefined)
        {
            textDisplay.editable = textDisplayProperties.editable;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), EDITABLE_PROPERTY_FLAG, true);
        }

        if (textDisplayProperties.heightInLines !== undefined)
        {
            textDisplay.heightInLines = textDisplayProperties.heightInLines;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), 
                HEIGHT_IN_LINES_PROPERTY_FLAG, true);
        }

        if (textDisplayProperties.imeMode !== undefined)
        {
            textDisplay.imeMode = textDisplayProperties.imeMode;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), IME_MODE_PROPERTY_FLAG, true);
        }

        if (textDisplayProperties.maxChars !== undefined)
        {
            textDisplay.maxChars = textDisplayProperties.maxChars;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), MAX_CHARS_PROPERTY_FLAG, true);
        }

        if (textDisplayProperties.maxWidth !== undefined)
        {
            textDisplay.maxWidth = textDisplayProperties.maxWidth;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), MAX_WIDTH_PROPERTY_FLAG, true);
        }

        if (textDisplayProperties.restrict !== undefined)
        {
            textDisplay.restrict = textDisplayProperties.restrict;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), RESTRICT_PROPERTY_FLAG, true);
        }

        if (textDisplayProperties.selectable !== undefined)
        {
            textDisplay.selectable = textDisplayProperties.selectable;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), SELECTABLE_PROPERTY_FLAG, true);
        }

        if (textDisplayProperties.selectionHighlighting !== undefined)
        {
            textDisplay.selectionHighlighting = 
                textDisplayProperties.selectionHighlighting;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), 
                SELECTION_HIGHLIGHTING_FLAG, true);
        }
            
        if (textDisplayProperties.text != null)
        {
            textDisplay.text = textDisplayProperties.text;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), TEXT_PROPERTY_FLAG, true);
        }

        if (textDisplayProperties.textFlow !== undefined)
        {
            textDisplay.textFlow = textDisplayProperties.textFlow;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), TEXT_FLOW_PROPERTY_FLAG, true);
        }

        if (textDisplayProperties.widthInChars !== undefined)
        {
            textDisplay.widthInChars = textDisplayProperties.widthInChars;
            newTextDisplayProperties = BitFlagUtil.update(
                uint(newTextDisplayProperties), 
                WIDTH_IN_CHARS_PROPERTY_FLAG, true);
        }
            
        // Switch from storing properties to bit mask of stored properties.
        textDisplayProperties = newTextDisplayProperties;    
    }
    
    /**
     *  @private
     *  Copy values stored in textDisplay back to local storage since 
     *  textDisplay is about to be removed.
     */
    private function textDisplayRemoved():void
    {        
        var newTextDisplayProperties:Object = {};
        
        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              DISPLAY_AS_PASSWORD_PROPERTY_FLAG))
        {
            newTextDisplayProperties.displayAsPassword = 
                textDisplay.displayAsPassword;
        }

        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              EDITABLE_PROPERTY_FLAG))
        {
            newTextDisplayProperties.editable = textDisplay.editable;
        }
        
        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              HEIGHT_IN_LINES_PROPERTY_FLAG))
        {
            newTextDisplayProperties.heightInLines = textDisplay.heightInLines;
        }

        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              IME_MODE_PROPERTY_FLAG))
        {
            newTextDisplayProperties.imeMode = textDisplay.imeMode;
        }
        
        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              MAX_CHARS_PROPERTY_FLAG))
        {
            newTextDisplayProperties.maxChars = textDisplay.maxChars;
        }

        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              MAX_WIDTH_PROPERTY_FLAG))
        {
            newTextDisplayProperties.maxWidth = textDisplay.maxWidth;
        }

        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              RESTRICT_PROPERTY_FLAG))
        {
            newTextDisplayProperties.restrict = textDisplay.restrict;
        }
        
        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              SELECTABLE_PROPERTY_FLAG))
        {
            newTextDisplayProperties.selectable = textDisplay.selectable;
        }

        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              SELECTION_HIGHLIGHTING_FLAG))
        {
            newTextDisplayProperties.selectionHighlighting = 
                textDisplay.selectionHighlighting;
        }
            
        // Text is special.            
        if (BitFlagUtil.isSet(uint(textDisplayProperties), TEXT_PROPERTY_FLAG))
            newTextDisplayProperties.text = textDisplay.text;

        // Content is just a setter.  So if it was set, get the textFlow
        // instead.        
        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                TEXT_FLOW_PROPERTY_FLAG) || 
            BitFlagUtil.isSet(uint(textDisplayProperties), 
                CONTENT_PROPERTY_FLAG))
        {
            newTextDisplayProperties.textFlow = textDisplay.textFlow;
        }

        if (BitFlagUtil.isSet(uint(textDisplayProperties), 
                              WIDTH_IN_CHARS_PROPERTY_FLAG))
        {
            newTextDisplayProperties.widthInChars = textDisplay.widthInChars;
        }
            
        // Switch from storing bit mask to storing properties.
        textDisplayProperties = newTextDisplayProperties;
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
        if (event.target == this)
        {
            // call setFocus on ourselves to pass focus to the
            // textDisplay.  This situation occurs when the
            // player occasionally takes over the first TAB
            // on a newly activated Window with nothing currently
            // in focus
            setFocus();
            return;
        }

        // Only editable text should have a focus ring.
        if (enabled && editable && focusManager)
            focusManager.showFocusIndicator = true;

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
    private function textDisplay_selectionChangeHandler(event:Event):void
    {
        // Update our storage variables for the selection indices.
        _selectionAnchorPosition = textDisplay.selectionAnchorPosition;
        _selectionActivePosition = textDisplay.selectionActivePosition;
        
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
    private function textDisplay_changeHandler(event:TextOperationEvent):void
    {        
        //trace(id, "textDisplay_changeHandler", textDisplay.text);
        
        // The text component has changed.  Generate an UPDATE_COMPLETE event.
        invalidateDisplayList();
        
        // Redispatch the event that came from the RichEditableText.
        dispatchEvent(event);
    }

    /**
     *  @private
     *  Called when the RichEditableText dispatches a 'changing' event
     *  before an editing operation.
     */
    private function textDisplay_changingHandler(event:TextOperationEvent):void
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
    private function textDisplay_enterHandler(event:Event):void
    {
        // Redispatch the event that came from the RichEditableText.
        dispatchEvent(event);
    }

    /**
     *  @private
     *  Called when the RichEditableText dispatches an 'valueCommit' event
     *  when values are changed programmatically or by user interaction.
     *  Before the textDisplay part is loaded, any properties set are held
     *  in textDisplayProperties.  We don't want to dispatch 'valueCommit' when 
     *  there isn't a textDisplay since since the event will be dispatched by 
     *  RET when the textDisplay part is added.
     */
    private function textDisplay_valueCommitHandler(event:Event):void
    {
        // Redispatch the event that came from the RichEditableText.
        dispatchEvent(event);
    }
}

}
