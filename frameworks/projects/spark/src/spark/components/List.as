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

package mx.components
{
import flash.display.DisplayObject;
import flash.events.MouseEvent;

import mx.events.ItemExistenceChangedEvent;
import mx.skins.spark.FxDefaultItemRenderer;

import mx.core.ClassFactory;
import mx.components.baseClasses.FxSelector;

/**
 *  The List class.
 */
public class FxList extends FxSelector
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
    public function FxList()
    {
        super();
        itemRenderer = new ClassFactory(FxDefaultItemRenderer);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
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
                result[i] = dataProvider.getItemAt(selectedIndices[i]);  
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
                indices[i] = dataProvider.getItemIndex(value[i]);
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
        var item:* = dataGroup.getItemSkin(item);
        
        if (item)
        {
            if ("selected" in item)
                item.selected = selected;
            else
            {
                // TODO: localize below (and other messages)
                throw new Error("The item needs to support the \"selected\" property " + 
                        "for selection to work.  An easy way to accomplish this is by wrapping " + 
                        "your component in a DefaultComplexItemRenderer");
            }
        }
    }
	
	/**
	 *  Called when a skin part has been added or assigned. 
	 *  This method pushes the content, layout, itemRenderer, and
	 *  itemRendererFunction properties down to the contentGroup
	 *  skin part.
	 */
	override protected function partAdded(partName:String, instance:Object):void
	{
		super.partAdded(partName, instance);
		if (instance == dataGroup)
		{
			dataGroup.addEventListener(
			    ItemExistenceChangedEvent.ITEM_ADD, dataGroup_itemAddHandler);
			dataGroup.addEventListener(
			    ItemExistenceChangedEvent.ITEM_REMOVE, dataGroup_itemRemoveHandler);
		}
	}

	/**
	 *  Called when a skin part is removed.
	 */
	override protected function partRemoved(partName:String, instance:Object):void
	{
		if (instance == dataGroup)
		{
			dataGroup.removeEventListener(
			    ItemExistenceChangedEvent.ITEM_ADD, dataGroup_itemAddHandler);
			dataGroup.removeEventListener(
			    ItemExistenceChangedEvent.ITEM_REMOVE, dataGroup_itemRemoveHandler);
		}
		
		super.partRemoved(partName, instance);
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
                itemSelected(dataProvider.getItemAt(removedItems[i]), false);
            }
        }
        
        // select the new
        if (addedItems.length > 0)
        {
            count = addedItems.length;
            for (i = 0; i < count; i++)
            {
                itemSelected(dataProvider.getItemAt(addedItems[i]), true);
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
    private function dataGroup_itemAddHandler(event:ItemExistenceChangedEvent):void
    {
        var skin:* = dataGroup.getItemSkin(event.relatedObject);
        
        if (skin)
            skin.addEventListener("click", item_clickHandler);
    }
    
    /**
     *  @private
     *  Called when an item has been removed from this component.
     */
    private function dataGroup_itemRemoveHandler(event:ItemExistenceChangedEvent):void
    {        
        var skin:* = dataGroup.getItemSkin(event.relatedObject);
        
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
        
        selectedItem = dataGroup.getSkinItem(DisplayObject(event.currentTarget));
    }
}

}