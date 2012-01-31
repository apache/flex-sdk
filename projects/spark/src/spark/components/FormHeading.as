////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{

import spark.core.IDisplayText;
import spark.components.supportClasses.SkinnableComponent;

include "../styles/metadata/BasicInheritingTextStyles.as"
include "../styles/metadata/AdvancedInheritingTextStyles.as"

/**
 *  Alpha level of the background for this component.
 *  Valid values range from 0.0 to 1.0. 
 *  
 *  @default 1.0
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="backgroundAlpha", type="Number", inherit="no", theme="spark")]

/**
 *  Background color of a component.
 *  
 *  @default 0xFFFFFF
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="backgroundColor", type="uint", format="Color", inherit="no", theme="spark")]

/**
 * A simple form item component which contains a label. It is used to 
 * provide a heading to a set of form items. It is basically a FormItem 
 * without any content, sequenceLabel or helpContent. Since it is 
 * a separate class from FormItem, it has a default style 
 * (larger font size) and its own skin.
 */ 
public class FormHeading extends SkinnableComponent
{
    public function FormHeading()
    {
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    /**
     *   A reference to the visual element that displays this FormItem's label.
     */
    [Bindable]
    [SkinPart(required="false")]
    public var labelDisplay:IDisplayText;
            
    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  label
    //----------------------------------
    
    private var _label:String = "";
    
    [Bindable("labelChanged")]
    [Inspectable(category="General", defaultValue="")]
    
    /**
     *  Text to display in the FormHeading 
     * 
     *  @default ""
     */
    public function get label():String
    {
        return _label;
    }
    
    /**
     *  @private
     */
    public function set label(value:String):void
    {
        if (_label == value)
            return;
        
        _label = value;
        
        if (labelDisplay)
            labelDisplay.text = label;
        dispatchEvent(new Event("labelChanged"));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == labelDisplay)
            labelDisplay.text = label;
    }
    
    /**
     *  @private
     */
    override protected function getCurrentSkinState():String
    {
        return enabled ? "normal" : "disabled";
    }
}
}