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
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.system.ApplicationDomain;
import flash.text.TextField;
import flash.ui.Keyboard;

import spark.components.supportClasses.ScrollerLayout;
import spark.components.supportClasses.SkinnableComponent;
import spark.core.IViewport;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.ScrollPolicy;
import spark.core.ScrollUnit;
import mx.events.PropertyChangeEvent;
import mx.managers.IFocusManagerComponent;
import flash.display.InteractiveObject;

include "../styles/metadata/AdvancedTextLayoutFormatStyles.as"
include "../styles/metadata/BasicTextLayoutFormatStyles.as"
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

//--------------------------------------
//  Other metadata
//--------------------------------------

[ResourceBundle("components")]
    
[DefaultProperty("viewport")]

[IconFile("Scroller.png")]

/**
 *  The Scroller component displays a single scrollable component, 
 *  called a viewport, and a horizontal and vertical scrollbars. 
 *  The viewport must implement the IViewport interface.
 * 
 *  <p>The scrollbars control the viewport's <code>horizontalScrollPosition</code> and
 *  <code>verticalScrollPosition</code> properties.
 *  Scrollbars make it possible to view the area defined by the viewport's 
 *  <code>contentWidth</code> and <code>contentHeight</code> properties.</p>
 * 
 *  <p>The scrollbars are displayed according to the vertical and horizontal scrollbar
 *  policy, which can be <code>auto</code>, <code>on</code>, or <code>off</code>.
 *  The <code>auto</code> policy means that the scrollbar will be visible and included
 *  in the layout when the viewport's content is larger than the viewport itself.</p>
 * 
 *  <p>The Scroller skin layout cannot be changed, it's unconditionally set to a 
 *  private layout implementation that handles the scroll policies.  Scroller skins
 *  can only provide replacement scrollbars.  To gain more control over the layout
 *  of a viewport and its scrollbars, instead of using Scroller, just add them 
 *  to a <code>Group</code> and use the scrollbar <code>viewport</code> property 
 *  to link them together.</p>
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
     * Constructor
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function Scroller()
    {
        super();
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
     *  A skin part that defines the horizontal scrollbar.
     * 
     *  This property should be considered read-only, it's only
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
     *  A skin part that defines the vertical scrollbar.
     * 
     *  This property should be considered read-only, it's only
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
     *  The viewport is added to the Scroller component's skin 
     *  which lays out both the viewport and scrollbars.
     * 
     *  When the viewport property is set, the viewport's clipAndEnableScrolling property is 
     *  set to true to enable scrolling.
     * 
     *  Scroller does not support rotating the viewport directly.  The viewport's
     *  contents can be transformed arbitrarily but the viewport itself can not.
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
            skin.addElementAt(viewport, 0);
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
            skin.removeElement(viewport);
            viewport.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
        }
    }
    
    //----------------------------------
    //  verticalScrollPolicy
    //----------------------------------

    private var _verticalScrollPolicy:String = ScrollPolicy.AUTO;

    [Bindable]
    [Inspectable(enumeration="off,on,auto", defaultValue="auto")]
            
    /**
     *  Indicates under what conditions the vertical scrollbar is displayed.
     * 
     *  <ul>
     *  <li>
     *  <code>ScrollPolicy.ON</code> ("on") - the scrollbar is always displayed.
     *  </li> 
     *  <li>
     *  <code>ScrollPolicy.OFF</code> ("off") - the scrollbar is never displayed.
     *  The viewport can still be scrolled programmatically, by setting its
     *  verticalScrollPosition property.
     *  </li>
     *  <li>
     *  <code>ScrollPolicy.AUTO</code> ("auto") - the scrollbar is displayed when 
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
    public function get verticalScrollPolicy():String
    {
        return _verticalScrollPolicy;
    }

    /**
     *  @private
     */
    public function set verticalScrollPolicy(value:String):void
    {
        if (value == _verticalScrollPolicy)
            return;

        _verticalScrollPolicy = value;
        invalidateSkin();
    }
    

    //----------------------------------
    //  horizontalScrollPolicy
    //----------------------------------

    private var _horizontalScrollPolicy:String = ScrollPolicy.AUTO;
    
    [Bindable]
    [Inspectable(enumeration="off,on,auto", defaultValue="auto")]

    /**
     *  Indicates under what conditions the horizontal scrollbar is displayed.
     * 
     *  <ul>
     *  <li>
     *  <code>ScrollPolicy.ON</code> ("on") - the scrollbar is always displayed.
     *  </li> 
     *  <li>
     *  <code>ScrollPolicy.OFF</code> ("off") - the scrollbar is never displayed.
     *  The viewport can still be scrolled programmatically, by setting its
     *  horizontalScrollPosition property.
     *  </li>
     *  <li>
     *  <code>ScrollPolicy.AUTO</code> ("auto") - the scrollbar is displayed when 
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
    public function get horizontalScrollPolicy():String
    {
        return _horizontalScrollPolicy;
    }

    /**
     *  @private
     */
    public function set horizontalScrollPolicy(value:String):void
    {
        if (value == _horizontalScrollPolicy)
            return;

        _horizontalScrollPolicy = value;
        invalidateSkin();
    }
    
    //----------------------------------
    //  minViewportInset
    //----------------------------------

    private var _minViewportInset:Number = 0;
    
    [Inspectable(category="General")]

    /**
     *  The minimum space between the viewport and the edges of the Scroller.  
     * 
     *  If neither of the scrollbars is visible, then the viewport is inset by 
     *  <code>minViewportInset</code> on all four sides.
     * 
     *  If a scrollbar is visible then the viewport is inset by <code>minViewportInset</code>
     *  or by the scrollbar's size, whichever is larger.
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
     *  Returns the 0 if the element passed in is the viewport.  
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
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in Scroller.  Scroller only 
     *  has one child.  Use the <code>viewport</code> property to manipulate 
     *  it.</p>
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
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in Scroller.  Scroller only 
     *  has one child.  Use the <code>viewport</code> property to manipulate 
     *  it.</p>
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
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in Scroller.  Scroller only 
     *  has one child.  Use the <code>viewport</code> property to manipulate 
     *  it.</p>
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
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in Scroller.  Scroller only 
     *  has one child.  Use the <code>viewport</code> property to manipulate 
     *  it.</p>
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
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in Scroller.  Scroller only 
     *  has one child.  Use the <code>viewport</code> property to manipulate 
     *  it.</p>
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
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in Scroller.  Scroller only 
     *  has one child.  Use the <code>viewport</code> property to manipulate 
     *  it.</p>
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
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in Scroller.  Scroller only 
     *  has one child.  Use the <code>viewport</code> property to manipulate 
     *  it.</p>
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
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in Scroller.  Scroller only 
     *  has one child.  Use the <code>viewport</code> property to manipulate 
     *  it.</p>
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
    override protected function attachSkin():void
    {
        super.attachSkin();
        skin.layout = new ScrollerLayout();
        installViewport();
        skin.addEventListener(MouseEvent.MOUSE_WHEEL, skin_mouseWheelHandler);
    }
    
    /**
     *  @private
     */
    override protected function detachSkin():void
    {    
        uninstallViewport();
        skin.layout = null;
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
        
        if (instance == horizontalScrollBar)
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
        
        if (instance == horizontalScrollBar)
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
                     vspDelta = vp.getVerticalScrollPositionDelta(ScrollUnit.UP);
                     break;
                case Keyboard.DOWN:
                     vspDelta = vp.getVerticalScrollPositionDelta(ScrollUnit.DOWN);
                     break;
                case Keyboard.PAGE_UP:
                     vspDelta = vp.getVerticalScrollPositionDelta(ScrollUnit.PAGE_UP);
                     break;
                case Keyboard.PAGE_DOWN:
                     vspDelta = vp.getVerticalScrollPositionDelta(ScrollUnit.PAGE_DOWN);
                     break;
                case Keyboard.HOME:
                     vspDelta = vp.getVerticalScrollPositionDelta(ScrollUnit.HOME);
                     break;
                case Keyboard.END:
                     vspDelta = vp.getVerticalScrollPositionDelta(ScrollUnit.END);
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
                    hspDelta = vp.getHorizontalScrollPositionDelta(ScrollUnit.LEFT);
                    break;
                case Keyboard.RIGHT:
                    hspDelta = vp.getHorizontalScrollPositionDelta(ScrollUnit.RIGHT);
                    break;
                case Keyboard.HOME:
                    hspDelta = vp.getHorizontalScrollPositionDelta(ScrollUnit.HOME);
                    break;
                case Keyboard.END:                
                    hspDelta = vp.getHorizontalScrollPositionDelta(ScrollUnit.END);
                    break;
                // If there's no vertical scrollbar, then map page up/down to
                // page left,right
                case Keyboard.PAGE_UP:
                     if (!verticalScrollBar || !(verticalScrollBar.visible))   
                         hspDelta = vp.getHorizontalScrollPositionDelta(ScrollUnit.PAGE_LEFT);
                     break;
                case Keyboard.PAGE_DOWN:
                     if (!verticalScrollBar || !(verticalScrollBar.visible))   
                         hspDelta = vp.getHorizontalScrollPositionDelta(ScrollUnit.PAGE_RIGHT);
                     break;
            }
            if (!isNaN(hspDelta))
            {
                vp.horizontalScrollPosition += hspDelta;
                event.preventDefault();
            }
        }
    }
    
    // To avoid unconditionally linking the RichEditableText class we lazily
    // get a reference if it's been linked already.  See below.
    private static var textViewClassLoaded:Boolean = false;
    private static var textViewClass:Class = null;

    private function skin_mouseWheelHandler(event:MouseEvent):void
    {
        var vp:IViewport = viewport;
        if (!vp || event.isDefaultPrevented())
            return;
            
        // If a TextField has the focus, then check to see if it's already
        // handling mouse wheel events.  For now, we'll make the same 
        // assumption about RichEditableText.
        
        /*var focusOwner:InteractiveObject = getFocus();
        if ((focusOwner is TextField) && TextField(focusOwner).mouseWheelEnabled)
            return;    

        if (!textViewClassLoaded)
        {
            textViewClassLoaded = true;
            const s:String = "spark.components.RichEditableText";
            if (ApplicationDomain.currentDomain.hasDefinition(s))
                textViewClass = Class(ApplicationDomain.currentDomain.getDefinition(s));
        }
        if (textViewClass && (focusOwner is textViewClass))
            return;*/

        var nSteps:uint = Math.abs(event.delta);
        var scrollUnit:uint;

        // Scroll event.delta "steps".  If the VSB is up, scroll vertically,
        // if -only- the HSB is up then scroll horizontally.
         
        if (verticalScrollBar && verticalScrollBar.visible)
        {
            scrollUnit = (event.delta < 0) ? ScrollUnit.DOWN : ScrollUnit.UP;
            for(var vStep:int = 0; vStep < nSteps; vStep++)
            {
                var vspDelta:Number = vp.getVerticalScrollPositionDelta(scrollUnit);
                if (!isNaN(vspDelta))
                    vp.verticalScrollPosition += vspDelta;
            }
            event.preventDefault();
        }
        else if (horizontalScrollBar && horizontalScrollBar.visible)
        {
            scrollUnit = (event.delta < 0) ? ScrollUnit.LEFT : ScrollUnit.RIGHT;
            for(var hStep:int = 0; hStep < nSteps; hStep++)
            {
                var hspDelta:Number = vp.getHorizontalScrollPositionDelta(scrollUnit);
                if (!isNaN(hspDelta))
                    vp.horizontalScrollPosition += hspDelta;
            }
            event.preventDefault();
        }            
    }

}

}
