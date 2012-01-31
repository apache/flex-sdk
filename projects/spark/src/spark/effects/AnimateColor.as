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
package mx.effects
{
import mx.effects.effectClasses.FxAnimateColorInstance;

import mx.effects.IEffectInstance;
import mx.styles.StyleManager;

/**
 * This effect animates a change in color over time, interpolating
 * between given from/to color values on a per-channel basis.
 */
public class FxAnimateColor extends FxAnimate
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

    /**
     * The starting color
     */
    public var colorFrom:uint = StyleManager.NOT_A_COLOR;
    
    /**
     * The ending color
     */
    public var colorTo:uint = StyleManager.NOT_A_COLOR;
    
    /**
     * The name of the color property on the target object affected
     * by this animation.
     * 
     * @default "color"
     */
    public var colorPropertyName:String = "color";
    
    /**
     * Constructs a Tint effect with an optional target object
     */
    public function FxAnimateColor(target:Object=null)
    {
        super(target);
        instanceClass = FxAnimateColorInstance;
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
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        super.initInstance(instance);
        
        var tintInstance:FxAnimateColorInstance = FxAnimateColorInstance(instance);
        tintInstance.colorFrom = colorFrom;
        tintInstance.colorTo = colorTo;
        tintInstance.colorPropertyName = colorPropertyName;
    }
}
}