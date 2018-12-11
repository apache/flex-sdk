////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.android4
{
import flash.display.DisplayObject;

import mx.core.DPIClassification;

import spark.components.Button;
import spark.skins.android4.assets.HSliderThumb_normal;
import spark.skins.mobile.supportClasses.MobileSkin;

/**
 *  Android 4.x specific ActionScript-based skin for the HSlider thumb skin part in mobile applications.
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
        
		thumbNormalClass = spark.skins.android4.assets.HSliderThumb_normal;
		thumbPressedClass = spark.skins.android4.assets.HSliderThumb_pressed;
		
        // set the dimensions to use based on the screen density
        switch (applicationDPI)
        {
			case DPIClassification.DPI_640:
			{
				thumbImageWidth = 116;
				thumbImageHeight = 116;
				
				hitZoneOffset = 20;
				hitZoneSideLength = 160;
				
				break;              
			}
			case DPIClassification.DPI_480:
			{
				// Note provisional may need changes
				thumbImageWidth = 88;
				thumbImageHeight = 88;
				
				hitZoneOffset = 20;
				hitZoneSideLength = 130;
				
				break;
			}
            case DPIClassification.DPI_320:
            {
                thumbImageWidth = 58;
                thumbImageHeight = 58;
                
                hitZoneOffset = 10;
                hitZoneSideLength = 80;
                
                break;              
            }
			case DPIClassification.DPI_240:
			{
				thumbImageWidth = 44;
				thumbImageHeight = 44;
				
				hitZoneOffset = 10;
				hitZoneSideLength = 65;
				
				break;
			}
			case DPIClassification.DPI_120:
			{
				thumbImageWidth = 22;
				thumbImageHeight = 22;
				
				hitZoneOffset = 5;
				hitZoneSideLength = 33;
				
				break;
			}
            default:
            {
                // default DPI_160
                thumbImageWidth = 29;
                thumbImageHeight = 29;
                
                hitZoneOffset = 5;
                hitZoneSideLength = 40;
                
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
        // put in a larger hit zone than the thumb
        graphics.beginFill(0xffffff, 0);
        graphics.drawRect(-hitZoneOffset, -hitZoneOffset, hitZoneSideLength, hitZoneSideLength);
        graphics.endFill();
    }
}
}