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
    import org.flexunit.runners.Parameterized;

    import spark.components.Application;

    [RunWith("org.flexunit.runners.Parameterized")]
	public class HierarchicalCollectionViewCursor_FLEX_34456_Tests
	{
        public static var positionAndOperation:Array = [[11, 5, 0], [11, 5, 1]];
		
        private static const OP_ADD:int = 0;
        private static const OP_REMOVE:int = 1;
        private static var _generatedHierarchy:HierarchicalCollectionView;
        private static var _utils:HierarchicalCollectionViewTestUtils = new HierarchicalCollectionViewTestUtils();
        private static var _noErrorsThrown:Boolean = true;
        private static var _currentHierarchy:HierarchicalCollectionView;
        private static var _sut:HierarchicalCollectionViewCursor;
        private static var _operationCursor:HierarchicalCollectionViewCursor;
		private static var _mirrorCursor:HierarchicalCollectionViewCursor;

        private static var foo:Parameterized;

		[BeforeClass]
		public static function setUpBeforeClass():void
		{
			_generatedHierarchy = _utils.generateOpenHierarchyFromRootList(_utils.generateHierarchySourceFromString(HIERARCHY_STRING));
            if(FlexGlobals.topLevelApplication is Application)
                (FlexGlobals.topLevelApplication as Application).loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtClientError);
        }
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
            if(FlexGlobals.topLevelApplication is Application)
                (FlexGlobals.topLevelApplication as Application).loaderInfo.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtClientError);
			_generatedHierarchy = null;
			_utils = null;
		}
		
		[Before]
		public function setUp():void
		{
			_currentHierarchy = _utils.clone(_generatedHierarchy);
			_utils.openAllNodes(_currentHierarchy);
			_sut = _currentHierarchy.createCursor() as HierarchicalCollectionViewCursor;
		}
		
		[After]
		public function tearDown():void
		{
			_sut = null;
			_currentHierarchy = null;
			_operationCursor = null;
			_mirrorCursor = null;
		}


		[Test(dataProvider="positionAndOperation")]
        public function testReproduce_FLEX_34119_Comprehensive(selectedItemIndex:int, operationIndex:int, operation:int):void
        {
			//WHEN
			//1. Select a random node
			_sut.seek(new CursorBookmark(selectedItemIndex));
			
            var selectedNode:DataNode = DataNode(_sut.current);
            assertNotNull(selectedNode);

		   selectedNode.isSelected = true;
		   
            //2. Perform operation
		   _operationCursor = _currentHierarchy.createCursor() as HierarchicalCollectionViewCursor;
		   _operationCursor.seek(new CursorBookmark(operationIndex));
		   
            if (operation == OP_ADD)
                testAddition(_operationCursor);
            else if (operation == OP_REMOVE)
                testRemoval(_operationCursor, selectedNode);

            //THEN 1
            assertTrue(_noErrorsThrown);

            //3. Create mirror HierarchicalCollectionView from the changed root, as the source of truth
            _mirrorCursor = _utils.navigateToItem(_currentHierarchy.createCursor() as HierarchicalCollectionViewCursor, selectedNode) as HierarchicalCollectionViewCursor;

            //4. Navigate somewhere in both HierarchicalCollectionViews and make sure they do the same thing
            _sut.moveNext();
            _mirrorCursor.moveNext();

            //THEN 2
            assertEquals(_mirrorCursor.current, _sut.current);
        }
		
	
	    private function testRemoval(where:HierarchicalCollectionViewCursor, selectedNode:DataNode):void
	    {
	        var itemToDelete:DataNode = where.current as DataNode;
	        assertNotNull(itemToDelete);

	        //mark the next item, so we know which item disappeared
			where.moveNext();
	        var nextItem:DataNode = where.current as DataNode;
	        if (nextItem)
	            nextItem.isPreviousSiblingRemoved = true;
	
			//remove the item
	        var parentOfItemToRemove:DataNode = _currentHierarchy.getParentItem(itemToDelete) as DataNode;
	        var collectionToChange:ArrayCollection = parentOfItemToRemove ? parentOfItemToRemove.children : _utils.getRoot(_currentHierarchy) as ArrayCollection;
			
	        collectionToChange.removeItem(itemToDelete);
	    }


        private function testAddition(where:HierarchicalCollectionViewCursor):void
        {
            var itemBeforeWhichWereAdding:DataNode = where.current as DataNode;
            assertNotNull(itemBeforeWhichWereAdding);

            var parentOfAdditionLocation:DataNode = _currentHierarchy.getParentItem(itemBeforeWhichWereAdding) as DataNode;
            var collectionToChange:ArrayCollection = parentOfAdditionLocation ? parentOfAdditionLocation.children : _utils.getRoot(_currentHierarchy) as ArrayCollection;
            var positionOfItemBeforeWhichWereAdding:int = collectionToChange.getItemIndex(itemBeforeWhichWereAdding);

			collectionToChange.addItemAt(_utils.createSimpleNode(itemBeforeWhichWereAdding.label + " [INSERTED NODE]"), positionOfItemBeforeWhichWereAdding);
        }


		
		
		private static function onUncaughtClientError(event:UncaughtErrorEvent):void
		{
			event.preventDefault();
			event.stopImmediatePropagation();
			_noErrorsThrown = false;
			
			trace("\n" + event.error);
			_utils.printHCollectionView(_currentHierarchy);
		}


        private static const HIERARCHY_STRING:String = (<![CDATA[
         Region(1)
         Region(2)
         Region(2)->City(1)
         Region(2)->City(1)->Company(1)
         Region(2)->City(1)->Company(2)
         Region(2)->City(1)->Company(2)->Department(1)[REM]
         Region(2)->City(1)->Company(2)->Department(1)[REM]->Employee(1)
         Region(2)->City(1)->Company(2)->Department(1)[REM]->Employee(2)
         Region(2)->City(1)->Company(2)->Department(2)
         Region(2)->City(1)->Company(2)->Department(2)->Employee(1)
         Region(2)->City(1)->Company(2)->Department(2)->Employee(2)
         Region(2)->City(1)->Company(2)->Department(2)->Employee(3)[SEL]
         Region(2)->City(1)->Company(2)->Department(3)
         Region(2)->City(1)->Company(2)->Department(3)->Employee(1)
         Region(2)->City(1)->Company(3)
       ]]>).toString();
	}
}