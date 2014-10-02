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

package spark.skins.ios7
{

import flash.display.DisplayObject;

import mx.core.DPIClassification;

import spark.skins.ios7.assets.RadioButton_up;
import spark.skins.mobile.supportClasses.SelectableButtonSkinBase;

/**
 *  ActionScript-based skin for RadioButton controls in mobile applications. 
 * 
 * @see spark.components.RadioButton
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class RadioButtonSkin extends SelectableButtonSkinBase
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    static private const exclusions:Array = ["labelDisplay", "labelDisplayShadow"];
	
	//--------------------------------------------------------------------------
	//
	//  Member variables
	//
	//--------------------------------------------------------------------------
	
	protected var symbolOffsetX:Number;
	protected var symbolOffsetY:Number;
	protected var iconWidth:Number;
	protected var iconHeight:Number;
	protected var symbolWidth:Number;
	protected var symbolHeight:Number;
    
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
    public function RadioButtonSkin()
    {
        super();
        
        layoutPaddingLeft = 0;
        layoutPaddingRight = 0;
        layoutPaddingTop = 0;
        layoutPaddingBottom = 0;

		upIconClass = spark.skins.ios7.assets.RadioButton_up;
		upSelectedIconClass = spark.skins.ios7.assets.RadioButton_up;
		downIconClass = spark.skins.ios7.assets.RadioButton_down;
		downSelectedIconClass = spark.skins.ios7.assets.RadioButton_down;
		upSymbolIconClass =  null;
		downSymbolIconClass =  null;
		upSymbolIconSelectedClass = spark.skins.ios7.assets.RadioButton_upSymbolSelected;
		downSymbolIconSelectedClass = spark.skins.ios7.assets.RadioButton_downSymbolSelected;
		
        switch (applicationDPI)
        {
			case DPIClassification.DPI_640:
			{
				
				layoutGap = 16;
				minWidth = 128;
				minHeight = 128;
				iconWidth = 128;
				iconHeight = 128;
				symbolWidth = 44;
				symbolHeight = 44;
				symbolOffsetX = 44;
				symbolOffsetY = 44;
				
				break;
			}
            case DPIClassification.DPI_480:
            {
                
				layoutGap = 12;
				minWidth = 96;
				minHeight = 96;
				iconWidth = 96;
				iconHeight = 96;
				symbolWidth = 33;
				symbolHeight = 33;
				symbolOffsetX = 33;
				symbolOffsetY = 33;
                
                break;
            }
            case DPIClassification.DPI_320:
            {
                
				layoutGap = 8;
				minWidth = 64;
				minHeight = 64;
				iconWidth = 64;
				iconHeight = 64;
				symbolWidth = 22;
				symbolHeight = 22;
				symbolOffsetX = 22;
				symbolOffsetY = 22;
                
                break;
            }
            case DPIClassification.DPI_240:
            {
                
				layoutGap = 6;
				minWidth = 48;
				minHeight = 48;
				iconWidth = 48;
				iconHeight = 48;
				symbolWidth = 16.5;
				symbolHeight = 16.5;
				symbolOffsetX = 16.5;
				symbolOffsetY = 16.5;
                
                break;
            }
			case DPIClassification.DPI_120:
			{
				
				layoutGap = 3;
				minWidth = 24;
				minHeight = 24;
				iconWidth = 24;
				iconHeight = 24;
				symbolWidth = 8.25;
				symbolHeight = 8.25;
				symbolOffsetX = 8.25;
				symbolOffsetY = 8.25;
				
				break;
			}
            default:
            {
				
                layoutGap = 4;
                minWidth = 32;
                minHeight = 32;
				iconWidth = 32;
				iconHeight = 32;
				symbolWidth = 11;
				symbolHeight = 11;
				symbolOffsetX = 11;
				symbolOffsetY = 11;
                
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  RadioButton <code>chromeColor</code> is drawn to match the FXG ellipse
     *  shape and position.
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // super draws a transparent hit zone
        super.drawBackground(unscaledWidth, unscaledHeight);

        // get the size and position of iconDisplay
        var currentIcon:DisplayObject = getIconDisplay();
        
        graphics.beginFill(getStyle("chromeColor"));
        graphics.drawEllipse(currentIcon.x + 1, currentIcon.y + 1, currentIcon.width - 2, currentIcon.height - 2);
        graphics.endFill();
    }
    
    /**
     *  @private
     */
    override protected function get focusSkinExclusions():Array 
    {
        return exclusions;
    }
	
	override protected function commitCurrentState():void
	{
		super.commitCurrentState();
		if(symbolIcon != null)
		{
			symbolIcon.width = symbolWidth;
			symbolIcon.height = symbolHeight;
		}
		var iconDisplay:DisplayObject = getIconDisplay(); 
		if(iconDisplay != null)
		{
			iconDisplay.width = iconWidth;
			iconDisplay.height = iconHeight;
		}
	}
	
	override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.layoutContents(unscaledWidth, unscaledHeight);
		// position the symbols to align with the background "icon"
		if (symbolIcon)
		{
			var currentIcon:DisplayObject = getIconDisplay();
			setElementPosition(symbolIcon, symbolOffsetX, symbolOffsetY);
		}
	}
}
}