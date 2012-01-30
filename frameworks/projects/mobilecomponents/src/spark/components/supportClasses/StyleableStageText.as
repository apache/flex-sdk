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
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Stage;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.SoftKeyboardEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
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
import flash.ui.Keyboard;

import flashx.textLayout.formats.LineBreak;

import mx.core.DPIClassification;
import mx.core.FlexGlobals;
import mx.core.IUIComponent;
import mx.core.LayoutDirection;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.events.MoveEvent;
import mx.events.ResizeEvent;
import mx.managers.SystemManager;

import spark.components.Application;
import spark.core.IEditableText;
import spark.core.ISoftKeyboardHintClient;
import spark.events.TextOperationEvent;

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
    
    /**
     *  Text measuring behavior needs to be slightly different on Android
     *  devices to account for its native text being slightly taller. Without
     *  this adjustment, single-line text on Android will be clipped or will
     *  scroll vertically.
     */
    private static const androidHeightMultiplier:Number = 1.15;
    private static const isAndroid:Boolean = Capabilities.version.indexOf("AND") == 0;

    
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
        
        _multiline = multiline;
        getStageText(true);
        
        if (!defaultStyles)
        {
            defaultStyles = {};
            
            defaultStyles["textAlign"] = stageText.textAlign;
            defaultStyles["fontFamily"] = stageText.fontFamily;
            defaultStyles["fontWeight"] = stageText.fontWeight;
            defaultStyles["fontStyle"] = stageText.fontPosture;
            defaultStyles["fontSize"] = stageText.fontSize;
            defaultStyles["color"] = stageText.color;
            defaultStyles["locale"] = stageText.locale;
        }
        
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
     *  Storage for the effective enabled property.
     */
    private var _effectiveEnabled:Boolean;
    
    /**
     *  Flag indicating that the aggregate enabled states of the StageText's
     *  ancestors is unknown.
     */
    private var invalidateEffectiveEnabledFlag:Boolean = true;
    
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
        invalidateEffectiveEnabledFlag = true;
        invalidateProperties();
    }
    
    private function get effectiveEnabled():Boolean
    {
        if (invalidateEffectiveEnabledFlag)
        {
            _effectiveEnabled = _enabled;
            
            if (_effectiveEnabled)
            {
                var ancestor:DisplayObject = parent;
                
                while (ancestor != null)
                {
                    if (ancestor is IUIComponent && !IUIComponent(ancestor).enabled)
                    {
                        _effectiveEnabled = false;
                        break;
                    }
                    
                    ancestor = ancestor.parent;
                }
            }
            
            invalidateEffectiveEnabledFlag = false;            
        }
        
        return _effectiveEnabled;
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
    //  densityScale
    //----------------------------------
    
    private var _densityScale:Number;
    
    /**
     *  The scale factor necessary to account for differences in the design
     *  resolution of the application (applicationDPI) and the resolution of the
     *  device the application is running on.
     */
    private function get densityScale():Number
    {
        if (isNaN(_densityScale))
        {
            var application:Application = FlexGlobals.topLevelApplication as Application;
            var sm:SystemManager = application ? application.systemManager as SystemManager : null;
            _densityScale = sm ? sm.densityScale : 1.0;
        }
        
        return _densityScale;
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
        return stageText ? stageText.selectionActiveIndex : 0;
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
        return stageText ? stageText.selectionAnchorIndex : 0;
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
     *  Storage for the autoCapitalize property.
     */
    private var _autoCapitalize:String = AutoCapitalize.NONE;
    
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
        if (value == "")
            value = AutoCapitalize.NONE;
        
        if (stageText != null)
            stageText.autoCapitalize = value;
        
        _autoCapitalize = value;
    }
    
    public function get autoCapitalize():String
    {
        return stageText ? stageText.autoCapitalize : _autoCapitalize;
    }
    
    //----------------------------------
    //  autoCorrect
    //----------------------------------
    
    /**
     *  Storage for the autoCorrect property.
     */
    private var _autoCorrect:Boolean = false;
    
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
        return stageText ? stageText.autoCorrect : _autoCorrect;
    }
    
    public function set autoCorrect(value:Boolean):void
    {
        if (stageText != null)
            stageText.autoCorrect = value;
        
        _autoCorrect = value;
    }
    
    //----------------------------------
    //  returnKeyLabel
    //----------------------------------
    
    /**
     *  Storage for the returnKeyLabel property.
     */
    private var _returnKeyLabel:String = ReturnKeyLabel.DEFAULT;
    
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
        return stageText ? stageText.returnKeyLabel : _returnKeyLabel;
    }
    
    public function set returnKeyLabel(value:String):void
    {
        if (value == "")
            value = ReturnKeyLabel.DEFAULT;
        
        if (stageText != null)
            stageText.returnKeyLabel = value;
        
        _returnKeyLabel = value;
    }
    
    //----------------------------------
    //  softKeyboardType
    //----------------------------------
    
    /**
     *  Storage for the softKeyboardType property.
     */
    private var _softKeyboardType:String = SoftKeyboardType.DEFAULT;
    
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
        return stageText ? stageText.softKeyboardType : _softKeyboardType;
    }
    
    public function set softKeyboardType(value:String):void
    {
        if (value == "")
            value = SoftKeyboardType.DEFAULT;
        
        if (stageText != null)
            stageText.softKeyboardType = value;
        
        _softKeyboardType = value;
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
        if (effectiveEnabled)
        {
            super.setFocus();
            if (stageText != null)
                stageText.assignFocus();
        }
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
        
        measuredMinWidth = minMetrics.width;
        measuredWidth = Math.max(measuredMinWidth, currentMetrics.width);
        
        if (isAndroid)
        {
            // Android text heights are slightly different from Flex's.
            measuredMinHeight = minMetrics.height * androidHeightMultiplier;
            measuredHeight = Math.max(measuredMinHeight, currentMetrics.height * androidHeightMultiplier);
        }
        else
        {
            measuredMinHeight = minMetrics.height;
            measuredHeight = Math.max(measuredMinHeight, currentMetrics.height);
        }
    }
    
    override protected function commitProperties():void
    {
        super.commitProperties();

        if (stageText != null) 
            stageText.editable = _editable && effectiveEnabled;
        
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
        if (stageText != null && text.length > 0)
        {
            if (stageText.text != null)
                stageText.text += text;
            else
                stageText.text = text;
            
            _text = stageText.text;
            
            // Move the cursor to the end of the appended text.
            stageText.selectRange(_text.length, _text.length);
            
            dispatchEvent(new TextOperationEvent(TextOperationEvent.CHANGE));
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
        if (stageText == null || text.length == 0)
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
        
        // Move the cursor to the end of the inserted text.
        stageText.selectRange(startIndex + text.length, startIndex + text.length);

        _text = stageText.text;
        dispatchEvent(new TextOperationEvent(TextOperationEvent.CHANGE));
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
                stageText.fontSize = fontSize * densityScale;
            else
                stageText.fontSize = defaultStyles["fontSize"] * densityScale;

            var color:* = getStyle("color");
            
            if (color != undefined)
                stageText.color = color;
            else
                stageText.color = defaultStyles["color"];
            
            var locale:* = getStyle("locale");
            
            if (locale != undefined)
                stageText.locale = locale;
            else
                stageText.locale = defaultStyles["locale"];
            
            invalidateStyleFlag = false;
        }
    }
    
    private var textImage:Bitmap = null;
    private var numEffectsRunning:int = 0;
        
    /**
     *  If a StageText is visible, this will capture a bitmap copy of what it is
     *  displaying. This includes any text visible in the StageText and may
     *  include the text insertion cursor if it is visible at the time of the
     *  call.
     */
    mx_internal function captureBitmapData():BitmapData
    {
        if (!stageText || !localViewPort || 
            localViewPort.width == 0 || localViewPort.height == 0 ||
            !visible || !calcAncestorsVisible())
            return null; // The StageText is invisible.
        
        if (stageText.viewPort.width == 0 || stageText.viewPort.height == 0)
            updateViewPort(); // The StageText viewport is stale.
        
        var bitmap:BitmapData = new BitmapData(stageText.viewPort.width, 
            stageText.viewPort.height, true, 0x00FFFFFF);
        
        stageText.drawViewPortToBitmapData(bitmap);
        
        return bitmap;
    }
    
    /**
     *  Generate an image that represents this StageText and replace the live
     *  StageText display with that image. Used for display while effects are
     *  playing.
     */
    private function createProxyImage():void
    {
        if (textImage == null)
        {
            var imageData:BitmapData = captureBitmapData();
            
            if (imageData)
            {
                textImage = new Bitmap(imageData);
                textImage.scaleX = 1.0 / densityScale;
                textImage.scaleY = 1.0 / densityScale;
                addChild(textImage);
                
                updateViewPort();
            }
        }
    }
    
    /**
     *  Destroy any previously created proxy image and restore the visibility of
     *  the StageText display that the proxy image had represented.
     */
    private function disposeProxyImage():void
    {
        if (textImage != null)
        {
            removeChild(textImage);
            textImage.bitmapData.dispose();
            textImage = null;
            
            updateViewPort();
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
    
                if (_visible && calcAncestorsVisible()) 
                {
                    if (textImage)
                    {
                        textImage.x = 0;
                        textImage.y = 0;
                    }
                    else
                    {
                        // Transform the bottom-right corner of the local rect
                        // instead of setting width/height to account for any
                        // transformations applied to ancestor objects.
                        globalRect.bottomRight = parent.localToGlobal(localViewPort.bottomRight);
                        globalRect.width = Math.floor(globalRect.width);
                        globalRect.height = Math.floor(globalRect.height);
                    }
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
        
        // Android text heights are slightly different from Flex's.
        if (isAndroid)
            return lineMetrics.height * androidHeightMultiplier;
        
        return lineMetrics.height;
    }
    
    private var ancestorsVisible:Boolean;
    private var ancestorsVisibleInvalidateFlag:Boolean = true;
    
    /**
     *  Returns true if every ancestor of this object is visible.
     */
    private function calcAncestorsVisible():Boolean
    {
        if (ancestorsVisibleInvalidateFlag)
        {
            var result:Boolean = visible;
            var ancestor:DisplayObject = parent;
            
            while (result && ancestor)
            {
                result = ancestor.visible;
                ancestor = ancestor.parent;
            }
            
            ancestorsVisible = result;
            ancestorsVisibleInvalidateFlag = false;
        }
        
        return ancestorsVisible;
    }
    
    private var watchedAncestors:Vector.<UIComponent> = new Vector.<UIComponent>();
    
    private function gatherAncestorComponents():Vector.<UIComponent>
    {
        var ancestors:Vector.<UIComponent> = new Vector.<UIComponent>();
        var ancestorObj:DisplayObject = parent;
        
        while (ancestorObj)
        {
            if (ancestorObj is UIComponent)
                ancestors.push(ancestorObj as UIComponent);
            
            ancestorObj = ancestorObj.parent;
        }
        
        return ancestors;
    }
    
    /**
     *  Search for ancestor components and add listeners to them for changes in
     *  visibility or geometry. This is necessary because StageText is separate
     *  from the display object hierarchy and must have its position and 
     *  visibilty updated manually to account for changes in the hierarchy.
     *  Listeners are needed on all ancestor components because components will
     *  not dispatch move, resize, show, or hide events unless they have
     *  listeners for those events.
     */
    private function updateWatchedAncestors():void
    {
        var newWatchedAncestors:Vector.<UIComponent> = gatherAncestorComponents();
        
        var i:int;
        for (i = 0; i < watchedAncestors.length; i++)
        {
            var ancestor:UIComponent = watchedAncestors[i];
            
            if (newWatchedAncestors.indexOf(ancestor) == -1)
            {
                ancestor.removeEventListener(MoveEvent.MOVE, ancestor_moveHandler);
                ancestor.removeEventListener(ResizeEvent.RESIZE, ancestor_resizeHandler);
                ancestor.removeEventListener(FlexEvent.SHOW, ancestor_showHandler);
                ancestor.removeEventListener(FlexEvent.HIDE, ancestor_hideHandler);
            }
        }
        
        for (i = 0; i < newWatchedAncestors.length; i++)
        {
            var newAncestor:UIComponent = newWatchedAncestors[i];
            
            if (watchedAncestors.indexOf(newAncestor) == -1)
            {
                newAncestor.addEventListener(MoveEvent.MOVE, ancestor_moveHandler, false, 0, true);
                newAncestor.addEventListener(ResizeEvent.RESIZE, ancestor_resizeHandler, false, 0, true);
                newAncestor.addEventListener(FlexEvent.SHOW, ancestor_showHandler, false, 0, true);
                newAncestor.addEventListener(FlexEvent.HIDE, ancestor_hideHandler, false, 0, true);
            }
        }
        
        watchedAncestors = newWatchedAncestors;
    }
    
    private function restoreStageText():void
    {
        if (stageText != null)
        {
            // This has to happen here instead of waiting for commitProperties
            // because this will cause stageText.text to get cleared. Subsequent
            // change events would then copy that cleared text to the _text
            // storage variable, making the change permanent.
            stageText.editable = _editable && effectiveEnabled;

            stageText.text = _text;
            stageText.displayAsPassword = _displayAsPassword;
            stageText.maxChars = _maxChars;
            
            // Workaround for runtime bug 2931896: Don't set restrict to null
            // even though that technically shouldn't do anything. Setting
            // restrict to null disables typing.
            if (_restrict != null)
                stageText.restrict = _restrict;
            
            // Soft keyboard hints
            stageText.autoCapitalize = _autoCapitalize;
            stageText.autoCorrect = _autoCorrect;
            stageText.returnKeyLabel = _returnKeyLabel;
            stageText.softKeyboardType = _softKeyboardType;
            
            // Make sure styles are restored
            invalidateStyleFlag = true;
            
            // Make sure viewPort and enabled state are recalculated
            invalidateViewPortFlag = true;
            invalidateProperties();
        }
    }
    
    mx_internal function getStageText(create:Boolean = false):StageText
    {
        if (stageText == null && create)
            stageText = new StageText(new StageTextInitOptions(_multiline));
        
        return stageText;
    }
    
    private function registerStageTextListeners():void
    {
        if (stageText != null)
        {
            stageText.addEventListener(Event.CHANGE, stageText_changeHandler);
            stageText.addEventListener(FocusEvent.FOCUS_IN, stageText_focusInHandler);
            stageText.addEventListener(FocusEvent.FOCUS_OUT, stageText_focusOutHandler);
            stageText.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, stageText_softKeyboardHandler);
            stageText.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, stageText_softKeyboardHandler);
            stageText.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, stageText_softKeyboardHandler);
            stageText.addEventListener(KeyboardEvent.KEY_DOWN, stageText_keyDownHandler);
            stageText.addEventListener(KeyboardEvent.KEY_UP, stageText_keyUpHandler);
        }
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
        
        if (stageText != null && focusedStageText != stageText && effectiveEnabled)
            stageText.assignFocus();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    private function ancestor_hideHandler(event:FlexEvent):void
    {
        // Shortcut: If any ancestor hid, the StageText must hide. No need to
        // recalculate visibility.
        ancestorsVisible = false;
        ancestorsVisibleInvalidateFlag = false;
        invalidateViewPortFlag = true;
        
        invalidateProperties();
    }
    
    private function ancestor_moveHandler(event:MoveEvent):void
    {
        // Any change in ancestor geometry may affect the StageText's geometry.
        invalidateViewPortFlag = true;
        invalidateProperties();
    }
    
    private function ancestor_resizeHandler(event:ResizeEvent):void
    {
        // Any change in ancestor geometry may affect the StageText's geometry.
        invalidateViewPortFlag = true;
        invalidateProperties();
    }
    
    private function ancestor_showHandler(event:FlexEvent):void
    {
        // An ancestor was shown, but some other ancestor may still be hidden.
        // Invalidate visibility and recalculate it later.
        ancestorsVisibleInvalidateFlag = true;
        invalidateViewPortFlag = true;
        
        invalidateProperties();
    }

    private function stageText_changeHandler(event:Event):void
    {
        var foundChange:Boolean = false;
        
        if (stageText != null)
        {
            var oldText:String = _text;
            var newText:String = stageText.text;
                
            foundChange = newText != oldText;
            _text = stageText.text;
        }

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
    
    private function stageText_keyDownHandler(event:KeyboardEvent):void
    {
        if (event.keyCode == Keyboard.ENTER && !_multiline)
            dispatchEvent(new FlexEvent(FlexEvent.ENTER));
        
        dispatchEvent(event);
    }
    
    private function stageText_keyUpHandler(event:KeyboardEvent):void
    {
        dispatchEvent(event);
    }
    
    private function stageText_softKeyboardHandler(event:SoftKeyboardEvent):void
    {
        dispatchEvent(new SoftKeyboardEvent(event.type, 
            event.bubbles, event.cancelable, this, event.triggerType));
    }
    
    private function eventTargetsAncestor(event:Event):Boolean
    {
        var ancestor:DisplayObject = parent;
        var target:Object = event.target;
        
        while (ancestor != null && ancestor != target)
            ancestor = ancestor.parent;
        
        return ancestor != null;
    }
    
    private function stage_effectStartHandler(event:EffectEvent):void
    {
        // An effect is starting, but the effect will only affect the StageText
        // if its target is an ancestor of it.
        if (eventTargetsAncestor(event))
        {
            // The first effect affecting the StageText that starts causes us
            // to replace the StageText with a bitmap.
            if (numEffectsRunning++ == 0)
                createProxyImage();
        }
    }
    
    private function stage_effectEndHandler(event:EffectEvent):void
    {
        if (eventTargetsAncestor(event))
        {
            // The last effect affecting the StageText to end causes us to put
            // the live StageText back and remove the bitmap.
            if (--numEffectsRunning == 0)
                disposeProxyImage();
        }
    }
    
    private function stage_enabledChangedHandler(event:Event):void
    {
        if (eventTargetsAncestor(event))
        {
            invalidateEffectiveEnabledFlag = true;
            invalidateProperties();
        }
    }
    
    private function stage_hierarchyChangedHandler(event:Event):void
    {
        // If an ancestor is added to or removed from the list of this
        // StageText's ancestors, update the list of components we watch for
        // visibility and geometry changes.
        if (eventTargetsAncestor(event))
            updateWatchedAncestors();
    }
    
    private function addedToStageHandler(event:Event):void
    {
        var needsRestore:Boolean = false;
        
        if (stageText == null)
        {
            getStageText(true);
            needsRestore = true;
        }
        
        stageText.stage = stage;
        
        stageText.stage.addEventListener(EffectEvent.EFFECT_START, stage_effectStartHandler, true, 0, true);
        stageText.stage.addEventListener(EffectEvent.EFFECT_END, stage_effectEndHandler, true, 0, true);
        
        stageText.stage.addEventListener(Event.ADDED, stage_hierarchyChangedHandler, false, 0, true);
        stageText.stage.addEventListener(Event.REMOVED, stage_hierarchyChangedHandler, false, 0, true);
        
        stageText.stage.addEventListener("enabledChanged", stage_enabledChangedHandler, true, 0, true);
        
        updateWatchedAncestors();
        
        if (needsRestore)
            restoreStageText();
        
        if (deferredViewPortUpdate)
            updateViewPort();
        
        registerStageTextListeners();
    }
    
    private function removedFromStageHandler(event:Event):void
    {
        if (stageText == null)
            return;
        
        stageText.stage.removeEventListener(EffectEvent.EFFECT_START, stage_effectStartHandler, true);
        stageText.stage.removeEventListener(EffectEvent.EFFECT_END, stage_effectEndHandler, true);

        stageText.stage.removeEventListener(Event.ADDED, stage_hierarchyChangedHandler);
        stageText.stage.removeEventListener(Event.REMOVED, stage_hierarchyChangedHandler);

        stageText.stage.removeEventListener("enabledChanged", stage_enabledChangedHandler, true);

        stageText.stage = null;
        
        stageText.removeEventListener(Event.CHANGE, stageText_changeHandler);
        stageText.removeEventListener(FocusEvent.FOCUS_IN, stageText_focusInHandler);
        stageText.removeEventListener(FocusEvent.FOCUS_OUT, stageText_focusOutHandler);
        stageText.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, stageText_softKeyboardHandler);
        stageText.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, stageText_softKeyboardHandler);
        stageText.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, stageText_softKeyboardHandler);
        stageText.removeEventListener(KeyboardEvent.KEY_DOWN, stageText_keyDownHandler);
        stageText.removeEventListener(KeyboardEvent.KEY_UP, stageText_keyUpHandler);

        stageText.dispose();
        stageText = null;
        
        // This component may be removed from the stage by a Fade effect. In
        // that case, we will not receive the EFFECT_END event, but should still
        // reset the effect running state and remove any bitmap representation
        // of the StageText.
        disposeProxyImage();
        numEffectsRunning = 0;
    }
}
}