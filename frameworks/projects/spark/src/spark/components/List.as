////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package flex.component
{
import flash.display.DisplayObject;
import flash.events.MouseEvent;

import flex.events.ItemExistenceChangedEvent;
import flex.skin.DefaultItemRenderer;

import mx.core.ClassFactory;
import mx.core.IFactory;

/**
 *  The List class.
 */
public class List extends Selector
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constants
    //
    //--------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     */
    public function List()
    {
        super();
        itemRenderer = new ClassFactory(DefaultItemRenderer);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Flag that determines if the items in a list are rendered directly or 
     *  wrapped by an item renderer.
     * 
     *  <p>For example, a list may contain Image components. In this case, you want
     *  the images to be wrapped by the item renderer so highlighting and 
     *  selection works correctly. Another list may have ToggleButtons as items.
     *  In this case, the buttons themselves are the renderers, and do not
     *  need to be wrapped.</p>
     * 
     *  @default false
     */
    public var itemsAreRenderers:Boolean = false;
    
    /**
     *  Flag that determines if the list supports multiple selection.
     * 
     *  TODO: description of how single selection properties
     *  work when multiple selection is enabled. multiple selection
     *  doesn't support selectionChanging event. etc.
     * 
     *  @default false
     */
    public var allowMultipleSelection:Boolean = false;
    
    //----------------------------------
    //  selectedIndex
    //----------------------------------
    
   /**
     *  The 0-based index of the selected item, or -1 if no item is selected.
     *  Setting the selectedIndex property de-selects the currently selected
     *  item and selects the item at the specified index.
     *
     *  The value of selectedIndex is always pinned between -1 and 
     *  (numItems - 1). If items at a lower index than selectedIndex are 
     *  removed from the component, the selected index is adjusted downward
     *  accordingly. 
     * 
     *  When the value of the <code>allowMultipleSelection</code> property
     *  is true, the getter returns the first selected item.
     *
     *  @default -1
     */
    
    [Bindable("selectionChanged")]
    override public function get selectedIndex():int
    {
        if (!allowMultipleSelection)
            return super.selectedIndex;
            
        if (_selectedIndices && _selectedIndices.length > 0)
            return _selectedIndices[0];
        
        return NO_SELECTION;
    }
    
    override public function set selectedIndex(value:int):void
    {
        if (!allowMultipleSelection)
        {
            super.selectedIndex = value;
            return;
        }
        
        selectedIndices = [value];
        invalidateProperties();
    }
    
    
    /**
     *  @private
     *  Internal storage for the selectedIndices property and invalidation variables.
     */
    private var _selectedIndices:Array;
    private var _proposedSelectedIndices:Array;
    private var multipleSelectionChanged:Boolean = false;
    
    /**
     *  Selected indices for this component.
     *  
     *  TODO: describe
     * 
     *  @default null
     */
    [Bindable("selectionChanged")]
    public function get selectedIndices():Array
    {
        if (!allowMultipleSelection)
            return null;
            
        return _selectedIndices;
    }
    
    public function set selectedIndices(value:Array):void
    {
        if (!allowMultipleSelection)
            return;
            
        // ?? should we check to see if the selection changed?
        
        multipleSelectionChanged = true;
        _proposedSelectedIndices = value;
        invalidateProperties();
    }
    
    /**
     *  Selected items for this component.
     * 
     *  TODO: describe
     * 
     *  @default null
     */
    [Bindable("selectionChanged")]
    public function get selectedItems():Array
    {
        var result:Array;
        
        if (selectedIndices)
        {
            result = [];
            
            var count:int = selectedIndices.length;
            
            for (var i:int = 0; i < count; i++)
                result[i] = getItemAt(selectedIndices[i]);  
        }
        
        return result;
    }
    
    public function set selectedItems(value:Array):void
    {
        var indices:Array;
        
        if (value)
        {
            indices = [];
            
            var count:int = value.length;
            
            for (var i:int = 0; i < count; i++)
                indices[i] = getItemIndex(value[i]);
        }
        
        selectedIndices = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (multipleSelectionChanged)
        {
            multipleSelectionChanged = false;
            commitMultipleSelection();
        }
    }
    
    /**
     *  @private
     */
    override protected function itemSelected(item:Object, selected:Boolean):void
    {
        var item:* = contentGroup.getItemSkin(item);
        
        if (item)
            item.selected = selected;
    }
    
    /**
     *  Called when a skin part has been added or assigned. 
     *  This method sets the "alwaysUseItemRenderer" flag on the
     *  contentGroup part.
     */
    override protected function partAdded(partName:String, instance:*):void
    {
        super.partAdded(partName, instance);
        
        if (instance == contentGroup && !itemsAreRenderers)
            contentGroup.alwaysUseItemRenderer = true;
    }

    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Returns true if a is null or an empty array.
     */
    private function isEmpty(a:Array):Boolean
    {
        return a == null || a.length == 0;
    }
    
    /**
     *  @private
     */
    private function commitMultipleSelection():void
    {
        var removedItems:Array = [];
        var addedItems:Array = [];
        var i:int;
        var count:int;
    
        if (!isEmpty(_selectedIndices) && !isEmpty(_proposedSelectedIndices))
        {
            // Changing selection, determine which items were added
            count = _proposedSelectedIndices.length;
            for (i = 0; i < count; i++)
            {
                if (_selectedIndices.indexOf(_proposedSelectedIndices[i]) < 0)
                    addedItems.push(_proposedSelectedIndices[i]);
            }
            
            // determine which items were removed
            for (i = 0; i < count; i++)
            {
                if (_proposedSelectedIndices.indexOf(_selectedIndices[i]) < 0)
                    removedItems.push(_selectedIndices[i]);
            }
        }
        else if (!isEmpty(_selectedIndices))
        {
            // Going to a null selection, remove all
            removedItems = _selectedIndices;
        }
        else if (!isEmpty(_proposedSelectedIndices))
        {
            // Going from a null selection, add all
            addedItems = _proposedSelectedIndices;
        }
        
        // Commit
        _selectedIndices = _proposedSelectedIndices;
        _proposedSelectedIndices = null;
        
        // un-select the old
        if (removedItems.length > 0)
        {
            count = removedItems.length;
            for (i = 0; i < count; i++)
            {
                itemSelected(getItemAt(removedItems[i]), false);
            }
        }
        
        // select the new
        if (addedItems.length > 0)
        {
            count = addedItems.length;
            for (i = 0; i < count; i++)
            {
                itemSelected(getItemAt(addedItems[i]), true);
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Called when an item has been added to this component.
     */
    override protected function itemAddedHandler(event:ItemExistenceChangedEvent):void
    {
        super.itemAddedHandler(event);
        
        var skin:* = contentGroup.getItemSkin(event.relatedObject);
        
        if (skin)
            skin.addEventListener("click", item_clickHandler);
    }
    
    /**
     *  @private
     *  Called when an item has been removed from this component.
     */
    override protected function itemRemovedHandler(event:ItemExistenceChangedEvent):void
    {
        super.itemRemovedHandler(event);
        
        var skin:* = contentGroup.getItemSkin(event.relatedObject);
        
        if (skin)
            skin.removeEventListener("click", item_clickHandler);
    }
    
    /**
     *  @private
     *  Called when an item is clicked.
     */
    private function item_clickHandler(event:MouseEvent):void
    {
        // Multiple selection needs to be added here....
        
        selectedItem = contentGroup.getSkinItem(DisplayObject(event.currentTarget));
    }
}

}