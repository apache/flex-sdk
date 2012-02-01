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
import flash.events.Event;

import spark.components.Application;
import mx.core.Container;
import mx.core.IUIComponent;
import spark.effects.AnimationProperty;
import spark.effects.animation.Animation;
import spark.events.AnimationEvent;
import mx.events.EffectEvent;
import mx.events.TweenEvent;
import spark.core.IGraphicElement;
import mx.styles.IStyleClient;
    
public class MoveInstance extends AnimateInstance
{
    include "../../core/Version.as";

    public function MoveInstance(target:Object)
    {
        super(target);
        affectsConstraints = true;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------


    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  yBy
    //----------------------------------

    /** 
     *  Number of pixels by which to modify the y of the component.
     *  Values may be negative.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var yBy:Number;
    
    //----------------------------------
    //  yFrom
    //----------------------------------

    /** 
     *  Initial y. If omitted, Flex uses the current size.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var yFrom:Number;

    //----------------------------------
    //  yTo
    //----------------------------------
    
    
    /** 
     *  Final y, in pixels.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var yTo:Number;
    
    //----------------------------------
    //  xBy
    //----------------------------------
    
    /** 
     *  Number of pixels by which to modify the width of the component.
     *  Values may be negative.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public var xBy:Number;

    //----------------------------------
    //  xFrom
    //----------------------------------

    /** 
     *  Initial x. If omitted, Flex uses the current size.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var xFrom:Number;

    //----------------------------------
    //  xTo
    //----------------------------------

    /** 
     *  Final x, in pixels.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var xTo:Number;
    

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
        animationProperties = 
            [new AnimationProperty("x", xFrom, xTo, duration, xBy),
             new AnimationProperty("y", yFrom, yTo, duration, yBy)];
        
        // TODO (chaase): The Flex3 version of Move had logic for forcing clipping
        // off during the effect. We probably need something like this
        // in this version as well, but the implementation is TBD with the
        // new container (Group) and layout management in Flex4
        
        super.play();        
    }
}
}
