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
import flash.events.IEventDispatcher;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.components.baseClasses.FxListBase;
import mx.core.IFactory;
import mx.core.ISelectableRenderer;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.events.RendererExistenceEvent;
import mx.managers.IFocusManagerComponent;

[IconFile("FxButtonBar.png")]

/**
 *  The FxButtonBar control displays a set of Buttons 
 *
 *  @includeExample examples/FxButtonBarExample.mxml
 */
public class FxButtonBar extends FxListBase implements IFocusManagerComponent
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
        addEventListener(KeyboardEvent.KEY_DOWN, buttonBar_keyDownHandler);

		tabChildren = false;
		tabEnabled = true;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Index of currently focused child.
     */
    private var focusedIndex:int = 0;

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
    
    [SkinPart(required="true", type="mx.components.FxButton")]
    
    /**
     * A skin part that defines the middle button(s).
     */
    public var middleButton:IFactory;

    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------

	private var requiresSelectionChanging:Boolean;

    /**
     *  @private
     */
    override public function set requiresSelection(value:Boolean):void
	{
		super.requiresSelection = value;
		requiresSelectionChanging = true;
	}

	private var enabledChanging:Boolean;

    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
	{
		super.enabled = value;
		enabledChanging = true;
	}

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
		super.commitProperties();

        if (requiresSelectionChanging && dataProvider)
		{
			requiresSelectionChanging = false;
			var n:int = dataProvider.length;
			for (var i:int = 0; i < n; i++)
			{
				var renderer:ISelectableRenderer = 
					dataGroup.getElementAt(i) as ISelectableRenderer;
				if (renderer)
					renderer.allowDeselection = !requiresSelection;
			}
		}
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(w:Number, h:Number):void
    {
		super.updateDisplayList(w, h);

        if (enabledChanging)
		{
			enabledChanging = false;
			if (dataProvider)
			{
				var n:int = dataProvider.length;
				for (var i:int = 0; i < n; i++)
				{
					var renderer:ISelectableRenderer = 
						dataGroup.getElementAt(i) as ISelectableRenderer;
					if (renderer)
						renderer.enabled = enabled;
				}
			}
		}
    }

    /**
     *  @private
     */
    override public function drawFocus(isFocused:Boolean):void
    {
		adjustLayering(focusedIndex);
        drawButtonFocus(focusedIndex, isFocused);
    }

    /**
     *  @private
     */
    override protected function itemSelected(index:int, selected:Boolean):void
    {
        super.itemSelected(index, selected);
        
        var renderer:ISelectableRenderer = 
			dataGroup.getElementAt(index) as ISelectableRenderer;
        
        if (renderer)
        {
			focusedIndex = index;
            renderer.selected = selected;
        }
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
                RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler);
            dataGroup.addEventListener(
                RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererRemoveHandler);
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
    private function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void
    {
        var renderer:IEventDispatcher = IEventDispatcher(event.renderer);
        var index:int = event.index;
        
        if (renderer)
		{
            renderer.addEventListener("click", item_clickHandler);
			if (renderer is IFocusManagerComponent)
				IFocusManagerComponent(renderer).focusEnabled = false;
			if (renderer is ISelectableRenderer)
			{
				ISelectableRenderer(renderer).allowDeselection = !requiresSelection;
				ISelectableRenderer(renderer).enabled = enabled;
			}
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
        var index:int = dataGroup.getElementIndex(
                            event.currentTarget as IVisualElement);

		if (index == selectedIndex)
		{
			if (!requiresSelection)
				selectedIndex = -1;
		}
		else
		{
			focusedIndex = selectedIndex = index;
		}
    }
    
    /**
     *  @private
	 *  Attempt to lift the focused button above the others
	 *  so that the focus ring can show.
     */
    private function adjustLayering(focusedIndex:int):void
    {
		var n:int = dataProvider.length;
		for (var i:int = 0; i < n; i++)
		{
			var renderer:IVisualElement = IVisualElement(dataGroup.getElementAt(i));
			if (i == focusedIndex)
				renderer.layer = 1;
			else
				renderer.layer = 0;
		}
	}

    /**
     *  @private
     */
    private function buttonBar_keyDownHandler(event:KeyboardEvent):void
    {
		var currentRenderer:ISelectableRenderer;
		var renderer:ISelectableRenderer;

        switch (event.keyCode)
        {
            case Keyboard.UP:
            case Keyboard.LEFT:
            {
				currentRenderer = dataGroup.getElementAt(focusedIndex) as ISelectableRenderer;
				if (focusedIndex > 0)
				{
					if (currentRenderer)
						currentRenderer.showFocusIndicator = false;
					--focusedIndex;
					adjustLayering(focusedIndex);
					renderer = dataGroup.getElementAt(focusedIndex) as ISelectableRenderer;
					if (renderer)
						renderer.showFocusIndicator = true;
				}

                break;
            }
            case Keyboard.DOWN:
            case Keyboard.RIGHT:
            {
				currentRenderer = dataGroup.getElementAt(focusedIndex) as ISelectableRenderer;
				if (focusedIndex < dataProvider.length - 1)
				{
					if (currentRenderer)
						currentRenderer.showFocusIndicator = false;
					++focusedIndex;
					adjustLayering(focusedIndex);
					renderer = dataGroup.getElementAt(focusedIndex) as ISelectableRenderer;
					if (renderer)
						renderer.showFocusIndicator = true;
				}

                break;
            }            
            case Keyboard.SPACE:
            {
				currentRenderer = dataGroup.getElementAt(focusedIndex) as ISelectableRenderer;
				if (!currentRenderer || (currentRenderer.selected && requiresSelection))
					return;
				currentRenderer.selected = !currentRenderer.selected;
				if (currentRenderer.selected)
					selectedIndex = focusedIndex;
				else
					selectedIndex = -1;
                break;
            }            
        }
    }
  
    /**
     *  @private
     */
    private function drawButtonFocus(index:int, focused:Boolean):void
    {
		var n:int = dataProvider.length;
        if (n > 0 && index < n)
        {
			var renderer:ISelectableRenderer = 
				dataGroup.getElementAt(index) as ISelectableRenderer;
			if (renderer)
				renderer.showFocusIndicator = focused;
        }
    }
}

}

