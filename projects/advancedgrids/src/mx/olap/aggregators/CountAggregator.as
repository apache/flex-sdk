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
 *  The CountAggregator class  implements the count aggregator.
 *  The count aggregator returns the count of the measures.
 *  Flex uses this aggregator when you set the <code>OLAPMeasure.aggregator</code> property 
 *  to <code>"COUNT"</code>.
 *
 *  @see mx.olap.OLAPMeasure
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class CountAggregator implements IOLAPCustomAggregator
{
	//--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------
    
	//count functions.
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
		newObj[dataField] = [];
		newObj[dataField + "Counter"] = 0;
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
	public function computeLoop(data:Object, dataField:String, value:Object):void
	{
		if (!data.hasOwnProperty(dataField))
		{
			data[dataField] = [value[dataField]];
			data[dataField + "Counter"] = 1;
		}
		else
		{
			data[dataField].push(value[dataField]);
			data[dataField + "Counter"] = data[dataField + "Counter"] + 1;
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
		return data[dataField + "Counter"];
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
			if (oldValue[p] is Array)
				oldValue[p] = oldValue[p].concat(newValue[p]);
			else
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
		return oldValue[dataField + "Counter"];
	}
}
}
