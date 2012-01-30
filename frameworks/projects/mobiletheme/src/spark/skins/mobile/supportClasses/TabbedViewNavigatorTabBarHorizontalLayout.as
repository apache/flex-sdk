package spark.skins.mobile.supportClasses
{
import mx.core.ILayoutElement;

import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;

/**
 *  The TabbedViewNavigatorButtonBarHorizontalLayout class is a layout
 *  specifically designed for the TabbedViewNavigator.
 *  The layout lays out the children horizontally, left to right.
 *  
 *  <p>The layout sizes children to equal sizes and to fit the parent
 *  width.</p>
 * 
 *  <p>All children are set to the height of the parent.</p>
 * 
 *  @see spark.skins.mobile.TabbedViewNavigatorButtonBarSkin
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class TabbedViewNavigatorTabBarHorizontalLayout extends LayoutBase
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
    public function TabbedViewNavigatorTabBarHorizontalLayout()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     */
    override public function measure():void
    {
        super.measure();
        
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;
        
        var elementCount:int = 0;
        
        var width:Number = 0;
        var height:Number = 0;
        
        var count:int = layoutTarget.numElements;
        for (var i:int = 0; i < count; i++)
        {
            var layoutElement:ILayoutElement = layoutTarget.getElementAt(i);
            if (!layoutElement || !layoutElement.includeInLayout)
                continue;
            
            width += layoutElement.getPreferredBoundsWidth();
            elementCount++;
            height = Math.max(height, layoutElement.getPreferredBoundsHeight());
            
        }
        
        layoutTarget.measuredWidth = width;
        layoutTarget.measuredHeight = height;
    }
    
    /**
     *  @private 
     */
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;
        
        var childX:Number = 0;
        var count:int = layoutTarget.numElements;
        var elementCount:int = count;
        var layoutElement:ILayoutElement;
        for (var i:int = 0; i < count; i++)
        {
            layoutElement = layoutTarget.getElementAt(i);
            if (!layoutElement || !layoutElement.includeInLayout)
            {
                elementCount--;
                continue;
            }
        }
        
        // The content size is always the parent size
        layoutTarget.setContentSize(unscaledWidth, unscaledHeight);
        
        // mininum width 1px
        var preferredChildWidth:Number = Math.max(Math.floor(unscaledWidth / elementCount), 1);
        
        // distribute rounding errors evenly
        var excessWidth:Number = unscaledWidth - (preferredChildWidth * elementCount);
        var childWidth:Number = 0;
        
        // Resize and position children
        for (i = 0; i < count; i++)
        {
            layoutElement = layoutTarget.getElementAt(i);
            if (!layoutElement || !layoutElement.includeInLayout)
                continue;
            
            childWidth = (excessWidth > 0) ? preferredChildWidth + 1 : preferredChildWidth;
            
            layoutElement.setLayoutBoundsSize(childWidth, unscaledHeight);
            layoutElement.setLayoutBoundsPosition(childX, 0);
            
            childX += childWidth;
            excessWidth--;
        }
    }
}
}