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

import flex.core.Group;
import flex.core.SkinnableComponent;
import flex.events.FlexEvent;
import flex.events.ItemExistenceChangedEvent;

import mx.core.IFactory;
import mx.managers.IFocusManagerContainer;

/**
 *  Dispatched prior to the component's content being changed. This is only
 *  dispatched when all content of the component is changing.
 */
[Event(name="contentChanging", type="flex.events.FlexEvent")]

/**
 *  Dispatched after the component's content has changed. This is only
 *  dispatched when all content of the component has changed.
 */
[Event(name="contentChanged", type="flex.events.FlexEvent")]

/**
 *  Dispatched when an item is added to the component.
 *  event.relatedObject is the visual item that was added.
 */
[Event(name="itemAdd", type="flex.events.ItemExistenceChangedEvent")]

/**
 *  Dispatched when an item is removed from the component.
 *  event.relatedObject is the visual item that was removed.
 */
[Event(name="itemRemove", type="flex.events.ItemExistenceChangedEvent")]

[DefaultProperty("content")]

/**
 * The ItemsComponent class is the base class for all skinnable components that have 
 * content. This class is not typically instantiated in MXML. It is primarily
 * used as a base class, or as a SkinPart.
 */
public class ItemsComponent extends SkinnableComponent implements IFocusManagerContainer
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */
	public function ItemsComponent()
	{
		super();
		
		tabChildren = true;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Skin Parts
	//
	//--------------------------------------------------------------------------
	
	[SkinPart]
	public var contentGroup:Group;

	//--------------------------------------------------------------------------
	//
	//  Properties proxied to contentHolder
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  content
	//----------------------------------
	
	private var _content:*;
	
	/**
	 *  @copy flex.core.Group#content
	 */
	[Bindable]
	public function get content():*
	{
		if (contentGroup)
			return contentGroup.content;
		
		return _content;
	}
	
	public function set content(value:*):void
	{
		if (value == _content)
			return;
			
		_content = value;
		
		if (contentGroup)
			contentGroup.content = _content;
	}
	
	//----------------------------------
	//  layout
	//----------------------------------
	
	private var _layout:Class;
	
	/**
	 *  @copy flex.core.Group#layout
	 */
	public function get layout():Class
	{
		if (contentGroup)
			return contentGroup.layout;
		
		return _layout;
	}
	
	public function set layout(value:Class):void
	{
		if (value == _layout)
			return;
			
		_layout = value;
		
		if (contentGroup)
			contentGroup.layout = _layout;
	}
	
	//----------------------------------
	//  itemRenderer
	//----------------------------------
	
	private var _itemRenderer:IFactory;
	
	/**
	 *  @copy flex.core.Group#itemRenderer
	 */
	public function get itemRenderer():IFactory
	{
		if (contentGroup)
			return contentGroup.itemRenderer;
		
		return _itemRenderer;
	}
	
	public function set itemRenderer(value:IFactory):void
	{
		if (value == _itemRenderer)
			return;
			
		_itemRenderer = value;
		
		if (contentGroup)
			contentGroup.itemRenderer = _itemRenderer;
	}
	
	//----------------------------------
	//  itemRendererFunction
	//----------------------------------
	
	private var _itemRendererFunction:Function;
	
	/**
	 *  @copy flex.core.Group#itemRendererFunction
	 */
	public function get itemRendererFunction():Function
	{
		if (contentGroup)
			return contentGroup.itemRendererFunction;
		
		return _itemRendererFunction;
	}
	
	public function set itemRendererFunction(value:Function):void
	{
		if (value == _itemRendererFunction)
			return;
		
		_itemRendererFunction = value;
		
		if (contentGroup)
			contentGroup.itemRendererFunction = _itemRendererFunction;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods proxied to contentGroup
	//
	//--------------------------------------------------------------------------

	/**
	 *  @copy flex.core.Group#numItems
	 */
	public function get numItems():int
	{
		if (!contentGroup)
			return 0;
		
		return contentGroup.numItems;
	}
	
	/**
	 *  @copy flex.core.Group#getItemAt()
	 */
	public function getItemAt(index:int):*
	{
		if (!contentGroup)
			return null;
		
		return contentGroup.getItemAt(index);
	}
	
	/**
	 *  @copy flex.core.Group#addItem()
	 */
	public function addItem(item:*):*
	{
		if (!contentGroup)
			return null;
		
		return contentGroup.addItem(item);
	}
	
	/**
	 *  @copy flex.core.Group#addItemAt()
	 */
	public function addItemAt(item:*, index:int):*
	{
		if (!contentGroup)
			return null;
		
		return contentGroup.addItemAt(item, index);
	}
	
	/**
	 *  @copy flex.core.Group#removeItem()
	 */
	public function removeItem(item:*):*
	{
		if (!contentGroup)
			return null;
		
		return contentGroup.removeItem(item);
	}
	
	/**
	 *  @copy flex.core.Group#removeItemAt()
	 */
	public function removeItemAt(index:int):*
	{
		if (!contentGroup)
			return null;
		
		return contentGroup.removeItemAt(index);
	}
	
	/**
	 *  @copy flex.core.Group#getItemIndex()
	 */
	public function getItemIndex(item:*):int
	{
		if (!contentGroup)
			return -1;
		
		return contentGroup.getItemIndex(item);
	}
	
	/**
	 *  @copy flex.core.Group#setItemIndex()
	 */
	public function setItemIndex(item:*, index:int):void
	{
		if (!contentGroup)
			return;
		
		contentGroup.setItemIndex(item, index);
	}
	
	/**
	 *  @copy flex.core.Group#swapItems()
	 */
	public function swapItems(item1:*, item2:*):void
	{
		if (!contentGroup)
			return;
		
		contentGroup.swapItems(item1, item2);
	}
	
	/**
	 *  @copy flex.core.Group#swapItemsAt()
	 */
	public function swapItemsAt(index1:*, index2:*):void
	{
		if (!contentGroup)
			return;
		
		contentGroup.swapItemsAt(index1, index2);
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  Called when a skin part has been added or assigned. 
	 *  This method pushes the content, layout, itemRenderer, and
	 *  itemRendererFunction properties down to the contentGroup
	 *  skin part.
	 */
	override protected function partAdded(partName:String, instance:*):void
	{
		if (instance == contentGroup)
		{
			if (_content != undefined)
				contentGroup.content = _content;
			if (_layout != null)
				contentGroup.layout = _layout;
			if (_itemRenderer != null || _itemRendererFunction != null)
			{
				contentGroup.itemRenderer = _itemRenderer;
				contentGroup.itemRendererFunction = _itemRendererFunction;
			}
			
			contentGroup.addEventListener(
				ItemExistenceChangedEvent.ITEM_ADD, contentGroup_itemAddedHandler);
			contentGroup.addEventListener(
				ItemExistenceChangedEvent.ITEM_REMOVE, contentGroup_itemRemovedHandler);
			contentGroup.addEventListener(
			    FlexEvent.CONTENT_CHANGING, contentGroup_contentChangingHandler);
			contentGroup.addEventListener(
			    FlexEvent.CONTENT_CHANGED, contentGroup_contentChangedHandler);
		}
	}

	/**
	 *  Called when a skin part is removed.
	 */
	override protected function partRemoved(partName:String, instance:*):void
	{
		if (instance == contentGroup)
		{
			contentGroup.removeEventListener(
				ItemExistenceChangedEvent.ITEM_ADD, contentGroup_itemAddedHandler);
			contentGroup.removeEventListener(
				ItemExistenceChangedEvent.ITEM_REMOVE, contentGroup_itemRemovedHandler);
			contentGroup.removeEventListener(
			    FlexEvent.CONTENT_CHANGING, contentGroup_contentChangingHandler);
			contentGroup.removeEventListener(
			    FlexEvent.CONTENT_CHANGED, contentGroup_contentChangedHandler);
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event Handlers
	//
	//--------------------------------------------------------------------------
	
	private function contentGroup_itemAddedHandler(event:ItemExistenceChangedEvent):void
	{
		// Re-dispatch the event
		dispatchEvent(event);
	}
	
	private function contentGroup_itemRemovedHandler(event:ItemExistenceChangedEvent):void
	{
		// Re-dispatch the event
		dispatchEvent(event);
	}
	
	private function contentGroup_contentChangingHandler(event:FlexEvent):void
	{
		// Re-dispatch the event
		dispatchEvent(event);
	}
	
	private function contentGroup_contentChangedHandler(event:FlexEvent):void
	{
		// Re-dispatch the event
		dispatchEvent(event);
	}
}

}
