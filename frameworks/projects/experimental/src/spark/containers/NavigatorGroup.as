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
package spark.containers
{
	import flash.events.Event;
	
	import mx.core.ISelectableList;
	import mx.core.IVisualElement;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	
	import spark.events.IndexChangeEvent;
	import spark.layouts.supportClasses.LayoutBase;
	
	import spark.containers.supportClazzes.DeferredCreationPolicy;
	import spark.layouts.StackLayout;
	import spark.layouts.supportClasses.AnimationNavigatorLayoutBase;
	import spark.layouts.supportClasses.INavigatorLayout;
	

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
	 *  The NavigatorGroup class is the base container for navigating all visual elements.
	 * 
	 *  The NavigatorGroup container takes as children any components that implement 
 	 *  the IUIComponent interface, and any components that implement 
	 *  the IGraphicElement interface. 
 	 *  Use this container when you want to navigate between visual children, 
 	 *  both visual elements and graphical elements.
	 *  
	 *  <p>The layout for a NavigatorGroup must implement INavigatorLayout.</p>
	 *
	 *  <p>To improve performance and minimize application size, 
	 *  the NavigatorGroup container cannot be skinned. 
	 *  If you want to apply a skin, use the Navigator instead.</p>
	 * 
	 *  <p>The NavigatorGroup container has the following default characteristics:</p>
 	 *  <table class="innertable">
	 *     <tr><th>Characteristic</th><th>Description</th></tr>
	 *     <tr><td>Default size</td><td>Large enough to display its children</td></tr>
	 *     <tr><td>Minimum size</td><td>0 pixels</td></tr>
	 *     <tr><td>Maximum size</td><td>10000 pixels wide and 10000 pixels high</td></tr>
	 *  </table>
	 *
	 *  @mxml <p>The <code>&lt;st:NavigatorGroup&gt;</code> tag inherits all of the tag 
	 *  attributes of its superclass and adds the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;st:NavigatorGroup
	 *
	 *    <strong>Properties</strong>
	 *    selectedIndex="-1"
	 *    selectedItem="undefined"
	 *    length="0"
	 * 
	 *    <strong>Events</strong>
	 *    change="<i>No default</i>"
	 *    collectionChange="<i>No default</i>"
	 *  /&gt;
	 *  </pre>
	 *  
	 *  @see spark.containers.Navigator
	 *  @see spark.layouts.supportClasses.INavigatorLayout
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public class NavigatorGroup extends DeferredGroup implements ISelectableList
	{
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor. 
		 *  Initializes the <code>creationPolicy</code> property to "construct". 
		 * 
		 *  @see #creationPolicy
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */  
		public function NavigatorGroup()
		{
			super();
			
			creationPolicy = DeferredCreationPolicy.CONSTRUCT;
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  selectedIndex
		//---------------------------------- 
		
		/**
		 *  @private
		 *  Storage property for selectedIndex.
		 */
		private var _selectedIndex		: int = -1;
		
		[Bindable("change")]
		[Bindable("valueCommit")]
		
		/**
		 *  The index of the currently selected item IList item.
		 *  Setting this property deselects the currently selected 
		 *  index and selects the newly specified item.
		 *  
		 *  @default -1
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function set selectedIndex( value:int ):void
		{
			if( _selectedIndex == value ) return;
			
			_selectedIndex = value;
			
			if( layout ) INavigatorLayout( layout ).selectedIndex = _selectedIndex;
		}
		/**
		 *  @private
		 */
		public function get selectedIndex():int
		{
			return ( layout ) ? INavigatorLayout( layout ).selectedIndex : _selectedIndex;
		}
		
		
		//----------------------------------
		//  selectedItem
		//---------------------------------- 
		
		[Bindable("change")]
		[Bindable("valueCommit")]
		
		/**
		 *  The item that is currently selected. 
		 *  Setting this property deselects the currently selected 
		 *  item and selects the newly specified item.
		 *
		 *  @default undefined
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get selectedItem():IVisualElement
		{
			var index:int = selectedIndex;
			return index != -1 ? getElementAt( index ) : null;
		}
		/**
		 *  @private
		 */
		public function set selectedItem( value:IVisualElement ):void
		{
			var index:int = getElementIndex( value );
			if( index != -1 ) selectedIndex = index;
		}
		
		
		//----------------------------------
		//  length
		//---------------------------------- 
		
		/**
		 *  The number of items in this collection. 
		 *  0 means no items while -1 means the length is unknown. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get length():int
		{
			return numElements;
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  layout
		//----------------------------------    
		/**
		 *  @private
		 */
		override public function set layout( value:LayoutBase ):void
		{
			if( layout == value ) return;
			
			if( value is INavigatorLayout )
			{
				removeLayoutListeners();
				super.layout = value;
				INavigatorLayout( value ).selectedIndex = _selectedIndex;
				addLayoutListeners();
			}
			else
			{
				throw new Error( "Layout must implement INavigatorLayout" );
			}
			
		}
		
		
		//----------------------------------
		//  mxmlContent
		//----------------------------------  
		
		/**
		 *  @private
		 */
		override public function set mxmlContent( value:Array ):void
		{
			super.mxmlContent = value;
			
			adjustSelection( length ? 0 : -1 );
			
			dispatchEvent( new CollectionEvent( CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.RESET, -1, -1, toArray() ) );
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Adds the specified item to the end of the list.
		 *  Equivalent to <code>addItemAt(item, length)</code>.
		 *
		 *  @param item The item to add.
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
		 *  Adds the item at the specified index.  
		 *  The index of any item greater than the index of the added item is increased by one.  
		 *  If the the specified index is less than zero or greater than the length
		 *  of the list, a RangeError is thrown.
		 * 
		 *  @param item The item to place at the index.
		 *
		 *  @param index The index at which to place the item.
		 *
		 *  @throws RangeError if index is less than 0 or greater than the length of the list. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function addItemAt( item:Object, index:int ):void
		{
			addElementAt( item as IVisualElement, index );
		}
		
		/**
		 *  Gets the item at the specified index.
		 * 
		 *  @param index The index in the list from which to retrieve the item.
		 *
		 *  @param prefetch An <code>int</code> indicating both the direction
		 *  and number of items to fetch during the request if the item is
		 *  not local.
		 *
		 *  @return The item at that index, or <code>null</code> if there is none.
		 *
		 *  @throws mx.collections.errors.ItemPendingError if the data for that index needs to be 
		 *  loaded from a remote location.
		 *
		 *  @throws RangeError if <code>index &lt; 0</code>
		 *  or <code>index >= length</code>.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function getItemAt( index:int, prefetch:int = 0 ):Object
		{
			return  _mxmlContent[ index ];
		}
		
		/**
		 *  Returns the index of the item if it is in the list such that
		 *  getItemAt(index) == item.
		 * 
		 *  <p>Note: unlike <code>IViewCursor.find<i>xxx</i>()</code> methods,
		 *  The <code>getItemIndex()</code> method cannot take a parameter with 
		 *  only a subset of the fields in the item being serched for; 
		 *  this method always searches for an item that exactly matches
		 *  the input parameter.</p>
		 * 
		 *  @param item The item to find.
		 *
		 *  @return The index of the item, or -1 if the item is not in the list.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function getItemIndex( item:Object ):int
		{
			return getElementIndex( IVisualElement( item ) );
		}
		
		/**
		 *  Notifies the view that an item has been updated.  
		 *  This is useful if the contents of the view do not implement 
		 *  <code>IEventDispatcher</code> and dispatches a 
		 *  <code>PropertyChangeEvent</code>.  
		 *  If a property is specified the view may be able to optimize its 
		 *  notification mechanism.
		 *  Otherwise it may choose to simply refresh the whole view.
		 *
		 *  @param item The item within the view that was updated.
		 *
		 *  @param property The name of the property that was updated.
		 *
		 *  @param oldValue The old value of that property. (If property was null,
		 *  this can be the old value of the item.)
		 *
		 *  @param newValue The new value of that property. (If property was null,
		 *  there's no need to specify this as the item is assumed to be
		 *  the new value.)
		 *
		 *  @see mx.events.CollectionEvent
		 *  @see mx.events.PropertyChangeEvent
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function itemUpdated( item:Object, property:Object=null, oldValue:Object=null, newValue:Object=null ):void
		{
			var event:PropertyChangeEvent = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
			
			event.kind = PropertyChangeEventKind.UPDATE;
			event.source = item;
			event.property = property;
			event.oldValue = oldValue;
			event.newValue = newValue;
			
			internalDispatchEvent( CollectionEventKind.UPDATE, event );
			
			// need to dispatch object event now
			if( hasEventListener( PropertyChangeEvent.PROPERTY_CHANGE ) )
			{
				var objEvent:PropertyChangeEvent = PropertyChangeEvent( event.clone() );
				var index:uint = getItemIndex(event.target);
				objEvent.property = index.toString() + "." + event.property;
				dispatchEvent(objEvent);
			}
		}
		
		/** 
		 *  Removes all items from the list.
		 *
		 *  <p>If any item is not local and an asynchronous operation must be
		 *  performed, an <code>ItemPendingError</code> will be thrown.</p>
		 *
		 *  <p>See the ItemPendingError documentation as well as
		 *  the collections documentation for more information
		 *   on using the <code>ItemPendingError</code>.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function removeAll():void
		{
			removeAllElements();
		}
		
		/**
		 *  Removes the specified item from the list.
		 *
		 *  @param the item to remove.
		 *
		 *  @return boolean true if the item was removed
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4.10
		 */
		public function removeItem( item:Object ):Boolean
		{
			var element:IVisualElement = removeElement(item as IVisualElement);
			return element != null;
		}
		
		/**
		 *  Removes the item at the specified index and returns it.  
		 *  Any items that were after this index are now one index earlier.
		 *
		 *  @param index The index from which to remove the item.
		 *
		 *  @return The item that was removed.
		 *
		 *  @throws RangeError is index is less than 0 or greater than length. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function removeItemAt( index:int ):Object
		{
			return removeElementAt( index );
		}
		
		/**
		 *  Places the item at the specified index.  
		 *  If an item was already at that index the new item will replace it
		 *  and it will be returned.
		 *
		 *  @param item The new item to be placed at the specified index.
		 *
		 *  @param index The index at which to place the item.
		 *
		 *  @return The item that was replaced, or <code>null</code> if none.
		 *
		 *  @throws RangeError if index is less than 0 or greater than length.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function setItemAt( item:Object, index:int ):Object
		{
			var result:Object = removeElementAt( index );
			addElementAt( item as IVisualElement,index );
			
			if( hasEventListener( CollectionEvent.COLLECTION_CHANGE ) )
			{
				var propertyChangeEvent:PropertyChangeEvent = new PropertyChangeEvent( PropertyChangeEvent.PROPERTY_CHANGE );
				propertyChangeEvent.kind = PropertyChangeEventKind.UPDATE;
				propertyChangeEvent.oldValue = result;
				propertyChangeEvent.newValue = item;
				propertyChangeEvent.property = index;
					
				internalDispatchEvent( CollectionEventKind.REPLACE, propertyChangeEvent, index );
			}
			
			return result;
		}
		
		/**
		 *  Returns an Array that is populated in the same order as the IList
		 *  implementation.
		 *  This method can throw an ItemPendingError.
		 *
		 *  @return The array.
		 *  
		 *  @throws mx.collections.errors.ItemPendingError If the data is not yet completely loaded
		 *  from a remote location.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */ 
		public function toArray():Array
		{
			return _mxmlContent;
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
			layout.addEventListener( IndexChangeEvent.CHANGE, onBubbleLayoutEvent, false, 0, true );
			layout.addEventListener( FlexEvent.VALUE_COMMIT, onBubbleLayoutEvent, false, 0, true );
		}
		
		/**
		 *  @private
		 */
		private function removeLayoutListeners():void
		{
			if( !layout ) return;
			layout.removeEventListener( IndexChangeEvent.CHANGE, onBubbleLayoutEvent, false );
			layout.removeEventListener( FlexEvent.VALUE_COMMIT, onBubbleLayoutEvent, false );
		}
		
		/**
		 *  @private
		 */
		private function onBubbleLayoutEvent( event:Event ):void
		{
			if( hasEventListener( event.type ) ) dispatchEvent( event );
		}
		
		/**
		 *  Dispatches a collection event with the specified information.
		 *
		 *  @param kind String indicates what the kind property of the event should be
		 *  @param item Object reference to the item that was added or removed
		 *  @param location int indicating where in the source the item was added.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		private function internalDispatchEvent( kind:String, item:Object = null, location:int = -1):void
		{
			switch( kind )
			{
				case CollectionEventKind.ADD :
				{
					if( location <= selectedIndex ) adjustSelection( selectedIndex + 1 );
					break;
				}
				case CollectionEventKind.REMOVE :
				{
					if( location <= selectedIndex ) adjustSelection( length ? selectedIndex == 0 ? 0 : selectedIndex - 1 : -1 );
					break;
				}
				case CollectionEventKind.RESET :
				{
					adjustSelection( length ? 0 : -1 );
					break;
				}
			}
			
			if( hasEventListener( CollectionEvent.COLLECTION_CHANGE ) )
			{
				var event:CollectionEvent = new CollectionEvent( CollectionEvent.COLLECTION_CHANGE );
				event.kind = kind;
				event.items.push( item );
				event.location = location;
				dispatchEvent(event);
			}
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @inheritDoc
		 *  
		 *  <p>If the layout object has not been set yet, 
		 *  createChildren() assigns this container a 
		 *  default layout object, BasicLayout.</p>
		 */ 
		override protected function createChildren():void
		{
			if( !layout ) layout = new StackLayout();
			layout.useVirtualLayout = useVirtualLayout;
			
			if( _selectedIndex != -1 ) INavigatorLayout( layout ).selectedIndex = _selectedIndex;
			super.createChildren();
		}	
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override public function addElementAt( element:IVisualElement, index:int ):IVisualElement
		{
			super.addElementAt( element, index );
			internalDispatchEvent( CollectionEventKind.ADD, element, index );
			return element;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override public function removeAllElements():void
		{
			super.removeAllElements();
			internalDispatchEvent( CollectionEventKind.RESET );
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override public function removeElementAt(index:int):IVisualElement
		{
			var removed:IVisualElement = super.removeElementAt( index );
			internalDispatchEvent( CollectionEventKind.REMOVE, removed, index );
			return removed;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override public function swapElementsAt( index1:int, index2:int ):void
		{
			super.swapElementsAt( index1, index2 );
			
			if( hasEventListener( CollectionEvent.COLLECTION_CHANGE ) )
			{
				dispatchEvent( new CollectionEvent( CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.MOVE, index1, index2, [ getElementAt( index1 ) ] ) );
				dispatchEvent( new CollectionEvent( CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.MOVE, index2, index1, [ getElementAt( index2 ) ] ) );
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
		override public function setElementIndex( element:IVisualElement, index:int ):void
		{
			const oldIndex:int = hasEventListener( CollectionEvent.COLLECTION_CHANGE ) ? getElementIndex( element ) : -1;
			
			super.setElementIndex( element, index );
			
			if( oldIndex != -1 )
			{
				var i:int;
				var loops:int;
				var direction:int;
				if( oldIndex < index )
				{
					i = oldIndex;
					loops = index;
					for( i; i < loops; i++ )
					{
						dispatchEvent( new CollectionEvent( CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.MOVE, i, i + 1, [ getElementAt( i ) ] ) );
					}
					dispatchEvent( new CollectionEvent( CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.MOVE, index, oldIndex, [ element ] ) );
				}
				else
				{
					i = index;
					loops = oldIndex;
					dispatchEvent( new CollectionEvent( CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.MOVE, index, oldIndex, [ element ] ) );
					for( i; i < loops; i++ )
					{
						dispatchEvent( new CollectionEvent( CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.MOVE, i, i - 1, [ getElementAt( i ) ] ) )
					}
				}
			}
		}
	}
}