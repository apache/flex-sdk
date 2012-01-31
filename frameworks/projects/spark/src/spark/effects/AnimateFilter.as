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
 *  The AnimateFilter effect applies an mx.filters.IBitmapFilter instance to the target 
 *  and allows you to animate properties of the filter between values. 
 *  Unlike effects that animate properties of the target, 
 *  the AnimateFilter effect animates properties of the filter applied to the target.
 *
 *  <p>The filters that you can use with this effect are defined in the spark.filters. package. 
 *  Common filters include the DropShadowFilter, GlowFilter, BlurFilter, and ShaderFilter.</p>
 *
 *  <p>To define the properties of the filter to animate, pass an Array of SimpleMotionPath objects 
 *  to the to the <code>motionPath</code> property of the AnimateFilter effect. 
 *  Each SimpleMotionPath object defines a property on the filer, 
 *  the starting value of the property, and the ending value of the property.</p>
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;s:AnimateFilter&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:AnimateFilter
 *    <b>Properties</b>
 *    id="ID"
 *    bitmapFilter="no default"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.effects.supportClasses.AnimateFilterInstance
 *
 *  @includeExample examples/AnimateFilterEffectExample.mxml
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
     *  @param target The Object to animate with this effect.  
     *
     *  @param filter The filter to apply to the target. 
     *  The filters that you can use with this effect are 
     *  defined in the spark.filters. package.
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
     *  <p>The filters that you can use with this effect are defined in the spark.filters. package. 
     *  Common filters include the DropShadowFilter, GlowFilter, BlurFilter, and ShaderFilter.</p>
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