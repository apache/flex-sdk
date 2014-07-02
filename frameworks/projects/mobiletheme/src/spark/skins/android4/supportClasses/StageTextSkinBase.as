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
package spark.skins.android4.supportClasses
{
import flash.display.DisplayObject;
import flash.events.FocusEvent;

import mx.core.DPIClassification;
import mx.core.mx_internal;

import spark.components.supportClasses.IStyleableEditableText;
import spark.components.supportClasses.SkinnableTextBase;
import spark.components.supportClasses.StyleableStageText;
import spark.components.supportClasses.StyleableTextField;
import spark.core.IDisplayText;
import spark.skins.mobile.supportClasses.MobileSkin;

use namespace mx_internal;

/**
 *  ActionScript-based skin for text input controls in mobile applications. 
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.6
 */
public class StageTextSkinBase extends MobileSkin
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
     *  @playerversion AIR 3.0 
     *  @productversion Flex 4.6
     * 
     */
    public function StageTextSkinBase()
    {
        super();
		
        switch (applicationDPI)
        {
			case DPIClassification.DPI_640:
			{	
				measuredDefaultWidth = 1200;
				measuredDefaultHeight = 132;
				layoutBorderSize = 4;
				flatheight = 9;
				break;
			}
			case DPIClassification.DPI_480:
			{				
				measuredDefaultWidth = 880;
				measuredDefaultHeight = 100;	
				layoutBorderSize = 3;
				flatheight = 7;
				break;
			}
            case DPIClassification.DPI_320:
            {               
                measuredDefaultWidth = 600;
                measuredDefaultHeight = 66;   
				layoutBorderSize = 2;
				flatheight = 6;
                break;
            }
			case DPIClassification.DPI_240:
			{				
				measuredDefaultWidth = 440;
				measuredDefaultHeight = 50;			
				layoutBorderSize = 2;
				flatheight = 5;
				break;
			}
			case DPIClassification.DPI_120:
			{				
				measuredDefaultWidth = 220;
				measuredDefaultHeight = 25;		
				layoutBorderSize = 1;
				flatheight = 2;
				break;
			}
            default:
			{
                measuredDefaultWidth = 300;
                measuredDefaultHeight = 33;
				layoutBorderSize = 1;
				flatheight = 3; 
                break;
            }
				
        }
		addEventListener(FocusEvent.FOCUS_IN, focusChangeHandler);
		addEventListener(FocusEvent.FOCUS_OUT, focusChangeHandler);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Graphics variables
    //
    //--------------------------------------------------------------------------


    //--------------------------------------------------------------------------
    //
    //  Layout variables
    //
    //-------------------------------------------------------------------------- 
    
    /**
     *  Defines the border's thickness.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.6
     */
    protected var layoutBorderSize:uint;
	
	protected var flatheight:uint;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
	
	protected var isFocused:Boolean = false;
	
    /**
     *  @private
     * 
     *  Instance of the border graphics.
     */
    protected var border:DisplayObject;
    
    private var borderVisibleChanged:Boolean = false;

    /**
     *  @private
     * 
     *  Multiline flag.
     */
    protected var multiline:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts
    //
    //--------------------------------------------------------------------------
    
    /**
     *  textDisplay skin part.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.6
     */
    public var textDisplay:IStyleableEditableText; 
	
    [Bindable]
    /**
     *  Bindable promptDisplay skin part. Bindings fire when promptDisplay is
     *  removed and added for proper updating by the SkinnableTextBase.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.6
     */
    public var promptDisplay:IDisplayText;

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
        
        if (!textDisplay)
        {
            textDisplay = createTextDisplay();
            textDisplay.editable = true;
            textDisplay.styleName = this;
            this.addChild(DisplayObject(textDisplay));
        }
    }

    /**  Could be overridden by subclasses
     *
     * @return   instance of  IStyleableEditableText
     */
    protected function createTextDisplay():IStyleableEditableText
	{
        return   new StyleableStageText(multiline);
    }

    /**
     *  @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.drawBackground(unscaledWidth, unscaledHeight);
        
        var contentBackgroundColor:uint = getStyle("contentBackgroundColor");
        var contentBackgroundAlpha:Number = getStyle("contentBackgroundAlpha");	
		//change border color and thickness when in focus
		var borderColor:uint = isFocused ? getStyle("focusColor") : getStyle("borderColor");
		var selectWidth:uint = isFocused ? layoutBorderSize + 1 : layoutBorderSize;
        if (isNaN(contentBackgroundAlpha))
		{
            contentBackgroundAlpha = 1;
		}        
		var halfGap:int = flatheight * 2;
		// change the border type
		if (getStyle("contentBackgroundBorder") == "flat")
		{		
			//background
			graphics.beginFill(contentBackgroundColor, contentBackgroundAlpha);
			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight - flatheight);
			graphics.endFill();
			//begin flat border
			graphics.beginFill(borderColor, 1);
			//left half border
			graphics.drawRect(0, unscaledHeight - halfGap, selectWidth, flatheight );
			//bottom border
			graphics.drawRect(0, unscaledHeight - flatheight, unscaledWidth, selectWidth);
			//right border
			graphics.drawRect(unscaledWidth - selectWidth, unscaledHeight - halfGap, selectWidth, flatheight);
			graphics.endFill();
		}
		else if (getStyle("contentBackgroundBorder") == "rectangle")
		{
			var borderWidth:uint = layoutBorderSize * 2;
			//rectangle border and background
			graphics.lineStyle(selectWidth, borderColor, 1);
			graphics.beginFill(contentBackgroundColor, contentBackgroundAlpha);
			graphics.drawRect(layoutBorderSize, layoutBorderSize, unscaledWidth - borderWidth, unscaledHeight - borderWidth);
			graphics.endFill();
		}
    }
    
    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        var allStyles:Boolean = !styleProp || styleProp == "styleName";
        
        if (allStyles || styleProp == "borderVisible")
        {
            borderVisibleChanged = true;
            invalidateProperties();
        }
        
        if (allStyles || styleProp.indexOf("padding") == 0)
        {
            invalidateDisplayList();
        }       
        super.styleChanged(styleProp);
    }
	
    /**
     *  @private
     */
    override protected function commitCurrentState():void
    {
        super.commitCurrentState();
        
        alpha = currentState.indexOf("disabled") == -1 ? 1 : 0.5;
        
        var showPrompt:Boolean = currentState.indexOf("WithPrompt") != -1;

        if (showPrompt && !promptDisplay)
        {
            promptDisplay = createPromptDisplay();
            promptDisplay.addEventListener(FocusEvent.FOCUS_IN, promptDisplay_focusInHandler);
        }
        else if (!showPrompt && promptDisplay)
        {
            promptDisplay.removeEventListener(FocusEvent.FOCUS_IN, promptDisplay_focusInHandler);
            removeChild(promptDisplay as DisplayObject);
            promptDisplay = null;
        }
		super.commitCurrentState();
		
        invalidateDisplayList();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Create a control appropriate for displaying the prompt text in a mobile
     *  input field.
     */
    protected function createPromptDisplay():IDisplayText
    {
        var prompt:StyleableTextField = StyleableTextField(createInFontContext(StyleableTextField));
        prompt.styleName = this;
        prompt.editable = false;
        prompt.mouseEnabled = false;
        prompt.useTightTextBounds = false;   
        // StageText objects appear in their own layer on top of the display
        // list. So, even though this prompt may be created after the StageText
        // for textDisplay, textDisplay will still be on top.
        addChild(prompt);
        
        return prompt;
    }
    
    /**
     *  @private
     *  Utility function used by subclasses' measure functions to measure their
     *  text host components.
     */
    protected function measureTextComponent(hostComponent:SkinnableTextBase):void
    {
        var paddingLeft:Number = getStyle("paddingLeft");
        var paddingRight:Number = getStyle("paddingRight");
        var paddingTop:Number = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");
        var textHeight:Number = getStyle("fontSize");
        
        if (textDisplay)
		{
            textHeight = getElementPreferredHeight(textDisplay);
		}
        // width is based on maxChars (if set)
        if (hostComponent && hostComponent.maxChars)
        {
            // Grab the fontSize and subtract 2 as the pixel value for each character.
            // This is just an approximation, but it appears to be a reasonable one
            // for most input and most font.
            var characterWidth:int = Math.max(1, (textHeight - 2));
            measuredWidth =  (characterWidth * hostComponent.maxChars) + paddingLeft + paddingRight;
        }
        
        measuredHeight = paddingTop + textHeight + paddingBottom;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
	
	/**
	 *  Listen to see if the component gains focus then change the style to selected
	 */	
	private function focusChangeHandler(event:FocusEvent):void
	{
		isFocused = event.type == FocusEvent.FOCUS_IN;
		invalidateDisplayList();		
	}
	
    /**
     *  If the prompt is focused, we need to move focus to the textDisplay
     *  StageText. This needs to happen outside of the process of setting focus
     *  to the prompt, so we use callLater to do that.
     */
    private function focusTextDisplay():void
    {
        textDisplay.setFocus();
    }
    
    private function promptDisplay_focusInHandler(event:FocusEvent):void
    {
        callLater(focusTextDisplay);
    }
}
}