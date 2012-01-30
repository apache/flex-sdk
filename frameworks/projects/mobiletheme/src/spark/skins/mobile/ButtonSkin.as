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

package spark.skins.mobile
{

import flash.display.DisplayObject;
import flash.display.GradientType;

import mx.core.DPIClassification;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.utils.ColorUtil;

import spark.components.supportClasses.StyleableTextField;
import spark.skins.mobile.supportClasses.ButtonSkinBase;
import spark.skins.mobile160.assets.Button_down;
import spark.skins.mobile160.assets.Button_up;
import spark.skins.mobile240.assets.Button_down;
import spark.skins.mobile240.assets.Button_up;
import spark.skins.mobile320.assets.Button_down;
import spark.skins.mobile320.assets.Button_up;


use namespace mx_internal;

/**
 *  ActionScript-based skin for Button controls in mobile applications. The skin supports 
 *  iconClass and labelPlacement. It uses FXG classes to 
 *  implement the vector drawing.  
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class ButtonSkin extends ButtonSkinBase
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     * An array of color distribution ratios.
     * This is used in the chrome color fill.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    mx_internal static const CHROME_COLOR_RATIOS:Array = [0, 127.5];
    
    /**
     * An array of alpha values for the corresponding colors in the colors array. 
     * This is used in the chrome color fill.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    mx_internal static const CHROME_COLOR_ALPHAS:Array = [1, 1];
    
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
     */
    public function ButtonSkin()
    {
        super();
        
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                upBorderSkin = spark.skins.mobile320.assets.Button_up;
                downBorderSkin = spark.skins.mobile320.assets.Button_down;
                
                layoutGap = 10;
                layoutCornerEllipseSize = 20;
                layoutPaddingLeft = 20;
                layoutPaddingRight = 20;
                layoutPaddingTop = 20;
                layoutPaddingBottom = 20;
                layoutBorderSize = 2;
                measuredDefaultWidth = 64;
                measuredDefaultHeight = 86;
                
                break;
            }
            case DPIClassification.DPI_240:
            {
                upBorderSkin = spark.skins.mobile240.assets.Button_up;
                downBorderSkin = spark.skins.mobile240.assets.Button_down;
                
                layoutGap = 7;
                layoutCornerEllipseSize = 15;
                layoutPaddingLeft = 15;
                layoutPaddingRight = 15;
                layoutPaddingTop = 15;
                layoutPaddingBottom = 15;
                layoutBorderSize = 1;
                measuredDefaultWidth = 48;
                measuredDefaultHeight = 65;
                
                break;
            }
            default:
            {
                // default DPI_160
                upBorderSkin = spark.skins.mobile160.assets.Button_up;
                downBorderSkin = spark.skins.mobile160.assets.Button_down;
                
                layoutGap = 5;
                layoutCornerEllipseSize = 10;
                layoutPaddingLeft = 10;
                layoutPaddingRight = 10;
                layoutPaddingTop = 10;
                layoutPaddingBottom = 10;
                layoutBorderSize = 1;
                measuredDefaultWidth = 32;
                measuredDefaultHeight = 43;
                
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Layout variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Defines the corner radius.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */  
    protected var layoutCornerEllipseSize:uint;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    private var _border:DisplayObject;
    
    private var changeFXGSkin:Boolean = false;
    
    private var borderClass:Class;
    
    mx_internal var fillColorStyleName:String = "chromeColor";
    
    /**
     *  Defines the shadow for the Button control's label.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */  
    public var labelDisplayShadow:StyleableTextField;
    
    /**
     *  Read-only button border graphic. Use getBorderClassForCurrentState()
     *  to specify a graphic per-state.
     * 
     *  @see #getBorderClassForCurrentState()
     */
    protected function get border():DisplayObject
    {
        return _border;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Class to use for the border in the up state.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     * 
     *  @default Button_up
     */  
    protected var upBorderSkin:Class;
    
    /**
     *  Class to use for the border in the down state.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     *       
     *  @default Button_down
     */ 
    protected var downBorderSkin:Class;
    
    
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
        super.createChildren();
        
        if (!labelDisplayShadow && labelDisplay)
        {
            labelDisplayShadow = StyleableTextField(createInFontContext(StyleableTextField));
            labelDisplayShadow.styleName = this;
            labelDisplayShadow.colorName = "textShadowColor";
            labelDisplayShadow.useTightTextBounds = false;
            
            // add shadow before display
            addChildAt(labelDisplayShadow, getChildIndex(labelDisplay));
        }
        
        setStyle("textAlign", "center");
    }
    
    /**
     *  @private 
     */
    override protected function commitCurrentState():void
    {   
        super.commitCurrentState();
        
        borderClass = getBorderClassForCurrentState();
        
        if (!(_border is borderClass))
            changeFXGSkin = true;
        
        // update borderClass and background
        invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        // size the FXG background
        if (changeFXGSkin)
        {
            changeFXGSkin = false;
            
            if (_border)
            {
                removeChild(_border);
                _border = null;
            }
            
            if (borderClass)
            {
                _border = new borderClass();
                addChildAt(_border, 0);
            }
        }
        
        layoutBorder(unscaledWidth, unscaledHeight);
        
        // update label shadow
        labelDisplayShadow.alpha = getStyle("textShadowAlpha");
        labelDisplayShadow.commitStyles();
        
        // don't use tightText positioning on shadow
        setElementPosition(labelDisplayShadow, labelDisplay.x, labelDisplay.y + 1);
        setElementSize(labelDisplayShadow, labelDisplay.width, labelDisplay.height);
        
        // if labelDisplay is truncated, then push it down here as well.
        // otherwise, it would have gotten pushed in the labelDisplay_valueCommitHandler()
        if (labelDisplay.isTruncated)
            labelDisplayShadow.text = labelDisplay.text;
    }
    
    /**
     *  Position the background of the skin. Override this function to re-position the background. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */ 
    mx_internal function layoutBorder(unscaledWidth:Number, unscaledHeight:Number):void
    {
        setElementSize(border, unscaledWidth, unscaledHeight);
        setElementPosition(border, 0, 0);
    }
    
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.drawBackground(unscaledWidth, unscaledHeight);
        
        var chromeColor:uint = getStyle(fillColorStyleName);
        
        // In the down state, the fill shadow is defined in the FXG asset
        if (currentState == "down")
        {
            graphics.beginFill(chromeColor);
        }
        else
        {
            var colors:Array = [];
            colorMatrix.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0);
            colors[0] = ColorUtil.adjustBrightness2(chromeColor, 70);
            colors[1] = chromeColor;
            
            graphics.beginGradientFill(GradientType.LINEAR, colors, CHROME_COLOR_ALPHAS, CHROME_COLOR_RATIOS, colorMatrix);
        }
        
        // inset chrome color by BORDER_SIZE
        // bottom line is a shadow
        graphics.drawRoundRect(layoutBorderSize, layoutBorderSize, 
            unscaledWidth - (layoutBorderSize * 2), 
            unscaledHeight - (layoutBorderSize * 2), 
            layoutCornerEllipseSize, layoutCornerEllipseSize);
        graphics.endFill();
    }
    
    /**
     *  Returns the borderClass to use based on the currentState.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected function getBorderClassForCurrentState():Class
    {
        if (currentState == "down") 
            return downBorderSkin;
        else
            return upBorderSkin;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     */
    override protected function labelDisplay_valueCommitHandler(event:FlexEvent):void 
    {
        super.labelDisplay_valueCommitHandler(event);
        labelDisplayShadow.text = labelDisplay.text;
    }
    
}
}