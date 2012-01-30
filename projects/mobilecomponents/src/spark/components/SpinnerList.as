////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package spark.components
{
import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.IList;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.events.SandboxMouseEvent;
import mx.events.TouchInteractionEvent;
import mx.states.OverrideBase;

import spark.components.supportClasses.ListBase;
import spark.effects.Animate;
import spark.events.RendererExistenceEvent;
import spark.layouts.VerticalSpinnerLayout;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

[Exclude(name="layout", kind="property")]
[Exclude(name="requireSelection", kind="property")]
[Exclude(name="changing", kind="event")]
[Exclude(name="itemRollOut", kind="event")]
[Exclude(name="itemRollOver", kind="event")]	

/*
	
TODO
	Prevent the changing event from getting dispatched
	Support interrupting animateToSelectedIndex (listen for touchStart and kill the animation)
*/

/**
 *  The SpinnerList component displays a list of items. The item in the center of the 
 *  list is always the selectedItem. By default, the list wraps around.
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */ 
public class SpinnerList extends ListBase
{	
	/**
	 *  Constructor.
	 *        
	 *  @langversion 3.0
	 *  @playerversion AIR 3
	 *  @productversion Flex 4.5.2
	 */ 
	public function SpinnerList()
	{
		super();
		
		addEventListener(TouchInteractionEvent.TOUCH_INTERACTION_END, touchInteractionEnd);
		
		super.requireSelection = true;
		
		useVirtualLayout = true;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	mx_internal static const FORCE_NO_WRAP_ELEMENTS_CHANGE:String = "forceNoWrapElementsChange";
    mx_internal static const ENABLED_PROPERTY_NAME:String = "_enabled_";
	
	private var scrollToSelection:Boolean = false;
	private var numElementsChanged:Boolean = false;
	
	private function get spinnerLayout():VerticalSpinnerLayout
	{
		return layout as VerticalSpinnerLayout;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Skin parts
	//
	//--------------------------------------------------------------------------    
	
	//----------------------------------
	//  scroller
	//----------------------------------
	
	[SkinPart(required="false")]
	
	/**
	 *  The optional Scroller used to scroll the List.
	 * 
	 *  @langversion 3.0
	 *  @playerversion AIR 3
	 *  @productversion Flex 4.5.2
	 */
	public var scroller:Scroller;	
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  wrapElements
	//----------------------------------
	
	private var forceNoWrapElements:Boolean = false;
	private var _wrapElements:Boolean = true;
	private var wrapElementsChanged:Boolean = false;
	
	/**
	 *  When true, scrolling past the last element will scroll to the first element. 
	 *       
	 *  @langversion 3.0
	 *  @playerversion AIR 3
	 *  @productversion Flex 4.5.2
	 * 
	 *  @default true
	 */
	public function get wrapElements():Boolean
	{
		if (forceNoWrapElements)
			return false;
		else
			return _wrapElements;
	}
	
	public function set wrapElements(value:Boolean):void
	{
		if (_wrapElements == value)
			return;
		
		_wrapElements = value;
		wrapElementsChanged = true;
		invalidateProperties();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  caretIndex
	//----------------------------------
	
	override public function get caretIndex():Number
	{
		// CaretIndex is always equivalent to the selectedIndex
		return selectedIndex;
	}
	
	//----------------------------------
	//  layout
	//----------------------------------

	override public function set layout(value:LayoutBase):void
	{
		// Layout is not allowed to be set
		return;
	}
	
	override public function set requireSelection(value:Boolean):void
	{
		// Selection is always required
		return;
	}
	
	override public function set dataProvider(value:IList):void
	{	
		super.dataProvider = value;
		
		numElementsChanged = true;
		invalidateProperties();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	override protected function commitProperties():void
	{
		super.commitProperties();
		
		if (numElementsChanged)
		{
			numElementsChanged = false;
			
			// When the DP changes, the DataGroup sets the scroll position to 0
			// So we need to wait for updateComplete before resetting the scroll position to 
			// display the selected item in the center
			if (!scrollToSelection)
			{
				scrollToSelection = true;
				addEventListener(FlexEvent.UPDATE_COMPLETE, updateCompleteHandler);
			}
		}
		
		if (wrapElementsChanged)
		{			
			if (spinnerLayout)
			{
				spinnerLayout.requestedWrapElements = _wrapElements;
			}
			
			if (scroller)
			{
				scroller.pullEnabled = !wrapElements;
				scroller.bounceEnabled = !wrapElements;
			}
			
			wrapElementsChanged = false;
		}
	}
	
	override protected function commitSelection(dispatchChangedEvents:Boolean=true):Boolean
	{		
		var result:Boolean = super.commitSelection(dispatchChangedEvents);

		// SnapElement requires a layout pass in order to properly center the selection
		// The listener for updateComplete calls commitSelection
		if (initialized)
			scroller.snapElement(spinnerLayout.getUnwrappedElementIndex(selectedIndex), false);
		
		return result;
	}
	
	override mx_internal function measureSizes():Boolean
	{
		var changeSize:Boolean = super.measureSizes();
		
		if (changeSize && !scrollToSelection)
		{
			// If the size has changed, then recenter the selectedItem 
			scrollToSelection = true;
			addEventListener(FlexEvent.UPDATE_COMPLETE, updateCompleteHandler);
		}
		
		return changeSize;
	}
	
	override protected function partAdded(partName:String, instance:Object):void
	{
		super.partAdded(partName, instance);
		
		if (instance == scroller)
		{
			scroller.pullEnabled = !wrapElements;
			scroller.bounceEnabled = !wrapElements;
			scroller.scrollSnappingMode = ScrollSnappingMode.CENTER;
		}
		else if (instance == dataGroup)
		{
			if (dataGroup.layout)
				dataGroup.layout.addEventListener(FORCE_NO_WRAP_ELEMENTS_CHANGE, forceNoWrapElementsChangeHandler);
		}
		
	}
	
	override protected function partRemoved(partName:String, instance:Object):void
	{
		super.partRemoved(partName, instance);
		
		if (instance == dataGroup)
		{
			if (dataGroup.layout)
				dataGroup.layout.removeEventListener(FORCE_NO_WRAP_ELEMENTS_CHANGE, forceNoWrapElementsChangeHandler);
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//-------------------------------------------------------------------------- 
	
	/**
	 *   Animate a spin from the current position to the new index
	 */ 
	mx_internal function animateToSelectedIndex(index:int):void
	{
		if (scroller)
		{
			var animate:Animate = scroller.snapElement(
				spinnerLayout.getUnwrappedElementIndex(index), true);
			if (animate)
				animate.addEventListener(EffectEvent.EFFECT_END, animateToIndex_effectEndHandler);
		}
	}
	
	mx_internal function animateToIndex_effectEndHandler(event:EffectEvent):void
	{
		if (spinnerLayout)
		{
			// Commit the center item as the selectedItem
			var centerElementIndex:int = spinnerLayout.getIndexAtVerticalCenter();
			selectedIndex = centerElementIndex;
		}
		
		Animate(event.currentTarget).removeEventListener(EffectEvent.EFFECT_END, animateToIndex_effectEndHandler);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//-------------------------------------------------------------------------- 
	
	private function touchInteractionEnd(event:TouchInteractionEvent):void
	{
		// Commit the center item as the selectedItem when the scroll has completed
		if (spinnerLayout)
		{
			var centerElementIndex:int = spinnerLayout.getIndexAtVerticalCenter();
			setSelectedIndex(centerElementIndex, true);
		}
	}
	
	override protected function dataProvider_collectionChangeHandler(event:Event):void
	{
		super.dataProvider_collectionChangeHandler(event);
		
		if (event is CollectionEvent)
		{
			var ce:CollectionEvent = CollectionEvent(event);
			
			if (ce.kind == CollectionEventKind.ADD ||
				ce.kind == CollectionEventKind.REMOVE ||
				ce.kind == CollectionEventKind.RESET ||
				ce.kind == CollectionEventKind.REFRESH)
			{
				numElementsChanged = true;
				invalidateProperties();
			}
		}
	}
	
	/**
	 *  @private
	 *  Called when an item has been added to this component.
	 */
	override protected function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void
	{
		super.dataGroup_rendererAddHandler(event);
		var renderer:IVisualElement = event.renderer;
		
		if (!renderer)
			return;
		
		renderer.addEventListener(MouseEvent.CLICK, item_mouseClickHandler);
	}
	
	/**
	 *  @private
	 *  Called when an item has been removed from this component.
	 */
	override protected function dataGroup_rendererRemoveHandler(event:RendererExistenceEvent):void
	{
		super.dataGroup_rendererRemoveHandler(event);
		
		var renderer:Object = event.renderer;
		
		if (!renderer)
			return;
		
		renderer.removeEventListener(MouseEvent.CLICK, item_mouseClickHandler);
	}
	
	/**
	 *  When an item is clicked, animate it to the center
	 */ 
	private function item_mouseClickHandler(event:MouseEvent):void
	{
		var newIndex:int;
		
		if (event.currentTarget is IItemRenderer)
			newIndex = IItemRenderer(event.currentTarget).itemIndex;
		else
			newIndex = dataGroup.getElementIndex(event.currentTarget as IVisualElement);
		
		// If an item is disabled, then don't animate to that item
		if (event.currentTarget["enabled"] == undefined ||
			event.currentTarget["enabled"] == true)
			animateToSelectedIndex(newIndex);
	}
	
	/**
	 *  Animate the selectedItem to the center once we have performed a layout pass
	 */ 
	private function updateCompleteHandler(event:FlexEvent):void
	{
		if (scrollToSelection && spinnerLayout)
		{
			scrollToSelection = false;
			scroller.snapElement(spinnerLayout.getUnwrappedElementIndex(selectedIndex), false);
			
			removeEventListener(FlexEvent.UPDATE_COMPLETE, updateCompleteHandler);
		}
	}
	
	/**
	 *  Called if the layout has automatically switched wrap modes
	 */ 
	private function forceNoWrapElementsChangeHandler(event:Event):void
	{
		invalidateProperties();
		forceNoWrapElements = spinnerLayout.forceNoWrapElements;
		wrapElementsChanged = true;
	}
	
	
}
}