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

package spark.components.gridClasses
{
    
import mx.core.IVisualElement;
import mx.core.mx_internal;

import spark.components.Grid;
import spark.components.Group;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

/**
 *  The GridLayer class defines a container used for the layers of the 
 *  Grid control's visual elements.  
 *  The Grid control creates and adds visual elements to its layers
 *  as needed, and is responsible for their layout.
 *
 *  @see spark.components.Grid
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class GridLayer extends Group
{
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function GridLayer()
    {
        super();
        layout = new LayoutBase();        
    }
    
    //--------------------------------------------------------------------------
    //
    //  Method Overrides
    //
    //--------------------------------------------------------------------------      
    
    /**
     *  @private
     */
    override public function invalidateDisplayList():void
    {
        const grid:Grid = parent as Grid;
        if (grid && grid.inUpdateDisplayList)
            return;
        
        if (grid)
            grid.invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    override public function invalidateSize():void
    {   
        const grid:Grid = parent as Grid;
        if (grid && grid.inUpdateDisplayList)
            return;
        
        if (grid)
            grid.invalidateSize();        
    }
}
}