////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.supportClasses
{
import flash.accessibility.AccessibilityProperties;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.FocusEvent;
import flash.events.SoftKeyboardEvent;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.system.Capabilities;
import flash.text.AutoCapitalize;
import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;
import flash.text.StageText;
import flash.text.StageTextInitOptions;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.text.TextLineMetrics;

import flashx.textLayout.formats.LineBreak;

import mx.core.DPIClassification;
import mx.core.DesignLayer;
import mx.core.FlexGlobals;
import mx.core.IInvalidating;
import mx.core.IVisualElement;
import mx.core.LayoutDirection;
import mx.core.UIComponent;
import mx.core.UITextFormat;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.geom.TransformOffsets;
import mx.managers.FocusManager;
import mx.styles.CSSStyleDeclaration;
import mx.styles.ISimpleStyleClient;
import mx.styles.IStyleClient;

import spark.core.IEditableText;
import spark.core.ISoftKeyboardHintClient;
import spark.events.TextOperationEvent;
import spark.primitives.Rect;

use namespace mx_internal;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="alpha", kind="property")]
[Exclude(name="horizontalScrollPosition", kind="property")]
[Exclude(name="isTruncated", kind="property")]
[Exclude(name="lineBreak", kind="property")]
[Exclude(name="selectable", kind="property")]
[Exclude(name="verticalScrollPosition", kind="property")]

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched after a user editing operation is complete.
 * 
 *  @eventType flash.events.Event.CHANGE
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.5.2
 */
[Event(name="change", type="flash.events.Event")]

/**
 *  Dispatched if the StageText is not multiline and the user presses the enter
 *  key.
 * 
 *  @eventType mx.events.FlexEvent.ENTER
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.5.2
 */
[Event(name="enter", type="mx.events.FlexEvent")]

/**
 *  Dispatched after the native text control gains focus. This happens when a
 *  user highlights the text field with a pointing device, keyboard navigation,
 *  or a touch gesture.
 * 
 *  <p>Note: Since <code>flash.text.StageText</code> is not an
 *  <code>InteractiveObject</code>, the <code>Stage.focus</code> property may
 *  not be used to determine if a native text field has focus.</p>
 * 
 *  @eventType flash.events.FocusEvent.FOCUS_IN
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.5.2
 */
[Event(name="focusIn", type="flash.events.FocusEvent")]

/**
 *  Dispatched after the native text control loses focus. This happens when a
 *  user highlights an object other than the text field with a pointing device,
 *  keyboard navigation, or a touch gesture.
 * 
 *  <p>Note: Since <code>flash.text.StageText</code> is not an
 *  <code>InteractiveObject</code>, the <code>Stage.focus</code> property may
 *  not be used to determine if a native text field has focus.</p>
 * 
 *  @eventType flash.events.FocusEvent.FOCUS_OUT
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.5.2
 */
[Event(name="focusOut", type="flash.events.FocusEvent")]

/**
 *  Dispatched when a soft keyboard is displayed.
 * 
 *  @eventType flash.events.SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.5.2
 */
[Event(name="softKeyboardActivate", type="flash.events.SoftKeyboardEvent")]

/**
 *  Dispatched immediately before a soft keyboard is displayed. If canceled by
 *  calling <code>preventDefault</code>, the soft keyboard will not open.
 * 
 *  @eventType flash.events.SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.5.2
 */
[Event(name="softKeyboardActivating", type="flash.events.SoftKeyboardEvent")]

/**
 *  Dispatched when a soft keyboard is lowered or hidden.
 * 
 *  @eventType flash.events.SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.5.2
 */
[Event(name="softKeyboardDeactivate", type="flash.events.SoftKeyboardEvent")]

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  Color of text in the component, including the component label.
 *
 *  @default 0x000000
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.5.2
 */
[Style(name="color", type="uint", format="Color", inherit="yes")]

/**
 *  Name of the font to use.
 *  Unlike in a full CSS implementation,
 *  comma-separated lists are not supported.
 *  You can use any font family name.
 *  If you specify a generic font name,
 *  it is converted to an appropriate device font.
 * 
 *  @default "_sans"
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.5.2
 */
[Style(name="fontFamily", type="String", inherit="yes")]

/**
 *  Height of the text, in pixels.
 * 
 *  @default 24
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.5.2
 */
[Style(name="fontSize", type="Number", format="Length", inherit="yes")]

/**
 *  Determines whether the text is italic font.
 *  Recognized values are <code>"normal"</code> and <code>"italic"</code>.
 * 
 *  @default "normal"
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.5.2
 */
[Style(name="fontStyle", type="String", enumeration="normal,italic", inherit="yes")]

/**
 *  Determines whether the text is boldface.
 *  Recognized values are <code>normal</code> and <code>bold</code>.
 * 
 *  @default "normal"
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.5.2
 */
[Style(name="fontWeight", type="String", enumeration="normal,bold", inherit="yes")]

/**
 *  Alignment of text within a container.
 *  Possible values are <code>"left"</code>, <code>"right"</code>,
 *  or <code>"center"</code>.
 * 
 *  @default "left"
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.5.2
 */
[Style(name="textAlign", type="String", enumeration="left,center,right", inherit="yes")]

/**
 *  The StageTextField class is a text primitive for use in ActionScript skins.
 *  It cannot be used in MXML markup and is not compatible with effects or the
 *  subset of styles enumerated above.
 * 
 *  @see flash.text.StageText
 *
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.5.2
 */
public class StyleableStageText extends UIComponent implements IEditableText, ISoftKeyboardHintClient
{
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
    private static var supportedStyles:String = "textAlign fontFamily fontWeight fontStyle fontSize color";
    
    /**
     *  StageText does not support setting its style-like properties to null or
     *  undefined to restore their default values. So, the first time we create
     *  a StageText, store its default values here.
     */
    private static var defaultStyles:Object;
    
    /**
     *  The last StageText to take focus. This needs to be kept track of because
     *  StageTexts have a focus model compeletely separate from the rest of
     *  Flash's focus model. Stage.focus will never point to a StageText. The
     *  only way to get the focused StageText is to listen to all the 
     *  StageTexts' focus events.
     */
    private static var focusedStageText:StageText = null;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    public function StyleableStageText(multiline:Boolean = false)
    {
        super();
        
        stageText = new StageText(new StageTextInitOptions(multiline));
        
        if (!defaultStyles)
        {
            defaultStyles = {};
            
            defaultStyles["textAlign"] = stageText.textAlign;
            defaultStyles["fontFamily"] = stageText.fontFamily;
            defaultStyles["fontWeight"] = stageText.fontWeight;
            defaultStyles["fontStyle"] = stageText.fontPosture;
            defaultStyles["fontSize"] = stageText.fontSize;
            defaultStyles["color"] = stageText.color;
        }
        
        stageText.addEventListener(Event.CHANGE, stageText_changeHandler);
        stageText.addEventListener(FocusEvent.FOCUS_IN, stageText_focusInHandler);
        stageText.addEventListener(FocusEvent.FOCUS_OUT, stageText_focusOutHandler);
        stageText.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, stageText_softKeyboardHandler);
        stageText.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, stageText_softKeyboardHandler);
        stageText.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, stageText_softKeyboardHandler);
        
        _multiline = multiline;
        _displayAsPassword = stageText.displayAsPassword;
        _maxChars = stageText.maxChars;
        _restrict = stageText.restrict;
        
        addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);
        addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The runtime StageText object that this field uses for text display and
     *  editing. 
     */
    private var stageText:StageText;
    
    /**
     *  Flag indicating one or more styles have changed. If invalidateStyleFlag
     *  is false, commitStyles is a no-op, so it is safe to call commitStyles
     *  whenever this object is measured or drawn.
     */
    private var invalidateStyleFlag:Boolean = true;
    
    /**
     *  The rectangle that defines the StageText's bounds in this object's
     *  parent's coordinate space.
     */    
    private var localViewPort:Rectangle;
    
    /**
     *  Flag indicating the position or size of the StageText needs to change.
     */
    private var invalidateViewPortFlag:Boolean = false;
    
    /**
     *  The StageText's view port needs to be assigned after the StageText has
     *  its stage reference set. Otherwise, it will never show up. So, if we get
     *  called to set up the view port before this object is added to a stage,
     *  defer setting the StageText's view port.
     */
    private var deferredViewPortUpdate:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  enabled
    //----------------------------------
    
    /**
     *  Storage for the enabled property.
     */
    private var _enabled:Boolean = true;
    
    /**
     *  @copy mx.core.UIComponent#enabled
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    override public function set enabled(value:Boolean):void
    {
        super.enabled = value;
        _enabled = value;
        invalidateProperties();
    }
    
    //----------------------------------
    //  height
    //----------------------------------
    
    /**
     *  @copy flash.display.DisplayObject#height
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    override public function get height():Number
    {
        if (!localViewPort)
            return 0;
        
        return localViewPort.height;
    }
    
    override public function set height(value:Number):void
    {
        super.height = value;
        
        if (value == height)
            return;
        
        if (!localViewPort)
            localViewPort = new Rectangle();
        
        localViewPort.height = value;
        
        invalidateViewPortFlag = true;
        invalidateProperties();
    }
    
    //----------------------------------
    //  visible
    //----------------------------------
    
    /**
     * Storage for the visible property.
     */
    private var _visible:Boolean = true;
    
    /**
     *  @copy flash.display.DisplayObject#visible
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    override public function get visible():Boolean
    {
        return _visible;
    }
    
    override public function set visible(value:Boolean):void
    {
        super.visible = value;
        
        if (value == _visible)
            return;
        
        _visible = value;

        invalidateViewPortFlag = true;
        invalidateProperties();
    }
    
    //----------------------------------
    //  width
    //----------------------------------
    
    /**
     *  @copy flash.display.DisplayObject#width
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    override public function get width():Number
    {
        if (!localViewPort)
            return 0;
        
        return localViewPort.width;
    }
    
    override public function set width(value:Number):void
    {
        super.width = value;
        
        if (value == width)
            return;
        
        if (!localViewPort)
            localViewPort = new Rectangle();
        
        localViewPort.width = value;
        
        invalidateViewPortFlag = true;
        invalidateProperties();
    }
    
    //----------------------------------
    //  x
    //----------------------------------
    
    /**
     *  @copy flash.display.DisplayObject#x
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    override public function get x():Number
    {
        if (!localViewPort)
            return 0;
        
        return localViewPort.x;
    }
    
    override public function set x(value:Number):void
    {
        super.x = value;
        
        if (value == x)
            return;
        
        if (!localViewPort)
            localViewPort = new Rectangle();
        
        localViewPort.x = value;
        
        invalidateViewPortFlag = true;
        invalidateProperties();
    }
    
    //----------------------------------
    //  y
    //----------------------------------
    
    /**
     *  @copy flash.display.DisplayObject#y
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    override public function get y():Number
    {
        if (!localViewPort)
            return 0;
        
        return localViewPort.y;
    }
    
    override public function set y(value:Number):void
    {
        super.y = value;
        
        if (value == y)
            return;
        
        if (!localViewPort)
            localViewPort = new Rectangle();
        
        localViewPort.y = value;
        
        invalidateViewPortFlag = true;
        invalidateProperties();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
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
        return measureTextLineHeight();
    }
    
    //----------------------------------
    //  displayAsPassword
    //----------------------------------
    
    /**
     *  Storage for the displayAsPassword property.
     *  This is needed because clients may ask for this after the StageText has
     *  been disposed.
     */
    private var _displayAsPassword:Boolean;
    
    /**
     *  Specifies whether the text field is a password text field.
     * 
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    public function get displayAsPassword():Boolean
    {
        return _displayAsPassword;
    }
    
    public function set displayAsPassword(value:Boolean):void
    {
        if (stageText != null)
            stageText.displayAsPassword = value;
        
        _displayAsPassword = value;
    }
    
    //----------------------------------
    //  editable
    //----------------------------------
    
    /**
     *  Storage for the editable property.
     */
    private var _editable:Boolean = true;
    
    /**
     *  Flag that indicates whether the text in the field is editable.
     * 
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    public function get editable():Boolean
    {
        return _editable;
    }
    
    public function set editable(value:Boolean):void
    {
        _editable = value;
        invalidateProperties();
    }
    
    //----------------------------------
    //  horizontalScrollPosition
    //----------------------------------
    
    /**
     *  @private
     *  The horizontal scroll position of the text. StageText doesn't support
     *  this currently. Even so, we need to have this to satisfy requirements
     *  of the IEditableText interface.
     */
    public function get horizontalScrollPosition():Number
    {
        // TODO: StageText doesn't support this yet
        return 0;
    }
    
    public function set horizontalScrollPosition(value:Number):void
    {
        // TODO: StageText doesn't support this yet
    }
    
    //----------------------------------
    //  isTruncated
    //----------------------------------
    
    /**
     *  @private
     *  A flag that indicates whether the text has been truncated. StageText
     *  doesn't support this currently. Even so, we need to have this to satisfy
     *  requirements of the IEditableText interface.
     */
    public function get isTruncated():Boolean
    {
        // TODO: StageText doesn't support measuring text yet
        return false;
    }
    
    //----------------------------------
    //  lineBreak
    //----------------------------------
    
    /**
     *  @private
     *  Controls word wrapping within the text. This property corresponds
     *  to the lineBreak style. StageText doesn't support this currently. Even
     *  so, we need to have this to satisfy requirements of the IEditableText
     *  interface.
     */
    public function get lineBreak():String
    {
        return LineBreak.TO_FIT;
    }
    
    public function set lineBreak(value:String):void
    {
        // StageText only supports LineBreak.TO_FIT
    }
    
    //----------------------------------
    //  maxChars
    //----------------------------------
    
    /**
     *  Storage for the maxChars property.
     *  This is needed because clients may ask for this after the StageText has
     *  been disposed.
     */
    private var _maxChars:int;
    
    /**
     *  @copy flash.text.StageText#maxChars
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    public function get maxChars():int
    {
        return _maxChars;
    }
    
    public function set maxChars(value:int):void
    {
        if (stageText != null)
            stageText.maxChars = value;
        _maxChars = value;
    }
    
    //----------------------------------
    //  multiline
    //----------------------------------
    
    /**
     *  Storage for the multiline property.
     *  This is needed because clients may ask for this after the StageText has
     *  been disposed.
     */
    private var _multiline:Boolean;
    
    /**
     *  @copy flash.text.StageText#multiline
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    public function get multiline():Boolean
    {
        return _multiline;
    }
    
    /**
     *  @private
     *  StageText doesn't support setting its multiline property after it has
     *  been created. This setter is only here to satisfy requirements of the
     *  IEditableText interface.
     */
    public function set multiline(value:Boolean):void
    {
        // Do nothing.
        // multiline cannot be set on StageText after it is created.
    }
    
    //----------------------------------
    //  restrict
    //----------------------------------
    
    /**
     *  Storage for the restrict property.
     *  This is needed because clients may ask for this after the StageText has
     *  been disposed.
     */
    private var _restrict:String;
    
    /**
     *  @copy flash.text.StageText#restrict
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    public function get restrict():String
    {
        return _restrict;
    }
    
    public function set restrict(value:String):void
    {
        if (stageText != null)
            stageText.restrict = value;
        _restrict = value;
    }
    
    //----------------------------------
    //  selectable
    //----------------------------------
    
    /**
     *  @private
     *  @copy flash.text.StageText#selectable
     */
    public function get selectable():Boolean
    {
        return true;
    }
    
    public function set selectable(value:Boolean):void
    {
        // Text is always selectable in StageText
    }
    
    //----------------------------------
    //  selectionActivePosition
    //----------------------------------
    
    /**
     *  The active, or last clicked position, of the selection. If the
     *  implementation does not support selection anchor this is the last
     *  character of the selection.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    public function get selectionActivePosition():int
    {
        if (stageText != null)
            return stageText.selectionActiveIndex;
        return 0;
    }
    
    //----------------------------------
    //  selectionAnchorPosition
    //----------------------------------
    
    /**
     *  The anchor, or first clicked position, of the selection. If the
     *  implementation does not support selection anchor this is the first
     *  character of the selection.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    public function get selectionAnchorPosition():int
    {
        if (stageText != null)
            return stageText.selectionAnchorIndex;
        return 0;
    }

    //----------------------------------
    //  text
    //----------------------------------
    
    /**
     *  Storage for the text property.
     *  This is needed because clients may ask for this after the StageText has
     *  been disposed.
     */
    private var _text:String = "";
    
    /**
     *  @copy flash.text.StageText#text
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    public function get text():String
    {
        return _text;
    }
    
    public function set text(value:String):void
    {
        if (stageText != null)
            stageText.text = value;
        _text = value;
    }
    
    //----------------------------------
    //  verticalScrollPosition
    //----------------------------------
    
    /**
     *  @private
     *  The vertical scroll position of the text. StageText doesn't support
     *  this currently. Even so, we need to have this to satisfy requirements
     *  of the IEditableText interface.
     */
    public function get verticalScrollPosition():Number
    {
        // TODO: StageText doesn't support this yet
        return 0;
    }
    
    public function set verticalScrollPosition(value:Number):void
    {
        // TODO: StageText doesn't support this yet
    }
    
    //--------------------------------------------------------------------------
    //
    //  ISoftKeyboardHint properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  autoCapitalize
    //----------------------------------
    
    /**
     *  @private
     *  Hint indicating what captialization behavior soft keyboards should use.
     *
     *  Supported values are defined in flash.text.AutoCapitalize:
     *      "none" - no automatic capitalization
     *      "word" - capitalize the first letter following any space or
     *          punctuation
     *      "sentence" - captitalize the first letter following any period
     *      "all" - capitalize every letter
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    public function set autoCapitalize(value:String):void
    {
        if (stageText != null)
        {
            if (value == null || value.length == 0)
                value = AutoCapitalize.NONE;
            
            stageText.autoCapitalize = value;
        }
    }
    
    public function get autoCapitalize():String
    {
        if (stageText != null)
            return stageText.autoCapitalize;
        
        return AutoCapitalize.NONE;
    }
    
    //----------------------------------
    //  autoCorrect
    //----------------------------------
    
    /**
     *  @private
     *  Hint indicating whether a soft keyboard should use its auto-correct
     *  behavior, if supported.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    public function get autoCorrect():Boolean
    {
        if (stageText != null)
            return stageText.autoCorrect;
        
        return false;
    }
    
    public function set autoCorrect(value:Boolean):void
    {
        if (stageText != null)
            stageText.autoCorrect = value;
    }
    
    //----------------------------------
    //  returnKeyLabel
    //----------------------------------
    
    /**
     *  @private
     *  Hint indicating what label should be displayed for the return key on
     *  soft keyboards.
     *
     *  Supported values are defined in flash.text.ReturnKeyLabel:
     *      "default" - default icon or label text
     *      "done" - icon or label text indicating completed text entry
     *      "go" - icon or label text indicating that an action should start
     *      "next" - icon or label text indicating a move to the next field
     *      "search" - icon or label text indicating that the entered text
     *          should be searched for
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    public function get returnKeyLabel():String
    {
        if (stageText != null)
            return stageText.returnKeyLabel;
        
        return ReturnKeyLabel.DEFAULT;
    }
    
    public function set returnKeyLabel(value:String):void
    {
        if (stageText != null)
        {
            if (value == null || value.length == 0)
                value = ReturnKeyLabel.DEFAULT;
            
            stageText.returnKeyLabel = value;
        }
    }
    
    //----------------------------------
    //  softKeyboardType
    //----------------------------------
    
    /**
     *  @private
     *  Hint indicating what kind of soft keyboard should be displayed for this
     *  component.
     *
     *  Supported values are defined in flash.text.SoftKeyboardType:
     *      "default" - the default keyboard
     *      "punctuation" - puts the keyboard into punctuation/symbol entry mode
     *      "url" - present soft keys appropriate for URL entry, such as a
     *          specialized key that inserts '.com'
     *      "number" - puts the keyboard into numeric keypad mode
     *      "contact" - puts the keyboard into a mode appropriate for entering
     *          contact information
     *      "email" - puts the keyboard into e-mail addres entry mode, which may
     *          make it easier to enter the at sign or '.com'
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    public function get softKeyboardType():String
    {
        if (stageText != null)
            return stageText.softKeyboardType;
        
        return SoftKeyboardType.DEFAULT;
    }
    
    public function set softKeyboardType(value:String):void
    {
        if (stageText != null)
        {
            if (value == null || value.length == 0)
                value = SoftKeyboardType.DEFAULT;
            
            stageText.softKeyboardType = value;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @copy mx.core.UIComponent#move()
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    override public function move(x:Number, y:Number):void
    {
        super.move(x, y);

        if (!localViewPort)
            localViewPort = new Rectangle();
        
        localViewPort.x = x;
        localViewPort.y = y;
        
        invalidateViewPortFlag = true;
        invalidateProperties();
    }
    
    /**
     *  Set focus to this text field.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */ 
    override public function setFocus():void
    {
        super.setFocus();
        if (stageText != null)
            stageText.assignFocus();
    }
    
    /**
     *  @copy mx.core.UIComponent#styleChanged()
     * 
     *  @param styleProp The style property that changed.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);
        
        if (styleProp == null || styleProp == "styleName"
            || supportedStyles.indexOf(styleProp) >= 0)
        {
            invalidateStyleFlag = true;
        }
    }
    
    /**
     *  @copy mx.core.UIComponent#setActualSize()
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    override public function setActualSize(w:Number, h:Number):void
    {
        super.setActualSize(w, h);
        
        if (!localViewPort)
            localViewPort = new Rectangle();
        
        localViewPort.width = w;
        localViewPort.height = h;
        
        invalidateViewPortFlag = true;
        invalidateProperties();
    }
    
    /**
     *  @copy mx.core.UIComponent#measure()
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    override protected function measure():void
    {
        commitStyles();
        
        var minMetrics:TextLineMetrics = measureText("Wj");
        var currentMetrics:TextLineMetrics = measureText(text);
        var padding:Point = calculateInternalPadding();
        
        measuredMinWidth = minMetrics.width + 2 * padding.x;
        measuredMinHeight = minMetrics.height + 2 * padding.y;
        measuredWidth = Math.max(measuredMinWidth, currentMetrics.width + 2 * padding.x);
        measuredHeight = Math.max(measuredMinHeight, currentMetrics.height + 2 * padding.y);
    }
    
    override protected function commitProperties():void
    {
        super.commitProperties();

        if (stageText != null) 
            stageText.editable = _editable && _enabled;
        
        if (invalidateViewPortFlag)
            updateViewPort();
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Appends the specified text to the end of the text component, as if you
     *  had clicked at the end and typed.
     *
     *  <p>An insertion point is then set after the new text. If necessary, the
     *  text will scroll to ensure that the insertion point is visible.</p>
     *
     *  @param text The text to be appended.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    public function appendText(text:String):void
    {
        if (stageText != null)
        {
            if (stageText.text != null)
                stageText.text += text;
            else
                stageText.text = text;
        }
    }
    
    /**
     *  Inserts the specified text into the text component as if you had typed
     *  it.
     *
     *  <p>If a range was selected, the new text replaces the selected text. If
     *  there was an insertion point, the new text is inserted there.</p>
     *
     *  <p>An insertion point is then set after the new text. If necessary, the
     *  text will scroll to ensure that the insertion point is visible.</p>
     *
     *  @param text The text to be inserted.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    public function insertText(text:String):void
    {
        if (stageText == null)
            return;
        
        var origText:String = stageText.text;
        
        var selectionActiveIndex:int = stageText.selectionActiveIndex;
        var selectionAnchorIndex:int = stageText.selectionAnchorIndex;
        
        var startIndex:int = origText.length;
        var endIndex:int = startIndex;
        
        if (selectionActiveIndex >= 0 && selectionAnchorIndex >= 0) 
        {
            startIndex = Math.min(selectionActiveIndex, selectionAnchorIndex);
            endIndex = Math.max(selectionActiveIndex, selectionAnchorIndex);
        }
        else if (selectionActiveIndex >= 0)
        {
            startIndex = selectionActiveIndex;
            endIndex = selectionActiveIndex;
        }
        else if (selectionAnchorIndex >= 0)
        {
            startIndex = selectionAnchorIndex;
            endIndex = selectionAnchorIndex;
        }
        
        var newText:String = "";
        
        if (startIndex > 0)
            newText += origText.substring(0, startIndex);
        
        newText += text;
        
        if (endIndex < origText.length)
            newText += origText.substring(endIndex);
        
        stageText.text = newText;
    }
    
    /**
     *  @private
     *  Scroll so the specified range is in view.
     */
    public function scrollToRange(anchorPosition:int, activePosition:int):void
    {
        // TODO: StageText doesn't support this yet
    }
    
    /**
     *  Selects all of the text.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */ 
    public function selectAll():void
    {
        if (stageText != null && stageText.text != null)
            stageText.selectRange(0, stageText.text.length);
    }
    
    /**
     *  Selects a specified range of characters.
     * 
     *  <p>If either position is negative, it will deselect the text range.</p>
     * 
     *  @param anchorIndex The character position specifying the end of the
     *  selection that stays fixed when the selection is extended.
     * 
     *  @param activeIndex The character position specifying the end of the
     *  selection that moves when the selection is extended.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
     */
    public function selectRange(anchorIndex:int, activeIndex:int):void
    {
        if (stageText != null)
            stageText.selectRange(anchorIndex, activeIndex);
    }
    
    /**
     *  @private
     */
    public function commitStyles():void
    {
        if (invalidateStyleFlag && stageText != null)
        {
            var textAlign:String = getStyle("textAlign");
            
            if (textAlign)
            {
                var rtl:Boolean = getStyle("layoutDirection") == LayoutDirection.RTL;
                
                if (textAlign == "start")
                    textAlign = rtl ? TextFormatAlign.RIGHT : TextFormatAlign.LEFT;
                else if (textAlign == "end")
                    textAlign = rtl ? TextFormatAlign.LEFT : TextFormatAlign.RIGHT;
                
                stageText.textAlign = textAlign;
            }
            else
            {
                stageText.textAlign = defaultStyles["textAlign"];
            }
            
            var fontFamily:String = getStyle("fontFamily");
            
            if (fontFamily)
                stageText.fontFamily = fontFamily;
            else
                stageText.fontFamily = defaultStyles["fontFamily"];
            
            var fontPosture:String = getStyle("fontStyle");
            
            if (fontPosture)
                stageText.fontPosture = fontPosture;
            else
                stageText.fontPosture = defaultStyles["fontStyle"];
            
            var fontWeight:String = getStyle("fontWeight");
            
            if (fontWeight)
                stageText.fontWeight = fontWeight;
            else
                stageText.fontWeight = defaultStyles["fontWeight"];
            
            var fontSize:* = getStyle("fontSize");
            
            if (fontSize != undefined)
                stageText.fontSize = fontSize;
            else
                stageText.fontSize = defaultStyles["fontSize"];

            var color:* = getStyle("color");
            
            if (color != undefined)
                stageText.color = color;
            else
                stageText.color = defaultStyles["color"];
            
            invalidateStyleFlag = false;
        }
    }
    
    /**
     *  Tell the StageText what rectangle it needs to render in. The StageText
     *  is not part of the normal display hierarchy, so its coordinates are
     *  always specified in global space.
     */
    private function updateViewPort():void
    {
        if (parent && localViewPort && stageText != null)
        {
            if (stageText.stage)
            {
                var globalPoint:Point = parent.localToGlobal(localViewPort.topLeft);
                var globalRect:Rectangle = new Rectangle(globalPoint.x, globalPoint.y);
    
                if (_visible) 
                {
                    globalRect.width = localViewPort.width;
                    globalRect.height = localViewPort.height;
                }
                
                stageText.viewPort = globalRect;
                deferredViewPortUpdate = false;
            }
            else
            {
                deferredViewPortUpdate = true;
            }
        }
    }
    
    mx_internal function calculateInternalPadding():Point
    {
        // TODO: This shouldn't be necessary once we get an API to determine
        // what a StageText's height should be
        const applicationDPI:Number = FlexGlobals.topLevelApplication.applicationDPI;
        const isAndroid:Boolean = Capabilities.version.indexOf("AND") == 0;
        
        var verticalPadPerPixel:Number = 0;
        var baseHorizontalPad:Number = 0;
        var baseVerticalPad:Number = 0;
        var minMetrics:TextLineMetrics = measureText("Wj");
        var minSize:Point = new Point(minMetrics.width, minMetrics.height);
        
        if (isAndroid)
        {
            switch (applicationDPI)
            {
                case DPIClassification.DPI_320:
                    verticalPadPerPixel = 0.75;
                    baseHorizontalPad = 11;
                    baseVerticalPad = 15;
                    break;
                case DPIClassification.DPI_240:
                    verticalPadPerPixel = 0.36;
                    baseHorizontalPad = 9;
                    baseVerticalPad = 12;
                    break;
                default:
                    verticalPadPerPixel = 0.125;
                    baseHorizontalPad = 7;
                    baseVerticalPad = 7;
                    break;
            }
        }

        return new Point(baseHorizontalPad, 
            baseVerticalPad + Math.ceil(minSize.y * verticalPadPerPixel));
    }
    
    /**
     *  StageText does not have any provision for measuring text. To get
     *  approximate sizing, this uses UIComponent's text measurement method on a
     *  string with an ascender and a descender. Because platform rendering and
     *  UIComponent's rendering differ, the measurement should only be used as
     *  an approximation.
     */
    private function measureTextLineHeight():Number
    {
        var lineMetrics:TextLineMetrics = measureText("Wj");
        var internalPadding:Point = calculateInternalPadding();
        
        return lineMetrics.height + internalPadding.y;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Forward the focus event to the StageText. The focusedStageText flag is
     *  modified by the StageText's focus event handlers, not this one.
     */
    override protected function focusInHandler(event:FocusEvent):void
    {
        super.focusInHandler(event);
        
        if (stageText != null && focusedStageText != stageText)
            stageText.assignFocus();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    private function stageText_changeHandler(event:Event):void
    {
        var foundChange:Boolean = false;
        var foundEnter:Boolean = false;
        
        if (stageText != null)
        {
            var oldText:String = _text;
            var oldLength:int = oldText.length;
            var newText:String = stageText.text;
            var newLength:int = newText.length;
                
            if (!_multiline && newText.substr(0, oldLength) == oldText)
            {
                // This is a single-line text field, so the enter key should
                // dispatch an enter event instead of inserting a newline
                // character. StageText does not dispatch a key-down event for
                // us to use to intercept the enter key, so our only choice
                // right now is to trap it here, after the field's text has 
                // changed.
                
                if (oldLength == newLength - 1)
                {
                    var lastChar:String = newText.substr(oldLength, 1);
                    foundEnter = lastChar == "\r" || lastChar == "\n";
                }
                else if (oldLength == newLength - 2)
                {
                    var tail:String = newText.substr(oldLength, 2);
                    foundEnter = tail == "\r\n" || tail == "\n\r";
                }
            }

            if (foundEnter)
            {
                foundChange = true;
                stageText.text = _text;
            }
            else
            {
                foundChange = newText != oldText;
                _text = stageText.text;
            }
        }

        if (foundEnter)
            dispatchEvent(new FlexEvent(FlexEvent.ENTER));
        
        if (foundChange)
            dispatchEvent(new TextOperationEvent(event.type));
    }
    
    private function stageText_focusInHandler(event:FocusEvent):void
    {
        focusedStageText = stageText;
        dispatchEvent(event);
    }
    
    private function stageText_focusOutHandler(event:FocusEvent):void
    {
        if (focusedStageText == stageText)
            focusedStageText = null;

        dispatchEvent(event);
    }
    
    private function stageText_softKeyboardHandler(event:SoftKeyboardEvent):void
    {
        dispatchEvent(new SoftKeyboardEvent(event.type, 
            event.bubbles, event.cancelable, this, event.triggerType));
    }
    
    private function addedToStageHandler(event:Event):void
    {
        if (stageText == null)
            return;
        
        stageText.stage = stage;
        
        if (deferredViewPortUpdate)
            updateViewPort();
    }
    
    /**
     *  Clean up and dispose of our StageText.
     *  TODO: This fails on iOS because of bug 2906305. 
     */
    private function removedFromStageHandler(event:Event):void
    {
        if (stageText == null)
            return;
        
        stageText.stage = null;
        
        stageText.removeEventListener(Event.CHANGE, stageText_changeHandler);
        stageText.removeEventListener(FocusEvent.FOCUS_IN, stageText_focusInHandler);
        stageText.removeEventListener(FocusEvent.FOCUS_OUT, stageText_focusOutHandler);
        stageText.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, stageText_softKeyboardHandler);
        stageText.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, stageText_softKeyboardHandler);
        stageText.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, stageText_softKeyboardHandler);

        stageText.dispose();
        stageText = null;
    }
}
}