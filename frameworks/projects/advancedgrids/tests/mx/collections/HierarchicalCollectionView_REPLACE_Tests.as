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

package mx.collections {
    import mx.collections.HierarchicalCollectionView;
    import mx.collections.IList;
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;
    import mx.utils.StringUtil;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertFalse;
    import org.flexunit.asserts.assertNotNull;
    import org.flexunit.asserts.assertNull;
    import org.flexunit.asserts.assertTrue;

    public class HierarchicalCollectionView_REPLACE_Tests {

        private static var _sut:HierarchicalCollectionView;
        private static var _utils:HierarchicalCollectionViewTestUtils = new HierarchicalCollectionViewTestUtils();
        private var _root:IList;
        private static var noItemsInHierarchy:int = NaN;

        [BeforeClass]
        public static function setUpBeforeClass():void
        {
            const hierarchyLines:Array = HIERARCHY_STRING.split("\n");
            for(var i:int = 0; i < hierarchyLines.length; i++)
            {
                if(StringUtil.trim(hierarchyLines[i]))
                    noItemsInHierarchy++;
            }
        }

        [Before]
        public function setUp():void
        {
            _sut = _utils.generateOpenHierarchyFromRootListWithAllNodesMethod(_utils.generateHierarchySourceFromString(HIERARCHY_STRING));
            _root = _utils.getRoot(_sut) as IList;
        }

        [After]
        public function tearDown():void
        {
            _sut = null;
            _root = null;
        }

        [Test]
        public function test_make_sure_we_count_nodes_correctly():void
        {
            //when
            var noChildren:int = 0;
            for(var i:int = 0; i < _root.length; i++)
            {
                noChildren += countAllChildrenOf(_root.getItemAt(i) as DataNode);
            }

            //then
            assertEquals(noItemsInHierarchy, noChildren);
        }

        [Test]
        public function test_make_sure_isDescendantOf_works_correctly():void
        {
            //when
            var region1:DataNode = _root.getItemAt(0) as DataNode;
            var region2:DataNode = _root.getItemAt(1) as DataNode;
            var city2:DataNode = region2.children.getItemAt(1) as DataNode;
            var company2:DataNode = city2.children.getItemAt(1) as DataNode;
            var department2:DataNode = company2.children.getItemAt(1) as DataNode;

            //then
            assertTrue(isDescendantOf(department2, company2));
            assertTrue(isDescendantOf(department2, city2));
            assertTrue(isDescendantOf(department2, region2));
            assertFalse(isDescendantOf(department2, region1));
        }

        [Test]
        public function test_replacing_a_childless_node_does_not_dispatch_REMOVED_collection_event_but_changes_parent_references():void
        {
            function onCollectionChanged(event:CollectionEvent):void
            {
                if(event.kind == CollectionEventKind.REMOVE)
                    removeEvent = event;
                else if(event.kind == CollectionEventKind.REPLACE)
                    replaceEvent = event;
            }

            var removeEvent:CollectionEvent = null;
            var replaceEvent:CollectionEvent = null;

            //GIVEN
            _sut.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChanged);
            var company2:DataNode = getDirectChildrenOf(1, 1).getItemAt(1) as DataNode;
            var departmentsOfCompany2:IList = company2.children;
            var firstDepartment:DataNode = departmentsOfCompany2.getItemAt(0) as DataNode;

            //WHEN
            const newDepartment:DataNode = new DataNode("Region(2)->City(1)->Company(2)->DepartmentX");
            departmentsOfCompany2.setItemAt(newDepartment, 0);

            //THEN
            assertNotNull(replaceEvent);
            assertNull(removeEvent); //because the replaced node had no children
            assertNull(_sut.getParentItem(firstDepartment));
            assertEquals(company2, _sut.getParentItem(newDepartment));
            assertEquals(noItemsInHierarchy, _sut.length);
        }

        [Test]
        public function test_replacing_a_node_with_children_dispatches_REMOVED_collection_event_and_changes_parent_references():void
        {
            function onCollectionChanged(event:CollectionEvent):void
            {
                if(event.kind == CollectionEventKind.REMOVE)
                {
                    removeEvent = event;

                    if(event.items && event.items.length == noChildrenOfSecondDepartment)
                    {
                        for(var i:int = 0; i < noChildrenOfSecondDepartment; i++)
                        {
                            if(event.items.indexOf(secondDepartment.children.getItemAt(i)) == -1)
                                REMOVEDEventHasChildrenOfSecondDepartment = false;
                        }
                    }
                }
                else if(event.kind == CollectionEventKind.REPLACE)
                    replaceEvent = event;
            }

            var removeEvent:CollectionEvent = null;
            var replaceEvent:CollectionEvent = null;
            var REMOVEDEventHasChildrenOfSecondDepartment:Boolean = true;

            //GIVEN
            _sut.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChanged);
            var company2:DataNode = getDirectChildrenOf(1, 1).getItemAt(1) as DataNode;
            var departmentsOfCompany2:IList = company2.children;
            var secondDepartment:DataNode = departmentsOfCompany2.getItemAt(1) as DataNode;
            const noChildrenOfSecondDepartment:int = secondDepartment.children.length;

            //WHEN
            const newDepartment:DataNode = new DataNode("Region(2)->City(1)->Company(2)->DepartmentX");
            departmentsOfCompany2.setItemAt(newDepartment, 1);

            //THEN
            assertNotNull(replaceEvent);
            assertNotNull(removeEvent); //because the replaced node had children
            assertTrue(REMOVEDEventHasChildrenOfSecondDepartment);
            assertEquals(-1, removeEvent.items.indexOf(secondDepartment));
            assertNull(_sut.getParentItem(secondDepartment));
            assertEquals(company2, _sut.getParentItem(newDepartment));
            assertEquals(noItemsInHierarchy - noChildrenOfSecondDepartment, _sut.length);
        }

        [Test]
        public function test_replacing_a_root_node_with_children_dispatches_REMOVED_collection_event_and_changes_parent_references():void
        {
            function onCollectionChanged(event:CollectionEvent):void
            {
                if(event.kind == CollectionEventKind.REMOVE)
                {
                    removeEvent = event;
                    if(event.items && event.items.length == noChildrenOfSecondRegion)
                    {
                        for(var i:int = 0; i < noChildrenOfSecondRegion; i++)
                        {
                            if(!isDescendantOf(event.items[1] as DataNode, region2))
                                REMOVEDEventHasAllChildrenOfSecondRegion = false;
                        }
                    }
                }
                else if(event.kind == CollectionEventKind.REPLACE)
                    replaceEvent = event;
            }

            var removeEvent:CollectionEvent = null;
            var replaceEvent:CollectionEvent = null;
            var REMOVEDEventHasAllChildrenOfSecondRegion:Boolean = true;

            //GIVEN
            _sut.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChanged);
            var region2:DataNode = _root.getItemAt(1) as DataNode;
            var noChildrenOfSecondRegion:int = countAllChildrenOf(region2);

            //WHEN
            const newRegion:DataNode = new DataNode("Region(X)");
            _root.setItemAt(newRegion, 1);

            //THEN
            assertNotNull(replaceEvent);
            assertNotNull(removeEvent); //because the replaced node had children
            assertTrue(REMOVEDEventHasAllChildrenOfSecondRegion);
            assertEquals(-1, removeEvent.items.indexOf(region2));
            assertNull(_sut.getParentItem(region2));
            assertEquals(null, _sut.getParentItem(newRegion));
            assertEquals(noItemsInHierarchy - noChildrenOfSecondRegion + 1, _sut.length);
        }

        [Test]
        public function test_replacing_inaccessible_node_does_not_dispatch_REMOVED_collection_event_nor_changes_parent_references():void
        {
            function onCollectionChanged(event:CollectionEvent):void
            {
                if(event.kind == CollectionEventKind.REMOVE)
                    removeEvent = event;
                else if(event.kind == CollectionEventKind.REPLACE)
                    replaceEvent = event;
            }

            var removeEvent:CollectionEvent = null;
            var replaceEvent:CollectionEvent = null;

            //GIVEN
            _sut.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChanged);
            var company2:DataNode = getDirectChildrenOf(1, 1).getItemAt(1) as DataNode;
            var departmentsOfCompany2:IList = company2.children;
            var firstDepartment:DataNode = departmentsOfCompany2.getItemAt(0) as DataNode;

            //WHEN
            _sut.closeNode(_root.getItemAt(1)); //close second region
            const newDepartment:DataNode = new DataNode("Region(2)->City(1)->Company(2)->DepartmentX");
            departmentsOfCompany2.setItemAt(newDepartment, 0);

            //THEN
            assertNotNull(replaceEvent);
            assertNull(removeEvent); //because the replaced node had no children
            assertNull(_sut.getParentItem(firstDepartment));
            assertEquals(company2, _sut.getParentItem(newDepartment));

            var secondRegion:DataNode = DataNode(_root.getItemAt(1));
            assertEquals(noItemsInHierarchy - countAllChildrenOf(secondRegion) + 1, _sut.length);
        }


        private function getDirectChildrenOf(...indexesOfSubsequentParents):IList
        {
            var currentLevel:IList = _root;
            var i:int = -1;
            while(currentLevel && ++i < indexesOfSubsequentParents.length)
            {
                var currentParent:DataNode = currentLevel.getItemAt(indexesOfSubsequentParents[i]) as DataNode;
                currentLevel = currentParent ? currentParent.children : null;
            }

            return currentLevel;
        }

        private function isDescendantOf(node:DataNode, potentialAncestor:DataNode):Boolean
        {
            if(!potentialAncestor || !node)
                return false;

            var currentParent:DataNode = node.parent;
            while(currentParent && currentParent != potentialAncestor)
            {
                currentParent = currentParent.parent;
            }

            return currentParent == potentialAncestor;
        }

        private function countAllChildrenOf(parent:DataNode):int
        {
            if(!parent.children || !parent.children.length)
                return 1;
            else
            {
                var noChildren:int = 0;
                for(var i:int = 0; i < parent.children.length; i++)
                {
                    noChildren += countAllChildrenOf(parent.children.getItemAt(i) as DataNode);
                }

                return noChildren + 1;
            }

            return NaN;
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
    ]]>).
        toString();
    }
}
