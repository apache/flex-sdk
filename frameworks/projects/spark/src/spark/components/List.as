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

package spark.components
{
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.FocusEvent;
import flash.geom.Point;
import flash.ui.Keyboard;

import mx.core.IVisualElement;
import mx.events.IndexChangedEvent;
import mx.managers.IFocusManagerComponent;

import spark.components.supportClasses.ListBase;
import spark.events.RendererExistenceEvent;
import spark.layouts.HorizontalLayout;
import spark.layouts.VerticalLayout;

/**
 *  @copy spark.components.supportClasses.GroupBase#alternatingItemColors
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes")]

/**
 *  @copy spark.components.supportClasses.GroupBase#contentBackgroundColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes")]

/**
 *  @copy spark.components.supportClasses.GroupBase#rollOverColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]

/**
 *  @copy spark.components.supportClasses.GroupBase#selectionColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="selectionColor", type="uint", format="Color", inherit="yes")]

/**
 *  @copy spark.components.supportClasses.GroupBase#symbolColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("List.png")]
[DefaultTriggerEvent("selectionChanged")]

/**
 *  The List control displays a vertical list of items.
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
 *  @includeExample examples/ListExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class List extends ListBase implements IFocusManagerComponent
{
    include "../core/Version.as";
    
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
    public function List()
    {
        super();
        
        addEventListener(KeyboardEvent.KEY_DOWN, list_keyDownHandler);
    }
    
    //----------------------------------
    //  scroller
    //----------------------------------

    [SkinPart(required="false")]

    /**
     *  The optional Scroller used to scroll the List.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var scroller:Scroller;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  allowMultipleSelection
    //----------------------------------
    
    private var _allowMultipleSelection:Boolean = false;
    private var allowMultipleSelectionChanged:Boolean = false; 
    
    /**
     *  Boolean flag controlling whether multiple selection
     *  is enabled or not. 
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get allowMultipleSelection():Boolean
    {
        return _allowMultipleSelection;
    }
    
    /**
     *  @private
     */
    public function set allowMultipleSelection(value:Boolean):void
    {
        if (value == _allowMultipleSelection)
            return 
        
        _allowMultipleSelection = value;
        
        //Going from multiple to single, clear out selection  
        if (!_allowMultipleSelection)
        {
            _proposedSelectedIndices = [NO_SELECTION]; 
            commitMultipleSelection(); 
        } 
    }
    
    //----------------------------------
    //  selectedIndex
    //----------------------------------
    
    [Bindable("selectionChanged")]
    /**
     *  @private
     */
    override public function get selectedIndex():int
    {   
        if (!allowMultipleSelection || !_selectedIndices)
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
        if (value == selectedIndex)
            return; 
            
        selectedIndices = [value];
    }
    
    //----------------------------------
    //  selectedItem
    //----------------------------------
    
    [Bindable("selectionChanged")]
    /**
     *  @private
     */
    override public function get selectedItem():*
    {   
        if (!allowMultipleSelection)
            return super.selectedItem;
            
        if (_selectedIndices && _selectedIndices.length > 0)
            return dataProvider.getItemAt(_selectedIndices[0]); 
            
        return NO_SELECTION;
    }
    
    /**
     *  @private
     */
    override public function set selectedItem(value:*):void
    {
        if (!allowMultipleSelection)
        {
            super.selectedItem = value;
            return;
        }
        if (value == selectedItem)
            return; 
            
        selectedItems = [value];
    }
    
    
    /**
     *  @private
     *  Internal storage for the selectedIndices property and invalidation variables.
     */
    private var _selectedIndices:Array;
    private var _proposedSelectedIndices:Array;
    private var multipleSelectionChanged:Boolean = false;
    
    [Bindable("selectionChanged")]
    /**
     *  Selected indices for this component.
     *  
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
            
        if (_proposedSelectedIndices == value)
            return; 
        
        multipleSelectionChanged = true;
        _proposedSelectedIndices = value;
        invalidateProperties();
    }
    
    [Bindable("selectionChanged")]
    /**
     *  Selected items for this component.
     * 
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
        
        selectedIndices = indices;
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
    override protected function itemSelected(index:int, selected:Boolean):void
    {
        super.itemSelected(index, selected);
        
        var renderer:Object = dataGroup ? dataGroup.getElementAt(index) : null;
        
        if (renderer is IItemRenderer)
        {
            IItemRenderer(renderer).selected = selected;
        }
    }
    
    /**
     *  @private
     */
    override public function isItemIndexSelected(index:int):Boolean
    {
        if (allowMultipleSelection && (selectedIndices != null))
            return selectedIndices.indexOf(index) != -1;
        
        return index == selectedIndex;
    }
        
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        if (instance == dataGroup)
        {
            dataGroup.addEventListener(
                RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler);
            dataGroup.addEventListener(
                RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererRemoveHandler);
        }
        // The scroller, between textView and this in the chain, should not 
        // getFocus.
        if (instance == scroller)
            scroller.focusEnabled = false;
    }

    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == dataGroup)
        {
            dataGroup.removeEventListener(
                RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler);
            dataGroup.removeEventListener(
                RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererRemoveHandler);
        }
        
        super.partRemoved(partName, instance);
    }
    
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
     *  Given a new selection interval, figure out which
     *  items are newly added/removed from the selection interval and update
     *  selection properties and view accordingly. Additionally, dispatch the 
     *  selectionChanged event. 
     */
    private function commitMultipleSelection():void
    {
        var removedItems:Array = [];
        var addedItems:Array = [];
        var i:int;
        var count:int;
    
        if (!isEmpty(_selectedIndices) && !isEmpty(_proposedSelectedIndices))
        {
            // Changing selection, determine which items were added to the 
            // selection interval 
            count = _proposedSelectedIndices.length;
            for (i = 0; i < count; i++)
            {
                if (_selectedIndices.indexOf(_proposedSelectedIndices[i]) < 0)
                    addedItems.push(_proposedSelectedIndices[i]);
            }
            
            // Then determine which items were removed from the selection 
            // interval 
            count = _selectedIndices.length; 
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
        
        // Commit the selected Indices 
        _selectedIndices = _proposedSelectedIndices;
        _proposedSelectedIndices = null;
        
        // De-select the old items that were selected 
        if (removedItems.length > 0)
        {
            count = removedItems.length;
            for (i = 0; i < count; i++)
            {
                itemSelected(removedItems[i], false);
            }
        }
        
        // Select the new items in the new selection interval 
        if (addedItems.length > 0)
        {
            count = addedItems.length;
            for (i = 0; i < count; i++)
            {
                itemSelected(addedItems[i], true);
            }
        }
        
        //Dispatch the selectionChanged event
        var e:IndexChangedEvent = new IndexChangedEvent(IndexChangedEvent.SELECTION_CHANGED);
        e.multipleSelectionChange = true; 
        dispatchEvent(e); 
    }
    
    /**
     *  @private
     *  Taking into account which modifier keys were clicked, the new
     *  selectedIndices interval is calculated. 
     */
    private function calculateSelectedIndicesInterval(renderer:IVisualElement, shiftKey:Boolean, ctrlKey:Boolean):Array
    {
        var i:int; 
        var interval:Array = []; 
        var index:Number = dataGroup.getElementIndex(renderer); 
        
        if (!shiftKey)
        {
            if (ctrlKey)
            {
                if (!isEmpty(selectedIndices))
                {
                    //Quick check to see if selectedIndices had only one selected item
                    //and that item was de-selected
                    if (selectedIndices.length == 1 && (selectedIndices[0] == index))
                    {
                        return [NO_SELECTION];  
                    }
                    else
                    {
                        // Go through and see if the index passed in was in the 
                        // selection model. If so, leave it out when constructing
                        // the new interval so it is de-selected. 
                        var found:Boolean = false; 
                        for (i = 0; i < _selectedIndices.length; i++)
                        {
                            if (_selectedIndices[i] == index)
                                found = true; 
                            else if (_selectedIndices[i] != index)
                                interval.push(_selectedIndices[i]); 
                        }
                        if (!found)
                        {
                            //Nothing from the selection model was de-selected. 
                            //Instead, the Ctrl key was held down and we're doing a  
                            //new add. 
                            interval.push(index);   
                        }
                        return interval; 
                    } 
                }
            }
            //A single item was newly selected, add that to the selection interval.  
            else 
                return [index];
        }
        
        else (shiftKey)
        {
            //A contiguous selection action has occurred. Figure out which new 
            //indices to add to the selection interval and return that. 
            var start:Number = (!isEmpty(selectedIndices)) ? selectedIndices[0] : -1; 
            var end:Number = index; 
            if (start < end)
            {
                for (i = start; i <= end; i++)
                {
                    interval.push(i); 
                }
            }
            else 
            {
                for (i = start; i >= end; i--)
                {
                    interval.push(i); 
                }
            }
            return interval; 
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
    private function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void
    {
        var index:int = event.index;
        var renderer:IVisualElement = event.renderer;
        
        if (renderer)
        {
        	renderer.addEventListener("click", item_clickHandler);
        	updateRendererInformation(IVisualElement(renderer));
        }
            
        if (isItemIndexSelected(index))
            itemSelected(index, true);
    }
    
    /**
     *  @private
     *  Called when an item has been removed from this component.
     */
    private function dataGroup_rendererRemoveHandler(event:RendererExistenceEvent):void
    {
        var index:int = event.index;
        var renderer:Object = event.renderer;
        
        if (renderer)
        {
            renderer.removeEventListener("click", item_clickHandler);
        }
    }
    
    /**
     *  @private
     *  Called when an item is clicked.
     */
    protected function item_clickHandler(event:MouseEvent):void
    {
        if (!allowMultipleSelection)
        {
            //Single selection case 
            var newIndex:Number = dataGroup.getElementIndex(event.currentTarget as IVisualElement);  
            
            //Check to see if we're deselecting the currently selected item 
            if (event.ctrlKey && selectedIndex == newIndex)
                selectedIndex = NO_SELECTION;  
            //Otherwise, select the new item 
            else 
                selectedIndex = newIndex; 
        }
        else 
        {
            //Multiple selection is handled by the helper method below 
            selectedIndices = calculateSelectedIndicesInterval(event.currentTarget as IVisualElement, event.shiftKey, event.ctrlKey); 
        }
    }
    
    /**
     *  If the layout element at the specified index isn't completely 
     *  visible, scroll this IViewport.
     * 
     *  In the future, this method may animate the scroll.
     * 
     *  @param index The index of the item that is brought into
     *  visibility  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function ensureItemIsVisible(index:int):void
    {
        if (!layout)
            return;

        var spDelta:Point = layout.getScrollPositionDeltaToElement(index);
        if (spDelta)
        { 
            horizontalScrollPosition += spDelta.x;
            verticalScrollPosition += spDelta.y;
        }
    }
    
    
    /**
     *  @private
     *  Build in basic keyboard navigation support in List. 
     */
    protected function list_keyDownHandler(event:KeyboardEvent):void
    {   
        super.keyDownHandler(event);
        
        if (dataProvider)
        {
            //Delegate to the layout to tell us what the next item is we shoudl select. 
	        var proposedSelectedIndex:int = layout.nextItemIndex(event.keyCode, selectedIndex, dataProvider.length - 1); 
	        // Note that the KeyboardEvent is canceled even if the selectedIndex doesn't
            // change because we don't want another component to start handling these
            // events when the selectedIndex reaches a limit.
            if (proposedSelectedIndex != -1)
            {
                event.preventDefault(); 
                selectedIndex = proposedSelectedIndex; 
                ensureItemIsVisible(selectedIndex); 
            } 
		}
    }
  
}

}