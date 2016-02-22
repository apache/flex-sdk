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
    import org.flexunit.asserts.*;

    public class AddRemoveObjects
	{	
		private var _sut:ArrayCollection;
		
		protected var players:Array = [
			{team:"TeamOne",jerseyNumber:80,lastName:"PlayerA",firstName:"Aa"},
			{team:"TeamTwo",jerseyNumber:7, lastName:"PlayerB",firstName:"Bb"},
			{team:"TeamOne",jerseyNumber:12, lastName:"PlayerC",firstName:"Cc"},
			{team:"TeamOne",jerseyNumber:21,lastName:"PlayerD",firstName:"Dd"},
			{team:"TeamThree",jerseyNumber:34, lastName:"PlayerE",firstName:"Ee"},
			{team:"TeamOne",jerseyNumber:12, lastName:"PlayerF",firstName:"Ff"},
			{team:"TeamTwo",jerseyNumber:7, lastName:"PlayerG",firstName:"Gg"}
		];
		
		[Before]
		public function setUp():void
		{
			_sut = new ArrayCollection();
		}
		
		[After]
		public function tearDown():void
		{
			_sut = null;
		}
		
		[Test]
		public function empty():void
		{
			assertEquals(_sut.length, 0);
		}
		
		[Test]
		public function addObjects():void
		{
			_sut = new ArrayCollection(players);
			assertEquals("Length is not seven", _sut.length, 7);
			assertEquals("First element not correct", _sut[0], players[0]);
			assertEquals("Second element not correct", _sut[1], players[1]);
			assertEquals("Third element not correct", _sut[2], players[2]);
			assertEquals("Fouth element not correct", _sut[3], players[3]);
			assertEquals("Fifth element not correct", _sut[4], players[4]);
			assertEquals("Sixth element not correct", _sut[5], players[5]);
			assertEquals("Seventh element not correct", _sut[6], players[6]);
		}
		
		[Test]
		public function addDuplicate():void
		{
			addObjects();
			_sut.addItem(players[0]);
			assertEquals("Length is not eight", _sut.length, 8);
			assertEquals("First element not correct", _sut[0], players[0]);
			assertEquals("Second element not correct", _sut[1], players[1]);
			assertEquals("Third element not correct", _sut[2], players[2]);
			assertEquals("Fouth element not correct", _sut[3], players[3]);
			assertEquals("Fifth element not correct", _sut[4], players[4]);
			assertEquals("Sixth element not correct", _sut[5], players[5]);
			assertEquals("Seventh element not correct", _sut[6], players[6]);
			assertEquals("Eighth element not correct", _sut[7], players[0]);
		}
		
		[Test]
		public function removeDuplicate():void
		{
            //given
			addObjects();
            var firstPlayer:* = players[0];
            var secondPlayer:* = players[1];
            var thirdPlayer:* = players[2];
            var fourthPlayer:* = players[3];
            var fifthPlayer:* = players[4];
            var sixthPlayer:* = players[5];
            var seventhPlayer:* = players[6];

            //when
			_sut.addItem(players[0]);
            _sut.removeItemAt(0);
            //then
			assertEquals("Length is not seven", _sut.length, 7);
            assertEquals("First element not correct", _sut[0], secondPlayer);
            assertEquals("Second element not correct", _sut[1], thirdPlayer);
            assertEquals("Third element not correct", _sut[2], fourthPlayer);
            assertEquals("Fourth element not correct", _sut[3], fifthPlayer);
            assertEquals("Fifth element not correct", _sut[4], sixthPlayer);
            assertEquals("Sixth element not correct", _sut[5], seventhPlayer);
            assertEquals("Seventh element not correct", _sut[6], firstPlayer);
		}
		
		[Test]
		public function removeAllObjects():void
		{
			addObjects();
			_sut.removeAll();
			assertEquals("Length is not zero", _sut.length, 0);
		}
		
		[Test]
		public function removeFirstObjects():void
		{
            //given
			addObjects();
            var secondPlayer:Object = players[1];

            //when
			_sut.removeItemAt(0);

            //then
            assertEquals("First element not correct", secondPlayer, _sut[0]);
			assertEquals("Length is not six", 6, _sut.length);

            //when
			_sut.removeItemAt(0);
            //then
			assertEquals("Length is not five", _sut.length, 5);

            //when
			_sut.removeItemAt(0);
            //then
			assertEquals("Length is not four", _sut.length, 4);

            //when
			_sut.removeItemAt(0);
            //then
			assertEquals("Length is not three", _sut.length, 3);

            //when
			_sut.removeItemAt(0);
            //then
			assertEquals("Length is not two", _sut.length, 2);

            //when
			_sut.removeItemAt(0);
            //then
			assertEquals("Length is not one", _sut.length, 1);

            //when
			_sut.removeItemAt(0);
            //then
			assertEquals("Length is not zero", _sut.length, 0);
		}
		
		[Test]
		public function removeLastNumbers():void
		{
			addObjects();
			_sut.removeItemAt(6);
			assertEquals("First element not correct", _sut[0], players[0]);
			assertEquals("Length is not six", _sut.length, 6);
			_sut.removeItemAt(0);
			assertEquals("Length is not five", _sut.length, 5);
			_sut.removeItemAt(0);
			assertEquals("Length is not four", _sut.length, 4);
			_sut.removeItemAt(0);
			assertEquals("Length is not three", _sut.length, 3);
			_sut.removeItemAt(0);
			assertEquals("Length is not two", _sut.length, 2);
			_sut.removeItemAt(0);
			assertEquals("Length is not one", _sut.length, 1);
			_sut.removeItemAt(0);
			assertEquals("Length is not zero", _sut.length, 0);
		}
		
		[Test]
		public function removeItemByIndex():void
		{
			//given
			addObjects();
            const secondPlayer:Object = players[1];
            const thirdPlayer:Object = players[2];
            const fourthPlayer:Object = players[3];

            //when
			_sut.removeItemAt(_sut.getItemIndex(players[0]));

            //then
            assertEquals("First element incorrect", secondPlayer, _sut[0]);
			assertEquals("Length is not six", 6, _sut.length);

            //when
			_sut.removeItemAt(_sut.getItemIndex(thirdPlayer));

            //then
			assertEquals("First element not correct", secondPlayer, _sut[0]);
			assertEquals("Second element not correct", fourthPlayer, _sut[1]);
			assertEquals("Length is not four", 5, _sut.length);
		}
		
		[Test]
		public function outOfRange():void
		{
			addObjects();
			try {
				_sut.removeItemAt(-1);
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			assertEquals("Length is not seven", _sut.length, 7);
			try {
				_sut.removeItemAt(10);
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			assertEquals("Length is not seven", _sut.length, 7);
		}
		
		[Test]
		public function swapItemsTwoThenOne():void
		{
            //given
			addObjects();
			var item1:Object = _sut.getItemAt(0);
			var item2:Object = _sut.getItemAt(1);
            var firstPlayer:* = players[0];
            var secondPlayer:* = players[1];

            //when
			_sut.setItemAt(item2,0);
			_sut.setItemAt(item1,1);

            //then
			assertEquals("Length is not seven", _sut.length, 7);
            assertEquals("First element not correct", _sut[0], secondPlayer);
            assertEquals("Second element not correct", _sut[1], firstPlayer);
		}
		
		[Test]
		public function swapItemsOneThenTwo():void
		{
            //given
			addObjects();
			var item1:Object = _sut.getItemAt(0);
			var item2:Object = _sut.getItemAt(1);
            var secondPlayer:Object = players[1];
            var firstPlayer:Object = players[0];

            //when
			_sut.setItemAt(item1,1);
			_sut.setItemAt(item2,0);

            //then
			assertEquals("Length is not seven", _sut.length, 7);
            assertEquals("First element not correct", _sut[0], secondPlayer);
            assertEquals("Second element not correct", _sut[1], firstPlayer);

		}
		
	}
}