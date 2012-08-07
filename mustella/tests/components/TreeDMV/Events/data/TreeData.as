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
package data {

public class TreeData  {
    
 

import mx.collections.*;
[Bindable]
public var o1:Object = { label:"Containers", children:
		[    
			{ label:"DividedBoxClasses", children: 
				[  
					{ label:"BoxDivider", data:"BoxDivider.as" }
				]
			},
			{ label:"GridClasses", children: 
				[ 
					{ label:"GridRow", data:"GridRow.as" },
					{ label:"GridItem", data:"GridItem.as" }
				]
			}
		]
	};
[Bindable]	
public var o2:Object = { label:"Printing", children:
		[    
			{ label:"PrintJob",  data:"PrintJob.as" },
			{ label:"PrintJob1",  data:"PrintJob1.as" },			
			{ label:"PrintDataGrid",  data:"PrintDataGrid.as" }
		]
	};		
[Bindable]
public var o3:Object = { label:"Data", children:
		[    
			{ label:"Messages", children: 
				[ 
					{ label:"DataMessage", data:"DataMessage.as" },
					{ label:"SequencedMessage", data:"SequencedMessage.as" },
					{ label:"PagedMessage", data:"PagedMessage.as" }

				]
			},
			{ label:"Events", children: 
				[ 

					{ label:"ConflictEvent", children:
						[
							{ label:"ResolveEvent", data:"ResolveEvent.as" },
							{ label:"BubbleEvent", data:"BubbleEvent.as" }
						]
					},
					{ label:"CommitFaultEvent", data:"CommitFaultEvent.as" }

				]
			}

		]
	};	
[Bindable]	
public var o4:Object = { label:"Printing2", children:
	[    
		{ label:"PrintJob2",  data:"PrintJob.as" },
		{ label:"PrintJob23",  data:"PrintJob1.as" },			
		{ label:"PrintDataGrid23",  data:"PrintDataGrid.as" }
	]
};
	
[Bindable]
public var a1:Array = [ o1, o2 ];

public var a2:Array = [ o3, o4 ];
	
[Bindable]
public var ac1:ICollectionView;

[Bindable]
public var ac2:ICollectionView;


[Bindable]
public var nac1:ICollectionView;
public var nac2:ICollectionView;

[Bindable]
public var x1:XML = 
			<node label="rootnode">
					<node label="Containers">
					    <node label="DividedBoxClasses">
							<node label="BoxDivider" data="BoxDivider.as" />			
					    </node>
					    <node label="GridClasses">
							<node label="GridRow" data="GridRow.as" />			
							<node label="GridItem" data="GridItem.as" />			
					    </node>		    
					</node>		
					<node label="Printing">
						<node label="PrintJob" data="PrintJob.as" />			
						<node label="PrintJob1" data="PrintJob1.as" />			
						<node label="PrintTree" data="PrintTree.as" />			
					</node>
			</node>;		
	
		public var x2:XML = 
			<node label="rootNode2">
					<node label="New XML Object">
					    <node label="child1">
							<node label="child2" data="child.as" />			
					    </node>
					    <node label="child3">
							<node label="child4" data="child.as" />			
							<node label="child5" data="child.as" />			
					    </node>		    
					</node>		
			</node>;	

		public var x3:XML = 
			<node label="Data">
			    <node label="Messages">
					<node label="DataMessage" data="DataMessage.as" />			
					<node label="SequenceMessage" data="SequenceMessage.as" />			
					<node label="PagedMessage" data="PagedMessage.as" />			
			    </node>
			    <node label="Events">
				    <node label="ConflictEvents">
					<node label="ResolveEvent" data="ResolveEvent.as" />			
					<node label="BubbleEvent" data="BubbleEvent.as" />			
				    </node>
				    <node label="CommitFaultEvent" data="CommitFaultEvent.as" />
			    </node>		    
			</node>;

[Bindable]
public var xl1:XMLList = new XMLList(x1.children());
public var xl2:XMLList = new XMLList(x2.children());
public var xl3:XMLList = new XMLList(x3.children());

[Bindable]
public var xlc1:XMLListCollection = new XMLListCollection(xl1);
public var xlc2:XMLListCollection = new XMLListCollection(xl2);

[Bindable]
public var largeObj:Object = 
				[	{ label:"Accessibility", children: [    
     				    { label:"Classes", children: [       
                     		{ label:"BoxDivider", data:"BoxDivider.as" },    
                     		{ label:"BoxUniter", data:"BoxUniter.as" } ]   
                     	}, 
                     	{ label:"Assets" },    
                 		{ label:"CSS" } ]   
                 	},  
                 	{ label:"Charts", children: [     
     				    { label:"Skins", children: [      
                     		{ label:"AreaSkin", data:"AreaSkin.as" },   
                     		{ label:"BoxSkin", data:"BoxSkin.as" } ]    
                     	},
                     	{ label:"AssetRenderer" },   
                 		{ label:"PlotChart" } ]  
                 	},     
	             	{ label:"Automation", children: [   
	                	{ label:"AutomationError", data:"AutomationError.as"},   
	                	{ label:"AlertClasses", children: [  
	                 		{ label:"AlertForm", data:"AlertForm.as" } ]    
	                 	},   
	                	{ label:"Tree", data:"Tree.as" },   
	               		{ label:"Button", data:"Button.as"} ]    
	               	},   
	             	{ label:"Binding" },   
	             	{ label:"Collections", children: [    
	                	{ label:"Box", data:"Alert.as"},   
	                	{ label:"BoxClasses", children: [  
	                 		{ label:"HBox", data:"HBox.as" } ]    
	                 	},   
	                	{ label:"Canvas", data:"Canvas.as" },   
	               		{ label:"ICollectionView", data:"ICollectionView.as"} ]   
	               	},  
	             	{ label:"Containers" },
	             	{ label:"Controls", children: [   
     				    { label:"DividedBox", children: [      
                     		{ label:"BoxDivider", data:"BoxDivider.as" },  
                     		{ label:"BoxUniter", data:"BoxUniter.as" } ]   
                     	},
                     	{ label:"Accordian" },   
                 		{ label:"Grid" } ]  
                 	},   
	             	{ label:"Binding" },   
	             	{ label:"Collections", children: [    
	                	{ label:"Box", data:"Alert.as"},   
	                	{ label:"BoxClasses", children: [  
	                 		{ label:"HBox", data:"HBox.as" } ]    
	                 	},   
	                	{ label:"Canvas", data:"Canvas.as" },   
	               		{ label:"ICollectionView", data:"ICollectionView.as"} ]   
	               	},  
	             	{ label:"Containers" },
	             	{ label:"Controls", children: [   
     				    { label:"DividedBox", children: [      
                     		{ label:"BoxDivider", data:"BoxDivider.as" },  
                     		{ label:"BoxUniter", data:"BoxUniter.as" } ]   
                     	},
                     	{ label:"Accordian" },   
                 		{ label:"Grid" } ]  
                 	}
	            ];  
	            
 public function TreeData(): void
 {
        
 }
 
 
 }
 
 }