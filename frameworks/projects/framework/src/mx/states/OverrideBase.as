////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.states
{
    
import flash.events.EventDispatcher;

import mx.core.UIComponent;
import mx.utils.OnDemandEventDispatcher;

/**
 * @private 
 */
public class OverrideBase extends OnDemandEventDispatcher
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    public function OverrideBase() {}
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private 
     * Initialize this object from a descriptor.
     */
    public function initializeFromObject(properties:Object):Object
    {
        for (var p:String in properties)
        {
            this[p] = properties[p];
        }
        
        return Object(this);
    }
    
    /**
     * @private
     * @param parent The document level context for this override.
     * @param target The component level context for this override.
     */
    protected function getOverrideContext(target:Object, parent:UIComponent):Object
    {
        if (target == null)
            return parent;
    
        if (target is String)
            return parent[target];
    
        return target;
    }
}

}