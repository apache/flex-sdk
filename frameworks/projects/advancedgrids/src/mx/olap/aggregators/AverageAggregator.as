////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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