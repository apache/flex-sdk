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

package mx.utils {
    import flash.utils.Dictionary;

    import org.flexunit.asserts.assertEquals;

    import org.flexunit.asserts.assertFalse;
    import org.flexunit.asserts.assertTrue;

    public class ObjectUtil_Tests
    {
        //--------------------------------------------------------------------------
        //
        //  isDynamicObject()
        //
        //--------------------------------------------------------------------------

        [Test]
        public function test_dynamic_class_instance_recognized_as_dynamic_object():void
        {
            //then
            assertTrue(ObjectUtil.isDynamicObject(new DynamicVO("John")));
        }

        [Test]
        public function test_anonymous_class_instance_recognized_as_dynamic_object():void
        {
            //then
            assertTrue(ObjectUtil.isDynamicObject({name:"John"}));
        }

        [Test]
        public function test_array_instance_recognized_as_dynamic_object():void
        {
            //then
            assertTrue(ObjectUtil.isDynamicObject([]));
        }

        [Test]
        public function test_dictionary_instance_recognized_as_dynamic_object():void
        {
            //then
            assertTrue(ObjectUtil.isDynamicObject(new Dictionary()));
        }

        [Test]
        public function test_sealed_class_instance_recognized_as_non_dynamic_object():void
        {
            //then
            assertFalse(ObjectUtil.isDynamicObject(new NonDynamicVO("John")));
        }

        [Test]
        public function test_null_does_not_throw_fatal():void
        {
            //then
            assertFalse(ObjectUtil.isDynamicObject(null));
        }

        //--------------------------------------------------------------------------
        //
        //  getEnumerableProperties()
        //
        //--------------------------------------------------------------------------

        [Test]
        public function test_enumerable_properties_of_anonymous_object():void
        {
            //given
            var object:Object = {name:"John", age:32};

            //when
            var enumerableProperties:Array = ObjectUtil.getEnumerableProperties(object);

            //then
            assertTrue(ArrayUtil.arrayValuesMatch(["age", "name"], enumerableProperties));
        }

        [Test]
        public function test_enumerable_properties_of_null():void
        {
            //when
            var enumerableProperties:Array = ObjectUtil.getEnumerableProperties(null);

            //then
            assertEquals(0, enumerableProperties.length);
        }

        [Test]
        public function test_enumerable_properties_of_dictionary():void
        {
            //given
            var object:Dictionary = new Dictionary(false);
            object["name"] = "John";
            object["age"] = 9;

            //when
            var enumerableProperties:Array = ObjectUtil.getEnumerableProperties(object);

            //then
            assertTrue(ArrayUtil.arrayValuesMatch(["age", "name"], enumerableProperties));
        }

        [Test]
        public function test_enumerable_properties_of_dynamic_class_instance():void
        {
            //given
            var object:DynamicVO = new DynamicVO("John");
            object["age"] = 9;

            //when
            var enumerableProperties:Array = ObjectUtil.getEnumerableProperties(object);

            //then
            assertTrue(ArrayUtil.arrayValuesMatch(["age", "name"], enumerableProperties));
        }

        [Test]
        public function test_enumerable_properties_of_associative_array():void
        {
            //given
            var object:Array = [];
            object["age"] = 9;
            object["name"] = "John";

            //when
            var enumerableProperties:Array = ObjectUtil.getEnumerableProperties(object);

            //then
            assertTrue(ArrayUtil.arrayValuesMatch(["age", "name"], enumerableProperties));
        }

        [Test]
        public function test_enumerable_properties_of_indexed_array():void
        {
            //given
            var object:Array = [9, "John"];

            //when
            var enumerableProperties:Array = ObjectUtil.getEnumerableProperties(object);

            //then
            assertTrue(ArrayUtil.arrayValuesMatch([0, 1], enumerableProperties));
        }

        [Test]
        public function test_enumerable_properties_of_manually_indexed_array():void
        {
            //given
            var object:Array = [];
            object[3] = 9;
            object[5] = "John";

            //when
            var enumerableProperties:Array = ObjectUtil.getEnumerableProperties(object);

            //then
            assertTrue(ArrayUtil.arrayValuesMatch([3, 5], enumerableProperties));
        }

        [Test]
        public function test_enumerable_properties_of_sealed_class_instance():void
        {
            //given
            var object:Object = new NonDynamicVO("John");

            //when
            var enumerableProperties:Array = ObjectUtil.getEnumerableProperties(object);

            //then
            assertEquals(0, enumerableProperties.length);
        }
    }
}

dynamic class DynamicVO
{
    public function DynamicVO(name:String)
    {
        this.name = name;
    }
}

class NonDynamicVO
{
    public var name:String;

    public function NonDynamicVO(name:String)
    {
        this.name = name;
    }
}