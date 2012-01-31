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
import spark.effects.supportClasses.AnimateColorInstance;

import mx.effects.IEffectInstance;
import mx.styles.StyleManager;

/**
 *  The AnimateColor effect animates a change in a color property over time, interpolating
 *  between given from/to color values on a per-channel basis. 
 *  use this effect, rather than the Animate or other effect, when animating color properties. 
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;s:AnimateColor&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:AnimateColor
 *    <b>Properties</b>
 *    id="ID"
 *    colorFrom="no default"
 *    colorPropertyName="color"
 *    colorTo="no default"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.effects.supportClasses.AnimateColorInstance
 *
 *  @includeExample examples/AnimateColorEffectExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class AnimateColor extends Animate
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static var AFFECTED_PROPERTIES:Array = ["color"];
    // Some objects have a 'color' style instead
    private static var RELEVANT_STYLES:Array = ["color"];

    [Inspectable(category="General", format="Color")]
    /**
     *  The starting color value. 
     *
     *  @default 0xFFFFFF
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var colorFrom:uint = StyleManager.NOT_A_COLOR;
    
    [Inspectable(category="General", format="Color")]
    /**
     * The ending color value.
     *
     *  @default 0xFFFFFF
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var colorTo:uint = StyleManager.NOT_A_COLOR;
    
    /**
     *  The name of the color property on the target object affected
     *  by this animation. 
     *  A color property is a property that takes 32-bit color value.
     * 
     *  @default "color"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var colorPropertyName:String = "color";
    
    /**
     *  Constructor. 
     *
     *  @param target The Object to animate with this effect.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function AnimateColor(target:Object=null)
    {
        super(target);
        instanceClass = AnimateColorInstance;
    }

    /**
     *  @private
     */
    override public function getAffectedProperties():Array /* of String */
    {
        return (colorPropertyName == "color") ? AFFECTED_PROPERTIES : [colorPropertyName];
    }

    /**
     *  @private
     */
    override public function get relevantStyles():Array /* of String */
    {
        return (colorPropertyName == "color") ? RELEVANT_STYLES : [colorPropertyName];
    }   

    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        super.initInstance(instance);
        
        var animateColorInstance:AnimateColorInstance = AnimateColorInstance(instance);
        animateColorInstance.colorFrom = colorFrom;
        animateColorInstance.colorTo = colorTo;
        animateColorInstance.colorPropertyName = colorPropertyName;
    }
}
}