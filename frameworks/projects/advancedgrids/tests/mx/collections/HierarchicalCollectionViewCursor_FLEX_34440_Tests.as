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

    import org.flexunit.asserts.assertNotNull;
    import org.flexunit.asserts.assertTrue;

    import spark.components.Application;

    public class HierarchicalCollectionViewCursor_FLEX_34440_Tests
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
        public function testReproduce_FLEX_34440():void
        {
			//GIVEN
			var selectedItemIndex:int = 10, operationIndex:int = 5;
			
			//WHEN
			//1. Select a specific node
			_sut.seek(new CursorBookmark(selectedItemIndex));
			
            var selectedNode:DataNode = DataNode(_sut.current);
            assertNotNull(selectedNode);
		    selectedNode.isSelected = true;

            //2. Perform setItemAt operation
			_operationCursor = _currentHierarchy.createCursor() as HierarchicalCollectionViewCursor;
			_operationCursor.seek(new CursorBookmark(operationIndex));
		    performReplacement(_operationCursor);

            //THEN
            assertTrue(_noErrorsThrown);
        }
		
        private static function performReplacement(where:HierarchicalCollectionViewCursor):void
        {
            var itemToBeReplaced:DataNode = where.current as DataNode;
            assertNotNull(itemToBeReplaced);

            var parentOfReplacementLocation:DataNode = _currentHierarchy.getParentItem(itemToBeReplaced) as DataNode;
            var collectionToChange:ArrayCollection = parentOfReplacementLocation ? parentOfReplacementLocation.children : _utils.getRoot(_currentHierarchy) as ArrayCollection;
            var replacedItemIndex:int = collectionToChange.getItemIndex(itemToBeReplaced);

            collectionToChange.setItemAt(_utils.createSimpleNode(itemToBeReplaced.label + " [REPLACED NODE]"), replacedItemIndex);
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
         Region(2)->City(1)->Company(2)TBR
         Region(2)->City(1)->Company(2)TBR->Department(1)
         Region(2)->City(1)->Company(2)TBR->Department(2)
         Region(2)->City(1)->Company(2)TBR->Department(2)->Employee(1)
         Region(2)->City(1)->Company(2)TBR->Department(2)->Employee(2)
         Region(2)->City(1)->Company(2)TBR->Department(2)->Employee(3)SEL
         Region(2)->City(1)->Company(2)TBR->Department(3)
         Region(2)->City(1)->Company(2)TBR->Department(3)->Employee(1)
         Region(2)->City(1)->Company(2)TBR->Department(3)->Employee(2)
         Region(2)->City(1)->Company(2)TBR->Department(3)->Employee(3)
         Region(2)->City(1)->Company(2)TBR->Department(3)->Employee(4)
         Region(2)->City(1)->Company(3)
         Region(2)->City(1)->Company(3)->Department(1)
         Region(2)->City(1)->Company(3)->Department(1)->Employee(1)
         Region(2)->City(1)->Company(3)->Department(2)
       ]]>).toString();
	}
}