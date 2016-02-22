package mx.collections {
	import mx.collections.ArrayCollection;
	
	import org.flexunit.asserts.*;

	public class AddRemoveStrings
	{	
		protected var _sut:ArrayCollection;
		
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
			assertEquals(0, _sut.length);
		}
		
		[Test]
		public function addStrings():void
		{
			_sut.addItem("A");
			assertEquals("Length is not one", 1, _sut.length);
			assertEquals("First element not correct", "A", _sut[0]);

			_sut.addItem("B");
			assertEquals("Length is not two", 2, _sut.length);
			assertEquals("Second element not correct", "B", _sut[1]);

			_sut.addItem("D");
			assertEquals("Length is not three", 3, _sut.length);
			assertEquals("Second element not correct", "D", _sut[2]);

			_sut.addItem("C");
			assertEquals("Length is not four", 4, _sut.length);
			assertEquals("Second element not correct", "C", _sut[3]);
		}
		
		[Test]
		public function addDuplicate():void
		{
            //given
			addStrings();

            //when
			_sut.addItem("B");

            //then
			assertEquals("Length is not five", 5, _sut.length);
			assertEquals("First element not correct", "A", _sut[0]);
			assertEquals("Second element not correct", "B", _sut[1]);
			assertEquals("Second element not correct", "D", _sut[2]);
			assertEquals("Second element not correct", "C", _sut[3]);
			assertEquals("Second element not correct", "B", _sut[4]);
		}
		
		[Test]
		public function removeDuplicate():void
		{
            //given
			addStrings();

            //when
			_sut.addItem("B");
			_sut.removeItemAt(1);

            //then
			assertEquals("Length is not four", 4, _sut.length);
			assertEquals("First element not correct", _sut[0], "A");
			assertEquals("Second element not correct", _sut[1], "D");
			assertEquals("Second element not correct", _sut[2], "C");
			assertEquals("Second element not correct", _sut[3], "B");
		}
		
		[Test]
		public function removeAllStrings():void
		{
			addStrings();
			_sut.removeAll();
			assertEquals("Length is not zero", _sut.length, 0);
		}
		
		[Test]
		public function removeFirstStrings():void
		{
			addStrings();
			_sut.removeItemAt(0);
			assertEquals("First element not correct", _sut[0], "B");
			assertEquals("Length is not three", _sut.length, 3);
			_sut.removeItemAt(0);
			assertEquals("Length is not two", _sut.length, 2);
		}
		
		[Test]
		public function removeLastStrings():void
		{
			addStrings();
			_sut.removeItemAt(1);
			assertEquals("First element not correct", _sut[0], "A");
			assertEquals("Length is not three", _sut.length, 3);
			_sut.removeItemAt(0);
			assertEquals("Length is not two", _sut.length, 2);
		}
		
		[Test]
		public function removeItemByIndex():void
		{
			addStrings();
			_sut.removeItemAt(_sut.getItemIndex("B"));
			assertEquals("First element not correct", _sut[0], "A");
			assertEquals("Length is not three", _sut.length, 3);
			_sut.removeItemAt(_sut.getItemIndex("D"));
			assertEquals("Length is not two", _sut.length, 2);
		}
		
		[Test]
		public function outOfRange():void
		{
			addStrings();
			try {
				_sut.removeItemAt(-1);
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			assertEquals("Length is not four", 4, _sut.length);
			try {
				_sut.removeItemAt(10);
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			assertEquals("Length is not two", 4, _sut.length);
		}
		
		[Test]
		public function swapItemsTwoThenOne():void
		{
            //given
			addStrings();
			var item1:String = _sut.getItemAt(0) as String;
			var item2:String = _sut.getItemAt(1) as String;

            //when
			_sut.setItemAt(item2, 0);
			_sut.setItemAt(item1, 1);

            //then
			assertEquals("Length is not four", _sut.length, 4);
			assertEquals("First element not correct", _sut[0], "B");
			assertEquals("Second element not correct", _sut[1], "A");
		}
		
		[Test]
		public function swapItemsOneThenTwo():void
		{
            //given
			addStrings();
			var item1:String = _sut.getItemAt(0) as String;
			var item2:String = _sut.getItemAt(1) as String;

			//when
			_sut.setItemAt(item1, 1);
			_sut.setItemAt(item2, 0);

            //then
			assertEquals("Length is not four", 4, _sut.length);
			assertEquals("First element not correct", _sut[0], "B");
			assertEquals("Second element not correct", _sut[1], "A");
		}
		
	}
}