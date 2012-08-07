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
package assets {

import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.getTimer;

import mx.collections.*;
import mx.collections.errors.ItemPendingError;
import mx.events.*;
import mx.rpc.IResponder;

/**
 * This class implements a collection which simulates item pending errors.
 * It extends ArrayList and initially populates the entire list with valid items of
 * the given class.  It maintains a parallel
 * array of values, one for each with one element in the actual list.
 * <p>
 * When getItemAt is called,
 * if the item is available we just call super.getItemAt to retrieve the data.  If it is
 * not available and this is the first attempt made to access this page, we thrown
 * an ItemPendingError and set up a timer for the DELAY interval (i.e. the time we are
 * simulating for when this item is available).  When that timer function
 * runs, it marks the item and other items in its "page" as paged in
 * by copying the original data into the parallel data,
 * dispatches a collection event to tell any UI components
 * that the item at the corresponding location has been replaced then calls the
 * responders for any ItemPendingError that has been thrown for that page.
 * <p>
 * It does not currently handle adding/removing from the list, but does
 * simulate adding a pending item to the list.
 */
public class ItemPendingErrorSimulator extends ArrayList
{

	/**
	 *  IPE's are resolved in order, but in a random amount of time
	 */
	public static const MODE_RANDOM:String = "random";

	/**
	 *  IPE's are resolved in order, at the responseDelay interval
	 */
	public static const MODE_FIXED:String = "fixed";

	/**
	 *  IPE's are resolved in order by calling receivePage()
	 */
	public static const MODE_MANUAL:String = "manual";

	private static const NOT_SET:int = -8000;

	/**
	 *  The mode to use when resolving IPE's
	 */
	public var mode:String = ItemPendingErrorSimulator.MODE_RANDOM;

	/**
	 *  A function that creates the objects.  This gets called
	 *  numItems times when you call reset();
	 */
	public var objectFactory:Function = makeDefaultObject;

	/**
	 *  The delay before resolving an IPE if you use MODE_FIXED
	 */
	public var responseDelay:int = 3000;

	/**
	 *  The number of items in the array (length of collection)
	 */
	public var numItems:int = 100;

	/**
	 *  The number of pages already paged in at reset()
	 */
	public var numPreloadedPages:int = 5;

	/**
	 *  The number of items in a page
	 */
	public var pageSize:int = 2;

	/**
	 *  TRUE if trace output tracks the IPE requests and resolutions
	 *  @default FALSE
	 */
	public var tracing:Boolean = false;

	/**
	 *  TRUE if using dynamic sizing.
	 *  @default FALSE
	 */
	public var dynamicSizing:Boolean = false;

	/**
	 *  Probability that a request (a page of them really) will fail.  If 0.0
	 *  all requests will succeed, if 1.0, they will all fail.
	 *  @default 0.0
	 */
	public var failureProbability:Number = 0.0;

	/**
	 *  Default function that makes a basic label & data object
	 */
	private function makeDefaultObject(i:int):Object
	{
		return { label: "v" + i, data: "x" + i };
	}

	/**
	 *  This is the data structure which gets populated with pre-paged
	 *  data, IPEs, and errors.
	 */
	private var items:Array;

	/**
	 *  The initial value for elements of the items array.
	 */
	private static const NO_ITEM:Object = { toString: function():String {return "NO_ITEM";} };

	/**
	 *  This is an array of PageRequests which need servicing.
	 **/
	private var pendingRequests:Array = [];

	private var eventsDisabled:Boolean = false;

	/**
	 *  If true, then addItem(), addItemAt(), setItemAt(), and the 'get length' methods
	 *  will throw an IPE after queueing a task in pendingChangesQueue.  To run the
	 *  queued tasks call flushPendingChanges().
	 *
	 *  The mx.data DataList class implements the IList interface but does not comply with
	 *  the documented semantics.   This flag enables testing the DataList version of the
	 *  aforementioned IList methods.
	 *
	 *  @default false;
	 */
	public var dataListCompatibility:Boolean = false;

	private const pendingChangesQueue:Array = [];


	override public function dispatchEvent(event:Event):Boolean
	{
		if (eventsDisabled) return true;

		return super.dispatchEvent(event);
	}

	/**
	 *  If a page request for exactly one item at the specified index exists, then
	 *  resolve it by firing the responders.
	 **/
	public function receiveItem(index:int):void
	{
		var pageRequest:PageRequest = null
		for each (var pr:PageRequest in pendingRequests)
		if ((pr.startIndex == index) && (pr.endIndex == index))
		{
			pageRequest = pr;
			break;
		}

		if (!pageRequest)
			return;

		pendingRequests.splice(pendingRequests.indexOf(pageRequest), 1);
		items[index] = super.getItemAt(index);
		dispatchCollectionEvent(CollectionEventKind.REPLACE, items[index], index);

		for each (var ipe:ItemPendingError in pageRequest.ipes)
		for each (var responder:IResponder in ipe.responders)
		responder.result(null);
	}

	public function receivePage(te:TimerEvent = null):void
	{
		if (tracing)
			trace("receivePage");

		if (pendingRequests.length == 0)
		{
			if (tracing)
				trace("No page requests pending");
			return;
		}

		var pageRequest:PageRequest = pendingRequests.shift();
		if (tracing)
			trace("Items: " + pageRequest.startIndex + " through " + pageRequest.endIndex + " received");

		var failThisPage:Boolean = Math.random() > (1.0 - failureProbability);
		if (failThisPage)
		{
			for each (var ipe:ItemPendingError in pageRequest.ipes)
			for each (var responder:IResponder in ipe.responders)
			responder.fault(null);
			return;
		}

		if (dynamicSizing)
		{
			// grow the array by a page
			var index:int = source.length - 1;
			var newItems:Array = [];
			numItems += pageSize;
			for (i = source.length; i < numItems; i++)
			{
				source[i] = objectFactory(i);
				items[i] = source[i];
				newItems.push(null);
			}
			// last item will generate another IPE
			items[i - 1] = NO_ITEM;
			var ce:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
			ce.kind = CollectionEventKind.ADD;
			ce.location = index;
			ce.items = newItems;
			dispatchEvent(ce);
		}

		for (var i:int = pageRequest.startIndex; i <= pageRequest.endIndex; i++)
		{
			items[i] = super.getItemAt(i);
			dispatchCollectionEvent(CollectionEventKind.REPLACE, items[i], i);
		}

		if (failThisPage)
			return;

		var ipes:Array = pageRequest.ipes;
		for (var j:int = 0; j < ipes.length; j++)
		{
			if (ipes[j].responders)
			{
				for (var k:int = 0; k < ipes[j].responders.length; k++)
					ipes[j].responders[k].result(null);
			}
		}
	}

	/**
	 *  If a page request for exactly one item at the specified index exists, then
	 *  fail it by firing the responders.
	 **/
	public function failItem(index:int):void
	{
		var pageRequest:PageRequest = null
		for each (var pr:PageRequest in pendingRequests)
		if ((pr.startIndex == index) && (pr.endIndex == index))
		{
			pageRequest = pr;
			break;
		}

		if (!pageRequest)
			return;

		pendingRequests.splice(pendingRequests.indexOf(pageRequest), 1);

		for each (var ipe:ItemPendingError in pageRequest.ipes)
		for each (var responder:IResponder in ipe.responders)
		responder.fault(null);

		items[index] = super.getItemAt(index);
	}

	public function failPage():void
	{
		if (pendingRequests.length == 0)
		{
			if (tracing)
				trace("No page requests pending");
			return;
		}

		var pageRequest:PageRequest = pendingRequests.shift();
		if (tracing)
			trace("Items: " + pageRequest.startIndex + " through " + pageRequest.endIndex + " received");

		for each (var ipe:ItemPendingError in pageRequest.ipes)
		for each (var responder:IResponder in ipe.responders)
		responder.fault(null);

		for (var i:int = pageRequest.startIndex; i <= pageRequest.endIndex; i++)
		{
			items[i] = super.getItemAt(i);
			//dispatchCollectionEvent(CollectionEventKind.REPLACE, items[i], i);
		}
	}

	public function addPendingItemAt(item:Object, index:int):void
	{
		// silently add the item w/o notifications
		source.splice(index, 0, item);
		eventsDisabled = true;
		source = source;
		eventsDisabled = false;

		// insert NO_ITEM in local copy
		items.splice(index, 0, NO_ITEM);

		var n:int = pendingRequests.length;
		for (var i:int = 0; i < n; i++)
		{
			if (pendingRequests[i].startIndex >= index)
				pendingRequests[i].startIndex++;
			if (pendingRequests[i].endIndex >= index)
				pendingRequests[i].endIndex++;
		}

		var event:CollectionEvent =
			new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
		event.kind = CollectionEventKind.ADD;
		event.items.push(null);
		event.location = index;
		dispatchEvent(event);
	}

	public function ItemPendingErrorSimulator()
	{
		super();
	}

	/**
	 *   Replace the parent ArrayList's source array with a fresh set of items.
	 *   Replace the items array with a number of preloaded items.
	 **/
	public function reset():void
	{
		var arr:Array = [];

		if (dynamicSizing)
			numItems = pageSize + 1;

		for (var i:int = 0; i < numItems; i++)
			arr.push(objectFactory(i));

		source = arr;

		items = new Array(arr.length);
		for (i = 0; i < items.length; i++)
			items[i] = NO_ITEM;

		for (i = 0; i < numPreloadedPages * pageSize; i++)
			items[i] = arr[i];
	}

	public function dispatchCollectionEvent(kind:String, item:Object, location:int):void
	{
		if (kind == CollectionEventKind.REPLACE)
		{
			var objEvent:PropertyChangeEvent =
				new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
			objEvent.property = location;
			objEvent.newValue = item;
			objEvent.oldValue = null;

			var event:CollectionEvent =
				new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
			event.kind = kind;
			event.items.push(objEvent);
			event.location = location;
			dispatchEvent(event);
		}
	}

	/**
	 *	RV: Added the dispatching of an event if given a prefetch
	 *	paramter != 0.  This way, we can test that prefetch was
	 *	passed to the simulator in mustella.  e.g.: If prefetch
	 *	is 3, the event type is "simulatorPrefetchEvent_3."
	 **/
	override public function getItemAt(index:int, prefetch:int=0):Object
	{
		var pageRequest:PageRequest;
		var ipe:ItemPendingError;
		var s:String;
		var timer:Timer;
		var delay:int = -1;

		if (prefetch != 0)
			dispatchEvent(new Event("simulatorPrefetchEvent_" + prefetch.toString()));

		if (items[index] != NO_ITEM)
			return items[index];

		var pendingRequest:PageRequest;

		var n:int = pendingRequests.length;
		for (var i:int = 0; i < n; i++)
		{
			if (pendingRequests[i].startIndex <= index &&
				pendingRequests[i].endIndex >= index)
			{
				pendingRequest = pendingRequests[i];
				break;
			}
		}

		if (!pendingRequest)
		{
			for (i = 1; i < pageSize; i++)
			{
				if (index + i >= length)
					break;
				if (items[index + i] != NO_ITEM)
					break;
			}
			i--;

			for (var j:int = 0; j < n; j++)
			{
				if (pendingRequests[j].startIndex > index && pendingRequests[j].startIndex <= (index + i))
				{
					i = pendingRequests[j].startIndex - index - 1;
				}
			}

			if (mode == MODE_FIXED)
			{
				s = "Items: " + index + " through " + (index + i) + " will be resolved in " + responseDelay + " millis"
				ipe = new ItemPendingError(s);
				if (tracing)
					trace(s);

				timer = new Timer(responseDelay, 1);
				timer.addEventListener("timer", receivePage);
				timer.start();

				pageRequest = new PageRequest();
				pageRequest.startIndex = index;
				pageRequest.endIndex = index + i;
				pageRequest.startTime = getTimer();
				pageRequest.endTime = pageRequest.startTime + responseDelay;
				// Stash the IPE in the request.
				pageRequest.ipes = [ipe];

				pendingRequests.push(pageRequest);

				throw ipe;
			}
			else if (mode == MODE_RANDOM)
			{
				delay = Math.round(Math.random() * 1000);
				/* This makes no sense
				if (pendingRequests.length)
				delay += pendingRequests[pendingRequests.length - 1].endTime;
				*/

				s = "Items: " + index + " through " + (index + i) + " will be resolved in " + delay + " millis";
				ipe = new ItemPendingError(s);
				if (tracing)
					trace(s);

				timer = new Timer(delay, 1);
				timer.addEventListener("timer", receivePage);
				timer.start();

				pageRequest = new PageRequest();
				pageRequest.startIndex = index;
				pageRequest.endIndex = index + i;
				pageRequest.startTime = getTimer();
				pageRequest.endTime = pageRequest.startTime + delay;
				// Stash the IPE in the request.
				pageRequest.ipes = [ipe];
				pendingRequests.push(pageRequest);

				throw ipe;
			}
			else
			{
				s = "Items: " + index + " through " + (index + i) + " must be resolved by calling receivePage";
				ipe = new ItemPendingError(s);
				if (tracing)
					trace(s);

				pageRequest = new PageRequest();
				pageRequest.startIndex = index;
				pageRequest.endIndex = index + i;
				pageRequest.startTime = getTimer();
				pageRequest.endTime = NOT_SET;
				// Stash the IPE in the request.
				pageRequest.ipes = [ipe];
				pendingRequests.push(pageRequest);

				throw ipe;
			}
		}
		else
		{
			if (pendingRequest.endTime == NOT_SET)
				delay = NOT_SET;
			else
				delay = pendingRequest.endTime - getTimer();
			if (delay == NOT_SET)
				s = "Items: " + pendingRequest.startIndex + " through " + pendingRequest.endIndex + " already requested.  Must be resolved by calling receivePage"
			else if (delay < 0)
				s = "Items: " + pendingRequest.startIndex + " through " + pendingRequest.endIndex + " already requested.  Will be resolved in this frame."
			else
				s = "Items: " + pendingRequest.startIndex + " through " + pendingRequest.endIndex + " already requested.  Will be resolved in " + delay + " millis"
			ipe = new ItemPendingError(s);
			if (tracing)
				trace(s);

			pendingRequest.ipes.push(ipe);

			throw ipe;
		}
		return null;
	}

	/**
	 *  Rudimentary support for testing addItem(), addItemAt(), setItemAt(), and 'get length' in
	 *  when dataListCompatibility=true.  Calling this method causes the tasks queued by
	 *  the three IList mutation methods to run, in the order they were queued (called).
	 *  It also sets queueGetLengthRequest=false so that 'get length' will return the actual
	 *  list length.
	 */
    public function flushPendingChanges():void
	{
		const oldDataListCompatibility:Boolean = dataListCompatibility;
		dataListCompatibility = false;  // ArrayList.addItem() calls addItemAt()
		queueGetLengthRequest = false;		
		for each (var task:Function in pendingChangesQueue)
			task();
		pendingChangesQueue.length = 0;
		dataListCompatibility = oldDataListCompatibility;		
	}


	private function superAddItemAt(item:Object, index:int):void
	{
		super.addItemAt(item, index);
	}

	override public function addItemAt(item:Object, index:int):void
	{
		items.splice(index, 0, item);

		for each (var pr:PageRequest in pendingRequests)
		{
			if (pr.startIndex >= index)
				pr.startIndex += 1;
			if (pr.endIndex >= index)
				pr.endIndex = Math.min(items.length - 1, pr.endIndex + 1);
		}

		if (dataListCompatibility)
		{
			const task:Function = function():void { superAddItemAt(item, index); };
			pendingChangesQueue.push(task);
			throw new ItemPendingError("addItemAt() queued");
		}
		else
			super.addItemAt(item, index);
	}

	private function superAddItem(item:Object):void
	{
		super.addItem(item);
	}

	override public function addItem(item:Object):void
	{
		items.push(item);

		if (dataListCompatibility)
		{
			const task:Function = function():void { superAddItem(item); };
			pendingChangesQueue.push(task);
			throw new ItemPendingError("addItem() queued");
		}
		else
			super.addItem(item);
	}

	private function superSetItemAt(item:Object, index:int):void
	{
		super.setItemAt(item, index);
	}

	override public function setItemAt(item:Object, index:int):Object
	{
		var oldItem:Object = (items[index] === NO_ITEM) ? null : items[index];
		items[index] = item;

		if (dataListCompatibility)
		{
			const task:Function = function():void { superSetItemAt(item, index); };
			pendingChangesQueue.push(task);
			throw new ItemPendingError("setItemAt() queued");
		}
		else
			super.setItemAt(item, index);

		return oldItem;
	}

	private var queueGetLengthRequest:Boolean = true;  // see flushPendingChanges

	override public function get length():int
	{
		if (dataListCompatibility && queueGetLengthRequest)
			throw new ItemPendingError("get length queued");
		else
			return super.length;
	}

	override public function removeItemAt(index:int):Object
	{

		var pendingRequest:PageRequest;
		var n:int = pendingRequests.length;
		for (var i:int = n - 1; i >= 0; i--)
		{
			var r:PageRequest = pendingRequests[i];
			if ((index == r.startIndex) && (r.startIndex == r.endIndex))
				pendingRequests.splice(index, 1);
			else
			{
				if (r.startIndex >= index)
					r.startIndex = Math.max(0, r.startIndex - 1);
				if (r.endIndex >= index) r.endIndex -= 1;
			}
		}

		var ipe:ItemPendingError = null;
		if (items[index] === NO_ITEM)
			ipe = new ItemPendingError("no item at index=" + index);
		items.splice(index, 1);

		const item:Object = super.removeItemAt(index);
		if (ipe)
			throw ipe;
		return item;
	}

}
}

class PageRequest
{
	public var startIndex:int;
	public var endIndex:int;
	public var startTime:int;
	public var endTime:int;
	public var ipes:Array;
}

