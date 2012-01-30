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
import flash.display.DisplayObjectContainer;
import flash.display.PixelSnapping;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.SoftKeyboardEvent;
import flash.events.TimerEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import flash.text.AutoCapitalize;
import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;
import flash.text.StageText;
import flash.text.StageTextInitOptions;
import flash.text.TextFormatAlign;
import flash.text.TextLineMetrics;
import flash.ui.Keyboard;
import flash.utils.Timer;

import flashx.textLayout.formats.LineBreak;

import mx.core.FlexGlobals;
import mx.core.IRawChildrenContainer;
import mx.core.IUIComponent;
import mx.core.LayoutDirection;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.DynamicEvent;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.events.MoveEvent;
import mx.events.ResizeEvent;
import mx.managers.FocusManager;
import mx.managers.SystemManager;
import mx.managers.systemClasses.ActiveWindowManager;
import mx.utils.MatrixUtil;

import spark.components.Application;
import spark.components.ViewNavigator;
import spark.core.IEditableText;
import spark.core.ISoftKeyboardHintClient;
import spark.effects.Fade;
import spark.events.PopUpEvent;
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
 *  @productversion Flex 4.6
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
 *  @productversion Flex 4.6
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
 *  @productversion Flex 4.6
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
 *  @productversion Flex 4.6
 */
[Event(name="focusOut", type="flash.events.FocusEvent")]

/**
 *  Dispatched when a soft keyboard is displayed.
 * 
 *  @eventType flash.events.SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.6
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
 *  @productversion Flex 4.6
 */
[Event(name="softKeyboardActivating", type="flash.events.SoftKeyboardEvent")]

/**
 *  Dispatched when a soft keyboard is lowered or hidden.
 * 
 *  @eventType flash.events.SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.6
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
 *  @productversion Flex 4.6
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
 *  @productversion Flex 4.6
 */
[Style(name="fontFamily", type="String", inherit="yes")]

/**
 *  Height of the text, in pixels.
 * 
 *  @default 24
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.6
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
 *  @productversion Flex 4.6
 */
[Style(name="fontStyle", type="String", enumeration="normal,italic", inherit="yes")]

/**
 *  Determines whether the text is boldface.
 *  Recognized values are <code>"normal"</code> and <code>"bold"</code>.
 * 
 *  @default "normal"
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.6
 */
[Style(name="fontWeight", type="String", enumeration="normal,bold", inherit="yes")]

/**
 *  @copy spark.components.supportClasses.SkinnableTextBase#style:locale
 *
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.6
 */
[Style(name="locale", type="String", inherit="yes")]

/**
 *  Alignment of text within a container.
 *  Possible values are <code>"start"</code>, <code>"end"</code>, <code>"left"</code>, 
 *  <code>"right"</code>, or <code>"center"</code>.
 * 
 *  @default "start"
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.6
 */
[Style(name="textAlign", type="String", enumeration="start,end,left,right,center", inherit="yes")]

/**
 *  The StyleableStageText class is a text primitive for use in ActionScript
 *  skins which is used to present the user with a native text input field.
 *  It cannot be used in MXML markup, is not compatible with effects, and
 *  is not compatible with transformations such as rotation, scale, and skew.
 * 
 *  <p>StageText allows for better text entry and manipulation experiences on mobile devices 
 *  using native text fields.
 *  The native fields provide correct visuals, text spacing and reflow, selection behavior, and 
 *  text entry assistance.  
 *  This class can also be used on desktop platforms where it behaves as a wrapper around TextField.
 *  </p>
 * 
 *  The padding around native text controls may be different than the padding around 
 *  TextField controls.
 * 
 *  <p>Similiar to other native applications, when you tap outside of the native text field, the 
 *  text field gives up focus and the soft keyboard goes away.  
 *  This differs from when you tap outside of a TextField and the focus stays in the TextField and 
 *  the soft keyboard remains visible.</p>
 * 
 *  <p><b>Limitation of StageText-based controls:</b>
 *  <ul>
 *  <li>Native text input fields cannot be clipped by other Flex content and are rendered in a 
 *  layer above the Stage. 
 *  Because of this limitation, <b>components that use StageText-based skin classes will always appear 
 *  to be on top of other Flex components</b>. 
 *  Flex popups and drop-downs will also be obscured by any visible native text fields. 
 *  Finally, native text fields' relative z-order cannot be controlled by the application.</li>
 * 
 *  <li>The native controls do not support embedded fonts.</li>
 * 
 *  <li>Links and html markup are not supported.</li>
 * 
 *  <li><code>text</code> is always selectable.</li>
 * 
 *  <li>Fractional alpha values are not supported.</li>
 * 
 *  <li>Keyboard events are not dispatched for most keys.
 *  This means that the tab key will not dispatch keyDown or keyUp events so focus
 *  cannot be removed from a StageText-based control with the tab key.</li>
 * 
 *  <li>StageText is currently not capable of measuring text.</li>
 * 
 *  <li>At this time StageText does not support programmatic control of scroll position. </li>
 * 
 *  <li>At this time StageText does not support an event model necessary to allow for 
 *  touch-based scrolling of forms containing native text fields.</li>
 *  </ul>
 *  </p>
 *  
 *  @see flash.text.StageText
 *  @see spark.components.supportClasses.StyleableTextField
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.6
 */
public class StyleableStageText extends UIComponent implements IEditableText, ISoftKeyboardHintClient
{
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Class-global flag set by Design View in Builder to always display 
     *  bitmaps instead of native StageText components.
     */
    mx_internal static var alwaysShowProxyImage:Boolean = false;
    
    /**
     *  A reference to the ActiveWindowManager is necessary for detecting when a
     *  popup is displayed. If that popup obscures any StyleableStageText, the
     *  StageText within needs to be hidden so it doesn't draw on top of the
     *  popup.
     */
    private static var awm:ActiveWindowManager;
    
    private static var supportedStyles:String = "textAlign fontFamily fontWeight fontStyle fontSize color locale";
    
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
     *  A StageText corresponding to a control that was programmatically focused
     *  while the StageText was unable to take focus. Focus should be set to
     *  this StageText once it is able to take focus.
     */
    private static var pendingFocusedStageText:StageText = null;
    
    /**
     *  Text measuring behavior needs to be slightly different on Android
     *  devices to account for its native text being slightly taller. Without
     *  this adjustment, single-line text on Android will be clipped or will
     *  scroll vertically.
     */
    mx_internal static var androidHeightMultiplier:Number = 1.15;
    private static const isAndroid:Boolean = Capabilities.version.indexOf("AND") == 0;
    private static const isDesktop:Boolean = Capabilities.os.indexOf("Windows") != -1 || Capabilities.os.indexOf("Mac OS") != -1;    

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     * 
     *  <p><code>multiline</code> determines what happens when you press the Enter key.
     *  If it is <code>true</code>, the Enter key starts a new line.
     *  If it is <code>false</code>, it causes a <code>FlexEvent.ENTER</code>
     *  event to be dispatched.</p>
     * 
     *  @param multiline Set to <code>true</code> to allow more than one line of text to be input.
     * 
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.6
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
        
        // Flex's default for autoCorrect is now true, so we need to turn on
        // autoCorrect on the runtime side during construction.
        stageText.autoCorrect = _autoCorrect;
        
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
    
    /**
     *  Along with the text, need to save the selection, when the StageText is
     *  removed from the stage, so that when the StageText is restored, the
     *  selection can be restored.
     */
    private var savedSelectionAnchorIndex:int = 0;
    private var savedSelectionActiveIndex:int = 0;
    
    /**
     *  When transitions run or when a popup is displayed over this component,
     *  the StageText needs to be hidden and replaced with a bitmap proxy. This
     *  prevents StageText, which is always in a layer above everything else,
     *  from obscuring UI which is supposed to be on top and from handling
     *  gestures intended for other components. In transitons, it allows text to
     *  animate smoothly.
     */
    private var proxyImage:Bitmap = null;
    private var showProxyImage:Boolean = false;
    private var numEffectsRunning:int = 0;
    
    /**
     *  The proxy bitmap has been updated once during a view transition. Further
     *  updates during the transition will not be visible and only serve to slow
     *  the transition's frame rate.
     */    
    private var ignoreProxyUpdatesDuringTransition:Boolean = false;
    
    /**
     *  Some transitions cause components to be reparented temporarily. As an
     *  optimization, we ignore the remove and re-adds that these reparenting
     *  operations cause. However, if this component is removed from the stage
     *  and not re-added during the transition, we need to clean up after the
     *  transition is complete.
     */
    private var removedDuringTransition:Boolean = false;
    
    /**
     *  Because StageText exists outside of the display hierarchy, its visiblity
     *  needs to be calculated as the aggregate visibility of all of its
     *  ancestors.
     */
    private var ancestorsVisible:Boolean;
    private var invalidateAncestorsVisibleFlag:Boolean = true;
    
    /**
     *  If a complete event is pending when we are about to show the StageText,
     *  we set this flag to wait for the complete event before showing it.
     *  Otherwise, the StageText may show then snap to a new location when the
     *  complete event happens.
     */
    private var showOnComplete:Boolean = false;
    
    /**
     *  Ancestors watched for changes in visibility or geometry. Any change in
     *  an ancestor's visibility or position may affect the StageText's 
     *  visibility or position.
     */
    private var watchedAncestors:Vector.<UIComponent> = new Vector.<UIComponent>();
    
    /**
     *  When StageText.visible is changed, the platform text control is shown
     *  immediately. Because of this, when a view is temporarily shown in
     *  preparation for a transition, the StageText may flash. To prevent this,
     *  delay changes to StageText.visible for a frame.
     */
    private var stageTextVisibleChangePending:Boolean = false;
    private var stageTextVisible:Boolean;
    private var viewTransitionRunning:Boolean = false;
    
    /**
     *  @private
     *  This flag is used to track if this text component has already requested
     *  that ViewTransitions be disabled.  This prevents the stage text from
     *  incrementing ViewNavigator's suspend count multiple times.
     */ 
    private var suspendedViewTransitions:Boolean = false;
    
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
     *  @private
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
     *  @private
     */
    override public function get height():Number
    {
        if (!localViewPort)
            return 0;
        
        return localViewPort.height;
    }
    
    /**
     *  @private
     */
    override public function set height(value:Number):void
    {
        super.height = value;
        
        if (value == height)
            return;
        
        if (!localViewPort)
            localViewPort = new Rectangle();
        
        localViewPort.height = Math.max(0, value);
        
        invalidateViewPortFlag = true;
        invalidateProperties();
    }
    
    //----------------------------------
    //  visible
    //----------------------------------
    
    /**
     *  Storage for the visible property.
     */
    private var _visible:Boolean = true;
    
    /**
     *  @private
     */
    override public function get visible():Boolean
    {
        return _visible;
    }
    
    /**
     *  @private
     */
    override public function set visible(value:Boolean):void
    {
        super.visible = value;
        
        if (value == _visible)
            return;
        
        _visible = value;
        invalidateProperties();
    }
    
    //----------------------------------
    //  width
    //----------------------------------
    
    /**
     *  @private
     */
    override public function get width():Number
    {
        if (!localViewPort)
            return 0;
        
        return localViewPort.width;
    }
    
    /**
     *  @private
     */
    override public function set width(value:Number):void
    {
        super.width = value;
        
        if (value == width)
            return;
        
        if (!localViewPort)
            localViewPort = new Rectangle();
        
        localViewPort.width = Math.max(0, value);
        
        invalidateViewPortFlag = true;
        invalidateProperties();
    }
    
    //----------------------------------
    //  x
    //----------------------------------
    
    /**
     *  @private
     */
    override public function get x():Number
    {
        if (!localViewPort)
            return 0;
        
        return localViewPort.x;
    }
    
    /**
     *  @private
     */
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
     *  @private
     */
    override public function get y():Number
    {
        if (!localViewPort)
            return 0;
        
        return localViewPort.y;
    }
    
    /**
     *  @private
     */
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
     *  @productversion Flex 4.6
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
     *  @productversion Flex 4.6
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
     *  @default 0
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.6
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
     *  @productversion Flex 4.6
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
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.6
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
     *  @inheritDoc
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
     *  <p>This value can not be used as the source for data binding.</p>
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.6
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
     *  <p>This value can not be used as the source for data binding.</p>
     *
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.6
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
     *  A string that is the current text in the text field. 
     *  Lines are separated by the carriage return character ('\r', ASCII 13). 
     *  This property contains unformatted text in the text field, without any formatting tags.
     *
     *  <p>If there was a prior selection, it will be preserved. 
     *  If the length of the old text was less than the length of the new text, the selection
     *  will be adjusted so that neither <code>selectionAnchorPosition</code> or
     *  <code>selectionActivePosition</code> is greater than the length of the new text.</p>
     * 
     *  @default ""
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.6
     */
    public function get text():String
    {
        return _text;
    }
    
    public function set text(value:String):void
    {
        // This is to match legacy behavior. Setting text to null really just
        // sets it to the empty string.
        if (value == null)
            value = "";
        
        if (value != _text)
        {
            // Like TextField, preserve the selection when setting text.  This is necessary so that
            // if there is a binding to the text property, the insertion poiint doesn't reset after 
            // every character typed.
            if (stageText != null)
            {
                var anchorIndex:int = stageText.selectionAnchorIndex;
                var activeIndex:int = stageText.selectionActiveIndex;
                stageText.text = value;
                stageText.selectRange(anchorIndex, activeIndex);
            }
            
            _text = value;
            
            dispatchEvent(new TextOperationEvent(TextOperationEvent.CHANGE));
            updateProxyImage();
        }
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
     *  @inheritDoc
     * 
     *  @default "none"
     * 
     *  @see flash.text.AutoCapitalize
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.6
     */
    public function get autoCapitalize():String
    {
        return stageText ? stageText.autoCapitalize : _autoCapitalize;
    }
    
    public function set autoCapitalize(value:String):void
    {
        if (value == "")
            value = AutoCapitalize.NONE;
        
        if (stageText != null)
            stageText.autoCapitalize = value;
        
        _autoCapitalize = value;
    }
    
    //----------------------------------
    //  autoCorrect
    //----------------------------------
    
    /**
     *  Storage for the autoCorrect property.
     */
    private var _autoCorrect:Boolean = true;
    
    /**
     *  @inheritDoc
     * 
     *  @default true
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.6
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
     *  @inheritDoc
     * 
     *  @default "default"
     * 
     *  @see flash.text.ReturnKeyLabel
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.6
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
     *  @inheritDoc
     * 
     *  @default "default"
     * 
     *  @see flash.text.SoftKeyboardType
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.6
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
    
    //----------------------------------
    //  completeEventPending
    //----------------------------------
    
    /**
     *  Storage for the completeEventPending private property.
     */
    private var _completeEventPending:Boolean = false;
    private var completeEventBackstop:Timer = null;
    
    /**
     *  Flag indicating a change has been made to the runtime StageText object 
     *  that requires asynchronous processing before a bitmap may be captured
     *  from it.
     */
    private function get completeEventPending():Boolean
    {
        return _completeEventPending;
    }
    
    private function set completeEventPending(value:Boolean):void
    {
        if (_completeEventPending != value)
        {
            _completeEventPending = value;
            
            if (value)
            {
                completeEventBackstop = new Timer(1000, 1);
                completeEventBackstop.addEventListener(TimerEvent.TIMER, completeEventBackstop_timerHandler);
                completeEventBackstop.start();
            }
            else
            {
                completeEventBackstop.removeEventListener(TimerEvent.TIMER, completeEventBackstop_timerHandler);
                completeEventBackstop = null;
                
                // The suspend/resume of transitions for bitmap capture is to
                // fix framerate issues on Android. While the suspend/resume
                // should work on iOS as well, it isn't necessary. In the spirit
                // of keeping this change as localized as possible, we are
                // limiting transition suspend/resume to Android.
                if (!isDesktop && viewTransitionRunning && isAndroid)
                {
                    ViewNavigator.resumeTransitions();
                    suspendedViewTransitions = false;
                }
            }
        }
        else if (_completeEventPending)
        {
            completeEventBackstop.reset();
            completeEventBackstop.start();
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
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
     *  @private
     */ 
    override public function setFocus():void
    {
        // The proxy bitmap should not be showing and somebody is trying to set
        // focus on us. Make sure the proxy bitmap really is gone and the
        // StageText is visible.
        if (!showProxyImage && !alwaysShowProxyImage)
            commitVisible(true);
        
        // Do not set focus if the StageText is invisible (it has been replaced
        // by a proxy image). This component may be in a form that is lower in
        // z-order than the topmost form and we cannot allow the StageText,
        // which cannot clip, to appear above the topmost form.
        if (effectiveEnabled && stageText != null)
        {
            if (stageText.visible)
                stageText.assignFocus();
            else
                pendingFocusedStageText = stageText;
        }
    }
    
    /**
     *  @private
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
     *  @private
     */
    override public function setActualSize(w:Number, h:Number):void
    {
        super.setActualSize(w, h);
        
        if (!localViewPort)
            localViewPort = new Rectangle();
        
        localViewPort.width = Math.max(0, w);
        localViewPort.height = Math.max(0, h);
        
        invalidateViewPortFlag = true;
        invalidateProperties();
    }
    
    /**
     *  @private
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
    
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        // DesignView may call validateNow before the path which normally
        // creates the proxy bitmap. In that case, make sure the proxy bitmap
        // gets created here.
        var proxyCreated:Boolean = false;
        if (alwaysShowProxyImage && !showProxyImage)
        {
            createProxyImage();
            proxyCreated = true;
        }
        
        if (stageText != null)
            stageText.editable = _editable && effectiveEnabled;
        
        if (!proxyCreated)
            commitVisible();
        
        if (invalidateViewPortFlag)
        {
            updateViewPort();
            invalidateViewPortFlag = false;
            
            // If this is a new StageText created while a popup is already open,
            // a proxy image needs to be created for it.
            updateProxyImageForTopmostForm();
        }
        
        if (!proxyCreated && showProxyImage)
            updateProxyImage();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.6
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
            
            updateProxyImage();
        }
    }
    
    /**
     *  Calculate whether the StageText needs to be shown or hidden. If any
     *  ancestor of this StyleableStageText is hidden, the StageText itself must
     *  be hidden. This will not happen automatically because the StageText is
     *  not part of the display hierarchy.
     */
    private function commitVisible(immediate:Boolean = false):void
    {
        if (showProxyImage)
        {
            if (proxyImage != null)
            {
                proxyImage.x = 0;
                proxyImage.y = 0;
                
                if (stageText != null)
                {
                    stageText.visible = false;
                    stageTextVisibleChangePending = false;
                    removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
                }
            }
        }
        else
        {
            if (stageText != null)
            {
                var calculatedVisible:Boolean = _visible && calcAncestorsVisible();
                
                if (completeEventPending && calculatedVisible)
                {
                    showOnComplete = true;
                }
                else
                {
                    if (immediate)
                    {
                        stageText.visible = calculatedVisible;
                        
                        // The focused stageText may have been replaced by a bitmap during
                        // an animation. When restoring its visibility, restore its focus as
                        // well if the soft keyboard is open. (If the soft keyboard is not
                        // open, do not restore focus because doing so will force the soft
                        // keyboard to open.)
                        if (stageText.visible)
                        {
                            if (stageText == focusedStageText && stage.softKeyboardRect.height > 0 ||
                                stageText == pendingFocusedStageText)
                            {
                                stageText.assignFocus();
                            }
                        }
                        
                        // Do not remove the proxy bitmap until after stageText has been
                        // made visible to reduce flicker.
                        disposeProxyImage();
                        stageTextVisibleChangePending = false;
                        removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
                    }
                    else
                    {
                        stageTextVisible = calculatedVisible;
                        stageTextVisibleChangePending = true;
                        addEventListener(Event.ENTER_FRAME, enterFrameHandler);
                    }
                }
            }
        }
    }
    
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.6
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
        
        // TODO: scrollToRange so the insertion point is visible
        
        dispatchEvent(new TextOperationEvent(TextOperationEvent.CHANGE));
        
        updateProxyImage();
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
     *  <p>On iOS, for non multiline StyleableStageText objects, this function
     *  is not supported and does nothing.</p>
     * 
     *  <p>For some devices or operating systems, the selection may only be
     *  visible when the StageText object has focus.</p>
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.6
     */ 
    public function selectAll():void
    {
        if (stageText != null && stageText.text != null)
        {
            stageText.selectRange(0, stageText.text.length);
            updateProxyImage();
        }
    }
    
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.6
     */
    public function selectRange(anchorIndex:int, activeIndex:int):void
    {
        if (stageText != null)
        {
            stageText.selectRange(anchorIndex, activeIndex);
            updateProxyImage();
        }
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
            
            updateProxyImage();
        }
    }
    
    /**
     *  If a StageText is visible, this will capture a bitmap copy of what it is
     *  displaying. This includes any text visible in the StageText and may
     *  include the text insertion cursor if it is visible at the time of the
     *  call.
     */
    mx_internal function captureBitmapData():BitmapData
    {
        if (!stageText || !stageText.stage || !localViewPort || 
            localViewPort.width == 0 || localViewPort.height == 0)
            return null; // The StageText is invisible.
        
        if (stageText.viewPort.width == 0 || stageText.viewPort.height == 0)
            updateViewPort(); // The StageText viewport is stale.
        
        // Make sure any pending style changes get saved before replacing
        // the StageText with a bitmap
        commitStyles();
        
        var bitmap:BitmapData = new BitmapData(stageText.viewPort.width, 
            stageText.viewPort.height, true, 0x00FFFFFF);
        
        stageText.drawViewPortToBitmapData(bitmap);
        
        return bitmap;
    }
    
    private function beginAnimation():void
    {
        // The first effect affecting the StageText that starts causes us to
        // replace the StageText with a bitmap.
        if (numEffectsRunning++ == 0)
        {
            // Unlike other places where bitmap swapping is necessary (popups),
            // effects may run immediately after a text component is created.
            // So, we need to make sure anything that could affect the size or
            // contents of the bitmap (viewPort and styles) are saved to the
            // StageText before creating a new bitmap. Effects may play too
            // quickly to rely on subsequent updates to correct the bitmap.
            if (invalidateViewPortFlag)
            {
                // Update the viewport now so a subsequent "complete" event will
                // allow us to get a bitmap of the correct size
                updateViewPort();
                invalidateViewPortFlag = false
            }
            
            createProxyImage();
        }
    }
    
    /**
     *  Generate an image that represents this StageText and replace the live
     *  StageText display with that image. Used for display while effects are
     *  playing.
     */
    private function createProxyImage():void
    {
        if (!showProxyImage && proxyImage != null)
        {
            // In this case, we have just received an event that causes us to
            // dispose the proxy image, but havent disposed it yet 
            // (commitProperties hasn't been called yet). So, we don't need to
            // create a new text image. Just update the one we have and update
            // our state variables.
            showProxyImage = true;
            updateProxyImage();
            commitVisible(true);
        } 
        else if (proxyImage == null)
        {
            var imageData:BitmapData = captureBitmapData();
            
            if (imageData)
            {
                if (densityScale == 1)
                {
                    proxyImage = new Bitmap(imageData);
                }
                else
                {
                    proxyImage = new Bitmap(imageData, PixelSnapping.NEVER, true);
                    proxyImage.scaleX = 1.0 / densityScale;
                    proxyImage.scaleY = 1.0 / densityScale;
                }
                
                // This order seems backwards, but it isn't. Setting the
                // visibility of a StageText does not happen immediately. To
                // reduce the amount of time where both the StageText and the
                // bitmap are visible, we tell the StageText to hide before we
                // show the proxy bitmap.
                showProxyImage = true;
                commitVisible();
                addChild(proxyImage);
            }
        }
    }
    
    private function endAnimation():void
    {
        // The last effect affecting the StageText to end causes us to put
        // the live StageText back and remove the bitmap.
        // If alwaysShowProxyImage is set, don't dispose the image.
        if (--numEffectsRunning == 0 && !alwaysShowProxyImage)
        {
            if (removedDuringTransition)
            {
                removedFromStageHandler(null);
            }
            else
            {
                updateViewPort();
                
                // The effect may have played while a popup is open. If so, we
                // need to make sure the proxy image stays.
                if (awm)
                    updateProxyImageForTopmostForm();
                else
                    disposeProxyImageLater();
            }
        }
    }
    
    /**
     *  Iterate through the forms tracked by ActiveWindowManager and return the
     *  one that is highest in z-order excluding the passed-in form.
     */
    private function findTopmostForm(excludeForm:Object):Object
    {
        if (!awm)
            return null;
        
        var form:Object = awm.form;
        var formIndex:int = getFormIndex(form);
        
        for each (var otherForm:Object in awm.forms)
        {
            var otherIndex:int = getFormIndex(otherForm);
            
            if (otherIndex > formIndex && otherForm != excludeForm)
            {
                form = otherForm;
                formIndex = otherIndex;
            }
        }
        
        return form;
    }
    
    /**
     *  Determine an index for the given form that may be used to determine the
     *  relative z-orders of forms.
     */
    private function getFormIndex(form:Object):int
    {
        return form is DisplayObject ?
            systemManager.rawChildren.getChildIndex(form as DisplayObject) :
            -1;
    }
    
    private function getGlobalViewPort():Rectangle
    {
        // We calculate the parent's concatenated matrix to deal with
        // issues in the runtime where the concatenated matrix of the
        // parent is out of sync.  See SDK-31538.
        var m:Matrix = MatrixUtil.getConcatenatedMatrix(parent, stage);
        var globalTopLeft:Point = m.transformPoint(localViewPort.topLeft);
        
        // Transform the bottom-right corner of the local rect
        // instead of setting width/height to account for any
        // transformations applied to ancestor objects.
        var globalBottomRight:Point = m.transformPoint(localViewPort.bottomRight);
        var globalRect:Rectangle = new Rectangle();
        
        // StageText can't deal with upside-down or mirrored rectangles
        // or non-integer values. Fix those here.
        globalRect.x = Math.floor(Math.min(globalTopLeft.x, globalBottomRight.x));
        globalRect.y = Math.floor(Math.min(globalTopLeft.y, globalBottomRight.y));
        globalRect.width = Math.ceil(Math.abs(globalBottomRight.x - globalTopLeft.x));
        globalRect.height = Math.ceil(Math.abs(globalBottomRight.y - globalTopLeft.y));
        
        return globalRect;
    }
    
    private function hasOverlappingForm():Boolean
    {
        if (!localViewPort || !parent || !stageText || !awm)
            return false;
        
        // Prevent the StageText from becoming interactive if there is a modal
        // window open by assuming that the modal window overlaps everything.
        // If the StageText is part of the topmost popup, we won't get here, so
        // those StageTexts will remain interactive (as designed).
        // If a StageText is part of some other popup or the application root 
        // and there is at least one modal open, the StageText will be replaced
        // by a bitmap.
        // This is the best we can do as far as modal popups is concerned. The
        // association between popup and modality is private to PopUpManager, so
        // all we can do is determine if there are any modal windows open. We
        // can't associate a given modal window with a given popup.
        // This means that, if somebody opens a modal popup and then opens a
        // modeless popup on top of that, only the StageTexts in the topmost
        // of the two popups will remain interactive.
        if (awm.numModalWindows > 0)
            return true;
        
        var globalRect:Rectangle = getGlobalViewPort();
        var result:Boolean = false;
        
        for each (var otherForm:Object in awm.forms)
        {
            var otherFormDisplayObj:DisplayObject = otherForm as DisplayObject;
            
            if (otherFormDisplayObj && 
                (!otherForm.hasOwnProperty("focusManager") || otherForm.focusManager != focusManager))
            {
                var formGlobalRect:Rectangle = otherFormDisplayObj is UIComponent ? 
                    UIComponent(otherFormDisplayObj).getVisibleRect() : otherFormDisplayObj.getBounds(stage);
                
                if (formGlobalRect.intersects(globalRect))
                {
                    result = true;
                    break;
                }
            }
        }
        
        return result;
    }
    
    /**
     *  Determine whether the given form is an application. This is the same
     *  check as is used by ActiveWindowManager.
     */
    private function isFormApplication(form:DisplayObject):Boolean
    {
        return systemManager.document is IRawChildrenContainer ? 
            IRawChildrenContainer(systemManager.document).rawChildren.contains(form) :
            systemManager.document.contains(form);
    }
    
    /**
     *  Determine whether the given form is owned by an ancestor of this
     *  StyleableStageText. This is used by bitmap swapping for popups. If a
     *  text component or ancestor of one owns the popup, the text component
     *  should not be swapped for a bitmap to support workflows where performing
     *  an action within the text component displays the callout or determines
     *  the callout's content.
     */
    private function isFormOwnedByAncestor(form:Object):Boolean
    {
        var result:Boolean = false;
        
        if (form is UIComponent)
        {
            var formComponent:UIComponent = form as UIComponent;
            var formOwner:DisplayObjectContainer = formComponent.owner;
            
            result = formOwner != null && formOwner.contains(this);
        }
        
        return result;
    }
    
    /**
     *  Replace the existing proxy image representing this StageText with a new
     *  one. Call this whenever the StageText's properties, contents, or
     *  geometry changes. This does nothing if there is no proxy image, so it is
     *  safe to call updateProxyImage even if the state of the proxy image is
     *  unknown.
     */
    private function updateProxyImage():void
    {
        if (stageText == null || completeEventPending)
            return;
        
        if (ignoreProxyUpdatesDuringTransition)
            return;
        
        if (proxyImage != null)
        {
            var newImageData:BitmapData = captureBitmapData();
            
            if (newImageData)
            {
                var oldImageData:BitmapData = proxyImage.bitmapData;
                
                proxyImage.bitmapData = newImageData;
                oldImageData.dispose();
            }
        }
    }
    
    private function disposeProxyImage():void
    {
        if (proxyImage != null)
        {
            var fade:Fade = new Fade(proxyImage);
            
            fade.alphaTo = 0;
            fade.duration = 125;
            
            fade.addEventListener(EffectEvent.EFFECT_END,
                function (event:EffectEvent):void
                {
                    if (proxyImage)
                    {
                        removeChild(proxyImage);
                        proxyImage.bitmapData.dispose();
                        proxyImage = null;
                    }
                }, false, 0, true);

            fade.play();
        }
    }
    
    /**
     *  Destroy any previously created proxy image and restore the visibility of
     *  the StageText display that the proxy image had represented.
     */
    private function disposeProxyImageLater():void
    {
        if (showProxyImage)
        {
            showProxyImage = false;
            invalidateProperties();
        }
    }
    
    /**
     *  If this component is part of the form that is active, remove the proxy
     *  bitmap (if present) and show the StageText. Otherwise, create or update
     *  the proxy bitmap and hide the StageText.
     */
    private function updateProxyImageForForm(form:Object):void
    {
        // If we are always showing proxy bitmaps, then there is nothing to do
        // here.
        if (alwaysShowProxyImage)
            return;
        
        if (form && form.hasOwnProperty("focusManager"))
        {
            if (form.focusManager != focusManager 
                && (!isFormOwnedByAncestor(form) || hasOverlappingForm()))
            {
                createProxyImage();
            }
            else
            {
                disposeProxyImageLater();
            }
        }
    }
    
    /**
     *  Find the topmost form in z-order and show the StageText if this is a
     *  child of that form. Otherwise, create or update the proxy bitmap and
     *  hide the StageText. When searching for the topmost form, optionally
     *  exclude a form that is known to be hiding or closing.
     */
    private function updateProxyImageForTopmostForm(excludeForm:Object = null):void
    {
        // If there is no active window manager or we are always showing proxy
        // bitmaps, then there is nothing to do here.
        if (!awm || alwaysShowProxyImage)
            return;
        
        var form:Object = awm.form;
        
        if (!(form is DisplayObject) || isFormApplication(form as DisplayObject))
            form = findTopmostForm(excludeForm);
        
        updateProxyImageForForm(form);
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
                var globalRect:Rectangle = getGlobalViewPort();

                if (!globalRect.equals(stageText.viewPort))
                {
                    if (stageText.viewPort.width != globalRect.width || stageText.viewPort.height != globalRect.height)
                        completeEventPending = true;

                    stageText.viewPort = globalRect;
                }
                
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
    
    /**
     *  Returns true if every ancestor of this object is visible.
     */
    private function calcAncestorsVisible():Boolean
    {
        if (invalidateAncestorsVisibleFlag)
        {
            var result:Boolean = visible;
            var ancestor:DisplayObject = parent;
            
            while (result && ancestor)
            {
                result = ancestor.visible;
                ancestor = ancestor.parent;
            }
            
            ancestorsVisible = result;
            invalidateAncestorsVisibleFlag = false;
        }
        
        return ancestorsVisible;
    }
    
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
                ancestor.removeEventListener(FlexEvent.CREATION_COMPLETE, ancestor_creationCompleteHandler);
                ancestor.removeEventListener(MoveEvent.MOVE, ancestor_moveHandler);
                ancestor.removeEventListener(ResizeEvent.RESIZE, ancestor_resizeHandler);
                ancestor.removeEventListener(FlexEvent.SHOW, ancestor_showHandler);
                ancestor.removeEventListener(FlexEvent.HIDE, ancestor_hideHandler);
                ancestor.removeEventListener(PopUpEvent.CLOSE, ancestor_closeHandler);
                ancestor.removeEventListener(PopUpEvent.OPEN, ancestor_openHandler);
            }
        }
        
        var foundUninitialized:Boolean = false;
        for (i = newWatchedAncestors.length - 1; i >= 0; i--)
        {
            var newAncestor:UIComponent = newWatchedAncestors[i];
            
            if (watchedAncestors.indexOf(newAncestor) == -1)
            {
                newAncestor.addEventListener(MoveEvent.MOVE, ancestor_moveHandler, false, 0, true);
                newAncestor.addEventListener(ResizeEvent.RESIZE, ancestor_resizeHandler, false, 0, true);
                newAncestor.addEventListener(FlexEvent.SHOW, ancestor_showHandler, false, 0, true);
                newAncestor.addEventListener(FlexEvent.HIDE, ancestor_hideHandler, false, 0, true);
                
                if (newAncestor.isPopUp)
                {
                    newAncestor.addEventListener(PopUpEvent.CLOSE, ancestor_closeHandler, false, 0, true);
                    newAncestor.addEventListener(PopUpEvent.OPEN, ancestor_openHandler, false, 0, true);
                }
                
                if (!newAncestor.initialized && !foundUninitialized)
                {
                    foundUninitialized = true;
                    newAncestor.addEventListener(FlexEvent.CREATION_COMPLETE, ancestor_creationCompleteHandler, false, 0, true);
                }
            }
        }
        
        watchedAncestors = newWatchedAncestors;
    }
    
    /**
     *  For each form that the ActiveWindowManager knows about, add listeners
     *  for changes to geometry. These listeners are necessary because changes
     *  to the geometry of a form may cause popups to start or stop overlapping
     *  StageTexts. When that happens, StageTexts need to be replaced with proxy
     *  bitmaps or vice-versa.
     */
    private function updateWatchedForms(excludeForm:Object = null):void
    {
        if (awm)
        {
            for each (var form:Object in awm.forms)
            {
                if (form is EventDispatcher)
                {
                    var formDispatcher:EventDispatcher = form as EventDispatcher;
                    
                    // Remove event listeners in case we've already seen this form before.
                    formDispatcher.removeEventListener(MoveEvent.MOVE, form_moveHandler);
                    formDispatcher.removeEventListener(ResizeEvent.RESIZE, form_resizeHandler);
                    
                    if (form != excludeForm)
                    {
                        // Use weak references so we don't prevent the form from being garbage collected.
                        formDispatcher.addEventListener(MoveEvent.MOVE, form_moveHandler, false, 0, true);
                        formDispatcher.addEventListener(ResizeEvent.RESIZE, form_resizeHandler, false, 0, true);
                    }
                }
            }
        }
    }
    
    /**
     *  Stop watching for visibility and geometry events on all ancestors. Call
     *  this when disposing the StageText.
     */
    private function clearWatchedAncestors():void
    {
        while (watchedAncestors.length > 0)
        {
            var ancestor:UIComponent = watchedAncestors.pop();
            
            ancestor.removeEventListener(FlexEvent.CREATION_COMPLETE, ancestor_creationCompleteHandler);
            ancestor.removeEventListener(MoveEvent.MOVE, ancestor_moveHandler);
            ancestor.removeEventListener(ResizeEvent.RESIZE, ancestor_resizeHandler);
            ancestor.removeEventListener(FlexEvent.SHOW, ancestor_showHandler);
            ancestor.removeEventListener(FlexEvent.HIDE, ancestor_hideHandler);
            ancestor.removeEventListener(PopUpEvent.CLOSE, ancestor_closeHandler);
            ancestor.removeEventListener(PopUpEvent.OPEN, ancestor_openHandler);
        }
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
            
            // Restore the text and the selection.
            stageText.text = _text;
            stageText.selectRange(savedSelectionAnchorIndex, savedSelectionActiveIndex);
            savedSelectionAnchorIndex = 0;
            savedSelectionActiveIndex = 0;
            
            stageText.displayAsPassword = _displayAsPassword;
            stageText.maxChars = _maxChars;
            
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
            invalidateAncestorsVisibleFlag = true;
            invalidateProperties();
        }
    }
    
    mx_internal function getStageText(create:Boolean = false):StageText
    {
        if (stageText == null && create)
            stageText = StageTextPool.acquireStageText(this);
        
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
     */
    override protected function focusInHandler(event:FocusEvent):void
    {
        //  Forward the focus event to the StageText. The focusedStageText flag
        //  is modified by the StageText's focus event handlers, not this one.
        if (stageText != null && focusedStageText != stageText && effectiveEnabled)
            stageText.assignFocus();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    private function ancestor_closeHandler(event:PopUpEvent):void
    {
        ancestorsVisible = false;
        invalidateAncestorsVisibleFlag = false;
        invalidateProperties();
    }
    
    private function ancestor_creationCompleteHandler(event:FlexEvent):void
    {
        if (!invalidateAncestorsVisibleFlag)
        {
            invalidateAncestorsVisibleFlag = true;
            invalidateProperties();
        }
    }
    
    private function ancestor_hideHandler(event:FlexEvent):void
    {
        // Shortcut: If any ancestor hid, the StageText must hide. No need to
        // recalculate visibility.
        ancestorsVisible = false;
        invalidateAncestorsVisibleFlag = false;
        invalidateProperties();
    }
    
    private function ancestor_moveHandler(event:MoveEvent):void
    {
        // Any change in ancestor geometry may affect the StageText's geometry.
        invalidateViewPortFlag = true;
        invalidateProperties();
    }
    
    private function ancestor_openHandler(event:PopUpEvent):void
    {
        invalidateAncestorsVisibleFlag = true;
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
        invalidateAncestorsVisibleFlag = true;
        invalidateProperties();
    }
    
    private function ancestor_viewChangeStartHandler(event:Event):void
    {
        viewTransitionRunning = true;
    }
    
    private function ancestor_viewChangeCompleteHandler(event:Event):void
    {
        viewTransitionRunning = false;
        
        if (stageTextVisibleChangePending)
            enterFrameHandler(null);
    }
    
    private function awm_activatedFormHandler(event:DynamicEvent):void
    {
        updateWatchedForms();
        updateProxyImageForTopmostForm();
    }
    
    private function awm_deactivatedFormHandler(event:DynamicEvent):void
    {
        updateWatchedForms();
        
        // When the ActiveWindowManager dispatches the deactivatedForm event,
        // its internal list of forms has not been updated yet. So, determining
        // the topmost form from that list will fail and find the old topmost
        // form (the one that is going away). Always assume that the form passed
        // as the event property will be the new topmost form.
        var form:Object = event.hasOwnProperty("form") ? event.form : null;
        updateProxyImageForForm(form);
    }
    
    private function awm_removeFocusManagerHandler(event:FocusEvent):void
    {
        // When a popup is removed from the popup manager, its focus manager
        // gets removed from the ActiveWindowManager. This happens even in cases
        // where the AWM will not send a deactivatedForm event for that popup.
        // This happens before the popup is removed from the AWM's forms array,
        // though, so the popup whose focus manager is getting removed needs to
        // be explicitly skipped when determining the new topmost form.
        var removedForm:Object = event.relatedObject;
        updateWatchedForms(removedForm);
        updateProxyImageForTopmostForm(removedForm);
    }
    
    private function completeEventBackstop_timerHandler(event:TimerEvent):void
    {
        completeEventPending = false;

        if (showOnComplete)
        {
            commitVisible(true);
            showOnComplete = false;
        }
    }
    
    private function form_moveHandler(event:MoveEvent):void
    {
        updateProxyImageForTopmostForm();
    }
    
    private function form_resizeHandler(event:ResizeEvent):void
    {
        updateProxyImageForTopmostForm();
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
    
    private function stageText_completeHandler(event:Event):void
    {
        // Since Android devices update their text asynchronously,
        // there may be situations where a complete event is received
        // during a transition.  If one is received, we reset the
        // ignoreProxyUpdatesDuringTransition flag so that updateProxyImage()
        // method recreates the bitmap representing the text.
        if (!completeEventPending && !isDesktop && isAndroid && viewTransitionRunning)
            ignoreProxyUpdatesDuringTransition = false;
            
        completeEventPending = false;
        updateProxyImage();
        
        if (!isDesktop && viewTransitionRunning && isAndroid)
            ignoreProxyUpdatesDuringTransition = true;
        
        if (showOnComplete)
        {
            commitVisible(true);
            showOnComplete = false;
        }
    }
    
    private function stageText_focusInHandler(event:FocusEvent):void
    {
        focusedStageText = stageText;
        pendingFocusedStageText = null;
        
        // Focus events are documented as bubbling. However, all events coming
        // from StageText are set to not bubble. So we need to create an
        // appropriate bubbling event here.
        dispatchEvent(new FocusEvent(event.type, true, event.cancelable, 
            event.relatedObject, event.shiftKey, event.keyCode, event.direction));
    }
    
    private function stageText_focusOutHandler(event:FocusEvent):void
    {
        // This is to fix a race condition in PopUpManager and 
        // ActiveWindowManager. When a form (popup) is removed from
        // ActiveWindowManager, it reactivates the FocusManager of the previous
        // active form. That causes that FocusManager to set focus back to the
        // last component to have focus. In the race condition case, that
        // component has a focusIn handler that opens the popup that we were
        // closing to start this whole chain of events. Because the popup is
        // opening while it is in the middle of closing, it gets into an
        // inconsistent state. This race condition doesn't happen with non-
        // StageText-based text components because FocusManager normally
        // prevents focus from going to nothing (thereby preventing focus from
        // leaving the text component to begin with). StageText, however, does
        // not dispatch the necessary cancellable focus change events to allow
        // FocusManager to do this. So, to prevent these such race conditions
        // that the rest of the framework isn't prepared for, we must prevent
        // FocusManager from immediately setting focus back to this StageText.
        if (focusedStageText == stageText)
        {
            focusedStageText = null;
            
            if (focusManager is FocusManager)
            {
                var fm:FocusManager = focusManager as FocusManager;
                var lastFocus:Object = fm.lastFocus as Object;
                
                if (lastFocus && lastFocus.hasOwnProperty("textDisplay") && lastFocus.textDisplay == this)
                    fm.lastFocus = null;
            }
        }
        
        // Focus events are documented as bubbling. However, all events coming
        // from StageText are set to not bubble. So we need to create an
        // appropriate bubbling event here.
        dispatchEvent(new FocusEvent(event.type, true, event.cancelable, 
            event.relatedObject, event.shiftKey, event.keyCode, event.direction));
    }
    
    private function stageText_keyDownHandler(event:KeyboardEvent):void
    {
        // Taps on the Enter key on soft keyboards may send us the Next keycode
        if ((event.keyCode == Keyboard.ENTER || event.keyCode == Keyboard.NEXT)
            && !_multiline)
        {
            dispatchEvent(new FlexEvent(FlexEvent.ENTER));
        }
        
        // Keyboard events are documented as bubbling. However, all events
        // coming from StageText are set to not bubble. So we need to create an
        // appropriate bubbling event here.
        dispatchEvent(new KeyboardEvent(event.type, true, event.cancelable, 
            event.charCode, event.keyCode, event.keyLocation, event.ctrlKey, 
            event.altKey, event.shiftKey, event.controlKey, event.commandKey));
        
        if ((event.keyCode == Keyboard.ENTER || event.keyCode == Keyboard.NEXT)
            && !_multiline && !isDesktop)
        {
            event.preventDefault();
        }
    }
    
    private function stageText_keyUpHandler(event:KeyboardEvent):void
    {
        // Keyboard events are documented as bubbling. However, all events
        // coming from StageText are set to not bubble. So we need to create an
        // appropriate bubbling event here.
        dispatchEvent(new KeyboardEvent(event.type, true, event.cancelable, 
            event.charCode, event.keyCode, event.keyLocation, event.ctrlKey, 
            event.altKey, event.shiftKey, event.controlKey, event.commandKey));
        
        if ((event.keyCode == Keyboard.ENTER || event.keyCode == Keyboard.NEXT)
            && !_multiline && !isDesktop)
        {
            event.preventDefault();
        }
    }
    
    private function stageText_softKeyboardHandler(event:SoftKeyboardEvent):void
    {
        dispatchEvent(new SoftKeyboardEvent(event.type, 
            true, event.cancelable, this, event.triggerType));
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
            beginAnimation();
    }
    
    private function stage_effectEndHandler(event:EffectEvent):void
    {
        if (eventTargetsAncestor(event))
            endAnimation();
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
    
    private function viewTransition_prepareHandler(event:Event):void
    {
        // When a view transition runs, the first event that we see is
        // "viewTransitionPrepare", which is dispatched by ViewNavigator.
        // This event gives StyleableStageText a chance to suspend the
        // transition. Suspension of the transition is necessary if the 
        // StageText is not ready to give us a bitmap. Otherwise, by the time
        // the StageText is ready to give us a bitmap, capturing one would
        // case a noticeable stutter during the transition. If we suspend the
        // transition here, the next "complete" event we receive from the
        // StageText will cause us to resume transitions.
        
        // The suspend/resume of transitions for bitmap capture is to
        // fix framerate issues on Android. While the suspend/resume
        // should work on iOS as well, it isn't necessary. In the spirit
        // of keeping this change as localized as possible, we are
        // limiting transition suspend/resume to Android.
        if (!isDesktop && isAndroid)
        {
            if (completeEventPending && !suspendedViewTransitions)
            {
                ViewNavigator.suspendTransitions();
                suspendedViewTransitions = true;
            }
            else
                ignoreProxyUpdatesDuringTransition = true;
        }
        
        viewTransitionRunning = true;
        beginAnimation();
    }
    
    private function stage_transitionEndHandler(event:FlexEvent):void
    {
        // This component may have been created during a view transition. In
        // that case, it will not have received a call to its prepareHandler and
        // allowing endAnimation to run would get its running animation counter
        // into a bad state.
        if (viewTransitionRunning)
        {
            viewTransitionRunning = false;
            endAnimation();
        }

        ignoreProxyUpdatesDuringTransition = false;

        // If stageTextVisibleChangePending is true, a visibility change which
        // we ignored happened during the transition. Apply that visibility
        // change now.
        if (stageTextVisibleChangePending)
            enterFrameHandler(null);
    }
    
    private function addHierarchyListeners():void
    {
        if (stageText == null)
            return;
        
        updateWatchedAncestors();
        
        stageText.stage.addEventListener(Event.ADDED, stage_hierarchyChangedHandler, false, 0, true);
        stageText.stage.addEventListener(Event.REMOVED, stage_hierarchyChangedHandler, false, 0, true);
    }
    
    private function removeHierarchyListeners():void
    {
        if (stageText == null)
            return;
        
        stageText.stage.removeEventListener(Event.ADDED, stage_hierarchyChangedHandler);
        stageText.stage.removeEventListener(Event.REMOVED, stage_hierarchyChangedHandler);
        
        clearWatchedAncestors();
    }
    
    private function addedToStageHandler(event:Event):void
    {
        if (viewTransitionRunning)
        {
            removedDuringTransition = false;
            return;
        }
        
        var needsRestore:Boolean = false;
        
        if (!awm)
            awm = ActiveWindowManager(systemManager.getImplementation("mx.managers::IActiveWindowManager"));
        
        if (awm)
        {
            awm.addEventListener("activatedForm", awm_activatedFormHandler, false, 0, true);
            awm.addEventListener("deactivatedForm", awm_deactivatedFormHandler, false, 0, true);
            awm.addEventListener("removeFocusManager", awm_removeFocusManagerHandler, false, 0, true);
        }
        
        if (stageText == null)
        {
            needsRestore = !StageTextPool.hasCachedStageText(this);
            getStageText(true);
        }
        
        // Don't let the StageText show up until we've calculated its correct
        // visibility.
        stageText.visible = false;
        // The "complete" handler must be registered before changes to the stage
        // or viewPort. StageText on iOS dispatches complete events during the
        // setting of these properties, unlike Android which does so some time
        // afterward.
        stageText.addEventListener(Event.COMPLETE, stageText_completeHandler);
        
        stageText.stage = stage;
        // Setting stageText.stage requires a complete event for bitmap swapping
        completeEventPending = true;
        
        stageText.stage.addEventListener(EffectEvent.EFFECT_START, stage_effectStartHandler, true, 0, true);
        stageText.stage.addEventListener(EffectEvent.EFFECT_END, stage_effectEndHandler, true, 0, true);
        stageText.stage.addEventListener(FlexEvent.TRANSITION_END, stage_transitionEndHandler, false, 0, true);
        stageText.stage.addEventListener("viewTransitionPrepare", viewTransition_prepareHandler, false, 0, true);
        
        stageText.stage.addEventListener("enabledChanged", stage_enabledChangedHandler, true, 0, true);
        
        addHierarchyListeners();
        
        if (needsRestore)
        {
            restoreStageText();
        }
        else if (savedSelectionAnchorIndex > 0 || savedSelectionActiveIndex > 0)
        {
            // Even if the StageText has been retrieved from the cache, its
            // selection is not preserved. Restore the selection if necessary.
            if (savedSelectionAnchorIndex <= _text.length && savedSelectionActiveIndex <= _text.length)
                stageText.selectRange(savedSelectionAnchorIndex, savedSelectionActiveIndex);
            savedSelectionAnchorIndex = 0;
            savedSelectionActiveIndex = 0;
        }
        
        if (deferredViewPortUpdate)
            updateViewPort();
        
        registerStageTextListeners();
        
        if (alwaysShowProxyImage)
            createProxyImage();
        
        invalidateAncestorsVisibleFlag = true;
        invalidateEffectiveEnabledFlag = true;
        invalidateProperties();
    }
    
    private function enterFrameHandler(event:Event):void
    {
        removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
        
        // If a transition is running, delay pending changes to the visibility
        // of the StageText until the transition is complete.
        if (!viewTransitionRunning && stageTextVisibleChangePending)
        {
            stageText.visible = stageTextVisible;
            
            // The focused stageText may have been replaced by a bitmap during
            // an animation. When restoring its visibility, restore its focus as
            // well if the soft keyboard is open. (If the soft keyboard is not
            // open, do not restore focus because doing so will force the soft
            // keyboard to open.)
            if (stageTextVisible)
            {
                if (stageText == focusedStageText && stage.softKeyboardRect.height > 0 ||
                    stageText == pendingFocusedStageText)
                {
                    stageText.assignFocus();
                }
            }
            
            // Do not remove the proxy bitmap until after stageText has been
            // made visible to reduce flicker.
            disposeProxyImage();
            stageTextVisibleChangePending = false;
        }
    }
    
    private function removedFromStageHandler(event:Event):void
    {
        if (viewTransitionRunning)
        {
            removedDuringTransition = true;
            return;
        }
        
        if (awm)
        {
            awm.removeEventListener("activatedForm", awm_activatedFormHandler);
            awm.removeEventListener("deactivatedForm", awm_deactivatedFormHandler);
            awm.removeEventListener("removeFocusManager", awm_removeFocusManagerHandler);
        }
        
        if (stageText == null)
            return;
        
        // Text is saved in _text.  Also need to save the selection so it can be restored.
        savedSelectionAnchorIndex = stageText.selectionAnchorIndex;
        savedSelectionActiveIndex = stageText.selectionActiveIndex;
        
        stageText.stage.removeEventListener(EffectEvent.EFFECT_START, stage_effectStartHandler, true);
        stageText.stage.removeEventListener(EffectEvent.EFFECT_END, stage_effectEndHandler, true);
        stageText.stage.removeEventListener(FlexEvent.TRANSITION_END, stage_transitionEndHandler);
        stageText.stage.removeEventListener("viewTransitionPrepare", viewTransition_prepareHandler);
        
        stageText.stage.removeEventListener("enabledChanged", stage_enabledChangedHandler, true);
        
        removeHierarchyListeners();
        
        stageText.stage = null;
        
        stageText.removeEventListener(Event.CHANGE, stageText_changeHandler);
        stageText.removeEventListener(Event.COMPLETE, stageText_completeHandler);
        stageText.removeEventListener(FocusEvent.FOCUS_IN, stageText_focusInHandler);
        stageText.removeEventListener(FocusEvent.FOCUS_OUT, stageText_focusOutHandler);
        stageText.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, stageText_softKeyboardHandler);
        stageText.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, stageText_softKeyboardHandler);
        stageText.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, stageText_softKeyboardHandler);
        stageText.removeEventListener(KeyboardEvent.KEY_DOWN, stageText_keyDownHandler);
        stageText.removeEventListener(KeyboardEvent.KEY_UP, stageText_keyUpHandler);
        
        StageTextPool.releaseStageText(this, stageText);
        stageText = null;
        
        removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
        stageTextVisibleChangePending = false;
        
        // This component may be removed from the stage by a Fade effect. In
        // that case, we will not receive the EFFECT_END event, but should still
        // reset the effect running state and remove any bitmap representation
        // of the StageText.
        showProxyImage = false;
        if (proxyImage != null)
        {
            // If a textImage exists, we need to get rid of it to keep it in
            // sync with our proxy image state. disposeProxyImage does not do
            // this. It only sets a flag and invalidates properties.
            removeChild(proxyImage);
            proxyImage.bitmapData.dispose();
            proxyImage = null;
        }
        numEffectsRunning = 0;
        
        removedDuringTransition = false;
    }
}
}

import flash.events.TimerEvent;
import flash.text.StageText;
import flash.text.StageTextInitOptions;
import flash.utils.Dictionary;
import flash.utils.Timer;

import spark.components.supportClasses.StyleableStageText;

class StageTextPool
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    private static const poolReserve:Number = 5;
    private static const poolTimerInterval:Number = 10000;
    
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    private static var map_StyleableStageText_to_StageText:Dictionary = new Dictionary(true);
    private static var map_StageText_to_StyleableStageText:Dictionary = new Dictionary(true);
    
    private static var multilinePool:Vector.<StageText> = new Vector.<StageText>();
    private static var multilinePoolTimer:Timer;
    
    private static var singleLinePool:Vector.<StageText> = new Vector.<StageText>();
    private static var singleLinePoolTimer:Timer;
    
    private static var cleanProperties:Object = null;
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Acquires a StageText and removes it from the pool. If the host
     *  StyleableStageText has recently released a StageText and that StageText
     *  is still in the pool, that StageText will be returned.
     */
    public static function acquireStageText(host:StyleableStageText):StageText
    {
        var result:StageText = map_StyleableStageText_to_StageText[host];
        
        if (!result)
        {
            if (host.multiline)
            {
                if (multilinePool.length == 0)
                    while (multilinePool.length < poolReserve)
                        multilinePool.push(new StageText(new StageTextInitOptions(true)));
                
                result = multilinePool.pop();
            }
            else
            {
                if (singleLinePool.length == 0)
                    while (singleLinePool.length < poolReserve)
                        singleLinePool.push(new StageText(new StageTextInitOptions(false)));
                
                result = singleLinePool.pop();
            }
                        
            // The first time a StageText is acquired, it's guaranteed to have been
            // newly-created. Take that opportunity to stash away the StageText's
            // defaults for properties that StyleableStageText may not necessarily
            // overwrite during its initialization. This is necessary because this
            // object pool "recycles" StageTexts and we need to ensure that those
            // StageTexts are clean when they are reused.
            // While the "editable" property is set in commitProperties, there is a
            // bug on Android devices where setting editable to false fails to make
            // the StageText read-only if it's already false. So, make sure
            // "editable" is one of the properties that gets restored to its
            // default value.
            if (!cleanProperties)
            {
                cleanProperties = new Object();
                
                cleanProperties["autoCapitalize"] = result.autoCapitalize;
                cleanProperties["autoCorrect"] = result.autoCorrect;
                //cleanProperties["color"] = result.color;              // Set in commitStyles
                cleanProperties["displayAsPassword"] = result.displayAsPassword;
                cleanProperties["editable"] = result.editable;
                //cleanProperties["fontFamily"] = result.fontFamily;    // Set in commitStyles
                //cleanProperties["fontPosture"] = result.fontPosture;  // Set in commitStyles
                //cleanProperties["fontSize"] = result.fontSize;        // Set in commitStyles
                //cleanProperties["fontWeight"] = result.fontWeight;    // Set in commitStyles
                //cleanProperties["locale"] = result.locale;            // Set in commitStyles
                cleanProperties["maxChars"] = result.maxChars;
                cleanProperties["restrict"] = result.restrict;
                cleanProperties["returnKeyLabel"] = result.returnKeyLabel;
                cleanProperties["softKeyboardType"] = result.softKeyboardType;
                cleanProperties["text"] = result.text;
                //cleanProperties["textAlign"] = result.textAlign;      // Set in commitStyles
                //cleanProperties["visible"] = result.visible;          // Set in commitVisible
            }
            else
            {
                for (var prop:String in cleanProperties)
                    result[prop] = cleanProperties[prop];
            }
        }
        else
        {
            var index:int;
            
            if (host.multiline)
            {
                index = multilinePool.indexOf(result);
                multilinePool.splice(index, 1);
            }
            else
            {
                index = singleLinePool.indexOf(result);
                singleLinePool.splice(index, 1);
            }
        }
        
        uncacheStageText(result);
        
        return result;
    }
    
    /**
     *  Returns true if the StageText that would be returned by acquireStageText
     *  for the given StyleableStageText will be the same as the last StageText
     *  it released.
     */
    public static function hasCachedStageText(host:StyleableStageText):Boolean
    {
        return map_StyleableStageText_to_StageText[host] !== undefined;
    }
    
    /**
     *  Puts a StageText back into the pool and caches the StyleableStageText/
     *  StageText pair so the same StageText may be returned if the
     *  StyleableStageText re-acquires it. If this causes the pool to grow
     *  larger than its reserve size, this starts a timer to check and reduce
     *  the size of the pool poolTimerInterval milliseconds later.
     */
    public static function releaseStageText(host:StyleableStageText, stageText:StageText):void
    {
        map_StyleableStageText_to_StageText[host] = stageText;
        map_StageText_to_StyleableStageText[stageText] = host;
        
        if (host.multiline)
        {
            multilinePool.push(stageText);
            
            if (multilinePool.length > poolReserve)
            {
                if (!multilinePoolTimer)
                {
                    multilinePoolTimer = new Timer(poolTimerInterval, 1);
                    multilinePoolTimer.addEventListener(TimerEvent.TIMER,
                        function (event:TimerEvent):void
                        {
                            shrinkPool(true);
                            multilinePoolTimer = null;
                        }, false, 0, true);
                }
                
                multilinePoolTimer.reset();
                multilinePoolTimer.start();
            }
        }
        else
        {
            singleLinePool.push(stageText);
            
            if (singleLinePool.length > poolReserve)
            {
                if (!singleLinePoolTimer)
                {
                    singleLinePoolTimer = new Timer(poolTimerInterval, 1);
                    singleLinePoolTimer.addEventListener(TimerEvent.TIMER,
                        function (event:TimerEvent):void
                        {
                            shrinkPool(false);
                            singleLinePoolTimer = null;
                        }, false, 0, true);
                }
                
                singleLinePoolTimer.reset();
                singleLinePoolTimer.start();
            }
        }
    }
    
    /**
     *  Return the pool to its reserve size.
     */
    private static function shrinkPool(multiline:Boolean):void
    {
        var oldStageText:StageText;
        
        if (multiline)
        {
            while (multilinePool.length > poolReserve)
            {
                oldStageText = multilinePool.shift();
                uncacheStageText(oldStageText);
                oldStageText.dispose();
            }
        }
        else
        {
            while (singleLinePool.length > poolReserve)
            {
                oldStageText = singleLinePool.shift();
                uncacheStageText(oldStageText);
                oldStageText.dispose();
            }
        }
    }
    
    /**
     *  Remove a StageText and its last known StyleableStageText host from the
     *  cache.
     */
    private static function uncacheStageText(stageText:StageText):void
    {
        var host:StyleableStageText = map_StageText_to_StyleableStageText[stageText];
        
        delete map_StyleableStageText_to_StageText[host];
        delete map_StageText_to_StyleableStageText[stageText];
    }
}