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
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.components.baseClasses.FxListBase;
import mx.core.ClassFactory;
import mx.events.ItemExistenceChangedEvent;
import mx.layout.HorizontalLayout;
import mx.layout.VerticalLayout;
import mx.skins.spark.FxDefaultItemRenderer;

[IconFile("FxList.png")]

/**
 *  The FxList control displays a vertical list of items.
 *  Its functionality is very similar to that of the SELECT
 *  form element in HTML.
 *  If there are more items than can be displayed at once, it
 *  can display a vertical scroll bar so the user can access
 *  all items in the list.
 *  An optional horizontal scroll bar lets the user view items
 *  when the full width of the list items is unlikely to fit.
 *  The user can select one or more items from the list, depending
 *  on the value of the <code>allowMultipleSelection</code> property.
 *
 *  @includeExample examples/FxListExample.mxml
 */
public class FxList extends FxListBase
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
        
        //Add a keyDown event listener so we can adjust
        //selection accordingly.  
        addEventListener(KeyboardEvent.KEY_DOWN, list_keyDownHandler, true);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /*
     *  TODO: description of how single selection properties
     *  work when multiple selection is enabled. multiple selection
     *  doesn't support selectionChanging event. etc.
     */
    /**
     *  <code>true</code> if the list supports multiple selection.
     * 
     *  @default false
     */
    public var allowMultipleSelection:Boolean = false;
    
    //----------------------------------
    //  selectedIndex
    //----------------------------------
    
    
    [Bindable("selectionChanged")]
    /**
     *  The 0-based index of the selected item, or -1 if no item is selected.
     *  Setting the <code>selectedIndex</code> property deselects the currently selected
     *  item and selects the item at the specified index.
     *
     *  <p>The value of <code>selectedIndex</code> is always between -1 and 
     *  (<code>numItems</code> - 1). 
     *  If items at a lower index than <code>selectedIndex</code> are 
     *  removed from the component, the selected index is adjusted downward
     *  accordingly. </p>
     * 
     *  <p>When the value of the <code>allowMultipleSelection</code> property
     *  is <code>true</code>, the property is set to the first selected item.</p>
     *
     *  @default -1
     */
    override public function get selectedIndex():int
    {
        if (!allowMultipleSelection)
            return super.selectedIndex;
            
        if (_selectedIndices && _selectedIndices.length > 0)
            return _selectedIndices[0];
        
        return NO_SELECTION;
    }
    
    /**
     *  @private
     */
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
    
    [Bindable("selectionChanged")]
    /*
     *  Selected indices for this component.
     *  
     *  TODO: describe
     * 
     *  @default null
     */
    /**
     *  Selected indices for this component.
     *  
     *  @default null
     */
    public function get selectedIndices():Array
    {
        if (!allowMultipleSelection)
            return null;
            
        return _selectedIndices;
    }
    
    /**
     *  @private
     */
    public function set selectedIndices(value:Array):void
    {
        if (!allowMultipleSelection)
            return;
            
        // ?? should we check to see if the selection changed?
        
        multipleSelectionChanged = true;
        _proposedSelectedIndices = value;
        invalidateProperties();
    }
    
    [Bindable("selectionChanged")]
    /*
     *  Selected items for this component.
     * 
     *  TODO: describe
     * 
     *  @default null
     */
    /**
     *  Selected items for this component.
     * 
     *  @default null
     */
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
    
    /**
     *  @private
     */
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
        var item:Object = dataGroup.getItemRenderer(item);
        
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
     *  Returns true if the item is selected.
     */
    public function isItemSelected(item:Object):Boolean
    {
        if (allowMultipleSelection)
        {
            var itemIndex:int = dataProvider.getItemIndex(item);
            
            return selectedIndices.indexOf(itemIndex) != -1;
        }
        
        return item == selectedItem;
    }
        
    /**
     *  @inheritDoc
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
     *  @inheritDoc
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
        var renderer:Object = dataGroup.getItemRenderer(event.relatedObject);
        
        if (renderer)
            renderer.addEventListener("click", item_clickHandler);
            
        if (isItemSelected(event.relatedObject))
            itemSelected(event.relatedObject, true);
    }
    
    /**
     *  @private
     *  Called when an item has been removed from this component.
     */
    private function dataGroup_itemRemoveHandler(event:ItemExistenceChangedEvent):void
    {        
        var renderer:Object = dataGroup.getItemRenderer(event.relatedObject);
        
        if (renderer)
            renderer.removeEventListener("click", item_clickHandler);
    }
    
    /**
     *  @private
     *  Called when an item is clicked.
     */
    private function item_clickHandler(event:MouseEvent):void
    {
        // Multiple selection needs to be added here....
        
        selectedItem = dataGroup.getRendererItem(DisplayObject(event.currentTarget));
    }
    
    /**
     *  @private
     *  Build in basic keyboard navigation support in List. 
     *  TODO: Deepa - add overrideable methods to control 
     *  keyboard navigation across components and layout. 
     */
    private function list_keyDownHandler(event:KeyboardEvent):void
    {
        var nextInView:Number;
        switch (event.keyCode)
        {
            case Keyboard.UP:
            {
                if (layout is VerticalLayout)
                {
                    nextInView = VerticalLayout(layout).inView(selectedIndex-1); 
                    //The next item is already in full or partial view - don't scroll, just select it.
                    if ((nextInView == 1) || (nextInView < 0))
                        event.stopPropagation();
                    //The last item was selected and partially in view, don't increment selection 
                    if (nextInView == 0 && (VerticalLayout(layout).firstIndexInView == selectedIndex))
                        return;
                    //Adjust selection 
                    if (selectedIndex > 0)
                        selectedIndex--;
                }
                break;
            }
            case Keyboard.DOWN:
            {
                if (layout is VerticalLayout)
                {
                    nextInView = VerticalLayout(layout).inView(selectedIndex+1);
                    //The next item is already in full or partial view - don't scroll
                    if ((nextInView == 1) || (nextInView < 0))
                        event.stopPropagation();
                    //The last item was selected and partially in view, don't increment selection 
                    if (nextInView == 0 && (VerticalLayout(layout).lastIndexInView == selectedIndex))
                        return;
                    //Adjust selection 
                    if (selectedIndex < (dataProvider.length - 1))
                        selectedIndex++;
                }
                break;
            }
            case Keyboard.LEFT:
            {
                if (layout is HorizontalLayout)
                {
                    nextInView = HorizontalLayout(layout).inView(selectedIndex-1); 
                    //The next item is already in full or partial view - don't scroll
                    if ((nextInView == 1) || (nextInView < 0))
                        event.stopPropagation();
                    //The last item was selected and partially in view, don't increment selection 
                    if (nextInView == 0 && (HorizontalLayout(layout).firstIndexInView == selectedIndex))
                        return;
                    //Adjust selection 
                    if (selectedIndex > 0)
                        selectedIndex--;
                }
                break;
            }
            case Keyboard.RIGHT:
            {
                if (layout is HorizontalLayout)
                {
                    nextInView = HorizontalLayout(layout).inView(selectedIndex+1); 
                    //The next item is already in full or partial view - don't scroll
                    if ((nextInView == 1) || (nextInView < 0))
                        event.stopPropagation();
                    //The last item was selected and partially in view, don't increment selection 
                    if (nextInView == 0 && (HorizontalLayout(layout).lastIndexInView == selectedIndex))
                        return;
                    //Adjust selection 
                    if (selectedIndex < (dataProvider.length - 1))
                        selectedIndex++;
                }
                break;
            }            
        }
    }
  
}

}