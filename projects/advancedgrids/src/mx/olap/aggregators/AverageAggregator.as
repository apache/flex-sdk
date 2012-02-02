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


package mx.olap.aggregators
{
import mx.olap.IOLAPCustomAggregator;

/**
 *  The AverageAggregator class  implements the average aggregator.
 *  The average aggregator returns the average value of the measures.
 *  Flex uses this aggregator when you set the <code>OLAPMeasure.aggregator</code> property 
 *  to <code>"AVG"</code>.
 *
 *  @see mx.olap.OLAPMeasure
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class AverageAggregator implements IOLAPCustomAggregator
{
	//--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function computeBegin(dataField:String):Object
    {
    	//to start initialize the sum and count fields to zero.
        var newObj:Object = {};
        newObj[dataField] = 0;
        newObj[dataField + "Count"] = 0;
        return newObj;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function computeLoop(data:Object, dataField:String, rowData:Object):void
    {
    	var value:Number = rowData[dataField];				
    	if (typeof(value) == "xml")
			value = Number(value.toString());

        if (!data.hasOwnProperty(dataField))
        {
            data[dataField] = value;
            data[dataField + "Count"] = 1;
        }
        else
        {
            data[dataField] += value;
            data[dataField + "Count"] = data[dataField + "Count"] + 1;
        }
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function computeEnd(data:Object, dataField:String):Number
    {
        return data[dataField]/data[dataField + "Count"];
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function computeObjectBegin(value:Object):Object
    {
    	//start accumulating the sum and count values into
    	//separate properties
        var newObj:Object = {};
        for (var p:String in value)
        {
            newObj[p] = value[p];
        }
        return newObj;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function computeObjectLoop(oldValue:Object, newValue:Object):void
    {
    	//add sum to sum and count to count
        for (var p:String in newValue)
        {
            oldValue[p] += newValue[p];
        }
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function computeObjectEnd(oldValue:Object, dataField:String):Number
    {
    	//divide the total sum by the total count to get the avg value
        return oldValue[dataField]/oldValue[dataField + "Count"];;
    }
}
}