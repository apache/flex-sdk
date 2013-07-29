////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package spark.components
{
	import flash.events.Event;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.core.IDataRenderer;
	import mx.core.IFactory;
	import mx.core.ISelectableList;
	import mx.core.IVisualElement;
	import mx.core.mx_internal;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.FlexEvent;
	import mx.utils.BitFlagUtil;
	
	import spark.components.IItemRenderer;
	import spark.components.IItemRendererOwner;
	import spark.components.supportClasses.SkinnableContainerBase;
	import spark.events.IndexChangeEvent;
	import spark.events.RendererExistenceEvent;
	import spark.layouts.supportClasses.LayoutBase;
	import spark.utils.LabelUtil;
	
	import spark.layouts.supportClasses.AnimationNavigatorLayoutBase;
	import spark.layouts.supportClasses.INavigatorLayout;
	
	use namespace mx_internal;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 *  Dispatched when the ISelectableList has been updated in some way.
	 *
	 *  @eventType mx.events.CollectionEvent.COLLECTION_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	[Event(name="collectionChange", type="mx.events.CollectionEvent")]
	
	/**
	 *  Dispatched after the selection has changed. 
	 *  This event is dispatched when the user interacts with the control.
	 * 
	 *  <p>When you change the value of the <code>selectedIndex</code> 
	 *  or <code>selectedItem</code> properties programmatically, 
	 *  the control does not dispatch the <code>change</code> event. 
	 *  It dispatches the <code>valueCommit</code> event instead.</p>
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
	 *  Dispatched when a renderer is added to the container.
	 *  The <code>event.renderer</code> property contains 
	 *  the renderer that was added.
	 *
	 *  @eventType spark.events.RendererExistenceEvent.RENDERER_ADD
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Event(name="rendererAdd", type="spark.events.RendererExistenceEvent")]
	
	/**
	 *  Dispatched when a renderer is removed from the container.
	 *  The <code>event.renderer</code> property contains 
	 *  the renderer that was removed.
	 *
	 *  @eventType spark.events.RendererExistenceEvent.RENDERER_REMOVE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Event(name="rendererRemove", type="spark.events.RendererExistenceEvent")]
	
//	include "../styles/metadata/BasicInheritingTextStyles.as"
	
	/**
	 *  The alpha of the focus ring for this component.
	 *
	 *  @default 0.55
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="focusAlpha", type="Number", inherit="no", theme="spark", minValue="0.0", maxValue="1.0")]
	
	/**
	 *  Color of focus ring when the component is in focus.
	 *
	 *  @default 0x70B2EE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ 
	[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark")]
	
	/**
	 *  Thickness, in pixels, of the focus rectangle outline.
	 *
	 *  @default 2
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	[Style(name="focusThickness", type="Number", format="Length", inherit="no", minValue="0.0")]
	
	/**
	 *  The alpha of the border for this component.
	 *
	 *  @default 1.0
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="borderAlpha", type="Number", inherit="no", theme="spark", minValue="0.0", maxValue="1.0")]
	
	/**
	 *  The color of the border for this component.
	 *
	 *   @default #696969
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="borderColor", type="uint", format="Color", inherit="no", theme="spark")]
	
	/**
	 *  Controls the visibility of the border for this component.
	 *
	 *  @default true
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="borderVisible", type="Boolean", inherit="no", theme="spark")]
	
	/**
	 *  The alpha of the content background for this component.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="contentBackgroundAlpha", type="Number", inherit="yes", theme="spark", minValue="0.0", maxValue="1.0")]
	
	/**
	 *  @copy spark.components.supportClasses.GroupBase#style:contentBackgroundColor
	 *   
	 *  @default 0xFFFFFF
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes", theme="spark")]
	
	[DefaultProperty("dataProvider")]
	
	//[IconFile("SkinnableDataContainer.png")]
	
	/**
	 *  The SkinnableDataContainer class is the base container class for
	 *  data items.  The SkinnableDataContainer class converts data 
	 *  items to visual elements for display.
	 *  While this container can hold visual elements, it is often used only 
	 *  to hold data items as children.
	 *
	 *  <p>The SkinnableDataContainer class takes as children data items 
	 *  or visual elements that implement the IVisualElement interface
	 *  and are Display Objects.
	 *  Data items can be simple data items such String and Number objects, 
	 *  and more complicated data items such as Object and XMLNode objects. 
	 *  While these containers can hold visual elements, 
	 *  they are often used only to hold data items as children.</p>
	 *
	 *  <p>An item renderer defines the visual representation of the 
	 *  data item in the container. 
	 *  The item renderer converts the data item into a format that can 
	 *  be displayed by the container. 
	 *  You must pass an item renderer to a SkinnableDataContainer to 
	 *  render data items appropriately.</p>
	 *
	 *  <p>If you want a container of data items and don't need a skin, then 
	 *  it is recommended to use a DataGroup (which cannot be skinned) to 
	 *  improve performance and application size.</p>
	 *
	 *  <p>The SkinnableDataContainer container has the following default characteristics:</p>
	 *  <table class="innertable">
	 *     <tr><th>Characteristic</th><th>Description</th></tr>
	 *     <tr><td>Default size</td><td>Large enough to display its children</td></tr>
	 *     <tr><td>Minimum size</td><td>0 pixels</td></tr>
	 *     <tr><td>Maximum size</td><td>10000 pixels wide and 10000 pixels high</td></tr>
	 *  </table>
	 * 
	 *  @mxml
	 *
	 *  <p>The <code>&lt;s:SkinnableDataContainer&gt;</code> tag inherits all of the tag 
	 *  attributes of its superclass and adds the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;s:SkinnableDataContainer
	 *    <strong>Properties</strong>
	 *    autoLayout="true"
	 *    dataProvider="null"
	 *    itemRenderer="null"
	 *    itemRendererFunction="null"
	 *    layout="VerticalLayout"
	 *    typicalItem="null"
	 *  
	 *    <strong>Styles</strong>
	 *    alignmentBaseline="useDominantBaseline"
	 *    baselineShift="0.0"
	 *    cffHinting="horizontal_stem"
	 *    color="0"
	 *    digitCase="default"
	 *    digitWidth="default"
	 *    direction="LTR"
	 *    dominantBaseline="auto"
	 *    focusAlpha="0.55"
	 *    focusColor=""
	 *    focusThickness="2"
	 *    fontFamily="Times New Roman"
	 *    fontLookup="device"
	 *    fontSize="12"
	 *    fontStyle="normal"
	 *    fontWeight="normal"
	 *    justificationRule="auto"
	 *    justificationStyle="auto"
	 *    kerning="auto"
	 *    ligatureLevel="common"
	 *    lineHeight="120%"
	 *    lineThrough="false"
	 *    locale="en"
	 *    renderingMode="CFF"
	 *    textAlign="start"
	 *    textAlignLast="start"
	 *    textAlpha="1"
	 *    textJustify="inter_word"
	 *    trackingLeft="0"
	 *    trackingRight="0"
	 *    typographicCase="default"
	 *  
	 *    <strong>Events</strong>
	 *    rendererAdd="<i>No default</i>"
	 *    rendererRemove="<i>No default</i>"
	 *  /&gt;
	 *  </pre>
	 *
	 *  @see SkinnableContainer
	 *  @see DataGroup
	 *  @see spark.skins.spark.SkinnableDataContainerSkin
	 *
	 *  @includeExample examples/SkinnableDataContainerExample.mxml
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public class DataNavigator extends SkinnableContainerBase implements IItemRendererOwner, ISelectableList
	{
//			include "../core/Version.as";
		
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private static const AUTO_LAYOUT_PROPERTY_FLAG:uint = 1 << 0;
		
		/**
		 *  @private
		 */
		private static const DATA_PROVIDER_PROPERTY_FLAG:uint = 1 << 1;
		
		/**
		 *  @private
		 */
		private static const ITEM_RENDERER_PROPERTY_FLAG:uint = 1 << 2;
		
		/**
		 *  @private
		 */
		private static const ITEM_RENDERER_FUNCTION_PROPERTY_FLAG:uint = 1 << 3;
		
		/**
		 *  @private
		 */
		private static const LAYOUT_PROPERTY_FLAG:uint = 1 << 4;
		
		/**
		 *  @private
		 */
		private static const TYPICAL_ITEM_PROPERTY_FLAG:uint = 1 << 5;
		
		/**
		 *  @private
		 */
		private static const SELECTED_INDEX_PROPERTY_FLAG:uint = 1 << 6;
		
		
		
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
		public function DataNavigator()
		{
			super();
			
			useVirtualLayout = true;
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Skin Parts
		//
		//--------------------------------------------------------------------------
		
		[SkinPart(required="false")]
		
		/**
		 *  An optional skin part that defines the DataGroup in the skin class 
		 *  where data items get pushed into, rendered, and laid out.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var contentGroup:DataNavigatorGroup;
		
		/**
		 *  @private
		 *  Several properties are proxied to contentGroup.  However, when contentGroup
		 *  is not around, we need to store values set on SkinnableDataContainer.  This object 
		 *  stores those values.  If contentGroup is around, the values are stored 
		 *  on the contentGroup directly.  However, we need to know what values 
		 *  have been set by the developer on the SkinnableDataContainer (versus set on 
		 *  the contentGroup or defaults of the contentGroup) as those are values 
		 *  we want to carry around if the contentGroup changes (via a new skin). 
		 *  In order to store this info effeciently, dataGroupProperties becomes 
		 *  a uint to store a series of BitFlags.  These bits represent whether a 
		 *  property has been explicitly set on this SkinnableDataContainer.  When the 
		 *  contentGroup is not around, dataGroupProperties is a typeless 
		 *  object to store these proxied properties.  When contentGroup is around,
		 *  dataGroupProperties stores booleans as to whether these properties 
		 *  have been explicitly set or not.
		 */
		private var dataGroupProperties:Object = {};
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties 
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  selectedIndex
		//---------------------------------- 
		
		[Bindable("change")]
		[Bindable("valueCommit")]
		
		/**
		 *  @copy spark.components.DataNavigatorGroup#selectedIndex
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get selectedIndex():int
		{
			return contentGroup ? contentGroup.selectedIndex : dataGroupProperties.selectedIndex;
		}
		/**
		 *  @private
		 */
		public function set selectedIndex( value:int ):void
		{
			if( value == selectedIndex ) return;
			
			if (contentGroup)
			{
				contentGroup.selectedIndex = value;
				dataGroupProperties = BitFlagUtil.update(dataGroupProperties as uint, 
					SELECTED_INDEX_PROPERTY_FLAG, true);
			}
			else
				dataGroupProperties.selectedIndex = value;
		}
		
		
		
		//----------------------------------
		//  selectedItem
		//---------------------------------- 
		
		[Bindable("change")]
		[Bindable("valueCommit")]
		
		/**
		 *  @copy spark.components.DataNavigatorGroup#selectedItem
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get selectedItem():Object
		{
			var index:int = selectedIndex;
			return index != -1 ? dataProvider.getItemAt( index ) : null;
		}
		/**
		 *  @private
		 */
		public function set selectedItem( value:Object ):void
		{
			if( dataProvider )
			{
				var index:int = dataProvider.getItemIndex( value );
				if( index != -1 ) selectedIndex = index;
			}
		}
		
		
		
		//----------------------------------
		//  useVirtualLayout
		//----------------------------------
		
		/**
		 *  @private
		 */
		private var _useVirtualLayout:Boolean = true;
		
		/**
		 *  Sets the value of the <code>useVirtualLayout</code> property
		 *  of the layout associated with this control.  
		 *  If the layout is subsequently replaced and the value of this 
		 *  property is <code>true</code>, then the new layout's 
		 *  <code>useVirtualLayout</code> property is set to <code>true</code>.
		 *
		 *  @default true
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get useVirtualLayout():Boolean
		{
			return layout ? layout.useVirtualLayout : _useVirtualLayout;
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
			if( value == useVirtualLayout ) return;
			
			_useVirtualLayout = value;
			if ( layout ) layout.useVirtualLayout = value;
		}
		
		
		//----------------------------------
		//  length
		//---------------------------------- 
		
		/**
		 *  @copy spark.components.DataNavigatorGroup#length
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get length():int
		{
			return dataProvider ? dataProvider.length : 0;
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties proxied to contentGroup
		//
		//--------------------------------------------------------------------------
		
		
		
		
		//----------------------------------
		//  labelField
		//----------------------------------
		
		/**
		 *  @private
		 */
		private var _labelField:String = "label";
		
		/**
		 *  @private
		 */
		private var _labelFieldOrFunctionChanged:Boolean; 
		
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
			_labelFieldOrFunctionChanged = true;
			invalidateProperties();
		}
		
		//----------------------------------
		//  labelFunction
		//----------------------------------
		
		/**
		 *  @private
		 */
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
			_labelFieldOrFunctionChanged = true;
			invalidateProperties(); 
		}
		
		
		
		
		
		//----------------------------------
		//  autoLayout
		//----------------------------------
		
		[Inspectable(defaultValue="true")]
		
		/**
		 *  @copy spark.components.supportClasses.GroupBase#autoLayout
		 *
		 *  @default true
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get autoLayout():Boolean
		{
			if (contentGroup)
				return contentGroup.autoLayout;
			else
			{
				// want the default to be true
				var v:* = dataGroupProperties.autoLayout;
				return (v === undefined) ? true : v;
			}
		}
		
		/**
		 *  @private
		 */
		public function set autoLayout(value:Boolean):void
		{
			if (contentGroup)
			{
				contentGroup.autoLayout = value;
				dataGroupProperties = BitFlagUtil.update(dataGroupProperties as uint, 
					AUTO_LAYOUT_PROPERTY_FLAG, true);
			}
			else
				dataGroupProperties.autoLayout = value;
		}
		
		//----------------------------------
		//  dataProvider
		//----------------------------------    
		
		/**
		 *  @private
		 *  Storage property for dataProvider.
		 */
		private var _dataProvider:IList;
		
		/**
		 *  @copy spark.components.DataGroup#dataProvider
		 *
		 *  @see #itemRenderer
		 *  @see #itemRendererFunction
		 *  @see mx.collections.IList
		 *  @see mx.collections.ArrayCollection
		 *  @see mx.collections.ArrayList
		 *  @see mx.collections.XMLListCollection
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		[Bindable("dataProviderChanged")]
		[Bindable("change")]
		
		public function get dataProvider():IList
		{       
			return (contentGroup) 
			? contentGroup.dataProvider 
				: dataGroupProperties.dataProvider;
		}
		
		public function set dataProvider(value:IList):void
		{
			if( _dataProvider == value ) return;
			
			if( _dataProvider ) _dataProvider.removeEventListener( CollectionEvent.COLLECTION_CHANGE, onDataProviderCollectionChange, false );
			
			_dataProvider = value;
			
			if (contentGroup)
			{
				contentGroup.dataProvider = value;
				dataGroupProperties = BitFlagUtil.update(dataGroupProperties as uint, 
					DATA_PROVIDER_PROPERTY_FLAG, true);
			}
			else
				dataGroupProperties.dataProvider = value;
			
			if( _dataProvider ) _dataProvider.addEventListener( CollectionEvent.COLLECTION_CHANGE, onDataProviderCollectionChange, false, 0, true );
			
			dispatchEvent( new Event( "dataProviderChanged" ) );
			if( hasEventListener( CollectionEvent.COLLECTION_CHANGE )  ) dispatchEvent( new CollectionEvent( CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.RESET, -1, -1, toArray() ) );
		}
		
		//----------------------------------
		//  itemRenderer
		//----------------------------------
		
		/**
		 *  @copy spark.components.DataGroup#itemRenderer
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get itemRenderer():IFactory
		{
			return (contentGroup) 
			? contentGroup.itemRenderer 
				: dataGroupProperties.itemRenderer;
		}
		
		/**
		 *  @private
		 */
		public function set itemRenderer(value:IFactory):void
		{
			if( value == itemRenderer ) return;
			
			if (contentGroup)
			{
				contentGroup.itemRenderer = value;
				dataGroupProperties = BitFlagUtil.update(dataGroupProperties as uint, 
					ITEM_RENDERER_PROPERTY_FLAG, true);
			}
			else
				dataGroupProperties.itemRenderer = value;
		}
		
		//----------------------------------
		//  itemRendererFunction
		//----------------------------------
		
		/**
		 *  @copy spark.components.DataGroup#itemRendererFunction
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get itemRendererFunction():Function
		{
			return (contentGroup) 
			? contentGroup.itemRendererFunction 
				: dataGroupProperties.itemRendererFunction;
		}
		
		/**
		 *  @private
		 */
		public function set itemRendererFunction(value:Function):void
		{
			if (contentGroup)
			{
				contentGroup.itemRendererFunction = value;
				dataGroupProperties = BitFlagUtil.update(dataGroupProperties as uint, 
					ITEM_RENDERER_FUNCTION_PROPERTY_FLAG, true);
			}
			else
				dataGroupProperties.itemRendererFunction = value;
		}
		
		//----------------------------------
		//  layout
		//----------------------------------
		
		/**
		 *  @copy spark.components.supportClasses.GroupBase#layout
		 *
		 *  @default VerticalLayout
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */     
		public function get layout():LayoutBase
		{
			return (contentGroup) 
			? contentGroup.layout 
				: dataGroupProperties.layout;
		}
		/**
		 *  @private
		 */
		public function set layout(value:LayoutBase):void
		{
			var layout:LayoutBase = layout;
			
			if( layout == value ) return;
			
			if( value && useVirtualLayout) value.useVirtualLayout = true;
			
			removeLayoutListeners();
			
			if( value is INavigatorLayout )
			{
				if (contentGroup)
				{
					contentGroup.layout = value;
					dataGroupProperties = BitFlagUtil.update(dataGroupProperties as uint, 
						LAYOUT_PROPERTY_FLAG, true);
				}
				else
				{
					dataGroupProperties.layout = value;
				}
				
				addLayoutListeners();
			}
			else
			{
				throw new Error( "Layout must implement INavigatorLayout" );
			}
		}
		
		//----------------------------------
		//  typicalItem
		//----------------------------------
		
		/**
		 *  @copy spark.components.DataGroup#typicalItem
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get typicalItem():Object
		{
			return (contentGroup) 
			? contentGroup.typicalItem 
				: dataGroupProperties.typicalItem;
		}
		
		/**
		 *  @private
		 */
		public function set typicalItem(value:Object):void
		{
			if (contentGroup)
			{
				contentGroup.typicalItem = value;
				dataGroupProperties = BitFlagUtil.update(dataGroupProperties as uint, 
					TYPICAL_ITEM_PROPERTY_FLAG, true);
			}
			else
				dataGroupProperties.typicalItem = value;
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @copy spark.components.DataNavigatorGroup#addItem
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function addItem( item:Object ):void
		{
			addItemAt( item, length );
		}
		
		/**
		 *  @copy spark.components.DataNavigatorGroup#addItemAt
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function addItemAt( item:Object, index:int ):void
		{
			if( !dataProvider ) dataProvider = new ArrayList();
			dataProvider.addItemAt( item, index );
		}
		
		/**
		 *  @copy spark.components.DataNavigatorGroup#getItemAt
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function getItemAt( index:int, prefetch:int = 0 ):Object
		{
			if( !dataProvider || length <= index ) return null;
			return  dataProvider.getItemAt( index );
		}
		
		/**
		 *  @copy spark.components.DataNavigatorGroup#getItemIndex
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function getItemIndex( item:Object ):int
		{
			if( !dataProvider ) return -1;
			return dataProvider.getItemIndex( item );
		}
		
		/**
		 *  @copy spark.components.DataNavigatorGroup#itemUpdated
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function itemUpdated( item:Object, property:Object=null, oldValue:Object=null, newValue:Object=null ):void
		{
			if( dataProvider ) dataProvider.itemUpdated( item, property, oldValue, newValue );
		}
		
		/**
		 *  @copy spark.components.DataNavigatorGroup#removeAll
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function removeAll():void
		{
			if( !dataProvider ) return;
			dataProvider.removeAll();
		}
		
		/**
		 *  @copy spark.components.DataNavigatorGroup#removeItem
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4.10
		 */
		public function removeItem( item:Object ):Boolean
		{
			if ("removeItem" in dataProvider)
                return dataProvider["removeItem"]( item );
            return false;
		}
		
		/**
		 *  @copy spark.components.DataNavigatorGroup#removeItemAt
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function removeItemAt( index:int ):Object
		{
			if( !dataProvider || index >= length ) return null;
			return dataProvider.removeItemAt( index );
		}
		
		/**
		 *  @copy spark.components.DataNavigatorGroup#setItemAt
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function setItemAt(item:Object, index:int):Object
		{
			if( !dataProvider || index > length ) return null;
			return dataProvider.setItemAt( item, index );
		}
		
		/**
		 *  @copy spark.components.DataNavigatorGroup#toArray
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function toArray():Array
		{
			return ( !dataProvider ) ? null : dataProvider.toArray();
		}
		
		/**
		 *  From the specified data item, return the String representation 
		 *  of the data item for an item renderer to display.
		 *  This method uses the <code>toString()</code> method of 
		 *  the data item to convert it to a String representation.
		 *  A Null data item returns an empty string.
		 *
		 *  @param item The data item.
		 *
		 *  @return The String representation of the data item.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function itemToLabel(item:Object):String
		{
			return LabelUtil.itemToLabel( item, labelField, labelFunction );
		}
		
		/**
		 *  Updates an item renderer for use or reuse. 
		 *  When an item renderer is first created,
		 *  or when it is recycled because of virtualization, this 
		 *  SkinnableDataContainer instance can set the 
		 *  item renderer's <code>label</code> property and 
		 *  <code>owner</code> property. 
		 *  
		 *  @param renderer The renderer being updated 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 * 
		 */
		public function updateRenderer(renderer:IVisualElement, itemIndex:int, data:Object):void
		{
			// set the owner
			renderer.owner = this;
			
			// Set the index
			if (renderer is IItemRenderer)
				IItemRenderer(renderer).itemIndex = itemIndex;
			
			// set the label to the toString() of the data 
			if (renderer is IItemRenderer)
				IItemRenderer(renderer).label = itemToLabel(data);
			
			// always set the data last
			if ((renderer is IDataRenderer) && (renderer !== data))
				IDataRenderer(renderer).data = data;
		}
		
		/**
		 *  Adjusts the selected index to account for items being added to or 
		 *  removed from this component.
		 *
		 *  @param newIndex The new index.
		 *   
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		protected function adjustSelection( newIndex:int ):void
		{
			var nl:INavigatorLayout = INavigatorLayout( layout );
			if( !nl ) return;
			
			if( nl is AnimationNavigatorLayoutBase )
			{
				var anl:AnimationNavigatorLayoutBase = AnimationNavigatorLayoutBase( nl );
				var duration:Number = anl.duration;
				anl.duration = 0;
			}
			
			nl.selectedIndex = newIndex;
			
			if( anl ) anl.duration = duration;
		}
		
		/**
		 *  @private
		 */
		private function addLayoutListeners():void
		{
			if( !layout ) return;
			layout.addEventListener( IndexChangeEvent.CHANGE, onLayoutEvent, false, 0, true );
			layout.addEventListener( FlexEvent.VALUE_COMMIT, onLayoutEvent, false, 0, true );
		}
		
		/**
		 *  @private
		 */
		private function removeLayoutListeners():void
		{
			if( !layout ) return;
			layout.removeEventListener( IndexChangeEvent.CHANGE, onLayoutEvent, false );
			layout.removeEventListener( FlexEvent.VALUE_COMMIT, onLayoutEvent, false );
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == contentGroup)
			{
				// copy proxied values from dataGroupProperties (if set) to contentGroup
				
				var newDataGroupProperties:uint = 0;
				
				if (dataGroupProperties.layout !== undefined)
				{
					contentGroup.layout = dataGroupProperties.layout;
					newDataGroupProperties = BitFlagUtil.update(newDataGroupProperties as uint, 
						LAYOUT_PROPERTY_FLAG, true);;
				}
				
				if (dataGroupProperties.autoLayout !== undefined)
				{
					contentGroup.autoLayout = dataGroupProperties.autoLayout;
					newDataGroupProperties = BitFlagUtil.update(newDataGroupProperties as uint, 
						AUTO_LAYOUT_PROPERTY_FLAG, true);
				}
				
				if (dataGroupProperties.dataProvider !== undefined)
				{
					contentGroup.dataProvider = dataGroupProperties.dataProvider;
					newDataGroupProperties = BitFlagUtil.update(newDataGroupProperties as uint, 
						DATA_PROVIDER_PROPERTY_FLAG, true);
				}
				
				if (dataGroupProperties.itemRenderer !== undefined)
				{
					contentGroup.itemRenderer = dataGroupProperties.itemRenderer;
					newDataGroupProperties = BitFlagUtil.update(newDataGroupProperties as uint, 
						ITEM_RENDERER_PROPERTY_FLAG, true);
				}
				
				if (dataGroupProperties.itemRendererFunction !== undefined)
				{
					contentGroup.itemRendererFunction = dataGroupProperties.itemRendererFunction;
					newDataGroupProperties = BitFlagUtil.update(newDataGroupProperties as uint, 
						ITEM_RENDERER_FUNCTION_PROPERTY_FLAG, true);
				}
				
				if (dataGroupProperties.typicalItem !== undefined)
				{
					contentGroup.typicalItem = dataGroupProperties.typicalItem;
					newDataGroupProperties = BitFlagUtil.update(newDataGroupProperties as uint, 
						TYPICAL_ITEM_PROPERTY_FLAG, true);
				}
				
				if (dataGroupProperties.selectedIndex !== undefined)
				{
					contentGroup.selectedIndex = dataGroupProperties.selectedIndex;
					newDataGroupProperties = BitFlagUtil.update(newDataGroupProperties as uint, 
						SELECTED_INDEX_PROPERTY_FLAG, true);
				}
								
				dataGroupProperties = newDataGroupProperties;
				
				// Register our instance as the contentGroup's item renderer update delegate.
				contentGroup.rendererUpdateDelegate = this;
				
				// Not your typical delegation, see 'set useVirtualLayout'
				if( contentGroup.layout ) contentGroup.layout.useVirtualLayout = _useVirtualLayout;
				
				// The only reason we have these listeners is to re-dispatch events.  
				// We only add as necessary.
				
				if (hasEventListener(RendererExistenceEvent.RENDERER_ADD))
				{
					contentGroup.addEventListener(
						RendererExistenceEvent.RENDERER_ADD, dispatchEvent);
				}
				
				if (hasEventListener(RendererExistenceEvent.RENDERER_REMOVE))
				{
					contentGroup.addEventListener(
						RendererExistenceEvent.RENDERER_REMOVE, dispatchEvent);
				}
				
				if (hasEventListener(FlexEvent.VALUE_COMMIT))
				{
					contentGroup.addEventListener(
						FlexEvent.VALUE_COMMIT, dispatchEvent);
				}
				
				if (hasEventListener(IndexChangeEvent.CHANGE))
				{
					contentGroup.addEventListener(
						IndexChangeEvent.CHANGE, dispatchEvent);
				}
			}
		}
		
		/**
		 * @private
		 */
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			if (instance == contentGroup)
			{
				contentGroup.removeEventListener(
					RendererExistenceEvent.RENDERER_ADD, dispatchEvent);
				contentGroup.removeEventListener(
					RendererExistenceEvent.RENDERER_REMOVE, dispatchEvent);
				contentGroup.removeEventListener(
					FlexEvent.VALUE_COMMIT, dispatchEvent);
				contentGroup.removeEventListener(
					IndexChangeEvent.CHANGE, dispatchEvent);
				
				// copy proxied values from contentGroup (if explicitly set) to dataGroupProperties
				
				var newDataGroupProperties:Object = {};
				
				if (BitFlagUtil.isSet(dataGroupProperties as uint, LAYOUT_PROPERTY_FLAG))
					newDataGroupProperties.layout = contentGroup.layout;
				
				if (BitFlagUtil.isSet(dataGroupProperties as uint, AUTO_LAYOUT_PROPERTY_FLAG))
					newDataGroupProperties.autoLayout = contentGroup.autoLayout;
				
				if (BitFlagUtil.isSet(dataGroupProperties as uint, DATA_PROVIDER_PROPERTY_FLAG))
					newDataGroupProperties.dataProvider = contentGroup.dataProvider;
				
				if (BitFlagUtil.isSet(dataGroupProperties as uint, ITEM_RENDERER_PROPERTY_FLAG))
					newDataGroupProperties.itemRenderer = contentGroup.itemRenderer;
				
				if (BitFlagUtil.isSet(dataGroupProperties as uint, ITEM_RENDERER_FUNCTION_PROPERTY_FLAG))
					newDataGroupProperties.itemRendererFunction = contentGroup.itemRendererFunction;
				
				if (BitFlagUtil.isSet(dataGroupProperties as uint, TYPICAL_ITEM_PROPERTY_FLAG))
					newDataGroupProperties.typicalItem = contentGroup.typicalItem;
				
				if (BitFlagUtil.isSet(dataGroupProperties as uint, SELECTED_INDEX_PROPERTY_FLAG))
					newDataGroupProperties.selectedIndex = contentGroup.selectedIndex;
				
				dataGroupProperties = newDataGroupProperties;
				
				contentGroup.dataProvider = null;
				contentGroup.layout = null;
				contentGroup.rendererUpdateDelegate = null;
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if( _labelFieldOrFunctionChanged )
			{
				// Cycle through all instantiated renderers to push the correct text 
				// in to the renderer by setting its label property
				if( contentGroup )
				{
					var itemIndex:int;
					
					// if virtual layout, only loop through the indices in view
					// otherwise, loop through all of the item renderers
					if( layout && layout.useVirtualLayout )
					{
						for each( itemIndex in contentGroup.getItemIndicesInView() )
						{
							updateRendererLabelProperty( itemIndex );
						}
					}
					else
					{
						var n:int = contentGroup.numElements;
						for( itemIndex = 0; itemIndex < n; itemIndex++)
						{
							updateRendererLabelProperty(itemIndex);
						}
					}
				}
				
				_labelFieldOrFunctionChanged = false; 
			}
		}
		
		/**
		 *  @private
		 */
		private function updateRendererLabelProperty(itemIndex:int):void
		{
			// grab the renderer at that index and re-compute it's label property
			var renderer:IItemRenderer = contentGroup.getElementAt( itemIndex ) as IItemRenderer; 
			if( renderer ) renderer.label = itemToLabel( renderer.data ); 
		}
		
		/**
		 *  @private
		 * 
		 *  This method is overridden so we can figure out when someone starts listening
		 *  for property change events.  If no one's listening for them, then we don't 
		 *  listen for them on our contentGroup.
		 */
		override public function addEventListener(
			type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false) : void
		{
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			
			// TODO (rfrishbe): this isn't ideal as we should deal with the useCapture, 
			// priority, and useWeakReference parameters.
			
			// if it's a different type of event or the contentGroup doesn't
			// exist, don't worry about it.  When the contentGroup, 
			// gets created up, we'll check to see whether we need to add this 
			// event listener to the contentGroup.
			
			if (type == RendererExistenceEvent.RENDERER_ADD && contentGroup)
			{
				contentGroup.addEventListener(
					RendererExistenceEvent.RENDERER_ADD, dispatchEvent);
			}
			
			if (type == RendererExistenceEvent.RENDERER_REMOVE && contentGroup)
			{
				contentGroup.addEventListener(
					RendererExistenceEvent.RENDERER_REMOVE, dispatchEvent);
			}
			
			if (type == FlexEvent.VALUE_COMMIT && contentGroup)
			{
				contentGroup.addEventListener(
					FlexEvent.VALUE_COMMIT, dispatchEvent);
			}
			
			if (type == IndexChangeEvent.CHANGE && contentGroup)
			{
				contentGroup.addEventListener(
					IndexChangeEvent.CHANGE, dispatchEvent);
			}
		}
		
		/**
		 *  @private
		 * 
		 *  This method is overridden so we can figure out when someone stops listening
		 *  for property change events.  If no one's listening for them, then we don't 
		 *  listen for them on our contentGroup.
		 */
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false) : void
		{
			super.removeEventListener(type, listener, useCapture);
			
			// if no one's listening to us for this event any more, let's 
			// remove our underlying event listener from the contentGroup.
			if (type == RendererExistenceEvent.RENDERER_ADD && contentGroup)
			{
				if (!hasEventListener(RendererExistenceEvent.RENDERER_ADD))
				{
					contentGroup.removeEventListener(
						RendererExistenceEvent.RENDERER_ADD, dispatchEvent);
				}
			}
			
			if (type == RendererExistenceEvent.RENDERER_REMOVE && contentGroup)
			{
				if (!hasEventListener(RendererExistenceEvent.RENDERER_REMOVE))
				{
					contentGroup.removeEventListener(
						RendererExistenceEvent.RENDERER_REMOVE, dispatchEvent);
				}
			}
			
			if (type == FlexEvent.VALUE_COMMIT && contentGroup)
			{
				if (!hasEventListener(FlexEvent.VALUE_COMMIT))
				{
					contentGroup.removeEventListener(
						FlexEvent.VALUE_COMMIT, dispatchEvent);
				}
			}
			
			if (type == IndexChangeEvent.CHANGE && contentGroup)
			{
				if (!hasEventListener(IndexChangeEvent.CHANGE))
				{
					contentGroup.removeEventListener(
						IndexChangeEvent.CHANGE, dispatchEvent);
				}
			}
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event Listeners.
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function onLayoutEvent( event:Event ):void
		{
			if( hasEventListener( event.type ) ) dispatchEvent( event );
		}
		
		/**
		 *  @private
		 */
		private function onDataProviderCollectionChange( event:CollectionEvent ):void
		{
			// If there is a contentGroup it will take care of adjusting the selection
			if( !contentGroup )
			{
				if( event is CollectionEvent )
				{
					var ce:CollectionEvent = CollectionEvent( event );
					switch( ce.kind )
					{
						case CollectionEventKind.ADD :
						{
							if( ce.location <= selectedIndex ) adjustSelection( selectedIndex + 1 );
							break;
						}
						case CollectionEventKind.REMOVE :
						{
							if( ce.location <= selectedIndex )
							{
								adjustSelection( length ? selectedIndex == 0 ? 0 : selectedIndex - 1 : -1 );
							}
							break;
						}
						case CollectionEventKind.RESET :
						{
							adjustSelection( length ? 0 : -1 );
							break;
						}
						case CollectionEventKind.MOVE :
						{
							if( ce.oldLocation == selectedIndex ) adjustSelection( ce.location );
							break;
						}
					}
				}
			}
			
			if( hasEventListener( event.type ) ) dispatchEvent( event );
		}
	}
}