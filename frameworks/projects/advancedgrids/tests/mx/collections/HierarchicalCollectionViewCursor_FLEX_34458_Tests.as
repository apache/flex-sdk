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

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertNotNull;
    import org.flexunit.asserts.assertTrue;

    import spark.components.Application;

    public class HierarchicalCollectionViewCursor_FLEX_34458_Tests
	{
        private static var _utils:HierarchicalCollectionViewTestUtils = new HierarchicalCollectionViewTestUtils();
        private static var _noErrorsThrown:Boolean = true;
        private static var _currentHierarchy:HierarchicalCollectionView;
        private static var _sut:HierarchicalCollectionViewCursor;
        private static var _operationCursor:HierarchicalCollectionViewCursor;

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

       	[Test]
        public function testReproduce_FLEX_34458():void
        {
			//WHEN
			//1. Select a specific node
			_sut.moveToLast();
            _sut.movePrevious(); //Region(2)->City(3), with currentChildBookmark == CursorBookmark.LAST
			
            var selectedNode:DataNode = DataNode(_sut.current);
            assertNotNull(selectedNode);
		    selectedNode.isSelected = true;

            //2. Remove previous region
            _operationCursor = _currentHierarchy.createCursor() as HierarchicalCollectionViewCursor;
            _operationCursor.seek(CursorBookmark.FIRST, 3); //Region(2)->City(1)
            performRemoval(_operationCursor);

            //THEN
            assertTrue(_noErrorsThrown);
            assertEquals(selectedNode, _sut.current);
        }


        private static function performRemoval(where:HierarchicalCollectionViewCursor):void
        {
            var itemToBeRemoved:DataNode = where.current as DataNode;
            assertNotNull(itemToBeRemoved);

            var parentOfReplacementLocation:DataNode = _currentHierarchy.getParentItem(itemToBeRemoved) as DataNode;
            var collectionToChange:ArrayCollection = parentOfReplacementLocation ? parentOfReplacementLocation.children : _utils.getRoot(_currentHierarchy) as ArrayCollection;
            var removedItemIndex:int = collectionToChange.getItemIndex(itemToBeRemoved);
            collectionToChange.removeItemAt(removedItemIndex);
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
         Region(2)->City(2)
         Region(2)->City(3)
         Region(3)
       ]]>).toString();
	}
}