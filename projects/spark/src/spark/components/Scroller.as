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
	
public class Scroller extends SkinnableComponent
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
        
	public function Scroller()
	{
		super();
	}
	
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
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
    
    public function get viewport():IViewport
    {       
        return _viewport;
    }
    
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

    /**
     *  @private
     */
    private var _verticalScrollPolicy:String = ScrollPolicy.AUTO;
    
    /**
     *  Documentation is not currently available.
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
        if (skinObject)
        {
            skinObject.invalidateSize();
            skinObject.invalidateDisplayList();
        }
    }
    

    //----------------------------------
    //  horizontalScrollPolicy
    //----------------------------------

    /**
     *  @private
     */
    private var _horizontalScrollPolicy:String = ScrollPolicy.AUTO;
    
    /**
     *  Documentation is not currently available.
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
        if (skinObject)
        {
        	skinObject.invalidateSize();
            skinObject.invalidateDisplayList();
        }
    }
    

    //--------------------------------------------------------------------------
    // 
    // Event Handlers
    //
    //--------------------------------------------------------------------------
    
    protected function vsb_valueCommitHandler(event:Event):void
    {
        if (viewport)
            viewport.verticalScrollPosition = verticalScrollBar.value;    	
    }
    
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
    
    protected function viewportContentWidthChanged(event:PropertyChangeEvent):void
    {
        if (skinObject)
        {
        	skinObject.invalidateSize()
            skinObject.invalidateDisplayList();           
        }
    }
    
    protected function viewportContentHeightChanged(event:PropertyChangeEvent):void
    {
    	if (skinObject)
    	{
    		skinObject.invalidateSize();
            skinObject.invalidateDisplayList();
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