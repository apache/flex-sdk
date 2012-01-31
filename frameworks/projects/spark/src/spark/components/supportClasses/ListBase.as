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

package mx.components.baseClasses
{
import flash.events.Event;

import mx.events.FlexEvent;
import mx.events.ItemExistenceChangedEvent;

import mx.collections.IList;
import mx.components.FxDataContainer;
import mx.core.IVisualElement;
import mx.events.IndexChangedEvent;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
    
/**
 *  Dispatched when the selection is going to change. 
 *  Calling the <code>preventDefault()</code> method
 *  on the event will prevent the selection from changing.
 *
 *  @eventType mx.events.IndexChangedEvent.SELECTION_CHANGING
 */
[Event(name="selectionChanging", type="mx.events.IndexChangedEvent")]

/**
 *  Dispatched after the selection has changed. 
 *
 *  @eventType mx.events.IndexChangedEvent.SELECTION_CHANGED
 */
[Event(name="selectionChanged", type="mx.events.IndexChangedEvent")]

/**
 *  The FxListBase class is the base class for all components that support
 *  selection.
 */
public class FxListBase extends FxDataContainer
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     *  Constant representing the value "no selection".
     */
    protected static const NO_SELECTION:int = -1;
    
    /**
     *  @private
     *  Constant representing no proposed selection.
     */
    protected static const NO_PROPOSED_SELECTION:int = -2;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     */
    public function FxListBase()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private var doingWholesaleChanges:Boolean = false;
    
    //----------------------------------
    //  dataProvider
    //----------------------------------
    
    private var dataProviderChanged:Boolean;
    
    /**
     *  @inheritDoc
     */
    override public function set dataProvider(value:IList):void
    {
        if (dataProvider)
            dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler);
    
        dataProviderChanged = true;
        doingWholesaleChanges = true;
        
        super.dataProvider = value;
        
        if (dataProvider)
            dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler);
    }
    
    //----------------------------------
    //  selectedIndex
    //----------------------------------

    /**
     *  @private
     *  The proposed selected index. This is a temporary variable that is
     *  used until the selected index is committed.
     */
    private var _proposedSelectedIndex:int = NO_PROPOSED_SELECTION;
    
    /** 
     *  @private
     *  Flag that is set when the selectedIndex has been adjusted due to
     *  items being added or removed. When this flag is true, the value
     *  of the selectedIndex has changed, but the actual selected item
     *  is the same. This flag is cleared in commitProperties().
     */
    private var selectedIndexAdjusted:Boolean = false;
    
    /**
     *  @private
     *  Internal storage for the selectedIndex property.
     */
    private var _selectedIndex:int = NO_SELECTION;
    
    [Bindable("selectionChanged")]
    /**
     *  The 0-based index of the selected item, or -1 if no item is selected.
     *  Setting the <code>selectedIndex</code> property deselects the currently selected
     *  item and selects the item at the specified index.
     *
     *  <p>The value is always between -1 and (<code>dataProvider.length</code> - 1). 
     *  If items at a lower index than <code>selectedIndex</code> are 
     *  removed from the component, the selected index is adjusted downward
     *  accordingly.</p>
     *
     *  <p>If the selected item is removed, the selected index is set to:</p>
     *
     *  <ul>
     *    <li>-1 if <code>requireSelection</code> = <code>false</code> 
     *     or there are no remaining items.</li>
     *    <li>0 if <code>requireSelection</code> = <code>true</code> 
     *     and there is at least one item.</li>
     *  </ul>
     *
     *  @default -1
     */
    public function get selectedIndex():int
    {
        if (_proposedSelectedIndex != NO_PROPOSED_SELECTION)
            return _proposedSelectedIndex;
            
        return _selectedIndex;
    }
    
    /**
     *  @private
     */
    public function set selectedIndex(value:int):void
    {
        if (value == selectedIndex)
            return;
            
        _proposedSelectedIndex = value;
        invalidateProperties();
    }

    //----------------------------------
    //  selectedItem
    //----------------------------------
    
    private var _pendingSelectedItem:*;
    
    [Bindable("selectionChanged")]
    /**
     *  The item that is currently selected. 
     *  Setting this property
     *  deselects the currently selected item and selects the specified item.
     *
     *  <p>Setting <code>selectedItem</code> to an item that is not 
     *  in this component results in no selection, 
     *  and <code>selectedItem</code> being set to <code>undefined</code>.</p>
     * 
     *  <p>If the selected item is removed, the selected item is set to:</p>
     *
     *  <ul>
     *    <li><code>undefined</code> if <code>requireSelection</code> = <code>false</code> 
     *      or there are no remaining items.</li>
     *    <li>The first item if <code>requireSelection</code> = <code>true</code> 
     *      and there is at least one item.</li>
     *  </ul>
     *
     *  @default undefined
     */
    public function get selectedItem():*
    {
        if (_pendingSelectedItem != undefined)
            return _pendingSelectedItem;
            
        if (selectedIndex == NO_SELECTION || dataProvider == null)
           return undefined;
           
        return dataProvider.getItemAt(selectedIndex);
    }
    
    /**
     *  @private
     */
    public function set selectedItem(value:*):void
    {
        if (selectedItem == value)
            return;
        
        _pendingSelectedItem = value;
        invalidateProperties();
    }

    //----------------------------------
    //  requiresSelection
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the requiresSelection property.
     */
    private var _requiresSelection:Boolean = false;
    
    /**
     *  @private
     *  Flag that is set when requiresSelection has changed.
     */
    private var requiresSelectionChanged:Boolean = false;
    
    [Bindable]
    /**
     *  Specifies whether an item must always be selected.
     *  If the value is <code>true</code>, the <code>selectedIndex</code> property 
     *  is always set to a value between 0 and (<code>dataProvider.length</code> - 1), 
     *  or -1 if there are no items.
     *
     *  @default false
     */
    public function get requiresSelection():Boolean
    {
        return _requiresSelection;
    }

    /**
     *  @private
     */
    public function set requiresSelection(value:Boolean):void
    {
        if (value == _requiresSelection)
            return;
            
        _requiresSelection = value;
        
        // We only need to update if the value is changing 
        // from false to true
        if (value == true)
        {
            requiresSelectionChanged = true;
            invalidateProperties();
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  baselinePosition
    //----------------------------------

    /**
     *  @private
     *  The baseline position of a ListBase is calculated for the first item renderer.
     *  If there are no items, one is temporarily added to do the calculation.
     */
    override public function get baselinePosition():Number
    {
        if (!mx_internal::validateBaselinePosition())
            return NaN;
        
        // Fabricate temporary data provider if necessary.
        var isNull:Boolean = dataProvider == null;
        var isEmpty:Boolean = dataProvider != null && dataProvider.length == 0;
         
        if (isNull || isEmpty)
        {
            var originalProvider:IList = isEmpty ? dataProvider : null;
            dataProvider = new mx.collections.ArrayList([ new Object() ]);
            validateNow();
        }
        
        if (!dataGroup || dataGroup.numLayoutElements == 0)
            return super.baselinePosition;
        
        // Obtain reference to newly generated item element which will be used
        // to compute the baseline.
        var listItem:Object = dataGroup.getItemRenderer(0);
        if (!listItem)
            return super.baselinePosition;
        
        // Compute baseline position of item relative to our list component.
        if ("baselinePosition" in listItem)
            var result:Number = getSkinPartPosition(IVisualElement(listItem)).y + listItem.baselinePosition;
        else    
            super.baselinePosition;

        // Restore the previous state of our list.
        if (isNull || isEmpty)
        {
            if (isNull)
                dataProvider = null;
            else if (isEmpty)
                dataProvider = originalProvider;
                
            validateNow();
        }
        
        return result;
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
        var changedSelection:Boolean = false;
        
        super.commitProperties();
        
        if (dataProviderChanged)
        {
            dataProviderChanged = false;
            doingWholesaleChanges = false;
        
            // TODO: should resetting the dataProvider clear out all of its state?
            // or should we preserve selectedIndex
            if (selectedIndex >= 0 && dataProvider && selectedIndex < dataProvider.length)
               itemSelected(selectedIndex, true);
            else
               selectedIndex = -1;
        }
            
        if (requiresSelectionChanged)
        {
            requiresSelectionChanged = false;
            
            if (requiresSelection &&
                    selectedIndex == NO_SELECTION &&
                    dataProvider &&
                    dataProvider.length > 0)
            {
                // Set the proposed selected index here to make sure
                // commitSelectedIndex() is called below.
                _proposedSelectedIndex = 0;
            }
        }
        
        if (_pendingSelectedItem !== undefined)
        {
            if (dataProvider)
                _proposedSelectedIndex = dataProvider.getItemIndex(_pendingSelectedItem);
            _pendingSelectedItem = undefined;
        }
        
        if (_proposedSelectedIndex != NO_PROPOSED_SELECTION)
            changedSelection = commitSelectedIndex();
        
        // If the selectedIndex has been adjusted to account for items that
        // have been added or removed, send out a "selectionChanged" event so
        // any bindings to selectedIndex are updated correctly.
        if (selectedIndexAdjusted)
        {
            selectedIndexAdjusted = false;
            if (!changedSelection)
            {
                var e:IndexChangedEvent = new IndexChangedEvent(IndexChangedEvent.SELECTION_CHANGED);
                e.oldIndex = selectedIndex;
                e.newIndex = selectedIndex;
                dispatchEvent(e);
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Called when an item is selected or deselected. 
     *  Subclasses must override this method to display the selection.
     *
     *  @param index The item index that was selected.
     *
     *  @param selected <code>true</code> if the item is selected, 
     *  and <code>false</code> if it is deselected.
     */
    protected function itemSelected(index:int, selected:Boolean):void
    {
        // Subclasses must override this method to display the selection.
    }
    
    /**
     *  Returns true if the item is selected by calling 
     *  <code>isItemIndexSelected()</code>.
     * 
     *  <p>If multiple instances of the item are in the list, 
     *  this will only check to see whether the item at  
     *  <code>dataProvider.getItemIndex()</code> (usually the first 
     *  instance of that item) is selected.</p>
     * 
     *  @param item The item whose selection status is being checked
     *
     *  @return true if the item is selected, false otherwise.
     */
    public function isItemSelected(item:Object):Boolean
    {
        var index:int = dataProvider.getItemIndex(item);
        
        return isItemIndexSelected(index);
    }
        
    /**
     *  Returns true if the item at the index is selected.
     * 
     *  @param index The index of the item whose selection status is being checked
     *
     *  @return true if the item at that index is selected, false otherwise.
     */
    public function isItemIndexSelected(index:int):Boolean
    {        
        return index == selectedIndex;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Called to commit the pending selected index. This method dispatches
     *  the "selectionChanging" event, and if the event is not cancelled,
     *  commits the selection change and then dispatches the "selectionChanged"
     *  event.
     * 
     *  Returns true if the selection was committed, or false if the selection
     *  was cancelled.
     */
    private function commitSelectedIndex():Boolean
    {
        // Step 1: make sure the proposed selected index is in range.
        var maxIndex:int = dataProvider ? dataProvider.length - 1 : -1;
        var oldIndex:int = _selectedIndex;
        
        if (_proposedSelectedIndex < NO_SELECTION)
            _proposedSelectedIndex = NO_SELECTION;
        if (_proposedSelectedIndex > maxIndex)
            _proposedSelectedIndex = maxIndex;
        if (requiresSelection && _proposedSelectedIndex == NO_SELECTION && 
            dataProvider && dataProvider.length > 0)
            return false;
        
        // Step 2: dispatch the "selectionChanging" event. If preventDefault() is called
        // on this event, the selection change will be cancelled.
        var e:IndexChangedEvent = new IndexChangedEvent(IndexChangedEvent.SELECTION_CHANGING, false, true);
        e.oldIndex = _selectedIndex;
        e.newIndex = _proposedSelectedIndex;
        if (!dispatchEvent(e))
        {
            // The event was cancelled. Cancel the selection change and return.
            _proposedSelectedIndex = NO_PROPOSED_SELECTION;
            return false;
        }
        
        // Step 3: commit the selection change
        if (_selectedIndex != NO_SELECTION)
            itemSelected(_selectedIndex, false);
        if (_proposedSelectedIndex != NO_SELECTION)
            itemSelected(_proposedSelectedIndex, true);
        _selectedIndex = _proposedSelectedIndex;
        _proposedSelectedIndex = NO_PROPOSED_SELECTION;
        
        // Step 4: dispatch the "selectionChanged" event
        e = new IndexChangedEvent(IndexChangedEvent.SELECTION_CHANGED);
        e.oldIndex = oldIndex;
        e.newIndex = _selectedIndex;
        dispatchEvent(e);
        
        return true;
     }
    
    /**
     *  Adjusts the selected index to account for items being added to or 
     *  removed from this component. This method adjusts the selected index
     *  value and dispatches a <code>selectionChanged</code> event. 
     *  It does not dispatch a <code>selectionChanging</code> event 
     *  or allow the cancellation of the selection. 
     *  It also does not call the <code>itemSelected()</code> method, 
     *  since the same item is selected; 
     *  the only thing that has changed is the index of the item.
     * 
     *  <p>A <code>selectionChanged</code> event is dispatched in the next call to 
     *  the <code>commitProperties()</code> method.</p>
     *
     *  <p>The <code>selectionChanging</code> event is not sent when
     *  the <code>selectedIndex</code> is adjusted.</p>
     *
     *  @param newIndex The new index.
     */
    protected function adjustSelectedIndex(newIndex:int):void
    {
        if (_proposedSelectedIndex != NO_PROPOSED_SELECTION)
            _proposedSelectedIndex = newIndex;
        else
            _selectedIndex = newIndex;
        selectedIndexAdjusted = true;
        invalidateProperties();
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
    protected function itemAddedHandler(item:*, index:int):void
    {
        if (selectedIndex == NO_SELECTION || doingWholesaleChanges)
            return;
        
        // If an item is added before the selected item, bump up our
        // selected index backing variable. 
        if (index <= selectedIndex)
            adjustSelectedIndex(selectedIndex + 1);
    }
    
    /**
     *  @private
     *  Called when an item has been removed from this component.
     */
    protected function itemRemovedHandler(item:*, index:int):void
    {
        if (selectedIndex == NO_SELECTION || doingWholesaleChanges)
            return;
        
        // If the selected item is being removed, clear the selection (or
        // reset to the first item if requiresSelection is true)
        if (index == selectedIndex)
        {
            if (requiresSelection && dataProvider && dataProvider.length > 0)
            {    	
            	if (index == 0)
            	{
            		//We can't just set selectedIndex to 0 directly
            		//since the previous value was 0 and the new value is
            		//0, so the setter will return early.  
            		_proposedSelectedIndex = 0;
            		invalidateProperties();
            	}
            	else 
            		selectedIndex = 0;
            }
            else
            	adjustSelectedIndex(-1);
        }
        else if (index < selectedIndex)
        {
            // An item below the selected index has been removed, bump
            // the selected index backing variable.
            adjustSelectedIndex(selectedIndex - 1);
        }
    }
    
    /**
     *  @private
     */
    protected function collectionChangeHandler(event:Event):void
    {
        if (event is CollectionEvent)
        {
            var ce:CollectionEvent = CollectionEvent(event);

            if (ce.kind == CollectionEventKind.ADD)
            {
                itemAddedHandler(ce.items[0], ce.location);
            }
            else if (ce.kind == CollectionEventKind.REPLACE)
            {
                
            }
            else if (ce.kind == CollectionEventKind.REMOVE)
            {
                itemRemovedHandler(ce.items[0], ce.location);
            }
            else if (ce.kind == CollectionEventKind.MOVE)
            {
                
            }
            else if (ce.kind == CollectionEventKind.REFRESH)
            {
                
            }
            else if (ce.kind == CollectionEventKind.RESET)
            {
                // Data provider is being reset, clear out the selection
                _selectedIndex = -1;
            }
            else if (ce.kind == CollectionEventKind.UPDATE)
            {
                
            }
        }
            
    }
}

}
