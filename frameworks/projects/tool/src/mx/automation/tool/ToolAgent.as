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

package mx.automation.tool
{

import flash.display.DisplayObject;
import flash.display.Sprite;
import mx.events.FlexEvent;
import mx.automation.tool.ToolAdapter;

[Mixin]
public class ToolAgent
{

    include "../../core/Version.as";
	
	private static var _root:DisplayObject;
	
	private static var toolAdapter:ToolAdapter;
	
	public static function init(root:DisplayObject):void
    {
    	if(!toolAdapter)
	    {
	    	_root = root;
	    	new ToolAgent(root);
    	}
	}
	
	public function ToolAgent(root:DisplayObject):void
	{
		super();

		root.addEventListener(FlexEvent.APPLICATION_COMPLETE, applicationCompleteHandler);
	}
	
	private function applicationCompleteHandler(event:FlexEvent):void
	{
		_root.removeEventListener(FlexEvent.APPLICATION_COMPLETE, applicationCompleteHandler);

		// it was observed that when there are other applications loaded into the same domain
		// we get this event more than once. But for one application domain we need to cr
		if(!toolAdapter)
			toolAdapter = new ToolAdapter();
	}

}

}
