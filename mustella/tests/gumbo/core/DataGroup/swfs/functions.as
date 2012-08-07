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
	import spark.filters.DropShadowFilter;
	import spark.filters.BlurFilter;
	import flash.filters.BitmapFilterQuality;
	import mx.collections.*;
	import mx.graphics.SolidColorStroke;
	import mx.graphics.SolidColor;
	import mx.graphics.GradientEntry;
	import mx.graphics.LinearGradient;
	import spark.components.DataGroup;
	import spark.primitives.*;
	import spark.primitives.supportClasses.*;
//	import mx.graphics.baseClasses.*;
	import comps.*;
	import spark.skins.spark.*;
	import spark.components.Button;
	import mx.controls.Button;
	import spark.components.Group;
	
	import mx.collections.SortField;
	import mx.collections.Sort;
	import flash.events.Event;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;

	[Bindable]
	public var labelArr:Array=[{label: "top"},{label: "file"},{label:"I am a Menu"},{label:"here goes Nothing"},{label:"aw, don't sell yourself short"},{label:"can you check me?"}];
	[Bindable]
	public var abcArr:Array=[' ', '	', 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']; 
	[Bindable]
	public var emptyArr:Array=[];
	public var mixArr:Array= [{type: "color", label: "Green string", color: 0x00FF00},{type: "text", label: "This is a string"},{type:"checkBox", label: "Checked", value:true},
	{type:"checkBox", label: "Unchecked", value:false},{type: "text", label: "Second string"},
	  {type: "color", label: "Red string", color: 0xFF0000}];
	
	public var myRect:Rect;
	
	// for testing the enabled property
	public var testingEnabledOutput:String = "";
	
	// keep track of the results when testing events on datagroup.dataProvider
	// since can't seem to get Mustella to dig down directly
	public var collectionChangeResults:String;
	
	// for testing the enabled property
	public function handleClickEvent(e:Event):void {
		testingEnabledOutput += "[" + e.type + "]";	
	}	
	
	public function resetCollectionChangeResults():String 
	{
			collectionChangeResults = "";
			return "complete";
	}
	
	public function handleCollectionChangeResults(e:CollectionEvent):void 
	{
			collectionChangeResults += e.kind + "";
	}

	public function kickoffCollectionChangeMoveEvent(group1:DataGroup):int {
			var sort:Sort = new Sort();
			sort.fields = [new SortField("value",true)];
			ArrayCollection(group1.dataProvider).sort = sort;
			ArrayCollection(group1.dataProvider).refresh();
			group1.validateNow();
			group1.dataProvider.getItemAt(0).value = "yello1";
			group1.dataProvider.itemUpdated(group1.dataProvider.getItemAt(0)); 
			return 1;
	}
	
	public function nullItemRendererFunction(item:*):IFactory
	{
			return new ClassFactory(NullItemRenderer);
	}

	public function aligningItemRendererFunction(item:*):IFactory
	{
		if (item is DisplayObject || item is GraphicElement)
			return new ClassFactory(DataGroupJustifyItemRendererComplex);
		else
			return new ClassFactory(DataGroupJustifyItemRenderer);
	}
	
	public function dataGroupItemRendererFunctionSendingNulls(item:*):IFactory
	{
		// the item should only get a renderer if it doesnt have a DisplayObject Associated with it
		// so FxButton shouldn't have the justify background color, but strings should
		if (item is DisplayObject)
			return null;
		else
			return new ClassFactory(DataGroupJustifyItemRenderer);
	}	
	
	public function dataGroupItemRendererFunction(item:*):IFactory
	{
		if (item is DisplayObject || item is GraphicElement)
			return new ClassFactory(DataGroupDefaultItemRendererComplex);
		else
			return new ClassFactory(DataGroupDefaultItemRenderer);
	}
	
	public function getGroupWithScrollPositionThenLayout(vsp:int = 0, hsp:int = 0, clip:Boolean = true):DataGroup
	{
		var myGroup:DataGroup = new DataGroup();
		myGroup.verticalScrollPosition = vsp;
		myGroup.horizontalScrollPosition = hsp;
		myGroup.clipAndEnableScrolling = clip;
		myGroup.layout = new VerticalLayout();
		return myGroup;
	}			
	
	public function createLayeredItem(width:int, height:int, color:Number, depth:int = 0, x:int = 0, y:int = 0):Group {
		var myRect:Rect = new Rect();
		myRect.top = 0; myRect.left = 0;
		myRect.bottom=0; myRect.right=0;
		var myFill:SolidColor = new SolidColor();
		myFill.color = color;
		myRect.fill = myFill;
		
		// wrap the GraphicElement with a Group
		var wrapperGroup:Group = new Group();
		wrapperGroup.x = x;
		wrapperGroup.y = y;
		wrapperGroup.width = width;
		wrapperGroup.height = height;
		wrapperGroup.depth = depth;
		wrapperGroup.addElement(myRect);
		
		return wrapperGroup;
	}
	
	public function createButton(text:String):mx.controls.Button {
		var btn:mx.controls.Button = new mx.controls.Button();
		btn.label = text;
		return btn;
	}

	public function createFxButton(text:String, width:int = 0, height:int = 0, x:int = 0, y:int = 0):spark.components.Button {
		var btn:spark.components.Button = new spark.components.Button();
		btn.label = text;
		btn.width = width;
		btn.height = height;
		btn.x = x;
		btn.y = y;
		return btn;
	}

	public function customSwap(myGroup:DataGroup, index1:int, index2:int):void {
	
		// this code is taken from the swapElements() method on Group.as with the
		// item operations changed to apply to a DataGroup.
		
		if (index1 > index2){
			var temp:int = index2;
			index2 = index1;
			index1 = temp; 
		}
		
		else if (index1 == index2)
		return;
		
		var element2:Object = myGroup.dataProvider.removeItemAt(index2);
		var element1:Object = myGroup.dataProvider.removeItemAt(index1);
		
		myGroup.dataProvider.addItemAt(element2, index1);
		myGroup.dataProvider.addItemAt(element1, index2);
	
	}

	
	public function addVectorGraphicButton(myDataGroup:DataGroup):void {
		var myRect:Rect = new Rect();
		myRect.x = 0; 
		myRect.y = 0;
		myRect.width = 100;
		myRect.height = 100;
		
		var myFill:SolidColor = new SolidColor();
		myFill.color = 0x0000FF;
		myRect.fill = myFill;
		
		// wrap graphic elements in a Group
		var wrapperGroup:Group = new Group();
		wrapperGroup.x = myRect.x;
		wrapperGroup.y = myRect.y;
		wrapperGroup.width = myRect.width;
		wrapperGroup.height = myRect.height;
		wrapperGroup.addElement(myRect);
		
		myDataGroup.dataProvider.addItem(wrapperGroup);
	}
	
	/*
	 * Assert that these methods throw errors
	 */
	public function assertGroupError(method:String, myDataGroup:DataGroup):String {
	
		if(myDataGroup.dataProvider == null){
			myDataGroup.dataProvider = new ArrayCollection();
		}
	
		try {
		
			switch (method) {
	
				case "addChild":
					myDataGroup.addChild(new DataGroup());
					break;
				case "addChildAt":
					myDataGroup.addChildAt(new DataGroup(), 0);
					break;
				case "removeChild":
					myDataGroup.removeChild(new DataGroup());
					break;				
				case "removeChildAt":
					myDataGroup.removeChildAt(0);
					break;
				case "setChildIndex":
					myDataGroup.setChildIndex(new DataGroup(), 0);
					break;
				case "swapChildren":
					myDataGroup.swapChildren(new DataGroup(), new DataGroup());
					break;
				case "swapChildrenAt":
					myDataGroup.swapChildrenAt(0, 0);
					break;
				case "addItem(null)":
					myDataGroup.dataProvider.addItem(null);
					break;
				case "addItem(undefined)":
					myDataGroup.dataProvider.addItem(undefined);
					break;
				
			}
		
		} catch (error:Error) {
			return error.message;
		}
		
		return "no error";
		
	}
	
	public function playResizeEffect(effectTarget:Object, effectWidthTo:int, effectHeightTo:int):void {
		resizeEffect.target = effectTarget;
		resizeEffect.widthTo = effectWidthTo;
		resizeEffect.heightTo = effectHeightTo;
		
		resizeEffect.end();
		resizeEffect.play();
	}
	
	public function playMoveEffect(effectTarget:Object, effectXTo:int, effectYTo:int):void {
		moveEffect.target = effectTarget;
		moveEffect.xTo = effectXTo;
		moveEffect.yTo = effectYTo;
		
		moveEffect.end();
		moveEffect.play();
	}		
	
	public function applyGradientMask(myDataGroup:DataGroup):void {

		// create a gradient rect for the mask

		myRect = new Rect();
		//myRect.top = 0;
		//myRect.left = 0;
		//myRect.bottom = 0; 
		//myRect.right = 0;
		myRect.width = 50;
		myRect.height = 50;

		var myFill:LinearGradient = new LinearGradient();

		var g1:GradientEntry = new GradientEntry(0xFF00FF, 0, 0);
		var g2:GradientEntry = new GradientEntry(0x000000, 0.66, 1);

		myFill.entries = [ g1, g2 ];

		myRect.fill = myFill;

		addElement(myRect);


		// add the gradient to a masking DataGroup

		var maskGroup:Group = new Group();
		maskGroup.x = 0;
		maskGroup.y = 0;
		maskGroup.width = 50;
		maskGroup.height = 50;
		
		removeElement(myRect);
		maskGroup.addElement(myRect);
		
		// apply the mask to the DataGroup

		myDataGroup.mask = maskGroup;

	}
	
	
	public function applyMask(myDataGroup:DataGroup):void {
		var maskGroup:Group = new Group();
		maskGroup.x = 0;
		maskGroup.y = 0;
		maskGroup.width = 50;
		maskGroup.height = 50;
		addStretchRectToGroup(maskGroup);

		myDataGroup.mask = maskGroup;		
	}
	
	
	public function addShadowFilter(myDataGroup:DataGroup):void {            
		var f:DropShadowFilter = new DropShadowFilter(5,30,0x444444,0.8);
		var myFilters:Array = myDataGroup.filters;
		
		if (myFilters == null)
			myFilters = new Array();
			
		myFilters.push(f);
		myDataGroup.filters = myFilters;
	}
	
	public function addBlurFilter(myDataGroup:DataGroup):void {
		var f:BlurFilter = new BlurFilter(3, 3, BitmapFilterQuality.HIGH);
		var myFilters:Array = myDataGroup.filters;
		
		if (myFilters == null)
			myFilters = new Array();
		
		myFilters.push(f);
		myDataGroup.filters = myFilters;
	}
			
	public function setContentToArrayCollection(myDataGroup:DataGroup, myArray:Array):void {
		var myArrayCollection:ArrayCollection = new ArrayCollection(myArray);
		myDataGroup.dataProvider = myArrayCollection;
	}  
	  
	public function addLine(myDataGroup:DataGroup):void {
		var myLine:Line = new Line();
		//myLine.xFrom = 10; myLine.yFrom = 15;
		myLine.xTo=40; myLine.yTo=40;
		var mySolidColorStroke:SolidColorStroke = new SolidColorStroke();
		mySolidColorStroke.color = 0xAB0000;
		myLine.stroke = mySolidColorStroke;
		
		// wrap the GraphicElement with a Group
		var wrapperGroup:Group = new Group();
		wrapperGroup.x = 10;
		wrapperGroup.y = 15;
		
		wrapperGroup.addElement(myLine);
		
		myDataGroup.dataProvider.addItem(wrapperGroup);
	}
	
	public function addRect(myDataGroup:DataGroup):void{
		var myRect:Rect = new Rect();
		myRect.top = 0; myRect.left = 0;
		myRect.bottom=0; myRect.right=0;
		var myFill:SolidColor = new SolidColor();
		myFill.color = 0x123456;
		myRect.fill = myFill;
		
		// wrap the GraphicElement with a Group
		var wrapperGroup:Group = new Group();
		wrapperGroup.x = 30;
		wrapperGroup.y = 40;
		wrapperGroup.width = 15;
		wrapperGroup.height = 30;
		wrapperGroup.addElement(myRect);
		
		myDataGroup.dataProvider.addItem(wrapperGroup);
	}
	
	public function addStretchRect(myDataGroup:DataGroup):void {
	
		// make sure the dataProvider has been instantiated
		if(myDataGroup.dataProvider == null){
			myDataGroup.dataProvider = new ArrayCollection();
		}
		
		var myRect:Rect = new Rect();
		myRect.top = 0; myRect.left = 0;
		myRect.bottom=0; myRect.right=0;
		var myFill:SolidColor = new SolidColor();
		myFill.color = 0xFF0000;
		myRect.fill = myFill;
		
		// wrap the GraphicElement with a Group
		var wrapperGroup:Group = new Group();
		wrapperGroup.top = 0;
		wrapperGroup.left = 0;
		wrapperGroup.right = 0;
		wrapperGroup.bottom = 0;
		wrapperGroup.addElement(myRect);			
	
		myDataGroup.dataProvider.addItem(wrapperGroup);
	}
	
	public function addStretchRectToGroup(myGroup:Group):void {
		var myRect:Rect = new Rect();
		myRect.top = 0; myRect.left = 0;
		myRect.bottom=0; myRect.right=0;
		var myFill:SolidColor = new SolidColor();
		myFill.color = 0xFF0000;
		myRect.fill = myFill;
		myGroup.addElement(myRect);
	}

	public function addCustomRect(myDataGroup:DataGroup, width:int, height:int, color:Number, xPos:int = 0, yPos:int = 0):void {
		// check that the DataGroup has its dataProvider instantiated first
		// for Ryan's change 9/29/08
		if(myDataGroup.dataProvider == null){
			myDataGroup.dataProvider = new ArrayCollection();
		}
		
		var myRect:Rect = new Rect();
		myRect.left = 0; myRect.top = 0;
		myRect.bottom=0; myRect.right=0;
		var myFill:SolidColor = new SolidColor();
		myFill.color = color;
		myRect.fill = myFill;
		
		// wrap the GraphicElement with a Group
		var wrapperGroup:Group = new Group();
		wrapperGroup.x = xPos;
		wrapperGroup.y = yPos;
		wrapperGroup.width = width;
		wrapperGroup.height = height;
		wrapperGroup.addElement(myRect);
		
		myDataGroup.dataProvider.addItem(wrapperGroup);
	}	
	
	public function addEllipseAt(myDataGroup:DataGroup, i:int):void	{
		var myEllipse:Ellipse = new Ellipse();
		myEllipse.width=40;
		myEllipse.height=30;
		var myFill:SolidColor = new SolidColor();
		myFill.color = 0x9966FF;
		myEllipse.fill = myFill;
		
		// wrap the GraphicElement with a Group
		var wrapperGroup:Group = new Group();
		wrapperGroup.x = myEllipse.x;
		wrapperGroup.y = myEllipse.y;
		wrapperGroup.width = myEllipse.width;
		wrapperGroup.height = myEllipse.height;
		wrapperGroup.addElement(myEllipse);
		
		myDataGroup.dataProvider.addItemAt(wrapperGroup, i);			
	}
        	
	public function myItemRendererFunction(item:*):IFactory
	{
		if(item.type == "text")
			return (new ClassFactory(LabelRenderer));
		else if (item.type == "checkBox" )
			return (new ClassFactory(CheckBoxRenderer)) 
		else if (item.type == "color" )
			return (new ClassFactory(ColorLabelRenderer))			
		return (item);
	}        	

	public function skewGroup(myDataGroup:DataGroup):void {
		var currentMatrix:Matrix = myDataGroup.transform.matrix;
		var skewMatrix:Matrix = new Matrix();
		
        	skewMatrix.c = 1;
        
       		myDataGroup.transform.matrix = skewMatrix;
	
	}
		
	public function skewGroupViaTransform(myDataGroup:DataGroup):void {
		var currentTransform:Transform = myDataGroup.transform;
		var currentMatrix:Matrix = myDataGroup.transform.matrix;
		var skewMatrix:Matrix = new Matrix();
		
       	skewMatrix.c = 1;
        
   		currentTransform.matrix = skewMatrix;
		
		myDataGroup.transform = currentTransform;
	
	}
	
	public function colorTransform(myDataGroup:DataGroup):void {
		var currentColorTransform:ColorTransform = myDataGroup.transform.colorTransform;
		
		var redOffset:Number  = 100;
		var blueOffset:Number = 100;
		
		var colorTransform:ColorTransform = new ColorTransform(1, 1, 1, 1, redOffset, 0, blueOffset, 0);
	
		myDataGroup.transform.colorTransform = colorTransform;
	
	}	
		
	public function rotateTransform(myDataGroup:DataGroup, degrees:Number):void {
	
		var newMatrix:Matrix = myDataGroup.transform.matrix;
		newMatrix.rotate(degrees * (Math.PI / 180));
		//newMatrix.concat(myDataGroup.transform.matrix);

		myDataGroup.transform.matrix = newMatrix;

	}
	
	public function createSubgroup(myDataGroup:DataGroup):void {
		var subDataGroup:DataGroup = new DataGroup();
		subDataGroup.itemRendererFunction = dataGroupItemRendererFunction;
		
		// check that the DataGroup has its dataProvider instantiated first
		// for Ryan's change 9/29/08
		if(myDataGroup.dataProvider == null){
			myDataGroup.dataProvider = new ArrayCollection();
		}
		
		myDataGroup.dataProvider.addItem(subDataGroup);
	}
	
	public function createSubgroupAt(myDataGroup:DataGroup, width:int, index:int):void {
			
		var newSubDataGroup:DataGroup = new DataGroup();
		newSubDataGroup.width = width;
		myDataGroup.dataProvider.addItemAt(newSubDataGroup, index);
			
	}
	
	public function setLayoutAndRenderer(myDataGroup:DataGroup):void {
		var newLayout:VerticalLayout = new VerticalLayout();
		newLayout.useVirtualLayout = true;
		
		// set the renderer and layout at the same time
		myDataGroup.layout = newLayout;
		myDataGroup.itemRenderer = new ClassFactory(comps.ColorItemRenderer);
	}
	
	 import mx.collections.Sort;
            
     public function sortFunction (a:*, b:*, fields:Array = null):int {
         return a.num < b.num ? -1 : (a.num == b.num ? 0 : 1);
     }
     
     public function sortDataProvider(dp:ArrayCollection):void {
         dp.sort = new Sort();
         dp.sort.compareFunction = sortFunction;
         dp.refresh();
     }
            