package spark.layouts
{
import mx.containers.utilityClasses.ConstraintColumn;
import mx.core.mx_internal;

import spark.components.supportClasses.GroupBase;

use namespace mx_internal;

public class FormItemLayout extends ConstraintLayout
{
    public function FormItemLayout()
    {
        super();
    }
    
    // true if setLayoutColumnWidths has been called.
    private var useLayoutColumnWidths:Boolean = false;
    
    /**
     *  @private
     *  Only resize columns and rows if setLayoutColumnWidths hasn't been called.
     */
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        checkUseVirtualLayout();
        
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;
        
        if (!useLayoutColumnWidths)
            measureAndPositionColumnsAndRows();
        
        layoutContent(unscaledWidth, unscaledHeight);
        
        useLayoutColumnWidths = false;
    }
    
    /**
     *  @private
     *  Used by layout to get the measured column widths
     */
    mx_internal function getMeasuredColumnWidths():Vector.<Number>
    {
        measureAndPositionColumnsAndRows();
        
        var constraintColumns:Vector.<ConstraintColumn> = this.constraintColumns;
        var numCols:int = constraintColumns.length;
        var columnWidths:Vector.<Number> = new Vector.<Number>(numCols, true);
        
        for (var i:int = 0; i < numCols; i++)
            columnWidths[i] = constraintColumns[i].width;
        
        return columnWidths;
    }
        
    /**
     *  @private
     *  Used by layout to set the column widths for updateDisplayList. Must
     *  call this if you want to override the default widths of the columns.
     */
    mx_internal function setLayoutColumnWidths(value:Vector.<Number>):void
    {
        //apply new measurements and position the columns again.
        useLayoutColumnWidths = true;
        
        var constraintColumns:Vector.<ConstraintColumn> = this.constraintColumns;
        var numCols:int = constraintColumns.length;
        var totalWidth:Number = 0;
        
        for (var i:int = 0; i < numCols; i++)
        {
            constraintColumns[i].setActualWidth(value[i]);
            constraintColumns[i].x = totalWidth;
            totalWidth += value[i];
        }
    }
}
}