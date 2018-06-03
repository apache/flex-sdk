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

package mx.collections
{
    import flash.events.UncaughtErrorEvent;

    import mx.core.FlexGlobals;
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertNotNull;
    import org.flexunit.asserts.assertTrue;
    import org.flexunit.runners.Parameterized;

    import spark.components.Application;

    [RunWith("org.flexunit.runners.Parameterized")]
public class HierarchicalCollectionViewCursor_FLEX_34424_Tests
	{
        private static var _utils:HierarchicalCollectionViewTestUtils = new HierarchicalCollectionViewTestUtils();
        private static var _noErrorsThrown:Boolean = true;
        private static var _currentHierarchy:HierarchicalCollectionView;
        private static var _sut:HierarchicalCollectionViewCursor;
        private static var _operationCursor:HierarchicalCollectionViewCursor;
        public static var selectionAndRemovalLocations:Array = [[10, 8, 1], [11, 7, 1], [11, 6, 2], [19, 17, 1]];

        private static var foo:Parameterized;

		[BeforeClass]
		public static function setUpBeforeClass():void
		{
            if(FlexGlobals.topLevelApplication is Application)
                (FlexGlobals.topLevelApplication as Application).loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtClientError);
        }
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
            if(FlexGlobals.topLevelApplication is Application)
                (FlexGlobals.topLevelApplication as Application).loaderInfo.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtClientError);
		}
		
		[Before]
		public function setUp():void
		{
			_currentHierarchy = _utils.generateOpenHierarchyFromRootListWithAllNodesMethod(_utils.generateHierarchySourceFromString(HIERARCHY_STRING));
			_sut = _currentHierarchy.createCursor() as HierarchicalCollectionViewCursor;
		}
		
		[After]
		public function tearDown():void
		{
			_sut = null;
			_currentHierarchy = null;
			_operationCursor = null;
		}

        [Test(dataProvider="selectionAndRemovalLocations")]
        public function testReproduce_FLEX_34424(selectedItemIndex:int, removalIndex:int, noItemsToRemove:int):void
        {
			//WHEN
			//1. Select a specific node
			_sut.seek(new CursorBookmark(selectedItemIndex));
			
            var selectedNode:DataNode = DataNode(_sut.current);
            assertNotNull(selectedNode);
		    selectedNode.isSelected = true;

            //2. Perform removal
			_operationCursor = _currentHierarchy.createCursor() as HierarchicalCollectionViewCursor;
			_operationCursor.seek(new CursorBookmark(removalIndex));
		    performRemoval(_operationCursor, noItemsToRemove);

            //THEN
            assertTrue(_noErrorsThrown);
            assertEquals(selectedNode, _sut.current);
        }
		
        private static function performRemoval(where:HierarchicalCollectionViewCursor, noItemsToRemove:int):void
        {
            var itemToBeRemoved:DataNode = where.current as DataNode;
            assertNotNull(itemToBeRemoved);

            var parentOfReplacementLocation:DataNode = _currentHierarchy.getParentItem(itemToBeRemoved) as DataNode;
            var collectionToChange:ArrayCollection = parentOfReplacementLocation ? parentOfReplacementLocation.children : _utils.getRoot(_currentHierarchy) as ArrayCollection;
            var removedItemIndex:int = collectionToChange.getItemIndex(itemToBeRemoved);

            if(noItemsToRemove == 1)
                collectionToChange.removeItemAt(removedItemIndex);
            else {//note that this assumes the collection is not filtered or sorted; for this test the assumption holds.
                var removedItems:Array = collectionToChange.source.splice(removedItemIndex, noItemsToRemove);
                //fake a CollectionEventKind.REMOVE event with more than one item removed
                collectionToChange.dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.REMOVE, removedItemIndex, -1, removedItems));
            }
        }



		
		
		private static function onUncaughtClientError(event:UncaughtErrorEvent):void
		{
			event.preventDefault();
			event.stopImmediatePropagation();
			_noErrorsThrown = false;
			
			trace("\n FAIL: " + event.error);
			_utils.printHCollectionView(_currentHierarchy);
		}


        private static const HIERARCHY_STRING:String = (<![CDATA[
         Region(1)
         Region(2)
		 Region(2)->City(0)
         Region(2)->City(1)
         Region(2)->City(1)->Company(1)
         Region(2)->City(1)->Company(2)
         Region(2)->City(1)->Company(2)->Department(1)
         Region(2)->City(1)->Company(2)->Department(2)
         Region(2)->City(1)->Company(2)->Department(2)->Employee(1)
         Region(2)->City(1)->Company(2)->Department(2)->Employee(2)
         Region(2)->City(1)->Company(2)->Department(2)->Employee(3)
         Region(2)->City(1)->Company(2)->Department(3)
         Region(2)->City(1)->Company(2)->Department(3)->Employee(1)
         Region(2)->City(1)->Company(2)->Department(3)->Employee(2)
         Region(2)->City(1)->Company(2)->Department(3)->Employee(3)
         Region(2)->City(1)->Company(2)->Department(3)->Employee(4)
         Region(2)->City(1)->Company(3)
         Region(2)->City(1)->Company(3)->Department(1)
         Region(2)->City(1)->Company(3)->Department(1)->Employee(1)
         Region(2)->City(1)->Company(3)->Department(2)
       ]]>).toString();
	}
}