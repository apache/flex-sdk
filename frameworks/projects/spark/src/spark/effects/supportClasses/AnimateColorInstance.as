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

package spark.effects.supportClasses
{
import mx.styles.StyleManager;

import spark.effects.animation.Keyframe;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.effects.interpolation.RGBInterpolator;

/**
 *  The AnimateColorInstance class is the instance class of 
 *  the AnimateColor effect, which animates a change in
 *  color by interpolating the from/to values per color channel.
 *  Flex creates an instance of this class when
 *  it plays a AnimateFilter effect; you do not create one yourself.
 *
 *  @see spark.effects.AnimateColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class AnimateColorInstance extends AnimateInstance
{
    /**
     *  @copy spark.effects.AnimateColor#colorFrom
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var colorFrom:uint;

    /**
     *  @copy spark.effects.AnimateColor#colorTo
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var colorTo:uint;

    /**
     *  @copy spark.effects.AnimateColor#colorPropertyName
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var colorPropertyName:String;

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
    public function AnimateColorInstance(target:Object)
    {
        super(target);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function play():void
    {
        // The user may have supplied some combination of xFrom, xTo, and xBy.
        // If either xFrom or xTo is not explicitly defined, calculate its
        // value based on the other two values.
        if (colorFrom == StyleManager.NOT_A_COLOR)
        {
            if (propertyChanges && propertyChanges.start[colorPropertyName] !== undefined)
                colorFrom = propertyChanges.start[colorPropertyName];
            else
                colorFrom = getCurrentValue(colorPropertyName);
        }
        if (colorTo == StyleManager.NOT_A_COLOR)
        {
            if (propertyChanges &&
                propertyChanges.end[colorPropertyName] !== undefined)
            {
                colorTo = propertyChanges.end[colorPropertyName];
            }
            else
            {
                colorTo = getCurrentValue(colorPropertyName);
            }
        }
        
        motionPaths = new <MotionPath>[new MotionPath(colorPropertyName)];
        motionPaths[0].keyframes = new <Keyframe>[new Keyframe(0, colorFrom), 
            new Keyframe(duration, colorTo)];
                 
        if (!interpolator)
            interpolator = RGBInterpolator.getInstance();
                
        super.play();        
    }
}
}