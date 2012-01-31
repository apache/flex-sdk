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

import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  The SetPropertyActionInstance class implements the instance class
 *  for the SetPropertyAction effect.
 *  Flex creates an instance of this class when it plays a SetPropertyAction
 *  effect; you do not create one yourself.
 *
 *  @see mx.effects.SetPropertyAction
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */  
public class SetPropertyActionInstance extends ActionEffectInstance
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
	 *  @param target The Object to animate with this effect.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function SetPropertyActionInstance(target:Object)
	{
		super(target);
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  name
	//----------------------------------

	/** 
	 *  The name of the property being changed. 
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

	/** 
	 *  Storage for the value property.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	private var _value:*;
	
	/** 
	 *  The new value for the property.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get value():*
	{
		var val:*;
	
		if (playReversed)
		{
			 val = getStartValue();
			 if (val != undefined)
			 	return val;
		}
		
		return _value;
	}
	
	/** 
	 *  @private
	 */
	public function set value(val:*):void
	{
		_value = val;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @private
	 */
	override public function play():void
	{
		// Dispatch an effectStart event from the target.
		super.play();	
		
		if (value === undefined && propertyChanges)
		{
			if (name in propertyChanges.end &&
				propertyChanges.start[name] != propertyChanges.end[name])
				value = propertyChanges.end[name];
		}
		
		// Set the property
		if (target && name && value !== undefined)
		{
			if (target[name] is Number)
			{
				var propName:String = name;
				var val:Object = value;
				
				// Special case for width and height. If they are percentage values, 
				// set the percentWidth/percentHeight instead.
				if (name == "width" || name == "height")
				{
					if (val is String && val.indexOf("%") >= 0)
					{
						propName = name == "width" ? "percentWidth" : "percentHeight";
						val = val.slice(0, val.indexOf("%"));
					}
				}
				
				target[propName] = Number(val);
			}
			else if (target[name] is Boolean)
			{
				if (value is String)
					target[name] = (value.toLowerCase() == "true");
				else
					target[name] = value;
			}
			else
			{
				target[name] = value;
			}
		}
		
		// We're done...
		finishRepeat();
	}
	
	/** 
	 *  @private
	 */
	override protected function saveStartValue():*
	{
		if (name != null)
		{
			try
			{
				return target[name];
			}
			catch(e:Error)
			{
				// Do nothing. Let us return undefined.
			}
		}
		
		return undefined;
			
	}
}

}
