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
	import mx.graphics.*;
	import comps.*;
	import mx.collections.*;
    import spark.primitives.*;
	import mx.graphics.SolidColorStroke;
	import mx.graphics.SolidColor;
    import spark.primitives.supportClasses.*;
	import spark.layouts.*;
	
    import spark.components.*;
    import spark.skins.spark.*; 
    
	[Bindable]
	public var labelArr:Array=[{label: "top"},{label: "file"},{label:"I am a Menu"},{label:"here goes Nothing"},{label:"Label4"},{label:"bottom"}];
	[Bindable]
	public var abcArr:Array=[' ','', 'A','B','C','D','E','F','G','H','I','J','K','L']; 
	[Bindable]
	public var emptyArr:Array=[];
	public var mixArr:Array= [{type: "color", label: "Green string", color: 0x00FF00},{type: "text", label: "This is a string"},{type:"checkBox", label: "Checked", value:true},
	{type:"checkBox", label: "Unchecked", value:false},{type: "text", label: "Second string"},
	  {type: "color", label: "Red string", color: 0xFF0000}];
	  
  	[Bindable]
	public var ac:ArrayCollection;
	public var newPlayer:Object = {team:"ATeam",jerseyNumber:15, lastName:"Smith", firstName:"Sam"};
	[Bindable]
	public var players:ArrayCollection;
	[Bindable]
	public var ellipseAC:ArrayCollection;
	        public function createPlayersAC():void
		        {
		            players = new ArrayCollection([
	                {team:"ATeam",jerseyNumber:80, lastName:"BroPlayer",	   firstName:"TrName"},
		            {team:"JTeam", jerseyNumber:7,  lastName:"LePlayer", firstName:"ByName"},
		            {team:"ATeam",jerseyNumber:12, lastName:"BryPlayer",    firstName:"ToName"},
		            {team:"ATeam",jerseyNumber:21, lastName:"GaPlayer",      firstName:"RaName"},
		            {team:"RTeam", jerseyNumber:34, lastName:"OrPlayer",    firstName:"DaName"},
		            {team:"ATeam",jerseyNumber:12, lastName:"ViPlayer",firstName:"AdName"},
		            {team:"JTeam", jerseyNumber:7,  lastName:"BoPlayer",     firstName:"ByName"},
	       		]);
		        }		
	        public function createEllipseAC():void
		        {
		            ellipseAC = new ArrayCollection([
	            	    {label:"red",width:80, height:10, color:"0xFF0000"},
	            	    {label:"green",width:50, height:20, color:"0x00FF00"},
	            	    {label:"gray",width:30, height:60, color:"0x999999"},
	            	    {label:"red circle",width:50, height:50, color:"0xFF0000"},
	            	    {label:"yellow",width:40, height:10, color:"0xFFFF00"},
	            	    {label:"magenta",width:70, height:30, color:"0xFF00FF"},
    			    {label:"aqua",width:30, height:40, color:"0x00FFFF"}
	       		]);
		        }	        
	       public function sortAC():void
		        {
	            ac = new ArrayCollection([
		            {team:"ATeam",jerseyNumber:80, lastName:"BroPlayer",	   firstName:"TrName"},
		            {team:"JTeam", jerseyNumber:7,  lastName:"LePlayer", firstName:"ByName"},
		            {team:"ATeam",jerseyNumber:12, lastName:"BryPlayer",    firstName:"ToName"},
		            {team:"ATeam",jerseyNumber:21, lastName:"GaPlayer",      firstName:"RaName"},
		            {team:"RTeam", jerseyNumber:34, lastName:"OrPlayer",    firstName:"DaName"},
		            {team:"ATeam",jerseyNumber:12, lastName:"ViPlayer",firstName:"AdName"},
		            {team:"JTeam", jerseyNumber:7,  lastName:"BoPlayer",     firstName:"ByName"},
	        		]);
	            var s:Sort = new Sort();
		            var f:SortField = new SortField("jerseyNumber");
		            ac.filterFunction = function (item:Object):Boolean
		            {
		                return item.jerseyNumber >= 12 && item.jerseyNumber <= 34;
		            }
		            s.fields = [f];
		            ac.sort = s;
		            ac.refresh();
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
		
		public function aligningItemRendererFunction(item:*):IFactory
		{
			if (item is DisplayObject || item is GraphicElement)
				return new ClassFactory(DataGroupJustifyItemRendererComplex);
			else
				return new ClassFactory(DataGroupJustifyItemRenderer);
		}

		public function createAC():ArrayCollection
		{
			var col:ArrayCollection = 
			new ArrayCollection(['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']); 
			return (col);
		}

		public function addEllipseAt(myList:SkinnableDataContainer, i:int, color:int, width:int=40, height:int=30):void
		{
            var myGroup:Group = new Group();
			var myEllipse:Ellipse = new Ellipse();
			myEllipse.width=width; myEllipse.height=height;
			var myFill:SolidColor = new SolidColor();
			myFill.color = color;
			myEllipse.fill = myFill;
            myGroup.addElement(myEllipse);
            myList.dataProvider.addItemAt(myGroup, i);
		}
        
		public function addRectAt(myList:SkinnableDataContainer, i:int, color:int, width:int=15, height:int=30, x:int=30, y:int=40):void
		{
			var myRect:Rect = new Rect();
            var myGroup:Group = new Group();
			myRect.x = x; myRect.y = y;
			myRect.width=width; myRect.height=height;
			var myFill:SolidColor = new SolidColor();
			myFill.color = color;
			myRect.fill = myFill;
            myGroup.addElement(myRect);
			myList.dataProvider.addItemAt(myGroup,i);
		}
        
		public function createLine(color:int, xFrom:int=0, yFrom:int=0,xTo:int=40, yTo:int=30 ):Line
			{
			    var myLine:Line = new Line();
			    myLine.xFrom = xFrom; myLine.yFrom = yFrom;
			    myLine.xTo=xTo; myLine.yTo=yTo;
			    var mySolidColorStroke:SolidColorStroke = new SolidColorStroke();
			    mySolidColorStroke.color = color;
			    myLine.stroke = mySolidColorStroke;
			    return myLine;
			}
		public function createGroup(color:int, width:int=40, height:int=40, x:int=0, y:int=0 ):Group
			{
			    var myGroup:Group = new Group();
			    myGroup.layout = new VerticalLayout();

			    var myEllipse:Ellipse = new Ellipse();
			    myEllipse.width=width; myEllipse.height=height;
			    var myFill:SolidColor = new SolidColor();
			    myFill.color = color;
			    myEllipse.fill = myFill;
			    myGroup.addElement(myEllipse);

			    var myRect:Rect = new Rect();
			    myRect.width=width; myRect.height=height;
			    myRect.fill = myFill;
			    myGroup.addElement(myRect);

			    myGroup.addElement(createLine(color));

			    return myGroup;
			}
	        
		public function mixItemRendererFunction(item:*):IFactory
		{
		    if (item is DisplayObject || item is GraphicElement)
			return new ClassFactory(DefaultComplexItemRenderer);
		    else
			return new ClassFactory(DefaultItemRenderer);
		}
		
		[Bindable]
		[Embed(source="../../../../../Assets/Images/GridImages/1_r1_c1.png")]
		public var icon11:Class;

		[Bindable]
		[Embed(source="../../../../../Assets/Images/GridImages/1_r1_c2.png")]
		public var icon12:Class;

		[Bindable]
		[Embed(source="../../../../../Assets/Images/GridImages/1_r1_c3.png")]
		public var icon13:Class;

		[Bindable]
		[Embed(source="../../../../../Assets/Images/GridImages/1_r1_c4.png")]
		public var icon14:Class;

		[Bindable]
		[Embed(source="../../../../../Assets/Images/GridImages/1_r1_c5.png")]
		public var icon15:Class;

		[Bindable]
		[Embed(source="../../../../../Assets/Images/GridImages/1_r1_c6.png")]
		public var icon16:Class;

		[Bindable]
		[Embed(source="../../../../../Assets/Images/GridImages/1_r1_c7.png")]
		public var icon17:Class;

		[Bindable]
		[Embed(source="../../../../../Assets/Images/GridImages/1_r1_c8.png")]
		public var icon18:Class;

		[Bindable]
		[Embed(source="../../../../../Assets/Images/GridImages/1_r1_c9.png")]
		public var icon19:Class;

		[Bindable]
		[Embed(source="../../../../../Assets/Images/GridImages/1_r2_c1.png")]
		public var icon21:Class;

		[Bindable]
		public var objIcon:Object={label:"1", data:icon11};

		[Bindable]
		public var acIcons:ArrayCollection;	
	        public function createIconsAC():void
		{
		            acIcons = new ArrayCollection
		            ([  {label:"1", data:icon11},
				{label:"2", data:icon12},
				{label:"3", data:icon13},
				{label:"4", data:icon14},
				{label:"5", data:icon15},
				{label:"6", data:icon16},
				{label:"7", data:icon17},
				{label:"8", data:icon18},
				{label:"9", data:icon19},
				{label:"10", data:icon21}] );
		}