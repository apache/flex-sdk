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
import flash.display.Graphics;

import spark.components.Button;
import spark.primitives.Graphic;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile160.assets.HSliderThumb_normal;
import spark.skins.mobile160.assets.HSliderThumb_pressed;
import spark.skins.mobile240.assets.HSliderThumb_normal;
import spark.skins.mobile240.assets.HSliderThumb_pressed;

/**
 *  Actionscript based skin for the HSlider thumb skin part on mobile applications.
 * 
 *  Note that this particular implementation provides separate chromeColorEllipse*
 *  properties in order to handle a visible thumb image which is smaller than the
 *  actual thumb FXG asset being used. In this case, the FXG asset specifies a larger
 *  transparent background that acts as a larger "hit zone" for better usability on
 *  mobile screens.   
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class HSliderThumbSkin extends MobileSkin
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     * 
     */
	public function HSliderThumbSkin()
	{
		super();
        
        useChromeColor = true;
        
        // set the right assets and dimensions to use based on the screen density
        switch (targetDensity)
        {
            case MobileSkin.PPI240:
            {
                thumbImageWidth = 65;
                thumbImageHeight = 65;
                
                thumbNormalClass = spark.skins.mobile240.assets.HSliderThumb_normal;
                thumbPressedClass = spark.skins.mobile240.assets.HSliderThumb_pressed;
                
                // the actual thumb ellipse is inset into the overall thumb FXG asset
                chromeColorEllipseWidth = 42; 
                chromeColorEllipseHeight = 42;
                chromeColorEllipseX = 11;
                chromeColorEllipseY = 10;
                
                break;
            }
            default:
            {
                // default PPI160
                thumbImageWidth = 40;
                thumbImageHeight = 40;
                
                thumbNormalClass = spark.skins.mobile160.assets.HSliderThumb_normal;
                thumbPressedClass = spark.skins.mobile160.assets.HSliderThumb_pressed;
                
                // the actual thumb ellipse is inset into the overall thumb FXG asset
                chromeColorEllipseWidth = chromeColorEllipseHeight = 28;
                chromeColorEllipseX = chromeColorEllipseY = 6;
                
                break;
            }
                
        }
	}
	
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
	
    /** 
     * @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
	public var hostComponent:Button;
	
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    // FXG thumb classes
    /**
     *  Specifies the FXG class to use when the thumb is in the normal state
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    protected var thumbNormalClass:Class;

    /**
     *  Specifies the FXG class to use when the thumb is in the pressed state
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    protected var thumbPressedClass:Class;
    
    /**
     *  Specifies the DisplayObject to use when the thumb is in the normal state
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    protected var thumbSkin_normal:DisplayObject;

    /**
     *  Specifies the DisplayObject to use when the thumb is in the pressed state
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    protected var thumbSkin_pressed:DisplayObject;
    
    /**
     *  Specifies the current DisplayObject that should be shown
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    protected var currentThumbSkin:DisplayObject;

    /**
     *  Width of the overall thumb image
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    protected var thumbImageWidth:int;

    /**
     *  Height of the overall thumb image
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    protected var thumbImageHeight:int;
    
    /**
     *  Width of the chromeColor ellipse
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    protected var chromeColorEllipseWidth:int;
    
    /**
     *  Height of the chromeColor ellipse
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    protected var chromeColorEllipseHeight:int;


    /**
     *  X position of the chromeColor ellipse
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    protected var chromeColorEllipseX:int;

    /**
     *  Y position of the chromeColor ellipse
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    protected var chromeColorEllipseY:int;
    
    /**
     *  @private
     *  Remember which state is currently being displayed 
     */    
    private var displayedState:String;
    
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
        if (currentState == "up" || currentState == "disabled")
        {
            // show the normal button
            if (!thumbSkin_normal)
            {
                thumbSkin_normal = new thumbNormalClass();
                addChild(thumbSkin_normal);
            }
            else
            {
                thumbSkin_normal.visible = true;                
            }
            currentThumbSkin = thumbSkin_normal;
            
            // hide the pressed button
            if (thumbSkin_pressed)
                thumbSkin_pressed.visible = false;
        }
        else if (currentState == "down")
        {
            // show the pressed button
            if (!thumbSkin_pressed)
            {
                thumbSkin_pressed = new thumbPressedClass();
                addChild(thumbSkin_pressed);
            }
            else
            {
                thumbSkin_pressed.visible = true;
            }
            currentThumbSkin = thumbSkin_pressed;

            // hide the normal button
            if (thumbSkin_normal)
                thumbSkin_normal.visible = false;
        }
        else if (currentState == "disabled")
        {
            // TODO: (Tom) add opaque thumb in disabled state here
        }

        displayedState = currentState;
        
        invalidateDisplayList();
    }
    
    /**
     *  @private 
     */ 
	override protected function measure():void
	{
        measuredWidth = thumbImageWidth;
        measuredHeight = thumbImageHeight;
	}
	
    /**
     *  @private 
     */ 
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		resizeElement(currentThumbSkin, unscaledWidth, unscaledHeight);
		positionElement(currentThumbSkin, 0, 0)

        super.updateDisplayList(unscaledWidth, unscaledHeight);
    }
    
    /**
     *  @private 
     */ 
    override protected function drawChromeColor(chromeColorGraphics:Graphics, unscaledWidth:Number, unscaledHeight:Number):void
    {
        var chromeColor:uint = getChromeColor();
        chromeColorGraphics.beginFill(chromeColor, 1);
        
        chromeColorGraphics.drawEllipse(chromeColorEllipseX, chromeColorEllipseY,
                                        chromeColorEllipseWidth, chromeColorEllipseHeight);
        chromeColorGraphics.endFill();
    }
}
}