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
 * @see spark.components.DateSpinner
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */ 
public class DateSpinnerItemRenderer extends SpinnerListItemRenderer
{
    /**
     *  Constructor.
     *        
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public function DateSpinnerItemRenderer()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var _colorName:String = "color";
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
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
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    override public function set data(value:Object):void
    {
        super.data = value;

        try
        {
            if (data["_emphasized_"] != undefined)
                _colorName = "accentColor"; // highlighted item
            else
                _colorName = "color"; // reset to use standard color
        }
        catch (e:Error)
        {
            // Do nothing
        }
        
        setTextProperties();
    }
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    override protected function createChildren():void
    {
        super.createChildren();
        
        setTextProperties();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    private function setTextProperties():void
    {
        if (labelDisplay)
        {
            labelDisplay.colorName = _colorName;
            labelDisplay.alpha = enabled ? 1 : .5;
        }        
    }
}
}