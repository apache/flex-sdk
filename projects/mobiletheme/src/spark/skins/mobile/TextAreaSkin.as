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

import flash.events.Event;

import mx.core.DeviceDensity;
import mx.core.UIComponentGlobals;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.TextArea;
import spark.skins.mobile.supportClasses.TextSkinBase;
import spark.skins.mobile160.assets.TextInput_border;
import spark.skins.mobile240.assets.TextInput_border;
import spark.skins.mobile320.assets.TextInput_border;

use namespace mx_internal;

/**
 *  Base mobile skin for spark.components.TextArea
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class TextAreaSkin extends TextSkinBase 
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    public function TextAreaSkin()
    {
        super();
        
        useChromeColor = false;
        
        switch (authorDensity)
        {
            case DeviceDensity.PPI_320:
            {
                borderClass = spark.skins.mobile320.assets.TextInput_border;
                layoutCornerEllipseSize = 24;
                layoutMeasuredWidth = 600;
                layoutMeasuredHeight = 106;
                layoutBorderSize = 2;
                
                break;
            }
            case DeviceDensity.PPI_240:
            {
                borderClass = spark.skins.mobile240.assets.TextInput_border;
                layoutCornerEllipseSize = 12;
                layoutMeasuredWidth = 440;
                layoutMeasuredHeight = 70;
                layoutBorderSize = 1;
                
                break;
            }
            default:
            {
                borderClass = spark.skins.mobile160.assets.TextInput_border;
                layoutCornerEllipseSize = 12;
                layoutMeasuredWidth = 300;
                layoutMeasuredHeight = 53;
                layoutBorderSize = 1;
                
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    public var hostComponent:TextArea;
    
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
        
        textDisplay.multiline = true;
        textDisplay.wordWrap = true;
        textDisplay.addEventListener(Event.CHANGE, textDisplay_changeHandler);
        textDisplay.addEventListener(FlexEvent.VALUE_COMMIT, textDisplay_changeHandler);
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        var paddingTop:Number = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");
        
        // TextDisplay always defaults to 440 pixels wide, and tall enough to 
        // show all text.
        // 
        // You can set an explicit width and the height will adjust accordingly. The opposite
        // is not true: setting an explicit height will not adjust the width accordingly.
        
        measuredWidth = layoutMeasuredWidth;
        
        // now we need to measure textDisplay's height.  Unfortunately, this is tricky and 
        // is dependent on textDisplay's width
        
        // if we have an estimated width, use it here.  Otherwise, we'll keep it 
        // the same width as it was before
        if (!isNaN(estimatedWidth))
            textDisplay.width = estimatedWidth - paddingTop - paddingBottom;
        
        measuredHeight = Math.max(layoutMeasuredHeight, getElementPreferredHeight(textDisplay) + paddingTop + paddingBottom);
    }
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    override public function setEstimatedSize(estimatedWidth:Number = NaN, 
                                              estimatedHeight:Number = NaN,
                                              invalidateSizeAllowed:Boolean = true):void
    {
        var oldcw:Number = this.estimatedWidth;
        var oldch:Number = this.estimatedHeight;
        
        super.setEstimatedSize(estimatedWidth, estimatedHeight, invalidateSizeAllowed);
        
        var sameWidth:Boolean = isNaN(estimatedWidth) && isNaN(oldcw) || estimatedWidth == oldcw;
        var sameHeight:Boolean = isNaN(estimatedHeight) && isNaN(oldch) || estimatedHeight == oldch;
        if (!(sameHeight && sameWidth))
        {
            if (!isNaN(explicitWidth) &&
                !isNaN(explicitHeight))
                return;
            
            if (invalidateSizeAllowed)
                invalidateSize();
        }
    }
    
    /**
     *  @private
     *  We override the setLayoutBoundsSize to determine whether to perform
     *  text reflow. This is a convenient place, as the layout passes NaN
     *  for a dimension not constrained to the parent.
     */
    override public function setLayoutBoundsSize(width:Number,
                                                 height:Number,
                                                 postLayoutTransform:Boolean = true):void
    {
        var newEstimates:Boolean = false;
        var cw:Number = estimatedWidth;
        var ch:Number = estimatedHeight;
        var oldcw:Number = cw;
        var oldch:Number = ch;
        // we got lied to, probably the constraints weren't accurate or
        // couldn't be computed
        if (!isNaN(width))
        {
            if (isNaN(estimatedWidth) || width != estimatedWidth)
            {
                cw = width;
                newEstimates = true;
            }
        }
        // we got lied to, probably the constraints weren't accurate or
        // couldn't be computed
        if (!isNaN(height))
        {
            if (isNaN(estimatedHeight) || height != estimatedHeight)
            {
                ch = height;
                newEstimates = true;
            }
        }
        if (newEstimates)
        {
            setEstimatedSize(cw, ch);
            
            // re-measure with the new estimated size
            UIComponentGlobals.layoutManager.validateClient(this, true);
            
            // set estimated size back to what it was
            setEstimatedSize(oldcw, oldch, false);
        }
        
        super.setLayoutBoundsSize(width, height, postLayoutTransform);
    }
    
    /**
     *  @private
     */
    private function textDisplay_changeHandler(event:Event):void
    {
        invalidateSize();
    }
}
}