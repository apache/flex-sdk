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
import flash.display.DisplayObject;
import flash.geom.Rectangle;

import mx.core.IFactory;
import mx.core.IInvalidating;
import mx.core.IVisualElement;

import spark.components.DataGroup;
import spark.components.Group;
import spark.components.IItemRenderer;
import spark.components.List;

/**
 *  The default drag proxy used when dragging from a Spark List based control.
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
        
        // Generate a dragImage
        // FIXME (egeorgie): do we need to set the image size here?
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
        
        // Construct an image by adding clones of the visible item renderers
        var count:int = selection.length;
        for (var i:int = 0; i < count; i++)
        {
            // The element may be null if the layout is virtualized and the
            // ItemRenderer is not created by the layout (usually when the
            // ItemRenderer falls outside the viewport).
            var element:IVisualElement = dataGroup.getElementAt(selection[i]);
            if (!element || !(element is IItemRenderer))
                continue;
            
            // FIXME (egeorgie): figure out a better way to test for 3D.
            var displayObject:DisplayObject = element as DisplayObject;
            var is3D:Boolean = false;
            
            // Check visibility of the ItemRenderer. It's not guaranteed that the
            // dataGroup returns null for ItemRenderers outside the viewport
            if (scrollRect)
            {
                // FIXME (egeorgie): For elements with 3D, the bounds calculations will not be correct.
                if (is3D)
                {
                }
                else
                {
                    var elementBounds:Rectangle = getElementBounds(element);
                    if (!scrollRect.containsRect(elementBounds) && !scrollRect.intersects(elementBounds))
                        continue;
                }
            }
            
            var clone:IVisualElement = cloneItemRenderer(IItemRenderer(element), list);
            // FIXME (egeorgie): update the clone's state to "dragging" 

            // Add the clone as a child
            clone.x -= offsetX;
            clone.y -= offsetY;
            addElement(clone);
        }
        
        // FIXME (egeorgie): copy projection matrix, if there was a renderer in 3d.
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
        
        // Set the data    
        newRenderer.data = data;
        
        // The lis tis the IItemRendererOwner for this renderer.
        // It will update the renderer owner.
        list.updateRenderer(newRenderer);
        
        // setup the dimensions of the newRenderer
        newRenderer.width = renderer.width;
        newRenderer.height = renderer.height;
        
        // FIXME (egeorgie): Copy the appropriate matrix depending on 2D/3D
        //newRenderer.setLayoutMatrix3D(renderer.getLayoutMatrix3D(), false);
        newRenderer.setLayoutMatrix(renderer.getLayoutMatrix(), false);
        
        // FIXME (egeorgie): Copy the depth property
        return newRenderer;
    }
}
}