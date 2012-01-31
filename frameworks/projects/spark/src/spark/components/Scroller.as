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
        _viewport = value;
        installViewport();
    }
    
    private function installViewport():void
    {
        if (viewportHolder)
        {
            if (viewportHolder.numItems > 0)     // remove the old viewport
        	   viewportHolder.removeItemAt(0);
        	if (_viewport)                       // add the new viewport
        	   viewportHolder.addItemAt(_viewport, 0);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    override protected function partAdded(partName:String, instance:*):void
    {
    	super.partAdded(partName, instance);
    	if (instance == viewportHolder)
    	    installViewport();
    }   
        
    //--------------------------------------------------------------------------
    //
    // SkinParts
    //
    //--------------------------------------------------------------------------	
	
    [SkinPart]
    public var viewportHolder:Group;

    [SkinPart]
    public var verticalScrollBar:VScrollBar;
    
    [SkinPart]
    public var horizontalScrollBar:HScrollBar;
    	
}

}