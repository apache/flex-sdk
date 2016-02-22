package mx.collections {
	import mx.collections.ArrayCollection;
	
	import org.flexunit.asserts.*;

	public class AddRemoveObjects
	{	
		protected var ac:ArrayCollection;
		
		protected var players:Array=[
			{team:"TeamOne",jerseyNumber:80,lastName:"PlayerA",firstName:"Aa"},
			{team:"TeamTwo",jerseyNumber:7, lastName:"PlayerB",firstName:"Bb"},
			{team:"TeamOne",jerseyNumber:12, lastName:"PlayerC",firstName:"Cc"},
			{team:"TeamOne",jerseyNumber:21,lastName:"PlayerD",firstName:"Dd"},
			{team:"TeamThree",jerseyNumber:34, lastName:"PlayerE",firstName:"Ee"},
			{team:"TeamOne",jerseyNumber:12, lastName:"PlayerF",firstName:"Ff"},
			{team:"TeamTwo",jerseyNumber:7, lastName:"PlayerG",firstName:"Gg"},
		];
		
		[Before]
		public function setUp():void
		{
			ac = new ArrayCollection();
		}
		
		[After]
		public function tearDown():void
		{
			ac = null;
		}
		
		[Test]
		public function empty():void
		{
			assertEquals(ac.length, 0);
		}
		
		[Test]
		public function addObjects():void
		{
			ac = new ArrayCollection(players);
			assertEquals("Length is not seven", ac.length, 7);
			assertEquals("First element not correct", ac[0], players[0]);
			assertEquals("Second element not correct", ac[1], players[1]);
			assertEquals("Third element not correct", ac[2], players[2]);
			assertEquals("Fouth element not correct", ac[3], players[3]);
			assertEquals("Fifth element not correct", ac[4], players[4]);
			assertEquals("Sixth element not correct", ac[5], players[5]);
			assertEquals("Seventh element not correct", ac[6], players[6]);
		}
		
		[Test]
		public function addDuplicate():void
		{
			addObjects();
			ac.addItem(players[0]);
			assertEquals("Length is not eight", ac.length, 8);
			assertEquals("First element not correct", ac[0], players[0]);
			assertEquals("Second element not correct", ac[1], players[1]);
			assertEquals("Third element not correct", ac[2], players[2]);
			assertEquals("Fouth element not correct", ac[3], players[3]);
			assertEquals("Fifth element not correct", ac[4], players[4]);
			assertEquals("Sixth element not correct", ac[5], players[5]);
			assertEquals("Seventh element not correct", ac[6], players[6]);
			assertEquals("Eighth element not correct", ac[7], players[0]);
		}
		
		[Test]
		public function removeDuplicate():void
		{
			addObjects();
			ac.addItem(players[0]);
			ac.removeItemAt(0);
			assertEquals("Length is not seven", ac.length, 7);
			assertEquals("First element not correct", ac[0], players[1]);
			assertEquals("Second element not correct", ac[1], players[2]);
			assertEquals("Third element not correct", ac[2], players[3]);
			assertEquals("Fouth element not correct", ac[3], players[4]);
			assertEquals("Fifth element not correct", ac[4], players[5]);
			assertEquals("Sixth element not correct", ac[5], players[6]);
			assertEquals("Seventh element not correct", ac[6], players[0]);
		}
		
		[Test]
		public function removeAllObjects():void
		{
			addObjects();
			ac.removeAll();
			assertEquals("Length is not zero", ac.length, 0);		
		}
		
		[Test]
		public function removeFirstObjects():void
		{
			addObjects();
			ac.removeItemAt(0);
			assertEquals("First element not correct", ac[0], players[1]);
			assertEquals("Length is not six", ac.length, 6);
			ac.removeItemAt(0);
			assertEquals("Length is not five", ac.length, 5);
			ac.removeItemAt(0);
			assertEquals("Length is not four", ac.length, 4);
			ac.removeItemAt(0);
			assertEquals("Length is not three", ac.length, 3);
			ac.removeItemAt(0);
			assertEquals("Length is not two", ac.length, 2);
			ac.removeItemAt(0);
			assertEquals("Length is not one", ac.length, 1);
			ac.removeItemAt(0);
			assertEquals("Length is not zero", ac.length, 0);
		}
		
		[Test]
		public function removeLastNumbers():void
		{
			addObjects();
			ac.removeItemAt(6);
			assertEquals("First element not correct", ac[0], players[0]);
			assertEquals("Length is not six", ac.length, 6);
			ac.removeItemAt(0);
			assertEquals("Length is not five", ac.length, 5);
			ac.removeItemAt(0);
			assertEquals("Length is not four", ac.length, 4);
			ac.removeItemAt(0);
			assertEquals("Length is not three", ac.length, 3);
			ac.removeItemAt(0);
			assertEquals("Length is not two", ac.length, 2);
			ac.removeItemAt(0);
			assertEquals("Length is not one", ac.length, 1);
			ac.removeItemAt(0);
			assertEquals("Length is not zero", ac.length, 0);
		}
		
		[Test]
		public function removeItemByIndex():void
		{
			addObjects();
			ac.removeItemAt(ac.getItemIndex(players[0]));
			assertEquals("First element not correct", ac[0], players[1]);
			assertEquals("Length is not six", ac.length, 6);
			ac.removeItemAt(ac.getItemIndex(players[2]));
			assertEquals("First element not correct", ac[0], players[1]);
			assertEquals("Second element not correct", ac[1], players[3]);
			assertEquals("Length is not four", ac.length, 4);
		}
		
		[Test]
		public function outOfRange():void
		{
			addObjects();
			try {
				ac.removeItemAt(-1);
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			assertEquals("Length is not seven", ac.length, 7);
			try {
				ac.removeItemAt(10);
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			assertEquals("Length is not seven", ac.length, 7);
		}
		
		[Test]
		public function swapItemsTwoThenOne():void
		{
			addObjects();
			
			var item1:Object = ac.getItemAt(0);
			var item2:Object = ac.getItemAt(1);
			
			ac.setItemAt(item2,0);
			ac.setItemAt(item1,1);
			
			assertEquals("Length is not seven", ac.length, 7);
			assertEquals("First element not correct", ac[0], players[1]);
			assertEquals("Second element not correct", ac[1], players[0]);
		}
		
		[Test]
		public function swapItemsOneThenTwo():void
		{
			addObjects();

			var item1:Object = ac.getItemAt(0);
			var item2:Object = ac.getItemAt(1);
			
			ac.setItemAt(item1,1);
			ac.setItemAt(item2,0);
			
			assertEquals("Length is not seven", ac.length, 7);
			assertEquals("First element not correct", ac[0], players[1]);
			assertEquals("Second element not correct", ac[1], players[0]);

		}
		
	}
}