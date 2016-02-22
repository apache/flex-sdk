package mx.collections {
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	public class FilterNumbers
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
			ac.addItem(1);
			ac.addItem(2);
		}
		
		protected function allIn(object:Object):Boolean
		{
			return true;
		}
		
		protected function allOut(object:Object):Boolean
		{
			return false;
		}
		
		protected function isOne(object:Object):Boolean
		{
			return object == 1;
		}
		
		[Test]
		public function nullFilter():void
		{
			addNumbers();
			ac.filterFunction = null;
			ac.refresh();
			
			assertEquals("Length is not two", ac.length, 2);
			assertEquals("First element not correct", ac[0], 1);
			assertEquals("Second element not correct", ac[1], 2);
		}	
		
		[Test]
		public function trueFilter():void
		{
			addNumbers();
			ac.filterFunction = allIn; 
			ac.refresh();
			
			assertEquals("Length is not two", ac.length, 2);
			assertEquals("First element not correct", ac[0], 1);
			assertEquals("Second element not correct", ac[1], 2);
		}
		
		[Test]
		public function falseFilter():void
		{
			addNumbers();
			ac.filterFunction = allOut; 
			ac.refresh();
			
			assertEquals("Length is not two", ac.length, 0);
		}
		
		
		[Test]
		public function filterNoRefresh():void
		{
			addNumbers();
			ac.filterFunction = allOut;
			
			// Filter should not take effect
			assertEquals("Length is not two", ac.length, 2);
			assertEquals("First element not correct", ac[0], 1);
			assertEquals("Second element not correct", ac[1], 2);
		}
		
		[Test]
		public function nullFilterNoRefresh():void
		{
			addNumbers();
			ac.filterFunction = null;
			
			// Filter should not take effect
			assertEquals("Length is not two", ac.length, 2);
			assertEquals("First element not correct", ac[0], 1);
			assertEquals("Second element not correct", ac[1], 2);
		}
		
		[Test]
		public function filterDoubleRefresh():void
		{
			addNumbers();
			ac.filterFunction = allOut;
			ac.refresh();
			
			assertEquals("Length is not zero", ac.length, 0);
			
			ac.filterFunction = null;
			ac.refresh();
			
			// Filter should not take effect
			assertEquals("Length is not two", ac.length, 2);
			assertEquals("First element not correct", ac[0], 1);
			assertEquals("Second element not correct", ac[1], 2);
		}
		
		// RTEs in Apache Flex 4.9.1
		[Test]
		public function filterAddAfterNullNoRefresh():void
		{
			addNumbers();
			
			ac.filterFunction = allOut;
			ac.refresh();
			
			assertEquals("Length is not zero", ac.length, 0);
			
			ac.filterFunction = null;
			addNumbers();
			
			// Filter should be in effect and first 2 items sorted
			// item added after are not filtered until refresh called
			assertEquals("Length is not two", ac.length, 2);
			assertEquals("First element not correct", ac[0], 1);
			assertEquals("Second element not correct", ac[1], 2);
			
			ac.refresh();
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], 1);
			assertEquals("Second element not correct", ac[1], 2);
			assertEquals("First element not correct", ac[2], 1);
			assertEquals("Second element not correct", ac[3], 2);
		}
		
		[Test]
		public function filterRemoveAfterNullNoRefresh():void
		{
			addNumbers();
			
			ac.filterFunction = allOut;
			ac.refresh();
			ac.filterFunction = null;
			
			assertEquals("Length is not zero", ac.length, 0);
			
			try {
				ac.removeItemAt(0);
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			
			assertEquals("Length is not zero", ac.length, 0);
			
			ac.refresh();
			assertEquals("Length is not two", ac.length, 2);
		}
		
		[Test]
		public function filterIncludingDuplicates():void
		{
			addNumbers();
			addNumbers();
			
			ac.filterFunction = isOne;
			ac.refresh();
			
			assertEquals("Length is not two", ac.length, 2);
			
			assertEquals("First element not correct", ac[0], 1);
			assertEquals("Second element not correct", ac[1], 1);	
		}
		
		// Fails in Apache Flex 4.9.1
		[Test]
		public function swapItemsTwoThenOne():void
		{
			addNumbers();
			ac.filterFunction = allIn; 
			ac.refresh();
			
			var item1:Number = ac.getItemAt(0) as Number;
			var item2:Number = ac.getItemAt(1) as Number;
			
			ac.setItemAt(item2,0);
			ac.setItemAt(item1,1);
			
			assertEquals("Length is not two", ac.length, 2);
			assertEquals("First element not correct", ac[0], 2);
			assertEquals("Second element not correct", ac[1], 1);
		}
		
		[Test]
		public function swapItemsOneThenTwo():void
		{
			addNumbers();
			ac.filterFunction = allIn; 
			ac.refresh();
			
			var item1:Number = ac.getItemAt(0) as Number;
			var item2:Number = ac.getItemAt(1) as Number;
			
			ac.setItemAt(item1,1);
			ac.setItemAt(item2,0);
			
			assertEquals("Length is not two", ac.length, 2);
			assertEquals("First element not correct", ac[0], 2);
			assertEquals("Second element not correct", ac[1], 1);
		}
		
		[Test]
		public function removeAllAfterFiltered():void
		{
			addNumbers();
			ac.filterFunction = allOut; 
			ac.refresh();
			
			assertEquals("Length is not two", ac.length, 0);
			
			ac.removeAll();
			
			assertEquals("Length is not two", ac.length, 0);
			
			ac.filterFunction = null; 
			ac.refresh();
			
			assertEquals("Length is not two", ac.length, 2);
			assertEquals("First element not correct", ac[0], 1);
			assertEquals("Second element not correct", ac[1], 2);
		}
		
		[Test]
		public function removeFilteredItem():void
		{
			addNumbers();
			ac.filterFunction = isOne; 
			ac.refresh();
			
			assertEquals("Length is not one", ac.length, 1);
			
			ac.removeItemAt(ac.getItemIndex(1));
			
			assertEquals("Length is not zero", ac.length, 0);
			
			ac.filterFunction = null; 
			ac.refresh();
			
			assertEquals("Length is not two", ac.length, 1);
			assertEquals("First element not correct", ac[0], 2);
		}
		
		[Test]
		public function removeNonFilteredItem():void
		{
			addNumbers();
			ac.filterFunction = isOne; 
			ac.refresh();
			
			assertEquals("Length is not one", ac.length, 1);
			
			try {
				// not removed as filter hids it - perhaps it should be removed?
				ac.removeItemAt(ac.getItemIndex(2));	
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			
			assertEquals("Length is not one", ac.length, 1);
			
			ac.filterFunction = null; 
			ac.refresh();
			
			assertEquals("Length is not two", ac.length, 2);
			assertEquals("First element not correct", ac[0], 1);
			assertEquals("First element not correct", ac[1], 2);
		}
		
		
	}
}