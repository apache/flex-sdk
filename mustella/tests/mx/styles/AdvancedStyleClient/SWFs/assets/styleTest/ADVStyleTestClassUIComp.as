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
package assets.styleTest
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.collections.XMLListCollection;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	import mx.styles.CSSStyleDeclaration;
	
	//The possible values of the format property of the [Style] metadata tag are:
	// Boolean, Color, Number, Length, uint, Time, File, EmbeddedFile, int, 
	// ICollectionView, Array, Class, String, Object 
	
	//style with String type
	[Style(name="teststyle_1_string_noinh", type="String", inherit="no")]
	
	//sample as <s:ComboBox paddingBottom="13.5" />
	[Style(name="teststyle_2_number_noinh", type="Number", inherit="no")]
	
	[Style(name="teststyle_3_uint_inh", type="uint", inherit="yes")]
	
	[Style(name="teststyle_4_date_inh", type="Date", inherit="yes")]
	
	/*
	style with format, we will only focus on the following format type:
	Length format
	Time format
	Color format
	Using Arrays for style properties
	*/
	
	//Length format
	/**
	 Length is of type Number. 
	 Length format has following unit:
	 Unit    Scale    Description
	 em    Relative    Ems. The width of the character m in the character set.
	 ex    Relative    x-height. The height of the character x in the character set.
	 px    Relative    Pixels.
	 in    Absolute    Inches.
	 cm    Absolute    Centimeters.
	 mm    Absolute    Millimeters.
	 pt    Absolute    Points.
	 pc    Absolute    Picas.
	 Flex does not support the em and ex units. You can convert these to px units by using the following scales:
	 1em = 10.06667px
	 1ex = 6px
	 When you use inline styles, Flex ignores units and uses pixels as the default.
	 */
	[Style(name="teststyle_5_format_length_noinh", type="Number", format="Length", inherit="no")]
	
	//Time format
	/**
	 The Time format is of type Number and is represented in milliseconds.
	 Do not specify the units when entering a value in the Time format.
	 */
	[Style(name="teststyle_6_format_time_noinh", type="Number", format="Time", inherit="no")]
	
	//Color format
	/**
	 hexadecimal: 
	 You use the 0x prefix when defining colors in calls to the setStyle() method and in MXML tags. 
	 * 
	 You use the # prefix in CSS style sheets and in <fx:Style> tag blocks.
	 * 
	 YRGB: 
	 You can use the RGB format only in style sheet definitions.
	 * 
	 RGB colors are a mixture of the colors red, green, and blue, 
	 and are represented in percentages of the color’s saturation. 
	 The format for setting RGB colors is color:rgb(x%, y%, z%)
	 * 
	 8-bit octet RGB: 
	 You can use the RGB format only in style sheet definitions.
	 * 
	 The 8-bit octet RGB colors are red, green, and blue values from 1 to 255. 
	 The format of 8-bit octet colors is [0-255],[0-255],[0-255].
	 * 
	 VGA color names: 
	 You can use the VGA color names format in style sheet definitions and inline style declarations.
	 * 
	 VGA color names are not case-sensitive. 
	 The available color names are Aqua, Black, Blue, Fuchsia, Gray, Green, Lime, 
	 Maroon, Navy, Olive, Purple, Red, Silver, Teal, White, Yellow. 
	 */
	//sample as <s:Button label="test" emphasized="true" accentColor="#FF99FF" />
	[Style(name="teststyle_7_format_color_noinh", type="uint", format="Color", inherit="no")]
	
	//style with format and arrayType
	/** sample as:
	 mx|Tree {
	 deColors: #FFCC33, #FFCC99, #CC9900;
	 alternatingItemColors: red, green;
	 }
	 */
	[Style(name="teststyle_8_format_arrayType_noinh", type="Array", arrayType="uint", format="Color", inherit="no")]
	
	//style with ArrayCollection type
	[Style(name="teststyle_9_date_arrayCol_inh", type="ArrayCollection", arrayType="Date", inherit="yes")]
	[Style(name="teststyle_10_xml_arrayCol_noinh", type="XMLListCollection", arrayType="XMLList", format="ICollectionView", inherit="no")]
	
	//style of Boolean
	[Style(name="teststyle_11_boolean_noinh", type="Boolean", format="Boolean", inherit="no")]
	
	//style with enumeration
	[Style(name="teststyle_12_enum_string_inh", type="String", inherit="yes", enumeration="defaultType, firstType, secondType")]
	[Style(name="teststyle_13_enum_int_noinh", type="int", inherit="no", enumeration="15, 66, 99, 1")]
	
	//style with custom object
	[Style(name="teststyle_14_object_noinh", type="assets.styleTest.ADVStyleTestVo", format="Object", inherit="no")]
	
	//style with state
	[Style(name="teststyle_15_state_string_noinh", type="String", inherit="no", states="heavy, medium, light")]
	
	//skin
	[Style(name="teststyle_16_skin_noinh", type="Class", inherit="no")]
	//skin with state
	[Style(name="teststyle_17_skin_state_noinh", type="Class", format="Class", inherit="no", states="heavy, medium, light")]
	
	//end test style.
	
	[Event(name="testStylesChanged", type="assets.styleTest.ADVStyleTestEvent")]
	
	public class ADVStyleTestClassUIComp extends UIComponent
	{
		
		// Define a static variable.
		private static var classConstructed:Boolean = classConstruct();
		
		// Define a static method.
		private static function classConstruct():Boolean {
			/*
			var cssStyle:CSSStyleDeclaration = FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("assets.styleTest.ADVStyleTestClassUIComp");
			if (cssStyle == null)
			{
				// If there is no CSS definition for StyledRectangle, 
				// then create one and set the default value.
				cssStyle = new CSSStyleDeclaration();
			}
			
			cssStyle.defaultFactory = function():void
			{
				this.fillColors = [0xFF0000, 0x0000FF];
				this.alphas = [0.5, 0.5];
			}
				
			FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("assets.styleTest.ADVStyleTestClassUIComp", cssStyle, true);
			*/
			
			if (!FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("assets.styleTest.ADVStyleTestClassUIComp"))
			{
				// If there is no CSS definition for StyledRectangle, 
				// then create one and set the default value.
				var cssStyle:CSSStyleDeclaration = new CSSStyleDeclaration();
				cssStyle.defaultFactory = function():void
				{
					this.teststyle_1_string_noinh = 'defaultString';
					/**
					 * 2, 3 unset here, so can set them using Application and global selector.
					 */
//					this.teststyle_2_number_noinh = 11111.2345;
//					this.teststyle_3_uint_inh = 9870;
					this.teststyle_4_date_inh = new Date(2010, 5, 4);
					this.teststyle_5_format_length_noinh = 30;
					this.teststyle_6_format_time_noinh = 5000;
					this.teststyle_7_format_color_noinh = 0x112233;
					this.teststyle_8_format_arrayType_noinh = [0xFFCC33, 0xCC33FF, 0x33FFCC];
					
					this.teststyle_9_date_arrayCol_inh = new ArrayCollection([
						new Date(1910, 1, 5), 
						new Date(1950, 5, 5), 
						new Date(1990, 10, 5)]);
					this.teststyle_10_xml_arrayCol_noinh = new XMLListCollection(new XMLList(
						'<defaultXml1>defaultXml1</defaultXml1>' +
						'<defaultXml2>defaultXml2</defaultXml2>' +
						'<defaultXml3>defaultXml3</defaultXml3>'));
					
					this.teststyle_11_boolean_noinh = false;
					this.teststyle_12_enum_string_inh = 'defaultType';
					this.teststyle_13_enum_int_noinh = 15;
					this.teststyle_14_object_noinh = ADVStyleTestConstants.defaultAdvVo;
					
					this.teststyle_15_state_string_noinh = "defaultStateString";
					
					this.teststyle_16_skin_noinh = ADVStyleTestConstants.defaultCls;
					this.teststyle_17_skin_state_noinh = ADVStyleTestConstants.defaultCls_heavy;
				}
				
				FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("assets.styleTest.ADVStyleTestClassUIComp", cssStyle, true);
				
			}

			return true;
		}
		
		public static const STYLE_NAME_LIST:ArrayCollection = new ArrayCollection([
			'teststyle_1_string_noinh',
			'teststyle_2_number_noinh',
			'teststyle_3_uint_inh',
			'teststyle_4_date_inh',
			'teststyle_5_format_length_noinh',
			'teststyle_6_format_time_noinh',
			'teststyle_7_format_color_noinh',
			'teststyle_8_format_arrayType_noinh',
			'teststyle_9_date_arrayCol_inh',
			'teststyle_10_xml_arrayCol_noinh',
			'teststyle_11_boolean_noinh',
			'teststyle_12_enum_string_inh',
			'teststyle_13_enum_int_noinh',
			'teststyle_14_object_noinh',
			'teststyle_15_state_string_noinh',
			'teststyle_16_skin_noinh',
			'teststyle_17_skin_state_noinh',
		]);
		
		[Bindable]
		private var truelyGetStyleList:ArrayCollection;
		
		public function ADVStyleTestClassUIComp()
		{
			super();
			//truelyGetStyleList = new ArrayCollection(new Array(STYLE_NAME_LIST.length));
			
			//this.addEventListener("allStylesChanged", allStyleChangedHandler);
		}
		
		// Define a default size of 100 x 100 pixels.
		override protected function measure():void {
			super.measure();
			
			measuredWidth = measuredMinWidth = 100;
			measuredHeight = measuredMinHeight = 100;
		}
		
		// Define the flag to indicate that a style property changed.
		private var bStypePropChanged:Boolean = true;
		
		private var myColor:uint;
		private var myAlpha:Number;
		
		// Define the variable for additional control on the fill.
		// You can create a style property for this as well.
		private var ratios:Array = [0x00, 0xFF];
		
		// Override updateDisplayList() to update the component 
		// based on the style setting.
		override protected function updateDisplayList(unscaledWidth:Number,
													  unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// Check to see if style changed. 
			if (bStypePropChanged == true) 
			{
				// Redraw gradient fill only if style changed.
				myColor = getStyle("teststyle_7_format_color_noinh");
				//myAlpha = getStyle("teststyle_2_number_noinh");
				
				graphics.beginFill(myColor);  
				graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
				
				bStypePropChanged = false;
			}
		}

		
		private function allStyleChangedHandler(event:Event):void {
			truelyGetStyleList = generateTruelyGetStyleList();
			
//			var ev:TestStylesEvent = new TestStylesEvent(TestStylesEvent.ALL_TEST_STYLE_CHANGED);
//			ev.truelyStyleList = truelyGetStyleList;
//			
//			dispatchEvent(ev);
		}
		
		private function generateTruelyGetStyleList():ArrayCollection {
			var temp:ArrayCollection = new ArrayCollection(new Array(STYLE_NAME_LIST.length));
			
			for each (var styleName:String in STYLE_NAME_LIST) {
				setStyleInList(getStyle(styleName), getIdxOfStyle(styleName), temp);
			}
			
			return temp;
		}
		
		/**
		 * get index value with the given styleName. 
		 * Because custom style named from 1, this idx will decrease 1.
		 */
		private function getIdxOfStyle(styleName:String):int {
			var idx:int = 0;
			
			if (styleName != null) {
				var start:int = styleName.indexOf('_');
				
				if (start > 0) {
					var end:int = styleName.indexOf('_', start + 1);
					
					if (end > 0) {
						var str:String = styleName.substring(start + 1, end);
						
						idx = int (str);
					}
				}
				
			}
			
			return (idx - 1);
		}
		
		/**
		 * set 'style' into an 'IList' at 'idx'.
		 */
		private function setStyleInList(style:*, idx:int, list:IList):void {
			if (list) {
				list.removeItemAt(idx);
				list.addItemAt(style, idx);
			}
		}
		
		override public function styleChanged(styleProp:String):void {
			super.styleChanged(styleProp);
			
			if (styleProp && (styleProp != "styleName")) {
				// Check to see if style changed. 
				if (styleProp=="teststyle_7_format_color_noinh" || styleProp=="teststyle_2_number_noinh") 
				{
					bStypePropChanged = true; 
					invalidateDisplayList();
					return;
				}
				
				if (styleProp.indexOf('teststyle_') == 0) {
					var event:ADVStyleTestEvent = new ADVStyleTestEvent(ADVStyleTestEvent.TEST_STYLE_CHANGED);
					event.changedStyleName = styleProp;
					
					this.dispatchEvent(event);
					//setStyleInList(styleProp, truelyGetStyleList);
				}
			} else {
				bStypePropChanged = true; 
				invalidateDisplayList();
				return;
			}
			
		}

	}
}