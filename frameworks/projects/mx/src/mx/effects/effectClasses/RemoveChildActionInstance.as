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

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  The RemoveChildActionInstance class implements the instance class
 *  for the RemoveChildAction effect.
 *  Flex creates an instance of this class when it plays a RemoveChildAction
 *  effect; you do not create one yourself.
 *
 *  @see mx.effects.RemoveChildAction
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */  
public class RemoveChildActionInstance extends ActionEffectInstance
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
	public function RemoveChildActionInstance(target:Object)
	{
		super(target);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private var _startIndex:Number;

	/**
	 *  @private
	 */
	private var _startParent:DisplayObjectContainer;
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override public function initEffect(event:Event):void
	{
		super.initEffect(event);
	}
	
	/**
	 *  @private
	 */
	override public function play():void
	{
		var targetDisplayObject:DisplayObject = DisplayObject(target);

		var doRemove:Boolean = true;
		
		// Dispatch an effectStart event from the target.
		super.play();	
		
		if (propertyChanges)
		{
			doRemove = (propertyChanges.start.parent != null &&
						propertyChanges.end.parent == null)
		}
		
		if (!playReversed)
		{
			// Set the style property
			if (doRemove && target && targetDisplayObject.parent != null)
				targetDisplayObject.parent.removeChild(targetDisplayObject);
		}
		else if (_startParent && !isNaN(_startIndex))
		{
			_startParent.addChildAt(targetDisplayObject, _startIndex);
		}
		
		// We're done...
		finishRepeat();
	}
	
	/** 
	 *  @private
	 */
	override protected function saveStartValue():*
	{
		var targetDisplayObject:DisplayObject = DisplayObject(target);

		if (target && targetDisplayObject.parent != null)
		{
			_startIndex =
				targetDisplayObject.parent.getChildIndex(targetDisplayObject);
			_startParent = targetDisplayObject.parent;
		}
	}
}

}
