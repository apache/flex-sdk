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
import mx.layout.LayoutBase;

import mx.events.PropertyChangeEvent;
import mx.components.baseClasses.FxComponent;
import mx.core.ScrollPolicy;
import mx.managers.IFocusManagerComponent;

	
[DefaultProperty("viewport")]

/**
 *  Support for a displaying a single scrollable component, called a
 *  "viewport", and a pair of scrollbars.
 *
 *  The viewport must implement IViewport.  Group and [TBD] implement
 *  IViewport.
 * 
 *  The scrollbars control the viewport's horizontalScrollPosition and
 *  verticalScrollPosition properties to make it possible to view the area
 *  defined by the viewport's contentWidth and contentHeight.
 * 
 *  Scroller links the scrollbars' pageSize to the viewport's
 *  width and height, and their maximum property to the viewport's
 *  contentWidth and Height less the pageSize.
 *       
 *  <p>
 *  The scrollbars are displayed per the vertical and horizontal scrollbar
 *  policy properties, which can be "auto", "on", or "off".
 *  
 *  The auto policy means that the scrollbar will be visible and included
 *  in the Scroller's layout when the scrollable container's content is
 *  larger than the scrollable contiainer itself.
 *  </p>
 */

public class FxScroller extends FxComponent implements IFocusManagerComponent
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
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
    public var horizontalScrollBar:FxHScrollBar;
    
    //----------------------------------
    //  verticalScrollBar
    //---------------------------------- 
    
    [SkinPart]
    public var verticalScrollBar:FxVScrollBar;
    
    //----------------------------------
    //  viewport - default property
    //----------------------------------    
    
    private var _viewport:IViewport;
    
    [Bindable]
    
	/**
	 *  The viewport component to be scrolled.
	 * 
	 *  The viewport is added to the Scroller's skin which lays out
	 *  both the viewport and scrollbars.
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
	 *  The viewport can still be scrolled programatically, by setting its
	 *  verticalScrollPosition property.
	 *  </li>
	 *  <li>
	 *  <code>ScrollPolicy.AUTO</code> ("auto") - the scrollbar is displayed when 
	 *  the viewport's contentHeight is larger than its height.
	 *  </li>
	 *  </ul>
	 * 
	 *  <p>
	 *  The scroll policy affects the measured size of the Scroller.
	 *  </p>
	 * 
	 *  @default ScrollPolicy.AUTO
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
	 *  The viewport can still be scrolled programatically, by setting its
	 *  horizontalScrollPosition property.
	 *  </li>
	 *  <li>
	 *  <code>ScrollPolicy.AUTO</code> ("auto") - the scrollbar is displayed when 
	 *  the viewport's contentWidth is larger than its width.
	 *  </li>
	 *  </ul>
	 * 
	 *  <p>
	 *  The scroll policy affects the measured size of the Scroller.
	 *  </p>
	 * 
	 *  @default ScrollPolicy.AUTO
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
   
	/**
	 *  Called when the vertical scrollbar value changes; updates 
	 *  the viewport's verticalScrollPosition.
	 */
    protected function vsb_valueCommitHandler(event:Event):void
    {
        if (viewport)
            viewport.verticalScrollPosition = verticalScrollBar.value;    	
    }
	
	/**
	 *  Called when the horizontal scrollbar value changes; updates 
	 *  the viewport's horizontalScrollPosition.
	 */
    protected function hsb_valueCommitHandler(event:Event):void
    {
    	if (viewport)
    	   viewport.horizontalScrollPosition = horizontalScrollBar.value;
    }
    
    private function viewport_propertyChangeHandler(event:PropertyChangeEvent):void
    {
    	switch(event.property) {
    		case "contentWidth": 
    		    viewportContentWidthChanged(event);
    		    break;
    		    
    		case "contentHeight": 
    		    viewportContentHeightChanged(event);
    		    break;
    		    
            case "horizontalScrollPosition":
                viewportHorizontalScrollPositionChanged(event);
                break;

    		case "verticalScrollPosition":
    		    viewportVerticalScrollPositionChanged(event);
    		    break;
    	}
    }
    
   /**
    *  Called when the viewport's contentWidth changes; invalidates
    *  the skin's size and display list.
    */
    protected function viewportContentWidthChanged(event:PropertyChangeEvent):void
    {
    	invalidateSkin();
    }
	/**
	 *  Called when the viewport's contentHeight changes; invalidates
	 *  the skin's size and display list.
	 */
    protected function viewportContentHeightChanged(event:PropertyChangeEvent):void
    {
        invalidateSkin();
    }
    
    /**
     *  Called when the viewport's horizontalScrollPosition changes; sets the 
     *  horizontal scrollbar's value.
     */
    protected function viewportHorizontalScrollPositionChanged(event:PropertyChangeEvent):void
    {
       if (horizontalScrollBar)
           horizontalScrollBar.value = viewport.horizontalScrollPosition;
    }  
    
    /**
     *  Called when the viewport's verticalScrollPosition changes; sets the 
     *  vertical scrollbar's value.
     */
    protected function viewportVerticalScrollPositionChanged(event:PropertyChangeEvent):void
    {
       if (verticalScrollBar)
           verticalScrollBar.value = viewport.verticalScrollPosition;
    }   
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function skinLoaded():void
    {
        super.skinLoaded();
        installViewport();
    }
    
    /**
     *  @private
     */
    override protected function unloadingSkin():void
    {    
        super.unloadingSkin();
        uninstallViewport();
    }
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == verticalScrollBar)
        {
            verticalScrollBar.viewport = viewport;            
        	verticalScrollBar.addEventListener("valueCommit", vsb_valueCommitHandler);
        }
        
        if (instance == horizontalScrollBar)
        {
            horizontalScrollBar.viewport = viewport;            
            horizontalScrollBar.addEventListener("valueCommit", hsb_valueCommitHandler);
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == verticalScrollBar)
        {
            verticalScrollBar.viewport = null;
            verticalScrollBar.removeEventListener("valueCommit", vsb_valueCommitHandler);
        }
        
        if (instance == horizontalScrollBar)
        {
            horizontalScrollBar.viewport = null;
            horizontalScrollBar.removeEventListener("valueCommit", hsb_valueCommitHandler);
        }
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
                case Keyboard.DOWN:
                case Keyboard.UP:
                case Keyboard.PAGE_UP:
                case Keyboard.PAGE_DOWN:
                case Keyboard.HOME:
                case Keyboard.END:
                     vspDelta = vp.verticalScrollPositionDelta(event.keyCode);
                     break;
            }
            if (!isNaN(vspDelta))
            {
            	vp.verticalScrollPosition += vspDelta;
            	event.stopPropagation();
            }
        }

        if (horizontalScrollBar && horizontalScrollBar.visible)
        {
        	var hspDelta:Number = NaN;
            switch (event.keyCode)
            {
                case Keyboard.LEFT:
                case Keyboard.RIGHT:
                case Keyboard.HOME:
                case Keyboard.END:                
                    hspDelta = vp.horizontalScrollPositionDelta(event.keyCode);
                    break;
            }
            if (!isNaN(hspDelta))
            {
                vp.horizontalScrollPosition += hspDelta;
                event.stopPropagation();
            }
        }
    }
    	
}

}
