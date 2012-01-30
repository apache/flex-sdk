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

package mx.effects.effectClasses
{

import mx.effects.EffectTargetFilter;

/**
 *  HideShowEffectTargetFilter is a subclass of EffectTargetFilter
 *  that handles the logic for filtering targets that have been shown or hidden
 *  by modifying their <code>visible</code> property.
 *  If you set the Effect.filter property to <code>hide</code>
 *  or <code>show</code>, one of these is used.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class HideShowEffectTargetFilter extends EffectTargetFilter
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
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function HideShowEffectTargetFilter()
	{
		super();

		filterProperties = [ "visible" ];
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  show
	//----------------------------------

	/**
	 *  Determines if this is a show or hide filter.
	 * 
	 *  @default true
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var show:Boolean = true;
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override protected function defaultFilterFunction(
									propChanges:Array,
									instanceTarget:Object):Boolean
	{
		var n:int = propChanges.length;
		for (var i:int = 0; i < n; i++)
		{
			var props:PropertyChanges = propChanges[i];
			
			if (props.target == instanceTarget)
				return props.end["visible"] == show;
		}
		
		return false;
	}
}

}
