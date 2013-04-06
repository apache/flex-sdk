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
package spark.components
{
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.mx_internal;
	import mx.utils.BitFlagUtil;
	
	import spark.components.Button;
	import spark.events.DropDownEvent;
	import spark.events.PopUpEvent;
	import spark.layouts.supportClasses.LayoutBase;
	
	import spark.components.supportClasses.CallOutDropDownController;
	import spark.components.supportClasses.IDropDownContainer;
	
	use namespace mx_internal;
	
	[Event(name="close", type="spark.events.DropDownEvent")]
	[Event(name="open", type="spark.events.DropDownEvent")]
	
	[DefaultProperty("calloutContent")]
	
	public class CallOutButton extends Button implements IDropDownContainer
	{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		mx_internal static const CALLOUT_CONTENT_PROPERTY_FLAG:uint = 1 << 0;
		
		/**
		 *  @private
		 */
		mx_internal static const CALLOUT_LAYOUT_PROPERTY_FLAG:uint = 1 << 1;
		
		/**
		 *  @private
		 */
		mx_internal static const HORIZONTAL_POSITION_PROPERTY_FLAG:uint = 1 << 2;
		
		/**
		 *  @private
		 */
		mx_internal static const VERTICAL_POSITION_PROPERTY_FLAG:uint = 1 << 3;
		
		[SkinPart(required="false")]
		public var dropDown:IFactory;
		
		public var topCallOut:CallOut;
		public var subCallOut:CallOut;
		
		private var _callout:CallOut;
		[Bindable("calloutChanged")]
		public function get callout():CallOut
		{
			return _callout;
		}
		
		protected function setCallout(value:CallOut):void
		{
			_callout = value;
			if (hasEventListener("calloutChanged")) dispatchEvent(new Event("calloutChanged"));
		}
		
		private var _calloutContent:Array;
		[ArrayElementType("mx.core.IVisualElement")]
		public function get calloutContent():Array
		{
			return _calloutContent;
		}
		
		public function set calloutContent(value:Array):void
		{
			_calloutContent = value;
			if (callout) callout.mxmlContent = value;
		}
		
		private var _calloutLayout:LayoutBase;
		public function get calloutLayout():LayoutBase
		{
			return _calloutLayout;
		}
		
		public function set calloutLayout(value:LayoutBase):void
		{
			_calloutLayout = value;
			if (callout) callout.layout = value;
		}
		
		[Inspectable(category="General", enumeration="rollOver,click", defaultValue="rollOver")] //mouseOver
		public var triggerEvent:String = MouseEvent.ROLL_OVER;
		
		private var dropDownController:CallOutDropDownController;
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Several properties are proxied to callout.  However, when callout
		 *  is not around, we need to store values set on CalloutButton.  This object 
		 *  stores those values.  If callout is around, the values are stored 
		 *  on the callout directly.  However, we need to know what values 
		 *  have been set by the developer on the CalloutButton (versus set on 
		 *  the callout or defaults of the callout) as those are values 
		 *  we want to carry around if the callout changes (via a new skin). 
		 *  In order to store this info effeciently, calloutProperties becomes 
		 *  a uint to store a series of BitFlags.  These bits represent whether a 
		 *  property has been explicitely set on this CalloutButton.  When the 
		 *  callout is not around, calloutProperties is a typeless 
		 *  object to store these proxied properties.  When callout is around,
		 *  calloutProperties stores booleans as to whether these properties 
		 *  have been explicitely set or not.
		 */
		mx_internal var calloutProperties:Object = {};
		
		
		//----------------------------------
		//  horizontalPosition
		//----------------------------------
		
		[Inspectable(category="General", enumeration="before,start,middle,end,after,auto", defaultValue="auto")]
		
		/**
		 *  @copy spark.components.Callout#horizontalPosition
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 3
		 *  @productversion Flex 4.6
		 */
		public function get horizontalPosition():String
		{
			if (callout)
				return callout.horizontalPosition;
			
			return calloutProperties.horizontalPosition;
		}
		
		/**
		 *  @private
		 */
		public function set horizontalPosition(value:String):void
		{
			if (callout)
			{
				callout.horizontalPosition = value;
				calloutProperties = BitFlagUtil.update(calloutProperties as uint, 
					HORIZONTAL_POSITION_PROPERTY_FLAG, value != null);
			}
			else
				calloutProperties.horizontalPosition = value;
		}
		
		//----------------------------------
		//  verticalPosition
		//----------------------------------
		
		[Inspectable(category="General", enumeration="before,start,middle,end,after,auto", defaultValue="auto")]
		
		/**
		 *  @copy spark.components.Callout#verticalPosition
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 3
		 *  @productversion Flex 4.6
		 */
		public function get verticalPosition():String
		{
			if (callout)
				return callout.verticalPosition;
			
			return calloutProperties.verticalPosition;
		}
		
		/**
		 *  @private
		 */
		public function set verticalPosition(value:String):void
		{
			if (callout)
			{
				callout.verticalPosition = value;
				calloutProperties = BitFlagUtil.update(calloutProperties as uint, 
					VERTICAL_POSITION_PROPERTY_FLAG, value != null);
			}
			else
				calloutProperties.verticalPosition = value;
		}
		
		
		
		override public function initialize():void
		{
			dropDownController = new CallOutDropDownController();
			dropDownController.closeOnResize = false;
			dropDownController.addEventListener(DropDownEvent.OPEN, handleDropDownOpen);
			dropDownController.addEventListener(DropDownEvent.CLOSE, handleDropDownClose);
			dropDownController.rollOverOpenDelay = (triggerEvent == MouseEvent.CLICK) ? NaN : 0;
			dropDownController.openButton = this;
			
			super.initialize();
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (partName == "dropDown")
			{
				// copy proxied values from calloutProperties (if set) to callout
				var newCalloutProperties:uint = 0;
				var calloutInstance:CallOut = instance as CallOut;
				
				if (calloutInstance && dropDownController)
				{
					calloutInstance.id = "callout";
					dropDownController.dropDown = calloutInstance;
					
					calloutInstance.addEventListener(PopUpEvent.OPEN, handleCalloutOpen);
					calloutInstance.addEventListener(PopUpEvent.CLOSE, handleCalloutClose);
					
					calloutInstance.mxmlContent = _calloutContent;
					if (_calloutLayout) calloutInstance.layout = _calloutLayout;
					
					/*
					if (calloutProperties.calloutContent !== undefined)
					{
					calloutInstance.mxmlContent = calloutProperties.calloutContent;
					newCalloutProperties = BitFlagUtil.update(newCalloutProperties, 
					CALLOUT_CONTENT_PROPERTY_FLAG, true);
					}
					
					if (calloutProperties.calloutLayout !== undefined)
					{
					calloutInstance.layout = calloutProperties.calloutLayout;
					newCalloutProperties = BitFlagUtil.update(newCalloutProperties, 
					CALLOUT_LAYOUT_PROPERTY_FLAG, true);
					}
					*/
					if (calloutProperties.horizontalPosition !== undefined)
					{
						calloutInstance.horizontalPosition = calloutProperties.horizontalPosition;
						newCalloutProperties = BitFlagUtil.update(newCalloutProperties, HORIZONTAL_POSITION_PROPERTY_FLAG, true);
					}
					
					if (calloutProperties.verticalPosition !== undefined)
					{
						calloutInstance.verticalPosition = calloutProperties.verticalPosition;
						newCalloutProperties = BitFlagUtil.update(newCalloutProperties, VERTICAL_POSITION_PROPERTY_FLAG, true);
					}
					
					calloutProperties = newCalloutProperties;
				}
			}
		}
		
		override protected function attachSkin():void
		{
			super.attachSkin();
			if (!dropDown && !("dropDown" in skin)) dropDown = new ClassFactory(CallOut);
		}
		
		
		private function handleDropDownOpen(event:DropDownEvent):void
		{
			if (!callout) setCallout(createDynamicPartInstance("dropDown") as CallOut);
			if (!callout) return;
			
			if(topCallOut != null)
				if(topCallOut.owner != null)
					(this.topCallOut.owner as CallOutButton).subCallOut = callout;
			
			addEventListener(Event.REMOVED_FROM_STAGE, handleButtonRemoved);
			callout.open(this, false);
		}
		
		private function handleDropDownClose(event:DropDownEvent):void
		{
			if (!callout) return;
			
			removeEventListener(Event.REMOVED_FROM_STAGE, handleButtonRemoved);
			callout.close();
		}
		
		private function handleCalloutOpen(event:PopUpEvent):void
		{
			dispatchEvent(new DropDownEvent(DropDownEvent.OPEN));
		}
		
		private function handleCalloutClose(event:PopUpEvent):void
		{
			if (dropDownController.isOpen) closeDropDown();
			
			/*if (calloutDestructionPolicy == ContainerDestructionPolicy.AUTO)
			destroyCallout();*/
			
			dispatchEvent(new DropDownEvent(DropDownEvent.CLOSE));
		}
		
		private function handleButtonRemoved(event:Event):void
		{
			if (!isDropDownOpen) return;
			
			callout.visible = false;
			closeDropDown();
		}
		
		
		public function get isDropDownOpen():Boolean
		{
			return dropDownController ? dropDownController.isOpen : false;
		}
		
		public function openDropDown():void
		{
			dropDownController.openDropDown();
		}
		
		public function closeDropDown():void
		{
			dropDownController.closeDropDown(false);
		}
		
		public function updatePopUpPosition():void
		{
			callout.updatePopUpPosition();
		}
	}
}
