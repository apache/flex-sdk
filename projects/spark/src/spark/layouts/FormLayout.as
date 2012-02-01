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
import mx.core.ILayoutElement;
import mx.core.mx_internal;

import spark.components.Form;
import spark.components.supportClasses.GroupBase;
import spark.components.supportClasses.SkinnableComponent;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

/**
 *  The default layout for Spark Form skins.
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class FormLayout extends VerticalLayout
{
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */                  
    public function FormLayout()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  IFormLayout Implementation
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Maximum width for each column.
     */
    private var columnMaxWidths:Vector.<Number>;
    
    /**
     *  @private
     *  Caches the previously calculated column widths.
     */
    private var columnWidthsOverride:Vector.<Number>;
    
    /**
     *  @private
     */
    public function getMeasuredColumnWidths():Vector.<Number>
    {
        calculateColumnMaxWidths();
        return columnMaxWidths;
    }
    
    /**
     *  @private
     */
    public function setLayoutColumnWidths(value:Vector.<Number>):void
    {
        columnWidthsOverride = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function measure():void
    {
        super.measure();
        
        const layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;

        if (columnWidthsOverride == null)
            calculateColumnMaxWidths();
        
        var colWidths:Vector.<Number> = columnWidthsOverride == null ? columnMaxWidths : columnWidthsOverride;
        
        var formWidth:Number = calculateColumnWidthsSum(colWidths);
        
        // use measured column widths to set Form's measuredWidth
        // Assumes measuredWidth is already set in super.measure()
        layoutTarget.measuredWidth = Math.max(formWidth, layoutTarget.measuredWidth);
        layoutTarget.measuredMinWidth = Math.max(formWidth, layoutTarget.measuredMinWidth);
    }
    
    /**
     *  @private
     */
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {            
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        // Need to get the max column widths again because they might have changed
        // due to resolution of certain constraints
        if (columnWidthsOverride == null)
            calculateColumnMaxWidths();
        
        var colWidths:Vector.<Number> = columnWidthsOverride == null ? columnMaxWidths : columnWidthsOverride;
  
        var eltWidth:Number = calculateColumnWidthsSum(colWidths);
        
        var layout:LayoutBase;
        var fiLayout:FormItemLayout;
        
        // Apply constraint columns before measuring
        const layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;
        
        const nElts:int = layoutTarget.numElements;
        var elt:ILayoutElement
        
        if (colWidths != null)
        {
            var eltHeight:Number;
            
            for(var i:int = 0; i < nElts; i++)
            { 
                elt = layoutTarget.getElementAt(i);
                if (!elt.includeInLayout)
                    continue;
                
                layout = getElementLayout(elt);
                
                if (layout is FormItemLayout)
                {
                    // Force each form item to use the max column widths
                    fiLayout = layout as FormItemLayout;
                    fiLayout.setLayoutColumnWidths(colWidths);
                    // Set the size of the element to use the sum of the maximum column widths
                    // TODO (jszeto) This might not be accurate for Form if the skin has a bunch of chrome
                    elt.setLayoutBoundsSize(Math.max(eltWidth, elt.getLayoutBoundsWidth(false)),
                        elt.getLayoutBoundsHeight(false)); 
                }
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Iterate through all of the form items (elements with a FormItemLayout layout)
     *  and calculate the maximum width for each column. 
     */
    private function calculateColumnMaxWidths():void
    { 
        const layoutTarget:GroupBase = target;
        
        var layout:LayoutBase;
        var fiLayout:FormItemLayout;
                    
        const nElts:int = layoutTarget.numElements;
        var elt:ILayoutElement;
        var lastColumnCount:Number = NaN;
        
        // Initialize the Vector. It is reset everytime measure or updateDisplayList is called
        columnMaxWidths = new Vector.<Number>();
        
        for(var i:int = 0; i < nElts; i++)
        {
            elt = layoutTarget.getElementAt(i);
            if (!elt.includeInLayout)
                continue;
            
            layout = getElementLayout(elt);
            
            if (layout is FormItemLayout)
            {
                fiLayout = layout as FormItemLayout;
                var cols:Vector.<Number> = fiLayout.getMeasuredColumnWidths();
        
                if (isNaN(lastColumnCount))
                    lastColumnCount = cols.length;
                
                if (columnMaxWidths.length == 0)
                {
                    for (var j:int = 0; j < cols.length; j++)
                        columnMaxWidths[j] = 0;
                }
                
                // TODO (jszeto) grab this error message from a resource bundle
                if (lastColumnCount != cols.length)
                    throw new Error("The Form must have form items with the same number of constraint columns");
                // TODO add logic to throw RTE if column lengths don't match
                
                for (var k:int = 0; k < cols.length; k++)
                {
                    columnMaxWidths[k] = Math.max(columnMaxWidths[k], cols[k]);
                }
            }
        }
    }
    
    /**
     *  @private
     *  Return the sum of all of the column widths
     */
    private function calculateColumnWidthsSum(columnWidths:Vector.<Number>):Number
    {
        if (columnWidths == null)
            return 0;
        
        var sum:Number = 0;
        for (var i:int = 0; i < columnWidths.length; i++)
        {
            sum += columnWidths[i];
        }
        
        return sum;
    }
    
    /**
     *  @private
     *  Look for the layout property of several known types. 
     *  For Form, we want the content layout. 
     *  For SkinnableComponent, we want the skin's layout. 
     *  For GroupBase, we get the layout (it has no skin).
     *  If that layout is an IFormItemLayout, then it will
     *  participate in the FormLayout's column alignment
     */ 
    private function getElementLayout(elt:ILayoutElement):LayoutBase
    {
        var layout:LayoutBase = null;
        
        if (elt is SkinnableComponent)
        {
            var skin:GroupBase = SkinnableComponent(elt).skin as GroupBase;
            if (skin)
                layout = skin.layout;
        }
        else if (elt is GroupBase)
        {
            layout = GroupBase(elt).layout;
        }
        
        return layout;
    }
}
}
    
