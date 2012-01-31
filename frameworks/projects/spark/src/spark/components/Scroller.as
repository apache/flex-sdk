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
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.system.ApplicationDomain;
import flash.text.TextField;
import flash.ui.Keyboard;

import mx.core.IInvalidating;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.LayoutDirection;
import mx.core.ScrollPolicy;
import mx.events.EffectEvent;
import mx.events.PropertyChangeEvent;
import mx.managers.IFocusManagerComponent;

import spark.components.Group;
import spark.components.supportClasses.ScrollerLayout;
import spark.components.supportClasses.SkinnableComponent;
import spark.components.supportClasses.TouchScrollingEasing;
import spark.core.IViewport;
import spark.core.NavigationUnit;
import spark.effects.Animate;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.events.TouchScrollEvent;

include "../styles/metadata/BasicInheritingTextStyles.as"
include "../styles/metadata/AdvancedInheritingTextStyles.as"
include "../styles/metadata/SelectionFormatTextStyles.as"

/**
 *  @copy spark.components.supportClasses.GroupBase#style:alternatingItemColors
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes", theme="spark")]

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
 *  @copy spark.components.supportClasses.GroupBase#style:contentBackgroundColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:focusColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark")]

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
 * @copy spark.components.supportClasses.GroupBase#style:rollOverColor
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
[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark")]

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
 *  Therefore, those containers, such as the Border and SkinnableContainer containers, 
 *  cannot be used as the direct child of the Scroller component.
 *  However, all Spark containers can have a Scroller component as a child component. 
 *  For example, to use scroll bars on a child of the Spark Border container, 
 *  wrap the child in a Scroller component. </p>
 *
 *  <p>To make the entire Border container scrollable, wrap it in a Group container. 
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
 *    color="0"
 *    contentBackgroundAlpha=""
 *    contentBackgroundColor=""
 *    digitCase="default"
 *    digitWidth="default"
 *    direction="LTR"
 *    dominantBaseline="auto"
 *    firstBaselineOffset="auto"
 *    focusColor=""
 *    focusedTextSelectionColor=""
 *    fontFamily="Times New Roman"
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
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    private function invalidateSkin():void
    {
        if (skin)
        {
            skin.invalidateSize()
            skin.invalidateDisplayList();
        }
    }    
    
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
    
    [Inspectable(category="General")]

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
    // Event Handlers
    //
    //--------------------------------------------------------------------------

    
    private function viewport_propertyChangeHandler(event:PropertyChangeEvent):void
    {
        switch(event.property) 
        {
            case "contentWidth": 
            case "contentHeight": 
                invalidateSkin();
                break;
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
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
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
        
        if (allStyles || styleProp == "inputMode")
        {
            if (getStyle("inputMode") == "touch")
            {
                installTouchListeners();
                
                touchScrollHelper = new TouchScrollHelper(this);
                touchScrollHelper.horizontalSlop = MIN_HORIZONTAL_SLOP;
                touchScrollHelper.verticalSlop = MIN_VERTICAL_SLOP;
                touchScrollHelper.diagonalSlop = MIN_DIAGONAL_SLOP;
            }
            else
            {
                uninstallTouchListeners();
            }
        }
    }
    
    /**
     *  @private
     */
    private function installTouchListeners():void
    {
        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        addEventListener(TouchScrollEvent.TOUCH_SCROLL_STARTING, touchScrollStartingHandler);
        addEventListener(TouchScrollEvent.TOUCH_SCROLL_START, touchScrollStartHandler);
        addEventListener(TouchScrollEvent.TOUCH_SCROLL_DRAG, touchScrollDragHandler);
        addEventListener(TouchScrollEvent.TOUCH_SCROLL_END, touchScrollEndHandler);
        addEventListener(TouchScrollEvent.TOUCH_SCROLL_THROW, touchScrollThrowHandler);
    }
    
    // ScrollerLayout vars
    public var horizontalScrollInProgress:Boolean = false;
    public var verticalScrollInProgress:Boolean = false;
    
    // SLOP CONSTANTS
    private static const MIN_HORIZONTAL_SLOP:int = 10;
    private static const MIN_VERTICAL_SLOP:int = 10;
    private static const MIN_DIAGONAL_SLOP:int = 10;
    
    /**
     *  @private
     */
    private function uninstallTouchListeners():void
    {
        removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        removeEventListener(TouchScrollEvent.TOUCH_SCROLL_STARTING, touchScrollStartingHandler);
        removeEventListener(TouchScrollEvent.TOUCH_SCROLL_START, touchScrollStartHandler);
        removeEventListener(TouchScrollEvent.TOUCH_SCROLL_END, touchScrollEndHandler);
        removeEventListener(TouchScrollEvent.TOUCH_SCROLL_DRAG, touchScrollDragHandler);
        removeEventListener(TouchScrollEvent.TOUCH_SCROLL_THROW, touchScrollThrowHandler);
    }
    
    private function touchScrollStartingHandler(event:TouchScrollEvent):void
    {
        if (event.scrollingObject != this)
        {
            touchScrollHelper.stopScrollWatch();
        }
    }
    
    private function touchScrollStartHandler(event:TouchScrollEvent):void
    {
        installSwallowingMouseHandlers();
        hspBeforeTouchScroll = viewport.horizontalScrollPosition;
        vspBeforeTouchScroll = viewport.verticalScrollPosition;
        
        if (viewport.scrollAxis == "horizontal" || viewport.scrollAxis == "diagonal")
            horizontalScrollInProgress = true;
        if (viewport.scrollAxis == "vertical" || viewport.scrollAxis == "diagonal")
            verticalScrollInProgress = true;
        
        // need to invaliadte the ScrollerLayout object so it'll update the
        // scrollbars in overlay mode
        skin.invalidateDisplayList();
    }
    
    private function installSwallowingMouseHandlers():void
    {
        // block click events from occuring on me
        addEventListener(MouseEvent.CLICK, touchScrolling_captureMouseHandler, true);
        addEventListener(MouseEvent.MOUSE_DOWN, touchScrolling_captureMouseHandler, true);
//        addEventListener(MouseEvent.MOUSE_OVER, touchScrolling_captureMouseHandler, true);
//        addEventListener(MouseEvent.ROLL_OVER, touchScrolling_captureMouseHandler, true);
    }
    
    private function uninstallSwallowingMouseHandlers():void
    {
        removeEventListener(MouseEvent.CLICK, touchScrolling_captureMouseHandler, true);
        removeEventListener(MouseEvent.MOUSE_DOWN, touchScrolling_captureMouseHandler, true);
//        removeEventListener(MouseEvent.MOUSE_OVER, touchScrolling_captureMouseHandler, true);
//        removeEventListener(MouseEvent.ROLL_OVER, touchScrolling_captureMouseHandler, true);
    }
    
    private var stoppedPreemptively:Boolean = false;
    
    private function touchScrolling_captureMouseHandler(event:MouseEvent):void
    {
        switch(event.type)
        {
            case MouseEvent.MOUSE_DOWN:
                if (throwEffect && throwEffect.isPlaying)
                {
                    // stop the effect.  we don't want to move it to its final value...we want to stop it in place
                    // FIXME (rfrishbe): however if it's below 0 or above maxVSP, we should snap it to these values
                    stoppedPreemptively = true;
                    throwEffect.stop();
                    
                    // get new values in case we start scrolling again
                    hspBeforeTouchScroll = viewport.horizontalScrollPosition;
                    vspBeforeTouchScroll = viewport.verticalScrollPosition;
                }
                
                touchScrollHelper.startScrollWatch(event);
                event.stopImmediatePropagation();
                break;
            case MouseEvent.ROLL_OVER:
            case MouseEvent.MOUSE_OVER:
            case MouseEvent.CLICK:
                event.stopImmediatePropagation();
                break;
        }
    }
    
    private function mouseDownHandler(event:MouseEvent):void
    {
        // FIXME (rfrishbe): if currently scrolling, we should stop scrolling 
        // and move the VSP/HSP in to range (0, maxVSP).
               
        touchScrollHelper.startScrollWatch(event);
    }
    
    private var touchScrollHelper:TouchScrollHelper;
    private var hspBeforeTouchScroll:Number;
    private var vspBeforeTouchScroll:Number;
    
    private function touchScrollDragHandler(event:TouchScrollEvent):void
    {
        var xMove:int = 0;
        var yMove:int = 0;
        
        if (viewport.scrollAxis == "horizontal" || viewport.scrollAxis == "diagonal")
            xMove = event.dragX;
        
        if (viewport.scrollAxis == "vertical" || viewport.scrollAxis == "diagonal")
            yMove = event.dragY

        // FIXME (rfrishbe): figure out how we want negative signs to work
        viewport.horizontalScrollPosition = hspBeforeTouchScroll - xMove;
        viewport.verticalScrollPosition = vspBeforeTouchScroll - yMove;
    }
    
    private function touchScrollEndHandler(event:TouchScrollEvent):void
    {
        horizontalScrollInProgress = false;
        verticalScrollInProgress = false;
        uninstallSwallowingMouseHandlers();
        
        // need to invaliadte the ScrollerLayout object so it'll update the
        // scrollbars in overlay mode
        skin.invalidateDisplayList();
    }
    
    private var throwEaser:TouchScrollingEasing;
    private var EFFECT_TIME:int = 3000;
    private var throwEffect:Animate;
    
    private function setUpThrowEffect(velocity:Point):void
    {
        if (!throwEffect)
        {
            throwEffect = new Animate();
            throwEffect.addEventListener(EffectEvent.EFFECT_END, throwEffect_effectEndHandler);
            
            throwEaser = new TouchScrollingEasing(0);
        }
        var finalHSP:Number = viewport.horizontalScrollPosition;
        var finalVSP:Number = viewport.verticalScrollPosition;
        
        // want velocity to be 0 and to decrease by currentFriction every 
        // SCROLLING_TIMER_DELAY over EFFECT_TIME total
        var decelerationRate:Point = velocity.clone();
        decelerationRate.x = decelerationRate.x/EFFECT_TIME;
        decelerationRate.y = decelerationRate.y/EFFECT_TIME;
        
        // figure out where we're scrolling to
        if (viewport.scrollAxis == "horizontal" || viewport.scrollAxis == "diagonal")
        {
            var hsp:Number = viewport.horizontalScrollPosition;
            var viewportWidth:Number = isNaN(viewport.width) ? 0 : viewport.width;
            var cWidth:Number = viewport.contentWidth;
            var maxWidth:Number = Math.max(0, (cWidth == 0) ? viewport.horizontalScrollPosition : cWidth - viewportWidth);
            
            // initialVelocity.y * ellapsedTime - (0.5 * frictionToUse * ellapsedTime * ellapsedTime);
            finalHSP = viewport.horizontalScrollPosition - (velocity.x * EFFECT_TIME) + (.5 * decelerationRate.x * EFFECT_TIME * EFFECT_TIME);
//            finalHSP = Math.max(0, Math.min(finalHSP, maxWidth));
            
        }
        
        if (viewport.scrollAxis == "vertical" || viewport.scrollAxis == "diagonal")
        {
            var vsp:Number = viewport.verticalScrollPosition;
            var viewportHeight:Number = isNaN(viewport.height) ? 0 : viewport.height;
            var cHeight:Number = viewport.contentHeight;
            var maxHeight:Number = Math.max(0, (cHeight == 0) ? viewport.verticalScrollPosition : cHeight - viewportHeight);
            
            // initialVelocity.y * ellapsedTime - (0.5 * frictionToUse * ellapsedTime * ellapsedTime);
            finalVSP = viewport.verticalScrollPosition - (velocity.y * EFFECT_TIME) + (.5 * decelerationRate.y * EFFECT_TIME * EFFECT_TIME);
//            finalVSP = Math.max(0, Math.min(finalVSP, maxHeight));
        }
        
        // set up easer.  Sometimes these values won't be exactly right, but it shouldn't 
        // matter if maxHeight is wrong as long as we aren't actually moving it around
        // in that axis.
        throwEaser.velocity = velocity;
        throwEaser.maxHeight = maxHeight;
        throwEaser.maxWidth = maxWidth;
        throwEaser.maxExtraY = viewportHeight;
        throwEaser.maxExtraX = viewportWidth;
        
        // FIXME (rfrishbe): could move some of this to a setup function to do only once
        // set up throw effect
        throwEffect.target = viewport;
        throwEffect.duration = EFFECT_TIME;
        
        // maybe use motion paths with more keyframes for the bounce effect??
        var horizontalMP:MotionPath = new SimpleMotionPath("horizontalScrollPosition", hsp, finalHSP);
        var verticalMP:MotionPath = new SimpleMotionPath("verticalScrollPosition", vsp, finalVSP);
        
        if (viewport.scrollAxis == "diagonal")
            throwEffect.motionPaths = Vector.<MotionPath>([horizontalMP, verticalMP]);
        else if (viewport.scrollAxis == "horizontal")
            throwEffect.motionPaths = Vector.<MotionPath>([horizontalMP]);
        else if (viewport.scrollAxis == "vertical")
            throwEffect.motionPaths = Vector.<MotionPath>([verticalMP]);
        
        throwEffect.easer = throwEaser;
    }
    
    private function throwEffect_effectEndHandler(event:EffectEvent):void
    {
        // if we stopped the effect ourself (because someone pressed down), then let's not consider
        // this the end
        if (stoppedPreemptively)
            return;
        
        dispatchEvent(new TouchScrollEvent(TouchScrollEvent.TOUCH_SCROLL_THROW_ANIMATION_END));
    }
    
    private function touchScrollThrowHandler(event:TouchScrollEvent):void
    {
        stoppedPreemptively = false;
        setUpThrowEffect(event.throwVelocity);
        throwEffect.play();
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
        
        if (instance == verticalScrollBar)
            verticalScrollBar.viewport = viewport;
        
        else if (instance == horizontalScrollBar)
            horizontalScrollBar.viewport = viewport;
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
            
        var nSteps:uint = Math.abs(event.delta);
        var navigationUnit:uint;

        // Scroll event.delta "steps".  If the VSB is up, scroll vertically,
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
            navigationUnit = (event.delta < 0) ? NavigationUnit.DOWN : NavigationUnit.UP;
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
            navigationUnit = (event.delta < 0) ? NavigationUnit.RIGHT : NavigationUnit.LEFT;
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

}

}

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Point;
import flash.utils.getTimer;

import mx.events.SandboxMouseEvent;

import spark.components.Scroller;
import spark.events.TouchScrollEvent;

class TouchScrollHelper
{
    private static const HISTORY:int = 5;
    private static const MIN_START_VELOCITY:Number = 0.05;
    
    private static function calculateVelocity(clickHistory:Vector.<Point>, timeHistory:Vector.<int>):Vector.<Point>
    {
        var len:int = clickHistory.length - 1;
        if (len <= 0)
            
            return null;
        
        var velocities:Vector.<Point> = new Vector.<Point>(len);
        
        for (var i:int = 0; i < len; i++)
        {
            var point1:Point = clickHistory[i];
            var point2:Point = clickHistory[i+1];
            var distance:Point = point2.subtract(point1);
            var time:Number = timeHistory[i+1] - timeHistory[i];
            velocities[i] = new Point(distance.x/time, distance.y/time);
        }
        
        return velocities;
    }
    
    private static function averagePoints(points:Vector.<Point>, weighted:Vector.<Number>):Point
    {
        var len:int = points.length;
        
        var currentPoint:Point = new Point(0, 0);
        var totalWeight:Number = 0;
        
        for (var i:int = 0; i < len; i++)
        {
            var point:Point = new Point(points[i].x, points[i].y);
            totalWeight += weighted[i];
            point.x *= weighted[i];
            point.y *= weighted[i];
            currentPoint.x += point.x;
            currentPoint.y += point.y;
        }
        
        currentPoint.x = currentPoint.x/totalWeight;
        currentPoint.y = currentPoint.y/totalWeight;
        
        return currentPoint;
    }
    
    public function TouchScrollHelper(scroller:Scroller)
    {
        super();
        
        clickHistory = new Vector.<Point>();
        timeHistory = new Vector.<int>();
        
        this.scroller = scroller;
    }
    
    public var horizontalSlop:Number;
    public var verticalSlop:Number;
    public var diagonalSlop:Number;
    public var scroller:Scroller;
    
    // each of these per mouseEvent (or per touchPoint ID)
    private var mouseDownedPoint:Point;
    private var scrollStartPoint:Point;
    private var startTime:Number;
    private var mouseDownedDisplayObject:DisplayObject;
    private var clickHistory:Vector.<Point>;
    private var timeHistory:Vector.<int>;
    private var isScrolling:Boolean;
    
    public function startScrollWatch(event:Event):void
    {
        startTime = flash.utils.getTimer();
        
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
                // FIXME (rfrishbe): below is same as in mouseMove...should it be?
//                var scrollDragStartEvent:TouchScrollEvent = new TouchScrollEvent(TouchScrollEvent.TOUCH_SCROLL_START);
//                scrollDragStartEvent.scrollingObject = scroller;
//                scroller.dispatchEvent(scrollDragStartEvent);
                scrollStartPoint = new Point(mouseEvent.stageX, mouseEvent.stageY);
                mouseDownedPoint = new Point(mouseEvent.stageX, mouseEvent.stageY);
            }
            
            // only need to do this stuff once per target
            // store last 5 values
            clickHistory.length = 0;
            timeHistory.length = 0;
            
            addMouseEventHistory(mouseEvent);
        }
        else if (event is TouchEvent && event.type == TouchEvent.TOUCH_BEGIN)
        {
            // TouchEvent case
        }            
    }
    
    public function stopScrollWatch():void
    {
        uninstallMouseListeners();
    }
    
    private function addMouseEventHistory(event:MouseEvent):Point
    {
        var p:Point = new Point(event.stageX, event.stageY);
        var differencePoint:Point = p.subtract(mouseDownedPoint);
        
        if (clickHistory.length >= HISTORY)
        {
            clickHistory.shift();
            timeHistory.shift();
        }
        
        clickHistory.push(differencePoint);
        timeHistory.push(flash.utils.getTimer() - startTime);
        
        return differencePoint;
    }

    // event listener helpers
    private function installMouseListeners():void
    {
        var sbRoot:DisplayObject = scroller.systemManager.getSandboxRoot();
        
        sbRoot.addEventListener(MouseEvent.MOUSE_MOVE, sbRoot_mouseMoveHandler, true);
        sbRoot.addEventListener(MouseEvent.MOUSE_UP, sbRoot_mouseUpHandler, true);
        sbRoot.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, sbRoot_mouseUpHandler);
        
        scroller.systemManager.deployMouseShields(true);
    }
    
    private function uninstallMouseListeners():void
    {
        var sbRoot:DisplayObject = scroller.systemManager.getSandboxRoot();
        
        // mouse events added in installMouseListeners()
        sbRoot.removeEventListener(MouseEvent.MOUSE_MOVE, sbRoot_mouseMoveHandler, true);
        sbRoot.removeEventListener(MouseEvent.MOUSE_UP, sbRoot_mouseUpHandler, true);
        sbRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, sbRoot_mouseUpHandler);
        
        scroller.systemManager.deployMouseShields(false);
    }
    
    // event listeners
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function sbRoot_mouseMoveHandler(event:MouseEvent):void
    {
        var mouseDownedDifference:Point = addMouseEventHistory(event);
        
        if (!isScrolling)
        {
            var shouldBeScrolling:Boolean = false;
            
            switch (scroller.viewport.scrollAxis)
            {
                case "vertical":
                    shouldBeScrolling = Math.abs(mouseDownedDifference.y) >= verticalSlop;
                    break;
                case "horizontal":
                    shouldBeScrolling = Math.abs(mouseDownedDifference.x) >= horizontalSlop;
                    break;
                case "diagonal":
                    shouldBeScrolling = Math.abs(mouseDownedDifference.length) >= diagonalSlop;
                    break;
            }
            
            // Check to see if we should be scrolling
            if (shouldBeScrolling)
            {
                // cancellable and bubbling event
                var scrollDragStartingEvent:TouchScrollEvent = new TouchScrollEvent(TouchScrollEvent.TOUCH_SCROLL_STARTING, true, true);
                scrollDragStartingEvent.scrollingObject = scroller;
                var eventAccepted:Boolean = mouseDownedDisplayObject.dispatchEvent(scrollDragStartingEvent);
                
                if (!eventAccepted)
                {                    
                    // TODO (rfrishbe): do we need to call updateAfterEvent() here and below?
                    event.updateAfterEvent();
                    
                    // if our mouse target has been rejected, let's give up and remove all the listeners
                    uninstallMouseListeners();
                    
                    return;
                }
                
                var scrollDragStartEvent:TouchScrollEvent = new TouchScrollEvent(TouchScrollEvent.TOUCH_SCROLL_START);
                scrollDragStartEvent.scrollingObject = scroller;
                scroller.dispatchEvent(scrollDragStartEvent);
                
                // FIXME (rfrishbe): the difference should not be from the original point but from the slop.
                // otherwise we "jump" on the first move.
                // we should reset startPoint here to be this point minus slop (in the direction that caused the scroll)
                scrollStartPoint = new Point(event.stageX, event.stageY);
                isScrolling = true;
                
                // velocity calculations come from mouseDownedPoint.  The drag ones com from scrollStartPoint.
            }
            
            
        }
        
        // if we are scrolling
        if (isScrolling)
        {
            var p:Point = new Point(event.stageX, event.stageY);
            var scrollDifferencePoint:Point = p.subtract(scrollStartPoint);
            
            var scrollDragEvent:TouchScrollEvent = new TouchScrollEvent(TouchScrollEvent.TOUCH_SCROLL_DRAG, false, false);
            scrollDragEvent.scrollingObject = scroller;
            scrollDragEvent.dragX = scrollDifferencePoint.x;
            scrollDragEvent.dragY = scrollDifferencePoint.y;
            
            scroller.dispatchEvent(scrollDragEvent);
            event.updateAfterEvent();
        }
    }
    
    /**
     *  @private
     *  Called when the user releases the TitleWindow.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function sbRoot_mouseUpHandler(event:Event):void
    {
        uninstallMouseListeners();
        
        // FIXME (rfrishbe): can we scroll by velocity even tho no drag took place?
        if (!isScrolling)
            return;
        
        if (event is MouseEvent)
            addMouseEventHistory(event as MouseEvent);
        
        // decide about throw
        
        // pad click and timeHistory if needed
        var currentTime:Number = getTimer();
        
        // calculate average time b/w events and see if the last two (mouseMove and this mouseUp) 
        // were far apart.  If they were, then don't do anything if the velocity of them is small.
        var averageTime:Number = 0;
        var len:int = timeHistory.length;
        
        // FIXME (rfrishbe): this isn't true sine we could get a mouseUpSomehwere event
        // gauranteed to have 2 mouse events b/c atleast a mousedown and a mouse up
        
        for (var i:int = 0; i < len - 2; i++)
        {
            averageTime += timeHistory[i+1] - timeHistory[i];
        }
        averageTime /= len-2;
        
        var lastTime:Number = timeHistory[len-1] - timeHistory[len-2];
        var lastVelocity:Point = clickHistory[len-1].subtract(clickHistory[len-2]);
        lastVelocity.x /= lastTime;
        lastVelocity.y /= lastTime;
        
        var scrollEndEvent:TouchScrollEvent;
        
        // FIXME (rfrishbe): should be minXVelocity, minYVelocity, minDiagonalVelocity
        // FIXME (rfrishbe): this should be parameterized better
        if ( (lastTime >= 3*averageTime) &&
            (lastVelocity.length <= MIN_START_VELOCITY))
        {
            isScrolling = false;
            
            // don't do anything
            scrollEndEvent = new TouchScrollEvent(TouchScrollEvent.TOUCH_SCROLL_END);
            scrollEndEvent.scrollingObject = scroller;
            scroller.dispatchEvent(scrollEndEvent);
            return;
        }
        
        var velocities:Vector.<Point> = calculateVelocity(clickHistory, timeHistory);
        
        var velocityWeights:Vector.<Number> = Vector.<Number>([1,1.33,1.66,2]);
        var throwVelocity:Point = averagePoints(velocities, velocityWeights);
        
        //            trace("velocity: ", initialVelocity.y);
        if (throwVelocity.length > MIN_START_VELOCITY)
        {
            var scrollEndAndThrowEvent:TouchScrollEvent = new TouchScrollEvent(TouchScrollEvent.TOUCH_SCROLL_THROW, false, false);
            scrollEndAndThrowEvent.scrollingObject = scroller;
            scrollEndAndThrowEvent.throwVelocity = throwVelocity;
            
            scroller.addEventListener(TouchScrollEvent.TOUCH_SCROLL_THROW_ANIMATION_END, scroller_touchScrollThrowAnimationEnd);
            scroller.dispatchEvent(scrollEndAndThrowEvent);
        }
        else
        {
            isScrolling = false;

            // don't do anything
            scrollEndEvent = new TouchScrollEvent(TouchScrollEvent.TOUCH_SCROLL_END);
            scrollEndEvent.scrollingObject = scroller;
            scroller.dispatchEvent(scrollEndEvent);
        }
        
        // if we own this user gesture, don't let others see this event
//        if (isScrolling)
//            event.stopImmediatePropagation();
    }
    
    private function scroller_touchScrollThrowAnimationEnd(event:TouchScrollEvent):void
    {
        scroller.removeEventListener(TouchScrollEvent.TOUCH_SCROLL_THROW_ANIMATION_END, scroller_touchScrollThrowAnimationEnd);
        
        isScrolling = false;
        
        var scrollEndEvent:TouchScrollEvent = new TouchScrollEvent(TouchScrollEvent.TOUCH_SCROLL_END);
        scrollEndEvent.scrollingObject = scroller;
        scroller.dispatchEvent(scrollEndEvent);
    }
    
    
}
