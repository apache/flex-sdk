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

package spark.skins.mobile.supportClasses
{
import flash.display.Graphics;
import flash.geom.Point;

import mx.core.DPIClassification;
import mx.core.FlexGlobals;
import mx.core.IDataRenderer;
import mx.core.UIComponent;
import mx.core.mx_internal;

import spark.components.Application;
import spark.components.HSlider;
import spark.components.supportClasses.StyleableTextField;

use namespace mx_internal;

/**
 *  HSlider dataTip component for HSlider in mobile applications. 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class HSliderDataTip extends UIComponent implements IDataRenderer
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     * 
     */
    public function HSliderDataTip()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    private var _data:String;
    
    /**
     * The data to be displayed in the dataTip.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get data():Object
    {
        return _data;
    }
    
    public function set data(value:Object):void
    {
        if (_data != String(value))
        {
            _data = String(value);
            dataChanged = true;
            invalidateProperties();
            invalidateSize();
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    private var labelDisplay:StyleableTextField;
    
    private var dataChanged:Boolean = false;
    
    /**
     *  Font size for the ToolTip text.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var fontSize:String;
    
    /**
     *  Left padding for the text in the ToolTip.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var leftTextPadding:int;
    
    /**
     *  Left and right padding for the text in the ToolTip.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var leftRightTextPadding:int;
    
    /**
     *  Top and bottom padding for the text in the ToolTip.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var topBottomTextPadding:int;
    
    /**
     *  Top padding for the text in the ToolTip.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var topTextPadding:int;
    
    /**
     *  Corner radius for the Rect around a ToolTip.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var cornerRadius:int;
    
    /**
     *  Offset of the bottom of the ToolTip from the top of the overall HSlider skin.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var tooltipOffset:int;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     */ 
    override protected function createChildren():void
    {
        var applicationDPI:int = Application(FlexGlobals.topLevelApplication).applicationDPI;
        
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                fontSize = "30";
                leftTextPadding = 14;
                leftRightTextPadding = 28;
                topTextPadding = 8;
                topBottomTextPadding = 14;
                tooltipOffset = 22;
                cornerRadius = 8;				
            }
            case DPIClassification.DPI_240:
            {
                fontSize = "20";
                leftTextPadding = 11;
                leftRightTextPadding = 22;
                topTextPadding = 5;
                topBottomTextPadding = 10;
                tooltipOffset = 7;
                cornerRadius = 6;
                
                break;
            }
            default:
            {
                // default DPI_160
                fontSize = "15";
                leftTextPadding = 7;
                leftRightTextPadding = 14;
                topTextPadding = 4;
                topBottomTextPadding = 7;
                tooltipOffset = 11;
                cornerRadius = 4;
                
                break;
            }
        }
        
        // create the label object  
        labelDisplay = new StyleableTextField();
        labelDisplay.styleName = this;
        labelDisplay.setStyle("textAlign", "center");
        labelDisplay.setStyle("verticalAlign", "middle");
        labelDisplay.setStyle("color", 0xFFFFFF);
        labelDisplay.setStyle("fontWeight", "bold");
        labelDisplay.setStyle("fontSize", fontSize);
        labelDisplay.commitStyles();
        
        addChild(labelDisplay);
    }
    
    /**
     *  @private 
     */ 
    override protected function measure():void
    {
        var textSize:Point = labelDisplay.measuredTextSize;
        measuredWidth = textSize.x + leftRightTextPadding;
        measuredHeight = textSize.y + topBottomTextPadding;
    }
    
    /**
     *  @private 
     */ 
    override protected function commitProperties():void
    {
        if (dataChanged)
        {
            labelDisplay.text = _data;
            dataChanged = false;
        }
    }
    
    /**
     *  @private 
     */ 
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // draw the rect
        var g:Graphics = graphics;
        g.clear();
        g.beginFill(0x000000, 1.0);
        g.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, cornerRadius, cornerRadius);
        g.endFill();
        
        // position and size the label
        labelDisplay.x = leftTextPadding;
        labelDisplay.y = topTextPadding;
        labelDisplay.width = unscaledWidth - leftRightTextPadding;
        labelDisplay.height = unscaledHeight - topBottomTextPadding;
        
        // adjust so that the bottom of the toolTip is above the thumb
        y = -(tooltipOffset + unscaledHeight);
    }    
}
}