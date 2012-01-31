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
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
    
import mx.components.Group;
import mx.core.IViewport;
import mx.core.IVisualContainer;
import mx.layout.LayoutBase;

import mx.events.PropertyChangeEvent;
import mx.components.baseClasses.FxComponent;
import mx.core.ScrollPolicy;
import mx.core.ScrollUnit;
import mx.managers.IFocusManagerComponent;

    
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
       implements IFocusManagerComponent, IVisualContainer
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
    
    [SkinPart]
    /**
     * A skin part that defines the horizontal scrollbar.
     */
    public var horizontalScrollBar:FxHScrollBar;
    
    //----------------------------------
    //  verticalScrollBar
    //---------------------------------- 
    
    [SkinPart]
    /**
     * A skin part that defines the vertical scrollbar.
     */
    public var verticalScrollBar:FxVScrollBar;
    
    //----------------------------------
    //  viewport - default property
    //----------------------------------    
    
    private var _viewport:IViewport;
    
    [Bindable]
    
    /**
     *  The viewport component to be scrolled.
     * 
     *  <p>The viewport is added to the FXScroller component's skin 
     *  which lays out both the viewport and scrollbars.
     * 
     *  When the viewport property is set, the viewport's clipContent property is 
     *  set to true to enable scrolling.</p>
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
    }

    private function installViewport():void
    {
        if (skin && viewport)
        {
            viewport.clipContent = true;
            skin.addItemAt(viewport, 0);
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
            skin.removeItem(viewport);
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
    //  Methods: IVisualContainer
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     */
    public function get numItems():int
    {
        return viewport ? 1 : 0;
    }
    
    /**
     *  @inheritDoc
     */
    public function getItemAt(index:int):Object
    {
        if (viewport && index == 0)
            return viewport;
        else
            throw new RangeError("Index " + index + " is out of range");
    }
    
    /**
     *  @inheritDoc
     */
    public function getItemIndex(item:Object):int
    {
        if (item != null && item == viewport)
            return 0;
        else
            throw ArgumentError(item + " is not found in this FxScroller");
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
        var vp:IViewport = viewport;
        if (!vp)
            return;
            
        // TBD: is special handling for textfields needed here, as in mx.core.Container?
    
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
            }
        }
    }
        
}

}
