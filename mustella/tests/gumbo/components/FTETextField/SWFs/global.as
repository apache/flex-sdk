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
import flashx.textLayout.formats.*;
import mx.core.*;
import mx.utils.*;

public const dummyTxt:String = "The quick brown fox jumps over the lazy dog.";
public const dummyHTMLTxt:String = "<p>The <b>quick brown</b> fox <i>jumps over</i> the<br/>lazy dog.</p>";
public const dummyHTMLTxt2:String = "<p>para 1</p><p>para 2</p><p>para 3</p><p>para 4</p>";
public const dummyHTMLTxt3:String = "<p>para 1 - line 1<br/>para 1 - line 2<br/>para 1 - line 3<br/>para 1 - line 4</p>";
public const dummyHTMLTxt4:String = "<p>1) The quick brown fox jumps over the lazy dog.</p><p>2) The quick brown fox jumps over the lazy dog.</p>";

public const htmlText_default:String = '<TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="Arial" SIZE="12" COLOR="#000000" LETTERSPACING="0" KERNING="0">The quick brown fox jumps over the lazy dog.</FONT></P></TEXTFORMAT>';
public const condenseWhiteTxt:String = "    The quick         brown\n        fox jumps\n   over the\t\t\t\t\t   a lazy\n\n\n\n\n\tdog      .           ";
public const htmlText_a:String = "The quick brown <a href='http://adobe.com/'>fox</a> jumps over the lazy dog.";
public const htmlText_b:String = "The quick brown <b>fox</b> jumps over the lazy dog.";
public const htmlText_br:String = "The quick brown fox<br/> jumps over the lazy dog.";
public const htmlText_br2:String = "The quick brown fox<br> jumps over the lazy dog.";
public const htmlText_font_color:String = "The quick brown <font color='#FF0000'>fox</font> jumps over the lazy dog.";
public const htmlText_font_size:String = "The quick brown <font size='16'>fox</font> jumps over the lazy dog.";
public const htmlText_img:String = "The quick brown <img src='../../../../../Assets/Images/Icons/smallsquares3.jpg' width='10' height='10'/> jumps over the lazy dog.";
public const htmlText_img2:String = "The quick brown <img src='../../../../../Assets/Images/Icons/smallsquares3.jpg' width='10' height='10'> jumps over the lazy dog.";
public const htmlText_i:String = "The quick brown <i>fox</i> jumps over the lazy dog.";
public const htmlText_li:String = "The quick brown <li>fox</li> jumps over the lazy dog.";
public const htmlText_p:String = "<p>The quick brown</p><p>fox</p><p>jumps over the lazy dog.</p>";
public const htmlText_p_align:String = "<p align='left'>left</p><p align='center'>center</p><p align='right'>right</p><p align='justify'>justify</p>";
public const htmlText_p_align2:String = "<p align='justify'>The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog.</p>";
public const htmlText_p_align3:String = "<p align='start'>The quick brown fox jumps over the lazy dog.</p><p align='end'>The quick brown fox jumps over the lazy dog.</p>";
public const htmlText_span:String = "The quick brown <span>fox</span> jumps over the lazy dog.";
public const htmlText_textformat_blockindent:String = "<textformat blockindent='10'>The quick brown fox jumps over the lazy dog.</textformat>";
public const htmlText_textformat_indent_pos:String = "<textformat indent='10'>The quick brown fox jumps over the lazy dog.</textformat>";
public const htmlText_textformat_leading_pos:String = "<textformat leading='5'>The quick brown fox jumps over the lazy dog.</textformat>";
public const htmlText_textformat_leading_neg:String = "<textformat leading='-5'>The quick brown fox jumps over the lazy dog.</textformat>";
public const htmlText_textformat_leftmargin:String = "<textformat leftmargin='20'>The quick brown fox jumps over the lazy dog.</textformat>";
public const htmlText_textformat_rightmargin:String = "<textformat rightmargin='20'>The quick brown fox jumps over the lazy dog.</textformat>";
public const htmlText_textformat_tabstops:String = "<textformat tabstops='20,40,60,80'>0\t20\t40\t60\t80</textformat>";
public const htmlText_textformat_tabstops2:String = "<textformat tabstops='20,40,60,80'>0<tab/>20<tab/>40<tab/>60<tab/>80</textformat>";
public const htmlText_textformat_tabstops3:String = "<textformat tabstops='20,40,60,80'>0<tab>20<tab>40<tab>60<tab>80</textformat>";
public const htmlText_u:String = "The quick brown <u>fox</u> jumps over the lazy dog.";
public const paraStyleSheet:String = "<p class='testPClass'>Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.</p> <p>Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip.</p>";
public const spanStyleSheet:String = "<span class='testSpanClass'>Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.</span> <span>Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip.</span>";
public const generalStyleSheet:String = "<p class='testClass'>Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.</p> <p>Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip.</p>";            



public function unsupported_method_error(name:String):String {
	return StringUtil.substitute("'{0}()' is not implemented in FTETextField.", name);
}

public function unsupported_property_error(name:String):String {
	return StringUtil.substitute("'{0}' is not implemented in FTETextField.", name);
}


public function safeGetter(property:String):String {
	try {
		FlexGlobals.topLevelApplication.can.fteTxt[property];
	} catch (err:Error) {
		return err.message;
	}
	return undefined;
}

public function safeSetter(property:String, value:Object):String {
	try {
		FlexGlobals.topLevelApplication.can.fteTxt[property] = value;
	} catch (err:Error) {
		return err.message;
	}
	return undefined;
}


public function safeMethod(methodName:String, ... args):String {
	try {
		FlexGlobals.topLevelApplication.can.fteTxt[methodName].apply(null, args);
	} catch (err:Error) {
		return err.message;
	}
	return undefined;
}


public function fixCanvasSize(p:uint = 0):void {
	FlexGlobals.topLevelApplication.can.fteTxt.x = p;
	FlexGlobals.topLevelApplication.can.fteTxt.y = p;
	FlexGlobals.topLevelApplication.can.width = (FlexGlobals.topLevelApplication.can.fteTxt.width + (p * 2));
	FlexGlobals.topLevelApplication.can.height = (FlexGlobals.topLevelApplication.can.fteTxt.height + (p * 2));
}

public var fmt:TextFormat;

public function initTextField(tf:FTETextField, fmt:TextFormat = null):void {
	if (!fmt) {
		fmt = new TextFormat();
	}
	fmt.font = "myVeraSpark";
	tf.border = true;
	tf.embedFonts = true;
	tf.defaultTextFormat = fmt;
}

/* config1 == single line of text; wordWrap:true; autoSize:none; */
public function config1(tf:FTETextField, txt:String = dummyTxt, fmt:TextFormat = null):void {
	initTextField(tf, fmt);
	tf.text = txt;
	tf.wordWrap = true;
	tf.autoSize = TextFieldAutoSize.NONE;
}

/* config2 == single line of text; wordWrap:true; autoSize:left; */
public function config2(tf:FTETextField, txt:String = dummyTxt, fmt:TextFormat = null):void {
	initTextField(tf, fmt);
	tf.text = txt;
	tf.wordWrap = true;
	tf.autoSize = TextFieldAutoSize.LEFT;
}

/* config3 == single line of text; wordWrap:false; autoSize:none; */
public function config3(tf:FTETextField, txt:String = dummyTxt, fmt:TextFormat = null):void {
	initTextField(tf, fmt);
	tf.text = txt;
	tf.wordWrap = false;
	tf.autoSize = TextFieldAutoSize.NONE;
}

/* config4 == single line of text; wordWrap:false; autoSize:left; */
public function config4(tf:FTETextField, txt:String = dummyTxt, fmt:TextFormat = null):void {
	initTextField(tf, fmt);
	tf.text = txt;
	tf.wordWrap = false;
	tf.autoSize = TextFieldAutoSize.LEFT;
}

/* config5 == mulitple lines of htmlText; wordWrap:true; autoSize:none; */
public function config5(tf:FTETextField, txt:String = dummyHTMLTxt, fmt:TextFormat = null):void {
	initTextField(tf, fmt);
	tf.htmlText = txt;
	tf.wordWrap = true;
	tf.autoSize = TextFieldAutoSize.NONE;
}

/* config6 == mulitple lines of htmlText; wordWrap:true; autoSize:left; */
public function config6(tf:FTETextField, txt:String = dummyHTMLTxt, fmt:TextFormat = null):void {
	initTextField(tf, fmt);
	tf.htmlText = txt;
	tf.wordWrap = true;
	tf.autoSize = TextFieldAutoSize.LEFT;
}

/* config7 == mulitple lines of htmlText; wordWrap:false; autoSize:none; */
public function config7(tf:FTETextField, txt:String = dummyHTMLTxt, fmt:TextFormat = null):void {
	initTextField(tf, fmt);
	tf.htmlText = txt;
	tf.wordWrap = false;
	tf.autoSize = TextFieldAutoSize.NONE;
}

/* config8 == mulitple lines of htmlText; wordWrap:false; autoSize:left; */
public function config8(tf:FTETextField, txt:String = dummyHTMLTxt, fmt:TextFormat = null):void {
	initTextField(tf, fmt);
	tf.htmlText = txt;
	tf.wordWrap = false;
	tf.autoSize = TextFieldAutoSize.LEFT;
}

public function initFTETextFieldStyleSheet(tf:FTETextField, txt:String, ss:StyleSheet):void {
	tf.htmlText = txt;
	tf.styleSheet = ss;
	tf.wordWrap = true;
	tf.autoSize = TextFieldAutoSize.LEFT;
}

private function setUpParaStyleSheet():StyleSheet{
	var ss:StyleSheet = new StyleSheet();
	
	var testPClass:Object = new Object();
	testPClass.fontWeight = "bold";
	testPClass.color = "#FF0000"; // red
	
	ss.setStyle(".testPClass", testPClass);
	
	return ss;
}

private function setUpSpanStyleSheet():StyleSheet{
	var ss:StyleSheet = new StyleSheet();
	
	var testSpanClass:Object = new Object();
	testSpanClass.fontWeight = "bold";
	testSpanClass.color = "#0000FF"; // blue
	
	ss.setStyle(".testSpanClass", testSpanClass);
	return ss;
}

private function setUpGeneralStyleSheet():StyleSheet{
	var ss:StyleSheet = new StyleSheet();
	
	var testClass:Object = new Object();
	testClass.fontWeight = "bold";
	testClass.color = "#0000FF"; // blue
	testClass.fontStyle = "italic";
	testClass.letterSpacing = "0";
	testClass.textAlign = "center";
	testClass.textDecoration = "underline";
	
	ss.setStyle(".testClass", testClass);
	return ss;
}
