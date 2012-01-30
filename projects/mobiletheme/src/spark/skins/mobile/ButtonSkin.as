////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.mobile
{
    
import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.text.TextLineMetrics;

import mx.core.IUITextField;
import mx.core.UIComponent;
import mx.core.UITextField;
import mx.core.mx_internal;
import mx.states.SetProperty;
import mx.states.State;
import mx.utils.ColorUtil;

import spark.components.Button;
import spark.components.supportClasses.ButtonLabelPlacement;

use namespace mx_internal;

/*    
    ISSUES:
    - should we support textAlign
    - labelPlacement a style?
    - iconClass a style?
    - need a downIconClass style? 
    - should the label be UITextField or another text class?  

*/
/**
 *  Actionscript based skin for mobile applications. The skin supports iconClass and labelPlacement. It uses
 *  a couple of FXG classes to implement the vector drawing.  
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ButtonSkin extends UIComponent
{	
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    public function ButtonSkin()
    {
        super();
        
        states = [
            new State({name:"up"}), 
            new State({name:"over"}),
            new State({name:"down"}),
            new State({name:"disabled", 
                overrides:[new SetProperty(this, "alpha", 0.5)]})
        ];
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    private var textField:IUITextField;
    private var textFieldShadow:IUITextField;
    private var bgImg:DisplayObject;
    
    private static var matrix:Matrix = new Matrix();
    
    // TODO (jszeto) move to const values
    // TODO (jszeto) add comments
    private static var alphas:Array = [1, 1, 1];
    private static var ratios:Array = [0, 127.5, 255];	
    // TODO (jszeto) move to local vars
    private static var colors:Array = [];  
    
    // Holds the icon
    private var iconDisplay:DisplayObject;
    
    // TODO (jszeto) Either static consts or styles
    private var gap:int = 10;
    private var paddingLeft:int = 10;
    private var paddingRight:int = 10;
    private var paddingTop:int = 10;
    private var paddingBottom:int = 10;

    private static var TEXT_WIDTH_PADDING:Number = UITextField.TEXT_WIDTH_PADDING + 1;

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    /** 
     * @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
    public var hostComponent:Button; // SkinnableComponent will popuplate
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  currentState
    //----------------------------------
    
    override public function set currentState(value:String):void
    {
        if (value == currentState)
            return;
        
        super.currentState = value;
        
        // TODO (jszeto) maybe call invalidateDisplayList instead of applyFXG
        applyFXG();
    }
    
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
        // Set up text fields only if we have a hostComponent
        // TODO (jszeto) Do we need to check for this?
        if (hostComponent != null) 
        {            
            textField = IUITextField(createInFontContext(UITextField));
            textFieldShadow = IUITextField(createInFontContext(UITextField));
           
            // TODO (jszeto) Ask XD if shadow color is dependant upon text color
            textFieldShadow.setColor(0x000000);
            textFieldShadow.alpha = .20;
            
            addChild(UITextField(textFieldShadow));
            addChild(UITextField(textField));
            
            hostComponent.addEventListener("contentChange", hostComponent_contentChangeHandler);
        }
        
        var iconClass:Class = getStyle("iconClass");
        
        if (iconClass)
        {
            // Should be a bitmap
            iconDisplay = new iconClass();
            addChild(iconDisplay);
        }
        
        applyFXG();
    }
    
    /**
     *  @private 
     */ 
    override public function styleChanged(styleProp:String):void {
        // TODO: Refactor to check whether styleProp is one of three following value types and update 
        // the styles accordingly:
        // 1) Individual style name (e.g. "fontSize"). 2) "styleName". 3) null. 
        // If 1) reset only individual style. If 2) or 3), reset all styles
        
        // Only deal with text if a hostComponent exists and text fields are not empty
        /*if(hostComponent != null && textField != null && textFieldShadow != null) {
            var tf:TextFormat = textField.defaultTextFormat;
            
            tf = setTextFormat(tf);
            
            //textField.setTextFormat(tf);
            tf.color = 0x000000;
            textFieldShadow.setTextFormat(tf);
            textFieldShadow.alpha = .20;
        }*/
        
        // TODO Reapply the color to the textFieldShadow
        // TODO (jszeto) Add check for change to iconClass
        
        super.styleChanged(styleProp);
    }
    
    /**
     *  @private 
     */ 
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        // TODO (jszeto) is this necessary? Won't the contentChange handler take care of this?
        updateLabel();
    }
    
    /**
     *  @private 
     */ 
    override protected function measure():void
    {        
        super.measure();
        
        var labelPlacement:String = getStyle("labelPlacement");
        if (labelPlacement == null)
            labelPlacement = ButtonLabelPlacement.RIGHT;
        
        var textWidth:Number = 0;
        var textHeight:Number = 0;
        var lineMetrics:TextLineMetrics;
        
        if (hostComponent && hostComponent.label != "")
        {
            lineMetrics = measureText(hostComponent.label);
            textWidth = lineMetrics.width + TEXT_WIDTH_PADDING;
            textHeight = lineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;
        }
        else
        {
            lineMetrics = measureText("Wj");
            textWidth = lineMetrics.width + TEXT_WIDTH_PADDING;
            textHeight = lineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;
        }
        
        var iconWidth:Number = iconDisplay ? iconDisplay.width : 0;
        var iconHeight:Number = iconDisplay ? iconDisplay.height : 0;
        var w:Number = 0;
        var h:Number = 0;
        
        if (labelPlacement == ButtonLabelPlacement.LEFT ||
            labelPlacement == ButtonLabelPlacement.RIGHT)
        {
            w = textWidth + iconWidth;
            if (textWidth && iconWidth)
                w += gap; //getStyle("horizontalGap");
            h = Math.max(textHeight, iconHeight);
        }
        else
        {
            w = Math.max(textWidth, iconWidth);
            h = textHeight + iconHeight;
            if (textHeight && iconHeight)
                h += gap; // getStyle("verticalGap");
        }
        
        // Add padding. !!!Need a hack here to only add padding if we don't
        // have text or icon. This is required to make small buttons (like scroll
        // arrows and numeric stepper buttons) look correct.
        if (textWidth || iconWidth)
        {
            w += paddingLeft + paddingRight; //getStyle("paddingLeft") + getStyle("paddingRight");
            h += paddingTop + paddingBottom; //getStyle("paddingTop") + getStyle("paddingBottom");
        }
        
        measuredMinWidth = measuredWidth = w;
        measuredMinHeight = measuredHeight = h;
    }
    
    /**
     *  @private 
     */ 
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {       
        graphics.clear();
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        var labelWidth:Number = 0;
        var labelHeight:Number = 0;
        
        var labelX:Number = 0;
        var labelY:Number = 0;
        
        var iconWidth:Number = 0;
        var iconHeight:Number = 0;
        
        var iconX:Number = 0;
        var iconY:Number = 0;
        
        var horizontalGap:Number = 0;
        var verticalGap:Number = 0;
        
        var labelPlacement:String = getStyle("labelPlacement");
        if (labelPlacement == null)
            labelPlacement = ButtonLabelPlacement.RIGHT;
        
        var textWidth:Number = 0;
        var textHeight:Number = 0;
        
        var lineMetrics:TextLineMetrics;
        
        // Size the FXG background            
        if (bgImg != null) 
        {	
            // TODO (jszeto) Figure out why this is .5 Should it be 0?
            bgImg.x = bgImg.y = 0.5;
            bgImg.width = unscaledWidth;
            bgImg.height = unscaledHeight;
        }
        
        // Draw the gradient background
        matrix.createGradientBox(unscaledWidth - 1, unscaledHeight - 2, Math.PI / 2, 0, 0);
        var chromeColor:uint = getStyle("chromeColor");
        colors[0] = ColorUtil.adjustBrightness2(chromeColor, 20);
        colors[1] = chromeColor;
        colors[2] = ColorUtil.adjustBrightness2(chromeColor, -20);
        
        graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
        
        // Draw the background rectangle within the border, so the corners of the rect don't 
        // spill over into the rounded corners of the Button
        graphics.drawRect(1, 1, unscaledWidth - 1, unscaledHeight - 2);
        graphics.endFill();
        
        if (hostComponent && hostComponent.label != "")
        {
            lineMetrics = measureText(hostComponent.label);
            textWidth = lineMetrics.width + TEXT_WIDTH_PADDING;
            textHeight = lineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;
        }
        else
        {
            lineMetrics = measureText("Wj");
            textWidth = lineMetrics.width + TEXT_WIDTH_PADDING;
            textHeight = lineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;
        }
        
        var textAlign:String = "center"; // getStyle("textAlign");
        // Map new Spark values that might be set in a selector
        // affecting both Halo and Spark components.
        if (textAlign == "start") 
            textAlign = TextFormatAlign.LEFT;
        else if (textAlign == "end")
            textAlign = TextFormatAlign.RIGHT;
        
        var viewWidth:Number = unscaledWidth;
        var viewHeight:Number = unscaledHeight;
        
        if (iconDisplay)
        {
            iconWidth = iconDisplay.width;
            iconHeight = iconDisplay.height;
        }
        
        if (labelPlacement == ButtonLabelPlacement.LEFT ||
            labelPlacement == ButtonLabelPlacement.RIGHT)
        {
            horizontalGap = gap;
            
            if (iconWidth == 0 || textWidth == 0)
                horizontalGap = 0;
            
            if (textWidth > 0)
            {
                labelWidth = 
                    Math.max(Math.min(viewWidth - iconWidth - horizontalGap -
                        paddingLeft - paddingRight, textWidth), 0);
            }
            else
            {
                labelWidth = 0;
            }
            labelHeight = Math.min(viewHeight, textHeight);
            
            if (textAlign == "left")
            {
                labelX += paddingLeft;
            }
            else if (textAlign == "right")
            {
                labelX += (viewWidth - labelWidth - iconWidth - 
                    horizontalGap - paddingRight);
            }
            else // "center" -- default value
            {
                labelX += ((viewWidth - labelWidth - iconWidth - 
                    horizontalGap - paddingLeft - paddingRight) / 2) + paddingLeft;
            }
            
            if (labelPlacement == ButtonLabelPlacement.RIGHT)
            {
                labelX += iconWidth + horizontalGap;
                iconX = labelX - (iconWidth + horizontalGap);
            }
            else
            {
                iconX  = labelX + labelWidth + horizontalGap; 
            }
            
            iconY  = ((viewHeight - iconHeight - paddingTop - paddingBottom) / 2) + paddingTop;
            labelY = ((viewHeight - labelHeight - paddingTop - paddingBottom) / 2) + paddingTop;
        }
        else
        {
            verticalGap = gap;
            
            if (iconHeight == 0 || !hostComponent || hostComponent.label == "")
                verticalGap = 0;
            
            if (textWidth > 0)
            {
                labelWidth = Math.max(viewWidth - paddingLeft - paddingRight, 0);
                labelHeight =
                    Math.min(viewHeight - iconHeight - paddingTop - paddingBottom - verticalGap, textHeight);
            }
            else
            {
                labelWidth = 0;
                labelHeight = 0;
            }
            
            labelX = paddingLeft;
            
            if (textAlign == "left")
            {
                iconX += paddingLeft;
            }
            else if (textAlign == "right")
            {
                iconX += Math.max(viewWidth - iconWidth - paddingRight, paddingLeft);
            }
            else
            {
                iconX += ((viewWidth - iconWidth - paddingLeft - paddingRight) / 2) + paddingLeft;
            }
            
            if (labelPlacement == ButtonLabelPlacement.TOP)
            {
                labelY += ((viewHeight - labelHeight - iconHeight - 
                    paddingTop - paddingBottom - verticalGap) / 2) + paddingTop;
                iconY += labelY + labelHeight + verticalGap;
            }
            else
            {
                iconY += ((viewHeight - labelHeight - iconHeight - 
                    paddingTop - paddingBottom - verticalGap) / 2) + paddingTop;
                labelY += iconY + iconHeight + verticalGap;
            }
        }
        
        textField.x = Math.round(labelX);
        textField.y = Math.round(labelY);
        textField.height = labelHeight;
        textField.width = labelWidth;
        
        textFieldShadow.x = Math.round(labelX);
        textFieldShadow.y = Math.round(labelY + 1);
        textFieldShadow.height = labelHeight;
        textFieldShadow.width = labelWidth;
        
        if (iconDisplay)
        {                
            iconDisplay.x = Math.round(iconX);
            iconDisplay.y = Math.round(iconY);
        }        
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     */ 
    private function hostComponent_contentChangeHandler(event:Event):void 
    {
        updateLabel();
    }
    
    /**
     *  @private 
     */ 
    private function updateLabel():void 
    {
        if (hostComponent != null && textField) 
        {
            textField.text = hostComponent.label;
            textFieldShadow.text = hostComponent.label;
            invalidateSize();
        }
    }

    /**
     *  @private 
     *  TODO (jszeto) fix up this logic
     */ 
    private function applyFXG():void 
    {
        if (currentState == "down") 
        {
            if (bgImg != null)
                removeChild(bgImg);
            bgImg = new Button_bg_down();
        }
        else 
        {
            if (!(bgImg is Button_bg_up)) 
            {
                if (bgImg != null) 
                    removeChild(bgImg);
                bgImg = new Button_bg_up();
            }
        }
        
        if (bgImg != null) 
        {
            // Put the fxg background on the bottom
            addChildAt(bgImg, 0);
            invalidateDisplayList();
        }
    }
    
}
}