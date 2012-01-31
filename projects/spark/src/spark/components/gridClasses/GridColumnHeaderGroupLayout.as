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
import flash.geom.Rectangle;

import mx.core.ILayoutElement;
import mx.core.IVisualElement;
import mx.core.mx_internal;

import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

public class ColumnHeaderBarLayout extends LayoutBase
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
    public function ColumnHeaderBarLayout()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private var gridLayout:GridLayout;
    
    /**
     *  @private
     */
    private var visibleColumnIndices:Vector.<int> = new Vector.<int>;
    
    /**
     *  @private
     */
    private var oldVisibleColumnIndices:Vector.<int>;
    
    /**
     *  @private
     */
    private var visibleHeaderSeparators:Vector.<IVisualElement> = 
                                        new Vector.<IVisualElement>(0);
    
    //---------------------------------------------------------------
    //
    //  Class properties
    //
    //---------------------------------------------------------------
        
    /**
     *  @private
     */
    override public function get useVirtualLayout():Boolean
    {
        return true;
    }
    
    /**
     *  @private
     */
    override public function set useVirtualLayout(value:Boolean):void
    {
    }
    
    /**
     *  @private
     */
    private function get columnGap():Number
    {
        return gridDimensions ? gridDimensions.columnGap : 0;
    }
    
    /**
     *  @private
     *  The GridDimensions associated with this CHB.
     */
    private function get gridDimensions():GridDimensions
    {        
        return gridLayout ? gridLayout.gridDimensions : null;       
    }

    //---------------------------------------------------------------
    //
    //  Class methods
    //
    //---------------------------------------------------------------
    
    /**
     *  @private
     *  Used to connect this layout with the grid layout and to
     *  signal to this layout that it needs to update.
     */
    public function updateLayout(layout:GridLayout):void
    {
        gridLayout = layout;
            
        const layoutTarget:GroupBase = target;
        if (layoutTarget)
            layoutTarget.invalidateDisplayList();
    }
    
    //---------------------------------------------------------------
    //
    //  Overridden methods
    //
    //---------------------------------------------------------------

    /**
     *  @private
     */
    override public function measure():void
    {
        var totalWidth:Number = 0;
        var totalHeight:Number = 0;

        // loop through the elements
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;
        
        var count:int = layoutTarget.numElements;
        for (var i:int = 0; i < count; i++)
        {
            var element:ILayoutElement = layoutTarget.getVirtualElementAt(i);
            
            // The element returned could still be null. Look at the typical 
            // element instead.
            if (!element)
                element = typicalLayoutElement;

            // Find the preferred sizes    
            var elementWidth:Number = element.getPreferredBoundsWidth();
            var elementHeight:Number = element.getPreferredBoundsHeight();
            
            totalWidth += elementWidth;
            totalHeight = Math.max(totalHeight, elementHeight);
        }
        if (count > 0)
            totalWidth += (count - 1) * columnGap;
        
        layoutTarget.measuredWidth = totalWidth;
        layoutTarget.measuredHeight = totalHeight;
        
        // Since we really can't fit the content in space any
        // smaller than this, set the measured minimum size
        // to be the same as the measured size.
        // If the container is clipping and scrolling, it will
        // ignore these limits and will still be able to 
        // shrink below them.
        layoutTarget.measuredMinWidth = totalWidth;
        layoutTarget.measuredMinHeight = totalHeight; 
    }

    /**
     *  @private
     */
    override public function updateDisplayList(unscaledWidth:Number,
                                               unscaledHeight:Number):void
    {
        var maxHeight:Number = 0;
        
        var layoutTarget:GroupBase = target;
        if (!layoutTarget || !gridLayout)
            return;
        
        oldVisibleColumnIndices = visibleColumnIndices;
        visibleColumnIndices = gridLayout.getVisibleColumnIndices();
        
        for each (var columnIndex:int in visibleColumnIndices)
        {
            var element:ILayoutElement = 
                layoutTarget.getVirtualElementAt(columnIndex);
            
            const bounds:Rectangle = gridDimensions.getColumnBounds(columnIndex);
            
            const elementWidth:Number = bounds.width;
            
            var elementHeight:Number;
            const prefHeight:Number = 
                typicalLayoutElement.getPreferredBoundsHeight();
            if (prefHeight)
            {
                elementHeight = prefHeight;
            }
            else
            {
                // Find out the element's dimensions sizes.
                // We do this after the element has been already resized
                // to its preferred size by passing NaN for the constraints.
                element.setLayoutBoundsSize(NaN, NaN);                
                elementHeight = element.getLayoutBoundsHeight();
            }
            element.setLayoutBoundsSize(elementWidth, elementHeight);
            
            // Position the element.
            element.setLayoutBoundsPosition(bounds.x, 0);
            
            // Find maximum element extents. This is needed for
            // the scrolling support.
            maxHeight = Math.max(maxHeight, elementHeight);
        }
                
        // Scrolling support - update the content size
        layoutTarget.setContentSize(gridDimensions.contentWidth, maxHeight);
        
        // ToDo(cframpto): 
        // These separators will need mouse listeners for the column move.
        // The listeners will have to be removed when the separators are freed 
        // or will have to be cached in a seperate freed list.
        
        // Now layout the separators between the headers.
        visibleHeaderSeparators = gridLayout.layoutColumnHeaderSeparators(
                                                oldVisibleColumnIndices, 
                                                visibleColumnIndices, 
                                                visibleHeaderSeparators);
        
        oldVisibleColumnIndices.length = 0;
    }
    
}
}