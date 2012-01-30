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
import flash.geom.Matrix;

import mx.core.mx_internal;
import mx.states.SetProperty;
import mx.states.State;
import mx.utils.ColorUtil;

import spark.core.SpriteVisualElement;
import spark.skins.mobile.assets.Button_down;
import spark.skins.mobile.assets.Button_up;
import spark.skins.mobile.supportClasses.ButtonSkinBase;

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
    private static const CORNER_ELLIPSE_SIZE:uint = 20;
    
    private static const BOTTOM_BORDER_SHADOW:uint = 1;
    
    private static const BORDER_SIZE:uint = 1;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    public function ButtonSkin()
    {
        super();
        upBorderSkin = Button_up;
        downBorderSkin = Button_down;
        useChromeColor = true;
    }
    
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
        resizePart(bgImg, unscaledWidth, unscaledHeight);
        positionPart(bgImg, 0, 0);
    }
    
    override protected function drawChromeColor(chromeColorGraphics:Graphics, unscaledWidth:Number, unscaledHeight:Number):void
    {
        // inset chrome color by BORDER_SIZE
        // bottom line is a shadow
        chromeColorGraphics.drawRoundRect(BORDER_SIZE, BORDER_SIZE, 
            unscaledWidth - (BORDER_SIZE * 2), 
            unscaledHeight - BOTTOM_BORDER_SHADOW - (BORDER_SIZE * 2), 
            CORNER_ELLIPSE_SIZE, CORNER_ELLIPSE_SIZE);
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