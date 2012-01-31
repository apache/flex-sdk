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

package spark.components.supportClasses
{
import spark.effects.animation.Animation;
import spark.effects.animation.IAnimationTarget;

internal class AnimationTarget implements IAnimationTarget
{
    public var updateFunction:Function;
    public var startFunction:Function;
    public var stopFunction:Function;
    public var endFunction:Function;
    public var repeatFunction:Function;
    
    public function AnimationTarget(updateFunction:Function = null)
    {
        this.updateFunction = updateFunction;
    }

    public function animationStart(animation:Animation):void
    {
        if (startFunction != null)
            startFunction(animation);
    }
    
    public function animationEnd(animation:Animation):void
    {
        if (endFunction != null)
            endFunction(animation);
    }
    
    public function animationStop(animation:Animation):void
    {
        if (stopFunction != null)
            stopFunction(animation);
    }
    
    public function animationRepeat(animation:Animation):void
    {
        if (repeatFunction != null)
            repeatFunction(animation);
    }
    
    public function animationUpdate(animation:Animation):void
    {
        if (updateFunction != null)
            updateFunction(animation);
    }
    
}
}