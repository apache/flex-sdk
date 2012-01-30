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
package spark.components.calendarClasses
{

import mx.core.DPIClassification;
import mx.core.mx_internal;

import spark.components.SpinnerList;
import spark.components.SpinnerListItemRenderer;
	
use namespace mx_internal;

/**
 *  The DateSpinnerItemRenderer class defines the default item renderer
 *  for a DateSpinner control in the mobile theme.  
 *  This is a simple item renderer with a single text component.
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */ 
public class DateSpinnerItemRenderer extends SpinnerListItemRenderer
{
	/**
	 *  Constructor.
	 *        
	 *  @langversion 3.0
	 *  @playerversion AIR 3
	 *  @productversion Flex 4.5.2
	 */ 
	public function DateSpinnerItemRenderer()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden properties: UIComponent
	//
	//--------------------------------------------------------------------------
	
	override public function get enabled():Boolean
	{
		var result:Boolean = true;
		
		// If data is a String or other primitive, this call will fail
		try 
		{
			result = data[SpinnerList.ENABLED_PROPERTY_NAME] == undefined || data[SpinnerList.ENABLED_PROPERTY_NAME];
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
	
	override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
	{
        var colorName:String = "color";
        
        try
        {
            if (data["_emphasized_"] != undefined)
                colorName = "accentColor"; // highlighted item
        }
        catch (e:Error)
        {
            // Do nothing
        }
        
        labelDisplay.colorName = colorName;
        labelDisplay.alpha = enabled ? 1 : .5;
		
		// We call the super at the end because it commits the labelDisplay styles. 
		super.layoutContents(unscaledWidth, unscaledHeight);
	}
}
}