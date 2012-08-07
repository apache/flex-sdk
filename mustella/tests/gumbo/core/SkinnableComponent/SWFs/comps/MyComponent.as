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
import spark.components.Button;
import 	spark.components.supportClasses.SkinnableComponent;
import spark.components.Label;
	import flash.events.MouseEvent;
	import mx.controls.Text;
	import mx.core.IFactory;	  
	import flash.display.DisplayObject;
	import comps.*;
	import mx.core.IVisualElement;
	import spark.components.supportClasses.Skin;
	/* Skin states*/
	// Any skin for this component must implement all these states
	[SkinState("one")]
	[SkinState("two")]
	[SkinState("three")]
	[SkinState("four")]
	[SkinState("stateX")]
	
	public class MyComponent extends SkinnableComponent
	{
		public var lbl:Text;
		private var ec:DisplayObject; //DisplayObject for dynamic part
		private var ellipses:Array;
		
		public function MyComponent()
		{
			super();
			ellipses = new Array();
		}
		
		//Binding labelChanged event
		[Bindable("labelChanged")]
		public function set label(value:String):void
		{
			content = value;
			dispatchEvent(new Event("labelChanged"));
			invalidateSkinState();
			
			var i:int;
			var curState:String = value;
			if (curState == 'two'){
				if(ellipses.length > 0){
					for(i=ellipses.length ; i > 0; i--){
						var remEll:DisplayObject = this.getDynamicPartAt('ellipseClass', (i-1)) as DisplayObject;
						removeDynamicPartInstance('ellipseClass', remEll);
						(Skin(skin)).removeElement(remEll as IVisualElement);
					} 
				}
			}
			else if (curState == 'three'){
				for (i=0; i < 4; i++){
					var ell:DisplayObject = createDynamicPartInstance('ellipseClass') as DisplayObject;
					ellipses.push(ell);
					(Skin(skin)).addElement(ell as IVisualElement);	
				}
			}
			//push data to skin part
			myState.text = curState;
			dp.text = this.numDynamicParts('ellipseClass').toString();
		}
		
		public function get label():String			
		{
			return (content != null) ? content.toString():"";
		}
		[Bindable]
		public var content:*
		/******************************SkinnableComponent Code*******************************************/
				
		/************************************************/
		/* SkinParts: need deferred, dynamic, and static*/
		/************************************************/
		
		/******static SkinParts******/
		/* required and not required*/
		/****************************/
		[SkinPart]
		public var txt:Label;
		
		[SkinPart(required="false")]
		public var btn:Button;
		
		[SkinPart]
		public var myState:Label;
		
		[SkinPart]
		public var dp:Label;
		
		/******dynamic SkinParts******/
		[SkinPart(type="flash.display.DisplayObject")]
		public var ellipseClass:IFactory;
		
		/******deferred skinPart *****/
		[SkinPart(required="false")]
		public var db:Button;
		
		/*****************************************************/
		/*Methods for helping determine and update skin state*/
		/*****************************************************/
		
		override protected function getCurrentSkinState():String{
			var curState:String = this.label;
			if (curState == 'one')
			
				return 'one';
			else if (curState == 'two')
				return 'two';
			else if (curState == 'three')
				return 'three';
			else if (curState == 'four')
				return 'four';
			else if (curState == 'stateX')
				return 'stateX';
			else
				return 'four';
		}	
		
		override public function invalidateSkinState():void{
			super.invalidateSkinState();	
		}
		
		/********************************/
		/*These are for loading the skin*/
		/********************************/
		public var functionOrder:Label = new Label();
		public var unloadOrder:Label = new Label();
		private var skinChanged:int = 0;
		
		public function numDynParts(st:String):int{
			return this.numDynamicParts(st);
		}
		
		public function getDynPartAt(st:String, index:int):Object{
			return this.getDynamicPartAt(st, index);
		}
			
		override protected function attachSkin():void{
			functionOrder.text += 'attachSkin ';
			if (skinChanged > 0){
				functionOrder.text = 'attachSkin ';
			}
			skinChanged++;
			super.attachSkin();
			
		}
	
		override protected function findSkinParts():void{
			//Called after attachSkin()
			functionOrder.text += 'findSkinParts ';
			super.findSkinParts();
			
		}
	
		override protected function partAdded(partName:String, instance:Object):void{
			//Called after findSkinParts
			functionOrder.text += 'partAdded ';
			super.partAdded(partName, instance);
			if (partName == 'db'){
				callLater(function(){instance.label="deferredAdded"});
			}
			if (partName == 'ellipseClass'){
				instance.addEventListener(MouseEvent.CLICK, eClick);
			}
			
    		}
	
		/**************************************************************/
		/*These are for unloading the skin, skin may change at runtime*/
		/**************************************************************/
		override protected function detachSkin():void{
			//called when skin changes at runtime
			unloadOrder.text += 'detachSkin ';
			super.detachSkin();
		}
		
		override protected function partRemoved(partName:String, instance:Object):void{
			//called after unloadingSkin()
			unloadOrder.text += 'partRemoved ';
			super.partRemoved(partName, instance);
			if (partName == 'ellipseClass'){
				instance.removeEventListener(MouseEvent.CLICK, eClick);
			}
		}		
		override protected function clearSkinParts():void{
			//called after partRemoved is done being called for each skin part	
			unloadOrder.text += 'clearSkinParts ';
			super.clearSkinParts();
		}
		
		/*********************/
		/*Dynamic parts code */
		/*********************/
		// Function for partAdded event behavior
	    	private function eClick(e:Event):void{
				trace("Target is: " + e.target);
	    			e.target.width=20;
		}
	
		/* numDynamicParts(partName:String):int; - Verify the number of dynamic parts is correct*/
    		/* getDynamicPartAt(partName:String, index:int) - Verify this returns the correct instance of a dynamic part*/
		
		
		
	}
}
