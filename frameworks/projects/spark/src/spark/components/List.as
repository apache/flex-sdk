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
import flash.events.Event;
import flash.geom.Point;
import flash.ui.Keyboard;

import mx.core.IVisualElement;
import mx.core.mx_internal; 
import mx.events.IndexChangedEvent;
import mx.managers.IFocusManagerComponent;

import spark.components.supportClasses.ListBase;
import spark.events.RendererExistenceEvent;
import spark.layouts.HorizontalLayout;
import spark.layouts.VerticalLayout;
import spark.core.NavigationUnit;

use namespace mx_internal;  //ListBase and List share selection properties that are mx_internal

/**
 *  @copy spark.components.supportClasses.GroupBase#style:alternatingItemColors
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:contentBackgroundColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:rollOverColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="rollOverColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:selectionColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="selectionColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:symbolColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark")]

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
        useVirtualLayout = true;
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
            return;     
        
        _allowMultipleSelection = value; 
    }
    
    /**
     *  @private
     *  Internal storage for the selectedIndices property and invalidation variables.
     */
    private var _selectedIndices:Array;
    private var _proposedSelectedIndices:Array = []; 
    private var multipleSelectionChanged:Boolean; 
    
    [Bindable("selectionChanged")]
    /**
     *  Selected indices for this component. If multiple selection 
     *  is off and this property is set, the first value in 
     *  the Array will be selected in order to honor single 
     *  selection.  
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
        return _selectedIndices;
    }
    
    /**
     *  @private
     */
    public function set selectedIndices(value:Array):void
    {
        if (_proposedSelectedIndices == value)
            return; 
        
        _proposedSelectedIndices = value;
        multipleSelectionChanged = true;  
        invalidateProperties();
    }
    
    [Bindable("selectionChanged")]
    /**
     *  Selected items for this component. If multiple selection 
     *  is off and this property is set, the first value in 
     *  the Array will be selected in order to honor single 
     *  selection.  
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
            {
                //TODO (dsubrama) What exactly should we do if an 
                //invalid item is in the selectedItems array? 
                var index:Number = dataProvider.getItemIndex(value[i]);
                if (index != -1)
                { 
                    indices[i] = index;  
                }
                if (index == -1)
                {
                    indices = [];
                    break;  
                }
            }
        }
        
        _proposedSelectedIndices = indices;
        multipleSelectionChanged = true;
        invalidateProperties(); 
    }

    /**
     *  A convenience that delegates to <code>layout.useVirtualLayout</code>.  
     *  If this list's layout is subsequently replaced and the value of this 
     *  property is true, then then the new layout's <code>useVirtualLayout</code> property 
     *  will also be true.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function get useVirtualLayout():Boolean
    {
        return super.useVirtualLayout;
    }

    /**
     *  @private
     *  The set/get overrides here only exist as a place to document the fact that
     *  the default for this inherited property is now true.  See the List constructor.
     */
    override public function set useVirtualLayout(value:Boolean):void
    {
        super.useVirtualLayout = value;
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
            commitSelection(); 
            multipleSelectionChanged = false; 
        }
    }
    
    /**
     *  @private
     *  Let ListBase handle single selection and afterwards come in and 
     *  handle multiple selection via the commitMultipleSelection() 
     *  helper method. 
     */
    override protected function commitSelection(dispatchSelectionChanged:Boolean = true):Boolean
    {
        var oldIndex:Number = _selectedIndex; 
        
        // Ensure that multiple selection is allowed and that proposed 
        // selected indices honors it. For example, in the single 
        // selection case, proposedSelectedIndices should only be an 
        // array of 1 entry. If its not, we pare it down and select the 
        // first item.  
        if (!allowMultipleSelection && !isEmpty(_proposedSelectedIndices))
            _proposedSelectedIndices = [_proposedSelectedIndices[0]];
        
        // Keep _proposedSelectedIndex in-sync with multiple selection properties. 
        if (!isEmpty(_proposedSelectedIndices))
           _proposedSelectedIndex = getLastItemValue(_proposedSelectedIndices); 
        
        // Let ListBase handle the validating and commiting of the single-selection
        // properties.  
        var retVal:Boolean = super.commitSelection(false); 
        
        // If super.commitSelection returns a value of false, 
        // the selection was cancelled, so return false and exit. 
        if (!retVal)
            return false; 
        
        // Now keep _proposedSelectedIndices in-sync with single selection 
        // properties now that the single selection properties have been 
        // comitted.  
        if (selectedIndex > NO_SELECTION)
        {
            if (_proposedSelectedIndices && _proposedSelectedIndices.indexOf(selectedIndex) == -1)
                _proposedSelectedIndices.push(selectedIndex);
        }
        
        // Validate and commit the multiple selection related properties. 
        commitMultipleSelection(); 
        
        // Finally, dispatch a selectionChanged event so that all of the bindings
        // update correctly. 
        if (dispatchSelectionChanged && retVal)
        {
            var e:IndexChangedEvent = new IndexChangedEvent(IndexChangedEvent.SELECTION_CHANGED);
            e.oldIndex = oldIndex;
            e.newIndex = _selectedIndex;
            dispatchEvent(e);
        }
        
        return retVal; 
    }
    
    /**
     *  @private
     *  Given a new selection interval, figure out which
     *  items are newly added/removed from the selection interval and update
     *  selection properties and view accordingly. 
     */
    protected function commitMultipleSelection():void
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
        if (_proposedSelectedIndices.length > 0)
        {
            count = _proposedSelectedIndices.length;
            for (i = 0; i < count; i++)
            {
                itemSelected(_proposedSelectedIndices[i], true);
            }
        }
        
        // Commit the selected indices and put _proposedSelectedIndices
        // back to its default value.  
        _selectedIndices = _proposedSelectedIndices;
        _proposedSelectedIndices = [];
        
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
    
    /**
     *  @private
     *  Called when an item has been added to this component.
     */
    override protected function itemAddedHandler(item:*, index:int):void
    {
        adjustSelectedIndices(index, true); 
    }
    
    /**
     *  @private
     *  Called when an item has been removed from this component.
     */
    override protected function itemRemovedHandler(item:*, index:int):void
    {
        adjustSelectedIndices(index, false);        
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Returns the index of the first selected item. In single 
     *  selection, this is just selectedIndex. In multiple 
     *  selection, this is the index of the first selected item.  
     */
    private function getFirstSelectedIndex():Number
    {
        if (selectedIndices && selectedIndices.length > 0)
            return selectedIndices[0]; 
        else 
            return 0; 
    }
    
    /**
     *  @private
     *  Given an Array, returns the value of the last item, 
     *  or -1 if there are no items in the Array; 
     */
    private function getLastItemValue(arr:Array):Number
    {
        if (arr && arr.length > 0)
            return arr[arr.length - 1]; 
        else 
            return -1; 
    }
    
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
     *  Handle the setting of the renderer's caret property and the 
     *  dispatching of focus events. 
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
                    // Quick check to see if selectedIndices had only one selected item
                    // and that item was de-selected
                    if (selectedIndices.length == 1 && (selectedIndices[0] == index))
                    {
                        // We need to respect requiresSelection 
                        if (!requiresSelection)
                            return [];
                        else 
                            return [selectedIndices[0]]; 
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
                            // Nothing from the selection model was de-selected. 
                            // Instead, the Ctrl key was held down and we're doing a  
                            // new add. 
                            interval.push(index);   
                        }
                        return interval; 
                    } 
                }
                // Ctrl+click with no previously selected items 
                else 
                    return [index]; 
            }
            // A single item was newly selected, add that to the selection interval.  
            else 
                return [index];
        }
        
        else (shiftKey)
        {
            // A contiguous selection action has occurred. Figure out which new 
            // indices to add to the selection interval and return that. 
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
        // TODO (jszeto) Clear the caret 
        var newIndex:Number; 
        if (!allowMultipleSelection)
        {
            // Single selection case 
            newIndex = dataGroup.getElementIndex(event.currentTarget as IVisualElement);  
            
            // Check to see if we're deselecting the currently selected item 
            if (event.ctrlKey && selectedIndex == newIndex)
                selectedIndex = NO_SELECTION;  
            // Otherwise, select the new item 
            else 
                selectedIndex = newIndex; 
        }
        else 
        {
            // Multiple selection is handled by the helper method below
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
     *  Adjusts the selected indices to account for items being added to or 
     *  removed from this component. 
     *   
     *  @param index The new index.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function adjustSelectedIndices(index:int, add:Boolean):void
    {
        var i:int; 
        var curr:Number; 
        var newInterval:Array = [];
        var e:IndexChangedEvent; 
        
        if (selectedIndex == NO_SELECTION || doingWholesaleChanges)
        {
            // The case where one item has been newly added and it needs to be 
            // selected because requiresSelection is true. 
            if (dataProvider && dataProvider.length == 1 && requiresSelection)
            {
                _selectedIndices = [0]; 
                _selectedIndex = 0; 
                // If the selection properties have been adjusted to account for items that
                // have been added or removed, send out a "selectionChanged" event so
                // any bindings to them are updated correctly.
                e = new IndexChangedEvent(IndexChangedEvent.SELECTION_CHANGED);
                e.oldIndex = -1;
                e.newIndex = _selectedIndex;
                dispatchEvent(e);
            }
            return; 
        }
        
        // Ensure multiple and single selection are in-sync before adjusting  
        // selection. Sometimes if selection has been changed before adding/removing
        // an item, we may not have handled selection via invalidation, so in those 
        // cases, force a call to commitSelection() to validate and commit the selection. 
        if ((!selectedIndices && selectedIndex > NO_SELECTION) ||
            (selectedIndex > NO_SELECTION && selectedIndices.indexOf(selectedIndex) == -1))
        {
            commitSelection(); 
        }
        
        // Handle the add or remove and adjust selection accordingly. 
        if (add)
        {
            for (i = 0; i < selectedIndices.length; i++)
            {
                curr = selectedIndices[i];
                 
                // Adding an item above one of the selected items,
                // bump the selected item up. 
                if (curr >= index)
                    newInterval.push(curr + 1); 
                else 
                    newInterval.push(curr); 
            }
        }
        else
        {
            // Quick check to see if we're removing the only selected item
            // in which case we need to honor requiresSelection. 
            if (!isEmpty(selectedIndices) && selectedIndices.length == 1 
                && index == selectedIndex && requiresSelection)
            {
                //Removing the last item 
                if (dataProvider.length == 0)
                {
                    newInterval = []; 
                }
                else if (index == 0)
                {
                    // We can't just set selectedIndex to 0 directly
                    // since the previous value was 0 and the new value is
                    // 0, so the setter will return early.
                    _proposedSelectedIndex = 0; 
                    invalidateProperties();
                    return;
                }    
                else
                {
                    newInterval = [0];
                }
            }
            else
            {    
                for (i = 0; i < selectedIndices.length; i++)
                {
                    curr = selectedIndices[i]; 
                    // Removing an item above one of the selected items,
                    // bump the selected item down. 
                    if (curr > index)
                        newInterval.push(curr - 1); 
                    else if (curr < index) 
                        newInterval.push(curr);
                }
            }
        }
        var oldIndices:Array = selectedIndices;  
        _selectedIndices = newInterval;
        _selectedIndex = getLastItemValue(newInterval);
        
        // If the selection has actually changed, trigger a pass to 
        // commitProperties where a selectionChanged event will be 
        // fired to update any bindings to selection properties. 
        if (_selectedIndices != oldIndices)
        {
            selectedIndexAdjusted = true; 
            invalidateProperties(); 
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
        
        if (!dataProvider || !layout || navigationUnit == NavigationUnit.NONE)
            return;

        var currentIndex:Number = selectedIndex; 
            
        // Delegate to the layout to tell us what the next item is we should select or focus into.
        // TODO (jszeto) At some point we should refactor this so we don't depend on layout
        // for keyboard handling. If layout doesn't exist, then use some other keyboard handler
        var proposedNewIndex:int = (selectUponNavigation) ? layout.getDestinationIndex(navigationUnit, currentIndex)
            : layout.getDestinationIndex(navigationUnit, currentCaretIndex);   
        
        // TODO (jszeto) proposedNewIndex depends on CTRL key
        // move CTRL key logic into single selection
        // add SPACE logic - add to selection for multi-select or change selection for single-select

        // Note that the KeyboardEvent is canceled even if the current selected or in focus index
        // doesn't change because we don't want another component to start handling these
        // events when the index reaches a limit.
        if (proposedNewIndex == -1)
            return;
        event.preventDefault(); 
        
        // Contiguous multi-selection action - create the new selection
        // interval. 
        if (allowMultipleSelection && event.shiftKey && selectedIndices)
        {
            var startIndex:Number = getFirstSelectedIndex(); 
            var newInterval:Array = []; 
            var i:int; 
            if (startIndex <= proposedNewIndex)
            {
                for (i = startIndex; i <= proposedNewIndex; i++)
                {
                    newInterval.push(i); 
                }
            }
            else 
            {
                for (i = startIndex; i >= proposedNewIndex; i--)
                {
                    newInterval.push(i); 
                }
            }
            selectedIndices = newInterval;   
            ensureItemIsVisible(proposedNewIndex); 
        }
        // Entering the caret state with the Ctrl key down 
        else if (event.ctrlKey)
        {
            // TODO (dsubrama) Finish up caret support, including visual 
            // indicators to default renderers. 
            handleCaretChange(proposedNewIndex, true);
            //ensureItemIsVisible(proposedNewIndex); 
        }
        // Its just a new selection action  
        else
        {
            selectedIndex = proposedNewIndex; 
            ensureItemIsVisible(proposedNewIndex);
        }
    }
  
}

}
