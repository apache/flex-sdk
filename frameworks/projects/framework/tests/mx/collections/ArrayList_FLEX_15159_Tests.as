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

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertTrue;
import org.flexunit.asserts.assertFalse;

public class ArrayList_FLEX_15159_Tests
{
    // Tests `var x = list[i];` syntax
    [Test]
    public function testGetItemAtSugar():void
    {
        var list:ArrayList = new ArrayList(['a', 'b', 'c']);
        assertEquals('a', list[0]);
        assertEquals('b', list[1]);
        assertEquals('c', list[2]);
    }
    
    // Tests `list[i] = x;` syntax
    [Test]
    public function testSetItemAtSugar():void
    {
        var list:ArrayList = new ArrayList([0, 0, 0]);
        list[0] = 'a';
        list[1] = 'b';
        list[2] = 'c';
        assertEquals('a,b,c', list);
    }
    
    // Tests for-in loops
    [Test]
    public function testForSugar():void
    {
        var list1:ArrayList = new ArrayList(['a', 'b', 'c']);
        var list2:ArrayList = new ArrayList();
        for (var i:String in list1) {
            list2.addItem(i);
        }
        assertEquals('0,1,2', list2);
    }
    
    // Tests for-each loops
    [Test]
    public function testForEachSugar():void
    {
        var list1:ArrayList = new ArrayList(['a', 'b', 'c']);
        var list2:ArrayList = new ArrayList();
        for each (var item:String in list1) {
            list2.addItem(item);
        }
        assertEquals('a,b,c', list2);
    }
    
    // Tests `i in list` syntax
    [Test]
    public function testIn():void
    {
        var list:ArrayList = new ArrayList(['a', 'b', 'c']);
        assertTrue(0 in list);
        assertTrue(1 in list);
        assertTrue(2 in list);
        assertFalse(3 in list);
        assertFalse(-1 in list);
        assertFalse('a' in list);
    }
    
}

}
