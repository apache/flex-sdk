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

package mx.skins.halo
{

import flash.display.GradientType;
import flash.display.Graphics;
import flash.geom.Matrix;
import mx.styles.StyleManager;
import mx.skins.ProgrammaticSkin;

    
/**
 *  The skin for the background of the column headers in a DataGrid control.
 *
 *  @see mx.controls.DataGrid
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class DataGridHeaderBackgroundSkin extends ProgrammaticSkin
{
	include "../../core/Version.as";
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  Constructor.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function DataGridHeaderBackgroundSkin()
	{
		super();
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
		var g:Graphics = graphics;
		g.clear();
		
		var colors:Array = getStyle("headerColors");
		styleManager.getColorNames(colors);
		
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(w, h + 1, Math.PI/2, 0, 0);
		
		colors = [ colors[0], colors[0], colors[1] ];
		var ratios:Array = [ 0, 60, 255 ];
		var alphas:Array = [ 1.0, 1.0, 1.0 ];
		
		g.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
		g.lineStyle(0, 0x000000, 0);
		g.moveTo(0, 0);
		g.lineTo(w, 0);
		g.lineTo(w, h - 0.5);
		g.lineStyle(0, getStyle("borderColor"), 100);
		g.lineTo(0, h - 0.5);
		g.lineStyle(0, 0x000000, 0);
		g.endFill();
	}
}

}
