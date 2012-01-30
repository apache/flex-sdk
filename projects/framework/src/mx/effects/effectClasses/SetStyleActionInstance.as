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
import mx.styles.StyleManager;
import mx.core.IFlexModuleFactory;
import mx.core.IFlexModule;

use namespace mx_internal;

/**
 *  The SetStyleActionInstance class implements the instance class
 *  for the SetStyleAction effect.
 *  Flex creates an instance of this class when it plays a SetStyleAction
 *  effect; you do not create one yourself.
 *
 *  @see mx.effects.SetStyleAction
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */  
public class SetStyleActionInstance extends ActionEffectInstance
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
	public function SetStyleActionInstance(target:Object)
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
	 *  The name of the style property being changed.
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
	 *  @private
	 *  Storage for the value property.
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
		if (playReversed)
			return getStartValue();
		else
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
		
		// Set the style property
		if (target && name && value !== undefined)
		{
			var currentValue:Object = target.getStyle(name);
			
			if (currentValue is Number)
			{
				// The "value" for colors can be several different formats:
				// 0xNNNNNN, #NNNNNN or "red". We can't use
				// StyleManager.isColorStyle() because that only returns true
				// for inheriting color styles and misses non-inheriting styles like
				// backgroundColor.
				if (name.toLowerCase().indexOf("color") != -1)
                {
                    var moduleFactory:IFlexModuleFactory = null;
                    if (target is IFlexModule)
                        moduleFactory = target.moduleFactory;
                    target.setStyle(name, 
                        StyleManager.getStyleManager(moduleFactory).getColorName(value));                    
                }
				else
					target.setStyle(name, Number(value));
			}
			else if (currentValue is Boolean)
			{
				if (value is String)
					target.setStyle(name, (value.toLowerCase() == "true"));
				else
					target.setStyle(name, value);
			}
			else
			{
				target.setStyle(name, value);
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
		return target.getStyle(name);
	}
}

}
