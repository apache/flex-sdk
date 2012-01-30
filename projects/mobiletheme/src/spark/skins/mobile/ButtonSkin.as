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
import flash.display.Graphics;

import mx.core.DeviceDensity;
import mx.core.mx_internal;
import mx.utils.ColorUtil;

import spark.skins.mobile.supportClasses.ButtonSkinBase;
import spark.skins.mobile160.assets.Button_down;
import spark.skins.mobile160.assets.Button_up;
import spark.skins.mobile240.assets.Button_down;
import spark.skins.mobile240.assets.Button_up;
import spark.skins.mobile320.assets.Button_down;
import spark.skins.mobile320.assets.Button_up;


use namespace mx_internal;

/*    
    ISSUES:
    - should we support textAlign

*/
/**
 *  Actionscript based skin for mobile applications. The skin supports 
 *  iconClass and labelPlacement. It uses a couple of FXG classes to 
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
    //  Constructor
    //
    //--------------------------------------------------------------------------
    public function ButtonSkin()
    {
        super();
        
        useChromeColor = true;
        
        switch (authorDensity)
        {
            case DeviceDensity.PPI_320:
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
                layoutMeasuredWidth = 64;
                layoutMeasuredHeight = 86;
                
                break;
            }
            case DeviceDensity.PPI_240:
            {
                upBorderSkin = spark.skins.mobile240.assets.Button_up;
                downBorderSkin = spark.skins.mobile240.assets.Button_down;
                
                layoutGap = 7;
                layoutCornerEllipseSize = 15;
                layoutPaddingLeft = 15;
                layoutPaddingRight = 15;
                layoutPaddingTop = 15;
                layoutPaddingBottom = 14;
                layoutBorderSize = 1;
                layoutMeasuredWidth = 48;
                layoutMeasuredHeight = 65;
                
                break;
            }
            default:
            {
                // default PPI160
                upBorderSkin = spark.skins.mobile160.assets.Button_up;
                downBorderSkin = spark.skins.mobile160.assets.Button_down;
                
                layoutGap = 5;
                layoutCornerEllipseSize = 10;
                layoutPaddingLeft = 10;
                layoutPaddingRight = 10;
                layoutPaddingTop = 10;
                layoutPaddingBottom = 10;
                layoutBorderSize = 1;
                layoutMeasuredWidth = 32;
                layoutMeasuredHeight = 43;
                
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Layout variables
    //
    //--------------------------------------------------------------------------
    
    protected var layoutCornerEllipseSize:uint;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    private var bgImg:DisplayObject;
    
    private var changeFXGSkin:Boolean = false;
    
    private var borderClass:Class;
    
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
     *  Class to use for the border in the up state.
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
    override protected function commitCurrentState():void
    {   
        super.commitCurrentState();
        
        borderClass = getBorderClassForCurrentState();
        
        if (!(bgImg is borderClass))
            changeFXGSkin = true;
        
        // update borderClass and background
        invalidateDisplayList();
    }
     
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // Size the FXG background   
        if (changeFXGSkin)
        {
            changeFXGSkin = false;
            
            if (bgImg)
            {
                removeChild(bgImg);
                bgImg = null;
            }
            
            if (borderClass)
            {
                // FIXME (jasonsj): cache instead of calling creating for every state change?
                bgImg = new borderClass();
                addChildAt(bgImg, 0);
            }
        }
        
        if (bgImg != null) 
        {
            layoutBorder(bgImg, unscaledWidth, unscaledHeight);
        }
                    
        // The label and icon should be placed on top of the FXG skins
        super.updateDisplayList(unscaledWidth, unscaledHeight);
    }
    
    /**
     *  Position the background of the skin. Override this function to position of the background. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */ 
    protected function layoutBorder(bgImg:DisplayObject, unscaledWidth:Number, unscaledHeight:Number):void
    {
        setElementSize(bgImg, unscaledWidth, unscaledHeight);
        setElementPosition(bgImg, 0, 0);
    }
    
	override protected function beginChromeColorFill(chromeColorGraphics:Graphics):void
	{
		// In the down state, the fill shadow is defined in the FXG asset
		if (currentState == "down")
			chromeColorGraphics.beginFill(getChromeColor());
		else
			super.beginChromeColorFill(chromeColorGraphics);
	}
	
    override protected function drawChromeColor(chromeColorGraphics:Graphics, unscaledWidth:Number, unscaledHeight:Number):void
    {
        // inset chrome color by BORDER_SIZE
        // bottom line is a shadow
        chromeColorGraphics.drawRoundRect(layoutBorderSize, layoutBorderSize, 
            unscaledWidth - (layoutBorderSize * 2), 
            unscaledHeight - (layoutBorderSize * 2), 
            layoutCornerEllipseSize, layoutCornerEllipseSize);
    }
    
    /**
     *  Returns the borderClass to use based on the currentState
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

}
}