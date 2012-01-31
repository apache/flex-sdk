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
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.components.baseClasses.FxListBase;
import mx.core.ClassFactory;
import mx.core.IFactory;
import mx.events.ItemExistenceChangedEvent;
import mx.layout.HorizontalLayout;
import mx.layout.VerticalLayout;
import mx.managers.IFocusManagerComponent;

[IconFile("FxButtonBar.png")]

/**
 *  The FxButtonBar control displays a set of Buttons 
 *
 *  @includeExample examples/FxButtonBarExample.mxml
 */
public class FxButtonBar extends FxListBase
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
    public function FxButtonBar()
    {
        super();
        itemRendererFunction = defaultButtonBarItemRendererFunction;
        
        //Add a keyDown event listener so we can adjust
        //selection accordingly.  
        addEventListener(KeyboardEvent.KEY_DOWN, buttonBar_keyDownHandler, true);

		// add a focusIn handler to move the focused button to the top layer
        addEventListener(FocusEvent.FOCUS_IN, buttonBar_focusInHandler);

    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  firstButton
    //---------------------------------- 
    
    [SkinPart(required="false", type="mx.components.FxButton")]
    /**
     * A skin part that defines the first button.
     */
    public var firstButton:IFactory;
    
    //----------------------------------
    //  lastButton
    //---------------------------------- 
    
    [SkinPart(required="false", type="mx.components.FxButton")]
    /**
     * A skin part that defines the last button.
     */
    public var lastButton:IFactory;

    //----------------------------------
    //  middleButton
    //---------------------------------- 
    
    [SkinPart(type="mx.components.FxButton")]
    /**
     * A skin part that defines the middle button(s).
     */
    public var middleButton:IFactory;

    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
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

    private function defaultButtonBarItemRendererFunction(data:Object):IFactory
	{
		var i:int = dataProvider.getItemIndex(data);
		if (i == 0)
			return firstButton ? firstButton : middleButton;

		var n:int = dataProvider.length - 1;
		if (i == n)
			return lastButton ? lastButton : middleButton;

		return middleButton;
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
        var item:Object = dataGroup.getRendererItem(DisplayObject(event.currentTarget));
		
		selectedItem = item;
    }
    
    /**
     *  @private
	 *  Attempt to lift the focused button above the others
	 *  so that the focus ring can show.
     */
    private function buttonBar_focusInHandler(event:FocusEvent):void
    {
		var currentButton:IFocusManagerComponent;
		var item:Object;
		var index:int;
		var renderer:Object;

		currentButton = focusManager.getFocus();
		item = dataGroup.getRendererItem(DisplayObject(currentButton));
		index = dataProvider.getItemIndex(item);

		var n:int = dataProvider.length;
		var zz:int = 0;
		for (var i:int = 0; i < n; i++)
		{
			renderer = dataGroup.getItemRenderer(dataProvider.getItemAt(i));
			if (renderer == currentButton)
				renderer.layer = n - 1;
			else
				renderer.layer = zz++;
		}
	}

    /**
     *  @private
     */
    private function buttonBar_keyDownHandler(event:KeyboardEvent):void
    {
		var currentButton:IFocusManagerComponent;
		var item:Object;
		var index:int;
		var renderer:Object;

        switch (event.keyCode)
        {
            case Keyboard.UP:
            case Keyboard.LEFT:
            {
				focusManager.showFocusIndicator = true;
				currentButton = focusManager.getFocus();
		        item = dataGroup.getRendererItem(DisplayObject(currentButton));
				index = dataProvider.getItemIndex(item);
				if (index > 0)
				{
					renderer = dataGroup.getItemRenderer(dataProvider.getItemAt(index - 1));
					IFocusManagerComponent(renderer).setFocus();
				}

                break;
            }
            case Keyboard.DOWN:
            case Keyboard.RIGHT:
            {
				focusManager.showFocusIndicator = true;
				currentButton = focusManager.getFocus();
		        item = dataGroup.getRendererItem(DisplayObject(currentButton));
				index = dataProvider.getItemIndex(item);
				if (index < dataProvider.length - 1)
				{
					renderer = dataGroup.getItemRenderer(dataProvider.getItemAt(index + 1));
					IFocusManagerComponent(renderer).setFocus();
				}

            }            
        }
    }
  
}

}

