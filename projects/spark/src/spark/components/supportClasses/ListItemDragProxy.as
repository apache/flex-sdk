////////////////////////////////////////////////////////////////////////////////
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////


package spark.components.supportClasses
{
import flash.geom.PerspectiveProjection;
import flash.geom.Rectangle;
import flash.display.DisplayObject;

import mx.core.IFactory;
import mx.core.IVisualElement;
import mx.utils.MatrixUtil;

import spark.components.DataGroup;
import spark.components.Group;
import spark.components.IItemRenderer;
import spark.components.List;

/**
 *  The ListItemDragProxy class defines the default drag proxy used 
 *  when dragging from a Spark List based control.
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ListItemDragProxy extends Group
{
    include "../../core/Version.as";
    
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
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function ListItemDragProxy()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function createChildren():void
    {
        super.createChildren();
        
        var list:List = owner as List;
        if (!list)
            return;
        
        var dataGroup:DataGroup = list.dataGroup;
        if (!dataGroup)
            return;
        
        // Make sure we inherit styles from the drag initiator, as those styles
        // may be affecting the appearance of the item renderers.
        this.styleName = list;
        
        width = dataGroup.width
        height = dataGroup.height;
        
        // Find all visible children within the selection:
        var selection:Vector.<int> = list.selectedIndices;
        if (!selection)
            return;
        
        var offsetX:Number = 0;
        var offsetY:Number = 0;
        var scrollRect:Rectangle = dataGroup.scrollRect;
        if (scrollRect)
        {
            offsetX = scrollRect.x;
            offsetY = scrollRect.y;
        }
        
        var perspectiveProjection:PerspectiveProjection = dataGroup.transform.perspectiveProjection;
        
        // Construct an image by adding clones of the visible item renderers
        var elementsIn3D:Boolean = false;
        var count:int = selection.length;
        for (var i:int = 0; i < count; i++)
        {
            // The element may be null if the layout is virtualized and the
            // ItemRenderer is not created by the layout (usually when the
            // ItemRenderer falls outside the viewport).
            var element:IVisualElement = dataGroup.getElementAt(selection[i]);
            if (!element || !(element is IItemRenderer))
                continue;
            
            if (element.is3D)
                elementsIn3D = true;
            
            // Check visibility of the ItemRenderer. It's not guaranteed that the
            // dataGroup returns null for ItemRenderers outside the viewport
            if (scrollRect)
            {
                var elementBounds:Rectangle;
                if (element.hasLayoutMatrix3D)
                {
                    // Bounds in child coordinates
                    elementBounds = new Rectangle(0, 0,
                                                  element.getLayoutBoundsWidth(false), 
                                                  element.getLayoutBoundsHeight(false));

                    // Bounds transformed in 3D and projected to parent
                    elementBounds = MatrixUtil.projectBounds(elementBounds, 
                                                             element.getLayoutMatrix3D(), 
                                                             perspectiveProjection);
                }
                else
                    elementBounds = getElementBounds(element);

                if (!scrollRect.containsRect(elementBounds) && !scrollRect.intersects(elementBounds))
                    continue;
            }

            var clone:IItemRenderer = cloneItemRenderer(IItemRenderer(element), list);

            // Copy the dimensions
            clone.width = element.width;
            clone.height = element.height;

            // Copy the transform
            if (element.hasLayoutMatrix3D)
                clone.setLayoutMatrix3D(element.getLayoutMatrix3D(), false);
            else
                clone.setLayoutMatrix(element.getLayoutMatrix(), false);
            clone.x -= offsetX;
            clone.y -= offsetY;

            // Copy other relevant properties
            clone.depth = element.depth;
            clone.visible = element.visible;
            if (element.postLayoutTransformOffsets)
                clone.postLayoutTransformOffsets = element.postLayoutTransformOffsets;
            
            // Put it in a dragging state
            clone.dragging = true;

            // Add the clone as a child
            addElement(clone);
        }

        // Copy projection matrix, if there was an element in 3d.
        if (elementsIn3D)
            this.transform.perspectiveProjection = perspectiveProjection;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------

    // FIXME (egeorgie): find a better place for this helper method.
    static private var elementBounds:Rectangle;
    /**
     *  @private
     *  Returns the bounds for the passed in element.
     */
    private function getElementBounds(element:IVisualElement):Rectangle
    {
        if (!elementBounds)
            elementBounds = new Rectangle();
        elementBounds.x = element.getLayoutBoundsX();
        elementBounds.y = element.getLayoutBoundsY();
        elementBounds.width = element.getLayoutBoundsWidth();
        elementBounds.height = element.getLayoutBoundsHeight();
        return elementBounds;
    }

    /**
     *  @private
     *  Clones the passed in renderer. The data item is not cloned.
     *  The clone and the original render the same item.
     */
    private function cloneItemRenderer(renderer:IItemRenderer, list:List):IItemRenderer
    {
        // Create a new ItemRenderer:
        // 1. if itemRendererFunction is defined, call it to get the renderer factory and instantiate it
        // 2. if itemRenderer is defined, instantiate one
        
        // 1. if itemRendererFunction is defined, call it to get the renderer factory and instantiate it    
        var rendererFactory:IFactory;
        var itemRendererFunction:Function = list.itemRendererFunction;
        var data:Object = renderer.data;
        if (itemRendererFunction != null)
            rendererFactory = itemRendererFunction(data);
        
        // 2. if itemRenderer is defined, instantiate one
        if (!rendererFactory)
            rendererFactory = list.itemRenderer;
        
        var newRenderer:IItemRenderer = rendererFactory.newInstance();
        
        // Initialize the item renderer
        if (!newRenderer)
            return null;
        
        // The list is the IItemRendererOwner for this renderer.
        // It will set all the properties on this renderer, based on 
        // the itemIndex and data.
        list.updateRenderer(newRenderer, renderer.itemIndex, data);
        
        return newRenderer;
    }
}
}