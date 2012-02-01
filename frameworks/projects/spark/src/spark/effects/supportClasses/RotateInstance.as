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

package mx.effects.effectClasses
{

import mx.effects.PropertyValuesHolder;
import mx.events.AnimationEvent;

import mx.core.mx_internal;
import mx.effects.EffectManager;
import mx.styles.IStyleClient;

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
 * @see mx.effects.Rotate
 */  
public class FxRotateInstance extends FxAnimateInstance
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor.
     *
     * @param target The Object to animate with this effect.
     */
    public function FxRotateInstance(target:Object)
    {
        super(target);
        affectsConstraints = true;
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
     * The starting angle of rotation of the target object,
     * expressed in degrees.
     * Valid values range from 0 to 360.
     */
    public var angleFrom:Number;
    
    //----------------------------------
    //  angleTo
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     * The ending angle of rotation of the target object,
     * expressed in degrees.
     * Values can be either positive or negative.
     *
     * <p>If the value of <code>angleTo</code> is less
     * than the value of <code>angleFrom</code>,
     * then the target rotates in a counterclockwise direction.
     * Otherwise, it rotates in clockwise direction.
     * If you want the target to rotate multiple times,
     * set this value to a large positive or small negative number.</p>
     */
    public var angleTo:Number;
 
    //----------------------------------
    //  angleBy
    //----------------------------------

    [Inspectable(category="General")]

    /** 
     * Degrees by which to rotate the target object. Value
     * may be negative.
     */
    public var angleBy:Number;

    //----------------------------------
    //  originY
    //----------------------------------

    /**
     * The x-position of the center point of rotation.
     * The target rotates around this point.
     * The valid values are between 0 and the width of the target.
     */
    public var originX:Number;
    
    //----------------------------------
    //  originY
    //----------------------------------
    
    /**
     * The y-position of the center point of rotation.
     * The target rotates around this point.
     * The valid values are between 0 and the height of the target.
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
        var radVal:Number = Math.PI * target.rotation / 180;        
        
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
            else
                angleFrom = getCurrentValue("rotation");
        
        if (isNaN(angleTo))
        {
            angleTo = (target.rotation == 0) ?
                      ((angleFrom > 180) ? 360 : 0) :
                      getCurrentValue("rotation");
            if (isNaN(angleBy) &&
                propertyChanges &&
                propertyChanges.end["rotation"] !== undefined)
            {
                angleTo = propertyChanges.end["rotation"];
            }
            else
            {
                angleTo = (!isNaN(angleBy)) ? angleFrom + angleBy : 
                    getCurrentValue("rotation");
            }
        }
        
        propertyValuesList = 
            [new PropertyValuesHolder("rotation", [angleFrom, angleTo])];

        super.play();
    }
  
    /**
     * @private
     * 
     * We override updateHandler because we must set x and y according
     * to the current target location and the specified rotationX/Y values.
     */
    override protected function updateHandler(event:AnimationEvent):void
    {
        var targetX:Number = getCurrentValue("x");
        var targetY:Number = getCurrentValue("y");

        // If somebody else has changed our position
        if (Math.abs(newX - targetX) > 0.1)
            centerX = targetX + originalOffsetX;
        
        if (Math.abs(newY - targetY) > 0.1)
            centerY = targetY + originalOffsetY;
        
        var rotateValue:Number = Number(event.value);     
        var radVal:Number = Math.PI * rotateValue / 180;
                
        newX = centerX - originX * Math.cos(radVal) + originY * Math.sin(radVal);
        newY = centerY - originX * Math.sin(radVal) - originY * Math.cos(radVal);
        
        newX = Number(newX.toFixed(1)); // use a precision of 1
        newY = Number(newY.toFixed(1)); // use a precision of 1
        
        setValue("x", newX);
        setValue("y", newY);
        
        // Now have the superclass handle the actual rotation as well as any
        // other event processing details
        super.updateHandler(event);
    }
}

}
