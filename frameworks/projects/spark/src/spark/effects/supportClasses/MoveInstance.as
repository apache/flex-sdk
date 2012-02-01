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
import spark.effects.SimpleMotionPath;
import spark.effects.animation.Keyframe;
import spark.effects.animation.MotionPath;
    
/**
 *  The MoveInstance class implements the instance class
 *  for the Move effect.
 *  Flex creates an instance of this class when it plays a Move
 *  effect; you do not create one yourself.
 *
 *  @see spark.effects.Move
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */  
public class MoveInstance extends AnimateInstance
{
    include "../../core/Version.as";

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
    public function MoveInstance(target:Object)
    {
        super(target);
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
     *  @copy spark.effects.Move#yBy
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
     *  @copy spark.effects.Move#yFrom
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
     *  @copy spark.effects.Move#yTo
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
     *  @copy spark.effects.Move#xBy
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
     *  @copy spark.effects.Move#xFrom
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
     *  @copy spark.effects.Move#xTo
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
        motionPaths = new <MotionPath>[new MotionPath("x"),
            new MotionPath("y")];
        motionPaths[0].keyframes = new <Keyframe>[new Keyframe(0, xFrom), 
            new Keyframe(duration, xTo, xBy)];
        motionPaths[1].keyframes = new <Keyframe>[new Keyframe(0, yFrom), 
            new Keyframe(duration, yTo, yBy)];
        
        // Also animate any position-related constraints that change between
        // transition states
        if (propertyChanges && !disableConstraints)
        {
            setupConstraintAnimation("left");
            setupConstraintAnimation("right");
            setupConstraintAnimation("top");
            setupConstraintAnimation("bottom");
            setupConstraintAnimation("percentWidth");
            setupConstraintAnimation("percentHeight");
            setupConstraintAnimation("horizontalCenter");
            setupConstraintAnimation("verticalCenter");
            setupConstraintAnimation("baseline");
        }
        
        super.play();        
    }
}
}
