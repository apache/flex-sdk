////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.supportClasses
{
    
import mx.core.IVisualElement;
import mx.core.mx_internal;

import spark.components.Grid;
import spark.components.Group;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 *  A simple no-layout container for Grid visual elements.   This class has-a Group, rather than 
 *  being one, to accomodate using the Grid itself as a layer.
 */
public class GridLayer
{
    public function GridLayer(layerRoot:Group = null)
    {
        super();
        _root = (layerRoot) ? layerRoot : new LayerGroup();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------    
    
    private var _root:Group;
    
    
    /**
     *  The root of the hierarchy that addGridElement() adds visual elements to and
     *  removeGridElement() removes them from.   To add a GridLayer to another Group,
     *  add its root: myGroup.add(myGridLayer.root).
     */
    public function get root():Group
    {
        return _root;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------      
    
    /**
     *  Add the specified element to this GridLayer.  The relative order of elements
     *  is not guaranteed.
     */
    public function addGridElement(elt:IVisualElement):void
    {
        if (elt.parent != root)
            root.addElement(elt);
    }
    
    /**
     *  Remove the specified element from this GridLayer.  
     */
    public function removeGridElement(elt:IVisualElement):void
    {
        if (elt.parent == root)
            root.removeElement(elt);
    }      
}
}

import mx.core.mx_internal;

import spark.components.Grid;
import spark.components.Group;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

class LayerGroup extends Group
{
    public function LayerGroup()
    {
        super();
        layout = new LayoutBase();
    }
    
    override public function invalidateDisplayList():void
    {
        const grid:Grid = parent as Grid;
        if (grid && grid.inUpdateDisplayList)
            return;
        
        super.invalidateDisplayList();
    }
    
    override public function invalidateSize():void
    {   
        const grid:Grid = parent as Grid;
        if (grid && grid.inUpdateDisplayList)
            return;
        
        super.invalidateSize();        
    }
}
