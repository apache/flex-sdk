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
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;

import mx.components.baseClasses.FxListBase;
import mx.core.ClassFactory;
import mx.core.IVisualElement;
import mx.events.RendererExistenceEvent;
import mx.layout.HorizontalLayout;
import mx.layout.VerticalLayout;
import mx.managers.IFocusManagerComponent;
import mx.skins.spark.FxDefaultItemRenderer;
import flash.geom.Point;

/**
 *  @copy mx.components.baseClasses.GroupBase#alternatingItemColors
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes")]

/**
 *  @copy mx.components.baseClasses.GroupBase#contentBackgroundColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes")]

/**
 *  @copy mx.components.baseClasses.GroupBase#rollOverColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]

/**
 *  @copy mx.components.baseClasses.GroupBase#selectionColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="selectionColor", type="uint", format="Color", inherit="yes")]

/**
 *  @copy mx.components.baseClasses.GroupBase#symbolColor
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

[IconFile("FxList.png")]
[DefaultTriggerEvent("selectionChanged")]

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
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class FxList extends FxListBase implements IFocusManagerComponent
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function FxList()
    {
        super();
        
        // This listener handles the arrow keys.   It runs at capture time 
        // so that can cancel - Event.preventDefault() - events we've processed
        // before they're seen by the skin's FxScroller
        addEventListener(KeyboardEvent.KEY_DOWN, list_keyDownHandler, true);
    }
    
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
    		
    	_allowMultipleSelection = true;
    }
    
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
     *  (<code>dataProvider.length</code> - 1). 
     *  If items at a lower index than <code>selectedIndex</code> are 
     *  removed from the component, the selected index is adjusted downward
     *  accordingly. </p>
     * 
     *  <p>When the value of the <code>allowMultipleSelection</code> property
     *  is <code>true</code>, the property is set to the first selected item.</p>
     *
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
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
    override protected function itemSelected(index:int, selected:Boolean):void
    {
        super.itemSelected(index, selected);
        
        var renderer:Object = dataGroup.getElementAt(index);
        
        if (renderer)
        {
            if ("selected" in renderer)
                renderer.selected = selected;
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
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
                itemSelected(removedItems[i], false);
            }
        }
        
        // select the new
        if (addedItems.length > 0)
        {
            count = addedItems.length;
            for (i = 0; i < count; i++)
            {
                itemSelected(addedItems[i], true);
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
    private function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void
    {
        var index:int = event.index;
        var renderer:Object = event.renderer;
        
        if (renderer)
            renderer.addEventListener("click", item_clickHandler);
            
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
            renderer.removeEventListener("click", item_clickHandler);
    }
    
    /**
     *  @private
     *  Called when an item is clicked.
     */
    private function item_clickHandler(event:MouseEvent):void
    {
        // Multiple selection needs to be added here....
        
        selectedIndex = dataGroup.getElementIndex(event.currentTarget as IVisualElement);
    }
    
    /**
     *  @private
     *  If the layout element at the specified index isn't completely 
     *  visible, scroll this IViewport.
     * 
     *  In the future, this method may animate the scroll.
     */
    private function ensureIndexIsVisible(index:int):void
    {
        if (!layout)
            return;

        var spDelta:Point = layout.getScrollPositionDelta(index);
        if (spDelta)
        { 
            horizontalScrollPosition += spDelta.x;
            verticalScrollPosition += spDelta.y;
        }
    }
    
    
    /**
     *  @private
     *  Build in basic keyboard navigation support in List. 
     *  TODO: Deepa - add overrideable methods to control 
     *  keyboard navigation across components and layout. 
     */
    private function list_keyDownHandler(event:KeyboardEvent):void
    {
        super.keyDownHandler(event);
        var delta:int = 0;

        if (layout is VerticalLayout)
            switch(event.keyCode)
            {
                case Keyboard.UP: delta = -1; break;
                case Keyboard.DOWN: delta = +1; break;
            }
        else if (layout is HorizontalLayout)
            switch(event.keyCode)
            {
                case Keyboard.LEFT: delta = -1; break;
                case Keyboard.RIGHT: delta = +1; break;
            }
        
        // Note that the KeyboardEvent is canceled even if the selectedIndex doesn't
        // change because we don't want another component to start handling these
        // events when the selectedIndex reaches a limit.
        if (delta != 0)
        {
            event.preventDefault();
            var maxSelectedIndex:int = dataProvider.length - 1;
            selectedIndex = Math.min(Math.max(0, selectedIndex + delta), maxSelectedIndex);
            ensureIndexIsVisible(selectedIndex);
        }
    }
  
}

}