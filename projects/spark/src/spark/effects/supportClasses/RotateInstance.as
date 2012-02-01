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
import spark.effects.animation.Animation;

//  Let (phi) be angle between r=(Ox,Oy - Cx,Cy) and -X Axis.
//   (theta) be clockwise further angle of rotation.
//  
//  Xtheta = Cx - rCos(theta + phi);
//  Ytheta = Cy - rSin(theta + phi);
//  
//  Xtheta = Cx - rCos(theta)Cos(phi) + rSin(theta)Sin(phi);
//  Ytheta = Cy - rSin(theta)Cos(phi) - rCos(theta)Sin(phi);
//  
//  Now Cos(phi) = w/2r; Sin(phi) = h/2r;
//  
//  Xtheta = Cx - rCos(theta)Cos(phi) + rSin(theta)Sin(phi);
//  Ytheta = Cy - rSin(theta)Cos(phi) - rCos(theta)Sin(phi);
//  
//  Xtheta = Cx - rCos(theta)w/2r + rSin(theta)h/2r;
//  Ytheta = Cy - rSin(theta)w/2r - rCos(theta)h/2r;
//  
//  Xtheta = Cx - wCos(theta)/2 + hSin(theta)/2;
//  Ytheta = Cy - wSin(theta)/2 - hCos(theta)/2;
//

/**
 * The RotateInstance class implements the instance class
 * for the Rotate effect.
 * Flex creates an instance of this class when it plays a Rotate effect;
 * you do not create one yourself.
 * 
 * @see spark.effects.Rotate
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */  
public class RotateInstance extends AnimateInstance
{
    include "../../core/Version.as";

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
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function RotateInstance(target:Object)
    {
        super(target);
    }
  
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     * The x coordinate of the absolute point of rotation.
     */
    private var centerX:Number;
    
    /**
     * @private
     * The y coordinate of absolute point of rotation.
     */
    private var centerY:Number;

    /**
     * @private
     */
    private var newX:Number;
    
    /**
     * @private
     */
    private var newY:Number;
    
    /**
     * @private
     */
    private var originalOffsetX:Number;
    
    /**
     * @private
     */
    private var originalOffsetY:Number;

    /**
     * @private
     */
    private var lastRotation:Number;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  angleFrom
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     *  @copy spark.effects.Rotate#angleFrom
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var angleFrom:Number;
    
    //----------------------------------
    //  angleTo
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     *  @copy spark.effects.Rotate#angleTo
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var angleTo:Number;
 
    //----------------------------------
    //  angleBy
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     *  @copy spark.effects.Rotate#angleBy
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var angleBy:Number;

    //----------------------------------
    //  originY
    //----------------------------------

    /**
     *  @copy spark.effects.Rotate#originX
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var originX:Number;
    
    //----------------------------------
    //  originY
    //----------------------------------
    
    /**
     *  @copy spark.effects.Rotate#originY
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var originY:Number;

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    override public function play():void
    {
        lastRotation = getCurrentValue("rotation");
        var radVal:Number = Math.PI * lastRotation / 180;        
        
        // Default to the center
        if (isNaN(originX))
            originX = getCurrentValue("width") / 2;
        
        if (isNaN(originY))
            originY = getCurrentValue("height") / 2;

        // Find the about point
        centerX = getCurrentValue("x") +
                  originX * Math.cos(radVal) -
                  originY * Math.sin(radVal);
        centerY = getCurrentValue("y") +
                  originX * Math.sin(radVal) +
                  originY * Math.cos(radVal);

        if (isNaN(angleFrom))
            if (!isNaN(angleTo) && !isNaN(angleBy))
                angleFrom = angleTo - angleBy;
            else if (propertyChanges && 
                propertyChanges.start["rotation"] !== undefined)
                angleFrom = propertyChanges.start["rotation"];
        
        if (isNaN(angleTo))
        {
            if (isNaN(angleBy) &&
                propertyChanges &&
                propertyChanges.end["rotation"] !== undefined)
            {
                angleTo = propertyChanges.end["rotation"];
            }
            else
            {
                if (!isNaN(angleBy) && !isNaN(angleFrom))
                    angleTo = angleFrom + angleBy; 
            }
        }
        
        originalOffsetX = originX * Math.cos(radVal) - originY * Math.sin(radVal);
        originalOffsetY = originX * Math.sin(radVal) + originY * Math.cos(radVal);

        newX = Number((centerX - originalOffsetX).toFixed(1)); // use a precision of 1
        newY = Number((centerY - originalOffsetY).toFixed(1)); // use a precision of 1
 
        motionPaths = new <MotionPath>[new MotionPath("rotation")];
        motionPaths[0].keyframes = new <Keyframe>[new Keyframe(0, angleFrom), 
            new Keyframe(duration, angleTo, angleBy)];

        super.play();
    }
  
    /**
     * @private
     * 
     * We override updateHandler because we must set x and y according
     * to the current target location and the specified rotationX/Y values.
     */
    override public function animationUpdate(animation:Animation):void
    {
        var targetX:Number = getCurrentValue("x");
        var targetY:Number = getCurrentValue("y");
        var targetRotation:Number = getCurrentValue("rotation");

        // If somebody else has changed the rotation
        if (Math.abs(targetRotation - lastRotation) > 0.1)
        {
            var radValCurr:Number = Math.PI * target.rotation / 180;        
            originalOffsetX = originX * Math.cos(radValCurr) - 
                originY * Math.sin(radValCurr);
            originalOffsetY = originX * Math.sin(radValCurr) + 
                originY * Math.cos(radValCurr);
        }
        
        // If somebody else has changed the position
        if (Math.abs(newX - targetX) > 0.1)
            centerX = targetX + originalOffsetX;

        if (Math.abs(newY - targetY) > 0.1)
            centerY = targetY + originalOffsetY;

        var rotateValue:Number = Number(animation.currentValue["rotation"]);     
        var radVal:Number = Math.PI * rotateValue / 180;

        newX = centerX - originX * Math.cos(radVal) + originY * Math.sin(radVal);
        newY = centerY - originX * Math.sin(radVal) - originY * Math.cos(radVal);
        
        newX = Number(newX.toFixed(1)); // use a precision of 1
        newY = Number(newY.toFixed(1)); // use a precision of 1
        
        setValue("x", newX);
        setValue("y", newY);
        
        // Now have the superclass handle the actual rotation as well as any
        // other event processing details
        super.animationUpdate(animation);
        
        // Cache the rotation we set for possible future adjustment of offsets
        lastRotation = getCurrentValue("rotation");
    }
}

}
