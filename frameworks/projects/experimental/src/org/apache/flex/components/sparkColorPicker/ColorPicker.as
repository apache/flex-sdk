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
package org.apache.flex.components.sparkColorPicker 
{	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.IList;
	import mx.core.IFlexModuleFactory;
	import mx.graphics.SolidColor;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.IStyleManager2;
	import mx.styles.StyleManager;
	
	import spark.components.ComboBox;
	import spark.events.DropDownEvent;
	
	import org.apache.flex.components.sparkColorPicker.skin.ColorPickerSkin;
	import org.apache.flex.components.sparkColorPicker.util.ColorPickerUtil;
	import org.apache.flex.components.sparkColorPicker.events.ColorChangeEvent;

	/**
	 * Dispatched when a color is choosed
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10.1
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */
	[Event(name="choose", type="org.apache.flex.components.spark.events.ColorChangeEvent")]
	/**
	 * Dispatched when a color is hovered. Might be usefull in 'preview' situations
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10.1
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */
	[Event(name="hover", type="org.apache.flex.components.spark.events.ColorChangeEvent")]
	/**
	 *  @langversion 3.0
	 *  @playerversion Flash 10.1
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */
	/**
	 *  Subclass DropDownList and make it work like a ColorPicker
	 *   
	 */
	/**
	 * @author Bogdan Dinu (http://www.badu.ro)
	 */
	public class ColorPicker extends ComboBox
	{		
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		[SkinPart(required="true")]
		public var solidColor:SolidColor;
		/**
		 * Instance of utility which provides all colors and transforms uint values to it's hex 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		private static var util:ColorPickerUtil = new ColorPickerUtil();
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function ColorPicker()
		{
			super();
		}
		/**
		 * Upon children creation, we're setting the dataprovider to the colors list 
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		override protected function childrenCreated():void
		{
			super.childrenCreated();
			super.dataProvider = util.getColorsList();
			labelFunction = blankLabelFunction;
			labelToItemFunction = colorFunction;
			openOnInput = false;
			addEventListener(Event.CHANGE, onColorChange);
		}		
		/**
		 * Converts the value to uint
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		private function colorFunction(value:String):*
		{
			return uint(value);
		}
		/**
		 * We're dispatching our event, instead of Event.CHANGE
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		private function onColorChange(event:Event):void
		{
			if (solidColor)
			{
				solidColor.color = selectedItem;				
				dispatchEvent(new ColorChangeEvent(ColorChangeEvent.CHOOSE, selectedItem));
			}			
		}
		/**
		 * Label function is required to be blank all the time
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		private function blankLabelFunction(item:Object):String
		{
			return "";
		}	
		/**
		 * We never allow the dataProvider to be set
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */		
		override public function set dataProvider(value:IList):void
		{
			
		}
		/**
		 * Initialization of the selected color
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);			
			if (instance == solidColor)
			{
				solidColor.color = selectedItem;
			}
		}
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		override public function setFocus():void
		{
			stage.focus = this;
		}
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		override protected function isOurFocus(target:DisplayObject):Boolean
		{
			return target === this;
		}
		/**
		 * The default behavior is prevented
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		override protected function dropDownController_closeHandler(event:DropDownEvent):void
		{
			event.preventDefault();
			super.dropDownController_closeHandler(event);
		}
		/**
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		override public function set selectedItem(value:*):void
		{
			super.selectedItem = value;
			if (solidColor) solidColor.color = value;
		}
		/**
		 * Duplicate of selectedItem property, just for naming to be right
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function set selectedColor(value : uint):void
		{
			selectedItem(value);
		}
		public function get selectedColor():uint
		{
			return selectedItem;
		}
		
		/**
		 *  Skinning
		 */		
		private static var defaultStylesSet                : Boolean;
		
		override public function set moduleFactory(factory:IFlexModuleFactory):void
		{
			super.moduleFactory = factory;
			prototype.constructor.setDefaultStyles( factory );
		}
		/**
		 * Declares the default skinClass, in case it's not mentioned a custom skinning
		 * If you want to customize skin, specify it in style declaration of your app.
		 */
		private static function setDefaultStyles( factory:IFlexModuleFactory ):void
		{
			if( defaultStylesSet ) return;			
			defaultStylesSet = true;			
			var defaultStyleName:String = getQualifiedClassName( prototype.constructor ).replace( /::/, "." );
			var styleManager:IStyleManager2 = StyleManager.getStyleManager( factory );
			var style:CSSStyleDeclaration = styleManager.getStyleDeclaration( defaultStyleName );			
			if( !style )
			{
				style = new CSSStyleDeclaration();
				styleManager.setStyleDeclaration( defaultStyleName, style, true );
			}			
			if( style.defaultFactory == null )
			{
				style.defaultFactory = function():void
				{
					this.skinClass = org.apache.flex.components.sparkColorPicker.skin.ColorPickerSkin;
				};
			}
		}	
	}	
}