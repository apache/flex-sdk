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
package spark.effects.easing
{
/**
 * Provides easing functionality using a polynomial expression, where the
 * instance is created with a <code>power</code> parameter describing the 
 * behavior of the expression.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Power extends EaseInOut
{
    /**
     * Storage for the exponent property
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private var _exponent:int;
    /**
     * The exponent that will be used in the easing calculation. For example,
     * to get quadratic behavior, set exponent equal to 2. To get cubic
     * behavior, set exponent equal to 3. A value of 1 represents linear
     * motion, while a value of 0 simply returns 1 from the ease
     * method.
     * 
     * @default 2
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get exponent():int
    {
        return _exponent;
    }
    public function set exponent(value:int):void
    {
        _exponent = value;
    }
    
    /**
     * Constructs a Power instance with optional easeInFraction and exponent
     * values
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function Power(easeInFraction:Number = .5, exponent:Number = 2)
    {
        super(easeInFraction);
        this.exponent = exponent;
    }

    /**
     * @inheritDoc
     * 
     * The easeIn calculation for Power is equal to 
     * <code>fraction^^exponent</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function easeIn(fraction:Number):Number
    {
        return Math.pow(fraction, _exponent);
    }
    
    /**
     * @inheritDoc
     * 
     * The easeOut calculation for Power is equal to 
     * <code>1 - ((1-fraction)^^exponent)</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function easeOut(fraction:Number):Number
    {
        return 1 - Math.pow((1 - fraction), _exponent);
    }
}
}