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

package spark.effects
{
import mx.effects.IEffectInstance;

import spark.effects.supportClasses.FadeInstance;

/**
 *  The Fade effect animates the <code>alpha</code> property of a component. 
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;mx:Fade&gt;</code> tag
 *  inherits the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;mx:Fade 
 *    id="ID"
 *    alphaFrom="val"
 *    alphaTo="val"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.effects.supportClasses.FadeInstance
 * 
 *  @includeExample examples/FadeEffectExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Fade extends Animate
{
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
    public function Fade(target:Object=null)
    {
        super(target);
        instanceClass = FadeInstance;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  alphaFrom
    //----------------------------------

    [Inspectable(category="General", defaultValue="undefined")]
    
    /** 
     *  Initial value of the <code>alpha</code> property, between 0.0 and 1.0, 
     *  where 0.0 means transparent and 1.0 means fully opaque. 
     * 
     *  <p>If the effect causes the target component to disappear,
     *  the default value is the current value of the target's
     *  <code>alpha</code> property.
     *  If the effect causes the target component to appear,
     *  the default value is 0.0.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var alphaFrom:Number;
    
    //----------------------------------
    //  alphaTo
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]
    
    /** 
     *  Final value of the <code>alpha</code> property, between 0.0 and 1.0,
     *  where 0.0 means transparent and 1.0 means fully opaque.
     *
     *  <p>If the effect causes the target component to disappear,
     *  the default value is 0.0.
     *  If the effect causes the target component to appear,
     *  the default value is the current value of the target's
     *  <code>alpha</code> property.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var alphaTo:Number;

    //----------------------------------
    //  affectVisibility
    //----------------------------------

    [Inspectable(category="General", defaultValue="true")]

    /** 
     *  Fade animates the <code>alpha</code> value of its target
     *  objects. But it may also be desirable for Fade to automatically
     *  affect the <code>visible</code> property as well, setting that
     *  property to <code>false</code> when fading out a visible object
     *  or setting it to <code>true</code> when fading in a non-visible 
     *  object. The setting of this flag determines whether that side-effect
     *  will persist after the Fade is complete.
     * 
     *  <p>For example, an object which is not visible when a fade-in
     *  operation is run on it will become visible when the effect runs and
     *  stay visible when the effect finishes.</p>
     * 
     *  <p>Note that if the <code>visible</code> property is specified 
     *  explicitly in state values, this behavior will not counter the
     *  instructions when going into that state. For example, an object
     *  which is not visible and which has a <code>visible</code> value 
     *  of <code>false</code> in some state "StateX" will remain non-visible
     *  after any Fade effect runs on it, even if that Fade effect 
     *  explicitly faded the object in.</p>
     * 
     *  @default true
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var affectVisibility:Boolean = true;
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private 
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        super.initInstance(instance);
        
        var fadeInstance:FadeInstance = FadeInstance(instance);

        fadeInstance.alphaFrom = alphaFrom;
        fadeInstance.alphaTo = alphaTo;
        fadeInstance.affectVisibility = affectVisibility;
    }

    /**
     *  @private
     */
    override public function getAffectedProperties():Array /* of String */
    {
        return ["alpha", "visible", "parent"];
    }

    /**
     *  @private
     */
    override protected function applyValueToTarget(target:Object,
                                                   property:String, 
                                                   value:*,
                                                   props:Object):void
    {
        // We only want to track "parent" as it affects how
        // we fade; we don't actually want to change target properties
        // other than alpha or visibility
        if (property == "parent")
            return;
            
        super.applyValueToTarget(target, property, value, props);
    }
}
}