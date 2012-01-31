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
package flex.effects.easing
{
/**
 * The superclass for classes that provide easing capability where there
 * is an easing-in portion of the animation followed by an easing-out portion.
 * The default behavior of this class will simply return a linear
 * interpolation for both easing phases; developers should create a subclass
 * of EaseInOut to get more interestion behavior.
 */
public class EaseInOut implements IEaser
{
    /**
     * A utility constant which, when supplied as the 
     * <code>easeInFraction</code>, will create an easing instance
     * that spends the entire animation easing in. This is equivalent
     * to simply using the <code>easeInFraction = 1</code>.
     */
    public static const IN:Number = 1;

    /**
     * A utility constant which, when supplied as the 
     * <code>easeInFraction</code>, will create an easing instance
     * that spends the entire animation easing out. This is equivalent
     * to simply using the <code>easeInFraction = 0</code>.
     */
    public static const OUT:Number = 0;

    /**
     * A utility constant which, when supplied as the 
     * <code>easeInFraction</code>, will create an easing instance
     * that eases in for the first half and eases out for the
     * remainder. This is equivalent
     * to simply using the <code>easeInFraction = .5</code>.
     */
    public static const IN_OUT:Number = .5;

    /**
     * Constructs an EaseInOut instance with an optional easeInFraction
     * parameter.
     * 
     * @param easeInFraction Optional parameter that sets the value of
     * the <code>easeInFraction</code> property.
     */
    public function EaseInOut(easeInFraction:Number = EaseInOut.IN_OUT)
    {
        this.easeInFraction = easeInFraction;
    }

    /**
     * Storage for the _easeInFraction property
     */
    private var _easeInFraction:Number;
    
    /**
     * The percentage of an animation that should be spent accelerating
     * according to the power formula. This factor sets an implicit
     * "easeOut" parameter, equal to (1 - easeIn), so that any time not
     * spent easing in is spent easing out. For example, to have an easing
     * equation that spends half the time easing in and half easing out,
     * set easeIn equal to .5.
     * 
     * @see IN
     * @see OUT
     * @see IN_OUT
     * 
     * @default .5
     */
    public function get easeInFraction():Number
    {
        return _easeInFraction;
    }
    public function set easeInFraction(value:Number):void
    {
        _easeInFraction = value;
    }

    /**
     * @inheritDoc
     * 
     * Calculates the eased fraction value based on the 
     * <code>easeInFraction</code> property. If the given
     * <code>fraction</code> is less than <code>easeInFraction</code>,
     * this will call the <code>easeIn()</code> function, otherwise it
     * will call the <code>easeOut()</code> function. It is expected
     * that these functions are overridden in a subclass.
     * 
     * @param fraction The elapsed fraction of the animation
     * @return The eased fraction of the animation
     */
    public function ease(fraction:Number):Number
    {
        var easeOutFraction:Number = 1 - easeInFraction;
        
        if (fraction <= easeInFraction && easeInFraction > 0)
            return easeInFraction * easeIn(fraction/easeInFraction);
        else
            return easeInFraction + easeOutFraction * 
                easeOut((fraction - easeInFraction)/easeOutFraction);
    }
    
    /**
     * Returns a value that represents the eased fraction during the 
     * ease-in part of the curve. The value returned by this class 
     * is simply the fraction itself, which represents a linear 
     * interpolation of the fraction. More interesting behavior is
     * implemented by subclasses of <code>EaseInOut</code>.
     * 
     * @param fraction The fraction elapsed of the easing-in portion
     * of the animation.
     * @return A value that represents the eased value for this
     * part of the animation.
     */
    protected function easeIn(fraction:Number):Number
    {
        return fraction;
    }
    
    /**
     * Returns a value that represents the eased fraction during the 
     * ease-out part of the curve. The value returned by this class 
     * is simply the fraction itself, which represents a linear 
     * interpolation of the fraction. More interesting behavior is
     * implemented by subclasses of <code>EaseInOut</code>.
     * 
     * @param fraction The fraction elapsed of the easing-out portion
     * of the animation.
     * @return A value that represents the eased value for this
     * part of the animation.
     */
    protected function easeOut(fraction:Number):Number
    {
        return fraction;
    }
    
}
}