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

import mx.collections.IList;
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
	//  Properties 
	//
	//--------------------------------------------------------------------------

	// Used to hold the content until the contentGroup is created. 
	private var _placeHolderGroup:Group;
	
	protected function get currentContentGroup():Group
	{
		if (!contentGroup)
		{
			if (!_placeHolderGroup)
			{
				_placeHolderGroup = new Group();
				
				if (_content)
					_placeHolderGroup.content = _content;
				
				_placeHolderGroup.addEventListener(
					ItemExistenceChangedEvent.ITEM_ADD, contentGroup_itemAddedHandler);
				_placeHolderGroup.addEventListener(
					ItemExistenceChangedEvent.ITEM_REMOVE, contentGroup_itemRemovedHandler);
				_placeHolderGroup.addEventListener(
				    FlexEvent.CONTENT_CHANGING, contentGroup_contentChangingHandler);
				_placeHolderGroup.addEventListener(
				    FlexEvent.CONTENT_CHANGED, contentGroup_contentChangedHandler);
			}
			return _placeHolderGroup;
		}
		else
		{
			return contentGroup;	
		}
	}
	
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
		else if (_placeHolderGroup)
			return _placeHolderGroup.content;
		else
			return _content; 
	}
	
	public function set content(value:*):void
	{
		if (value == _content)
			return;
			
		_content = value;	
		
		if (contentGroup)
			contentGroup.content = value;
		else if (_placeHolderGroup)
			_placeHolderGroup.content = value;
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
		return currentContentGroup.numItems;
	}
	
	/**
	 *  @copy flex.core.Group#getItemAt()
	 */
	public function getItemAt(index:int):*
	{
		return currentContentGroup.getItemAt(index);
	}
	
	/**
	 *  @copy flex.core.Group#addItem()
	 */
	public function addItem(item:*):*
	{
		return currentContentGroup.addItem(item);
	}
	
	/**
	 *  @copy flex.core.Group#addItemAt()
	 */
	public function addItemAt(item:*, index:int):*
	{
		return currentContentGroup.addItemAt(item, index);
	}
	
	/**
	 *  @copy flex.core.Group#removeItem()
	 */
	public function removeItem(item:*):*
	{
		return currentContentGroup.removeItem(item);
	}
	
	/**
	 *  @copy flex.core.Group#removeItemAt()
	 */
	public function removeItemAt(index:int):*
	{
		return currentContentGroup.removeItemAt(index);
	}
	
	/**
	 *  @copy flex.core.Group#getItemIndex()
	 */
	public function getItemIndex(item:*):int
	{
		return currentContentGroup.getItemIndex(item);
	}
	
	/**
	 *  @copy flex.core.Group#setItemIndex()
	 */
	public function setItemIndex(item:*, index:int):void
	{
		currentContentGroup.setItemIndex(item, index);
	}
	
	/**
	 *  @copy flex.core.Group#swapItems()
	 */
	public function swapItems(item1:*, item2:*):void
	{
		currentContentGroup.swapItems(item1, item2);
	}
	
	/**
	 *  @copy flex.core.Group#swapItemsAt()
	 */
	public function swapItemsAt(index1:*, index2:*):void
	{
		currentContentGroup.swapItemsAt(index1, index2);
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
			if (_placeHolderGroup != null)
			{
				var sourceContent:Array = _placeHolderGroup.content as Array;
				
				if (sourceContent)
					contentGroup.content = sourceContent.slice();
				else if (_placeHolderGroup.content is IList)
					throw new Error("ItemsComponent can not currently handle content of type " + 
							"IList when adding children dynamically. Please discuss with Jason Szeto");
				else
					contentGroup.content = _placeHolderGroup.content;
				
				// Temporary workaround because copying content from one Group to another throws RTE
				for (var i:int = _placeHolderGroup.numItems; i > 0; i--)
				{
					_placeHolderGroup.removeItemAt(0);	
				}
				
			}
			else if (_content != undefined)
			{
				contentGroup.content = _content;
			}
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
			
			if (_placeHolderGroup)
			{
				_placeHolderGroup.removeEventListener(
					ItemExistenceChangedEvent.ITEM_ADD, contentGroup_itemAddedHandler);
				_placeHolderGroup.removeEventListener(
					ItemExistenceChangedEvent.ITEM_REMOVE, contentGroup_itemRemovedHandler);
				_placeHolderGroup.removeEventListener(
				    FlexEvent.CONTENT_CHANGING, contentGroup_contentChangingHandler);
				_placeHolderGroup.removeEventListener(
				    FlexEvent.CONTENT_CHANGED, contentGroup_contentChangedHandler);
				
				_placeHolderGroup = null;
			}
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
