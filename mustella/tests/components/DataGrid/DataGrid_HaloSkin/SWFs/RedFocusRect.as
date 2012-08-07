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
package {

import flash.display.Graphics;
import mx.skins.ProgrammaticSkin;
import mx.styles.CSSStyleDeclaration;
import mx.styles.IStyleClient;
import mx.utils.GraphicsUtil;


public class RedFocusRect extends ProgrammaticSkin implements IStyleClient
{

	public function RedFocusRect()
	{
		super();
	}
  	

  	private var _focusColor:Number;

	public function get className():String
	{
		return "HaloFocusRect";
	}

	//----------------------------------
	//  inheritingStyles
	//----------------------------------

	/**
	 *  @private
	 */
	public function get inheritingStyles():Object
	{
		return styleName.inheritingStyles;
	}

	/**
	 *  @private
	 */
	public function set inheritingStyles(value:Object):void
	{
	}

	//----------------------------------
	//  nonInheritingStyles
	//----------------------------------

	/**
	 *  @private
	 */
	public function get nonInheritingStyles():Object
	{
		return styleName.nonInheritingStyles;
	}
	
	/**
	 *  @private
	 */
	public function set nonInheritingStyles(value:Object):void
	{
	}

	//----------------------------------
	//  styleDeclaration
	//----------------------------------

	/**
	 *  @private
	 */
	public function get styleDeclaration():CSSStyleDeclaration
	{
		return CSSStyleDeclaration(styleName);
	}
	
	/**
	 *  @private
	 */
	public function set styleDeclaration(value:CSSStyleDeclaration):void
	{
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override protected function updateDisplayList(w:Number, h:Number):void
	{		
		super.updateDisplayList(w, h);

		var focusBlendMode:String = getStyle("focusBlendMode");
		var focusAlpha:Number = getStyle("focusAlpha");
		var focusColor:Number = 0xFF0000;
		var cornerRadius:Number = 8;
		var focusThickness:Number = 5;
		var themeColor:Number = getStyle("themeColor");
		
		var rectColor:Number = focusColor;
		if (!rectColor)
			rectColor = themeColor;
			
		var g:Graphics = graphics;
		g.clear();

        if(focusBlendMode){		
		    blendMode = focusBlendMode;
        }
        
		var ellipseSize:Number;
			
		// outer ring
		g.beginFill(rectColor, focusAlpha);
		ellipseSize = (cornerRadius > 0 ? cornerRadius + focusThickness : 0) * 2;
		g.drawRoundRect(0, 0, w, h, ellipseSize, ellipseSize);
		ellipseSize = cornerRadius * 2;
		g.drawRoundRect(focusThickness, focusThickness,
			w - 2 * focusThickness, h - 2 * focusThickness,
			ellipseSize, ellipseSize);
		g.endFill();
		// inner ring
		g.beginFill(rectColor, focusAlpha);
		ellipseSize = (cornerRadius > 0 ? cornerRadius + focusThickness / 2 : 0) * 2;
		g.drawRoundRect(focusThickness / 2, focusThickness / 2,
			w - focusThickness, h - focusThickness,
			ellipseSize, ellipseSize);
		ellipseSize = cornerRadius * 2;
		g.drawRoundRect(focusThickness, focusThickness,
			w - 2 * focusThickness, h - 2 * focusThickness,
			ellipseSize, ellipseSize);
		g.endFill();
	}
	
    override public function getStyle(styleProp:String):*
	{
		return styleProp == "focusColor" ?
			   _focusColor :
			   super.getStyle(styleProp);
	}

	/**
	 *  @private
	 */
    public function setStyle(styleProp:String, newValue:*):void
	{
		if (styleProp == "focusColor")
			_focusColor = newValue;
	}

	/**
	 *  @private
	 */
	public function clearStyle(styleProp:String):void
	{
		if (styleProp == "focusColor")
			_focusColor = NaN;
	}

	/**
	 *  @private
	 */
	public function getClassStyleDeclarations():Array
	{
		return [];
	}

	/**
	 *  @private
	 */
    public function notifyStyleChangeInChildren(
						styleProp:String, recursive:Boolean):void
	{
	}

	/**
	 *  @private
	 */
    public function regenerateStyleCache(recursive:Boolean):void
	{
	}

	/**
	 *  @private
	 */
    public function registerEffects(effects:Array /* of String */):void
	{
	}
}

}
