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


package flex.component
{
import flex.core.SkinnableComponent;
import flex.core.Group;
import flex.intf.IViewport;
import mx.events.PropertyChangeEvent;
import mx.core.ScrollPolicy;

	
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

public class Scroller extends SkinnableComponent
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
        if (skinObject)
        {
            skinObject.invalidateSize()
            skinObject.invalidateDisplayList();           
        }
    }    
    
    //----------------------------------
    //  horizontalScrollBar
    //---------------------------------- 
    
    [SkinPart]
    public var horizontalScrollBar:HScrollBar;
    
    //----------------------------------
    //  verticalScrollBar
    //---------------------------------- 
    
    [SkinPart]
    public var verticalScrollBar:VScrollBar;
    
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
        if (skinObject && viewport)
        {
            skinObject.addItemAt(viewport, 0);
            viewport.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
        }
 	
    }
    
    private function uninstallViewport():void
    {
    	if (skinObject && viewport)
    	{
    		skinObject.removeItem(viewport);
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
    override protected function partAdded(partName:String, instance:*):void
    {
        super.partAdded(partName, instance);
        
        if (instance == verticalScrollBar)
        {
        	verticalScrollBar.addEventListener("valueCommit", vsb_valueCommitHandler);
        }
        
        if (instance == horizontalScrollBar)
        {
            horizontalScrollBar.addEventListener("valueCommit", hsb_valueCommitHandler);
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:*):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == verticalScrollBar)
        {
            verticalScrollBar.removeEventListener("valueCommit", vsb_valueCommitHandler);
        }
        
        if (instance == horizontalScrollBar)
        {
            horizontalScrollBar.removeEventListener("valueCommit", hsb_valueCommitHandler);
        }
    }
    	
}

}