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


package spark.components
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.SoftKeyboardEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import flash.text.TextField;
import flash.ui.Keyboard;
import flash.utils.Timer;

import mx.core.EventPriority;
import mx.core.FlexGlobals;
import mx.core.IInvalidating;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.InteractionMode;
import mx.core.LayoutDirection;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.events.FlexMouseEvent;
import mx.events.PropertyChangeEvent;
import mx.events.TouchInteractionEvent;
import mx.managers.IFocusManagerComponent;
import mx.styles.ISimpleStyleClient;
import mx.styles.IStyleClient;

import spark.components.supportClasses.GroupBase;
import spark.components.supportClasses.ScrollerLayout;
import spark.components.supportClasses.SkinnableComponent;
import spark.core.IGraphicElement;
import spark.core.IViewport;
import spark.core.NavigationUnit;
import spark.effects.Animate;
import spark.effects.animation.Keyframe;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.effects.easing.IEaser;
import spark.effects.easing.Power;
import spark.effects.easing.Sine;
import spark.events.CaretBoundsChangeEvent;
import spark.layouts.supportClasses.LayoutBase;
import spark.utils.MouseEventUtil;

use namespace mx_internal;

include "../styles/metadata/BasicInheritingTextStyles.as"
include "../styles/metadata/AdvancedInheritingTextStyles.as"
include "../styles/metadata/SelectionFormatTextStyles.as"

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the scroll position is going to change due to a 
 *  <code>mouseWheel</code> event.
 *  
 *  <p>If there is a visible verticalScrollBar, then by default
 *  the viewport is scrolled vertically by <code>event.delta</code> "steps".
 *  The height of the step is determined by the viewport's 
 *  <code>getVerticalScrollPositionDelta</code> method using 
 *  either <code>UP</code> or <code>DOWN</code>, depending on the scroll 
 *  direction.</p>
 *
 *  <p>Otherwise, if there is a visible horizontalScrollBar, then by default
 *  the viewport is scrolled horizontally by <code>event.delta</code> "steps".
 *  The width of the step is determined by the viewport's 
 *  <code>getHorizontalScrollPositionDelta</code> method using 
 *  either <code>LEFT</code> or <code>RIGHT</code>, depending on the scroll 
 *  direction.</p>
 *
 *  <p>Calling the <code>preventDefault()</code> method
 *  on the event prevents the scroll position from changing.
 *  Otherwise if you modify the <code>delta</code> property of the event,
 *  that value will be used as the number of "steps".</p>
 *
 *  @eventType mx.events.FlexMouseEvent.MOUSE_WHEEL_CHANGING
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="mouseWheelChanging", type="mx.events.FlexMouseEvent")]

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  @copy spark.components.supportClasses.GroupBase#style:alternatingItemColors
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  The alpha of the content background for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="contentBackgroundAlpha", type="Number", inherit="yes", theme="spark, mobile")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:contentBackgroundColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:downColor
 *   
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="downColor", type="uint", format="Color", inherit="yes", theme="mobile")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:focusColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  Indicates under what conditions the horizontal scroll bar is displayed.
 * 
 *  <ul>
 *  <li>
 *  <code>ScrollPolicy.ON</code> ("on") - the scroll bar is always displayed.
 *  </li> 
 *  <li>
 *  <code>ScrollPolicy.OFF</code> ("off") - the scroll bar is never displayed.
 *  The viewport can still be scrolled programmatically, by setting its
 *  horizontalScrollPosition property.
 *  </li>
 *  <li>
 *  <code>ScrollPolicy.AUTO</code> ("auto") - the scroll bar is displayed when 
 *  the viewport's contentWidth is larger than its width.
 *  </li>
 *  </ul>
 * 
 *  <p>
 *  The scroll policy affects the measured size of the Scroller component.
 *  </p>
 * 
 *  @default ScrollPolicy.AUTO
 *
 *  @see mx.core.ScrollPolicy
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="horizontalScrollPolicy", type="String", inherit="no", enumeration="off,on,auto")]

/**
 *  A proxy for the <code>liveDragging</code> style of the scrollbars 
 *  used by the Scroller component.   
 * 
 *  <p>If this style is set to <code>true</code>, then the 
 *  <code>liveDragging</code> styles are set to <code>true</code> (the default).
 *  That means dragging a scrollbar thumb immediately updates the viewport's scroll position.
 *  If this style is set to <code>false</code>, then the <code>liveDragging</code> styles 
 *  are set to <code>false</code>.
 *  That means when a scrollbar thumb is dragged the viewport's scroll position is only updated 
 *  then the mouse button is released.</p>
 * 
 *  <p>Setting this style to <code>false</code> can be helpful 
 *  when updating the viewport's display is so 
 *  expensive that "liveDragging" performs poorly.</p> 
 *  
 *  <p>By default this style is <code>undefined</code>, which means that 
 *  the <code>liveDragging</code> styles are not modified.</p>
 * 
 *  @default undefined
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="liveScrolling", type="Boolean", inherit="no")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:rollOverColor
 *   
 *  @default 0xCEDBEF
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="rollOverColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:symbolColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:touchDelay
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="touchDelay", type="Number", format="Time", inherit="yes", minValue="0.0")]

/**
 *  Indicates under what conditions the vertical scroll bar is displayed.
 * 
 *  <ul>
 *  <li>
 *  <code>ScrollPolicy.ON</code> ("on") - the scroll bar is always displayed.
 *  </li> 
 *  <li>
 *  <code>ScrollPolicy.OFF</code> ("off") - the scroll bar is never displayed.
 *  The viewport can still be scrolled programmatically, by setting its
 *  verticalScrollPosition property.
 *  </li>
 *  <li>
 *  <code>ScrollPolicy.AUTO</code> ("auto") - the scroll bar is displayed when 
 *  the viewport's contentHeight is larger than its height.
 *  </li>
 *  </ul>
 * 
 *  <p>
 *  The scroll policy affects the measured size of the Scroller component.
 *  </p>
 * 
 *  @default ScrollPolicy.AUTO
 *
 *  @see mx.core.ScrollPolicy
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
     */ 
[Style(name="verticalScrollPolicy", type="String", inherit="no", enumeration="off,on,auto")]


//--------------------------------------
//  Other metadata
//--------------------------------------

[ResourceBundle("components")]
    
[DefaultProperty("viewport")]

[IconFile("Scroller.png")]

/**
 *  The Scroller component displays a single scrollable component, 
 *  called a viewport, and horizontal and vertical scroll bars. 
 *  The viewport must implement the IViewport interface.  Its skin
 *  must be a derivative of the Group class.
 *
 *  <p>The Spark Group, DataGroup, and RichEditableText components implement 
 *  the IViewport interface and can be used as the children of the Scroller control,
 *  as the following example shows:</p>
 * 
 *  <pre>
 *  &lt;s:Scroller width="100" height="100"&gt;
 *       &lt;s:Group&gt; 
 *          &lt;mx:Image width="300" height="400" 
 *               source="&#64;Embed(source='assets/logo.jpg')"/&gt; 
 *       &lt;/s:Group&gt;        
 *  &lt;/s:Scroller&gt;</pre>     
 *
 *  <p>The size of the Image control is set larger than that of its parent Group container. 
 *  By default, the child extends past the boundaries of the parent container. 
 *  Rather than allow the child to extend past the boundaries of the parent container, 
 *  the Scroller specifies to clip the child to the boundaries and display scroll bars.</p>
 *
 *  <p>Not all Spark containers implement the IViewPort interface. 
 *  Therefore, those containers, such as the BorderContainer and SkinnableContainer containers, 
 *  cannot be used as the direct child of the Scroller component.
 *  However, all Spark containers can have a Scroller component as a child component. 
 *  For example, to use scroll bars on a child of the Spark BorderContainer, 
 *  wrap the child in a Scroller component. </p>
 *
 *  <p>To make the entire BorderContainer scrollable, wrap it in a Group container. 
 *  Then, make the Group container the child of the Scroller component,
 *  For skinnable Spark containers that do not implement the IViewport interface, 
 *  you can also create a custom skin for the container that 
 *  includes the Scroller component. </p>
 * 
 *  <p>The IViewport interface defines a viewport for the components that implement it.
 *  A viewport is a rectangular subset of the area of a container that you want to display, 
 *  rather than displaying the entire container.
 *  The scroll bars control the viewport's <code>horizontalScrollPosition</code> and
 *  <code>verticalScrollPosition</code> properties.
 *  scroll bars make it possible to view the area defined by the viewport's 
 *  <code>contentWidth</code> and <code>contentHeight</code> properties.</p>
 *
 *  <p>You can combine scroll bars with explicit settings for the container's viewport. 
 *  The viewport settings determine the initial position of the viewport, 
 *  and then you can use the scroll bars to move it, as the following example shows: </p>
 *  
 *  <pre>
 *  &lt;s:Scroller width="100" height="100"&gt;
 *      &lt;s:Group
 *          horizontalScrollPosition="50" verticalScrollPosition="50"&gt; 
 *          &lt;mx:Image width="300" height="400" 
 *              source="&#64;Embed(source='assets/logo.jpg')"/&gt; 
 *      &lt;/s:Group&gt;                 
 *  &lt;/s:Scroller&gt;</pre>
 * 
 *  <p>The scroll bars are displayed according to the vertical and horizontal scroll bar
 *  policy, which can be <code>auto</code>, <code>on</code>, or <code>off</code>.
 *  The <code>auto</code> policy means that the scroll bar will be visible and included
 *  in the layout when the viewport's content is larger than the viewport itself.</p>
 * 
 *  <p>The Scroller skin layout cannot be changed. It is unconditionally set to a 
 *  private layout implementation that handles the scroll policies.  Scroller skins
 *  can only provide replacement scroll bars.  To gain more control over the layout
 *  of a viewport and its scroll bars, instead of using Scroller, just add them 
 *  to a <code>Group</code> and use the scroll bar <code>viewport</code> property 
 *  to link them together.</p>
 *
 *  <p>The Scroller control has the following default characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>0</td>
 *        </tr>
 *        <tr>
 *           <td>Minimum size</td>
 *           <td>0</td>
 *        </tr>
 *        <tr>
 *           <td>Maximum size</td>
 *           <td>10000 pixels wide and 10000 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Default skin class</td>
 *           <td>spark.skins.spark.ScrollerSkin</td>
 *        </tr>
 *     </table>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:Scroller&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:Scroller
 *   <strong>Properties</strong>
 *    measuredSizeIncludesScrollBars="true"
 *    minViewportInset="0"
 *    viewport="null"
 *  
 *    <strong>Styles</strong>
 *    alignmentBaseline="use_dominant_baseline"
 *    alternatingItemColors=""
 *    baselineShift="0.0"
 *    blockProgression="TB"
 *    breakOpportunity="auto"
 *    cffHinting="horizontal_stem"
 *    clearFloats="none"
 *    color="0"
 *    contentBackgroundAlpha=""
 *    contentBackgroundColor=""
 *    digitCase="default"
 *    digitWidth="default"
 *    direction="LTR"
 *    dominantBaseline="auto"
 *    downColor=""
 *    firstBaselineOffset="auto"
 *    focusColor=""
 *    focusedTextSelectionColor=""
 *    fontFamily="Arial"
 *    fontLookup="device"
 *    fontSize="12"
 *    fontStyle="normal"
 *    fontWeight="normal"
 *    horizontalScrollPolicy="auto"
 *    inactiveTextSelection=""
 *    justificationRule="auto"
 *    justificationStyle="auto"
 *    kerning="auto"
 *    leadingModel="auto"
 *    ligatureLevel="common"
 *    lineHeight="120%"
 *    lineThrough="false"
 *    listAutoPadding="40"
 *    listStylePosition="outside"
 *    listStyleType="disc"
 *    locale="en"
 *    paragraphEndIndent="0"
 *    paragraphSpaceAfter="0"
 *    paragraphSpaceBefore="0"
 *    paragraphStartIndent="0"
 *    renderingMode="CFF"
 *    rollOverColor=""
 *    symbolColor=""
 *    tabStops="null"
 *    textAlign="start"
 *    textAlignLast="start"
 *    textAlpha="1"
 *    textDecoration="none"
 *    textIndent="0"
 *    textJustify="inter_word"
 *    textRotation="auto"
 *    trackingLeft="0"
 *    trackingRight="0"
 *    typographicCase="default"
 *    unfocusedTextSelectionColor=""
 *    verticalScrollPolicy="auto"
 *    whiteSpaceCollapse="collapse"
 *    wordSpacing="100%,50%,150%"
 *  /&gt;
 *  </pre>
 *  
 *  @see spark.core.IViewport
 *  @see spark.components.DataGroup
 *  @see spark.components.Group
 *  @see spark.components.RichEditableText
 *  @see spark.skins.spark.ScrollerSkin
 *
 *  @includeExample examples/ScrollerExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */

public class Scroller extends SkinnableComponent 
       implements IFocusManagerComponent, IVisualElementContainer
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  The duration of the overshoot effect when a throw "bounces" against the end of the list.
     */
    private static const THROW_OVERSHOOT_TIME:int = 200;

    /**
     *  @private
     *  The duration of the settle effect when a throw "bounces" against the end of the list.
     */
    private static const THROW_SETTLE_TIME:int = 600;
    
    /**
     *  @private
     *  The exponent used in the easer function for the main part of the throw animation.
     *  NOTE: if you change this, you need to re-differentiate the easer
     *  function and use the resulting derivative calculation in createThrowMotionPath. 
     */
    private static const THROW_CURVE_EXPONENT:Number = 3.0;
    
    /**
     *  @private
     *  The exponent used in the easer function for the "overshoot" portion 
     *  of the throw animation.
     */
    private static const OVERSHOOT_CURVE_EXPONENT:Number = 2.0;

    /**
     *  @private
     *  The ratio that determines how far the list scrolls when pulled past its end.
     */
    private static const PULL_TENSION_RATIO:Number = 0.5;
    
    /**
     *  @private
     *  Used so we don't have to keep allocating Point(0,0) to do coordinate conversions
     *  while draggingg
     */
    private static const ZERO_POINT:Point = new Point(0,0); 
    
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
    public function Scroller()
    {
        super();
        hasFocusableChildren = true;
        focusEnabled = false;
        
        addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables: Touch Scrolling
    //
    //--------------------------------------------------------------------------    
    
    /**
     *  @private
     *  Property used to communicate with ScrollerLayout to let it 
     *  know when a horizontal scroll is in progress or not (and when 
     *  the horizontal scroll bar should be hidden or not)
     */
    mx_internal var horizontalScrollInProgress:Boolean = false;
    
    /**
     *  @private
     *  Property used to communicate with ScrollerLayout to let it 
     *  know when a vertical scroll is in progress or not (and when 
     *  the vertical scroll bar should be hidden or not)
     */
    mx_internal var verticalScrollInProgress:Boolean = false;
    
    /**
     *  @private
     *  Threshold for screen distance they must move to count as a scroll
     *  Based on 20 pixels on a 252ppi device.
     */
    mx_internal var minSlopInches:Number = 0.079365; // 20.0/252.0
    
    /**
     *  @private
     *  The amount of deceleration to apply to the velocity for each effect period
     *  For a faster deceleration, you can switch this to 0.990.
     */
    mx_internal var throwEffectDecelFactor:Number = 0.998;
    
    /**
     *  @private
     *  Touch Scroll Helper -- used to help figure out 
     *  scrolling velocity and other information
     */
    private var touchScrollHelper:TouchScrollHelper;
    
    /**
     *  @private
     *  Keeps track of the horizontal scroll position
     *  before scrolling started, so we can figure out 
     *  how to related it to the dragX that are 
     *  associated with the touchScrollDrag events.
     */
    private var hspBeforeTouchScroll:Number;
    
    /**
     *  @private
     *  Keeps track of the vertical scroll position
     *  before scrolling started, so we can figure out 
     *  how to related it to the dragY that are 
     *  associated with the touchScrollDrag events.
     */
    private var vspBeforeTouchScroll:Number;
    
    /**
     *  @private
     *  Effect used for touch scroll throwing
     */
    private var throwEffect:Animate;
    
    /**
     *  @private
     *  The final position in the throw effect's vertical motion path
     */
    private var throwFinalVSP:Number;
    
    /**
     *  @private
     *  The final position in the throw effect's horizontal motion path
     */
    private var throwFinalHSP:Number;

    /**
     *  @private
     *  Indicates whether the previous throw reached one of the maximum
     *  scroll positions (vsp or hsp) that was in effect at the time. 
     */
    private var throwReachedMaximumScrollPosition:Boolean;
    
    /**
     *  @private
     *  Used to keep track of whether the throw animation 
     *  was stopped pre-emptively.  We stop propogation of 
     *  the mouse event, but in the throwEffect.EFFECT_END
     *  event handler, we need to tell it not to exit the
     *  scrolling state.
     */
    private var stoppedPreemptively:Boolean = false;
    
    /**
     *  @private
     *  Used to keep track of whether we are currently throwing
     *  vertically.  This is so on effect update we can perhaps stop 
     *  the effect pre-emptively since we are not doing pull 
     *  or spring effects yet.
     */
    private var scrollingVertically:Boolean;
    
    /**
     *  @private
     *  Used to keep track of whether we are currently throwing
     *  horizontally.  This is so on effect update we can perhaps stop 
     *  the effect pre-emptively since we are not doing pull 
     *  or spring effects yet.
     */
    private var scrollingHorizontally:Boolean;
    
    /**
     *  @private
     *  Used to keep track of whether we should capture the next 
     *  click event that we receive or whether we should let it dispatch 
     *  normally.  We capture the click event if a scroll happened.  We 
     *  set this property in mouseDown and touchScrollStart.
     */
    private var captureNextClick:Boolean = false;
    
    /**
     *  @private
     *  Used to keep track of whether we should capture the next 
     *  mousedown event that we receive or whether we should let it dispatch 
     *  normally.  We capture the mousedown event if a scroll-throw is 
     *  currently happening.  We set this property in mouseDown, touchInteractionStart, 
     *  and touchInteractionEnd.
     */
    private var captureNextMouseDown:Boolean = false;
    
    /**
     *  @private
     *  Animation to fade the scrollbars out when we are done
     *  throwing or dragging
     */
    private var hideScrollBarAnimation:Animate;
    
    /**
     *  @private
     *  Use to figure out whether the animation ended naturally and finished or 
     *  whether we called stop() on it.  Unfortunately, we get an EFFECT_END in 
     *  both cases, so we must keep track of it ourselves.
     */
    private var hideScrollBarAnimationPrematurelyStopped:Boolean;
    
    /**
     *  @private
     *  Keeps track of whether a touch interaction is in progress. 
     */
    private var inTouchInteraction:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Variables: SoftKeyboard Support
    //
    //--------------------------------------------------------------------------  
    
    /**
     *  @private
     * 
     *  Some devices do not support a hardware keyboard. 
     *  Instead, these devices use a keyboard that opens on 
     *  the screen when necessary. 
     *  A value of <code>true</code> means that when a component in 
     *  the container wrapped by the scroller receives focus, 
     *  the Scroller scrolls that component into view if the keyboard is 
     *  opening
     */    
    mx_internal var ensureElementIsVisibleForSoftKeyboard:Boolean = true;
    
    /**
     *  @private 
     */ 
    private var lastFocusedElement:IVisualElement;
    
    /**
     *  @private 
     *  Used to detect when the device orientation (landscape/portrait) has changed
     */
    private var aspectRatio:String;
    
    /**
     *  @private 
     */
    private var oldSoftKeyboardHeight:Number = NaN;
    
    /**
     *  @private 
     */
    private var oldSoftKeyboardWidth:Number = NaN;
    
    /**
     *  @private 
     */
    mx_internal var preventThrows:Boolean = false;
    
    /**
     *  @private 
     */
    private var lastFocusedElementCaretBounds:Rectangle;
    
    /**
     *  @private 
     */
    private var captureNextCaretBoundsChange:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  horizontalScrollBar
    //---------------------------------- 
    
    [SkinPart(required="false")]
    [Bindable]    

    /**
     *  A skin part that defines the horizontal scroll bar.
     * 
     *  This property should be considered read-only. It is only
     *  set by the Scroller's skin.
     * 
     *  This property is Bindable.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var horizontalScrollBar:HScrollBar;
    
    //----------------------------------
    //  verticalScrollBar
    //---------------------------------- 
    
    [SkinPart(required="false")]
    [Bindable]
    
    /**
     *  A skin part that defines the vertical scroll bar.
     * 
     *  This property should be considered read-only. It is only
     *  set by the Scroller's skin.
     * 
     *  This property is Bindable.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var verticalScrollBar:VScrollBar;


    //----------------------------------
    //  viewport - default property
    //----------------------------------    
    
    private var _viewport:IViewport;
    
    [Bindable(event="viewportChanged")]
    
    /**
     *  The viewport component to be scrolled.
     * 
     *  <p>
     *  The viewport is added to the Scroller component's skin, 
     *  which lays out both the viewport and scroll bars.
     * 
     *  When the <code>viewport</code> property is set, the viewport's 
     *  <code>clipAndEnableScrolling</code> property is 
     *  set to true to enable scrolling.
     * 
     *  The Scroller does not support rotating the viewport directly.  The viewport's
     *  contents can be transformed arbitrarily, but the viewport itself cannot.
     * </p>
     * 
     *  This property is Bindable.
     * 
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get viewport():IViewport
    {       
        return _viewport;
    }
    
    /**
     *  @private
     */
    public function set viewport(value:IViewport):void
    {
        if (value == _viewport)
            return;
        
        uninstallViewport();
        _viewport = value;
        installViewport();
        dispatchEvent(new Event("viewportChanged"));
    }
    
    /**
     *  @private
     *  This is used to disable thinning for automated testing.
     */
    mx_internal static var dragEventThinning:Boolean = true;
    
    private function installViewport():void
    {
        if (skin && viewport)
        {
            viewport.clipAndEnableScrolling = true;
            Group(skin).addElementAt(viewport, 0);
            viewport.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
        }
        if (verticalScrollBar)
            verticalScrollBar.viewport = viewport;
        if (horizontalScrollBar)
            horizontalScrollBar.viewport = viewport;
    }
    
    private function uninstallViewport():void
    {
        if (horizontalScrollBar)
            horizontalScrollBar.viewport = null;
        if (verticalScrollBar)
            verticalScrollBar.viewport = null;        
        if (skin && viewport)
        {
            viewport.clipAndEnableScrolling = false;
            Group(skin).removeElement(viewport);
            viewport.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
        }
    }
    
    
    //----------------------------------
    //  minViewportInset
    //----------------------------------

    private var _minViewportInset:Number = 0;
    
    [Inspectable(category="General", defaultValue="0")]

    /**
     *  The minimum space between the viewport and the edges of the Scroller.  
     * 
     *  If neither of the scroll bars is visible, then the viewport is inset by 
     *  <code>minViewportInset</code> on all four sides.
     * 
     *  If a scroll bar is visible then the viewport is inset by <code>minViewportInset</code>
     *  or by the scroll bar's size, whichever is larger.
     * 
     *  ScrollBars are laid out flush with the edges of the Scroller.   
     * 
     *  @default 0 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get minViewportInset():Number
    {
        return _minViewportInset;
    }

    /**
     *  @private
     */
    public function set minViewportInset(value:Number):void
    {
        if (value == _minViewportInset)
            return;
            
        _minViewportInset = value;
        invalidateSkin();
    }

    //----------------------------------
    //  measuredSizeIncludesScrollBars
    //----------------------------------
    
    private var _measuredSizeIncludesScrollBars:Boolean = true;
    
    [Inspectable(category="General", defaultValue="true")]
    
    /**
     *  If <code>true</code>, the Scroller's measured size includes the space required for
     *  the visible scroll bars, otherwise the Scroller's measured size depends
     *  only on its viewport.
     * 
     *  <p>Components like TextArea, which "reflow" their contents to fit the
     *  available width or height may use this property to stabilize their
     *  measured size.  By default a TextArea's is defined by its <code>widthInChars</code>
     *  and <code>heightInChars</code> properties and in many applications it's preferable
     *  for the measured size to remain constant, event when scroll bars are displayed
     *  by the TextArea skin's Scroller.</p>
     * 
     *  <p>In components where the content does not reflow, like a typical List's
     *  items, the default behavior is preferable because it makes it less
     *  likely that the component's content will be obscured by a scroll bar.</p>
     * 
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get measuredSizeIncludesScrollBars():Boolean
    {
        return _measuredSizeIncludesScrollBars;
    }
    
    /**
     *  @private 
     */
    public function set measuredSizeIncludesScrollBars(value:Boolean):void
    {
        if (value == _measuredSizeIncludesScrollBars)
            return;

        _measuredSizeIncludesScrollBars = value;
        invalidateSkin();
    }
    
    //--------------------------------------------------------------------------
    // 
    // Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Scrolls the viewport so the specified element is visible.
     * 
     *  @param element A child element of the container, 
     *  or of a nested container, wrapped by the Scroller.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function ensureElementIsVisible(element:IVisualElement):void
    {   
        ensureElementPositionIsVisible(element);
    }
    
    /**
     *  @private
     *  
     *  @param elementLocalBounds ensure that these bounds of the element are 
     *  visible. The bounds are in the coordinate system of the element
     *  @param doValidateNow if true, call validateNow() at the end of the 
     *  function 
     */  
    private function ensureElementPositionIsVisible(element:IVisualElement, 
                                                    elementLocalBounds:Rectangle = null,
                                                    entireElementVisible:Boolean = true,
                                                    doValidateNow:Boolean = true):void
    {
        // First check that the element is a descendant
        // If we are a GraphicElement, use the element's parent
        var possibleDescendant:DisplayObject = element as DisplayObject;
        
        if (element is IGraphicElement)
            possibleDescendant = IGraphicElement(element).parent as DisplayObject;
        
        if (!possibleDescendant || !contains(possibleDescendant))
            return;
        
        var layout:LayoutBase = null;
        
        if (viewport is GroupBase)
            layout = GroupBase(viewport).layout;
        else if (viewport is SkinnableContainer)
            layout = SkinnableContainer(viewport).layout;
        
        if (layout)
        {
            // Before we change the scroll position, make sure there is
            // no throw effect playing.
            if (throwEffect && throwEffect.isPlaying)
            {
                throwEffect.stop();
                snapContentScrollPosition();
            }
            
            // Scroll the element into view
            
            var delta:Point = layout.getScrollPositionDeltaToAnyElement(element, elementLocalBounds, entireElementVisible);
            
            if (delta)
            {
                viewport.horizontalScrollPosition += delta.x; 
                viewport.verticalScrollPosition += delta.y;
                
                // We only care about focusThickness if we are positioning the whole element 
                if (!elementLocalBounds)
                {
                    var eltBounds:Rectangle = layout.getChildElementBounds(element);
                    var focusThickness:Number = 0;
                
                    if (element is IStyleClient)
                        focusThickness = IStyleClient(element).getStyle("focusThickness");
                    
                    // Make sure that the focus ring is visible. Top and left sides have priority
                    if (focusThickness)
                    {
                        if (viewport.verticalScrollPosition > eltBounds.top - focusThickness)
                            viewport.verticalScrollPosition = eltBounds.top - focusThickness;
                        else if (viewport.verticalScrollPosition + height < eltBounds.bottom + focusThickness)
                            viewport.verticalScrollPosition = eltBounds.bottom + focusThickness - height;
                        
                        if (viewport.horizontalScrollPosition > eltBounds.left - focusThickness)
                            viewport.horizontalScrollPosition = eltBounds.left - focusThickness;
                        else if (viewport.horizontalScrollPosition + width < eltBounds.right + focusThickness)
                            viewport.horizontalScrollPosition = eltBounds.right + focusThickness - width;
                    }
                }
                
                if (doValidateNow && viewport is UIComponent)
                    UIComponent(viewport).validateNow();
            }
        }
    }
    
    //--------------------------------------------------------------------------
    // 
    // Event Handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Helper function for checkScrollPosition.  
     */
    private function getMotionPathCurrentVelocity(mp:MotionPath,currentTime:Number,totalTime:Number):Number
    {
        // Determine the fraction of the effect that has already played.
        var fraction:Number = currentTime / totalTime;

        // Now we need to determine the effective velocity at the effect's current position.
        // Here we use a "poor man's" approximation that doesn't require us to know any of the
        // derivative functions associated with the motion path.  We sample the position at two
        // time values very close together and assume the velocity slope is a straight line 
        // between them.  The smaller the distance between the two time values, the closer the 
        // result will be to the "instantaneous" velocity.
        const TINY_DELTA_TIME:Number = 0.00001; 
        var value1:Number = Number(mp.getValue(fraction));
        var value2:Number = Number(mp.getValue(fraction + (TINY_DELTA_TIME / totalTime)));
        return (value2 - value1) / TINY_DELTA_TIME;
    }
    
    /**
     *  @private 
     */
    private function checkScrollPosition():void
    {
        // Determine whether there's been a device orientation change
        // Note:  the first time this code runs it may falsely appear as though an orientation 
        // change has occurred (aspectRatio is null).  This is okay since there will be no 
        // throw animation playing, so orientationChange will not be acted upon.
        var orientationChange:Boolean = aspectRatio != FlexGlobals.topLevelApplication.aspectRatio;
        aspectRatio = FlexGlobals.topLevelApplication.aspectRatio;
        
        var curVelocity:Point;
        
        // Determine the new maximum valid scroll positions
        var maxVSP:Number = viewport.contentHeight > viewport.height ? 
            viewport.contentHeight-viewport.height : 0; 
        var maxHSP:Number = viewport.contentWidth > viewport.width ? 
            viewport.contentWidth-viewport.width : 0;
        
        // Determine whether we possibly need to re-throw because of changed max positions.
        var didNotThrowFarEnough:Boolean = throwReachedMaximumScrollPosition &&
            (throwFinalVSP < maxVSP || throwFinalHSP < maxHSP);
        var threwTooFar:Boolean = (throwFinalVSP > maxVSP || throwFinalHSP > maxHSP);

        if (throwEffect && throwEffect.isPlaying && (didNotThrowFarEnough || threwTooFar))
        {
            // There's currently a throw animation playing, and it's throwing to a 
            // now-incorrect position.
            if (orientationChange)
            {
                // The throw end position became invalid because the device
                // orientation changed.  In this case, we just want to stop
                // the throw animation and snap to valid positions.  We don't
                // want to animate to the final position because this may
                // require changing directions relative to the current throw,
                // which looks strange.
                throwEffect.stop();
                if (viewport.verticalScrollPosition > maxVSP)
                    viewport.verticalScrollPosition = maxVSP;
                if (viewport.horizontalScrollPosition > maxHSP)
                    viewport.horizontalScrollPosition = maxHSP;
            }
            else
            {
                // The size of the content may have changed during the throw.
                // In this case, we'll stop the current animation and start
                // a new one that gets us to the correct position. 
            
                var velX:Number = 0;
                var velY:Number = 0;
                
                // Get the current position of the existing throw animation
                var effectTime:Number = throwEffect.playheadTime;
                
                // It's possible for playheadTime to not be set if we're getting it
                // before the first animation timer call.
                if (isNaN(effectTime))
                    effectTime = 0;
                
                var effectDuration:Number = throwEffect.duration;
                
                // Now get the current effective velocity for each motionpath in the animation. 
                for (var t:int = 0; t < throwEffect.motionPaths.length; t++)
                {
                    var vel:Number = getMotionPathCurrentVelocity(throwEffect.motionPaths[t], effectTime, effectDuration);
                    
                    // The property can only either be horizontalScrollPosition or verticalScrollPosition
                    if (throwEffect.motionPaths[t].property == "horizontalScrollPosition")
                        velX = vel;
                    else
                        velY = vel;
                }
                
                // Stop the existing throw animation now that we've determined its current velocities.
                stoppedPreemptively = true;
                throwEffect.stop();
                
                // Now perform a new throw to get us to the right position.
                performThrow(-velX, -velY);
            }
        }
        else if (!inTouchInteraction)
        {
            // No touch interaction is in effect, but the content may be sitting at
            // a scroll position that is now invalid.  If so, snap the content to
            // a valid position.  The most likely reason we get here is that the
            // device orientation changed while the content is stationary (i.e. not
            // in an animated throw)
            if (viewport.verticalScrollPosition > maxVSP)
                viewport.verticalScrollPosition = maxVSP;
            if (viewport.horizontalScrollPosition > maxHSP)
                viewport.horizontalScrollPosition = maxHSP;
        }
    }
    
    /**
     *  @private 
     */
    private function checkScrollPositionsOnUpdateComplete(event:FlexEvent):void
    {
        viewport.removeEventListener(FlexEvent.UPDATE_COMPLETE, 
            checkScrollPositionsOnUpdateComplete);
        
        checkScrollPosition();
    }
    
    /**
     *  @private 
     */
    private function viewport_propertyChangeHandler(event:PropertyChangeEvent):void
    {
        switch(event.property) 
        {
            case "contentWidth": 
            case "contentHeight": 
                invalidateSkin();
                if (getStyle("interactionMode") == InteractionMode.TOUCH)
                {
                    // If the content size changed, then the valid scroll position ranges 
                    // may have changed.  In this case, we need to schedule an updateComplete 
                    // handler to check and potentially correct the scroll positions. 
                    viewport.addEventListener(FlexEvent.UPDATE_COMPLETE, 
                        checkScrollPositionsOnUpdateComplete);
                }
                break;
        }
    }
    
    /**
     *  @private 
     *  Listens for any focusIn events from descendants 
     */ 
    override protected function focusInHandler(event:FocusEvent):void
    {
        super.focusInHandler(event);
        
        // When we gain focus, make sure the focused element is visible
        if (viewport && ensureElementIsVisibleForSoftKeyboard)
        {
            var elt:IVisualElement = focusManager.getFocus() as IVisualElement; 
            lastFocusedElement = elt;
        }
    }
    
    /**
     *  @private
     */ 
    override protected function focusOutHandler(event:FocusEvent):void
        {
        super.focusOutHandler(event);
        lastFocusedElement = null;
    }
    
    /**
     *  @private 
     */
    private function orientationChangeHandler(event:Event):void
    {
        if (getStyle("interactionMode") == InteractionMode.TOUCH)
        {
            // When the orientation (landscape/portrait) changes, then the valid
            // scroll position ranges may have changed.
            checkScrollPosition();
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods: IVisualElementContainer
    //
    //--------------------------------------------------------------------------

    /**
     *  Returns 1 if there is a viewport, 0 otherwise.
     * 
     *  @return The number of visual elements in this visual container
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get numElements():int
    {
        return viewport ? 1 : 0;
    }
    
    /**
     *  Returns the viewport if there is a viewport and the 
     *  index passed in is 0.  Otherwise, it throws a RangeError.
     *
     *  @param index The index of the element to retrieve.
     *
     *  @return The element at the specified index.
     * 
     *  @throws RangeError If the index position does not exist in the child list.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function getElementAt(index:int):IVisualElement
    {
        if (viewport && index == 0)
            return viewport;
        else
            throw new RangeError(resourceManager.getString("components", "indexOutOfRange", [index]));
    }
    
    /**
     *  Returns 0 if the element passed in is the viewport.  
     *  Otherwise, it throws an ArgumentError.
     *
     *  @param element The element to identify.
     *
     *  @return The index position of the element to identify.
     * 
     *  @throws ArgumentError If the element is not a child of this object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function getElementIndex(element:IVisualElement):int
    {
        if (element != null && element == viewport)
            return 0;
        else
            throw ArgumentError(resourceManager.getString("components", "elementNotFoundInScroller", [element]));
    }
    
    /**
     * 
     *  This operation is not supported in Scroller.  
     *  A Scroller control has only one child. 
     *  Use the <code>viewport</code> property to manipulate 
     *  it.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function addElement(element:IVisualElement):IVisualElement
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     *  This operation is not supported in Scroller.  
     *  A Scroller control has only one child.  Use the <code>viewport</code> property to manipulate 
     *  it.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function addElementAt(element:IVisualElement, index:int):IVisualElement
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     * 
     *  This operation is not supported in Scroller.  
     *  A Scroller control has only one child.  Use the <code>viewport</code> property to manipulate 
     *  it.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function removeElement(element:IVisualElement):IVisualElement
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     * 
     *  This operation is not supported in Scroller.  
     *  A Scroller control has only one child.  Use the <code>viewport</code> property to manipulate 
     *  it.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function removeElementAt(index:int):IVisualElement
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     * 
     *  This operation is not supported in Scroller.  
     *  A Scroller control has only one child. Use the <code>viewport</code> property to manipulate 
     *  it.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function removeAllElements():void
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     * 
     *  This operation is not supported in Scroller.  
     *  A Scroller control has only one child.  Use the <code>viewport</code> property to manipulate 
     *  it.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setElementIndex(element:IVisualElement, index:int):void
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     * 
     *  This operation is not supported in Scroller.  
     *  A Scroller control has only one child.  Use the <code>viewport</code> property to manipulate 
     *  it.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function swapElements(element1:IVisualElement, element2:IVisualElement):void
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     * 
     *  This operation is not supported in Scroller.  
     *  A Scroller control has only one child.  Use the <code>viewport</code> property to manipulate 
     *  it.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function swapElementsAt(index1:int, index2:int):void
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Helper Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Helper method to easily invalidate the skins's size and display list.
     */
    private function invalidateSkin():void
    {
        if (skin)
        {
            skin.invalidateSize()
            skin.invalidateDisplayList();
        }
    }
    
    /**
     *  @private
     *  Helper method to grab the ScrollerLayout.
     */
    mx_internal function get scrollerLayout():ScrollerLayout
    {
        if (skin)
            return Group(skin).layout as ScrollerLayout;
        
        return null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Touch scrolling methods
    //
    //--------------------------------------------------------------------------
	
    /**
     *  @private
     *  Add touch listeners
     */
    private function installTouchListeners():void
    {
        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        addEventListener(TouchInteractionEvent.TOUCH_INTERACTION_STARTING, touchInteractionStartingHandler);
        addEventListener(TouchInteractionEvent.TOUCH_INTERACTION_START, touchInteractionStartHandler);
        addEventListener(TouchInteractionEvent.TOUCH_INTERACTION_END, touchInteractionEndHandler);
        
        // capture mouse listeners to help block click and mousedown events.
        // mousedown is blocked when a scroll is in progress
        // click is blocked when a scroll is in progress (or just finished)
        addEventListener(MouseEvent.CLICK, touchScrolling_captureMouseHandler, true);
        addEventListener(MouseEvent.MOUSE_DOWN, touchScrolling_captureMouseHandler, true);
    }
    
    /**
     *  @private
     */
    private function uninstallTouchListeners():void
    {
        removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        removeEventListener(TouchInteractionEvent.TOUCH_INTERACTION_STARTING, touchInteractionStartingHandler);
        removeEventListener(TouchInteractionEvent.TOUCH_INTERACTION_START, touchInteractionStartHandler);
        removeEventListener(TouchInteractionEvent.TOUCH_INTERACTION_END, touchInteractionEndHandler);
        
        removeEventListener(MouseEvent.CLICK, touchScrolling_captureMouseHandler, true);
        removeEventListener(MouseEvent.MOUSE_DOWN, touchScrolling_captureMouseHandler, true);
    }
    
    
    /**
     *  @private
     *  Use the specified velocity to determine the duration of the throw effect
     */
    private function calculateThrowEffectTime(velocityX:Number, velocityY:Number):int
    {
        if (scrollerLayout)
        {
            // This calculates the effect duration based on a deceleration factor that is applied evenly over time.
            // We decay the velocity by the deceleration factor until it is less than 0.01/ms, which is rounded to zero pixels.
            // We want to solve for "time" in this equasion: velocity*(decel^time)-0.01 = 0.
            // Note that we are only calculating an effect duration here.  The actual curve of our throw velocity is determined by 
            // the exponential easing function we use between animation keyframes.
            var throwTimeX:int = velocityX == 0 ? 0 : (Math.log(0.01 / (Math.abs(velocityX)))) / Math.log(throwEffectDecelFactor);
            var throwTimeY:int = velocityY == 0 ? 0 : (Math.log(0.01 / (Math.abs(velocityY)))) / Math.log(throwEffectDecelFactor);

            if (scrollerLayout.canScrollHorizontally && scrollerLayout.canScrollVertically)
            {
                return Math.max(throwTimeX, throwTimeY);
            }
            else if (scrollerLayout.canScrollHorizontally) 
            {
                return throwTimeX;
            }
            else if (scrollerLayout.canScrollVertically) 
            {
                return throwTimeY;
            }
        }
        return 0;        
    }
    
    /**
     *  @private
     *  A utility function to add a new keyframe to the motion path and return the frame time.  
     */
    private function addKeyframe(motionPath:SimpleMotionPath,time:Number,position:Number,easer:IEaser):Number
    {
        var keyframe:Keyframe = new Keyframe(time,position);
        keyframe.easer = easer;
        motionPath.keyframes.push(keyframe);
        return time;
    }
    
    /**
     *  @private
     *  This function builds a motion path that reflects the starting conditions (position, velocity)
     *  and exhibits overshoot/settle/snap effects (aka bounce/pull) according to the min/max boundaries.
     */
    private function createThrowMotionPath(propertyName:String, velocity:Number, position:Number, minPosition:Number,
                                            maxPosition:Number, throwEffectTime:Number):SimpleMotionPath
    {
        var motionPath:SimpleMotionPath = new SimpleMotionPath(propertyName);
        motionPath.keyframes = Vector.<Keyframe>([new Keyframe(0, position)]);
        var keyframe:Keyframe = null;
        var nowTime:Number = 0;
        
        // First, we handle the case where the velocity is zero (finger wasn't significantly moving when lifted).
        // Ordinarily, we do nothing in this case, but if the list is currently scrolled past its end (i.e. "pulled"),
        // we need to have the animation move it back so none of the empty space is visible.
        if (velocity == 0)
        {
            if (position < minPosition || position > maxPosition)
            {
                // Velocity is zero and we're past the end of the list.  We want the 
                // list to "snap" back to its resting position at the end.  We use a 
                // cubic easer curve so the snap has high initial velocity and 
                // gradually decelerates toward the resting point.
                position = position < minPosition ? minPosition : maxPosition;
                nowTime = addKeyframe(motionPath, nowTime + THROW_SETTLE_TIME, position, new Power(0, THROW_CURVE_EXPONENT));
            }
            else
            {
                // Velocity zero without being past the end of the list is a no-op.
                return null;
            }
        }
        
        // Each iteration of this loop adds one of more keyframes to the motion path and then
        // updates the velocity and position values.  Once the velocity has decayed to zero,
        // the motion path is complete.
        while (velocity != 0.0)
        {
            if ((position < minPosition && velocity > 0) || (position > maxPosition && velocity < 0))
            {
                // We're past the end of the list and the velocity is directed further beyond
                // the end.  In this case we want to overshoot the end of the list and then 
                // settle back to it.
                var settlePosition:Number = position < minPosition ? minPosition : maxPosition;
                
                // OVERSHOOT_CURVE_EXPONENT is the default initial slope of the easer function we use for the overshoot.  
                // This calculation scales the y axis (distance) of the overshoot so the actual slope matches the velocity.
                var overshootPosition:Number = Math.round(position - 
                    ((velocity / OVERSHOOT_CURVE_EXPONENT) * THROW_OVERSHOOT_TIME));
                
                nowTime = addKeyframe(motionPath, nowTime + THROW_OVERSHOOT_TIME,
                    overshootPosition, new Power(0, OVERSHOOT_CURVE_EXPONENT));
                nowTime = addKeyframe(motionPath, nowTime + THROW_SETTLE_TIME, settlePosition, new Sine(0.25));
                
                // Clear the velocity to indicate that the motion path is complete.
                velocity = 0;
                position = settlePosition;
            }
            else
            {
                // Here we're going to do a "normal" throw.

                var effectTime:Number = throwEffectTime;
                
                var minVelocity:Number;
                if (position < minPosition || position > maxPosition)
                {
                    // The throw is starting beyond the end of the list.  We need to enforce a minimum velocity
                    // to make sure the throw makes it all the way back to the end (i.e. doesn't leave any blank area
                    // exposed) and does so within THROW_SETTLE_TIME.  THROW_SETTLE_TIME needs to be consistently
                    // adhered to in all cases where the tension of being beyond the end acts on the scroll position.  
                    
                    // The minimum velocity is that which gets us back to the end position in exactly THROW_SETTLE_TIME milliseconds. 
                    minVelocity = ((position - (position < minPosition ? minPosition : maxPosition)) / 
                        THROW_SETTLE_TIME) * THROW_CURVE_EXPONENT;
                    if (Math.abs(velocity) < Math.abs(minVelocity))
                    {   
                        velocity = minVelocity;
                        effectTime = THROW_SETTLE_TIME;
                    }
                }
                
                // The easer function we use is 1-((1-x)^THROW_CURVE_EXPONENT), which has an initial slope of THROW_CURVE_EXPONENT.
                // The x axis is scaled according to the throw duration we calculated above, so now we need
                // to determine the correct y-axis scaling (i.e. throw distance) such that the initial 
                // slope matches the specified throw velocity.
                var finalPosition:Number = Math.round(position - ((velocity / THROW_CURVE_EXPONENT) * effectTime));
                
                if (finalPosition < minPosition || finalPosition > maxPosition)
                {
                    // The throw is going to hit the end of the list.  In this case we need to clip the 
                    // deceleration curve at the appropriate point.  We want the curve to look exactly as
                    // it would if we were allowing the throw to go beyond the end of the list.  But the 
                    // keyframe we add here will stop exactly at the end.  The subsequent loop iteration
                    // will add keyframes that describe the overshoot & settle behavior.
                    
                    var endPosition:Number = finalPosition < minPosition ? minPosition : maxPosition;

                    // since easing function is f(t) = start + (final - start) * e(t)
                    // e(t) = Math.pow(1 - t/throwEffectTime, 3)
                    // We want to solve for t when e(t) = finalPosition
                    // t = throwEffectTime*(1-(Math.pow(1-((endPosition-position)/(finalVSP-position)),1/3)));
                    var partialTime:Number = 
                            effectTime*(1 - (Math.pow(1 - ((endPosition - position) / (finalPosition - position)), 1 / THROW_CURVE_EXPONENT)));
                    
                    // PartialExponentialCurve creates a portion of the throw easer curve, but scaled up to fill the 
                    // specified duration.
                    nowTime = addKeyframe(motionPath, nowTime + partialTime, endPosition,
                            new PartialExponentialCurve(THROW_CURVE_EXPONENT, partialTime / effectTime));
                    
                    // Set the position just past the end of the list for the next loop iteration.
                    if (finalPosition < minPosition)
                        position = minPosition - 1;
                    if (finalPosition > maxPosition)
                        position = maxPosition + 1;
                    
                    // Set the velocity for the next loop iteration.  Make sure it matches the actual velocity in effect when the 
                    // throw reaches the end of the list.
                    //
                    // The easer function we use for the throw is 1-((1-x)^3), the derivative of which is 3*x^2-6*x+3.
                    // (I used http://www.numberempire.com/derivatives.php to differentiate the easer function).
                    // Since the slope of a curve function at any point x (i.e. f(x)) is the value of the derivative at x (i.e. f'(x)),
                    // we can use this to determine the velocity of the throw at the point it reached the beginning of the bounce.
                    var x:Number = partialTime / effectTime;
                    var y:Number =  3 * Math.pow(x, 2) - 6 * x + 3; // NOTE: This calculation must be matched to the THROW_CURVE_EXPONENT value.
                    velocity = -y * (finalPosition - position) / effectTime; 
                }
                else
                {
                    // This is the simplest case.  The throw both begins and ends on the list (i.e. not past the 
                    // end of the list).  We create a single keyframe and clear the velocity to indicate that the
                    // motion path is complete.
                    // Note that we only use the first 62% of the actual deceleration curve, and stop the motion
                    // path at that point.  That's the point in time at which most throws animations get to within
                    // a single pixel of their final destination.  Since scrolling is done at whole pixel 
                    // boundaries, there's no point in letting the rest of the animation play out, and stopping it 
                    // allows us to release the mouse capture earlier for a better user experience.
                    const CURVE_PORTION:Number = 0.62;
                    nowTime = addKeyframe(
                        motionPath, nowTime + (effectTime*CURVE_PORTION), finalPosition, 
                        new PartialExponentialCurve(THROW_CURVE_EXPONENT,CURVE_PORTION));
                    velocity = 0;
                }
            }
        }
        return motionPath;
    }

    /**
     *  @private
     *  Set up the effect to be used for the throw animation
     */
    private function setUpThrowEffect(velocityX:Number, velocityY:Number):Boolean
    {
        // create throwEffect if we haven't already
        if (!throwEffect)
        {
            throwEffect = new Animate();
            throwEffect.addEventListener(EffectEvent.EFFECT_END, throwEffect_effectEndHandler);
            throwEffect.target = viewport;
            
            // effect and easer stuff should be combined some or maybe we just need one 
            // touch specific class rather than two
            var throwEaser:IEaser = new Power(0,THROW_CURVE_EXPONENT);
            throwEffect.easer = throwEaser;
        }
        
        // Calculate the effect duration
        var throwEffectTime:int = calculateThrowEffectTime(velocityX,velocityY);
        throwEffect.duration = throwEffectTime;

        var throwEffectMotionPaths:Vector.<MotionPath> = new Vector.<MotionPath>();
        
        throwReachedMaximumScrollPosition = false;
        scrollingHorizontally = false;
        var horizontalTime:Number = 0;
        var finalKeyframe:int;
        throwFinalHSP = 0;
        if (scrollerLayout && scrollerLayout.canScrollHorizontally)
        {
            var hsp:Number = viewport.horizontalScrollPosition;
            var viewportWidth:Number = isNaN(viewport.width) ? 0 : viewport.width;
            var cWidth:Number = viewport.contentWidth;
            var maxWidth:Number = 
                    Math.max(0, (cWidth == 0) ? viewport.horizontalScrollPosition : cWidth - viewportWidth);
            
            var horizontalMP:SimpleMotionPath = 
                    createThrowMotionPath("horizontalScrollPosition",velocityX,hsp,0,maxWidth,throwEffectTime);
            if (horizontalMP)
            { 
                throwEffectMotionPaths.push(horizontalMP);
                horizontalTime = horizontalMP.keyframes[horizontalMP.keyframes.length-1].time;
                throwFinalHSP = Number(horizontalMP.keyframes[horizontalMP.keyframes.length-1].value); 
                if (throwFinalHSP == maxWidth)
                    throwReachedMaximumScrollPosition = true;
                scrollingHorizontally = true;
            }
        }
        
        scrollingVertically = false;
        var verticalTime:Number = 0;
        throwFinalVSP = 0;
        if (scrollerLayout && scrollerLayout.canScrollVertically)
        {
            var vsp:Number = viewport.verticalScrollPosition;
            var viewportHeight:Number = isNaN(viewport.height) ? 0 : viewport.height;
            var cHeight:Number = viewport.contentHeight;
            var maxHeight:Number = 
                    Math.max(0, (cHeight == 0) ? viewport.verticalScrollPosition : cHeight - viewportHeight);
            
            var verticalMP:SimpleMotionPath = 
                    createThrowMotionPath("verticalScrollPosition",velocityY,vsp,0,maxHeight,throwEffectTime);
            if (verticalMP)
            {
                throwEffectMotionPaths.push(verticalMP);
                verticalTime = verticalMP.keyframes[verticalMP.keyframes.length-1].time;
                throwFinalVSP = Number(verticalMP.keyframes[verticalMP.keyframes.length-1].value); 
                if (throwFinalVSP == maxHeight)
                    throwReachedMaximumScrollPosition = true;
                scrollingVertically = true;
            }
        }
        
        if (throwEffectMotionPaths.length == 0)
        {
            touchScrollHelper.endTouchScroll();
            return false;
        }
        else
        {
            throwEffect.duration = Math.max(horizontalTime, verticalTime);
            throwEffect.motionPaths = throwEffectMotionPaths;
            return true;
        }
    }
        
    
    /**
     *  @private
     *  When the throw or drag scroll is over, we should play a nice 
     *  animation to hide the scrollbars.
     */
    private function hideScrollBars():void
    {
        if (!hideScrollBarAnimation)
        {
            hideScrollBarAnimation = new Animate();
            hideScrollBarAnimation.addEventListener(EffectEvent.EFFECT_END, hideScrollBarAnimation_effectEndHandler);
            hideScrollBarAnimation.duration = 500;
            var alphaMP:Vector.<MotionPath> = Vector.<MotionPath>([new SimpleMotionPath("alpha", 1, 0)]);
            hideScrollBarAnimation.motionPaths = alphaMP;
        }
        
        // set up the target scrollbars (hsb and/or vsb)
        var targets:Array = [];
        if (horizontalScrollBar && horizontalScrollBar.visible)
        {
            targets.push(horizontalScrollBar);
        }
        
        if (verticalScrollBar && verticalScrollBar.visible)
        {
            targets.push(verticalScrollBar);
        }
        
        // we keep track of hideScrollBarAnimationPrematurelyStopped so that we know 
        // if the effect ended naturally or if we prematurely called stop()
        hideScrollBarAnimationPrematurelyStopped = false;
        
        hideScrollBarAnimation.play(targets);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function createChildren():void
    {
        super.createChildren();
        
        var topLevelApp:Application = FlexGlobals.topLevelApplication as Application;
        
        // Only listen for softKeyboardEvents if the 
        // softKeyboardBehavior attribute in the application descriptor equals "none"
        // Check that the top level app has resizeForSoftKeyboard == true
        if (topLevelApp && topLevelApp.resizeForSoftKeyboard && Application.softKeyboardBehavior == "none")
        {
            addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, 
                softKeyboardActivateHandler, false, 
                EventPriority.DEFAULT, true);
            addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, 
                softKeyboardActivateCaptureHandler, true, 
                EventPriority.DEFAULT, true);
            addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, 
                softKeyboardDeactivateHandler, false, 
                EventPriority.DEFAULT, true);  
            addEventListener(CaretBoundsChangeEvent.CARET_BOUNDS_CHANGE,
                caretBoundsChangeHandler);
        }
    }
    
    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);
        
        var allStyles:Boolean = (styleProp == null || styleProp == "styleName");
        
        if (allStyles || styleProp == "horizontalScrollPolicy" || 
            styleProp == "verticalScrollPolicy")
        {
            invalidateSkin();
        }
        
        if (allStyles || styleProp == "interactionMode")
        {
            if (getStyle("interactionMode") == InteractionMode.TOUCH)
            {
                installTouchListeners();
                
                if (!touchScrollHelper)
                {
                    touchScrollHelper = new TouchScrollHelper(this);
                    touchScrollHelper.scrollSlop = Math.round(minSlopInches * flash.system.Capabilities.screenDPI);
                }
            }
            else
            {
                uninstallTouchListeners();
            }
        }
        
        // If the liveScrolling style was set, set the scrollbars' liveDragging styles
        
        if (allStyles || styleProp == "liveScrolling")
        {
            const liveScrolling:* = getStyle("liveScrolling");
            if ((liveScrolling === true) || (liveScrolling === false))
            {
                if (verticalScrollBar)
                    verticalScrollBar.setStyle("liveDragging", Boolean(liveScrolling));
                if (horizontalScrollBar)
                    horizontalScrollBar.setStyle("liveDragging", Boolean(liveScrolling));
            }
        }
    }

    /**
     *  @private
     */
    override protected function attachSkin():void
    {
        super.attachSkin();
        Group(skin).layout = new ScrollerLayout();
        installViewport();
        skin.addEventListener(MouseEvent.MOUSE_WHEEL, skin_mouseWheelHandler);
    }
    
    /**
     *  @private
     */
    override protected function detachSkin():void
    {    
        uninstallViewport();
        Group(skin).layout = null;
        skin.removeEventListener(MouseEvent.MOUSE_WHEEL, skin_mouseWheelHandler);
        super.detachSkin();
    }
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        const liveScrolling:* = getStyle("liveScrolling");
        const liveScrollingSet:Boolean = (liveScrolling === true) || (liveScrolling === false);
        
        if (instance == verticalScrollBar)
        {
            verticalScrollBar.viewport = viewport;
            if (liveScrollingSet)
                verticalScrollBar.setStyle("liveDragging", Boolean(liveScrolling));
        }
        
        else if (instance == horizontalScrollBar)
        {
            horizontalScrollBar.viewport = viewport;
            if (liveScrollingSet)
                horizontalScrollBar.setStyle("liveDragging", Boolean(liveScrolling));            
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == verticalScrollBar)
            verticalScrollBar.viewport = null;
        
        else if (instance == horizontalScrollBar)
            horizontalScrollBar.viewport = null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        super.keyDownHandler(event);

        var vp:IViewport = viewport;
        if (!vp || event.isDefaultPrevented())
            return;

        // If a TextField has the focus, then assume it will handle all keyboard
        // events, and that it will not use Event.preventDefault().
        if (getFocus() is TextField)
            return;
    
        if (verticalScrollBar && verticalScrollBar.visible)
        {
            var vspDelta:Number = NaN;
            switch (event.keyCode)
            {
                case Keyboard.UP:
                     vspDelta = vp.getVerticalScrollPositionDelta(NavigationUnit.UP);
                     break;
                case Keyboard.DOWN:
                     vspDelta = vp.getVerticalScrollPositionDelta(NavigationUnit.DOWN);
                     break;
                case Keyboard.PAGE_UP:
                     vspDelta = vp.getVerticalScrollPositionDelta(NavigationUnit.PAGE_UP);
                     break;
                case Keyboard.PAGE_DOWN:
                     vspDelta = vp.getVerticalScrollPositionDelta(NavigationUnit.PAGE_DOWN);
                     break;
                case Keyboard.HOME:
                     vspDelta = vp.getVerticalScrollPositionDelta(NavigationUnit.HOME);
                     break;
                case Keyboard.END:
                     vspDelta = vp.getVerticalScrollPositionDelta(NavigationUnit.END);
                     break;
            }
            if (!isNaN(vspDelta))
            {
                vp.verticalScrollPosition += vspDelta;
                event.preventDefault();
            }
        }

        if (horizontalScrollBar && horizontalScrollBar.visible)
        {
            var hspDelta:Number = NaN;
            switch (event.keyCode)
            {
                case Keyboard.LEFT:
                    hspDelta = (layoutDirection == LayoutDirection.LTR) ?
                        vp.getHorizontalScrollPositionDelta(NavigationUnit.LEFT) :
                        vp.getHorizontalScrollPositionDelta(NavigationUnit.RIGHT);
                    break;
                case Keyboard.RIGHT:
                    hspDelta = (layoutDirection == LayoutDirection.LTR) ?
                        vp.getHorizontalScrollPositionDelta(NavigationUnit.RIGHT) :
                        vp.getHorizontalScrollPositionDelta(NavigationUnit.LEFT);
                    break;
                case Keyboard.HOME:
                    hspDelta = vp.getHorizontalScrollPositionDelta(NavigationUnit.HOME);
                    break;
                case Keyboard.END:                
                    hspDelta = vp.getHorizontalScrollPositionDelta(NavigationUnit.END);
                    break;
                // If there's no vertical scrollbar, then map page up/down to
                // page left,right
                case Keyboard.PAGE_UP:
                     if (!verticalScrollBar || !(verticalScrollBar.visible)) 
                     {
                         hspDelta = (LayoutDirection.LTR) ?
                             vp.getHorizontalScrollPositionDelta(NavigationUnit.LEFT) :
                             vp.getHorizontalScrollPositionDelta(NavigationUnit.RIGHT);
                     }
                     break;
                case Keyboard.PAGE_DOWN:
                     if (!verticalScrollBar || !(verticalScrollBar.visible)) 
                     {
                         hspDelta = (LayoutDirection.LTR) ?
                             vp.getHorizontalScrollPositionDelta(NavigationUnit.RIGHT) :
                             vp.getHorizontalScrollPositionDelta(NavigationUnit.LEFT);
                     }
                     break;
            }
            if (!isNaN(hspDelta))
            {
                vp.horizontalScrollPosition += hspDelta;
                event.preventDefault();
            }
        }
    }
    
    private function skin_mouseWheelHandler(event:MouseEvent):void
    {
        const vp:IViewport = viewport;
        if (event.isDefaultPrevented() || !vp || !vp.visible)
            return;
            
        // Dispatch the "mouseWheelChanging" event. If preventDefault() is called
        // on this event, the event will be cancelled.  Otherwise if  the delta
        // is modified the new value will be used.
        var changingEvent:FlexMouseEvent = MouseEventUtil.createMouseWheelChangingEvent(event);
        if (!dispatchEvent(changingEvent))
        {
            event.preventDefault();
            return;
        }
        
        const delta:int = changingEvent.delta;
        
        var nSteps:uint = Math.abs(event.delta);
        var navigationUnit:uint;

        // Scroll delta "steps".  If the VSB is up, scroll vertically,
        // if -only- the HSB is up then scroll horizontally.
         
        // TODO: The problem is that viewport.validateNow() doesn’t necessarily 
        // finish the job, see http://bugs.adobe.com/jira/browse/SDK-25740.   
        // Since some imprecision in mouse-wheel scrolling is tolerable this is
        // ok for now.  For 4.next we should add Scroller API for (reliably) 
        // scrolling in different increments and refactor code like this to 
        // depend on it.  Also applies to VScroller and HScroller mouse
        // handlers.
        
        if (verticalScrollBar && verticalScrollBar.visible)
        {
            navigationUnit = (delta < 0) ? NavigationUnit.DOWN : NavigationUnit.UP;
            for (var vStep:int = 0; vStep < nSteps; vStep++)
            {
                var vspDelta:Number = vp.getVerticalScrollPositionDelta(navigationUnit);
                if (!isNaN(vspDelta))
                {
                    vp.verticalScrollPosition += vspDelta;
                    if (vp is IInvalidating)
                        IInvalidating(vp).validateNow();
                }
            }
            event.preventDefault();
        }
        else if (horizontalScrollBar && horizontalScrollBar.visible)
        {
            navigationUnit = (delta < 0) ? NavigationUnit.RIGHT : NavigationUnit.LEFT;
            for (var hStep:int = 0; hStep < nSteps; hStep++)
            {
                var hspDelta:Number = vp.getHorizontalScrollPositionDelta(navigationUnit);
                if (!isNaN(hspDelta))
                {
                    vp.horizontalScrollPosition += hspDelta;
                    if (vp is IInvalidating)
                        IInvalidating(vp).validateNow();
                }
            }
            event.preventDefault();
        }            
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers: Touch Scrolling
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Event handler dispatched when someone is about to start scrolling.
     */
    private function touchInteractionStartingHandler(event:TouchInteractionEvent):void
    {
        // if it's us, don't do anything
        // if it's someone else and we've started scrolling, cancel this event
        // if it's someone else and we haven't started scrolling, don't do anything
        // here yet. Worry about it in the touchInteractionStartHandler().
        if (event.relatedObject != this && (horizontalScrollInProgress || verticalScrollInProgress))
        {
            event.preventDefault();
        }
    }
    
    /**
     *  @private
     *  Event handler dispatched when someone has started scrolling.
     */
    private function touchInteractionStartHandler(event:TouchInteractionEvent):void
    {
        if (event.relatedObject != this)
        {
            // if it's not us scrolling, abort our scrolling attempt
            touchScrollHelper.stopScrollWatch();
        }
        else
        {
            // we are scrolling
            captureNextClick = true;
            captureNextMouseDown = true;
            preventThrows = false;
            
            hspBeforeTouchScroll = viewport.horizontalScrollPosition;
            vspBeforeTouchScroll = viewport.verticalScrollPosition;
            
            // TODO (rfrishbe): should the ScrollerLayout just listen to 
            // Scroller events to determine this rather than doing it here.
            // Also should figure out who's in charge of fading the alpha of the
            // scrollbars...Scroller or ScrollerLayout (or even HScrollbar/VScrollbar)?
            if (scrollerLayout && scrollerLayout.canScrollHorizontally)
                horizontalScrollInProgress = true;
            
            if (scrollerLayout && scrollerLayout.canScrollVertically)
                verticalScrollInProgress = true;
            
            // need to invaliadte the ScrollerLayout object so it'll update the
            // scrollbars in overlay mode
            skin.invalidateDisplayList();
            
            // make sure our alpha is set back to normal from hideScrollBarAnimation
            if (hideScrollBarAnimation && hideScrollBarAnimation.isPlaying)
            {
                // stop the effect, but make sure our code for EFFECT_END doesn't actually 
                // run since the effect didn't end on its own.
                hideScrollBarAnimationPrematurelyStopped = true;
                hideScrollBarAnimation.stop();
            }
            
            // We only show want the scroll bars to be visible if there's actually content to scroll.
            // This is true even if the scroll policy is "on" for the purposes of bounce/pull.
            if (horizontalScrollBar)
                horizontalScrollBar.alpha = viewport.contentWidth > viewport.width ? 1.0 : 0.0;
            
            if (verticalScrollBar)
                verticalScrollBar.alpha = viewport.contentHeight > viewport.height ? 1.0 : 0.0;
            
            inTouchInteraction = true;
        }
    }
    
    /**
     *  @private
     *  Snap the scroll positions to valid values.
     */
    private function snapContentScrollPosition():void
    {
        var maxHsp:Number = viewport.contentWidth > viewport.width ? 
            viewport.contentWidth-viewport.width : 0; 
        viewport.horizontalScrollPosition = 
            Math.min(Math.max(0,viewport.horizontalScrollPosition),maxHsp);

        var maxVsp:Number = viewport.contentHeight > viewport.height ? 
            viewport.contentHeight-viewport.height : 0; 
        viewport.verticalScrollPosition = 
            Math.min(Math.max(0,viewport.verticalScrollPosition),maxVsp);
    }
    
    /**
     *  @private
     *  Stop the effect if it's currently playing and prepare for a possible scroll
     */
    private function stopThrowEffectOnMouseDown():void
    {
        if (throwEffect && throwEffect.isPlaying)
        {
            // stop the effect.  we don't want to move it to its final value...we want to stop it in place
            stoppedPreemptively = true;
            throwEffect.stop();
                    
            // Snap the scroll position to the content in case the empty space beyond the edge was visible
            // due to bounce/pull.
            snapContentScrollPosition();
            
            // get new values in case we start scrolling again
            hspBeforeTouchScroll = viewport.horizontalScrollPosition;
            vspBeforeTouchScroll = viewport.verticalScrollPosition;
        }
    }
    
    /**
     *  @private
     *  Event listeners added while a scroll/throw animation is in effect
     */
    private function touchScrolling_captureMouseHandler(event:MouseEvent):void
    {
        switch(event.type)
        {
            case MouseEvent.MOUSE_DOWN:
                // If we get a mouse down when the throw animation is within a few
                // pixels of its final destination, we'll go ahead and stop the 
                // touch interaction and allow the event propogation to continue
                // so other handlers can see it.  Otherwise, we'll capture the 
                // down event and start watching for the next scroll.
                
                // 5 pixels at 252dpi worked fairly well for this heuristic.
                const THRESHOLD_INCHES:Number = 0.01984; // 5/252 
                var captureThreshold:Number = Math.round(THRESHOLD_INCHES * flash.system.Capabilities.screenDPI);
                
                // Need to convert the pixel delta to the local coordinate system in 
                // order to compare it to a scroll position delta. 
                captureThreshold = globalToLocal(
                    new Point(captureThreshold,0)).subtract(globalToLocal(ZERO_POINT)).x;

                if (captureNextMouseDown &&  
                    (Math.abs(viewport.verticalScrollPosition - throwFinalVSP) > captureThreshold || 
                     Math.abs(viewport.horizontalScrollPosition - throwFinalHSP) > captureThreshold))
                {
                    // Capture the down event.
                    stopThrowEffectOnMouseDown();
                    touchScrollHelper.startScrollWatch(event);
                    event.stopImmediatePropagation();
                }
                else
                {
                    // Stop the current throw and allow the down event
                    // to propogate normally.
                    if (throwEffect && throwEffect.isPlaying)
                    {
                        throwEffect.stop();
                        snapContentScrollPosition();
                    }
                }
                break;
            case MouseEvent.CLICK:
                if (!captureNextClick)
                    return;
                
                event.stopImmediatePropagation();
                break;
        }
    }
    
    /**
     *  @private
     *  Mousedown listener that adds the other listeners to watch for a scroll.
     */
    private function mouseDownHandler(event:MouseEvent):void
    {
        stopThrowEffectOnMouseDown();
        
        captureNextClick = false;
        
        touchScrollHelper.startScrollWatch(event);
    }
    	
    /**
     *  @private
     */
    mx_internal function performDrag(dragX:Number, dragY:Number):void
    {
        // dragX and dragY are delta value in the global coordinate space.
        // In order to use them to change the scroll position we must convert
        // them to the scroller's local coordinate space first.
        // This code converts the deltas from global to local.
        var localDragDeltas:Point = 
            globalToLocal(new Point(dragX,dragY)).subtract(globalToLocal(ZERO_POINT));
        dragX = localDragDeltas.x;
        dragY = localDragDeltas.y;

        var xMove:int = 0;
        var yMove:int = 0;
		
        if (scrollerLayout && scrollerLayout.canScrollHorizontally)
            xMove = dragX;
        
        if (scrollerLayout && scrollerLayout.canScrollVertically)
            yMove = dragY;
        
        var newHSP:Number = hspBeforeTouchScroll - xMove;
        var newVSP:Number = vspBeforeTouchScroll - yMove;
        
        var hsp:Number = viewport.horizontalScrollPosition;
        var viewportWidth:Number = isNaN(viewport.width) ? 0 : viewport.width;
        var cWidth:Number = viewport.contentWidth;
        var maxWidth:Number = Math.max(0, (cWidth == 0) ? viewport.horizontalScrollPosition : cWidth - viewportWidth);
        
        // If we're pulling the list past its end, we want it to move
        // only a portion of the finger distance to simulate tension.
        if (newHSP < 0)
            newHSP = Math.round(newHSP * PULL_TENSION_RATIO);
        if (newHSP > maxWidth)
            newHSP = Math.round(maxWidth + ((newHSP-maxWidth) * PULL_TENSION_RATIO));

        var vsp:Number = viewport.verticalScrollPosition;
        var viewportHeight:Number = isNaN(viewport.height) ? 0 : viewport.height;
        var cHeight:Number = viewport.contentHeight;
        var maxHeight:Number = Math.max(0, (cHeight == 0) ? viewport.verticalScrollPosition : cHeight - viewportHeight);
        
        if (newVSP < 0)
            newVSP = Math.round(newVSP * PULL_TENSION_RATIO);
        
        if (newVSP > maxHeight)
            newVSP = Math.round(maxHeight + ((newVSP-maxHeight) * PULL_TENSION_RATIO));
        
        // clamp the values here
        newHSP = Math.min(Math.max(newHSP, -viewportWidth), maxWidth+viewportWidth);
        newVSP = Math.min(Math.max(newVSP, -viewportHeight), maxHeight+viewportHeight);
		
        viewport.horizontalScrollPosition = newHSP;
        viewport.verticalScrollPosition = newVSP;
    }
    
    /**
     *  @private
     */ 
    private function throwEffect_effectEndHandler(event:EffectEvent):void
    {
        // if we stopped the effect ourself (because someone pressed down), then let's not consider
        // this the end
        if (stoppedPreemptively)
            return;
        
        touchScrollHelper.endTouchScroll();
    }
    
    /**
     *  @private
     */ 
    mx_internal function performThrow(velocityX:Number, velocityY:Number):void
    {   
        stoppedPreemptively = false;

        if (setUpThrowEffect(velocityX, velocityY))
            throwEffect.play();
    }
    
    /**
     *  @private
     *  When the throw is over, no need to listen for mouse events anymore.
     *  Also, use this to hide the scrollbars.
     */
    private function touchInteractionEndHandler(event:TouchInteractionEvent):void
    {
        if (event.relatedObject == this)
        {
            captureNextMouseDown = false;
            // don't reset captureNextClick here because touchScrollEnd
            // may be invoked on mouseUp and mouseClick occurs immediately 
            // after that, so we want to block this next mouseClick
            
            hideScrollBars();
            inTouchInteraction = false;
        }
    }
    
    /**
     *  @private
     *  Called when the effect finishes playing on the scrollbars.  This is so ScrollerLayout 
     *  can hide the scrollbars completely and go back to controlling its visibility.
     */
    private function hideScrollBarAnimation_effectEndHandler(event:EffectEvent):void
    {
        // distinguish between if we called stop() and if the effect ended naturally
        if (hideScrollBarAnimationPrematurelyStopped)
            return;
        
        // now get rid of the scrollbars visibility
        horizontalScrollInProgress = false;
        verticalScrollInProgress = false;
        
        // need to invalidate the ScrollerLayout object so it'll update the
        // scrollbars in overlay mode
        skin.invalidateDisplayList();
    }
	
	//--------------------------------------------------------------------------
	//
	//  Text selection auto scroll
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @private
	 *  When true, use the text selection scroll behavior instead of the 
	 *  typical "throw" behavior. This is only used when interactionMode="touch"
	 */
	mx_internal var textSelectionAutoScrollEnabled:Boolean = false;
	private var textSelectionAutoScrollTimer:Timer;
	private var minTextSelectionVScrollPos:int = 0;
	private var maxTextSelectionVScrollPos:int = -1;
	private var minTextSelectionHScrollPos:int = 0;
	private var maxTextSelectionHScrollPos:int = -1;
	private static const TEXT_SELECTION_AUTO_SCROLL_FPS:int = 10;
	
	/**
	 *  @private
	 *  Change scroll behavior when selecting text. 
	 */
	mx_internal function enableTextSelectionAutoScroll(enable:Boolean,
					   minHScrollPosition:int = 0, maxHScrollPosition:int = -1,
					   minVScrollPosition:int = 0, maxVScrollPosition:int = -1):void
	{
		if (getStyle("interactionMode") == InteractionMode.TOUCH)
		{
			this.textSelectionAutoScrollEnabled = enable;
			this.minTextSelectionHScrollPos = minHScrollPosition;
			this.maxTextSelectionHScrollPos = maxHScrollPosition;
			this.minTextSelectionVScrollPos = minVScrollPosition;
			this.maxTextSelectionVScrollPos = maxVScrollPosition;
		}
	}
	
	/**
	 *  @private
	 */
	mx_internal function setUpTextSelectionAutoScroll():void
	{
		if (!textSelectionAutoScrollTimer)
		{
			textSelectionAutoScrollTimer = new Timer(1000 / TEXT_SELECTION_AUTO_SCROLL_FPS);
			textSelectionAutoScrollTimer.addEventListener(TimerEvent.TIMER, 
				textSelectionAutoScrollTimerHandler);
			
			textSelectionAutoScrollTimer.start();
		}
	}
	
	/**
	 *  @private
	 */
	mx_internal function stopTextSelectionAutoScroll():void
	{
		if (textSelectionAutoScrollTimer)
		{
			textSelectionAutoScrollTimer.stop();
			textSelectionAutoScrollTimer.removeEventListener(TimerEvent.TIMER,
				textSelectionAutoScrollTimerHandler);
			textSelectionAutoScrollTimer = null;
		}
	}
	
	/**
	 *  @private
	 */
	private function textSelectionAutoScrollTimerHandler(event:TimerEvent):void
	{
		const SLOW_SCROLL_THRESHOLD:int = 12;		// Distance from edge to trigger a slow scroll
		const SLOW_SCROLL_SPEED:int = 20;			// Pixels per timer callback to scroll
		const FAST_SCROLL_THRESHOLD:int = 3;		// Distance from edge to trigger a fast scroll
		const FAST_SCROLL_DELTA:int = 30; 			// Added to SLOW_SCROLL_SPEED to determine fast speed
		
		var newVSP:Number = viewport.verticalScrollPosition;
		var newHSP:Number = viewport.horizontalScrollPosition;
		
		if (scrollerLayout.canScrollHorizontally)
		{
			if (mouseX > width - SLOW_SCROLL_THRESHOLD)
			{
				newHSP += SLOW_SCROLL_SPEED;
				
				if (mouseX > width - FAST_SCROLL_THRESHOLD)
					newHSP += FAST_SCROLL_DELTA;
				
				if (maxTextSelectionHScrollPos != -1 && newHSP > maxTextSelectionHScrollPos)
					newHSP = maxTextSelectionHScrollPos;
			}
			
			if (mouseX < SLOW_SCROLL_THRESHOLD)
			{
				newHSP -= SLOW_SCROLL_SPEED;
				
				if (mouseX < FAST_SCROLL_THRESHOLD)
					newHSP -= FAST_SCROLL_DELTA;
				
				if (newHSP < minTextSelectionHScrollPos)
					newHSP = minTextSelectionHScrollPos;
    		}
		}
		
		if (scrollerLayout.canScrollVertically)
		{
			if (mouseY > height - SLOW_SCROLL_THRESHOLD)
			{
				newVSP += SLOW_SCROLL_SPEED;
				
				if (mouseY > height - FAST_SCROLL_THRESHOLD)
					newVSP += FAST_SCROLL_DELTA;
				
				if (maxTextSelectionVScrollPos != -1 && newVSP > maxTextSelectionVScrollPos)
					newVSP = maxTextSelectionVScrollPos;
			}
			
			if (mouseY < SLOW_SCROLL_THRESHOLD)
			{
				newVSP -= SLOW_SCROLL_SPEED;
				
				if (mouseY < FAST_SCROLL_THRESHOLD)
					newVSP -= FAST_SCROLL_DELTA;
				
				if (newVSP < minTextSelectionVScrollPos)
					newVSP = minTextSelectionVScrollPos;
			}
		}
		
		if (newHSP != viewport.horizontalScrollPosition)
			viewport.horizontalScrollPosition = newHSP;
		if (newVSP != viewport.verticalScrollPosition)
			viewport.verticalScrollPosition = newVSP;
	}

    //--------------------------------------------------------------------------
    //
    //  Event handlers: SoftKeyboard Interaction
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */  
    private function addedToStageHandler(event:Event):void
    {
        if (getStyle("interactionMode") == InteractionMode.TOUCH)
            systemManager.stage.addEventListener("orientationChange",orientationChangeHandler);
    }
    
    /**
     *  @private
     */
    private function removedFromStageHandler(event:Event):void
    {
        if (getStyle("interactionMode") == InteractionMode.TOUCH)
            systemManager.stage.removeEventListener("orientationChange",orientationChangeHandler);
    }
    
    /**
     *  @private
     *  Called when the soft keyboard is activated. 
     * 
     *  There are three use cases for Scroller and text component interaction
     * 
     *  A. Pressing a TextInput to open up the soft keyboard
     *  B. Pressing in the middle of a TextArea to open up the soft keyboard
     *  C. Pressing in a text component on a device that doesn't support soft keyboard
     * 
     *  For use case A, lastFocusedElementCaretBounds is never set, so we just
     *  call ensureElementIsVisible on the TextInput
     * 
     *  For use case B, we first get a softKeyboard active event in the 
     *  capture phase. We then receive a caretBoundsChange event from the 
     *  TextArea skin. We store the bounds in lastFocusedElementCaretBounds
     *  and use that value in the call to ensureElementPositionIsVisible in
     *  the softKeyboard activate bubble phase. 
     * 
     *  For use case C, we never receive a soft keyboard activate event, so 
     *  we just listen for caretBoundsChange. 
     */  
    private function softKeyboardActivateHandler(event:SoftKeyboardEvent):void
    {
        preventThrows = true;

        // Size of app has changed, so run this logic again
        var keyboardRect:Rectangle = stage.softKeyboardRect;
        
        if (keyboardRect.width > 0 && keyboardRect.height > 0)
        {
            if (lastFocusedElement && ensureElementIsVisibleForSoftKeyboard &&
                (keyboardRect.height != oldSoftKeyboardHeight ||
                 keyboardRect.width != oldSoftKeyboardWidth))
            {
                // lastFocusedElementCaretBounds might have been set in the 
                // caretBoundsChange event handler
                if (lastFocusedElementCaretBounds == null)
                {
                    ensureElementIsVisible(lastFocusedElement);
                }
                else
                {
                    // Only show entire element if we just activated the soft keyboard
                    // If the predictive text bar showed up, we don't want the
                    // the element to jump
                    var isSoftKeyboardActive:Boolean = oldSoftKeyboardHeight > 0 || oldSoftKeyboardWidth > 0;
                    ensureElementPositionIsVisible(lastFocusedElement, lastFocusedElementCaretBounds, !isSoftKeyboardActive);   
                    lastFocusedElementCaretBounds = null;
                }
            }
            
            oldSoftKeyboardHeight = keyboardRect.height;
            oldSoftKeyboardWidth = keyboardRect.width;
        }
    }
    
    /**
     *  @private 
     *  Listen for softKeyboard activate in the capture phase so we know if
     *  we need to delay calling ensureElementPositionIsVisible if we get
     *  a caretBoundsChange event
     */ 
    private function softKeyboardActivateCaptureHandler(event:SoftKeyboardEvent):void
    {
        var keyboardRect:Rectangle = stage.softKeyboardRect;
        
        if (keyboardRect.width > 0 && keyboardRect.height > 0)
        {
            captureNextCaretBoundsChange = true;
        }
    }
    
    /**
     *  @private
     *  Called when the soft keyboard is deactivated. Tells the top level 
     *  application to resize itself and fix the scroll position if necessary
     */ 
    private function softKeyboardDeactivateHandler(event:SoftKeyboardEvent):void
    {   
        // Adjust the scroll position after the application's size is restored. 
        adjustScrollPositionAfterSoftKeyboardDeactivate();
        oldSoftKeyboardHeight = NaN;
        oldSoftKeyboardWidth = NaN;
        preventThrows = false;
    }
    
    /**
     *  @private
     */ 
    mx_internal function adjustScrollPositionAfterSoftKeyboardDeactivate():void
    {      
        // If the throw animation is still playing, stop it. Otherwise, fix the 
        // scroll position. 
        if (throwEffect && throwEffect.isPlaying)
            stopThrowEffectOnMouseDown();
        else
            snapContentScrollPosition();
    }
    
    /**
     *  @private
     * 
     *  If we just received a softKeyboardActivate event in the capture phase,
     *  we will wait until the bubble phase to call ensureElementPositionIsVisible
     *  For now, store the caret bounds to be used. 
     */
    private function caretBoundsChangeHandler(event:CaretBoundsChangeEvent):void
    {
        if (event.isDefaultPrevented())
            return;
        
        event.preventDefault();

        if (captureNextCaretBoundsChange)
        {
            lastFocusedElementCaretBounds = event.newCaretBounds;
            captureNextCaretBoundsChange = false;
            return;
        }
        
        // If caretBounds is changing, minimize the scroll
        ensureElementPositionIsVisible(lastFocusedElement, event.newCaretBounds, false, false);
    }
}

}

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.events.TouchEvent;
import flash.geom.Point;
import flash.utils.Timer;

import mx.core.mx_internal;
import mx.events.SandboxMouseEvent;
import mx.events.TouchInteractionEvent;
import mx.events.TouchInteractionReason;
import mx.utils.GetTimerUtil;

import spark.components.Scroller;

use namespace mx_internal;

/**
 *  @private
 *  Helper class to handle some of the touch scrolling logic.  Specifically
 *  it is used to handle some of the mouse tracking and velocity calculations.
 */
class TouchScrollHelper
{
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Number of mouse movements to keep in the history to calculate 
     *  velocity.
     */
    private static const EVENT_HISTORY_LENGTH:int = 5;
    
    /**
     *  @private
     *  Minimum velocity needed to start a throw gesture, in inches per second.
     */
    private static const MIN_START_VELOCITY_IPS:Number = 0.8;
    
    /**
     *  @private
     *  Maximum velocity of throw effect, in inches per second.
     */
    private static const MAX_THROW_VELOCITY_IPS:Number = 10.0;
    
    /**
     *  @private
     *  Maximum number of times per second we will change the scroll position 
     *  and update the display while dragging.
     */
    private static const MAX_DRAG_RATE:Number = 30;

    /**
     *  @private
     *  Weights to use when calculating velocity, giving the last velocity more of a weight 
     *  than the previous ones.
     */
    private static const VELOCITY_WEIGHTS:Vector.<Number> = Vector.<Number>([1,1.33,1.66,2]);
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor
     */
    public function TouchScrollHelper(scroller:Scroller)
    {
        super();
        
        mouseEventCoordinatesHistory = new Vector.<Point>(EVENT_HISTORY_LENGTH);
        mouseEventTimeHistory = new Vector.<int>(EVENT_HISTORY_LENGTH);
        
        this.scroller = scroller;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  scrollSlop - the scrolling threshold (minimum number of 
     *  pixels needed to move before a scroll gesture is recognized
     */
    public var scrollSlop:Number;
    
    /**
     *  @private
     *  Reference to the Scroller associated with this ScrollThrowHelper
     */
    public var scroller:Scroller;
    
    /**
     *  @private
     *  The point that was moused downed on for this scroll gesture
     */
    private var mouseDownedPoint:Point;
    
    /**
     *  @private
     *  The displayObject that was mousedowned on.
     */
    private var mouseDownedDisplayObject:DisplayObject;
    
    /**
     *  @private
     *  The point that a scroll was recognized from.
     * 
     *  <p>This is different from mouseDownedPoint because the user may 
     *  mousedown on one point, but a scroll isn't recognized until 
     *  they move more than the slop.  Because of this, we don't want
     *  the delta scrolled to be calculated from the mouseDowned point 
     *  because that would look jerky the first time a scroll occurred.</p>
     */
    private var scrollGestureAnchorPoint:Point;
    
    /**
     *  @private
     *  The delta coordinates of the most recent mouse event during a drag gesture
     */
    private var mostRecentDragDeltaX:Number;
    private var mostRecentDragDeltaY:Number;
    
    /**
     *  @private
     *  Timer used to do drag scrolling.
     */
    private var dragTimer:Timer = null;
    
    /**
     *  @private
     *  Indicates that the mouse coordinates have changed and the 
     *  next dragTimer invokation needs to do a scroll.
     */
    private var dragScrollPending:Boolean = false;
    
    /**
     *  @private
     *  The time the scroll started
     */
    private var startTime:Number;
    
    /**
     *  @private
     *  Keeps track of the coordinates where the mouse events 
     *  occurred.  We use this for velocity calculation along 
     *  with timeHistory.
     */
    private var mouseEventCoordinatesHistory:Vector.<Point>;
    
    /**
     *  @private
     *  Length of items in the mouseEventCoordinatesHistory and 
     *  timeHistory Vectors since a circular buffer is used to 
     *  conserve points.
     */
    private var mouseEventLength:Number = 0;
    
    /**
     *  @private
     *  A history of times the last few mouse events occurred.
     *  We keep HISTORY objects in memory, and we use this mouseEventTimeHistory
     *  Vector along with mouseEventCoordinatesHistory to determine the velocity
     *  a user was moving their fingers.
     */
    private var mouseEventTimeHistory:Vector.<int>;
    
    /**
     *  @private
     *  Whether we are currently in a scroll gesture or not.
     */
    private var isScrolling:Boolean;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Starts watching for a scroll operation.  This should take either 
     *  MouseEvent.MOUSE_DOWN or TouchEvent.TOUCH_BEGIN, but for now, only
     *  mousedown works.
     */
    public function startScrollWatch(event:Event):void
    {
        // this is the point from which all deltas are based.
        startTime = GetTimerUtil.getTimer();
        
        if (event is MouseEvent && event.type == MouseEvent.MOUSE_DOWN)
        {
            var mouseEvent:MouseEvent = event as MouseEvent;
            
            if (!isScrolling)
            {
                this.mouseDownedDisplayObject = mouseEvent.target as DisplayObject;
                
                mouseDownedPoint = new Point(mouseEvent.stageX, mouseEvent.stageY);
            }
            
            installMouseListeners();
            
            // if we were already scrolling, continue scrolling
            if (isScrolling)
            {
                scrollGestureAnchorPoint = new Point(mouseEvent.stageX, mouseEvent.stageY);
                mouseDownedPoint = new Point(mouseEvent.stageX, mouseEvent.stageY);
            }
            
            // reset circular buffer index/length
            mouseEventLength = 0;
            
            addMouseEventHistory(mouseEvent.stageX, mouseEvent.stageY);
        }
        else if (event is TouchEvent && event.type == TouchEvent.TOUCH_BEGIN)
        {
            // TouchEvent case
            // TODO (rfrishbe)
        }            
    }
    
    /**
     *  @private
     *  Starts watching for a scroll operation.
     */
    public function stopScrollWatch():void
    {
        uninstallMouseListeners();
    }
    
    /**
     *  @private
     *  Adds the time and mouse coordinates for this event in to 
     *  our mouse event history so that we can use it later to 
     *  calculate velocity.
     * 
     *  @return the delta moved between this mouse event and the start
     *          of the scroll gesture.
     */
    private function addMouseEventHistory(stageX:Number, stageY:Number):Point
    {
        // calculate dx, dy
        var dx:Number = stageX - mouseDownedPoint.x;
        var dy:Number = stageY - mouseDownedPoint.y;
        
        // either use a Point object already created or use one already created
        // in mouseEventCoordinatesHistory
        var currentPoint:Point;
        var currentIndex:int = (mouseEventLength % EVENT_HISTORY_LENGTH);
        if (mouseEventCoordinatesHistory[currentIndex])
        {
            currentPoint = mouseEventCoordinatesHistory[currentIndex];
            currentPoint.x = dx;
            currentPoint.y = dy;
        }
        else
        {
            currentPoint = new Point(dx, dy);
            mouseEventCoordinatesHistory[currentIndex] = currentPoint;
        }
        
        // add time history as well
        mouseEventTimeHistory[currentIndex] = GetTimerUtil.getTimer() - startTime;
        
        // increment current length if appropriate
        mouseEventLength ++;
        
        return currentPoint;
    }

    /**
     *  @private
     *  Installs mouse listeners to determine how far we've moved.
     */
    private function installMouseListeners():void
    {
        var sbRoot:DisplayObject = scroller.systemManager.getSandboxRoot();
        
        sbRoot.addEventListener(MouseEvent.MOUSE_MOVE, sbRoot_mouseMoveHandler, true);
        sbRoot.addEventListener(MouseEvent.MOUSE_UP, sbRoot_mouseUpHandler, true);
        sbRoot.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, sbRoot_mouseUpHandler);
        
        scroller.systemManager.deployMouseShields(true);
    }
    
    /**
     *  @private
     */
    private function uninstallMouseListeners():void
    {
        var sbRoot:DisplayObject = scroller.systemManager.getSandboxRoot();
        
        // mouse events added in installMouseListeners()
        sbRoot.removeEventListener(MouseEvent.MOUSE_MOVE, sbRoot_mouseMoveHandler, true);
        sbRoot.removeEventListener(MouseEvent.MOUSE_UP, sbRoot_mouseUpHandler, true);
        sbRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, sbRoot_mouseUpHandler);
        
        scroller.systemManager.deployMouseShields(false);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  If we are not scrolling, this is used to determine whether we should start 
     *  scrolling or not by checking if we've moved more than the slop.
     *  If we are scrolling, this is used to call scroller.touchScrollDragHandler()
     *  events and to determine how far the user has scrolled.
     */
    private function sbRoot_mouseMoveHandler(event:MouseEvent):void
    {
        var mouseDownedDifference:Point = 
            new Point(event.stageX - mouseDownedPoint.x, event.stageY - mouseDownedPoint.y);   
        
        if (!isScrolling)
        {
            var shouldBeScrolling:Boolean = false;
            
            var possibleScrollHorizontally:Boolean = false;
            var possibleScrollVertically:Boolean = false;
            
            // figure out if we can even scroll horizontally or vertically
            if (scroller.scrollerLayout && scroller.scrollerLayout.canScrollHorizontally)
                possibleScrollHorizontally = true;
            
            if (scroller.scrollerLayout && scroller.scrollerLayout.canScrollVertically)
                possibleScrollVertically = true;
            
            // now figure out if we should scroll horizontally or vertically based on our slop
            if (possibleScrollHorizontally && Math.abs(mouseDownedDifference.x) >= scrollSlop)
                shouldBeScrolling = true;
            if (possibleScrollVertically && Math.abs(mouseDownedDifference.y) >= scrollSlop)
                shouldBeScrolling = true;
            
            // If we should be scrolling, start scrolling
            if (shouldBeScrolling)
            {
                // Dispatch a cancellable and bubbling event to notify others
                var scrollStartingEvent:TouchInteractionEvent = new TouchInteractionEvent(TouchInteractionEvent.TOUCH_INTERACTION_STARTING, true, true);
                scrollStartingEvent.relatedObject = scroller;
                scrollStartingEvent.reason = TouchInteractionReason.SCROLL;
                var eventAccepted:Boolean = dispatchBubblingEventOnMouseDownedDisplayObject(scrollStartingEvent);
                
                // if the event was preventDefaulted(), then stop scrolling scrolling
                if (!eventAccepted)
                {                    
                    // TODO (rfrishbe): do we need to call updateAfterEvent() here and below?
                    event.updateAfterEvent();
                    
                    // calling stopScrollWatch() will remove all the appropriate listeners
                    stopScrollWatch();
                    
                    return;
                }
                
                // if the event has been accepted, then dispatch a bubbling start event
                var scrollStartEvent:TouchInteractionEvent = new TouchInteractionEvent(TouchInteractionEvent.TOUCH_INTERACTION_START, true, true);
                scrollStartEvent.relatedObject = scroller;
                scrollStartEvent.reason = TouchInteractionReason.SCROLL;
				dispatchBubblingEventOnMouseDownedDisplayObject(scrollStartEvent);
                
                isScrolling = true;
                
                // now that we're scrolling, calculate the scrollAnchorPoint.  
                // There are three cases: diagonal, horizontal, and vertical.
                // if (0,0) is where you mouseDowned, (10,10) is where you are at now.  Then mouseDownedDiff is (10, 10)
                // scrollAnchorPoint is calculated as where we "crossed the threshold" in to scrolling territory.
                // so we figure out if they scrolled up, down, right, left (or a combination of that for 
                // the diagonal case).
                if (possibleScrollHorizontally && possibleScrollVertically)
                {
                    // diagonal case
                    var maxAxisDistance:Number = Math.max(Math.abs(mouseDownedDifference.x),Math.abs(mouseDownedDifference.y));
                    if (maxAxisDistance >= scrollSlop)
                    {
                        var scrollAnchorDiffX:int;
                        var scrollAnchorDiffY:int;
                        
                        // The anchor point is the point at which the line described by mouseDownedDifference
                        // intersects with the perimeter of the slop area.  The slop area is a square with sides
                        // of length scrollSlop*2. 
                        var normalizedDiff:Point = mouseDownedDifference.clone();
                        
                        // Use the ratio of scrollSlop to maxAxisDistance to determine the length of the line
                        // from the mouse down point to the anchor point.
                        var lineLength:Number = (scrollSlop / maxAxisDistance) * mouseDownedDifference.length;  
                        
                        // Normalize to create a line of that length with the same angle it had before.
                        normalizedDiff.normalize(lineLength);
                        
                        // 4 possibilities: top-right, top-left, bottom-right, bottom-left
                        scrollAnchorDiffX = Math.round(normalizedDiff.x);
                        scrollAnchorDiffY = Math.round(normalizedDiff.y);
                        
                        scrollGestureAnchorPoint = new Point(mouseDownedPoint.x + scrollAnchorDiffX, 
                            mouseDownedPoint.y + scrollAnchorDiffY);
                    }
                }
                else if (possibleScrollHorizontally)
                {
                    // horizontal case
                    if (mouseDownedDifference.x >= scrollSlop)
                        scrollGestureAnchorPoint = new Point(mouseDownedPoint.x + scrollSlop, mouseDownedPoint.y);
                    else
                        scrollGestureAnchorPoint = new Point(mouseDownedPoint.x - scrollSlop, mouseDownedPoint.y);
                }
                else if (possibleScrollVertically)
                {
                    // vertical case
                    if (mouseDownedDifference.y >= scrollSlop)
                        scrollGestureAnchorPoint = new Point(mouseDownedPoint.x, mouseDownedPoint.y + scrollSlop);
                    else
                        scrollGestureAnchorPoint = new Point(mouseDownedPoint.x, mouseDownedPoint.y - scrollSlop);
                }
                
                // velocity calculations come from mouseDownedPoint.  The drag ones com from scrollStartPoint.
                // This seems fine.
            }
        }
        
        // if we are scrolling (even if we just started scrolling)
        if (isScrolling)
        {
			if (scroller.textSelectionAutoScrollEnabled)
			{
				scroller.setUpTextSelectionAutoScroll();
				return;
			}

            // calculate the delta
            var dx:Number = event.stageX - scrollGestureAnchorPoint.x;
            var dy:Number = event.stageY - scrollGestureAnchorPoint.y;
            
            if (!dragTimer)
            {
                dragTimer = new Timer(1000/MAX_DRAG_RATE, 0);
                dragTimer.addEventListener(TimerEvent.TIMER, dragTimerHandler);
            }
            
            if (!dragTimer.running)
            {
                // The drag timer is not running, so we record the event and scroll
                // the content immediately.
                addMouseEventHistory(event.stageX, event.stageY);
                scroller.performDrag(dx, dy);
                
                // Call updateAfterEvent() to make sure it looks smooth
                event.updateAfterEvent();
                
                // If event thinning is not enabled, we never start the timer so all subsequent
                // move event will continue to be handled right in this function.
                if (Scroller.dragEventThinning)
                {
                    // Start the periodic timer that will do subsequent drag 
                    // scrolling if necessary. 
                    dragTimer.start();
                    
                    // No additional mouse events received yet, so no scrolling pending.
                    dragScrollPending = false;
                }
            }
            else
            {
                // The drag timer is running, so we just save the delta coordinates
                // and indicate that a scroll is pending.
                mostRecentDragDeltaX = dx;
                mostRecentDragDeltaY = dy;
                dragScrollPending = true;
            }
        }
    }
    
    /**
     *  @private
     *  Used to periodically scroll during a drag gesture
     */
    private function dragTimerHandler(event:TimerEvent):void
    {
        if (dragScrollPending)
        {
            // A scroll is pending, so record the mouse deltas and scroll the content. 
            addMouseEventHistory(
                mostRecentDragDeltaX + scrollGestureAnchorPoint.x,
                mostRecentDragDeltaY + scrollGestureAnchorPoint.y);
            scroller.performDrag(mostRecentDragDeltaX, mostRecentDragDeltaY);
            
            // Call updateAfterEvent() to make sure it looks smooth
            event.updateAfterEvent();

            // No scroll is pending now. 
            dragScrollPending = false;
        }
        else
        {
            // The timer elapsed with no mouse events, so we'll
            // just turn the timer off for now.  It will get turned
            // back on if another mouse event comes in.
            dragTimer.stop();
        }
    }

    /**
     *  @private
     *  Called when the user releases the mouse/touches up
     */
    private function sbRoot_mouseUpHandler(event:Event):void
    {
        uninstallMouseListeners();
        
        // If we weren't already scrolling, then let's not start scrolling now
        if (!isScrolling)
            return;
       
		// Don't throw if we're doing a text selection auto scroll
		if (scroller.textSelectionAutoScrollEnabled)
		{
			scroller.stopTextSelectionAutoScroll();
			endTouchScroll();
			return;
		}
		
        if (dragTimer)
        {
            if (dragScrollPending)
            {
                // A scroll is pending, so record the mouse deltas and scroll
                // the content.
                addMouseEventHistory(
                    mostRecentDragDeltaX + scrollGestureAnchorPoint.x,
                    mostRecentDragDeltaY + scrollGestureAnchorPoint.y);
                scroller.performDrag(mostRecentDragDeltaX, mostRecentDragDeltaY);

                // Call updateAfterEvent() to make sure it looks smooth
                if (event is MouseEvent)
                    MouseEvent(event).updateAfterEvent();
            }
            
            // The drag gesture is over, so we no longer need the timer.
            dragTimer.stop();
            dragTimer.removeEventListener(TimerEvent.TIMER, dragTimerHandler);
            dragTimer = null;
        }
        
        // If the soft keyboard is up (or about to come up), don't start a throw.
        if (scroller.preventThrows)
        {
            endTouchScroll();
            return;
        }

        // This could be a SanboxMouseEvent
        if (event is MouseEvent)
            addMouseEventHistory(MouseEvent(event).stageX, MouseEvent(event).stageY);
        
        // decide about throw
        
        // pad click and timeHistory if needed
        var currentTime:Number = GetTimerUtil.getTimer();
        
        // calculate average time b/w events and see if the last two (mouseMove and this mouseUp) 
        // were far apart.  If they were, then don't do anything if the velocity of them is small.
        var averageDt:Number = 0;
        var len:int = (mouseEventLength > EVENT_HISTORY_LENGTH ? EVENT_HISTORY_LENGTH : mouseEventLength);
        
        // if haven't wrapped around, then startIndex = 0.  If we've wrapped around, 
        // then startIndex = mouseEventLength % EVENT_HISTORY_LENGTH.  The equation 
        // below handles both of those cases
        const startIndex:int = ((mouseEventLength - len) % EVENT_HISTORY_LENGTH);
        const endIndex:int = ((mouseEventLength - 1) % EVENT_HISTORY_LENGTH);
        
        // gauranteed to have 2 mouse events b/c atleast a mousedown and a mousemove 
        // because if there was no mousemove, we definitely would not be scrolling and 
        // would have exited this function earlier
        var currentIndex:int = startIndex;
        while (currentIndex != endIndex)
        {
            // calculate nextIndex here so we can use it in the calculations
            var nextIndex:int = ((currentIndex + 1) % EVENT_HISTORY_LENGTH);
            
            averageDt += mouseEventTimeHistory[nextIndex] - mouseEventTimeHistory[currentIndex];
            
            currentIndex = nextIndex;
        }
        averageDt /= len-1;
        
		// if off screen for some reason, let's end scrolling:
		if (!scroller.stage)
		{
            endTouchScroll();
			return;
		}
		
        var lastMouseEventPoint:Point = mouseEventCoordinatesHistory[endIndex];

        // calculate the last velocity and make sure there was no pause that occurred
        var indexBeforeLast:int = ((mouseEventLength - 2) % EVENT_HISTORY_LENGTH);
        var lastDt:Number = mouseEventTimeHistory[endIndex] - mouseEventTimeHistory[indexBeforeLast];
        var lastVelocity:Point = lastMouseEventPoint.subtract(mouseEventCoordinatesHistory[indexBeforeLast]);
        lastVelocity.x /= lastDt;
        lastVelocity.y /= lastDt;
        
        var minVelocityPixels:Number = MIN_START_VELOCITY_IPS * flash.system.Capabilities.screenDPI / 1000;
        
        var scrollEndEvent:TouchInteractionEvent;
        
        // calculate the velocity using a weighted average
        var throwVelocity:Point = calculateThrowVelocity();
        if (throwVelocity.length <= minVelocityPixels)
        {
            throwVelocity.x = 0;
            throwVelocity.y = 0;
        }

        // If the gesture appears to have slowed or stopped prior to the mouse up, 
        // then force the velocity to zero.
        if ( (lastDt >= 3*averageDt) &&
            (lastVelocity.length <= minVelocityPixels))
        {
            throwVelocity.x = 0;
            throwVelocity.y = 0;
        }
        
        // The velocity values are deltas in the global coordinate space.
        // In order to use them to change the scroll position we must convert
        // them to the scroller's local coordinate space first.
        // This code converts the deltas from global to local.
        //        
        // Note that we scale the velocity values up and then back down around the 
        // calls to globalToLocal.  This is because the runtime only returns values
        // rounded to the nearest 0.05.  The velocities are small number (<4.0) with 
        // lots of precision that we don't want to lose.  The scaling preserves
        // a sufficient level of precision for our purposes.
        throwVelocity.x *= 100000;
        throwVelocity.y *= 100000;
        
        // Because we subtract out the difference between the two coordinate systems' origins,
        // This is essentially just multiplying by a scaling factor.
        throwVelocity = 
            scroller.globalToLocal(throwVelocity).subtract(scroller.globalToLocal(new Point(0,0)));

        throwVelocity.x /= 100000;
        throwVelocity.y /= 100000;
        
        // Note that we always call performThrow - even when the velocity is zero.
        // This is needed because we may be past the end of the list and need an 
        // animation to get us back.
        scroller.performThrow(throwVelocity.x, throwVelocity.y);
        }
    
    /**
     *  @private
     *  Helper function to calculate the current throwVelocity().
     *  
     *  <p>It calculates the velocities and then calculates a weighted 
     *  average from them.</p>
     */
    private function calculateThrowVelocity():Point
    {
        var len:int = (mouseEventLength > EVENT_HISTORY_LENGTH ? EVENT_HISTORY_LENGTH : mouseEventLength);
        
        // we are guarenteed to have 2 items here b/c of mouseDown and a mouseMove
        
        // if haven't wrapped around, then startIndex = 0.  If we've wrapped around, 
        // then startIndex = mouseEventLength % EVENT_HISTORY_LENGTH.  The equation 
        // below handles both of those cases
        const startIndex:int = ((mouseEventLength - len) % EVENT_HISTORY_LENGTH);
        const endIndex:int = ((mouseEventLength - 1) % EVENT_HISTORY_LENGTH);
        
        // variables to store a running average
        var weightedSumX:Number = 0;
        var weightedSumY:Number = 0;
        var totalWeight:Number = 0;
        
        var currentIndex:int = startIndex;
        var i:int = 0;
        while (currentIndex != endIndex)
        {
            // calculate nextIndex early so we can re-use it for these calculations
            var nextIndex:int = ((currentIndex + 1) % EVENT_HISTORY_LENGTH);
            
            // Get dx, dy, and dt
            var dt:Number = mouseEventTimeHistory[nextIndex] - mouseEventTimeHistory[currentIndex];
            var dx:Number = mouseEventCoordinatesHistory[nextIndex].x - mouseEventCoordinatesHistory[currentIndex].x;
            var dy:Number = mouseEventCoordinatesHistory[nextIndex].y - mouseEventCoordinatesHistory[currentIndex].y;
            
            if (dt != 0)
            {
                // calculate a weighted sum for velocities
                weightedSumX += (dx/dt) * VELOCITY_WEIGHTS[i];
                weightedSumY += (dy/dt) * VELOCITY_WEIGHTS[i];
                totalWeight += VELOCITY_WEIGHTS[i];
            }
            
            currentIndex = nextIndex;
            i++;
        }
        
        if (totalWeight == 0)
            return new Point(0,0);
        
        // Limit the velocity to an absolute maximum
        var maxPixelsPerMS:Number = MAX_THROW_VELOCITY_IPS * flash.system.Capabilities.screenDPI / 1000;
        var velX:Number = Math.min(maxPixelsPerMS,Math.max(-maxPixelsPerMS,weightedSumX/totalWeight));
        var velY:Number = Math.min(maxPixelsPerMS,Math.max(-maxPixelsPerMS,weightedSumY/totalWeight));
        
        return new Point(velX,velY);
    }
	
	/**
	 *  @private
	 *  Helper method to dispatch bubbling events on mouseDownDisplayObject.  Since this 
	 *  object can be off the display list, this may be tricky.  Technically, we should 
	 *  grab all the live objects at the time of mouseDown and dispatch events to them 
	 *  manually, but instead, we just use this heuristic, which is dispatch it to 
	 *  mouseDownedDisplayObject.  If it's not inside of scroller and off the display list,
	 *  then dispatch to scroller as well.
	 * 
	 *  <p>If you absolutely need to know the touch event ended, add event listeners 
	 *  to the mouseDownedDisplayObject directly and don't rely on event 
	 *  bubbling.</p>
	 */
	private function dispatchBubblingEventOnMouseDownedDisplayObject(event:Event):Boolean
	{
		var eventAccepted:Boolean = true;
		if (mouseDownedDisplayObject)
		{
			eventAccepted = eventAccepted && mouseDownedDisplayObject.dispatchEvent(event);
			if (!mouseDownedDisplayObject.stage)
			{
				if (scroller && !scroller.contains(mouseDownedDisplayObject))
					eventAccepted = eventAccepted && scroller.dispatchEvent(event);
			}
		}
		else
		{
			eventAccepted = eventAccepted && scroller.dispatchEvent(event);
		}
		
		return eventAccepted;
	}
	
    /**
     *  @private
     *  When the touchScrollThrow is over, we should dispatch a touchInteractionEnd.
     */
    public function endTouchScroll():void
    {
        if (isScrolling)
        {
            isScrolling = false;
            
            var scrollEndEvent:TouchInteractionEvent = new TouchInteractionEvent(TouchInteractionEvent.TOUCH_INTERACTION_END, true);
            scrollEndEvent.relatedObject = scroller;
            scrollEndEvent.reason = TouchInteractionReason.SCROLL;
            dispatchBubblingEventOnMouseDownedDisplayObject(scrollEndEvent);
        }
    }

}
    
import spark.effects.easing.EaseInOutBase;
    
/**
 *  @private
 *  A custom ease-out-only easer class which animates along a specified 
 *  portion of an exponential curve.  
 */
class PartialExponentialCurve extends EaseInOutBase
{
    public function PartialExponentialCurve(exponent:Number,xscale:Number)
    {
        super(0);
        _exponent = exponent;
        _xscale = xscale;
        _ymult = 1 / (1 - Math.pow(1 - _xscale,_exponent));
    }
    
    override protected function easeOut(fraction:Number):Number
    {
        return _ymult * (1 - Math.pow(1 - fraction*_xscale, _exponent)); 
    }
    private var _xscale:Number;
    private var _ymult:Number;
    private var _exponent:Number;
}
    
