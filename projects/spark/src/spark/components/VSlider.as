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

import spark.components.supportClasses.SliderBase;

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("VSlider.png")]
[DefaultTriggerEvent("change")]

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
            
        var thumbRange:Number = track.getLayoutBoundsHeight() - thumb.getLayoutBoundsHeight();
        var range:Number = maximum - minimum;
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
     *  FIXME (jszeto): Update this to also use the ILayoutElement API SDK-22045
     */
    override protected function updateDataTip(dataTipInstance:IDataRenderer, initialPosition:Point):void
    {
        var tipAsDisplayObject:DisplayObject = dataTipInstance as DisplayObject;
        
        if (tipAsDisplayObject && thumb)
        {
            var relY:Number = thumb.getLayoutBoundsY() + 
                            (thumb.getLayoutBoundsHeight() - tipAsDisplayObject.height) / 2;
            var o:Point = new Point(initialPosition.x, relY);
            var r:Point = localToGlobal(o);        
            
            // Get the screen bounds
            var screenBounds:Rectangle = systemManager.getVisibleApplicationRect();
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
