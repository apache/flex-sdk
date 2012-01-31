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


package mx.components
{
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.text.TextField;
import flash.ui.Keyboard;

import mx.components.baseClasses.FxComponent;
import mx.core.IViewport;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.ScrollPolicy;
import mx.core.ScrollUnit;
import mx.events.PropertyChangeEvent;
import mx.managers.IFocusManagerComponent;

include "../styles/metadata/AdvancedCharacterFormatTextStyles.as"
include "../styles/metadata/AdvancedContainerFormatTextStyles.as"
include "../styles/metadata/AdvancedParagraphFormatTextStyles.as"
include "../styles/metadata/BasicCharacterFormatTextStyles.as"
include "../styles/metadata/BasicContainerFormatTextStyles.as"
include "../styles/metadata/BasicParagraphFormatTextStyles.as"
include "../styles/metadata/SelectionFormatTextStyles.as"

/**
 *  @copy mx.components.baseClasses.GroupBase#alternatingItemColors
 */
[Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes")]

/**
 *  @copy mx.components.baseClasses.GroupBase#contentBackgroundColor
 */ 
[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes")]

/**
 *  @copy mx.components.baseClasses.GroupBase#focusColor
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes")]

/**
 * @copy mx.components.baseClasses.GroupBase#rollOverColor
 */ 
[Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]

/**
 *  @copy mx.components.baseClasses.GroupBase#symbolColor
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[ResourceBundle("components")]
    
[DefaultProperty("viewport")]

[IconFile("FxScroller.png")]

/**
 *  The FxScroller component displays a single scrollable component, 
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
 */

public class FxScroller extends FxComponent 
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
     */
    public function FxScroller()
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
    
    [SkinPart(required="true")]
    [Bindable]    

    /**
     *  A skin part that defines the horizontal scrollbar.
     * 
     *  This property should be considered read-only, it's only
     *  set by the FxScroller's skin.
     * 
     *  This property is Bindable.
     */
    public var horizontalScrollBar:FxHScrollBar;
    
    //----------------------------------
    //  verticalScrollBar
    //---------------------------------- 
    
    [SkinPart(required="true")]
    [Bindable]
    
    /**
     *  A skin part that defines the vertical scrollbar.
     * 
     *  This property should be considered read-only, it's only
     *  set by the FxScroller's skin.
     * 
     *  This property is Bindable.
     */
    public var verticalScrollBar:FxVScrollBar;


    //----------------------------------
    //  viewport - default property
    //----------------------------------    
    
    private var _viewport:IViewport;
    
    [Bindable(event="viewportChanged")]
    
    /**
     *  The viewport component to be scrolled.
     * 
     *  <p>
     *  The viewport is added to the FXScroller component's skin 
     *  which lays out both the viewport and scrollbars.
     * 
     *  When the viewport property is set, the viewport's clipContent property is 
     *  set to true to enable scrolling.
     * 
     *  Scroller does not support rotating the viewport directly.  The viewport's
     *  contents can be transformed arbitrarily but the viewport itself can not.
     * </p>
     * 
     *  This property is Bindable.
     * 
     *  @default null
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
            viewport.clipContent = true;
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
            viewport.clipContent = false;
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
     *  The scroll policy affects the measured size of the FxScroller component.
     *  </p>
     * 
     *  @default ScrollPolicy.AUTO
     *
     *  @see mx.core.ScrollPolicy
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
     *  The scroll policy affects the measured size of the FxScroller component.
     *  </p>
     * 
     *  @default ScrollPolicy.AUTO
     *
     *  @see mx.core.ScrollPolicy
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
     */ 
    public function getElementIndex(element:IVisualElement):int
    {
        if (element != null && element == viewport)
            return 0;
        else
            throw ArgumentError(resourceManager.getString("components", "elementNotFoundInFxScroller", [element]));
    }
    
    /**
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in FxScroller.  FxScroller only 
     *  has one child.  Use the <code>viewport</code> property to manipulate 
     *  it.</p>
     */
    public function addElement(element:IVisualElement):IVisualElement
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in FxScroller.  FxScroller only 
     *  has one child.  Use the <code>viewport</code> property to manipulate 
     *  it.</p>
     */
    public function addElementAt(element:IVisualElement, index:int):IVisualElement
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in FxScroller.  FxScroller only 
     *  has one child.  Use the <code>viewport</code> property to manipulate 
     *  it.</p>
     */
    public function removeElement(element:IVisualElement):IVisualElement
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in FxScroller.  FxScroller only 
     *  has one child.  Use the <code>viewport</code> property to manipulate 
     *  it.</p>
     */
    public function removeElementAt(index:int):IVisualElement
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in FxScroller.  FxScroller only 
     *  has one child.  Use the <code>viewport</code> property to manipulate 
     *  it.</p>
     */
    public function setElementIndex(element:IVisualElement, index:int):void
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in FxScroller.  FxScroller only 
     *  has one child.  Use the <code>viewport</code> property to manipulate 
     *  it.</p>
     */
    public function swapElements(element1:IVisualElement, element2:IVisualElement):void
    {
        throw new ArgumentError(resourceManager.getString("components", "operationNotSupported"));
    }
    
    /**
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in FxScroller.  FxScroller only 
     *  has one child.  Use the <code>viewport</code> property to manipulate 
     *  it.</p>
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
    override protected function loadSkin():void
    {
        super.loadSkin();
        installViewport();
    }
    
    /**
     *  @private
     */
    override protected function unloadSkin():void
    {    
        uninstallViewport();
        super.unloadSkin();
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
    
    private function mouseWheelHandler(event:MouseEvent):void
    {
        var vp:IViewport = viewport;
        if (!vp || event.isDefaultPrevented())
            return;

        var nSteps:uint = Math.abs(event.delta);
        var unit:ScrollUnit;

        if (verticalScrollBar && verticalScrollBar.visible)
        {
            unit = (event.delta < 0) ? ScrollUnit.DOWN : ScrollUnit.UP;
            for(var vStep:int = 0; vStep < nSteps; vStep++)
            {
                var vspDelta:Number = vp.getVerticalScrollPositionDelta(unit);
                if (!isNaN(vspDelta))
                    vp.verticalScrollPosition += vspDelta;
            }
            event.preventDefault();
        }
        else if (horizontalScrollBar && horizontalScrollBar.visible)
        {
            unit = (event.delta < 0) ? ScrollUnit.LEFT : ScrollUnit.RIGHT;
            for(var hStep:int = 0; hStep < nSteps; hStep++)
            {
                var hspDelta:Number = vp.getHorizontalScrollPositionDelta(unit);
                if (!isNaN(hspDelta))
                    vp.horizontalScrollPosition += hspDelta;
            }
            event.preventDefault();
        }            
    }
    
    /**
     *  @private
     */ 
    override protected function focusInHandler(event:FocusEvent):void
    {
         addSystemHandlers(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, mouseWheelHandler);
    }
    
    /**
     *  @private
     */
    override protected function focusOutHandler(event:FocusEvent):void
    {
        removeSystemHandlers(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, mouseWheelHandler);
    }    
        
}

}
