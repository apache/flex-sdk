package mx.collections {
	import mx.collections.ArrayCollection;
	
	import org.flexunit.asserts.*;

	public class AddRemoveStrings
	{	
		protected var ac:ArrayCollection;
		
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
		public function addStrings():void
		{
			ac.addItem("A");
			assertEquals("Length is not one", ac.length, 1);
			assertEquals("First element not correct", ac[0], "A");
			ac.addItem("B");
			assertEquals("Length is not two", ac.length, 2);
			assertEquals("Second element not correct", ac[1], "B");
			ac.addItem("D");
			assertEquals("Length is not three", ac.length, 3);
			assertEquals("Second element not correct", ac[2], "D");
			ac.addItem("C");
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("Second element not correct", ac[3], "C");
		}
		
		[Test]
		public function addDuplicate():void
		{
			addStrings();
			ac.addItem("B");
			assertEquals("Length is not five", ac.length, 5);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "B");
			assertEquals("Second element not correct", ac[2], "D");
			assertEquals("Second element not correct", ac[3], "C");
			assertEquals("Second element not correct", ac[4], "B");
		}
		
		[Test]
		public function removeDuplicate():void
		{
			addStrings();
			ac.addItem("B");
			ac.removeItemAt(1);
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "D");
			assertEquals("Second element not correct", ac[2], "C");
			assertEquals("Second element not correct", ac[3], "B");
		}
		
		[Test]
		public function removeAllStrings():void
		{
			addStrings();
			ac.removeAll();
			assertEquals("Length is not zero", ac.length, 0);		
		}
		
		[Test]
		public function removeFirstStrings():void
		{
			addStrings();
			ac.removeItemAt(0);
			assertEquals("First element not correct", ac[0], "B");
			assertEquals("Length is not three", ac.length, 3);
			ac.removeItemAt(0);
			assertEquals("Length is not two", ac.length, 2);
		}
		
		[Test]
		public function removeLastStrings():void
		{
			addStrings();
			ac.removeItemAt(1);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Length is not three", ac.length, 3);
			ac.removeItemAt(0);
			assertEquals("Length is not two", ac.length, 2);
		}
		
		[Test]
		public function removeItemByIndex():void
		{
			addStrings();
			ac.removeItemAt(ac.getItemIndex("B"));
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Length is not three", ac.length, 3);
			ac.removeItemAt(ac.getItemIndex("D"));
			assertEquals("Length is not two", ac.length, 2);
		}
		
		[Test]
		public function outOfRange():void
		{
			addStrings();
			try {
				ac.removeItemAt(-1);
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			assertEquals("Length is not four", ac.length, 4);
			try {
				ac.removeItemAt(10);
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			assertEquals("Length is not two", ac.length, 4);
		}
		
		[Test]
		public function swapItemsTwoThenOne():void
		{
			addStrings();
			
			var item1:String = ac.getItemAt(0) as String;
			var item2:String = ac.getItemAt(1) as String;
			
			ac.setItemAt(item2, 0);
			ac.setItemAt(item1, 1);
			
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], "B");
			assertEquals("Second element not correct", ac[1], "A");
		}
		
		[Test]
		public function swapItemsOneThenTwo():void
		{
			addStrings();

			var item1:String = ac.getItemAt(0) as String;
			var item2:String = ac.getItemAt(1) as String;
			
			ac.setItemAt(item1, 1);
			ac.setItemAt(item2, 0);
			
			assertEquals("Length is not two", ac.length, 2);
			assertEquals("First element not correct", ac[0], "B");
			assertEquals("Second element not correct", ac[1], "A");
		}
		
	}
}