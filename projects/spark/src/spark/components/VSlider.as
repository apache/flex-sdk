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
import mx.core.LayoutDirection;
import mx.utils.PopUpUtil;

import spark.components.supportClasses.SliderBase;

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("VSlider.png")]

[DefaultTriggerEvent("change")]

/**
 * Because this component does not define a skin for the mobile theme, Adobe
 * recommends that you not use it in a mobile application. Alternatively, you
 * can define your own mobile skin for the component. For more information,
 * see <a href="http://help.adobe.com/en_US/flex/mobileapps/WS19f279b149e7481c698e85712b3011fe73-8000.html">Basics of mobile skinning</a>.
 */
[DiscouragedForProfile("mobileDevice")]

/**
 *  The VSlider (vertical slider) control lets users select a value
 *  by moving a slider thumb between the end points of the slider track.
 *  The slider track stretches from bottom to top. The current value of 
 *  the slider is determined by the relative location of the thumb between
 *  the end points of the slider, corresponding to the slider's minimum and maximum values.
 * 
 *  <p>The slider can allow a continuous range of values between its minimum and maximum values, 
 *  or it can be restricted to values at concrete intervals between the minimum and maximum value. 
 *  It can use a data tip to display its current value.</p>
 *
 *  <p>The VSlider control has the following default characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>11 pixels wide by 100 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Minimum size</td>
 *           <td>11 pixels wide and 11 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Maximum size</td>
 *           <td>10000 pixels wide and 10000 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Default skin classes</td>
 *           <td>spark.skins.spark.VSliderSkin
 *              <p>spark.skins.spark.VSliderThumbSkin</p>
 *              <p>spark.skins.spark.VSliderTrackSkin</p></td>
 *        </tr>
 *     </table>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:VSlider&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds no tag attributes:</p>
 *  <pre>
 *  &lt;s:VSlider/&gt;
 *  </pre>
 *
 *  @see spark.skins.spark.VSliderSkin
 *  @see spark.skins.spark.VSliderThumbSkin
 *  @see spark.skins.spark.VSliderTrackSkin
 * 
 *  @includeExample examples/VSliderExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class VSlider extends SliderBase
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
    public function VSlider()
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
     *  Note that this method is slightly different than the HSlider version because
     *  the minimum occurs at the bottom of the VSlider, where y is largest.
     */
    override protected function pointToValue(x:Number, y:Number):Number
    {
        if (!thumb || !track)
            return 0;

        var range:Number = maximum - minimum;
        var thumbRange:Number = track.getLayoutBoundsHeight() - thumb.getLayoutBoundsHeight();
        return minimum + ((thumbRange != 0) ? ((thumbRange - y) / thumbRange) * range : 0); 
     }

    /**
     *  @private
     */
    override protected function updateSkinDisplayList():void
    {
        if (!thumb || !track)
            return;
    
        var thumbRange:Number = track.getLayoutBoundsHeight() - thumb.getLayoutBoundsHeight();
        var range:Number = maximum - minimum;
        
        // calculate new thumb position.
        var thumbPosTrackY:Number = (range > 0) ? thumbRange - (((pendingValue - minimum) / range) * thumbRange) : 0;
        
        // convert to parent's coordinates.
        var thumbPos:Point = track.localToGlobal(new Point(0, thumbPosTrackY));
        var thumbPosParentY:Number = thumb.parent.globalToLocal(thumbPos).y;
        
        thumb.setLayoutBoundsPosition(thumb.getLayoutBoundsX(), Math.round(thumbPosParentY));
    }
    
    /**
     *  @private
     */
    override protected function updateDataTip(dataTipInstance:IDataRenderer, initialPosition:Point):void
    {
        var tipAsDisplayObject:DisplayObject = dataTipInstance as DisplayObject;
        
        if (tipAsDisplayObject && thumb)
        {
            // Get the tips bounds. We only care about the dimensions.
            var tipBounds:Rectangle = tipAsDisplayObject.getBounds(tipAsDisplayObject.parent);

            // We are working in thumb.parent coordinates and we assume that there's no scale factor
            // between the tooltip and the thumb.parent.
            var relY:Number = thumb.getLayoutBoundsY() + 
                            (thumb.getLayoutBoundsHeight() - tipAsDisplayObject.height) / 2;
            var relX:Number = layoutDirection == LayoutDirection.RTL ? 
                              initialPosition.x + tipBounds.width : 
                              initialPosition.x;

            // Ensure that we don't overlap the screen
            var pt:Point = PopUpUtil.positionOverComponent(thumb.parent,
                                                           systemManager,
                                                           tipBounds.width, 
                                                           tipBounds.height,
                                                           NaN,
                                                           null,
                                                           new Point(relX, relY));

            // The point is in sandboxRoot coordinates, however tipAsDisplayObject is paranted to systemManager,
            // convert to tipAsDisplayObject's parent coordinates
            pt = tipAsDisplayObject.parent.globalToLocal(systemManager.getSandboxRoot().localToGlobal(pt));
            
            tipAsDisplayObject.x = Math.floor(pt.x);
            tipAsDisplayObject.y = Math.floor(pt.y);
        }
    }
    
}

}
