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

import flex.events.FlexEvent;
import flex.events.ItemExistenceChangedEvent;

import mx.events.IndexChangedEvent;
	
/**
 *  Dispatched when the selection is going to change. Calling preventDefault()
 *  on the event will prevent the selection from changing.
 */
[Event(name="selectionChanging", type="mx.events.IndexChangedEvent")]

/**
 *  Dispatched after the selection has changed. 
 */
[Event(name="selectionChanged", type="mx.events.IndexChangedEvent")]

/**
 *  The Selector class is the base class for all components that support
 *  selection.
 */
public class Selector extends ItemsComponent
{
    include "../core/Version.as";

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
	public function Selector()
    {
    	addEventListener(FlexEvent.CONTENT_CHANGING, contentChangingHandler);
    	addEventListener(FlexEvent.CONTENT_CHANGED, contentChangedHandler);
		addEventListener(ItemExistenceChangedEvent.ITEM_ADD, itemAddedHandler);
		addEventListener(ItemExistenceChangedEvent.ITEM_REMOVE, itemRemovedHandler);
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
	
   /**
     *  The 0-based index of the selected item, or -1 if no item is selected.
     *  Setting the selectedIndex property de-selects the currently selected
     *  item and selects the item at the specified index.
     *
     *  The value of selectedIndex is always pinned between -1 and 
     *  (numItems - 1). If items at a lower index than selectedIndex are 
     *  removed from the component, the selected index is adjusted downward
     *  accordingly. If the selected item is removed, selected index is
     *  set to -1 (if requireSelection = false or there are no remaining items) 
     *  or 0 (if requireSelection = true and there is at least one item).
     *
     *  @default -1
     */
    [Bindable("selectionChanged")]
    public function get selectedIndex():int
    {
    	if (_proposedSelectedIndex != NO_PROPOSED_SELECTION)
    		return _proposedSelectedIndex;
    		
    	return _selectedIndex;
    }
    
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
    
   /**
     *  The item that is currently selected. Setting the selectedItem property
     *  de-selects the currently selected item and selects the specified item.
     *
     *  Setting selectedItem to an item that is not in this component results in
     *  no selection, and selectedItem being set to undefined. If the selected 
     *  item is removed, the selected item is set to undefined (if requireSelection
     *  = false or there are no remaining items) or the first item (if 
     *  requireSelection = true and there is at least one item).
     *
     *  @default undefined
     */
    [Bindable("selectionChanged")]
    public function get selectedItem():*
    {
        return getItemAt(selectedIndex);
    }
    
    public function set selectedItem(value:*):void
    {
        selectedIndex = getItemIndex(value);
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
    
    /**
     *  Specifies whether an item must always be selected.
     *  If the value is true, the selectedIndex property will always be
     *  set to a value between 0 and (numItems - 1), or -1 if there are
     *  no items.
     *
     *  @default false
     */
    [Bindable]
    public function get requiresSelection():Boolean
    {
        return _requiresSelection;
    }

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
            
        if (requiresSelectionChanged)
        {
            requiresSelectionChanged = false;
            
            if (requiresSelection &&
                    selectedIndex == NO_SELECTION &&
                    numItems > 0)
            {
            	// Set the proposed selected index here to make sure
            	// commitSelectedIndex() is called below.
                _proposedSelectedIndex = 0;
            }
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
	            var e:IndexChangedEvent = new IndexChangedEvent("selectionChanged");
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
     *  Called when an item is selected or de-selected. Subclasses must override
     *  this method to display the selection.
     */
    protected function itemSelected(item:Object, selected:Boolean):void
    {
        // Subclasses must override this method to display the selection.
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
        var maxIndex:int = numItems - 1;
        var oldIndex:int = _selectedIndex;
        
        if (_proposedSelectedIndex < NO_SELECTION)
            _proposedSelectedIndex = NO_SELECTION;
        if (_proposedSelectedIndex > maxIndex)
            _proposedSelectedIndex = maxIndex;
        if (requiresSelection && _proposedSelectedIndex == NO_SELECTION && numItems > 0)
            return false;
        
        // Step 2: dispatch the "selectionChanging" event. If preventDefault() is called
        // on this event, the selection change will be cancelled.
        var e:IndexChangedEvent = new IndexChangedEvent("selectionChanging", false, true);
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
        	itemSelected(getItemAt(_selectedIndex), false);
        if (_proposedSelectedIndex != NO_SELECTION)
        	itemSelected(getItemAt(_proposedSelectedIndex), true);
        _selectedIndex = _proposedSelectedIndex;
        _proposedSelectedIndex = NO_PROPOSED_SELECTION;
        
        // Step 4: dispatch the "selectionChanged" event
        e = new IndexChangedEvent("selectionChanged");
        e.oldIndex = oldIndex;
        e.newIndex = _selectedIndex;
        dispatchEvent(e);
        
        return true;
     }
    
    /**
     *  Adjusts the selected index to account for items being added to or 
     *  removed from this component. This method adjusts the selected index
     *  value and sends a "selectionChanged" event. It does NOT send
     *  "selectionChanging" or allow the cancellation of the selection. It
     *  also does not call itemSelected(), since the same item is selected -
     *  the only thing that has changed is the index of the item.
     * 
     *  A "selectionChanged" event is sent in the next call to 
     *  commitProperties(). The "selectionChanging" event is not sent when
     *  the selectedIndex is adjusted.
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
    protected function itemAddedHandler(event:ItemExistenceChangedEvent):void
    {
        if (selectedIndex == NO_SELECTION || doingWholesaleChanges)
            return;
               
        var itemIndex:int = getItemIndex(event.relatedObject);
        
        // If an item is added before the selected item, bump up our
        // selected index backing variable. 
        if (itemIndex <= selectedIndex)
            adjustSelectedIndex(selectedIndex + 1);
    }
    
    /**
     *  @private
     *  Called when an item has been removed from this component.
     */
    protected function itemRemovedHandler(event:ItemExistenceChangedEvent):void
    {
        if (selectedIndex == NO_SELECTION || doingWholesaleChanges)
            return;
            
        var itemIndex:int = getItemIndex(event.relatedObject);
        
        // If the selected item is being removed, clear the selection (or
        // reset to the first item if requiresSelection is true)
        if (itemIndex == selectedIndex)
        {
            if (requiresSelection && numItems > 0)
                selectedIndex = 0;
            else
                selectedIndex = -1;
        }
        else if (itemIndex < selectedIndex)
        {
            // An item below the selected index has been removed, bump
            // the selected index backing variable.
            adjustSelectedIndex(selectedIndex - 1);
        }
    }
    
    /**
     *  @private
     */
    private function contentChangingHandler(event:FlexEvent):void
    {
    	doingWholesaleChanges = true;
    }
    
    /**
     *  @private
     */
    private function contentChangedHandler(event:FlexEvent):void
    {
    	doingWholesaleChanges = false;
    	
    	if (selectedIndex >= 0 && selectedIndex < numItems)
    	   itemSelected(getItemAt(selectedIndex), true);
    	else
    	   selectedIndex = -1;
    }
}

}