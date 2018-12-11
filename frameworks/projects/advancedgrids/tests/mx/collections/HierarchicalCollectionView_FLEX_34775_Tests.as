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
    import mx.utils.StringUtil;

    import org.flexunit.asserts.assertEquals;

    public class HierarchicalCollectionView_FLEX_34775_Tests
    {
        private static var _utils:HierarchicalCollectionViewTestUtils = new HierarchicalCollectionViewTestUtils();
        private static var _sut:HierarchicalCollectionView;
        private var _level0:ArrayCollection;

        [Before]
        public function setUp():void
        {
            _sut = generateHierarchyViewWithClosedNodes();
            _level0 = _utils.getRoot(_sut) as ArrayCollection;
        }

        [After]
        public function tearDown():void
        {
            _sut = null;
            _level0 = null;
        }



        [Test]
        public function test_navigation_after_trying_to_open_inaccessible_node():void
        {
            //given
            var company:DataNode = _level0.getItemAt(0) as DataNode;
            var location:DataNode = company.children.getItemAt(0) as DataNode;

            //when
            _sut.openNode(location);

            //then
            var stepsRequiredToNavigateStructure:int = attemptNavigation(_sut);
            assertEquals(1, stepsRequiredToNavigateStructure);
            assertEquals(1, _sut.length);
        }

        [Test]
        public function test_navigation_after_trying_to_open_accessible_node():void
        {
            //given
            var company:DataNode = _level0.getItemAt(0) as DataNode;
            var location:DataNode = company.children.getItemAt(0) as DataNode;

            //when
            _sut.openNode(company);
            _sut.openNode(location);

            //then
            var stepsRequiredToNavigateStructure:int = attemptNavigation(_sut);
            assertEquals(3, stepsRequiredToNavigateStructure);
            assertEquals(3, _sut.length);
        }

        [Test]
        public function test_navigation_after_trying_to_open_previously_closed_node():void
        {
            //given
            var company:DataNode = _level0.getItemAt(0) as DataNode;
            var location:DataNode = company.children.getItemAt(0) as DataNode;

            //when
            _sut.openNode(company);
            _sut.openNode(location);
            _sut.closeNode(location);

            //then
            var stepsRequiredToNavigateStructure:int = attemptNavigation(_sut);
            assertEquals(2, stepsRequiredToNavigateStructure);
            assertEquals(2, _sut.length);
        }

        [Test]
        public function test_navigation_after_trying_to_open_filtered_out_node():void
        {
            function filterOutLocationNode(node:DataNode):Boolean {
                return node && node.label != locationNodeName;
            };

            const locationNodeName:String = StringUtil.trim(HIERARCHY_STRING.split("\n")[2]);

            //given
            var company:DataNode = _level0.getItemAt(0) as DataNode;
            var location:DataNode = company.children.getItemAt(0) as DataNode;
            _sut.openNode(company);
            _sut.openNode(location);

            //when
            _sut.filterFunction = filterOutLocationNode;
            _sut.refresh();

            _sut.openNode(location);

            //then
            var stepsRequiredToNavigateStructure:int = attemptNavigation(_sut);
            assertEquals(1, stepsRequiredToNavigateStructure);
            assertEquals(1, _sut.length);
        }

        private function attemptNavigation(into:HierarchicalCollectionView):int
        {
            var cursor:IViewCursor = into.createCursor();
            var i:int = 0;
            while(!cursor.afterLast && i++ < 100)
            {
                cursor.moveNext();
            }

            return i;
        }

        private static function generateHierarchyViewWithClosedNodes():HierarchicalCollectionView
        {
            return _utils.generateHCV(_utils.generateHierarchySourceFromString(HIERARCHY_STRING));
        }

        private static const HIERARCHY_STRING:String = (<![CDATA[
        Adobe
        Adobe->London
        Adobe->London->FlexDept
    ]]>).toString();
    }
}