package spark.components.supportClasses
{

import mx.core.mx_internal;

import spark.components.Grid;
import spark.components.Group;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

[ExcludeClass]

public class GridLayer extends Group
{
    public function GridLayer()
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

}