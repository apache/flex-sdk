package mx.collections {
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;

	public class FilerAndSortNumbers
	{		
		import org.flexunit.asserts.*;
		
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
		
		
		protected function addNumbers():void
		{
			ac.addItem(6);
			ac.addItem(2);
			ac.addItem(3);
			ac.addItem(1);
			ac.addItem(5);
			ac.addItem(4);
		}
		
		protected function even(object:Object):Boolean
		{
			return Number(object) % 2 == 0;
		}
		
		protected function odd(object:Object):Boolean
		{
			return Number(object) % 2 == 1;
		}
		
		[Test]
		public function filterAndSortCombinations():void
		{
			addNumbers();
			ac.filterFunction = even;
			ac.sort = new Sort();
			ac.refresh();
			
			assertEquals("Length is not three", ac.length, 3);
			assertEquals("First element not correct", ac[0], 2);
			assertEquals("Second element not correct", ac[1], 4);
			assertEquals("Third element not correct", ac[2], 6);
			
			ac.filterFunction = odd;
			ac.refresh();
			
			assertEquals("Length is not three", ac.length, 3);
			assertEquals("First element not correct", ac[0], 1);
			assertEquals("Second element not correct", ac[1], 3);
			assertEquals("Third element not correct", ac[2], 5);
			
			ac.sort = new Sort();			
			ac.sort.fields = [new SortField(null, false, true, true)];
			ac.refresh();
			
			assertEquals("Length is not three", ac.length, 3);
			assertEquals("First element not correct", ac[0], 5);
			assertEquals("Second element not correct", ac[1], 3);
			assertEquals("Third element not correct", ac[2], 1);
			
			ac.filterFunction = null;
			ac.refresh();
			
			assertEquals("Length is not six", ac.length, 6);
			assertEquals("First element not correct", ac[0], 6);
			assertEquals("Second element not correct", ac[1], 5);
			assertEquals("Third element not correct", ac[2], 4);
			assertEquals("Fourth element not correct", ac[3], 3);
			assertEquals("Fith element not correct", ac[4], 2);
			assertEquals("Six element not correct", ac[5], 1);
			
			ac.sort = null;
			ac.refresh();
			
			assertEquals("Length is not six", ac.length, 6);
			assertEquals("First element not correct", ac[0], 6);
			assertEquals("Second element not correct", ac[1], 2);
			assertEquals("Third element not correct", ac[2], 3);
			assertEquals("Fourth element not correct", ac[3], 1);
			assertEquals("Fith element not correct", ac[4], 5);
			assertEquals("Six element not correct", ac[5], 4);
		}	
		
		
	}
}