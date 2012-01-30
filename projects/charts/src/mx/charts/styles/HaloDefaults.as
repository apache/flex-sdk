////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.charts.styles
{

import mx.core.mx_internal;
import mx.graphics.IFill;
import mx.graphics.IStroke;
import mx.graphics.SolidColor;
import mx.graphics.Stroke;
import mx.styles.CSSStyleDeclaration;
import mx.styles.IStyleManager2;

use namespace mx_internal;

/**
 *  Initializes the core default styles for the charts classes. Each chart and element is responsible for initializing their own 
 *	style values, but they rely on the common values computed by the HaloDefaults class.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class HaloDefaults
{
    include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------

	/** 
	 *  @private
	 */
	private static var inited:Boolean;

	[Inspectable(environment="none")]
	/**
	 *	The default selectors applied to the individual series in a chart.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	mx_internal static var chartBaseChartSeriesStyles:Array;
	
	[Inspectable(environment="none")]
	/**
	 *	The default color values used by chart controls to color different series (or, in a PieSeries, different items).
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	mx_internal static var defaultColors:Array =
	[
		0xE48701
		,0xA5BC4E
		,0x1B95D9
		,0xCACA9E
		,0x6693B0
		,0xF05E27
		,0x86D1E4
		,0xE4F9A0
		,0xFFD512
		,0x75B000
		,0x0662B0
		,0xEDE8C6
		,0xCC3300
		,0xD1DFE7
		,0x52D4CA
		,0xC5E05D
		,0xE7C174
		,0xFFF797
		,0xC5F68F
		,0xBDF1E6
		,0x9E987D
		,0xEB988D
		,0x91C9E5
		,0x93DC4A
		,0xFFB900
		,0x9EBBCD
		,0x009797
		,0x0DB2C2
	];

	[Inspectable(environment="none")]
	/**
	 *	The default SolidColor objects used as fills by chart controls to color different series (or, in a PieSeries, different items).
	 *	These Fill objects correspond to the values in the <code>defaultColors</code> Array.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	mx_internal static var defaultFills:Array = [];
	
	[Inspectable(environment="none")]
	mx_internal static var pointStroke:IStroke;
	
	[Inspectable(environment="none")]
	/**
	 *	A pre-defined invisible Stroke that is used by several chart styles.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	mx_internal static var emptyStroke:IStroke;
	
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Creates a CSSStyleDeclaration object or returns an existing one.
	 *
	 *  @param selectorName The name of the selector to return. If no existing CSSStyleDeclaration object matches 
	 *  this name, this method creates a new one and returns it.
	 * 
	 *  @param styleManager The styleManager instance to be used for getting and setting style declarations.
	 * 
	 *  @return The CSSStyleDeclaration object that matches the provided selector name. If no CSSStyleDeclaration object matches
	 *  that name, this method creates a new one and returns it.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static function createSelector(
								selectorName:String, styleManager:IStyleManager2):CSSStyleDeclaration
	{
		var selector:CSSStyleDeclaration =
			styleManager.getStyleDeclaration(selectorName);

		if (!selector)
		{
			selector = new CSSStyleDeclaration();
			styleManager.setStyleDeclaration(selectorName, selector, false);
		}

		return selector;
	}
		
	/**
	 *  Initializes the common values used by the default styles for the chart and element classes.
	 *
	 *  @param styleManager The styleManager instance to be used for getting and setting style declarations.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static function init(styleManager:IStyleManager2):void
	{
		if (inited)
			return;	
		
		var seriesStyleCount:int = defaultColors.length;

		for (var i:int = 0; i < seriesStyleCount; i++)
		{
			defaultFills[i] = new SolidColor(defaultColors[i]);
		}
 		
		pointStroke = new Stroke(0, 0, 0.5);
		emptyStroke = new Stroke(0, 0, 0);
		chartBaseChartSeriesStyles = [];
		
		var f:Function;
		
		for (i = 0; i < seriesStyleCount; i++)
		{
			var styleName:String = "haloSeries" + i;
			chartBaseChartSeriesStyles[i] = styleName;

			var o:CSSStyleDeclaration =
				HaloDefaults.createSelector("." + styleName, styleManager);
		
			f = function (o:CSSStyleDeclaration, defaultFill:IFill,defaultStroke:IStroke):void
			{
				o.defaultFactory = function():void
				{
					this.fill =  defaultFill;
					this.areaFill = defaultFill;
					this.areaStroke =  emptyStroke;
					this.lineStroke =  defaultStroke;
				}
			}
			
			f(o, HaloDefaults.defaultFills[i],new Stroke(defaultColors[i], 3, 1));
		}
	
	}
}

}
