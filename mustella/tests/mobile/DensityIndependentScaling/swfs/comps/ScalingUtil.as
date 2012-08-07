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
	import flash.display.Stage;
	import flash.geom.Rectangle;
	
	import spark.components.Application;
	
	import mx.core.FlexGlobals;
	import mx.core.mx_internal;
	import mx.utils.ObjectUtil;
	import mx.managers.SystemManager;		
	use namespace mx_internal;	
	

	public class ScalingUtil
	{
		public function ScalingUtil()
		{
		}
		
		public static function getScalingFactor(application:Application):Number
		{
			var scaling:Number = 0;
			
			if(application == null)
				return 0;
			
			
			scaling = SystemManager(application.systemManager).mx_internal::densityScale;
			
			
			/*var targetDPI:int = application.applicationDPI;
			var actualDPI:int = application.runtimeDPI;
			if(targetDPI != 0 && actualDPI != 0)
			{
				scaling = Number(actualDPI)/Number(targetDPI);
			}*/
			
			/*
			var screenRect:Rectangle = application.systemManager.screen;
			var stageRect:Stage = application.stage;
			
			if(screenRect != null && stageRect != null)
			{			
				scaling = screenRect.width/stageRect.width;
			}*/
			
			return scaling;
			
		}
		
		public static function getScreenWidth(application:Application):Number
		{
			var sWidth:Number;
			
			var screenRect:Rectangle = application.systemManager.screen;
			if(screenRect != null)
			{
				sWidth = screenRect.width;
			}else{
				sWidth = 0;
			}
			
			return sWidth;
		}
		
		public static function getScreenHeight(application:Application):Number
		{
			var sHeight:Number;
			
			var screenRect:Rectangle = application.systemManager.screen;
			if(screenRect != null)
			{
				sHeight = screenRect.height;
			}else{
				sHeight = 0;
			}
			
			return sHeight;
		}
		
		
	}
}