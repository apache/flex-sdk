////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.automation.tabularData
{
	import mx.automation.Automation;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationTabularData;
	import mx.core.mx_internal;
	
	import spark.components.IItemRenderer;
	import spark.components.supportClasses.ListBase;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	import mx.events.DragEvent;
	
	use namespace mx_internal;
	
	/**
	 *  @private
	 */
	public class SparkListBaseTabularData
		implements IAutomationTabularData
	{
		
		private var sparkList:spark.components.supportClasses.ListBase;
		
		/**
		 *  Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function SparkListBaseTabularData(l:spark.components.supportClasses.ListBase)
		{
			super();
			
			sparkList = l;
		}
		
		/**
		 * private
		 */
		private function getVisibleRows():Array
		{
			var visibleRows:Array = new Array();
			
			var count:int = sparkList.dataGroup.numElements;
			for (var i:int = 0; i<count ; i++)
			{
				var currentObj:Object = sparkList.dataGroup.getElementAt(i);
				if( currentObj is IItemRenderer)
					visibleRows.push(currentObj);
			}
			return visibleRows;
		}
		
		
		
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function get firstVisibleRow():int
		{
			if(sparkList.layout is VerticalLayout)
				return (sparkList.layout as VerticalLayout).firstIndexInView;
			else if(sparkList.layout is HorizontalLayout)
				return (sparkList.layout as HorizontalLayout).firstIndexInView;
			return 0;
			
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function get lastVisibleRow():int
		{
			if(sparkList.layout is VerticalLayout)
				return (sparkList.layout as VerticalLayout).lastIndexInView ;
			else if(sparkList.layout is HorizontalLayout)
				return (sparkList.layout as HorizontalLayout).lastIndexInView ;
			
			
			// this is index based data. so we need to subtract one from the number of rows.
			//http://bugs.adobe.com/jira/browse/FLEXENT-1100
			return numRows-1;
			
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function get numRows():int
		{
			return (sparkList.dataGroup ? sparkList.dataGroup.numElements:0);
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function get numColumns():int
		{
			return 1;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function get columnNames():Array
		{
			return [ "" ];
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function getValues(start:uint = 0, end:uint = 0):Array
		{
			// note: getElementAt(i) is based on total elements and it returns 
			// null for the item rendereres if they are not visible
			// if the useVirtualLayout is true. so we dont need 
			// special handing of the index
			
			var values:Array = [ ];
			if (sparkList.dataGroup)		
			{
				var alreadyProcessedCount:int  = 0;
				
				if(sparkList.useVirtualLayout == true)
				{
					var stopIndex:int  = firstVisibleRow;
					for( var x:int=start;  x < stopIndex ; x++ )
					{
						var currentObj1:Object = sparkList.dataGroup.createItemRendererFor(x);
						// this is only of one column list.  Ohter components need to override this metod
						// to handle appropritely
						if( currentObj1 is IAutomationObject)
						{
							values.push([(currentObj1 as IAutomationObject).automationName]);
							alreadyProcessedCount++;
						}
					}
				}
				for (var i:int = start+alreadyProcessedCount; i<=end ; i++)
				{
					var currentObj:Object = sparkList.dataGroup.getElementAt(i);
					// this is only of one column list.  Ohter components need to override this metod
					// to handle appropritely
					if( currentObj is IAutomationObject)
						values.push([(currentObj as IAutomationObject).automationName]);
				}
				
				if(sparkList.useVirtualLayout == true)
				{
					
					for( var x1:int=lastVisibleRow+1;  x1 <= end ; x1++ )
					{
						var currentObj2:Object = sparkList.dataGroup.createItemRendererFor(x1);
						// this is only of one column list.  Ohter components need to override this metod
						// to handle appropritely
						if( currentObj2 is IAutomationObject)
							values.push([(currentObj2 as IAutomationObject).automationName]);
					}
				}
				
			}
			
			
			
			return values;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function getAutomationValueForData(data:Object):Array
		{
			// convert the data (which is the data corresponding to the selected Item)
			var itemIndex:int = sparkList.dataProvider.getItemIndex(data)
			if(sparkList.dataGroup)
			{
				var delegate:IAutomationObject = sparkList.dataGroup.getElementAt(itemIndex) as IAutomationObject;
				if(delegate)
				{
					var automationValueArray:Array = delegate.automationValue;
					if(automationValueArray)
						return [ automationValueArray.join(" | ") ];
				}
			}
			else
			{
				// we may need to get the renderer deails for the dropdown list in a
				// different way as no renderers are available (and hence no datagroup)
				// itslef not present when the dropDown list is not visible.
				var message:String = "To be handled in SparkListBaseTabularData and it is happening in DropDownList - while getting selected item";
				Automation.automationDebugTracer.traceMessage("SparkListBaseTabularData","getAutomationValueForData()",message);
			}
			
			return [];
		}
		
		
		
	}
}
