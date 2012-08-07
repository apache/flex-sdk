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
import mx.collections.ArrayList;
import spark.collections.*;
import mx.controls.Button;

import spark.components.Button;
import spark.components.DataGroup;
import spark.layouts.*;
import spark.skins.spark.*;

// This is an optimization to workaround a Mustella performance bug.  Some things don't get garbage collected
// so only instantiating the ArrayList once and then clearing and refilling it saves a ton of memory
public var cachedItemList:ArrayList = new ArrayList();

// Keeps track of number of renderers fired
public var rendererAddCounter:int = 0;

public function updateRendererCounter(event:Event):void {
	rendererAddCounter++;
}

public function setupVerticalVirtualizationTest(dg:DataGroup):Boolean {
	dg.width  = 100;
	dg.height = 300;
	dg.layout = new VerticalLayout();
	dg.clipAndEnableScrolling = true;
	dg.itemRendererFunction = virtualizationItemRendererFunction;
	
	return true;	
}

public function setupHorizontalVirtualizationTest(dg:DataGroup):Boolean {
	dg.width  = 300;
	dg.height = 100;
	dg.layout = new HorizontalLayout();
	dg.clipAndEnableScrolling = true;
	dg.itemRendererFunction = virtualizationItemRendererFunction;
	
	return true;	
}	

public function setupTileLayoutVirtualizationTest(dg:DataGroup, orientation:String = 'rows'):Boolean {
	dg.width  = 500;
	dg.height = 500;
	dg.layout = new TileLayout();
	dg.layout.useVirtualLayout = true;
	(TileLayout(dg.layout)).orientation = orientation;
	dg.clipAndEnableScrolling = true;
	dg.itemRenderer = new ClassFactory(VirtualizationItemRenderer);
	
	return true;
}	


/**
 * Provide a generic method that returns an ArrayList of simple integers from 0 .. num
 */
public function createSimpleIncreasingItems(num:int):ArrayList {
    var ac:ArrayList = new ArrayList();
    
    for (var i:int = 0; i < num; i++){
        ac.addItem(i);
    }
    return ac;
}

public function createEvenOddItems(num:int):ArrayList {
    return createSimpleIncreasingItems(num);
}


public function createRandomItems(nItems:int, axis:String):ArrayList {
    var items:Array = new Array(nItems);
    for(var i:int = 0; i < nItems; i++)
        items[i] = {myItemIndex: i, majorAxis: axis, minorSize: 100, majorSize: int(Math.random() * (50) + 20)};
     
	cachedItemList.source = items;
		
	return cachedItemList;
} 

public function createLargeSmallItems(nItems:int, axis:String):ArrayList {
	var items:Array = new Array();
	for (var i:int = 0; i < nItems; i++){
		if (i % 2 == 0){
			items.push({myItemIndex: i, majorAxis: axis, minorSize: 100, majorSize: 10});
			items.push({myItemIndex: i, majorAxis: axis, minorSize: 100, majorSize: 10});
			items.push({myItemIndex: i, majorAxis: axis, minorSize: 100, majorSize: 10});
			items.push({myItemIndex: i, majorAxis: axis, minorSize: 100, majorSize: 10});
		} else {
			items.push({myItemIndex: i, majorAxis: axis, minorSize: 100, majorSize: 200});
			items.push({myItemIndex: i, majorAxis: axis, minorSize: 100, majorSize: 200});
			items.push({myItemIndex: i, majorAxis: axis, minorSize: 100, majorSize: 200});
			items.push({myItemIndex: i, majorAxis: axis, minorSize: 100, majorSize: 200});
		}
	
	}
	
	cachedItemList.source = items;
		
	return cachedItemList;
}

public function createGroupedSmallLargeItems(nItems:int, groupSize:int, axis:String):ArrayList {
	var items:Array = new Array();
	var numBunches:int = nItems / groupSize;
	var uniqueID:int = 0;
	
	for (var i:int = 0; i < numBunches; i++){
		if (i % 2 == 0){
			for (var j:int = 0; j < groupSize; j++){
				items.push({myItemIndex: uniqueID++, majorAxis: axis, minorSize: 100, majorSize: 10});
			}
		} else {
			for (var k:int = 0; k < groupSize; k++){
				items.push({myItemIndex: uniqueID++, majorAxis: axis, minorSize: 100, majorSize: 200});
			}
		}
	
	}
	
	cachedItemList.source = items;
		
	return cachedItemList;
}   	

public function createMixedItems(nItems:int, axis:String):ArrayList {
	var items:Array = new Array();
	var localMajorSize:int = 24;
	var localMinorSize:int = 100;
	
	var localWidth:int = 0;
	var localHeight:int = 0;
	
	if (axis == "vertical"){
		localWidth = localMinorSize;
		localHeight = localMajorSize;
	}
	if (axis == "horizontal"){
		localWidth = localMajorSize;
		localHeight = localMinorSize;
	}
	
	for (var i:int = 0; i < nItems; i++){
		items.push({myItemIndex: i, majorAxis: axis, minorSize: localMinorSize, majorSize: localMajorSize});

		var newBtn:spark.components.Button = new spark.components.Button();
		if(axis == 'vertical')
			newBtn.label = "btn"+i;
		newBtn.height = localHeight;
		newBtn.width = localWidth;
		items.push(newBtn);
		
		var haloBtn:mx.controls.Button = new mx.controls.Button();
		if(axis == 'vertical')
			haloBtn.label = "halobtn"+i;
		haloBtn.height = localHeight;
		haloBtn.width = localWidth;
		items.push(haloBtn);
	}
	
	cachedItemList.source = items;
		
	return cachedItemList;
}
   
public function createIdenticalItems(numItems:int, objMinor:int, objMajor:int, axis:String):ArrayList {
	
	var tempArray:Array = new Array(numItems);
	
	for (var i:int = 0; i < numItems; i++){
		tempArray[i] = ({myItemIndex: i, majorAxis: axis, minorSize: objMinor, majorSize: objMajor});
	}

	cachedItemList.source = tempArray;
		
	return cachedItemList;
}	  	

public function createGrowingItems(nItems:int, axis:String, sizeLimit:int = 1000):ArrayList {
	var tempArray:Array = new Array();
	for (var i:int = 0; i < nItems; i++){
		tempArray[i] = ({myItemIndex: i, majorAxis: axis, minorSize: 100, majorSize: (i % sizeLimit)});
	}
	cachedItemList.source = tempArray;
	
	return cachedItemList;
}   

public function createVariableItems(nItems:int, axis:String):ArrayList {
	var tempArray:Array = new Array(nItems);
	for (var i:int = 0; i < nItems; i++){
		tempArray[i] = ({myItemIndex: i, majorAxis: axis, minorSize: 100, majorSize: (20 + ((20 * i) % 100))});
	}
	
	cachedItemList.source = tempArray;
	
	return cachedItemList;
}  

public function createEstimationItems(nItems:int, axis:String):ArrayList {
	var items:Array = new Array();
	items.push({myItemIndex: 0, majorAxis: axis, minorSize: 100, majorSize: 1});
	items.push({myItemIndex: 1, majorAxis: axis, minorSize: 100, majorSize: 100});
	for (var i:int = 2; i < nItems; i++){
		items.push({myItemIndex: i, majorAxis: axis, minorSize: 100, majorSize: 20});
	}
	
	cachedItemList.source = items;
		
	return cachedItemList;
}    

public function createLargeItems(nItems:int, axis:String):ArrayList {
	var items:Array = new Array();
	for (var i:int = 0; i < nItems; i++){
		items.push({myItemIndex: i, majorAxis: axis, minorSize: 100, majorSize: 1000});
	}
	
	cachedItemList.source = items;
		
	return cachedItemList;
} 

public function createDuplicateItems(nItems:int, axis:String):ArrayList {
	var items:Array = new Array();
	var localMinorSize:int = 100;
	var localMajorSize:int = 24;
	
	var dupItem1:Object = {myItemIndex:-1, majorAxis: axis, minorSize: localMinorSize, majorSize: localMajorSize};
	var dupItem2:Object = {myItemIndex:-2, majorAxis: axis, minorSize: localMinorSize, majorSize: localMajorSize};
	
	for (var i:int = 0; i < nItems; i++){
		items.push({myItemIndex: i, majorAxis: axis, minorSize: localMinorSize, majorSize: localMajorSize});
		items.push(dupItem1);
		items.push(dupItem2);
	}
	
	cachedItemList.source = items;
		
	return cachedItemList;
}      	  	

public function virtualizationItemRendererFunction(item:*):IFactory {
	if (item is DisplayObject)
		return null;
	else
		return new ClassFactory(VirtualizationItemRenderer);
}

public function colorItemRendererFunction(item:*):IFactory {
	if (item is DisplayObject)
		return null;
	else
		return new ClassFactory(ColorItemRenderer);
}

public function fancyItemRendererFunction(item:*):IFactory {
	if (item is DisplayObject)
		return null;
	else
		return new ClassFactory(FancyItemRenderer);
}

public function stateItemRendererFunction(item:*):IFactory {
	if (item is DisplayObject)
		return null;
	else
		return new ClassFactory(StateItemRenderer);
}
