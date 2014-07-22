package
{
	import flash.events.UncaughtErrorEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.CursorBookmark;
	import mx.collections.HierarchicalCollectionView;
	import mx.collections.HierarchicalCollectionViewCursor;
	import mx.collections.IViewCursor;
	import mx.core.FlexGlobals;
	
	import spark.components.WindowedApplication;
	
	import flexunit.framework.AssertionFailedError;
	
	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.runners.Parameterized;

    /**
     * README
     *
     * -This unit test was initially created to test FLEX-34119, and ended up uncovering FLEX-34424 as well.
     * -This test builds a hierarchical collection from a string (see HIERARCHY_STRING), so that it's easy
     * to edit and change it for specific scenarios.
     * -This test uses utility functions from HierarchicalCollectionViewTestUtils, and data objects from DataNode.
     * -Running the test takes about 3min on my machine. It will vary on yours, of course, but it shouldn't
     * be wildly different.
     * -To speed it up you can decrease the size of the hierarchical collection by editing HIERARCHY_STRING.
     */
	[RunWith("org.flexunit.runners.Parameterized")]
	public class HierarchicalCollectionViewCursor_FLEX_34119_Test
	{
        private static const OP_ADD:int = 0;
        private static const OP_REMOVE:int = 1;
        private static const OP_SET:int = 2;
        private static const OPERATIONS:Array = [OP_ADD, OP_REMOVE, OP_SET];
        private static var _generatedHierarchy:HierarchicalCollectionView;
        private static var _utils:HierarchicalCollectionViewTestUtils = new HierarchicalCollectionViewTestUtils();
        public static var positionAndOperation:Array = [];

	    {
	        _generatedHierarchy = _utils.generateOpenHierarchyFromRootList(_utils.generateHierarchySourceFromString(HIERARCHY_STRING));
	        NO_ITEMS_IN_HIERARCHY = _generatedHierarchy.length;
	
	        private static var SELECTED_INDEX:int = 0;
	        private static var OPERATION_LOCATION:int = 0;
	        private static var OPERATION_INDEX:int = 0;
	        for(SELECTED_INDEX = 0; SELECTED_INDEX < NO_ITEMS_IN_HIERARCHY; SELECTED_INDEX++)
		        for(OPERATION_LOCATION = SELECTED_INDEX -1; OPERATION_LOCATION >= 0; OPERATION_LOCATION--)
		            for(OPERATION_INDEX = 0; OPERATION_INDEX < OPERATIONS.length; OPERATION_INDEX++)
		                positionAndOperation.push([SELECTED_INDEX, OPERATION_LOCATION, OPERATIONS[OPERATION_INDEX]]);
	    }

        private static var NO_ITEMS_IN_HIERARCHY:int = NaN;
        private static var _noErrorsThrown:Boolean = true;
		private static var _operationPerformedInLastStep:Boolean = false;
        private static var _currentHierarchy:HierarchicalCollectionView;
        private static var _sut:HierarchicalCollectionViewCursor;
        private static var _operationCursor:HierarchicalCollectionViewCursor;
		private static var _mirrorCursor:IViewCursor;

        private static var foo:Parameterized;

		[BeforeClass]
		public static function setUpBeforeClass():void
		{
            (FlexGlobals.topLevelApplication as WindowedApplication).loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtClientError);
        }
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
			(FlexGlobals.topLevelApplication as WindowedApplication).loaderInfo.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtClientError);
		}
		
		[Before]
		public function setUp():void
		{
			if(_operationPerformedInLastStep || !_currentHierarchy)
			{
				_operationPerformedInLastStep = false;
				
				_currentHierarchy = _utils.clone(_generatedHierarchy);
				_utils.openAllNodes(_currentHierarchy);
				_sut = _currentHierarchy.createCursor() as HierarchicalCollectionViewCursor;
			}
		}
		
		[After]
		public function tearDown():void
		{
			if(_operationPerformedInLastStep)
			{
				_sut = null;
				_currentHierarchy = null;
			}
			
			_operationCursor = null;
			_mirrorCursor = null;
		}

		[Test]
		public function reproduce_FLEX_34119_WithADDSimple():void
		{
			//given
			var _level0:ArrayCollection = _utils.getRoot(_currentHierarchy) as ArrayCollection;
			
			var secondRegion:DataNode = _level0.getItemAt(1) as DataNode;
			var firstCity:DataNode = secondRegion.children.getItemAt(0) as DataNode;
			var secondCompany:DataNode = firstCity.children.getItemAt(1) as DataNode;
			
			//when
			_sut.seek(new CursorBookmark(4)); //Region(2)->City(1)->Company(2)
			secondRegion.children.addItemAt(_utils.createSimpleNode("City [INS]"), 0); //RTE should be thrown here
			
			//then
			assertEquals(secondCompany, _sut.current);
			assertTrue(_noErrorsThrown);
		}
		
       	[Test(dataProvider="positionAndOperation")]
        public function testReproduce_FLEX_34119_Comprehensive(selectedItemIndex:int, operationIndex:int, operation:int):void
        {
			assertThat(operationIndex < selectedItemIndex);
			
            try {
				//WHEN
				//1. Select a random node
				_sut.seek(new CursorBookmark(selectedItemIndex));
				
                var selectedNode:DataNode = DataNode(_sut.current);
                assertNotNull(selectedNode);

                //2. Make sure FLEX-34119 can be reproduced with the current indexes
               if(!isFLEX_34119_Reproducible(operationIndex, selectedNode, operation))
			   {
				   //trace("can't reproduce " + operation + "; " + operationIndex + "; " + selectedNode);
				   return;
			   }
			   
			   selectedNode.isSelected = true;

                //3. Perform operation
                if (operation == OP_ADD)
                    testAddition(_operationCursor);
                else if (operation == OP_REMOVE)
                    testRemoval(_operationCursor);

                //THEN 1
                assertTrue(_noErrorsThrown);

				
				
                //4. Create mirror HierarchicalCollectionView from the changed root, as the source of truth
                _mirrorCursor = _utils.navigateToItem(_currentHierarchy.createCursor() as HierarchicalCollectionViewCursor, selectedNode);

                //5. Navigate somewhere in both HierarchicalCollectionViews and make sure they do the same thing
                _sut.moveNext();
                _mirrorCursor.moveNext();

                //THEN 2
                assertEquals(_mirrorCursor.current, _sut.current);
            }
            catch(error:AssertionFailedError)
            {
                trace("FAIL ("+selectedItemIndex + "," + operationIndex + "," + operation + "): " + error.message);
                _utils.printHCollectionView(_currentHierarchy);
                throw(error);
            }
        }
		
		private function isFLEX_34119_Reproducible(where:int, selectedNode:DataNode, operation:int):Boolean
		{
			var hasParent:Boolean = _currentHierarchy.getParentItem(selectedNode) != null;
			if(!hasParent)
				return false;
	
			_operationCursor = _currentHierarchy.createCursor() as HierarchicalCollectionViewCursor;
			_operationCursor.seek(new CursorBookmark(where));
			var itemToPerformOperationOn:DataNode = _operationCursor.current as DataNode;
			
			switch(operation)
			{
				case OP_ADD:
					return _utils.nodesHaveCommonAncestor(itemToPerformOperationOn, selectedNode, _currentHierarchy);
				case OP_REMOVE:
					return !_utils.isAncestor(itemToPerformOperationOn, selectedNode, _currentHierarchy);
				case OP_SET:
					return false;
				default:
					return false;
			}
		}
	
	    private function testRemoval(where:HierarchicalCollectionViewCursor):void
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
			//trace("REM: sel=" + selectedNode + "; before=" + itemToDelete);
			_operationPerformedInLastStep = true;
	        collectionToChange.removeItem(itemToDelete);
	    }


        /**
         * @return true when the where parameter designates an item on the root collection (last ancestor of modified node)
         */
        private function testAddition(where:HierarchicalCollectionViewCursor):void
        {
            var itemBeforeWhichWereAdding:DataNode = where.current as DataNode;
            assertNotNull(itemBeforeWhichWereAdding);

            var parentOfAdditionLocation:DataNode = _currentHierarchy.getParentItem(itemBeforeWhichWereAdding) as DataNode;
            var collectionToChange:ArrayCollection = parentOfAdditionLocation ? parentOfAdditionLocation.children : _utils.getRoot(_currentHierarchy) as ArrayCollection;
            var positionOfItemBeforeWhichWereAdding:int = collectionToChange.getItemIndex(itemBeforeWhichWereAdding);

			_operationPerformedInLastStep = true;
            collectionToChange.addItemAt(_utils.createSimpleNode(itemBeforeWhichWereAdding.label + " [INSERTED NODE]"), positionOfItemBeforeWhichWereAdding);
			//trace("ADD: sel=" + selectedNode + "; before=" + itemBeforeWhichWereAdding);
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
         Region(2)->City(1)->Company(2)->Department(1)
         Region(2)->City(1)->Company(2)->Department(1)->Employee(1)
         Region(2)->City(1)->Company(2)->Department(1)->Employee(2)
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
         Region(2)->City(1)->Company(3)->Department(2)->Employee(1)
         Region(2)->City(1)->Company(3)->Department(2)->Employee(2)
         Region(2)->City(1)->Company(3)->Department(3)
         Region(2)->City(1)->Company(3)->Department(3)->Employee(1)
         Region(2)->City(1)->Company(3)->Department(3)->Employee(2)
         Region(2)->City(1)->Company(3)->Department(3)->Employee(3)
         Region(2)->City(1)->Company(3)->Department(3)->Employee(4)
         Region(2)->City(1)->Company(3)->Department(3)->Employee(5)
         Region(2)->City(1)->Company(3)->Department(4)
         Region(2)->City(1)->Company(3)->Department(4)->Employee(1)
         Region(2)->City(1)->Company(3)->Department(4)->Employee(2)
         Region(2)->City(1)->Company(3)->Department(4)->Employee(3)
         Region(2)->City(1)->Company(3)->Department(4)->Employee(4)
         Region(2)->City(1)->Company(4)
         Region(2)->City(1)->Company(4)->Department(1)
         Region(2)->City(1)->Company(4)->Department(1)->Employee(1)
         Region(2)->City(1)->Company(4)->Department(1)->Employee(2)
         Region(2)->City(1)->Company(4)->Department(1)->Employee(3)
         Region(3)
         Region(3)->City(1)
         Region(3)->City(1)->Company(1)
         Region(3)->City(1)->Company(1)->Department(1)
         Region(3)->City(1)->Company(1)->Department(1)->Employee(1)
         Region(3)->City(1)->Company(1)->Department(1)->Employee(2)
         Region(3)->City(1)->Company(1)->Department(1)->Employee(3)
         Region(3)->City(1)->Company(1)->Department(1)->Employee(4)
         Region(3)->City(1)->Company(1)->Department(2)
         Region(3)->City(1)->Company(1)->Department(2)->Employee(1)
         Region(3)->City(1)->Company(1)->Department(2)->Employee(2)
         Region(3)->City(1)->Company(1)->Department(2)->Employee(3)
         Region(3)->City(1)->Company(1)->Department(3)
         Region(3)->City(1)->Company(1)->Department(3)->Employee(1)
         Region(3)->City(1)->Company(1)->Department(3)->Employee(2)
         Region(3)->City(1)->Company(1)->Department(3)->Employee(3)
         Region(3)->City(1)->Company(2)
         Region(3)->City(1)->Company(2)->Department(1)
         Region(3)->City(1)->Company(2)->Department(1)->Employee(1)
         Region(3)->City(1)->Company(2)->Department(2)
         Region(3)->City(1)->Company(2)->Department(2)->Employee(1)
         Region(3)->City(1)->Company(2)->Department(2)->Employee(2)
         Region(3)->City(1)->Company(2)->Department(3)
         Region(3)->City(1)->Company(2)->Department(4)
         Region(3)->City(1)->Company(3)
         Region(3)->City(1)->Company(4)
         Region(3)->City(1)->Company(4)->Department(1)
         Region(3)->City(1)->Company(4)->Department(1)->Employee(1)
         Region(3)->City(1)->Company(4)->Department(1)->Employee(2)
         Region(3)->City(1)->Company(4)->Department(1)->Employee(3)
         Region(3)->City(1)->Company(4)->Department(1)->Employee(4)
         Region(3)->City(1)->Company(4)->Department(2)
         Region(3)->City(1)->Company(4)->Department(2)->Employee(1)
         Region(3)->City(1)->Company(4)->Department(2)->Employee(2)
         Region(3)->City(1)->Company(4)->Department(2)->Employee(3)
         Region(3)->City(1)->Company(4)->Department(3)
         Region(3)->City(1)->Company(5)
         Region(3)->City(2)
         Region(3)->City(3)
         Region(3)->City(4)
         Region(3)->City(4)->Company(1)
         Region(4)
         Region(4)->City(1)
         Region(4)->City(1)->Company(1)
       ]]>).toString();
	}
}