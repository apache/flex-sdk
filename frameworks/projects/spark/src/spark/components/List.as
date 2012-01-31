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
import mx.managers.IFocusManagerComponent;

import spark.components.supportClasses.ListBase;
import spark.core.NavigationUnit;
import spark.events.IndexChangeEvent;
import spark.events.RendererExistenceEvent;
import spark.layouts.HorizontalLayout;
import spark.layouts.VerticalLayout;

use namespace mx_internal;  //ListBase and List share selection properties that are mx_internal

/**
 *  @copy spark.components.supportClasses.GroupBase#style:alternatingItemColors
 * 
 *  @default undefined
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  The alpha of the border for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderAlpha", type="Number", inherit="no", theme="spark")]

/**
 *  The color of the border for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderColor", type="uint", format="Color", inherit="no", theme="spark")]

/**
 *  Controls the visibility of the border for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderVisible", type="Boolean", inherit="no", theme="spark")]

/**
 *  The alpha of the content background for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="contentBackgroundAlpha", type="Number", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:contentBackgroundColor
 *   
 *  @default 0xFFFFFF
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
 *  @default 0xCEDBEF
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
 *  @default 0xA8C6EE
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
 *  @default 0x000000
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
[DefaultTriggerEvent("change")]

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
 *  @mxml <p>The <code>&lt;s:List&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:List
 *    <strong>Properties</strong>
 *    allowMultipleSelection="false"
 *    selectedIndices="null"
 *    selectedItems="null"
 *    useVirtualLayout="true"
 * 
 *    <strong>Styles</strong>
 *    alternatingItemColors="undefined"
 *    contentBackgroundColor="0xFFFFFF"
 *    rollOverColor="0xCEDBEF"
 *    selectionColor="0xA8C6EE"
 *    symbolColor="0x000000"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.skins.spark.ListSkin
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
    
    //----------------------------------
    //  allowMultipleSelection
    //----------------------------------
    
    private var _allowMultipleSelection:Boolean = false;
    
    /**
     *  If <code>true</code> multiple selections is enabled. 
     *  When switched at run time, the current selection
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
    private var _selectedIndices:Vector.<int>;
    private var _proposedSelectedIndices:Vector.<int> = new Vector.<int>(); 
    private var multipleSelectionChanged:Boolean; 
    
    [Bindable("change")]
    /**
     *  A Vector of ints representing the indices of the currently selected  
     *  item or items. If multiple selection is disabled by setting 
     *  <code>allowMultipleSelection</code> to <code>false</code>, and this property  
     *  is set, the data item corresponding to the first index in the Vector is selected.  
     *  
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectedIndices():Vector.<int>
    {
        return _selectedIndices;
    }
    
    /**
     *  @private
     */
    public function set selectedIndices(value:Vector.<int>):void
    {
        if (_proposedSelectedIndices == value)
            return; 
        
        _proposedSelectedIndices = value;
        multipleSelectionChanged = true;  
        invalidateProperties();
    }
    
    [Bindable("change")]
    /**
     *  An Vector of Objects representing the currently selected data items. 
     *  If multiple selection is disabled by setting <code>allowMultipleSelection</code>
     *  to <code>false</code>, and this property is set, the data item 
     *  corresponding to the first item in the Vector is selected.  
     * 
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectedItems():Vector.<Object>
    {
        var result:Vector.<Object>;
        
        if (selectedIndices)
        {
            result = new Vector.<Object>();
            
            var count:int = selectedIndices.length;
            
            for (var i:int = 0; i < count; i++)
                result[i] = dataProvider.getItemAt(selectedIndices[i]);  
        }
        
        return result;
    }
    
    /**
     *  @private
     */
    public function set selectedItems(value:Vector.<Object>):void
    {
        var indices:Vector.<int>;
        
        if (value)
        {
            indices = new Vector.<int>();
            
            var count:int = value.length;
            
            for (var i:int = 0; i < count; i++)
            {
                // FIXME (dsubrama): What exactly should we do if an 
                //invalid item is in the selectedItems vector? 
                var index:int = dataProvider.getItemIndex(value[i]);
                if (index != -1)
                { 
                    indices.splice(0, 0, index);   
                }
                if (index == -1)
                {
                    indices = new Vector.<int>();
                    break;  
                }
            }
        }
        
        _proposedSelectedIndices = indices;
        multipleSelectionChanged = true;
        invalidateProperties(); 
    }

    /**
     *  @inheritDoc
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
     *  Overrides the inherited default property , it is true for this class.
     * 
     *  Sets the value of the <code>useVirtualLayout</code> property
     *  of the layout associated with this control.  
     *  If the layout is subsequently replaced and the value of this 
     *  property is <code>true</code>, then the new layout's 
     *  <code>useVirtualLayout</code> property is set to <code>true</code>.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     */
    override public function set hasFocusableChildren(value:Boolean):void
    {
        super.hasFocusableChildren = value;
        if (scroller)
            scroller.hasFocusableChildren = value;
    }
    
    /**
     *  @private
     *  Let ListBase handle single selection and afterwards come in and 
     *  handle multiple selection via the commitMultipleSelection() 
     *  helper method. 
     */
    override protected function commitSelection(dispatchChangedEvents:Boolean = true):Boolean
    {
        var oldSelectedIndex:Number = _selectedIndex;
        var oldCaretIndex:Number = _caretIndex;  
        
        // Ensure that multiple selection is allowed and that proposed 
        // selected indices honors it. For example, in the single 
        // selection case, proposedSelectedIndices should only be a 
        // vector of 1 entry. If its not, we pare it down and select the 
        // first item.  
        if (!allowMultipleSelection && !isEmpty(_proposedSelectedIndices))
        {
            var temp:Vector.<int> = new Vector.<int>(); 
            temp.push(_proposedSelectedIndices[0]); 
            _proposedSelectedIndices = temp;  
        }
        // Keep _proposedSelectedIndex in-sync with multiple selection properties. 
        if (!isEmpty(_proposedSelectedIndices))
           _proposedSelectedIndex = getFirstItemValue(_proposedSelectedIndices); 
        
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
        
        // Set the caretIndex based on the current selection 
        setCurrentCaretIndex(selectedIndex);
        
        // And dispatch change and caretChange events so that all of 
        // the bindings update correctly. 
        if (dispatchChangedEvents && retVal)
        {
            var e:IndexChangeEvent = new IndexChangeEvent(IndexChangeEvent.CHANGE);
            e.oldIndex = oldSelectedIndex;
            e.newIndex = _selectedIndex;
            dispatchEvent(e);
            
            e = new IndexChangeEvent(IndexChangeEvent.CARET_CHANGE); 
            e.oldIndex = oldCaretIndex; 
            e.newIndex = caretIndex;
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
        var removedItems:Vector.<int> = new Vector.<int>();
        var addedItems:Vector.<int> = new Vector.<int>();
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
        if (!isEmpty(_proposedSelectedIndices))
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
        _proposedSelectedIndices = new Vector.<int>();
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
    override protected function itemShowingCaret(index:int, showsCaret:Boolean):void
    {
        super.itemShowingCaret(index, showsCaret); 
        
        var renderer:Object = dataGroup ? dataGroup.getElementAt(index) : null;
        
        if (renderer is IItemRenderer)
        {
            IItemRenderer(renderer).showsCaret = showsCaret;
        }
    }
    
    /**
     *  @private
     */
    override mx_internal function isItemIndexSelected(index:int):Boolean
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
        if (instance == scroller)
            scroller.hasFocusableChildren = hasFocusableChildren;
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
    override protected function itemAdded(index:int):void
    {
        adjustSelection(index, true); 
    }
    
    /**
     *  @private
     *  Called when an item has been removed from this component.
     */
    override protected function itemRemoved(index:int):void
    {
        adjustSelection(index, false);        
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Returns the index of the last selected item. In single 
     *  selection, this is just selectedIndex. In multiple 
     *  selection, this is the index of the first selected item.  
     */
    private function getLastSelectedIndex():int
    {
        if (selectedIndices && selectedIndices.length > 0)
            return selectedIndices[selectedIndices.length - 1]; 
        else 
            return 0; 
    }
    
    /**
     *  @private
     *  Given a Vector, returns the value of the first item, 
     *  or -1 if there are no items in the Vector; 
     */
    private function getFirstItemValue(v:Vector.<int>):int
    {
        if (v && v.length > 0)
            return v[0]; 
        else 
            return -1; 
    }
    
    /**
     *  @private
     *  Returns true if v is null or an empty Vector.
     */
    private function isEmpty(v:Vector.<int>):Boolean
    {
        return v == null || v.length == 0;
    }
    
    /**
     *  @private
     *  Taking into account which modifier keys were clicked, the new
     *  selectedIndices interval is calculated. 
     */
    private function calculateSelectedIndicesInterval(renderer:IVisualElement, shiftKey:Boolean, ctrlKey:Boolean):Vector.<int>
    {
        var i:int; 
        var interval:Vector.<int> = new Vector.<int>();  
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
                        // We need to respect requireSelection 
                        if (!requireSelection)
                            return interval; 
                        else 
                        {
                            interval.splice(0, 0, selectedIndices[0]); 
                            return interval; 
                    }
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
                                interval.splice(0, 0, _selectedIndices[i]);
                        }
                        if (!found)
                        {
                            // Nothing from the selection model was de-selected. 
                            // Instead, the Ctrl key was held down and we're doing a  
                            // new add. 
                            interval.splice(0, 0, index);   
                        }
                        return interval; 
                    } 
                }
                // Ctrl+click with no previously selected items 
                else
                { 
                    interval.splice(0, 0, index); 
                    return interval; 
            }
            }
            // A single item was newly selected, add that to the selection interval.  
            else 
            { 
                interval.splice(0, 0, index); 
                return interval; 
        }
        }
        else // shiftKey
        {
            // A contiguous selection action has occurred. Figure out which new 
            // indices to add to the selection interval and return that. 
            var start:int = (!isEmpty(selectedIndices)) ? selectedIndices[0] : 0; 
            var end:int = index; 
            if (start < end)
            {
                for (i = start; i <= end; i++)
                {
                    interval.splice(0, 0, i); 
                }
            }
            else 
            {
                for (i = start; i >= end; i--)
                {
                    interval.splice(0, 0, i); 
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
            renderer.addEventListener(MouseEvent.CLICK, item_clickHandler);
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
            renderer.removeEventListener(MouseEvent.CLICK, item_clickHandler);
        }
    }
    
    /**
     *  @private
     *  Called when an item is clicked.
     */
    protected function item_clickHandler(event:MouseEvent):void
    {
        var newIndex:Number; 
        
        if (!allowMultipleSelection)
        {
            // Single selection case, set the selectedIndex 
            newIndex = dataGroup.getElementIndex(event.currentTarget as IVisualElement);  
            
            var currentRenderer:IItemRenderer;
            if (caretIndex >= 0)
            {
                currentRenderer = dataGroup.getElementAt(caretIndex) as IItemRenderer;
                if (currentRenderer)
                    currentRenderer.showsCaret = false;
            }

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
     *  A convenience method that handles scrolling a data item
     *  into view. 
     * 
     *  If the data item at the specified index is not completely 
     *  visible, the List will scroll until it is brought into 
     *  view. If the data item is already in view, no additional
     *  scrolling will occur. 
     * 
     *  @param index The index of the data item.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function ensureIndexIsVisible(index:int):void
    {
        if (!layout)
            return;

        var spDelta:Point = dataGroup.layout.getScrollPositionDeltaToElement(index);
         
        if (spDelta)
        {
            dataGroup.horizontalScrollPosition += spDelta.x;
            dataGroup.verticalScrollPosition += spDelta.y;
        }
    }
    
    /**
     *  Adjusts the selected indices to account for items being added to or 
     *  removed from this component. 
     *   
     *  @param index The new index.
     *   
     *  @param add <code>true</code> if an item was added to the component, 
     *  and <code>false</code> if an item was removed.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function adjustSelection(index:int, add:Boolean=false):void
    {
        var i:int; 
        var curr:Number; 
        var newInterval:Vector.<int> = new Vector.<int>(); 
        var e:IndexChangeEvent; 
        
        if (selectedIndex == NO_SELECTION || doingWholesaleChanges)
        {
            // The case where one item has been newly added and it needs to be 
            // selected and careted because requireSelection is true. 
            if (dataProvider && dataProvider.length == 1 && requireSelection)
            {
                newInterval.push(0);
                _selectedIndices = newInterval;   
                _selectedIndex = 0; 
                itemShowingCaret(0, true); 
                // If the selection properties have been adjusted to account for items that
                // have been added or removed, send out a "change" event and 
                // "caretChange" event so any bindings to them are updated correctly.
                e = new IndexChangeEvent(IndexChangeEvent.CHANGE);
                e.oldIndex = -1;
                e.newIndex = _selectedIndex;
                dispatchEvent(e);
                
                e = new IndexChangeEvent(IndexChangeEvent.CARET_CHANGE); 
                e.oldIndex = -1; 
                e.newIndex = _caretIndex;
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
            // in which case we need to honor requireSelection. 
            if (!isEmpty(selectedIndices) && selectedIndices.length == 1 
                && index == selectedIndex && requireSelection)
            {
                //Removing the last item 
                if (dataProvider.length == 0)
                {
                    newInterval = new Vector.<int>(); 
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
                    newInterval.push(0);  
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
        
        if (caretIndex == selectedIndex)
        {
            // caretIndex is not changing, so we just need to dispatch
            // an "caretChange" event to update any bindings and update the 
            // caretIndex backing variable. 
            var oldIndex:Number = caretIndex; 
            _caretIndex = getFirstItemValue(newInterval);
            e = new IndexChangeEvent(IndexChangeEvent.CARET_CHANGE); 
            e.oldIndex = oldIndex; 
            e.newIndex = caretIndex; 
            dispatchEvent(e); 
        }
        else 
        {
            // De-caret the previous caretIndex renderer and set the 
            // caretIndexAdjusted flag to true. This will mean in 
            // commitProperties, the caretIndex will be adjusted to 
            // match the selectedIndex; 
            
            // FIXME (dsubrama): We should revisit the synchronous nature of the 
            // de-careting/re-careting behavior.
            itemShowingCaret(caretIndex, false); 
            caretIndexAdjusted = true; 
            invalidateProperties(); 
        }
        
        var oldIndices:Vector.<int> = selectedIndices;  
        _selectedIndices = newInterval;
        _selectedIndex = getFirstItemValue(newInterval);
        // If the selection has actually changed, trigger a pass to 
        // commitProperties where a change event will be 
        // fired to update any bindings to selection properties. 
        if (_selectedIndices != oldIndices)
        {
            selectedIndexAdjusted = true; 
            invalidateProperties(); 
        }
    }
    
    /**
     *  Tries to find the next item in the data provider that
     *  starts with the character in the <code>eventCode</code> parameter.
     *  You can override this to do fancier typeahead lookups. The search
     *  starts at the <code>selectedIndex</code> location; if it reaches
     *  the end of the data provider it starts over from the beginning.
     *
     *  @param eventCode The key that was pressed on the keyboard.
     *  @return <code>true</code> if a match was found.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function findKey(eventCode:int):Boolean
    {
        var tmpCode:int = eventCode;
        
        return tmpCode >= 33 &&
               tmpCode <= 126 &&
               findString(String.fromCharCode(tmpCode));
    }
    
    /**
     *  Finds an item in the list based on a String,
     *  and moves the selection to it. The search
     *  starts at the <code>selectedIndex</code> location; if it reaches
     *  the end of the data provider it starts over from the beginning.
     *
     *  @param str The String to match.
     * 
     *  @return <code>true</code> if a match is found.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function findString(str:String):Boolean
    {
        if (!dataProvider || dataProvider.length == 0)
            return false;

        var startIndex:int;
        var stopIndex:int;
        var retVal:Number;  

        if (selectedIndex == -1)
        {
            startIndex = 0;
            stopIndex = dataProvider.length; 
            retVal = findStringLoop(str, startIndex, stopIndex);
        }
        else
        {
            startIndex = selectedIndex + 1; 
            stopIndex = dataProvider.length; 
            retVal = findStringLoop(str, startIndex, stopIndex); 
            // We didn't find the item, loop back to the top 
            if (retVal == -1)
            {
                retVal = findStringLoop(str, 0, selectedIndex); 
            }
        }
        if (retVal != -1)
        {
            selectedIndex = retVal;
            ensureIndexIsVisible(retVal); 
            return true; 
        }
        else 
            return false; 
    }
    
    /**
     *  @private
     */
    private function findStringLoop(str:String, startIndex:int, stopIndex:int):Number
    {
        // Try to find the item based on the start and stop indices. 
        for (startIndex; startIndex != stopIndex; startIndex++)
        {
            var itmStr:String = itemToLabel(dataProvider.getItemAt(startIndex));

            itmStr = itmStr.substring(0, str.length);
            if (str == itmStr || str.toUpperCase() == itmStr.toUpperCase())
            {
               return startIndex;
            }
        }
        return -1;
    }
    
    /**
     *  @private
     *  Build in basic keyboard navigation support in List. 
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {   
        super.keyDownHandler(event);

        if (!dataProvider || !layout || event.isDefaultPrevented())
            return;
        
        // 1. Was the space bar hit? 
        // Hitting the space bar means the current caret item, 
        // that is the item currently in focus, is being 
        // selected. 
        if (event.keyCode == Keyboard.SPACE)
        {
            selectedIndex = caretIndex; 
            event.preventDefault();
            return; 
        }

        // 2. Or was an alphanumeric key hit? 
        // Hitting an alphanumeric key causes List's
        // findKey method to run to find a matching 
        // item in the dataProvider whose first char 
        // matches the keystroke. 
        if (findKey(event.charCode))
        {
            event.preventDefault();
            return;
        }
            
        // 3. Was a navigation key hit (like an arrow key,
        // or Shift+arrow key)?  
        // Delegate to the layout to interpret the navigation
        // key and adjust the selection and caret item based
        // on the combination of keystrokes encountered.      
        adjustSelectionAndCaretUponNavigation(event); 
    }
    
    /**
     *  Adjusts the selection based on what keystroke or 
     *  keystroke combinations were encountered. The keystroke
     *  is sent down to the layout and its up to the layout's
     *  getNavigationDestinationIndex() method to determine 
     *  what the index to navigate to based on the item that 
     *  is currently in focus. Once the index is determined, 
     *  single selection, caret item and if necessary, multiple 
     *  selection are fixed up to reflect the newly selected
     *  item.  
     *
     *  @param event The Keyboard Event encountered
     * 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function adjustSelectionAndCaretUponNavigation(event:KeyboardEvent):void
    {
        // Some unrecognized key stroke was entered, return. 
        var navigationUnit:uint = event.keyCode;    
        if (!NavigationUnit.isNavigationUnit(event.keyCode))
            return; 
            
        // Delegate to the layout to tell us what the next item is we should select or focus into.
        // FIXME (dsubrama): At some point we should refactor this so we don't depend on layout
        // for keyboard handling. If layout doesn't exist, then use some other keyboard handler
        var proposedNewIndex:int = layout.getNavigationDestinationIndex(caretIndex, navigationUnit, arrowKeysWrapFocus); 
        
        // FIXME (dsubrama): proposedNewIndex depends on CTRL key
        // move CTRL key logic into single selection
        // add SPACE logic - add to selection for multi-select or change selection for single-select

        // Note that the KeyboardEvent is canceled even if the current selected or in focus index
        // doesn't change because we don't want another component to start handling these
        // events when the index reaches a limit.
        if (proposedNewIndex == -1)
            return;
            
        event.preventDefault(); 
        
        // Contiguous multi-selection action. Create the new selection
        // interval.   
        if (allowMultipleSelection && event.shiftKey && selectedIndices)
        {
            var startIndex:Number = getLastSelectedIndex(); 
            var newInterval:Vector.<int> = new Vector.<int>();  
            var i:int; 
            if (startIndex <= proposedNewIndex)
            {
                for (i = startIndex; i <= proposedNewIndex; i++)
                {
                    newInterval.splice(0, 0, i); 
                }
            }
            else 
            {
                for (i = startIndex; i >= proposedNewIndex; i--)
                {
                    newInterval.splice(0, 0, i); 
                }
            }
            selectedIndices = newInterval;  
            ensureIndexIsVisible(proposedNewIndex); 
        }
        // Entering the caret state with the Ctrl key down 
        else if (event.ctrlKey)
        {
            var oldCaretIndex:Number = caretIndex; 
            setCurrentCaretIndex(proposedNewIndex);
            var e:IndexChangeEvent = new IndexChangeEvent(IndexChangeEvent.CARET_CHANGE); 
            e.oldIndex = oldCaretIndex; 
            e.newIndex = caretIndex; 
            dispatchEvent(e);    
            ensureIndexIsVisible(proposedNewIndex); 
        }
        // Its just a new selection action, select the new index.
        else
        {
            selectedIndex = proposedNewIndex;
            ensureIndexIsVisible(proposedNewIndex);
        }
    }
}

}
