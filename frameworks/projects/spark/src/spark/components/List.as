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
import flash.events.Event;
import spark.core.NavigationUnit;

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
    
    /**
     *  @private
     *  Current item in focus 
     */
    private var currentCaretIndex:Number = -1; 
    
    //----------------------------------
    //  allowMultipleSelection
    //----------------------------------
    
    private var _allowMultipleSelection:Boolean = false;
    private var allowMultipleSelectionChanged:Boolean = false; 
    
    /**
     *  Boolean flag controlling whether multiple selection
     *  is enabled or not. When switched dynamically, selection
     *  is cleared. 
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
            if (!requiresSelection)
                _proposedSelectedIndices = [NO_SELECTION];
            else 
                _proposedSelectedIndices = [0];
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
        if (!allowMultipleSelection)
            return super.selectedIndex;
            
        //The case that selection has been set as a result of 
        //requiresSelection, we want to make sure the multiple selection
        //properties stay in sync. 
        if (!_selectedIndices && _selectedIndex >= 0)
        {
            _selectedIndices = [_selectedIndex]; 
            return _selectedIndex; 
        }
            
        if (_selectedIndices && _selectedIndices.length > 0)
            return _selectedIndices[_selectedIndices.length - 1];
            
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
        if (!allowMultipleSelection || !_selectedIndices)
            return super.selectedItem;
            
        if (_selectedIndices && _selectedIndices.length > 0)
            return dataProvider.getItemAt(_selectedIndices[_selectedIndices.length - 1]); 
            
        return undefined;
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
    override protected function itemInCaret(index:int, caret:Boolean):void
    {
        super.itemInCaret(index, caret);
        
        var renderer:Object = dataGroup ? dataGroup.getElementAt(index) : null;
        
        if (renderer is IItemRenderer)
        {
            IItemRenderer(renderer).caret = caret;
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
     */
    private function handleCaretChange(index:Number, focusIn:Boolean):void
    {
        var old:Number = currentCaretIndex; 
        var renderer:Object = dataGroup ? dataGroup.getElementAt(old) : null;
        if (renderer && renderer is IItemRenderer)
            renderer.caret = false;
            
        renderer = dataGroup? dataGroup.getElementAt(index) : null; 
        if (renderer && renderer is IItemRenderer)
        {
            renderer.caret = true;
            currentCaretIndex = index; 
        }
            
        var e:IndexChangedEvent = new IndexChangedEvent(IndexChangedEvent.ITEM_FOCUS_CHANGED); 
        e.oldIndex = old;
        e.newIndex = index; 
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
                        //we need to respect requiresSelection 
                        if (!requiresSelection)
                            return [NO_SELECTION];
                        else return [selectedIndices[0]]; 
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
                //Ctrl+click with no previously selected items 
                else 
                    return [index]; 
            }
            //A single item was newly selected, add that to the selection interval.  
            else 
                return [index];
        }
        
        else (shiftKey)
        {
            //A contiguous selection action has occurred. Figure out which new 
            //indices to add to the selection interval and return that. 
            var start:Number = (!isEmpty(selectedIndices)) ? selectedIndices[0] : 0; 
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
        	updateRenderer(IVisualElement(renderer));
        }
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
        var newIndex:Number; 
        if (selectUponNavigation)
        {
            if (!allowMultipleSelection)
            {
                //Single selection case 
                newIndex = dataGroup.getElementIndex(event.currentTarget as IVisualElement);  
                
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
        else
        {
            newIndex = dataGroup.getElementIndex(event.currentTarget as IVisualElement);
            handleCaretChange(newIndex, true); 
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
     *  Used by <code>keyDownHandler</code> to map the keyboard events
     *  to NavigationUnit. The NavigationUnit values are passed to the
     *  layout to figure out what the new item in focus is based on
     *  the current item in focus.
     * 
     *  Override to add custom event to NavigationUnit mapping. 
     *  
     *  @param event The user input event.
     *  @return Returns the NavigationUnit value that corresponds to the event.
     * 
     *  @see spark.core.NavigationUnit
     *  @see spark.layouts.LayoutBase#getDestinationIndex
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function mapEventToNavigationUnit(event:Event):uint
    {
        if (!(event is KeyboardEvent))
            return NavigationUnit.NONE; 

        switch (KeyboardEvent(event).keyCode)
        {
            case Keyboard.LEFT:         return NavigationUnit.LEFT;
            case Keyboard.RIGHT:        return NavigationUnit.RIGHT;
            case Keyboard.UP:           return NavigationUnit.UP;
            case Keyboard.DOWN:         return NavigationUnit.DOWN;
            case Keyboard.PAGE_UP:      return NavigationUnit.PAGE_UP;
            case Keyboard.PAGE_DOWN:    return NavigationUnit.PAGE_DOWN;
            case Keyboard.HOME:         return NavigationUnit.HOME;
            case Keyboard.END:          return NavigationUnit.END;
            default:                    return NavigationUnit.NONE;
        }
    }
    
    /**
     *  @private
     *  Build in basic keyboard navigation support in List. 
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {   
        super.keyDownHandler(event);

        var navigationUnit:uint = mapEventToNavigationUnit(event);    
        
        if (!dataProvider || !layout)
            return;

        var currentIndex:Number; 
        if (allowMultipleSelection && selectedIndices && selectedIndices.length > 0)
            currentIndex = selectedIndices[selectedIndices.length - 1]; 
        else
            currentIndex = selectedIndex;
            
        //Delegate to the layout to tell us what the next item is we should select or focus into.
	    // TODO (jszeto) At some point we should refactor this so we don't depend on layout
	    // for keyboard handling. If layout doesn't exist, then use some other keyboard handler
        var proposedNewIndex:int = (selectUponNavigation) ? layout.getDestinationIndex(navigationUnit, currentIndex)
            : layout.getDestinationIndex(navigationUnit, currentCaretIndex);   

        // Note that the KeyboardEvent is canceled even if the current selected or in focus index
        // doesn't change because we don't want another component to start handling these
        // events when the index reaches a limit.
        if (proposedNewIndex == -1)
            return;
        event.preventDefault(); 
        
        if (selectUponNavigation)
        {
            if (allowMultipleSelection && event.shiftKey && selectedIndices)
            {
                var newInterval:Array = []; 
                var i:int; 
                //contiguous multi-selection action - create the new selection
                //interval
                if (selectedIndex <= proposedNewIndex)
                {
                    for (i = selectedIndex; i <= proposedNewIndex; i++)
                    {
                        newInterval.push(i); 
                    }
                }
                else 
                {
                    for (i = selectedIndex; i >= proposedNewIndex; i--)
                    {
                        newInterval.push(i); 
                    }
                }
                selectedIndices = newInterval;   
                ensureItemIsVisible(proposedNewIndex); 
            }
            else
            {
                //simple new selection 
                selectedIndex = proposedNewIndex; 
                ensureItemIsVisible(proposedNewIndex);
            }
        }
        else
        {
            //Handle the focus change of the items so that the currentCaretIndex property
            //gets updated and the itemFocusChanged event dispatches. 
            if(event.ctrlKey)
            {
                handleCaretChange(proposedNewIndex, true);
                ensureItemIsVisible(proposedNewIndex); 
            }
        }
    }
  
}

}
