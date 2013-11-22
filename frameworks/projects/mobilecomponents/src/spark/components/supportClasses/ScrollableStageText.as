////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.supportClasses
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.PixelSnapping;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.SoftKeyboardEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import flash.text.AutoCapitalize;
import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;
import flash.text.StageText;
import flash.text.TextFormatAlign;
import flash.text.TextLineMetrics;
import flash.ui.Keyboard;

import flashx.textLayout.formats.LineBreak;

import mx.core.FlexGlobals;
import mx.core.LayoutDirection;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.TouchInteractionEvent;
import mx.managers.FocusManager;
import mx.managers.SystemManager;
import mx.utils.MatrixUtil;

import spark.components.Application;
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
 *  The ScrollableStageText class is a text primitive for use in ActionScript
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
 *  Because of this limitation, ScrollableStageText maintains a proxy bitmap that  is a pixel copy of the native text input .
 *  This proxy is always displayed in place of the native text input, except when edition takes place.
 *  For this reason, the input text might be partially obscured during text edition.
 *  Flex popups and drop-downs will also be obscured by any visible native text fields.</li>
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
 *  <li>However, ScrollableStageText can be used in text input skins that are part of a scrolling of form.</li>
 *  </ul>
 *  </p>
 *
 *  @see flash.text.StageText
 *
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.12
 */
public class ScrollableStageText extends UIComponent  implements IStyleableEditableText, ISoftKeyboardHintClient
{

    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    protected static const isAndroid:Boolean = Capabilities.version.indexOf("AND") == 0;
    protected static const isDesktop:Boolean = Capabilities.os.indexOf("Windows") != -1 || Capabilities.os.indexOf("Mac OS") != -1;
    /**
     *  Text measuring behavior needs to be slightly different on Android
     *  devices to account for its native text being slightly taller. Without
     *  this adjustment, single-line text on Android will be clipped or will
     *  scroll vertically.
     */
    mx_internal static var androidHeightMultiplier:Number = 1.15;

    protected static var supportedStyles:String = "textAlign fontFamily fontWeight fontStyle fontSize color locale";
    /**
     *  StageText does not support setting its style-like properties to null or
     *  undefined to restore their default values. So, the first time we create
     *  a StageText, store its default values here.
     */
    protected static var defaultStyles:Object;

    /**
     * when set to true, displays the proxy images with a purple background, to help debugging proxy vs stageText usage.
     */
    mx_internal static var debugProxyImage:Boolean = false;

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
    public function ScrollableStageText(multiline:Boolean = false)
    {
        super();

        _multiline = multiline;
        stageText = StageTextPool.current.acquireStageText(this);
        stageText.visible = false;

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
    //  Constructor
    //
    //--------------------------------------------------------------------------
    /**
     *  To be displayed when out of focus
     */
    protected var proxy:DisplayObject = null;

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

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
     *  Along with the text, need to save the selection, when the StageText is
     *  removed from the stage, so that when the StageText is restored, the
     *  selection can be restored.
     */
    private var savedSelectionAnchorIndex:int = 0;
    private var savedSelectionActiveIndex:int = 0;

    /*  indicates whether editing is in place
     * */
    private var isEditing:Boolean = false;

    private var invalidateProxyFlag:Boolean = false;
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------


    /**
     *  The runtime StageText object that this field uses for text display and
     *  editing.
     */
    protected var stageText:StageText;

    /**
     *  Flag indicating one or more styles have changed. If invalidateStyleFlag
     *  is false, commitStyles is a no-op, so it is safe to call commitStyles
     *  whenever this object is measured or drawn.
     */
    protected var invalidateStyleFlag:Boolean = true;


    private var _softKeyboardType: String = SoftKeyboardType.DEFAULT;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

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
    protected function get densityScale():Number
    {
        if (isNaN(_densityScale))
        {
            var application:Application = FlexGlobals.topLevelApplication as Application;
            var sm:SystemManager = application ? application.systemManager as SystemManager : null;
            _densityScale = sm ? sm.densityScale : 1.0;
        }
        return _densityScale;
    }

    protected function get showProxy():Boolean {
        return !isEditing;
    }

    //----------------------------------
    //  displayAsPassword
    //----------------------------------

    /**
     *  Storage for the displayAsPassword property.
     *  This is needed because clients may ask for this after the StageText has
     *  been disposed.
     */
    protected var _displayAsPassword:Boolean;

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
    protected var _editable:Boolean = true;

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
    protected var _maxChars:int;

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
    protected var _multiline:Boolean;

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
    protected var _restrict:String;

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
            invalidateProxy();
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

            invalidateProxy();
        }
    }


    //----------------------------------
    //  completeEventPending
    //----------------------------------



    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();

        if (stageText != null)
            stageText.editable = _editable;

        if (invalidateViewPortFlag)
        {
            invalidateViewPortFlag = false;
            updateViewPort();
        }

        if (invalidateProxyFlag && showProxy)
        {
            invalidateProxyFlag = false;
            updateProxy();
        }

    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function setFocus():void
    {
        if (stageText != null)
        {
            stageText.assignFocus();      // will trigger stageTextfocusIn
        }
    }

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
            invalidateProxy();
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

        invalidateProxy();
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
            invalidateProxy();
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
            invalidateProxy();
        }
    }


  //--------------------------------------------------------------------------
  //  Proxy Management
  //--------------------------------------------------------------------------

    protected function createProxy():DisplayObject
    {
        var bm: DisplayObject ;
        if (densityScale == 1)
        {
            bm = new Bitmap(null);
        }
        else
        {
            bm = new Bitmap(null, PixelSnapping.NEVER, true);
            bm.scaleX = 1.0 / densityScale;
            bm.scaleY = 1.0 / densityScale;
        }
        return bm;
    }

    private function invalidateProxy():void
    {
        invalidateProxyFlag = true;
        invalidateProperties();
    }

    /**
     *  Replace the existing proxy image representing this StageText with a new
     *  one. Call this whenever the StageText's properties, contents, or
     *  geometry changes. This does nothing if there is no proxy image, so it is
     *  safe to call updateProxy even if the state of the proxy image is
     *  unknown.
     */
    protected function updateProxy():void
    {
        if (stageText == null)
            return;
        if (proxy != null)
        {
            var newImageData:BitmapData = captureBitmapData();
            if (newImageData)
            {
                var oldImageData:BitmapData = Bitmap(proxy).bitmapData;
                Bitmap(proxy).bitmapData = newImageData;
                if (oldImageData)
                    oldImageData.dispose();
            }
        }
    }

    /** Dispose the proxy resources once it has been removed from the stage */
    protected function disposeProxy():void
    {
        Bitmap(proxy).bitmapData.dispose();
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
                stageText.viewPort.height, !debugProxyImage, debugProxyImage ? 0xFF00FF : 0x00FFFFFF);

        stageText.drawViewPortToBitmapData(bitmap);

        return bitmap;
    }


    protected function getGlobalViewPort():Rectangle
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

    /**
     *  Tell the StageText what rectangle it needs to render in. The StageText
     *  is not part of the normal display hierarchy, so its coordinates are
     *  always specified in global space.
     */
    protected function updateViewPort():void
    {
        if (parent && localViewPort && stageText != null)
        {
            if (stageText.stage)
            {
                var globalRect:Rectangle = getGlobalViewPort();

                if (!globalRect.equals(stageText.viewPort))
                {
                   stageText.viewPort = globalRect;
                }
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
    protected function measureTextLineHeight():Number
    {
        var lineMetrics:TextLineMetrics = measureText("Wj");

        // Android text heights are slightly different from Flex's.
        if (isAndroid)
            return lineMetrics.height * androidHeightMultiplier;

        return lineMetrics.height;
    }

    protected function restoreStageText():void
    {
        if (stageText != null)
        {
            // This has to happen here instead of waiting for commitProperties
            // because this will cause stageText.text to get cleared. Subsequent
            // change events would then copy that cleared text to the _text
            // storage variable, making the change permanent.
            stageText.editable = _editable;

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
            invalidateProperties();
        }
    }

    //--------------------------------------------------------------------------
    //
    //   event handlers
    //
    //--------------------------------------------------------------------------

    protected function addedToStageHandler(event:Event):void
    {

        var needsRestore:Boolean = false;
        if (stageText == null)
        {
            needsRestore = !StageTextPool.current.hasCachedStageText(this);
            stageText = StageTextPool.current.acquireStageText(this);
            stageText.visible = false;
        }

        proxy = createProxy();
        addChild(proxy);
        invalidateProxy();
        // The "complete" handler must be registered before changes to the stage
        // or viewPort. StageText on iOS dispatches complete events during the
        // setting of these properties, unlike Android which does so some time
        // afterward.
        stageText.addEventListener(Event.COMPLETE, stageText_completeHandler);
        stageText.stage = stage;

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

        addEventListener(TouchInteractionEvent.TOUCH_INTERACTION_STARTING, touchStartingHandler);
        if (stageText != null)
        {
            stageText.addEventListener(Event.CHANGE, stageText_changeHandler);
            stageText.addEventListener(FocusEvent.FOCUS_IN, stageText_focusInHandler);
            stageText.addEventListener(FocusEvent.FOCUS_OUT, stageText_focusOutHandler);
            stageText.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, stageText_softKeyboardActivateHandler);
            stageText.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, stageText_softKeyboardDeactivateHandler);
            stageText.addEventListener(KeyboardEvent.KEY_DOWN, stageText_keyDownHandler);
            stageText.addEventListener(KeyboardEvent.KEY_UP, stageText_keyUpHandler);
        }

        invalidateProperties();
    }

    protected function removedFromStageHandler(event:Event):void
    {

        if (stageText == null)
            return;

        // Text is saved in _text.  Also need to save the selection so it can be restored.
        savedSelectionAnchorIndex = stageText.selectionAnchorIndex;
        savedSelectionActiveIndex = stageText.selectionActiveIndex;

        stageText.stage = null;
        addEventListener(TouchInteractionEvent.TOUCH_INTERACTION_STARTING, touchStartingHandler);
        stageText.removeEventListener(Event.CHANGE, stageText_changeHandler);
        stageText.removeEventListener(Event.COMPLETE, stageText_completeHandler);
        stageText.removeEventListener(FocusEvent.FOCUS_IN, stageText_focusInHandler);
        stageText.removeEventListener(FocusEvent.FOCUS_OUT, stageText_focusOutHandler);
        stageText.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, stageText_softKeyboardActivateHandler);
        stageText.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, stageText_softKeyboardDeactivateHandler);
        stageText.removeEventListener(KeyboardEvent.KEY_DOWN, stageText_keyDownHandler);
        stageText.removeEventListener(KeyboardEvent.KEY_UP, stageText_keyUpHandler);

        StageTextPool.current.releaseStageText(this, stageText);
        stageText = null;

        if (proxy != null)
        {
            // If a textImage exists, we need to get rid of it to keep it in
            // sync with our proxy image state. disposeProxyImage does not do
            // this. It only sets a flag and invalidates properties.
            removeChild(proxy);
            disposeProxy();
            proxy = null;
        }
    }

    protected function stageText_changeHandler(event:Event):void
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

    protected function stageText_completeHandler(event:Event):void
    {
        invalidateProxy();
        invalidateViewPortFlag = true;
        invalidateProperties();
    }



    private function touchStartingHandler(event: Event): void
    {
        // don't allow touch scrolling while editing (of the StageText will stay in place)
        if (isEditing)
            event.preventDefault();
    }

    private function stageText_focusInHandler(event:FocusEvent):void
    {
          if (!isEditing){
              startTextEdit();
          }
            // Focus events are documented as bubbling. However, all events coming
            // from StageText are set to not bubble. So we need to create an
            // appropriate bubbling event here.
        dispatchEvent(new FocusEvent(event.type, true, event.cancelable,
        event.relatedObject, event.shiftKey, event.keyCode, event.direction));
    }

    private function stageText_focusOutHandler(event:FocusEvent):void
    {
        if (isEditing)
        {
            endTextEdit();
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

    private function stageText_softKeyboardActivateHandler(event:SoftKeyboardEvent):void
    {

        if ( startTextEdit()) {
            dispatchEvent(new SoftKeyboardEvent(event.type,
                    true, event.cancelable, this, event.triggerType));
        }
    }

    private function stageText_softKeyboardDeactivateHandler(event:SoftKeyboardEvent):void
    {
            dispatchEvent(new SoftKeyboardEvent(event.type,
                    true, event.cancelable, this, event.triggerType));
    }

    //--------------------------------------------------------------------------
    //
    //    EDITING
    //
    //--------------------------------------------------------------------------

    /**
     * @return true if editing was actually stated,, false is already started
     * */
    protected function startTextEdit(): Boolean
    {
        if (!isEditing)
        {
      //      trace("start text edit:", debugId);
            isEditing = true;
            proxy.visible = false;
            updateViewPort();
            stageText.visible = true;
            return true;
        }
        else
        {
            return false;
        }
    }

    /**
     * @return true if editing was actually ended, false is already ended
     * */
    protected function endTextEdit(): Boolean
    {
        // if owning TextInput mouseDown is the cause of focus out, abort

        if (isEditing)
        {
     //       trace("end text edit:", debugId);
            isEditing = false;
            invalidateProxy();
            proxy.visible = true;
            stageText.visible = false;
            return true;
        }
        else
        {
            return false;
        }
    }

    /* debug */
    protected function get debugId():String {
        var parentSkin: UIComponent = this.parent.parent as UIComponent;
        return    parentSkin ? parentSkin.id : "-" ;
    }
}
}

import flash.events.TimerEvent;
import flash.text.StageText;
import flash.text.StageTextInitOptions;
import flash.utils.Dictionary;
import flash.utils.Timer;

import spark.components.supportClasses.ScrollableStageText;

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

    private static var _current:StageTextPool;

    internal static function get current():StageTextPool {
        if (!_current ){
            _current = new StageTextPool();
        }
        return _current;
    }

      //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

    /**
     * @private
     */
    public function StageTextPool( ) {
    }

      //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------

    private  var map_StyleableStageText_to_StageText:Dictionary = new Dictionary(true);
    private  var map_StageText_to_StyleableStageText:Dictionary = new Dictionary(true);

    private  var multilinePool:Vector.<StageText> = new Vector.<StageText>();
    private  var multilinePoolTimer:Timer;

    private  var singleLinePool:Vector.<StageText> = new Vector.<StageText>();
    private  var singleLinePoolTimer:Timer;

    private  var cleanProperties:Object = null;

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Acquires a StageText and removes it from the pool. If the host
     *  StyleableStageText2 has recently released a StageText and that StageText
     *  is still in the pool, that StageText will be returned.
     */
    public  function acquireStageText(host:ScrollableStageText):StageText
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
                cleanProperties = {};

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
     *  for the given StyleableStageText2 will be the same as the last StageText
     *  it released.
     */
    public  function hasCachedStageText(host:ScrollableStageText):Boolean
    {
        return map_StyleableStageText_to_StageText[host] !== undefined;
    }

    /**
     *  Puts a StageText back into the pool and caches the StyleableStageText2/
     *  StageText pair so the same StageText may be returned if the
     *  StyleableStageText2 re-acquires it. If this causes the pool to grow
     *  larger than its reserve size, this starts a timer to check and reduce
     *  the size of the pool poolTimerInterval milliseconds later.
     */
    public  function releaseStageText(host:ScrollableStageText, stageText:StageText):void
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
    private  function shrinkPool(multiline:Boolean):void
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
     *  Remove a StageText and its last known StyleableStageText2 host from the
     *  cache.
     */
    private  function uncacheStageText(stageText:StageText):void
    {
        var host:ScrollableStageText = map_StageText_to_StyleableStageText[stageText];

        delete map_StyleableStageText_to_StageText[host];
        delete map_StageText_to_StyleableStageText[stageText];
    }
}