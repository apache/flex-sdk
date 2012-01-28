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
 *  The MinAggregator class  implements the minimum aggregator.
 *  The minimum aggregator returns the minimum value of all measures.
 *  Flex uses this aggregator when you set the <code>OLAPMeasure.aggregator</code> property 
 *  to <code>"MIN"</code>.
 *
 *  @see mx.olap.OLAPMeasure
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class MinAggregator implements IOLAPCustomAggregator
{
	//--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------
    
    // min fucntions
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
        var newObj:Object = {};
        newObj[dataField] = Number.MAX_VALUE;
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
            data[dataField] = value;
        else
            data[dataField] =  data[dataField] < value ? data[dataField] : value;
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
        return data[dataField];
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
        for (var p:String in newValue)
        {
            oldValue[p] = oldValue[p] < newValue[p] ? oldValue[p] : newValue[p];
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
        return oldValue[dataField];
    }
}
}