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

package spark.layouts
{
import mx.containers.utilityClasses.ConstraintColumn;
import mx.core.mx_internal;

import spark.components.supportClasses.GroupBase;

use namespace mx_internal;

/**
 *  The FormItemLayout is used by FormItems to provide a constraint based layout.
 *  Elements using FormItemLayout within a FormLayout are aligned along columns.  
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
public class FormItemLayout extends ConstraintLayout
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
    public function FormItemLayout()
    {
        super();
    }
    
    private var layoutColumnWidths:Vector.<Number> = null;
    
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
        
        // need to parse constraints and rows may resize.
        measureAndPositionColumnsAndRows(unscaledWidth, unscaledHeight);
        
        if (layoutColumnWidths)
            setColumnWidths(layoutColumnWidths);
        
        layoutContent(unscaledWidth, unscaledHeight);
    }
    
    /**
     *  @private
     *  Used by layout to get the measured column widths
     */
    public function getMeasuredColumnWidths():Vector.<Number>
    {
        return measureColumns();
    }
        
    /**
     *  @private
     *  Used by layout to set the column widths for updateDisplayList. Must
     *  call this if you want to override the default widths of the columns.
     */
    public function setLayoutColumnWidths(value:Vector.<Number>):void
    {
        // apply new measurements and position the columns again.
        layoutColumnWidths = value;
        
        setColumnWidths(layoutColumnWidths);
        
        target.invalidateDisplayList();
    }
    
}
}