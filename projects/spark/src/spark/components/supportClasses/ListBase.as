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

package spark.components.supportClasses
{
import flash.events.Event;

import mx.collections.IList;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.FlexEvent;

import spark.components.IItemRenderer;
import spark.components.IItemRendererOwner;
import spark.components.SkinnableDataContainer;
import spark.events.IndexChangeEvent;
import spark.events.RendererExistenceEvent;
import spark.layouts.supportClasses.LayoutBase;
import spark.utils.LabelUtil;

use namespace mx_internal;  //ListBase and List share selection properties that are mx_internal

/**
 *  Dispatched when the selection is going to change. 
 *  Calling the <code>preventDefault()</code> method
 *  on the event prevents the selection from changing.
 *
 *  @eventType spark.events.IndexChangeEvent.CHANGING
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="changing", type="spark.events.IndexChangeEvent")]

/**
 *  Dispatched after the selection has changed. 
 *
 *  @eventType spark.events.IndexChangeEvent.CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="change", type="spark.events.IndexChangeEvent")]

/**
 *  Dispatched after the focus has changed.  
 *
 *  @eventType spark.events.IndexChangeEvent.CARET_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="caretChange", type="spark.events.IndexChangeEvent")]

/**
 *  The ListBase class is the base class for all components that support
 *  selection. 
 *
 *  @mxml <p>The <code>&lt;s:ListBase&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:ListBase
 *
 *    <strong>Properties</strong>
 *    arrowKeysWrapFocus="false"
 *    dataProvider="null"
 *    labelField="label"
 *    labelFunction="null"
 *    requireSelection="false"
 *    selectedIndex="-1"
 *    selectedItem="undefined"
 *    useVirtualLayout="false"
 * 
 *    <strong>Events</strong>
 *    caretChange="<i>No default</i>"
 *    change="<i>No default</i>"
 *    changing="<i>No default</i>"
 *  /&gt;
 *  </pre>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ListBase extends SkinnableDataContainer 
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Static constant representing the value "no selection".
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const NO_SELECTION:int = -1;
    
    /**
     *  @private
     *  Static constant representing no proposed selection.
     */
    mx_internal static const NO_PROPOSED_SELECTION:int = -2;
    
    /**
     *  @private
     *  Static constant representing no item in focus. 
     */
    private static const NO_CARET:int = -1;
    
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
    public function ListBase()
    {
        super();
    }
    
    mx_internal var allowCustomSelectedItem:Boolean = false;
    mx_internal static var CUSTOM_SELECTED_ITEM:int = -3;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  arrowKeysWrapFocus
    //---------------------------------- 
    
    /**
     *  If <code>true</code>, using arrow keys to navigate within
     *  the component wraps when it hits either end.
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var arrowKeysWrapFocus:Boolean;

    //----------------------------------
    //  CaretIndex
    //----------------------------------
    
    mx_internal var _caretIndex:Number = NO_CARET; 
    
    [Bindable("caretChange")]
    /**
     *  Item that is currently in focus. 
     *
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get caretIndex():Number
    {
        return _caretIndex;
    }
    
    /**
     *  @private
     */
    mx_internal var doingWholesaleChanges:Boolean = false;
    
    //----------------------------------
    //  dataProvider
    //----------------------------------
    private var dataProviderChanged:Boolean;
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function set dataProvider(value:IList):void
    {
        if (dataProvider)
            dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler);
    
        dataProviderChanged = true;
        doingWholesaleChanges = true;
        
        // ensure that our listener is added before the dataGroup which adds a listener during
        // the base class setter if the dataGroup already exists.  If the dataGroup isn't
        // created yet, then we still be first.
        if (value)
            value.addEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler);

        super.dataProvider = value;
        invalidateProperties();
    }
    
    //----------------------------------
    //  labelField
    //----------------------------------
    private var labelFieldOrFunctionChanged:Boolean; 
    private var _labelField:String = "label";
    
    /**
     *  The name of the field in the data provider items to display 
     *  as the label. 
     *  The <code>labelFunction</code> property overrides this property.
     *
     *  @default "label" 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get labelField():String
    {
        return _labelField;
    }
    
    /**
     *  @private
     */
    public function set labelField(value:String):void
    {
        if (value == _labelField)
            return 
            
        _labelField = value;
        labelFieldOrFunctionChanged = true;
        invalidateProperties();
    }
    
    //----------------------------------
    //  labelFunction
    //----------------------------------
    
    private var _labelFunction:Function; 
    
    /**
     *  A user-supplied function to run on each item to determine its label.  
     *  The <code>labelFunction</code> property overrides 
     *  the <code>labelField</code> property.
     *
     *  <p>You can supply a <code>labelFunction</code> that finds the 
     *  appropriate fields and returns a displayable string. The 
     *  <code>labelFunction</code> is also good for handling formatting and 
     *  localization. </p>
     *
     *  <p>The label function takes a single argument which is the item in 
     *  the data provider and returns a String.</p>
     *  <pre>
     *  myLabelFunction(item:Object):String</pre>
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get labelFunction():Function
    {
        return _labelFunction;
    }
    
    /**
     *  @private
     */
    public function set labelFunction(value:Function):void
    {
        if (value == _labelFunction)
            return 
            
        _labelFunction = value;
        labelFieldOrFunctionChanged = true;
        invalidateProperties(); 
    }
    
    //----------------------------------
    //  selectedIndex
    //----------------------------------

    /**
     *  @private
     *  The proposed selected index. This is a temporary variable that is
     *  used until the selected index is committed.
     */
    mx_internal var _proposedSelectedIndex:int = NO_PROPOSED_SELECTION;
    
    /** 
     *  @private
     *  Flag that is set when the selectedIndex has been adjusted due to
     *  items being added or removed. When this flag is true, the value
     *  of the selectedIndex has changed, but the actual selected item
     *  is the same. This flag is cleared in commitProperties().
     */
    mx_internal var selectedIndexAdjusted:Boolean = false;
    
    /** 
     *  @private
     *  Flag that is set when the caretIndex has been adjusted due to
     *  items being added or removed. This flag is cleared in 
     *  commitProperties().
     */
    mx_internal var caretIndexAdjusted:Boolean = false;
    
    /**
     *  @private
     *  Internal storage for the selectedIndex property.
     */
    mx_internal var _selectedIndex:int = NO_SELECTION;
    
    [Bindable("change")]
    /**
     *  The 0-based index of the selected item, or -1 if no item is selected.
     *  Setting the <code>selectedIndex</code> property deselects the currently selected
     *  item and selects the data item at the specified index.
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    
    mx_internal var _pendingSelectedItem:*;
    private var _selectedItem:*;
    
    [Bindable("change")]
    /**
     *  The item that is currently selected. 
     *  Setting this property deselects the currently selected 
     *  item and selects the newly specified item.
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectedItem():*
    {
        if (_pendingSelectedItem !== undefined)
            return _pendingSelectedItem;
            
        if (allowCustomSelectedItem && selectedIndex == CUSTOM_SELECTED_ITEM)
            return _selectedItem;
        
        if (selectedIndex == NO_SELECTION || dataProvider == null)
           return undefined;
           
        return dataProvider.length > selectedIndex ? dataProvider.getItemAt(selectedIndex) : undefined;
    }
    
    /**
     *  @private
     */
    public function set selectedItem(value:*):void
    {
        if (selectedItem === value)
            return;
        
        _pendingSelectedItem = value;
        invalidateProperties();
    }

    //----------------------------------
    //  requireSelection
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the requireSelection property.
     */
    private var _requireSelection:Boolean = false;
    
    /**
     *  @private
     *  Flag that is set when requireSelection has changed.
     */
    private var requireSelectionChanged:Boolean = false;

    /**
     *  If <code>true</code>, a data item must always be selected in the control.
     *  If the value is <code>true</code>, the <code>selectedIndex</code> property 
     *  is always set to a value between 0 and (<code>dataProvider.length</code> - 1), 
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get requireSelection():Boolean
    {
        return _requireSelection;
    }

    /**
     *  @private
     */
    public function set requireSelection(value:Boolean):void
    {
        if (value == _requireSelection)
            return;
            
        _requireSelection = value;
        
        // We only need to update if the value is changing 
        // from false to true
        if (value == true)
        {
            requireSelectionChanged = true;
            invalidateProperties();
        }
    }
    
    //----------------------------------
    //  useVirtualLayout
    //----------------------------------

    /**
     *  @private
     */
    private var _useVirtualLayout:Boolean = false;
    
    /**
     *  Sets the value of the <code>useVirtualLayout</code> property
     *  of the layout associated with this control.  
     *  If the layout is subsequently replaced and the value of this 
     *  property is <code>true</code>, then the new layout's 
     *  <code>useVirtualLayout</code> property is set to <code>true</code>.
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get useVirtualLayout():Boolean
    {
        return (layout) ? layout.useVirtualLayout : _useVirtualLayout;
    }

    /**
     *  @private
     *  Note: this property deviates a little from the conventional delegation pattern.
     *  If the user explicitly sets ListBase.useVirtualLayout=false and then sets
     *  the layout property to a layout with useVirtualLayout=true, the layout's value
     *  for this property trumps the ListBase.  The convention dictates opposite
     *  however in this case, always honoring the layout's useVirtalLayout property seems 
     *  less likely to cause confusion.
     */
    public function set useVirtualLayout(value:Boolean):void
    {
        if (value == useVirtualLayout)
            return;
            
        _useVirtualLayout = value;
        if (layout)
            layout.useVirtualLayout = value;
    }
    
    /**
     *  @private
     */
    override public function set layout(value:LayoutBase):void
    {
        if (useVirtualLayout)
            value.useVirtualLayout = true;
        super.layout = value;
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
        if (!validateBaselinePosition())
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
        
        if (!dataGroup || dataGroup.numElements == 0)
            return super.baselinePosition;
        
        // Obtain reference to newly generated item element which will be used
        // to compute the baseline.
        var listItem:Object = dataGroup ? dataGroup.getElementAt(0) : undefined;
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
        var e:IndexChangeEvent; 
        var changedSelection:Boolean = false;
        
        super.commitProperties();
        
        if (dataProviderChanged)
        {
            dataProviderChanged = false;
            doingWholesaleChanges = false;
        
            // FIXME (dsubrama): should resetting the dataProvider clear out all of its state?
            // or should we preserve selectedIndex
            if (selectedIndex >= 0 && dataProvider && selectedIndex < dataProvider.length)
               itemSelected(selectedIndex, true);
            else if (requireSelection)
               _proposedSelectedIndex = 0;
            else
               selectedIndex = -1;
        }
            
        if (requireSelectionChanged)
        {
            requireSelectionChanged = false;
            
            if (requireSelection &&
                    selectedIndex == NO_SELECTION &&
                    dataProvider &&
                    dataProvider.length > 0)
            {
                // Set the proposed selected index here to make sure
                // commitSelection() is called below.
                _proposedSelectedIndex = 0;
            }
        }
        
        if (_pendingSelectedItem !== undefined)
        {
            if (dataProvider)
                _proposedSelectedIndex = dataProvider.getItemIndex(_pendingSelectedItem);
            
            if (allowCustomSelectedItem && _proposedSelectedIndex == -1)
            {
				_proposedSelectedIndex = CUSTOM_SELECTED_ITEM;
                _selectedItem = _pendingSelectedItem;
            }
              
            _pendingSelectedItem = undefined;
        }
        
        if (_proposedSelectedIndex != NO_PROPOSED_SELECTION)
            changedSelection = commitSelection();
        
        // If the selectedIndex has been adjusted to account for items that
        // have been added or removed, send out a "change" event 
        // so any bindings to selectedIndex are updated correctly.
        if (selectedIndexAdjusted)
        {
            selectedIndexAdjusted = false;
            if (!changedSelection)
            {
                e = new IndexChangeEvent(IndexChangeEvent.CHANGE);
                e.oldIndex = selectedIndex;
                e.newIndex = selectedIndex;
                dispatchEvent(e);
            }
        }
        
        if (caretIndexAdjusted)
        {
            caretIndexAdjusted = false;
            if (!changedSelection)
            {
                // Put the new caretIndex renderer into the
                // caret state and dispatch an "caretChange" 
                // event to update any bindings. Additionally, update 
                // the backing variable. 
                itemShowingCaret(selectedIndex, true); 
                _caretIndex = selectedIndex; 
                
                e = new IndexChangeEvent(IndexChangeEvent.CARET_CHANGE); 
                e.oldIndex = caretIndex; 
                e.newIndex = caretIndex;
                dispatchEvent(e);  
            }
        }
        
        if (labelFieldOrFunctionChanged)
        {
            //Cycle through all instantiated renderers
            if (dataGroup)
            {
                for (var i:int = 0; i < dataGroup.numChildren; i++)
                {
                    // FIXME (rfrishbe):(dsubrama) Ryan, figure out numChildren/numElement vs. getElement/getChild
                    //and which is more performant.
                    var renderer:IItemRenderer = dataGroup.getElementAt(i) as IItemRenderer; 
                    //Push the correct text into the renderer by settings its label
                    //property 
                    if (renderer)
                    {
                        renderer.label = itemToLabel(renderer.data); 
                    }
                }
            }

            labelFieldOrFunctionChanged = false; 
        }
    }
    
    /**
     *  @private
     */
    override public function updateRenderer(renderer:IVisualElement):void
    {
        var transitions:Array;
         
        // First clean up any old, stale properties like selected and caret   
        if (renderer is IItemRenderer)
        {
            // If there are transitions bound to the renderer, lets turn them 
            // off while we clear stale properties by setting ItemRenderer's 
            // mx_internal property, playTransitions, to false
            if (renderer is ItemRenderer)
                ItemRenderer(renderer).playTransitions = false; 
            
            // FIXME (dsubrama): - Go through helper methods to do this. 
            // Make itemSelected()/itemShowingCaret() pass around the renderer 
            // instead of index
            IItemRenderer(renderer).selected = false;
            IItemRenderer(renderer).showsCaret = false;
            
            // Now turn the transitions back on by setting playTransitions
            // back to true 
            if (renderer is ItemRenderer)
                ItemRenderer(renderer).playTransitions = true;  
        }    
        
        // Now run through and initialize the renderer correctly
        super.updateRenderer(renderer); 
          
        var index:Number = dataGroup.getElementIndex(renderer);
        
        // Set any new properties on the renderer now that it's going to 
        // come back into use. 
        if (isItemIndexSelected(index))
            itemSelected(index, true);
    }
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        if (instance == dataGroup)
        {
            // Not your typical delegation, see 'set useVirtualLayout'
            if (_useVirtualLayout && dataGroup.layout)
                dataGroup.layout.useVirtualLayout = true;
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Given a data item, return the correct text a renderer
     *  should display while taking the <code>labelField</code> 
     *  and <code>labelFunction</code> properties into account. 
     *
     *  @param item A data item 
     *  
     *  @return String representing the text to display for the 
     *  data item in the  renderer. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function itemToLabel(item:Object):String
    {
        return LabelUtil.itemToLabel(item, labelField, labelFunction);
    }
    
    /**
     *  Called when an item is selected or deselected. 
     *  Subclasses must override this method to display the selection.
     *
     *  @param index The item index that was selected.
     *
     *  @param selected <code>true</code> if the item is selected, 
     *  and <code>false</code> if it is deselected.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function itemSelected(index:int, selected:Boolean):void
    {
        // Subclasses must override this method to display the selection.
    }
    
    /**
     *  Called when an item is in its caret state or not. 
     *  Subclasses must override this method to display the caret. 
     *
     *  @param index The item index that was put into caret state. 
     *
     *  @param showsCaret <code>true</code> if the item is in the caret state,  
     *  and <code>false</code> if it is not.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function itemShowingCaret(index:int, showsCaret:Boolean):void
    {
        // Subclasses must override this method to display the caret.
    }
    
    /**
     *  Returns <code>true</code> if the item at the index is selected.
     * 
     *  @param index The index of the item whose selection status is being checked
     *
     *  @return <code>true</code> if the item at that index is selected, 
     *  and <code>false</code> otherwise.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    mx_internal function isItemIndexSelected(index:int):Boolean
    {        
        return index == selectedIndex;
    }
    
    /**
     *  Returns true if the item at the index is the caret item, which is
     *  essentially the item in focus. 
     * 
     *  @param index The index of the item whose caret status is being checked
     *
     *  @return true if the item at that index is the caret item, false otherwise.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    mx_internal function isItemIndexShowingCaret(index:int):Boolean
    {        
        return index == caretIndex;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Set current caret index. This function takes the item that was
     *  previously the caret item and sets its caret property to false,
     *  then takes the current proposed caret item and sets its 
     *  caret property to true as well as updating the backing variable. 
     * 
     */
    mx_internal function setCurrentCaretIndex(value:Number):void
    {
        itemShowingCaret(caretIndex, false); 
        
        _caretIndex = value;
        
		if (caretIndex != CUSTOM_SELECTED_ITEM)
        	itemShowingCaret(caretIndex, true);
    }
    
    /**
     *  @private
     *  The selection validation and commitment workhorse method. 
     *  Called to commit the pending selected index. This method dispatches
     *  the "changing" event, and if the event is not cancelled,
     *  commits the selection change and then dispatches the "change"
     *  event.
     * 
     *  Returns true if the selection was committed, or false if the selection
     *  was cancelled.
     */
    protected function commitSelection(dispatchChangedEvents:Boolean = true):Boolean
    {
        // Step 1: make sure the proposed selected index is in range.
        var maxIndex:int = dataProvider ? dataProvider.length - 1 : -1;
        var oldSelectedIndex:int = _selectedIndex;
        var oldCaretIndex:int = _caretIndex;
        
        if (!allowCustomSelectedItem || _proposedSelectedIndex != CUSTOM_SELECTED_ITEM)
        {
            if (_proposedSelectedIndex < NO_SELECTION)
                _proposedSelectedIndex = NO_SELECTION;
            if (_proposedSelectedIndex > maxIndex)
                _proposedSelectedIndex = maxIndex;
            if (requireSelection && _proposedSelectedIndex == NO_SELECTION && 
                dataProvider && dataProvider.length > 0)
            {
                _proposedSelectedIndex = NO_PROPOSED_SELECTION;
                return false;
            }
        }
        
        // Step 2: dispatch the "changing" event. If preventDefault() is called
        // on this event, the selection change will be cancelled.
        var e:IndexChangeEvent = new IndexChangeEvent(IndexChangeEvent.CHANGING, false, true);
        e.oldIndex = _selectedIndex;
        e.newIndex = _proposedSelectedIndex;
        if (!dispatchEvent(e))
        {
            // The event was cancelled. Cancel the selection change and return.
            _proposedSelectedIndex = NO_PROPOSED_SELECTION;
            return false;
        }
        
        // Step 3: commit the selection change and caret change 
        if (_selectedIndex != NO_SELECTION)
            itemSelected(_selectedIndex, false);
        if (_proposedSelectedIndex != NO_SELECTION && _proposedSelectedIndex != CUSTOM_SELECTED_ITEM)
            itemSelected(_proposedSelectedIndex, true);
        _selectedIndex = _proposedSelectedIndex;
        setCurrentCaretIndex(_proposedSelectedIndex); 
        _proposedSelectedIndex = NO_PROPOSED_SELECTION;
        
        // Step 4: dispatch the "change" event and "caretChange" 
        // events based on the dispatchChangeEvents parameter. Overrides may  
        // chose to dispatch the change/caretChange events 
        // themselves, in which case we wouldn't want to dispatch the event 
        // here. 
        if (dispatchChangedEvents)
        {
            // Dispatch the change event
            e = new IndexChangeEvent(IndexChangeEvent.CHANGE);
            e.oldIndex = oldSelectedIndex;
            e.newIndex = _selectedIndex;
            dispatchEvent(e);
            
            //Dispatch the caretChange event 
            e = new IndexChangeEvent(IndexChangeEvent.CARET_CHANGE); 
            e.oldIndex = oldCaretIndex; 
            e.newIndex = caretIndex; 
            dispatchEvent(e);  
        }
        
        return true;
     }
    
    /**
     *  Adjusts the selected index to account for items being added to or 
     *  removed from this component. This method adjusts the selected index
     *  value and dispatches a <code>change</code> event. 
     *  It does not dispatch a <code>changing</code> event 
     *  or allow the cancellation of the selection. 
     *  It also does not call the <code>itemSelected()</code> method, 
     *  since the same item is selected; 
     *  the only thing that has changed is the index of the item.
     * 
     *  <p>A <code>change</code> event is dispatched in the next call to 
     *  the <code>commitProperties()</code> method.</p>
     *
     *  <p>The <code>changing</code> event is not sent when
     *  the <code>selectedIndex</code> is adjusted.</p>
     *
     *  @param newIndex The new index.
     *   
     *  @param add <code>true</code> if an item was added to the component, 
     *  and <code>false</code> if an item was removed.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function adjustSelection(newIndex:int, add:Boolean=false):void
    {
        if (_proposedSelectedIndex != NO_PROPOSED_SELECTION)
            _proposedSelectedIndex = newIndex;
        else
            _selectedIndex = newIndex;
        selectedIndexAdjusted = true;
        invalidateProperties();
    }
    
    /**
     *  Called when an item has been added to this component. Selection
     *  and caret related properties are adjusted accordingly. 
     * 
     *  @param index The index of the item being added. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function itemAdded(index:int):void
    {
        if (selectedIndex == NO_SELECTION || doingWholesaleChanges)
            return;
            
        // If an item is added before the selected item, bump up our
        // selected index backing variable. 
        if (index <= selectedIndex)
            adjustSelection(selectedIndex + 1);
    }
    
    /**
     *  Called when an item has been removed from this component.
     *  Selection and caret related properties are adjusted 
     *  accordingly. 
     * 
     *  @param index The index of the item being removed. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function itemRemoved(index:int):void
    {
        if (selectedIndex == NO_SELECTION || doingWholesaleChanges)
            return;
        
        // If the selected item is being removed, clear the selection (or
        // reset to the first item if requireSelection is true)
        if (index == selectedIndex)
        {
            if (requireSelection && dataProvider && dataProvider.length > 0)
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
                adjustSelection(-1);
        }
        else if (index < selectedIndex)
        {
            // An item below the selected index has been removed, bump
            // the selected index backing variable.
            adjustSelection(selectedIndex - 1);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Called when contents within the dataProvider changes.  
     *
     *  @param event The collection change event
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function dataProvider_collectionChangeHandler(event:Event):void
    {
        if (event is CollectionEvent)
        {
            var ce:CollectionEvent = CollectionEvent(event);

            if (ce.kind == CollectionEventKind.ADD)
            {
                itemAdded(ce.location);
            }
            else if (ce.kind == CollectionEventKind.REMOVE)
            {
                itemRemoved(ce.location);
            }
            else if (ce.kind == CollectionEventKind.RESET)
            {
                // Data provider is being reset, clear out the selection
                if (dataProvider.length == 0)
                {
                    selectedIndex = NO_SELECTION;
                    setCurrentCaretIndex(NO_CARET);
                }
                else
                {
                    dataProviderChanged = true; 
                    invalidateProperties(); 
                }
            }
            else if (ce.kind == CollectionEventKind.REPLACE ||
                ce.kind == CollectionEventKind.MOVE ||
                ce.kind == CollectionEventKind.REFRESH)
            {
                //These cases are handled by the DataGroup skinpart  
            }
        }
            
    }
    
}

}
