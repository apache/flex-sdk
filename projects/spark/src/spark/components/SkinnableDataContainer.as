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

import flex.core.DataGroup;
import flex.core.SkinnableComponent;
import flex.events.FlexEvent;
import flex.events.ItemExistenceChangedEvent;
import flex.layout.LayoutBase;

import mx.collections.IList;
import mx.core.IFactory;
import mx.managers.IFocusManagerContainer;

/**
 *  Dispatched prior to the dataProvider being changed.
 */
[Event(name="dataProviderChanging", type="flex.events.FlexEvent")]

/**
 *  Dispatched after the dataProvider has changed.
 */
[Event(name="dataProviderChanged", type="flex.events.FlexEvent")]

[DefaultProperty("dataProvider")]

/**
 * The DataComponent class is the base class for all skinnable components that have 
 * data content. This class is not typically instantiated in MXML. It is primarily
 * used as a base class, or as a SkinPart.
 */
public class DataComponent extends SkinnableComponent implements IFocusManagerContainer
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
	public function DataComponent()
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
	public var dataGroup:DataGroup;
	
	//--------------------------------------------------------------------------
	//
	//  Properties 
	//
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//
	//  Properties proxied to dataGroup
	//
	//--------------------------------------------------------------------------
		
	//----------------------------------
	//  content
	//----------------------------------	
	
	private var _dataProvider:*;
	
	/**
	 *  @copy flex.core.DataGroup#dataProvider
	 */
	[Bindable]
	public function get dataProvider():IList
	{		
		if (dataGroup)
			return dataGroup.dataProvider;
		else
			return _dataProvider; 
	}
	
	public function set dataProvider(value:IList):void
	{
		if (value == _dataProvider)
			return;
			
		_dataProvider = value;	
		
		if (dataGroup)
			dataGroup.dataProvider = value;
	}
	
	//----------------------------------
	//  layout
	//----------------------------------
	
	/**
	 *  @copy flex.core.DataGroup#layout
	 */
	 
	private var _layout:LayoutBase;
	
    public function get layout():LayoutBase
    {
    	return (dataGroup) ? dataGroup.layout : _layout;
    }

    public function set layout(value:LayoutBase):void
    {
		if (value != _layout) {
    		_layout = value;
    		if (dataGroup) {
    			dataGroup.layout = _layout;
    		}
		}
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
		if (dataGroup)
			return dataGroup.itemRenderer;
		
		return _itemRenderer;
	}
	
	public function set itemRenderer(value:IFactory):void
	{
		if (value == _itemRenderer)
			return;
			
		_itemRenderer = value;
		
		if (dataGroup)
			dataGroup.itemRenderer = _itemRenderer;
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
		if (dataGroup)
			return dataGroup.itemRendererFunction;
		
		return _itemRendererFunction;
	}
	
	public function set itemRendererFunction(value:Function):void
	{
		if (value == _itemRendererFunction)
			return;
		
		_itemRendererFunction = value;
		
		if (dataGroup)
			dataGroup.itemRendererFunction = _itemRendererFunction;
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
	override protected function partAdded(partName:String, instance:Object):void
	{
		if (instance == dataGroup)
		{
			if (_dataProvider != undefined)
			{
				dataGroup.dataProvider = _dataProvider;
			}
			if (_layout != null)
				dataGroup.layout = _layout;
			if (_itemRenderer != null || _itemRendererFunction != null)
			{
				dataGroup.itemRenderer = _itemRenderer;
				dataGroup.itemRendererFunction = _itemRendererFunction;
			}

			dataGroup.addEventListener(
			    FlexEvent.DATA_PROVIDER_CHANGING, dataGroup_dataProviderChangingHandler);
			dataGroup.addEventListener(
			    FlexEvent.DATA_PROVIDER_CHANGED, dataGroup_dataProviderChangedHandler);
		}
	}

	/**
	 *  Called when a skin part is removed.
	 */
	override protected function partRemoved(partName:String, instance:Object):void
	{
		if (instance == dataGroup)
		{
			dataGroup.removeEventListener(
			    FlexEvent.DATA_PROVIDER_CHANGING, dataGroup_dataProviderChangingHandler);
			dataGroup.removeEventListener(
			    FlexEvent.DATA_PROVIDER_CHANGED, dataGroup_dataProviderChangedHandler);
		}
	}
		
	
	//--------------------------------------------------------------------------
	//
	//  Event Handlers
	//
	//--------------------------------------------------------------------------
	
	private function dataGroup_dataProviderChangingHandler(event:FlexEvent):void
	{
		// Re-dispatch the event
		dispatchEvent(event);
	}
	
	private function dataGroup_dataProviderChangedHandler(event:FlexEvent):void
	{
		// Re-dispatch the event
		dispatchEvent(event);
	}
}

}
