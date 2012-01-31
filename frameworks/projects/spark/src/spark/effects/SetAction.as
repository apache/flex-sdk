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

package mx.effects
{

import mx.effects.effectClasses.SetActionInstance;

import mx.effects.Effect;
import mx.effects.IEffectInstance;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="duration", kind="property")]

/**
 *  The SetAction class defines an action effect that sets 
 *  the value of a named property or style.
 *  You use a SetAction effect within a transition definition
 *  to control when the view state change defined by a
 *  property or style change occurs during the transition.
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;mx:SetAction&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 * 
 *  <pre>
 *  &lt;mx:SetAction
 *    <b>Properties</b>
 *    id="ID"
 *    property=""
 *    value=""
 *  /&gt;
 *  </pre>
 *  
 *  @see mx.effects.effectClasses.SetActionInstance
 */
public class SetAction extends Effect
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @param target The Object to animate with this effect.
     */
    public function SetAction(target:Object = null)
    {
        super(target);

        instanceClass = SetActionInstance;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  property
    //----------------------------------

    [Inspectable(category="General")]
    
    /** 
     *  The name of the property being changed.
     */
    public var property:String;
    
    //----------------------------------
    //  value
    //----------------------------------

    [Inspectable(category="General")]
    
    /** 
     *  The new value for the property.
     *  When run within a transition and value is not specified, Flex determines 
     *  the value based on that set by the new state.
     */
    public var value:*;
        
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  relevantStyles
    //----------------------------------

    /**
     *  @private
     */
    override public function get relevantStyles():Array /* of String */
    {
        return [ property ];
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function getAffectedProperties():Array /* of String */
    {
        return [ property ];
    }

    /**
     *  @private
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        super.initInstance(instance);
        
        var actionInstance:SetActionInstance =
            SetActionInstance(instance);

        actionInstance.property = property;
        actionInstance.value = value;
    }
}

}
