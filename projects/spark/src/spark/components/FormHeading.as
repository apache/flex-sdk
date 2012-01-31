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
 *  Background color of the component.
 *  
 *  @default 0xFFFFFF
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="backgroundColor", type="uint", format="Color", inherit="no", theme="spark")]

//--------------------------------------
//  Other metadata
//--------------------------------------

/**
 *  Because this component does not define a skin for the mobile theme, Adobe
 *  recommends that you not use it in a mobile application. Alternatively, you
 *  can define your own mobile skin for the component. For more information,
 * see <a href="http://help.adobe.com/en_US/flex/mobileapps/WS19f279b149e7481c698e85712b3011fe73-8000.html">Basics of mobile skinning</a>.
 */
[DiscouragedForProfile("mobileDevice")]

[IconFile("FormHeading.png")]

/**
 *  The Spark FormHeading container displays a heading
 *  for a group of controls inside a Spark Form container.
 *  You can include multiple FormHeading containers within a single Form
 *  container.
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:FormHeading&gt;</code> tag inherits all the tag 
 *  attributes of its superclass and adds no new tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:FormHeading
 *    <strong>Properties</strong>
 *    label=""
 *  
 *    <strong>Common Styles</strong>
 *    alignmentBaseline="baseline"
 *    baselineShift="0"
 *    cffHinting="0.0"
 *    color="0x000000"
 *    digitCase="default"
 *    digitWidth="default"
 *    direction="ltr"
 *    dominantBaseline="auto"
 *    fontFamily="Arial"
 *    fontLookup="embeddedCFF"
 *    fontSize="12"
 *    fontStyle="normal"
 *    fontWeight="normal"
 *    justificationRule="auto"
 *    justificationStyle="auto"
 *    kerning="false"
 *    ligatureLevel="common"
 *    lineBreak="toFit"
 *    lineHeight="120%"
 *    lineThrough="false%"
 *    locale="en"
 *    paddingBottom="0"
 *    paddingLeft="0"
 *    paddingRight="0"
 *    paddingTop="0"
 *    renderingMode="cff"
 *    textAlign="start"
 *    textAlignLast="start"
 *    textAlpha="1"
 *    textDecoration="start"
 *    textJustify="interWord"
 *    trackingLeft="0"
 *    trackingRight="00"
 *    typographicCase="default"
 *    verticalAlign="top"
 * 
 *    <strong>Mobile Styles</strong>
 *    leading="2"
 *    letterSpacing="0"
 *  /&gt;
 *  </pre>
 * 
 *  @see spark.components.Form
 *  @see spark.components.FormItem
 *  @see spark.layouts.FormLayout
 *  @see spark.skins.spark.FormHeadingSkin
 * 
 *  @includeExample examples/FormExample.mxml
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5 
 */ 
public class FormHeading extends SkinnableComponent
{
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function FormHeading()
    {
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    /**
     *  A reference to the visual element that displays this FormItem's label.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
     *  Text to display in the FormHeading component.
     * 
     *  @default ""
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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