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
package spark.effects
{

import spark.effects.easing.IEaser;
import spark.effects.supportClasses.AnimateFilterInstance;

import mx.core.mx_internal;
import mx.effects.Effect;
import mx.effects.IEffectInstance;
import mx.events.EffectEvent;
import mx.filters.IBitmapFilter;
import mx.styles.IStyleClient;

use namespace mx_internal;

/**
 * This effect applies an IBitmapFilter instance and allows you to animate
 * an arbitrary set of properties of the filter between values, as specified
 * by the motionPaths. 
 * 
 * Example usage is as follows:
 * @example AnimateFilter example:
 * <listing version="3.0">
 * &lt;?xml version="1.0" encoding="utf-8"?&gt;
 * &lt;Application xmlns="http://ns.adobe.com/mxml/2009" &gt;
 * 
 * &lt;Script&gt;
 * &lt;![CDATA[
 * 
 * import mx.effects.*;
 * import spark.filters.DropShadowFilter;
 * 
 * // Use AnimateFilter to animate the color, distance, and angle
 * // of a DropShadowFilter.
 * 
 * private function doDropShadowFilterSample():void{
 *     var df:DropShadowFilter = new DropShadowFilter();
 *     var anim:AnimateFilter = new AnimateFilter(btn1, df);
 *     
 *     anim.motionPaths = [
 *         new SimpleMotionPath("color", 0, 0x0000FF),
 *         new SimpleMotionPath("distance", 0, 10),		
 *         new SimpleMotionPath("angle", 270, 360)
 *     ];
 * 
 *     anim.repeatCount = 0;
 *     anim.duration = 500;
 *     anim.repeatBehavior = Animation.REVERSE;
 *     anim.play();
 * }
 * 
 * ]]&gt;
 * &lt;/Script&gt;
 * 
 * &lt;Button id="btn1" x="50" y="50" label="Animate a DropShadowFilter" click="doDropShadowFilterSample()" /&gt;
 * 
 * &lt;/Application&gt;
 * </listing>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class AnimateFilter extends Animate
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
    public function AnimateFilter(target:Object = null, filter:IBitmapFilter = null)
    {
        super(target);
        instanceClass = AnimateFilterInstance;
        this.bitmapFilter = filter;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  bitmapFilter
    //----------------------------------
    
    /**
     *  IBitmapFilter instance to apply and animate.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var bitmapFilter:IBitmapFilter;
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */ 
    override public function getAffectedProperties():Array /* of String */
    {
        return [];
    }
    
    
    /**
     *  @private
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        super.initInstance(instance);
        var animateInstance:AnimateFilterInstance = instance as AnimateFilterInstance;
        animateInstance.bitmapFilter = bitmapFilter;
    }
}
}