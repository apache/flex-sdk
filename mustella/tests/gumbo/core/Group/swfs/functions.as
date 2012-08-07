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
	import mx.graphics.*;
	import spark.primitives.*;
	import comps.*;
	import spark.skins.spark.*;
	import spark.primitives.supportClasses.*;
	import mx.controls.Image;
	import mx.controls.Button;
	import spark.components.Button;
	import mx.controls.Label;
	
	import spark.layouts.*;
	import spark.components.Group;
	import spark.components.VGroup;	
	import spark.components.HGroup;
	import spark.components.SkinnableContainer;
	import mx.core.Container;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;	
	import mx.events.FlexEvent;
	
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
	
	// for testing the add event off of a UIComponent
	public var testingAddEventOutput:String = "";
	public var testingAddEventButton:mx.core.UIComponent;

	public var preinitializeMethodInput:String = "";
	public var preinitializeMethodOutput:String = "";
	public var preinitializeGroup:Group;
	
	// for testing the enabled property
	public function handleClickEvent(e:Event):void {
		testingEnabledOutput += "[" + e.type + "]";	
	}
	
	public function runPreinitializeTest(testInput:String):Boolean {
		// remember which method is being tested
		preinitializeMethodInput = testInput;
		preinitializeMethodOutput = "";
		
		preinitializeGroup = new Group();
		preinitializeGroup.addEventListener(FlexEvent.PREINITIALIZE, handlePreinitializeTest);
		preinitializeGroup.mxmlContent = [ new spark.components.Button(), new mx.controls.Button(), new Label() ];
		group1.addElement(preinitializeGroup);
		
		return true;
	}
	
	public function handlePreinitializeTest(e:Event):void {
		
		// make sure each of the IVisualElementContainer methods don't throw RTEs
		
		try {
			if(preinitializeMethodInput == "addElement")
				e.target.addElement(new spark.components.Button());
			if(preinitializeMethodInput == "addElementAt")
				e.target.addElementAt(new spark.components.Button(), 1);
			if(preinitializeMethodInput == "getElementAt")
				e.target.getElementAt(0);
			if(preinitializeMethodInput == "getElementIndex")
				e.target.getElementIndex(e.target.getElementAt(0));
			if(preinitializeMethodInput == "removeElement")
				e.target.removeElement(e.target.getElementAt(0));	
			if(preinitializeMethodInput == "removeElementAt")
				e.target.removeElementAt(0);	
			if(preinitializeMethodInput == "setElementIndex")
				e.target.setElementIndex(e.target.getElementAt(1), 2);	
			if(preinitializeMethodInput == "swapElements")
				e.target.swapElements(e.target.getElementAt(1), e.target.getElementAt(2));
			if(preinitializeMethodInput == "swapElementsAt")
				e.target.swapElementsAt(1, 2);
		} catch(e:Error) {
			preinitializeMethodOutput = "error caught";
			return;
		}
		
		preinitializeMethodOutput = "no error";
	}
	
	public function getGroupWithScrollPositionThenLayout(vsp:int = 0, hsp:int = 0, clip:Boolean = true):Group
	{
		var myGroup:Group = new Group();
		myGroup.verticalScrollPosition = vsp;
		myGroup.horizontalScrollPosition = hsp;
		myGroup.clipAndEnableScrolling = clip;
		myGroup.layout = new VerticalLayout();
		return myGroup;
	}				
		
	public function setupGetScrollPositionDeltaTest_HorizontalLayout(myGroup:Group):void {
		addCustomRect(myGroup, 50,  100, 0x111111);
		addCustomRect(myGroup, 20,  100, 0x444444);
		addCustomRect(myGroup, 500, 100, 0x777777);
		addCustomRect(myGroup, 10,  100, 0xAAAAAA);
		addCustomRect(myGroup, 25,  100, 0xEEEEEE);
		addCustomRect(myGroup, 250, 100, 0x0000FF);
		addCustomRect(myGroup, 200, 100, 0x0000FF);
	}

	public function setupGetScrollPositionDeltaTest_VerticalLayout(myGroup:Group):void {
		addCustomRect(myGroup, 100, 50,  0x111111);
		addCustomRect(myGroup, 100, 20,  0x444444);
		addCustomRect(myGroup, 100, 500, 0x777777);
		addCustomRect(myGroup, 100, 10,  0xAAAAAA);
		addCustomRect(myGroup, 100, 25,  0xEEEEEE);
		addCustomRect(myGroup, 100, 250, 0x0000FF);
		addCustomRect(myGroup, 100, 200, 0x0000FF);
	}

	public function setupGetScrollPositionDeltaTest_BasicLayout(myGroup:Group):void {
		myGroup.addElement(createFxButton("Item 0", 75,  50,  0,   0));
		myGroup.addElement(createFxButton("Item 1", 75,  50,  150, 25));
		myGroup.addElement(createFxButton("Item 2", 75,  50,  85,  85));
		myGroup.addElement(createFxButton("Item 3", 75,  50,  100, 225));	
		myGroup.addElement(createFxButton("Item 4", 250, 250, 50,  100));
		myGroup.addElement(createFxButton("Item 5", 200, 200, 300, 200));
		myGroup.addElement(createFxButton("Item 6", 400, 100, 350, 125));
		myGroup.addElement(createFxButton("Item 7", 100, 400, 125, 350));
		myGroup.addElement(createFxButton("Item 8", 20, 220, 190, -10));
		myGroup.addElement(createFxButton("Item 9", 220, 20, -10, 190));
		myGroup.addElement(createFxButton("Item 10", 20, 220, 170, -10));
		myGroup.addElement(createFxButton("Item 11", 220, 20, -10, 170));
		
		
	}
	
	public function createButton(customLabel:String = 'Button'):mx.controls.Button {
			var btn:mx.controls.Button = new mx.controls.Button();
			btn.label = customLabel;
			return btn;
	}
	
	public function createFxButton(customLabel:String = 'FxButton', width:int = 20, height:int = 20, x:int = 0, y:int = 0):spark.components.Button {
			var btn:spark.components.Button = new spark.components.Button();
			btn.label = customLabel;
			btn.width = width;
			btn.height = height;
			btn.x = x;
			btn.y = y;
			return btn;
	}
	
	public function addVectorGraphicButton(myGroup:Group):void {
		    var myRect:Rect = new Rect();
		    myRect.x = 0; 
		    myRect.y = 0;
		    myRect.width = 100;
		    myRect.height = 100;
		    
		    var myFill:SolidColor = new SolidColor();
		    myFill.color = 0x0000FF;
		    myRect.fill = myFill;
		    myGroup.addElement(myRect);
	}
	
	/*
	 * Assert that these methods throw errors
	 */
	public function assertGroupError(method:String, myGroup:Group):String {
	
		try {
		
			switch (method) {
			
				case "layout = new TileLayout()":
					group1.layout = new TileLayout()
					break;
				case "getElementIndex(subgroup1)":
					group1.getElementIndex(this.subgroup1);
					break;					
				case "getElementIndex(group1)":
					group1.getElementIndex(group1);
					break;
				case "getElementIndex(group1.getElementAt(90))":
					group1.getElementIndex(group1.getElementAt(90));
					break;	
				case "getElementAt(0)":
					group1.getElementAt(0);
					break;
				case "getElementAt(30)":
					group1.getElementAt(30);
					break;
				case "removeElementAt(0)":
					group1.removeElementAt(0);
					break;
				case "removeElementAt(30)":
					group1.removeElementAt(30);
					break;
				case "getElementAt(0)":
					myGroup.getElementAt(0);
					break;
				case "getElementAt(30)":
					myGroup.getElementAt(30);
					break;
				case "addChild":
					myGroup.addChild(new Group());
					break;
				case "addChildAt":
					myGroup.addChildAt(new Group(), 0);
					break;
				case "removeChild":
					myGroup.removeChild(new Group());
					break;				
				case "removeChildAt":
					myGroup.removeChildAt(0);
					break;
				case "setChildIndex":
					myGroup.setChildIndex(new Group(), 0);
					break;
				case "swapChildren":
					myGroup.swapChildren(new Group(), new Group());
					break;
				case "swapChildrenAt":
					myGroup.swapChildrenAt(0, 0);
					break;
				case "addElement(null)":
					myGroup.addElement(null);
					break;
				case "addElement(undefined)":
					myGroup.addElement(undefined);
					break;
				case "addElementAt(new spark.components.Button(), -1)":
					myGroup.addElementAt(new spark.components.Button(), -1);
					break;
				case "removeElementAt(-1)":
					myGroup.removeElementAt(-1);
					break;
				case "getElementAt(-1)":
					myGroup.getElementAt(-1);
					break;
				case "addElement(this group)":
					myGroup.addElement(myGroup);
					break;
				case "getElementIndex(new spark.components.Button())":
					myGroup.getElementIndex(new spark.components.Button());
					break;
						
			}
		
		} catch (error:Error) {
			return error.message;
		}
		
		return "no error";
		
	}
	
	
	public function createBlendedGroup(mode:String):void {
		
		// set up the holding group and its items
		
		var holdingGroup:Group = new Group();
		addElement(holdingGroup);
		
		var firstImage:Image = new Image();
		firstImage.source = "../../../../../Assets/Images/rgrect.jpg";
		holdingGroup.addElement(firstImage);
		
		var secondImage:Image = new Image();
		secondImage.source = "../../../../../Assets/Images/bwrect.jpg";
		
		var blendedGroup:Group = new Group();
		blendedGroup.x = 29;
		blendedGroup.y = 29;
		blendedGroup.blendMode = mode;
		
		var secondRect:Rect = new Rect();
		secondRect.width = 20;
		secondRect.height = 20;
		
	    var myFill:SolidColor = new SolidColor();
		myFill.color = 0x0000FF;
		secondRect.fill = myFill;

		if(mode == "alpha")
			secondRect.alpha = 0.01;
		
		if(mode == "alpha" || mode == "erase") {
			// alpha/erase don't play well with mustella bitmap compares so assert pixel instead
			blendedGroup.addElement(secondRect);
		} else {
			blendedGroup.addElement(secondImage);
		}
		
		holdingGroup.addElement(blendedGroup);
		
		group1.addElement(holdingGroup);
		
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
	
	public function applyGradientMask(myGroup:Group):void {

		// create a gradient rect for the mask
		
		myRect = new Rect();
		myRect.top = 0;
		myRect.left = 0;
		myRect.bottom = 0; 
		myRect.right = 0;

		var myFill:LinearGradient = new LinearGradient();

		var g1:GradientEntry = new GradientEntry(0xFF00FF, 0, 0);
		var g2:GradientEntry = new GradientEntry(0x000000, 0.66, 1);

		myFill.entries = [ g1, g2 ];

		myRect.fill = myFill;

		addElement(myRect);


		// add the gradient to a masking group

		var maskGroup:Group = new Group();
		maskGroup.x = 0;
		maskGroup.y = 0;
		maskGroup.width = 50;
		maskGroup.height = 50;
		
		removeElement(myRect);
		
		maskGroup.addElement(myRect);

		// apply the mask to the group

		myGroup.mask = maskGroup;

	}
	
	
	public function applyMask(myGroup:Group):void {
		var maskGroup:Group = new Group();
		maskGroup.x = 0;
		maskGroup.y = 0;
		maskGroup.width = 50;
		maskGroup.height = 50;
		addStretchRect(maskGroup);

		myGroup.mask = maskGroup;
	}
	
	public function applyMask2(myGroup:Group):void {
		var maskGroup:Group = new Group();
		maskGroup.x = 0;
		maskGroup.y = 0;
		maskGroup.width = 15;
		maskGroup.height = 15;
		addStretchRect(maskGroup);

		myGroup.mask = maskGroup;
	}
	
	public function createMaskGroup(width:int = 50, height:int = 50, x:int = 0, y:int = 0):Group {
		var maskGroup:Group = new Group();
		maskGroup.x = x;
		maskGroup.y = y;
		maskGroup.width = width;
		maskGroup.height = height;
		addStretchRect(maskGroup);

		return maskGroup;
	}
	
	public function addShadowFilter(myGroup:Group):void {            
		var f:DropShadowFilter = new DropShadowFilter(5,30,0x444444,0.8);
		var myFilters:Array = myGroup.filters;
		
		if (myFilters == null)
			myFilters = new Array();
			
		myFilters.push(f);
		myGroup.filters = myFilters;
	}
	
	public function addBlurFilter(myGroup:Group):void {
		var f:BlurFilter = new BlurFilter(3, 3, BitmapFilterQuality.HIGH);
		var myFilters:Array = myGroup.filters;
		
		if (myFilters == null)
			myFilters = new Array();
		
		myFilters.push(f);
		myGroup.filters = myFilters;
	}
			
	public function setContentToArrayCollection(myGroup:Group, myArray:Array):void {
		myGroup.mxmlContent = myArray;
	}  
	  
	public function addLine(myGroup:Group):void
	        {
	            var myLine:Line = new Line();
	            myLine.xFrom = 10; myLine.yFrom = 15;
	            myLine.xTo=50; myLine.yTo=55;
	            var mySolidColorStroke:SolidColorStroke = new SolidColorStroke();
	            mySolidColorStroke.color = 0xAB0000;
	            myLine.stroke = mySolidColorStroke;
	            myGroup.addElement(myLine);
	        }
	
        public function addRect(myGroup:Group):void
	        {
		    var myRect:Rect = new Rect();
		    myRect.x = 30; myRect.y = 40;
		    myRect.width=15; myRect.height=30;
		    var myFill:SolidColor = new SolidColor();
		    myFill.color = 0x123456;
		    myRect.fill = myFill;
		    myGroup.addElement(myRect);
        	}
		public function addStretchRect(myGroup:Group):void
	        {
		    var myRect:Rect = new Rect();
		    myRect.top = 0; myRect.left = 0;
		    myRect.bottom=0; myRect.right=0;
		    var myFill:SolidColor = new SolidColor();
		    myFill.color = 0xFF0000;
		    myRect.fill = myFill;
		    myGroup.addElement(myRect);
			
        	}
        public function addCustomRect(myGroup:Group, width:int, height:int, color:Number, xPos:int = 0, yPos:int = 0, trans:Number = 1):void
	        {
		    var myRect:Rect = new Rect();
		    myRect.x = xPos; myRect.y = yPos;
		    myRect.width=width; myRect.height=height;
		    var myFill:SolidColor = new SolidColor();
		    myFill.color = color;
		    myRect.fill = myFill;
			myRect.alpha = trans;
		    myGroup.addElement(myRect);
        }
		
        public function addButton(myGroup:Group, label:String = 'button', width:Number = NaN, height:Number = NaN):void
	        {
		    var myButton:spark.components.Button = new spark.components.Button();
		    myButton.width = width;
			myButton.height = height;
			myButton.label = label;
			
		    myGroup.addElement(myButton);
        }
		
        public function addSimpleText(myGroup:Group, text:String = 'SimpleText', width:Number = NaN, height:Number = NaN, x:Number = NaN, y:Number = NaN):void
	    {
		    var mySimpleText:spark.components.Label= new spark.components.Label();
		    mySimpleText.width = width;
			mySimpleText.height = height;
			mySimpleText.text = text;
			mySimpleText.x = x;
			mySimpleText.y = y;
			
		    myGroup.addElement(mySimpleText);
        }
		
        public function addEllipseAt(myGroup:Group, i:int):void
	        {
		    var myEllipse:Ellipse = new Ellipse();
		    //myEllipse.x = 0; myEllipse.y = 0;
		    myEllipse.width=40; myEllipse.height=30;
		    var myFill:SolidColor = new SolidColor();
		    myFill.color = 0x9966FF;
		    myEllipse.fill = myFill;
		    myGroup.addElementAt(myEllipse, i);
        	}
        			
	public function myItemRendererFunction(item:*):IFactory
	{
		if(item is String || item is Number)
			return new ClassFactory(DefaultItemRenderer);
		if(item.type == "text")
			return (new ClassFactory(LabelRenderer));
		else if (item.type == "checkBox" )
			return (new ClassFactory(CheckBoxRenderer)) 
		else if (item.type == "color" )
			return (new ClassFactory(ColorLabelRenderer))			
		return (item);
	}        	

	public function skewGroup(myGroup:Group):void {
		var currentMatrix:Matrix = myGroup.transform.matrix;
		var skewMatrix:Matrix = new Matrix();
		
        	skewMatrix.c = 1;
        
       		myGroup.transform.matrix = skewMatrix;
	
	}
		
	public function skewGroupViaTransform(myGroup:Group):void {
		var currentTransform:Transform = myGroup.transform;
		var currentMatrix:Matrix = myGroup.transform.matrix;
		var skewMatrix:Matrix = new Matrix();
		
       	skewMatrix.c = 1;
        
   		currentTransform.matrix = skewMatrix;
		
		myGroup.transform = currentTransform;
	
	}
	
	public function colorTransform(myGroup:Group):void {
		var currentColorTransform:ColorTransform = myGroup.transform.colorTransform;
		
		var redOffset:Number  = 100;
		var blueOffset:Number = 100;
		
		var colorTransform:ColorTransform = new ColorTransform(1, 1, 1, 1, redOffset, 0, blueOffset, 0);
	
		myGroup.transform.colorTransform = colorTransform;
	
	}	
		
	public function rotateTransform(myGroup:Group, degrees:Number):void {
	
		var newMatrix:Matrix = myGroup.transform.matrix;
		newMatrix.rotate(degrees * (Math.PI / 180));
		//newMatrix.concat(myGroup.transform.matrix);

		myGroup.transform.matrix = newMatrix;

	}
	
	public function createSubgroup(myGroup:Group):void {
		var subGroup:Group = new Group();
		
		myGroup.addElement(subGroup);
	}
	
	public function createSubgroupAt(myGroup:Group, width:int, index:int):void {
			
			var newSubgroup:Group = new Group();
			newSubgroup.width = width;
			myGroup.addElementAt(newSubgroup, index);
			
	}
	public function mixItemRendererFunction(item:*):IFactory
	{
		if (item is DisplayObject || item is GraphicElement)
		return new ClassFactory(DefaultComplexItemRenderer);
		else
		return new ClassFactory(DefaultItemRenderer);
	}
	
	public function useDefaultComplexItemRenderer(item:*):IFactory 
	{ 
		return new ClassFactory(DefaultComplexItemRenderer); 
	} 	
