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

package mx.effects
{

import mx.effects.effectClasses.SetStyleActionInstance;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="duration", kind="property")]

/**
 *  The SetStyleAction class defines an action effect that corresponds
 *  to the SetStyle property of a view state definition.
 *  You use an SetStyleAction effect within a transition definition
 *  to control when the view state change defined by a 
 *  <code>SetStyle</code> property occurs during the transition.
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;mx:SetStyleAction&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;mx:SetStyleAction
 *    <b>Properties</b>
 *    id="ID"
 *    style=""
 *    value=""
 *  /&gt;
 *  </pre>
 *  
 *  @see mx.effects.effectClasses.SetStyleActionInstance
 *  @see mx.states.SetStyle
 *
 *  @includeExample ../states/examples/TransitionExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
 public class SetStyleAction extends Effect
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
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function SetStyleAction(target:Object = null)
	{
		super(target);
        duration = 0;
		instanceClass = SetStyleActionInstance;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  relevantStyles
	//----------------------------------

	/**
	 *  Contains the style properties modified by this effect. 
	 *  This getter method overrides the superclass method.
	 *
	 *  <p>If you create a subclass of this class to create a custom effect, 
	 *  you must override this method 
	 *  and return an Array that contains a list of the style properties 
	 *  modified by your subclass.</p>
	 *
	 *  @return An Array of Strings specifying the names of the 
	 *  style properties modified by this effect.
	 *
	 *  @see mx.effects.Effect#getAffectedProperties()
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	override public function get relevantStyles():Array /* of String */
	{
		return [ name ];
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  name
	//----------------------------------

	[Inspectable(category="General")]
	
	/** 
	 *  The name of the style property being changed.
	 *  By default, Flex determines this value from the <code>SetStyle</code>
	 *  property definition in the view state definition.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var name:String;
	
	//----------------------------------
	//  value
	//----------------------------------

	[Inspectable(category="General")]
	
	/** 
	 *  The new value for the style property.
	 *  By default, Flex determines this value from the <code>SetStyle</code>
	 *  property definition in the view state definition.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var value:*;
		
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override protected function initInstance(instance:IEffectInstance):void
	{
		super.initInstance(instance);
		
		var actionInstance:SetStyleActionInstance =
			SetStyleActionInstance(instance);
		actionInstance.name = name;
		actionInstance.value = value;
	}
}

}
