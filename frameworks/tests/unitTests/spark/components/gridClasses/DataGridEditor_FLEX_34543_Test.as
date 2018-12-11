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

package spark.components.gridClasses {
    import mx.collections.ArrayCollection;
    import mx.collections.ArrayList;
    import mx.core.ClassFactory;
    import mx.core.mx_internal;
    import mx.managers.FocusManager;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertNotNull;
    import org.fluint.uiImpersonation.UIImpersonator;

    import spark.components.DataGrid;
    import spark.events.GridItemEditorEvent;

    public class DataGridEditor_FLEX_34543_Test
    {
        private var _dp:ArrayCollection;
        private var _dg:DataGrid;
        private var _sut:DataGridEditor;
        private var _saveEvent:GridItemEditorEvent;

        [Before]
        public function setUp():void
        {
            _dp = new ArrayCollection([new FLEX_34543_DataNode("First"), new FLEX_34543_DataNode("Second")]);

            _dg = new DataGrid();
            _dg.editable = true;
            _dg.dataProvider = _dp;

            var nameColumn:GridColumn = new GridColumn();
            nameColumn.dataField = "name";
            nameColumn.itemEditor = new ClassFactory(DefaultGridItemEditor);
            nameColumn.editable = true;
            _dg.columns = new ArrayList([nameColumn]);

            UIImpersonator.addChild(_dg);
            _dg.focusManager = new FocusManager(_dg, false);

            _sut = _dg.mx_internal::editor;
        }

        [After]
        public function tearDown():void
        {
            _dg.removeEventListener(GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_SAVE, onGridEditorSave);
            UIImpersonator.removeAllChildren();
            _dg = null;
            _dp = null;
            _saveEvent = null;
            _sut = null;
        }

        [Test]
        public function testEndItemEditorSessionEventContainsCorrectIndex():void
        {
            //given
            _dg.addEventListener(GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_SAVE, onGridEditorSave);
            _dg.startItemEditorSession(1,0);

            //when
            _dp.removeItemAt(0);
            _dg.endItemEditorSession();

            //then
            assertNotNull(_saveEvent);
            assertEquals(0, _saveEvent.rowIndex);
        }

        private function onGridEditorSave(event:GridItemEditorEvent):void
        {
            _saveEvent = event;
        }
    }
}

class FLEX_34543_DataNode
{
    public var name:String;

    public function FLEX_34543_DataNode(name:String)
    {
        this.name = name;
    }
}