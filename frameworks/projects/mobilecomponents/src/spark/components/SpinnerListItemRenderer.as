////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package spark.components
{

import mx.core.DPIClassification;
	
/**
 *  The SpinnerListItemRenderer class defines the default item renderer
 *  for a spinner list control in the mobile theme.  
 *  This is a simple item renderer with a single text component.
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */ 
public class SpinnerListItemRenderer extends LabelItemRenderer
{
	/**
	 *  Constructor.
	 *        
	 *  @langversion 3.0
	 *  @playerversion AIR 3
	 *  @productversion Flex 4.5.2
	 */ 
	public function SpinnerListItemRenderer()
	{
		super();
		
		switch (applicationDPI)
		{
			case DPIClassification.DPI_320:
			{
				minHeight = 20;
				break;
			}
			case DPIClassification.DPI_240:
			{
				minHeight = 15;
				break;
			}
			default: // default PPI160
			{
				minHeight = 10;
				break;
			}
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden properties: UIComponent
	//
	//--------------------------------------------------------------------------
	
	// TODO (tkraikit) Move this function into DateSpinner item renderer class
	override public function get enabled():Boolean
	{
		var result:Boolean = true;
		
		// If data is a String or other primitive, this call will fail
		try 
		{
			result = data["enabled"] == undefined || data["enabled"];
		}
		catch (e:Error)
		{
			
		}
		
		return result;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden Methods
	//
	//--------------------------------------------------------------------------
	
	override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
	{
		// draw a transparent background for hit testing
		graphics.beginFill(0x000000, 0);
		graphics.lineStyle();
		graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
		graphics.endFill();
	}
	
	// TODO (tkraikit) Move this function into DateSpinner item renderer class (put in calendarClasses)
	// TODO (jszeto) Fix this so the class will still respect the color style value set on the class
	override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
	{
		var labelColor:Object = undefined;
			
		// If data is a String or other primitive, this call will fail
		try
		{
			if (!enabled)
				labelColor = 0x696969; // unselectable item
			else if (data["accentColor"] != undefined)
				labelColor = data["accentColor"]; // highlighted item
			else
				labelColor = 0; // TODO (jszeto) This doesn't seem correct
		}
		catch (e:Error)
		{
			// Do nothing
		}
		
		labelDisplay.setStyle("color", labelColor);
		
		// We call the super at the end because it commits the labelDisplay styles. 
		super.layoutContents(unscaledWidth, unscaledHeight);
	}
}
}