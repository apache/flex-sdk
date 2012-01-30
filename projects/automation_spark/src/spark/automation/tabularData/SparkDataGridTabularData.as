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
    import flash.display.DisplayObject;
    
    import mx.automation.Automation;
    import mx.automation.IAutomationObject;
    import mx.automation.IAutomationTabularData;
    import mx.automation.delegates.controls.DataGridAutomationImpl;
    import mx.collections.CursorBookmark;
    import mx.collections.errors.ItemPendingError;
    import mx.controls.listClasses.ListBaseContentHolder;
    import mx.core.mx_internal;
    
    import spark.automation.delegates.components.SparkDataGridAutomationImpl;
    import spark.components.DataGrid;
    import spark.components.gridClasses.IGridItemRenderer;
    import spark.components.gridClasses.GridColumn;
    
    use namespace mx_internal;
    
    /**
     *  @private
     */
    public class SparkDataGridTabularData implements IAutomationTabularData
    {
        /**
         *  Constructor
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function SparkDataGridTabularData(dg:spark.components.DataGrid)
        {
            super();
            this.dg = dg;
        }
        
        /**
         *  @private
         */
        private var dg:spark.components.DataGrid;
        
        /**
         *  @private
         */
        public function get numColumns():int
        {
            return dg.columns.length;
        }
        
        /**
         *  @inheritDoc
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function get lastVisibleRow():int
        {
            /*var listItems:Array = ((dg.automationDelegate) as SparkDataGridAutomationImpl).getCompleteRenderersArray();
            
            if (listItems && listItems.length && listItems[0].length)
            {
                var row:int = listItems.length - 1;
                var col:int = listItems[0].length - 1;
                while (!listItems[row][col] && row >= 0 && col >= 0)
                {
                    if (col != 0)
                    {
                        col --;
                    }
                    else if (row != 0)
                    {
                        row--;
                        col = listItems[0].length - 1;
                    }
                }
                
                return (row >= 0 && col >= 0 
                    ? listItems[row][col].rowIndex 
                    : numRows);
            }
            
            return 0;*/
            var start:int = dg.grid.getVisibleRowIndices().length -1;
            return dg.grid.getVisibleRowIndices().slice(start).pop();
        }
        
        /**
         *  @inheritDoc
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function get numRows():int
        {
            return (dg.dataProvider? dg.dataProvider.length : 0);
        }
        
        /**
         *  @inheritDoc
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function getValues(start:uint = 0, end:uint = 0):Array
        {
            //empty list of column names for list, dg overrides
            var values:Array = [ ];
            var renderers:Array = (dg.automationDelegate as SparkDataGridAutomationImpl).getCompleteRenderersArray();
            
            var len:int = renderers.length;
            var col:int = dg.columns.length;
            for(var i:int = start ; i <= end; i++)
            {
                var autValue:String ="";
                var colValues:Array = [];
                for(var j:int = 0; j < col; j++)
                {
                    var autObj:IAutomationObject = renderers[i+1][j] as IAutomationObject;  //i+1 in order to by pass header item
                    if(autObj)
                    {
                        colValues.push(autObj.automationValue.join(" | "));
                        
                    }
                }
                values.push(colValues);
            }
            
            return values;
        }
        /**
         *  @private
         */
        public function get columnNames():Array
        {
            //override to provide the column names
            var result:Array = [];
            var colCount:int = dg.columns.length;
            var columns:Array = dg.columns.toArray();
            for (var i:int = 0; i < colCount; ++i)
            {
                if (columns[i].dataField)
                    result.push(columns[i].dataField);
                else 
                    result.push(columns[i].headerText);
                //for FileSystemDataGrid of AIR, the dataFiled is empty and the headerText
                // is directly assigned. To get the headerHeader text in those cases the above 
                // is added.
            }
            return result;
        }
        
        /**
         *  @private
         */
        
        
        public function get firstVisibleRow():int
        {
            return dg.grid.getVisibleRowIndices().slice(0,1).pop();
        }
        
        
        /**
         *  @private
         */
        public function getAutomationValueForData(data:Object):Array
        {
            var ret:Array = [];
            var colCount:int = dg.columns.length;
            var rowCount:int = dg.requestedRowCount;
            for (var colNo:int = 0; colNo < colCount; ++colNo)
            {
                //since visibleData data is only keyed per row
                //and doesn't include renderers for each column
                //we can't optimize by using it
                //var item:IListItemRenderer = visibleData[itemToUID(data)];
                var item:IGridItemRenderer;
                
                var c:GridColumn = dg.columns[colNo];
                //item = c.getMeasuringRenderer(false,data);
                /*item = c.itemToRenderer(data);
                if (item.owner == null) 
                    (dg.grid).addChild(DisplayObject(item));
                dg.setupRendererFromData(c, item, data);
                
                if(item is IAutomationObject)
                    ret.push(IAutomationObject(item).automationValue.join(" | "));*/
            }
            
            return ret;
        }
    }
}
