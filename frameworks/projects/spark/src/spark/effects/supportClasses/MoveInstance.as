////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
