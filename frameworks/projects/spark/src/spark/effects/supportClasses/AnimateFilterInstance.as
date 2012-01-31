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
    
import mx.filters.IBitmapFilter;
import mx.effects.FxAnimateFilter;
import mx.filters.ShaderFilter;

/**
 * The AnimateFilterInstance class implements the instance class for the
 * AnimateFilter effect. Flex creates an instance of this class when
 * it plays a AnimateFilter effect; you do not create one yourself.
 */
public class FxAnimateFilterInstance extends FxAnimateInstance
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor. 
     */
    public function FxAnimateFilterInstance(target:Object)
    {
        super(target);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  bitmapFilter
    //----------------------------------
    
    /**
     * IBitmapFilter instance to apply and animate.
     */  
    public var bitmapFilter:IBitmapFilter;
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     */
    override public function play():void
    {
        // Apply our filter instance.
        var filters:Array = target.filters;
        filters.push(bitmapFilter);
        target.filters = filters;
        super.play();
    }
    
    
    /**
     *  @copy mx.effects.IEffectInstance#finishEffect()
     */
    override public function finishEffect():void
    {   
        // Locate and remove our filter instance
        var filters:Array = target.filters;
        for (var i:int = 0; i < filters.length; i++)
        {
            if (filters[i] == bitmapFilter)
            {
                filters.splice(i, 1);
                break;
            }
        }
        
        // Refresh filter stack.
        target.filters = filters;
        
        super.finishEffect();
    }       
        
    /**
     * Unlike Animate's setValue we assign the new value to the filter
     * associated with our effect instance rather than the target of 
     * the effect. 
     *  
     * @private
     */
    override protected function setValue(property:String, value:Object):void
    {
        if (roundValues && (value is Number))
            value = Math.round(Number(value));
            
        bitmapFilter[property] = value;
    }

    /**
     * Unlike Animate's getValue we return the value of the property requested
     * from the filter associated with our effect instance rather than 
     * the effect target.
     *  
     * @private
     */
    override protected function getCurrentValue(property:String):*
    {
        return bitmapFilter[property];
    }
    
    /**
     * Override FXAnimate's setupStyleMapEntry to avoid the need to 
     * validate our properties against the 'target' (since we actually
     * set properties on our associated filter instance).
     *  
     * @private
     */
    override protected function setupStyleMapEntry(property:String):void
    {
    }
}

}