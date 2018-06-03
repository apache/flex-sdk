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

package mx.utils
{
    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertFalse;
    import org.flexunit.asserts.assertNotNull;
    import org.flexunit.asserts.assertTrue;

    public class ArrayUtil_Tests
    {
        //--------------------------------------------------------------------------
        //
        //  arraysMatch()
        //
        //--------------------------------------------------------------------------

        [Test]
        public function test_array_matches_with_itself():void
        {
            //given
            var array:Array = [1, 2, 3];

            //then
            assertTrue(ArrayUtil.arraysMatch(array, array));
        }

        [Test]
        public function test_empty_arrays_match():void
        {
            //then
            assertTrue(ArrayUtil.arraysMatch([], []));
        }

        [Test]
        public function test_arrays_with_same_values_in_different_indexes_dont_match():void
        {
            //then
            assertFalse(ArrayUtil.arraysMatch(["name", "age"], ["age", "name"]));
        }

        [Test]
        public function test_arrays_match_when_properties_created_in_different_orders():void
        {
            //given
            var arrayA:Array = [];
            var arrayB:Array = [];

            //when
            arrayA["name"] = "AName";
            arrayA["age"] = 22;

            arrayB["age"] = 22;
            arrayB["name"] = "AName";

            //then
            assertTrue(ArrayUtil.arraysMatch(arrayA, arrayB));
        }

        [Test]
        public function test_arrays_dont_match_when_indexes_match_but_values_different():void
        {
            //given
            var arrayA:Array = [];
            var arrayB:Array = [];

            //when
            arrayA["name"] = "AName";
            arrayA["age"] = 444;

            arrayB["age"] = 22;
            arrayB["name"] = "BName";

            //then
            assertFalse(ArrayUtil.arraysMatch(arrayA, arrayB));
        }

        [Test]
        public function test_arrays_dont_match_when_they_have_same_number_of_different_indexes():void
        {
            //given
            var arrayA:Array = [];
            var arrayB:Array = [];

            //when
            arrayA["name"] = "AName";
            arrayA["age"] = 444;

            arrayB["radius"] = "AName";
            arrayB[9] = 444;

            //then
            assertFalse(ArrayUtil.arraysMatch(arrayA, arrayB));
        }

        [Test]
        public function test_arrays_match_when_indexes_expressed_in_string_and_int():void
        {
            //given
            var arrayA:Array = ["value", "value"];
            var arrayB:Array = [];

            //when
            arrayB["0"] = "value";
            arrayB["1"] = "value";

            //then
            assertTrue(ArrayUtil.arraysMatch(arrayA, arrayB));
        }

        [Test]
        public function test_arrays_dont_match_when_values_expressed_in_string_and_int_if_strict_equality_used():void
        {
            //given
            var arrayA:Array = [];
            var arrayB:Array = [];

            //when
            arrayA[3] = 3;
            arrayA[4] = 4;

            arrayB[3] = "3";
            arrayB[4] = "4";

            //then
            assertFalse(ArrayUtil.arraysMatch(arrayA, arrayB, true));
        }

        [Test]
        public function test_arrays_match_when_values_expressed_in_string_and_int_if_strict_equality_not_used():void
        {
            //given
            var arrayA:Array = [];
            var arrayB:Array = [];

            //when
            arrayA[3] = 3;
            arrayA[4] = 4;

            arrayB[3] = "3";
            arrayB[4] = "4";

            //then
            assertTrue(ArrayUtil.arraysMatch(arrayA, arrayB, false));
        }

        [Test]
        public function test_array_and_null_dont_match():void
        {
            //then
            assertFalse(ArrayUtil.arraysMatch([1, 2, 3], null));
        }

        [Test]
        public function test_null_and_null_dont_match():void
        {
            //then
            assertFalse(ArrayUtil.arraysMatch(null, null));
        }

        [Test]
        public function test_arrays_with_null_in_different_positions_dont_match():void
        {
            //then
            assertFalse(ArrayUtil.arraysMatch([null, 0], [0, null]));
        }

        //--------------------------------------------------------------------------
        //
        //  arrayValuesMatch()
        //
        //--------------------------------------------------------------------------

        [Test]
        public function test_arrays_with_same_values_in_different_indexes_match_in_terms_of_values():void
        {
            //then
            assertTrue(ArrayUtil.arrayValuesMatch(["name", "age"], ["age", "name"]));
        }

        [Test]
        public function test_array_values_dont_match_with_null():void
        {
            //then
            assertFalse(ArrayUtil.arrayValuesMatch(["name", "age"], null));
        }

        [Test]
        public function test_null_doesnt_match_values_with_array():void
        {
            //then
            assertFalse(ArrayUtil.arrayValuesMatch(null, ["name", "age"]));
        }

        [Test]
        public function test_null_and_null_dont_have_matching_values():void
        {
            //then
            assertFalse(ArrayUtil.arrayValuesMatch(null, null));
        }

        [Test]
        public function test_array_values_match_although_they_have_different_indexes():void
        {
            //given
            var arrayA:Array = [];
            var arrayB:Array = [];

            //when
            arrayA["name"] = "AName";
            arrayA["age"] = 444;

            arrayB["label"] = "AName";
            arrayB["spin"] = 444;

            //then
            assertTrue(ArrayUtil.arrayValuesMatch(arrayA, arrayB));
        }

        [Test]
        public function test_array_values_dont_match_although_they_have_same_indexes():void
        {
            //given
            var arrayA:Array = [];
            var arrayB:Array = [];

            //when
            arrayA["name"] = "AName";
            arrayA["age"] = 444;

            arrayB["name"] = "BName";
            arrayB["age"] = 21;

            //then
            assertFalse(ArrayUtil.arrayValuesMatch(arrayA, arrayB));
        }

        [Test]
        //relevant because the array length is changed when a numeric index is used
        public function test_array_values_match_even_when_one_of_their_indexes_is_numeric():void
        {
            //given
            var arrayA:Array = [];
            var arrayB:Array = [];

            //when
            arrayA["name"] = "AName";
            arrayA["age"] = 444;

            arrayB["label"] = "AName";
            arrayB[9] = 444;

            //then
            assertTrue(ArrayUtil.arrayValuesMatch(arrayA, arrayB));
        }


        //--------------------------------------------------------------------------
        //
        //  getArrayValues()
        //
        //--------------------------------------------------------------------------
        [Test]
        public function test_values_of_null_is_an_empty_array():void
        {
            //when
            var values:Array = ArrayUtil.getArrayValues(null);

            //then
            assertNotNull(values);
            assertEquals(0, values.length);
        }

        [Test]
        public function test_values_of_array_whose_index_was_set_manually_to_a_number_include_only_that_value():void
        {
            //given
            var array:Array = [];
            array[2] = "hey";

            //when
            var values:Array = ArrayUtil.getArrayValues(array);

            //then
            assertNotNull(values);
            assertEquals(3, array.length);
            assertEquals(1, values.length);
            assertEquals("hey", values[0]);
        }
    }
}