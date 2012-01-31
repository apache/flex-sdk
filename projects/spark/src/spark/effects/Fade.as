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
import flash.display.DisplayObject;
import flash.display.MovieClip;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.effects.IEffectInstance;

import spark.effects.supportClasses.FadeInstance;

/**
 *  The Fade effect animates the <code>alpha</code> property of a component.
 *  If played manually (outside of a transition) on an object whose
 *  <code>visible</code> property is set to false, and told to animate
 *  <code>alpha</code> from zero to a nonzero value, it will set <code>visible</code>
 *  to true as a side-effect of fading it in. When run as part of a
 *  transition, it will respect state-specified values, but may use
 *  the <code>visible</code> property as well as whether the object
 *  is parented in the before/after states to determine the 
 *  values to animate <code>alpha</code> from and to if <code>alphaFrom</code>
 *  and <code>alphaTo</code> are not specified for the effect.
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;s:Fade&gt;</code> tag
 *  inherits the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;s:Fade 
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
    }

    /**
     *  @private
     */
    override public function getAffectedProperties():Array /* of String */
    {
        return ["alpha", "visible", "parent", "index"];
    }

    override protected function getValueFromTarget(target:Object, property:String):*
    {
        // We track 'index' for use in the addDisappearingTarget() function in
        // AnimateInstance, in order to add the item in the correct order
        if (property == "index" && "parent" in target)
        {
            var container:* = target.parent;
            // if the target has no parent, return undefined for index to indicate that
            // it has no index value.
            if (container === undefined || container === null ||
                ("mask" in container && container.mask == target))
                return undefined;
            if (container is IVisualElementContainer)
                return IVisualElementContainer(container).
                    getElementIndex(target as IVisualElement);
            else if ("getChildIndex" in container)
                return container.getChildIndex(target);
        }
        
        return super.getValueFromTarget(target, property);
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
        if (property == "parent" || property == "index")
            return;
            
        super.applyValueToTarget(target, property, value, props);
    }
}
}