package mx.collections {
	import mx.collections.ArrayCollection;
	
	import org.flexunit.asserts.*;

	public class AddRemoveNumbers
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
			//then
			assertEquals(_sut.length, 0);
		}
		
		[Test]
		public function addNumbers():void
		{
			_sut.addItem(1);
			assertEquals("Length is not one", _sut.length, 1);
			assertEquals("First element not correct", _sut[0], 1);
			_sut.addItem(2);
			assertEquals("Length is not two", _sut.length, 2);
			assertEquals("Second element not correct", _sut[1], 2);
		}
		
		[Test]
		public function addDuplicate():void
		{
			addNumbers();
			_sut.addItem(1);
			assertEquals("Length is not three", _sut.length, 3);
			assertEquals("First element not correct", _sut[0], 1);
			assertEquals("Second element not correct", _sut[1], 2);
			assertEquals("Second element not correct", _sut[2], 1);
		}
		
		[Test]
		public function removeDuplicate():void
		{
			addNumbers();
			_sut.addItem(1);
			_sut.removeItemAt(0);
			assertEquals("Length is not two", _sut.length, 2);
			assertEquals("First element not correct", _sut[0], 2);
			assertEquals("Second element not correct", _sut[1], 1);
		}
		
		[Test]
		public function removeAllNumbers():void
		{
			addNumbers();
			_sut.removeAll();
			assertEquals("Length is not zero", _sut.length, 0);
		}
		
		[Test]
		public function removeFirstNumbers():void
		{
			addNumbers();
			_sut.removeItemAt(0);
			assertEquals("First element not correct", _sut[0], 2);
			assertEquals("Length is not one", _sut.length, 1);
			_sut.removeItemAt(0);
			assertEquals("Length is not zero", _sut.length, 0);
		}
		
		[Test]
		public function removeLastNumbers():void
		{
			addNumbers();
			_sut.removeItemAt(1);
			assertEquals("First element not correct", _sut[0], 1);
			assertEquals("Length is not one", _sut.length, 1);
			_sut.removeItemAt(0);
			assertEquals("Length is not zero", _sut.length, 0);
		}
		
		[Test]
		public function removeItemByIndex():void
		{
			addNumbers();
			_sut.removeItemAt(_sut.getItemIndex(1));
			assertEquals("First element not correct", _sut[0], 2);
			assertEquals("Length is not one", _sut.length, 1);
			_sut.removeItemAt(_sut.getItemIndex(2));
			assertEquals("Length is not zero", _sut.length, 0);
		}
		
		[Test]
		public function outOfRange():void
		{
			addNumbers();
			try {
				_sut.removeItemAt(-1);
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			assertEquals("Length is not two", _sut.length, 2);
			try {
				_sut.removeItemAt(10);
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			assertEquals("Length is not two", _sut.length, 2);
		}
		
		[Test]
		public function swapItemsTwoThenOne():void
		{
			addNumbers();
			
			var item1:Number = _sut.getItemAt(0) as Number;
			var item2:Number = _sut.getItemAt(1) as Number;
			
			_sut.setItemAt(item2,0);
			_sut.setItemAt(item1,1);
			
			assertEquals("Length is not two", _sut.length, 2);
			assertEquals("First element not correct", _sut[0], 2);
			assertEquals("Second element not correct", _sut[1], 1);
		}
		
		[Test]
		public function swapItemsOneThenTwo():void
		{
			addNumbers();

			var item1:Number = _sut.getItemAt(0) as Number;
			var item2:Number = _sut.getItemAt(1) as Number;
			
			_sut.setItemAt(item1,1);
			_sut.setItemAt(item2,0);
			
			assertEquals("Length is not two", _sut.length, 2);
			assertEquals("First element not correct", _sut[0], 2);
			assertEquals("Second element not correct", _sut[1], 1);
		}
		
	}
}