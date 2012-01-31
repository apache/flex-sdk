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

package spark.components
{

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.IDataRenderer;
import mx.core.IVisualElement;
import mx.core.LayoutDirection;
import mx.core.mx_internal;

import spark.components.supportClasses.SliderBase;

use namespace mx_internal;

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("HSlider.png")]

[DefaultTriggerEvent("change")]

/**
 * Because this component does not define a skin for the mobile theme, Adobe
 * recommends that you not use it in a mobile application. Alternatively, you
 * can define your own mobile skin for the component. For more information,
 * see <a href="http://help.adobe.com/en_US/Flex/4.0/UsingSDK/WS53116913-F952-4b21-831F-9DE85B647C8A.html"/>Spark Skinning</a>.
 */
[DiscouragedForProfile("mobileDevice")]

/**
 *  The HSlider (horizontal slider) control lets users select a value
 *  by moving a slider thumb between the end points of the slider track.
 *  The HSlider control has a horizontal direction. The slider track stretches
 *  from left to right.
 *  The current value of the slider is determined by the relative location
 *  of the thumb between the end points of the slider, corresponding to the
 *  slider's minimum and maximum values.
 *
 *  <p>The slider can allow a continuous range of values between its minimum
 *  and maximum values or it can be restricted to values at specific intervals
 *  between the minimum and maximum value. The slider can contain a data tip
 *  to show its current value.</p>
 *
 *  <p>The HSlider control has the following default characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>100 pixels wide by 11 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Minimum size</td>
 *           <td>100 pixels wide and 100 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Maximum size</td>
 *           <td>10000 pixels wide and 10000 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Default skin classes</td>
 *           <td>spark.skins.spark.HSliderSkin
 *              <p>spark.skins.spark.HSliderThumbSkin</p>
 *              <p>spark.skins.spark.HSliderTrackSkin</p></td>
 *        </tr>
 *     </table>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:HSlider&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds no tag attributes:</p>
 *  <pre>
 *  &lt;s:HSlider/&gt;
 *  </pre>
 *
 *  @see spark.skins.spark.HSliderSkin
 *  @see spark.skins.spark.HSliderThumbSkin
 *  @see spark.skins.spark.HSliderTrackSkin
 *  @includeExample examples/HSliderExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class HSlider extends SliderBase
{
    include "../core/Version.as";

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
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function HSlider()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function pointToValue(x:Number, y:Number):Number
    {
        if (!thumb || !track)
            return 0;

        var range:Number = maximum - minimum;
        var thumbRange:Number = track.getLayoutBoundsWidth() - thumb.getLayoutBoundsWidth();
        return minimum + ((thumbRange != 0) ? (x / thumbRange) * range : 0); 
    }

    /**
     *  @private
     */
    override protected function updateSkinDisplayList():void
    {
        if (!thumb || !track)
            return;
    
        var thumbRange:Number = track.getLayoutBoundsWidth() - thumb.getLayoutBoundsWidth();
        var range:Number = maximum - minimum;
        
        // calculate new thumb position.
        var thumbPosTrackX:Number = (range > 0) ? ((pendingValue - minimum) / range) * thumbRange : 0;
        
        // convert to parent's coordinates.
        var thumbPos:Point = track.localToGlobal(new Point(thumbPosTrackX, 0));
        var thumbPosParentX:Number = thumb.parent.globalToLocal(thumbPos).x;
        
        thumb.setLayoutBoundsPosition(Math.round(thumbPosParentX), thumb.getLayoutBoundsY());
    }

    /**
     *  @private
     */
    override protected function updateDataTip(dataTipInstance:IDataRenderer, initialPosition:Point):void
    {
        var tipAsDisplayObject:DisplayObject = dataTipInstance as DisplayObject;
        
        if (tipAsDisplayObject && thumb)
        {
			const tipWidth:Number = tipAsDisplayObject.width;
            var relX:Number = thumb.getLayoutBoundsX() - (tipWidth - thumb.getLayoutBoundsWidth()) / 2;

			// If this component's coordinate system is RTL (x increases to the right), then
			// getLayoutBoundsX() returns the right edge, not the left.
			if (layoutDirection == LayoutDirection.RTL)
				relX += tipAsDisplayObject.width;
			
            var o:Point = new Point(relX, initialPosition.y);
            var r:Point = thumb.parent.localToGlobal(o);  
            
            // Get the screen bounds
            var screenBounds:Rectangle = systemManager.getVisibleApplicationRect(null, true);
            // Get the tips bounds. We only care about the dimensions.
            var tipBounds:Rectangle = tipAsDisplayObject.getBounds(tipAsDisplayObject.parent);
            
                // Make sure the tip doesn't exceed the bounds of the screen
                r.x = Math.floor( Math.max(screenBounds.left, 
                                    Math.min(screenBounds.right - tipBounds.width, r.x)));
                r.y = Math.floor( Math.max(screenBounds.top, 
                                    Math.min(screenBounds.bottom - tipBounds.height, r.y)));
            
            r = tipAsDisplayObject.parent.globalToLocal(r);
            
            tipAsDisplayObject.x = r.x;
            tipAsDisplayObject.y = r.y;
        }
    }
}

}
