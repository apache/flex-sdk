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
    
import mx.core.IInvalidating;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.mx_internal;

import spark.components.Grid;
import spark.components.Group;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

/**
 *  The element type for the Grid layers property.
 * 
 *  <p>A GridLayer is a non-visual object that has a simple no-layout container for Grid visual elements.  
 *  Visual elements are added to the layer's (internal) container with addElement() and removed with 
 *  removeElement().   GridLayer containers must not impose a layout on their elements, the Grid's 
 *  layout is responsible for sizing and positioning all GridLayer elements.</p>
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.4
 *  @productversion Flex 4.5
 */
public class GridLayer
{
    public function GridLayer()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //-------------------------------------------------------------------------- 
    
    //----------------------------------
    //  id
    //----------------------------------

    private var _id:String;
    
    /**
     *  A unique identifier for this layer.   The Grid's layout looks up layers by id.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.4
     *  @productversion Flex 4.5  
     */
    public function get id():String
    {
        return _id;
    }
    
    /**
     *  @private
     */
    public function set id(value:String):void
    {
        _id = value;
    }
    
    
    //----------------------------------
    //  root
    //----------------------------------
    
    private var _root:IVisualElement;
    
    /**
     *  The root of the hierarchy that addElement() adds visual elements to and
     *  removeElement() removes them from.   To add a GridLayer to another Group,
     *  add its root: myGroup.addElement(myGridLayer.root).
     * 
     *  @default A Group configured with a no-op layout.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.4
     *  @productversion Flex 4.5
     */
    public function get root():IVisualElement
    {
        if (!_root)
            _root = new LayerGroup();
        
        return _root;
    }
    
    /**
     *  @private
     */
    public function set root(value:IVisualElement):void
    {
        _root = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------      
    
    /**
     *  Add the specified element to this GridLayer.  The relative order of elements
     *  is not guaranteed.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.4
     *  @productversion Flex 4.5
     */
    public function addElement(elt:IVisualElement):void
    {
        if (elt.parent != root)
            IVisualElementContainer(root).addElement(elt);
    }
    
    /**
     *  Remove the specified element from this GridLayer.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.4
     *  @productversion Flex 4.5  
     */
    public function removeElement(elt:IVisualElement):void
    {
        if (elt.parent == root)
            IVisualElementContainer(root).removeElement(elt);
    }
    
    /** 
     *  Validate this layer's display list.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.4
     *  @productversion Flex 4.5
     */
    public function validateNow():void
    {
        IInvalidating(root).validateNow();
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
