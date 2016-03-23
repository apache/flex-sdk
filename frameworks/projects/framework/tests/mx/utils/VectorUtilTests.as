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
    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertStrictlyEquals;
    import org.flexunit.asserts.assertTrue;

    public class VectorUtilTests {

        //--------------------------------------------------------------------------
        //
        //  getFirstItem()
        //
        //--------------------------------------------------------------------------
        [Test]
        public function test_empty_vector():void
        {
            assertEquals(-1, VectorUtil.getFirstItem(new Vector.<int>()));
        }

        [Test]
        public function test_null_parameter():void
        {
            assertEquals(-1, VectorUtil.getFirstItem(null));
        }

        [Test]
        public function test_vector_with_three_elements():void
        {
            //given
            var vector:Vector.<int> = new Vector.<int>();

            //when
            vector.push(3, 2, 1);

            //then
            assertEquals(3, VectorUtil.getFirstItem(vector));
        }

        [Test]
        public function test_vector_with_three_elements_using_global_constructor():void
        {
            //given
            var vector:Vector.<int> = new <int>[35, 25, 15];

            //then
            assertEquals(35, VectorUtil.getFirstItem(vector));
        }

        [Test]
        public function test_vector_with_first_element_minus_1():void
        {
            //given
            var vector:Vector.<int> = new <int>[-1, 2, 1];

            //then
            assertEquals(-1, VectorUtil.getFirstItem(vector));
        }

        [Test]
        public function test_null_and_undefined_transformed_into_0():void
        {
            //given
            var vector:Vector.<int> = new <int>[undefined, null, 11];

            //then
            assertStrictlyEquals(0, vector[0]);
            assertStrictlyEquals(0, vector[1]);
            assertEquals(0, VectorUtil.getFirstItem(vector));
        }

        [Test]
        public function test_non_integers_floored():void
        {
            //given
            var vector:Vector.<int> = new Vector.<int>();

            //when
            vector.push(3.74, 2.5);

            //then
            assertStrictlyEquals(3, vector[0]);
            assertStrictlyEquals(2, vector[1]);
            assertEquals(3, VectorUtil.getFirstItem(vector));
        }


        //--------------------------------------------------------------------------
        //
        //  toArrayInt()
        //
        //--------------------------------------------------------------------------
        [Test]
        public function test_toArrayInt_with_different_items():void
        {
            //given
            var vector:Vector.<int> = new <int>[1, 2, 3];

            //then
            assertTrue(ArrayUtil.arraysMatch([1, 2, 3], VectorUtil.toArrayInt(vector)));
        }

        [Test]
        public function test_toArrayInt_with_duplicate_items():void
        {
            //given
            var vector:Vector.<int> = new <int>[2, 2, 3, 1];

            //then
            assertTrue(ArrayUtil.arraysMatch([2, 2, 3, 1], VectorUtil.toArrayInt(vector)));
        }

        [Test]
        public function test_toArrayInt_with_0_items():void
        {
            //given
            var vector:Vector.<int> = new <int>[];

            //when
            var result:Array = VectorUtil.toArrayInt(vector);

            //then
            assertEquals(0, result.length);
        }

        [Test]
        public function test_toArrayInt_with_null():void
        {
            //when
            var result:Array = VectorUtil.toArrayInt(null);

            //then
            assertEquals(0, result.length);
        }
    }
}
