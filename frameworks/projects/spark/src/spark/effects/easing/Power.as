package flex.effects.easing
{
/**
 * Provides easing functionality using a polynomial expression, where the
 * instance is created with a <code>power</code> parameter describing the 
 * behavior of the expression.
 */
public class Power implements IEaser
{
    /**
     * Storage for the exponent property
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
     * Storage for the easeIn property
     */
    private var _easeIn:Number;
    /**
     * The percentage of an animation that should be spent accelerating
     * according to the power formula. This factor sets an implicit
     * "easeOut" parameter, equal to (1 - easeIn), so that any time not
     * spent easing in is spent easing out. For example, to have an easing
     * equation that spends half the time easing in and half easing out,
     * set easeIn equal to .5.
     * 
     * @default .5
     */
    public function get easeIn():Number
    {
        return _easeIn;
    }
    public function set easeIn(value:Number):void
    {
        _easeIn = value;
    }

    /**
     * Constructs a Power instance with optional easeIn and exponent
     * values
     */
    public function Power(easeIn:Number = .5, exponent:Number = 2)
    {
        this.easeIn = easeIn;
        this.exponent = exponent;
    }
        
    /**
     * @inheritDoc
     * 
     * Calculates the eased fraction value based on the <code>easeIn</code> and
     * <code>exponent</code> properties. If the fraction is in the easeIn
     * phase of the animation, this result is equal to
     * <code>x^^exponent</code>, where x is the percentage elapsed in the
     * easeIn phase. Otherwise, the motion is in the easing-out phase
     * (1 - easeIn), and the result is equal to <code>1 - (1-x)^^exponent</code>.
     * 
     * @param fraction The elapsed fraction of the animation
     * @return The eased fraction of the animation
     */
    public function ease(fraction:Number):Number
    {
        var easeOut:Number = 1 - easeIn;
        
        if (fraction <= easeIn)
            return Math.pow(fraction/easeIn, _exponent)*easeIn;
        else
            return 1 - Math.pow((1 - fraction)/easeOut, _exponent)*easeOut;
    }
    
}
}