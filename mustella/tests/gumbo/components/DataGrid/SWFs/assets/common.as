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
	include "nameData.as";
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	import mx.collections.ListCollectionView;
	import mx.collections.IList;
	import mx.core.mx_internal;
	import mx.events.ListEvent;
	import mx.events.FlexEvent;
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import spark.components.DataGrid;
	
	import spark.components.gridClasses.GridSelection;
	import spark.components.gridClasses.GridSelectionMode;
	import spark.components.gridClasses.CellPosition;
	


	private var originalRowIndexHolder:ArrayList;
	private var originalColumnIndexHolder:ArrayList;
	public var keyword:String="";

	public function randomArrayItem(a:Array):String
	{
		return (a.length == 0) ? "<empty>" : a[Math.round(Math.random() * (a.length - 1))];
	}	


	//debugging method
	public function displaySelectedCellIndices(v:Vector.<CellPosition>):void
	{
		var n:int=v.length;
		var msg:String;
		for (var i:int=0;i<n;i++){
			msg+=CellPosition(v[i]).toString()+"\n";
		}
		trace(msg);
	}
	public function displaySelectedIndices(v:Vector.<int>):void
	{
		var n:int=v.length;
		for (var i:int=0;i<n;i++)
			trace("selected index="+v.pop());
	}
			
	public function createFixedItem(index:int):Object
	{
		const firstName:String ="Charles";
		const lastName:String = "Nasnas";
		const food:String = "seafood";
		const drink:String ="cocktail";
		const hobby:String = "golf";
		const occupancy:String ="sales person" ;
		return {index:index, firstName: firstName, lastName: lastName, food: food, drink: drink};
	}
	
	public function createItem(index:int):Object
	{
		if (index>=100) index=index-(int(index/100))*100;
		const firstName:String = humanNamesData[index];
		const lastName:String = humanNamesData[index];
		const food:String = foodNamesData[index];
		const drink:String = drinkNamesData[index];
		return {index:index, firstName: firstName, lastName: lastName, food: food, drink: drink};
	}
	public function addItem(dataGrid:DataGrid,index:int):void
	{
		if (dataGrid.dataProvider is XMLListCollection)
			dataGrid.dataProvider.addItemAt(createXMLItem(dataGrid.dataProvider.length+1),index);
		else 
			dataGrid.dataProvider.addItemAt(createItem(dataGrid.dataProvider.length+1),index);
	}
	public function removeItem(dataGrid:DataGrid,index:int):void
	{
		dataGrid.dataProvider.removeItemAt(index);
	}
	public function updateItem(dataGrid:DataGrid,index:int):void
	{
		if (dataGrid.dataProvider is XMLListCollection)
			dataGrid.dataProvider.setItemAt(createXMLItem(index),index);
		else 
			dataGrid.dataProvider.itemUpdated(dataGrid.dataProvider.getItemAt(index),"firstName",dataGrid.dataProvider.getItemAt(index)['firstName'],"blablabla");
	}
	public function insertColumns(dataGrid:DataGrid,index:int, count:int):void
	{
		
		for (var i:int=0;i<count;i++)
		{
			//	dataGrid.grid.gridSelection.setRow(index+i);
			trace("row="+(index+i));
			createColumn2(dataGrid,i);
		}

	}	
	private function createColumn2(dataGrid:DataGrid,index:int):void
	{
		const columnName:String = "colmn_"+index;
		var obj:Object;
		var columnObj:GridColumn;
		
		if (dataGrid.dataProvider.length==0)
		{
		
			//create 10 data
			for (var j:int=0;j<10;j++)
			{
				obj=createItem(j);
				obj[columnName]="value_"+j;
				dataGrid.dataProvider.addItem(obj);
			}
		}else{
		
			for (var i:int=0;i<dataGrid.dataProvider.length;i++)
			{
				obj=dataGrid.dataProvider.getItemAt(i);
				//add the new column data
				obj[columnName]="value_"+i;
			}
		}
		trace("columns.length="+dataGrid.columns.length);
		columnObj=new GridColumn();
		columnObj.dataField=columnName;
		if (dataGrid.columns.length==0)
			dataGrid.columns.addItem(columnObj);
		else 
		dataGrid.columns.addItemAt(columnObj,dataGrid.columns.length-1);
	}
	public function createXMLItem(index:int):XML
	{
		var obj:Object=createItem(index);
		var tmp:String="<person index="+"\""+obj.index+"\" firstName="+"\""+obj.firstName+"\" lastName=\""+obj.lastName+"\" food=\""+obj.food+"\" drink=\""+obj.drink+"\"/>";
		return new XML(tmp);
	}

	public function createXMLListCollection(length:int):XMLListCollection
	{
		var tmp:String="";
		var firstName:String,lastName:String, food:String, drink:String;
		var xmlStr:String="";
		for (var i:int = 0; i < length; i++)
		{
			firstName= humanNamesData[i];
			lastName= humanNamesData[i];
			food= foodNamesData[i];
			drink= drinkNamesData[i];
			tmp="<person index="+"\""+i+"\" firstName="+"\""+firstName+"\" lastName=\""+lastName+"\" food=\""+food+"\" drink=\""+drink+"\"/>";
			xmlStr+=tmp+"\n";
		}
		return new XMLListCollection(new XMLList(xmlStr));
	}
	
	public function applyFilter2(dataGrid:DataGrid):void
	{
		if (dataGrid.dataProvider is ListCollectionView)
		{
			ListCollectionView(dataGrid.dataProvider).filterFunction=excludeFirstNameContain;
			ListCollectionView(dataGrid.dataProvider).refresh();
		}
	}
	public function excludeFirstNameContain( item:Object ):Boolean
	{
		if (item is XML)
		{
			var xmlList:XMLList=XML(item).attribute("firstName");
			for each(item in xmlList) {
				if (item.toXMLString().indexOf(keyword))
					return false;
				else return true;
			}
			return true;
		}else {
			if( String(item["firstName"]).indexOf(keyword))
				return false;
			else return true;
		}
	}
				
			
	public function storeRowColumnIndices(rowIndices:Vector.<int>,columnIndices:Vector.<int>):void
	{

		originalRowIndexHolder=createArrayList(rowIndices);
		originalColumnIndexHolder=createArrayList(columnIndices);
		trace("originalRowIndexHolder="+originalRowIndexHolder);
	}
	public function createArrayList(v:Vector.<int>):ArrayList
	{
		var arr:ArrayList=new ArrayList();
		var n:int=v.length;
		for (var i:int=0;i<n;i++)
			arr.addItem(v.pop());
		return arr;
	}

	public function adjustRowColumnIndex(newRowIndices:Vector.<Object>):ArrayList
	{
		var n:int=newRowIndices.length;

		var arr:ArrayList=new ArrayList();
		var obj:Object;
		var oldIndex:int;
		var columnVal:int;
		for (var i:int=0;i<n;i++)
		{
			obj=newRowIndices.pop();
			trace("obj="+obj+";"+obj["oldIndex"]);
			oldIndex=findRowIndexPos(obj["oldIndex"]);
			if (oldIndex==-1) continue;
			columnVal=int(originalColumnIndexHolder.getItemAt(oldIndex));
			trace("new row/column:"+obj["newIndex"]+","+columnVal);
			arr.addItem({"rowIndex":obj["newIndex"],"columnIndex":columnVal});

		}
		return arr;

	}

	private function findRowIndexPos(oldIndex:int):int
	{

		var n:int=originalRowIndexHolder.length;
		var obj:Object;
		for (var i:int=0;i<n;i++)
		{
			obj=originalRowIndexHolder.getItemAt(i);
			trace("findRowIndexPos:obj="+obj);
			if (oldIndex==int(obj))
			{
				originalRowIndexHolder.removeItemAt(i);
				return i;
			}
		}
		return -1;
	}			