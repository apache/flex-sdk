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
 * This effect animates a change in color over time, interpolating
 * between given from/to color values on a per-channel basis.
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
     * The starting color
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var colorFrom:uint = StyleManager.NOT_A_COLOR;
    
    [Inspectable(category="General", format="Color")]
    /**
     * The ending color
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var colorTo:uint = StyleManager.NOT_A_COLOR;
    
    /**
     * The name of the color property on the target object affected
     * by this animation.
     * 
     * @default "color"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var colorPropertyName:String = "color";
    
    /**
     * Constructs an AnimateColor effect with an optional target object
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
        return AFFECTED_PROPERTIES;
    }

    /**
     *  @private
     */
    override public function get relevantStyles():Array /* of String */
    {
        return RELEVANT_STYLES;
    }   

    /**
     * @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        super.initInstance(instance);
        
        var tintInstance:AnimateColorInstance = AnimateColorInstance(instance);
        tintInstance.colorFrom = colorFrom;
        tintInstance.colorTo = colorTo;
        tintInstance.colorPropertyName = colorPropertyName;
    }
}
}