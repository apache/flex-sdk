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

import mx.core.DPIClassification;

import spark.components.Button;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile160.assets.HSliderThumb_normal;
import spark.skins.mobile160.assets.HSliderThumb_pressed;
import spark.skins.mobile240.assets.HSliderThumb_normal;
import spark.skins.mobile240.assets.HSliderThumb_pressed;
import spark.skins.mobile320.assets.HSliderThumb_normal;
import spark.skins.mobile320.assets.HSliderThumb_pressed;

/**
 *  ActionScript-based skin for the HSlider thumb skin part in mobile applications.
 *
 *  <p>Note that this particular implementation defines a hit zone which is larger than
 *  the visible thumb for better usability on mobile screens.</p>
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
     *  Constructor.
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
        
        // set the right assets and dimensions to use based on the screen density
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                thumbImageWidth = 58;
                thumbImageHeight = 58;
                
                thumbNormalClass = spark.skins.mobile320.assets.HSliderThumb_normal;
                thumbPressedClass = spark.skins.mobile320.assets.HSliderThumb_pressed;
                
                hitZoneOffset = 10;
                hitZoneSideLength = 80;
                
                // chromeColor ellipse goes up to the thumb border
                chromeColorEllipseWidth = chromeColorEllipseHeight = 56;
                chromeColorEllipseX = 1;
                chromeColorEllipseY = 1;
                
                break;              
            }
            case DPIClassification.DPI_240:
            {
                thumbImageWidth = 44;
                thumbImageHeight = 44;
                
                thumbNormalClass = spark.skins.mobile240.assets.HSliderThumb_normal;
                thumbPressedClass = spark.skins.mobile240.assets.HSliderThumb_pressed;
                
                hitZoneOffset = 10;
                hitZoneSideLength = 65;
                
                // chromeColor ellipse goes up to the thumb border
                chromeColorEllipseWidth = chromeColorEllipseHeight = 42; 
                chromeColorEllipseX = chromeColorEllipseY = 1;
                
                break;
            }
            default:
            {
                // default DPI_160
                thumbImageWidth = 29;
                thumbImageHeight = 29;
                
                thumbNormalClass = spark.skins.mobile160.assets.HSliderThumb_normal;
                thumbPressedClass = spark.skins.mobile160.assets.HSliderThumb_pressed;
                
                hitZoneOffset = 5;
                hitZoneSideLength = 40;
                
                // chromeColor ellipse goes up to the thumb border
                chromeColorEllipseWidth = chromeColorEllipseHeight = 29;
                chromeColorEllipseX = chromeColorEllipseY = 0;
                
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
     *  Length of the sizes of the hitzone (assumed to be square)
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var hitZoneSideLength:int;
    
    /**
     *  Distance between the left edge of the hitzone and the left edge
     *  of the thumb
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    protected var hitZoneOffset:int;
    
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
        if (currentState == "up")
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
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        setElementSize(currentThumbSkin, unscaledWidth, unscaledHeight);
        setElementPosition(currentThumbSkin, 0, 0)
    }
    
    /**
     *  @private 
     */ 
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.drawBackground(unscaledWidth, unscaledHeight);

        graphics.beginFill(getStyle("chromeColor"));
        graphics.drawEllipse(chromeColorEllipseX, chromeColorEllipseY,
            chromeColorEllipseWidth, chromeColorEllipseHeight);
        graphics.endFill();
        
        // put in a larger hit zone than the thumb
        graphics.beginFill(0xffffff, 0);
        graphics.drawRect(-hitZoneOffset, -hitZoneOffset, hitZoneSideLength, hitZoneSideLength);
        graphics.endFill();
    }
}
}