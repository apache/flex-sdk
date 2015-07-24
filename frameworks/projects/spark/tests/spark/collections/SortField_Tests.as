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

package spark.collections {
    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertFalse;

    import spark.collections.SortField;

    public class SortField_Tests {
        private var _sut:SortField;

        [Test]
        public function fix_mustella_failure_due_to_FLEX_34852():void
        {
            //given
            _sut = new SortField("someField");

            //when
            const emptyObject:Object = {};
            var emptyObjectHasASortField:Boolean = _sut.objectHasSortField(emptyObject);

            //then
            assertFalse(emptyObjectHasASortField);
        }

        [Test]
        public function locale_setting_and_retrieving_work():void
        {
            //given
            _sut = new SortField("someField");

            //when
            _sut.setStyle("locale", "ru-RU");

            //then
            assertEquals("ru-RU", _sut.getStyle("locale"));
        }
    }
}
