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
