package mx.collections
{
import flash.events.UncaughtErrorEvent;

import mx.collections.ArrayCollection;
import mx.collections.CursorBookmark;
import mx.collections.HierarchicalCollectionView;
import mx.collections.HierarchicalCollectionViewCursor;
import mx.core.FlexGlobals;

    import org.flexunit.asserts.assertEquals;

    import org.flexunit.asserts.assertNotNull;
import org.flexunit.asserts.assertTrue;
import org.flexunit.runners.Parameterized;

import spark.components.WindowedApplication;

public class HierarchicalCollectionViewCursor_FLEX_34458_Test
	{
        private static var _utils:HierarchicalCollectionViewTestUtils = new HierarchicalCollectionViewTestUtils();
        private static var _noErrorsThrown:Boolean = true;
        private static var _currentHierarchy:HierarchicalCollectionView;
        private static var _sut:HierarchicalCollectionViewCursor;
        private static var _operationCursor:HierarchicalCollectionViewCursor;

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