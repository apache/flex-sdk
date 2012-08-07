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
package comps
{

import mx.controls.treeClasses.*;
import mx.collections.*;

	public class MyTreeItemRenderer extends TreeItemRenderer
	{
		
        public function MyTreeItemRenderer() 
		{
			super();

			// InteractiveObject variables.
			mouseEnabled = false;
			
		}
		
		override public function set data(value:Object):void
		{
				if(value != null)
				{ 
				     super.data = value;
				     if(TreeListData(super.listData).hasChildren)
					{
						setStyle("color", 0xff0000);
						setStyle("fontWeight", 'bold');
					}
					else
					{
						setStyle("color", 0x000000);
						setStyle("fontWeight", 'normal');
					}
				}
			
	        
	    }
	 

	   override protected function updateDisplayList(unscaledWidth:Number,
														  unscaledHeight:Number):void
	   {
				super.updateDisplayList(unscaledWidth, unscaledHeight);
		        if(super.data)
		        {
				    if(TreeListData(super.listData).hasChildren)
				    {
				        var tmp:XMLList = new XMLList(TreeListData(super.listData).item);
				        var myStr:int = tmp[0].children().length();
				        super.label.text =  TreeListData(super.listData).label + "(" + myStr + ")";
				    }
				}
	    }

	}

}
