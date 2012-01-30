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

import flash.events.Event;
import mx.core.mx_internal;
import mx.events.FlexEvent;

use namespace mx_internal;

/**
 *  The FadeInstance class implements the instance class
 *  for the Fade effect.
 *  Flex creates an instance of this class when it plays a Fade effect;
 *  you do not create one yourself.
 *
 *  <p>Every effect class that is a subclass of the TweenEffect class 
 *  supports the following events:</p>
 *  
 *  <ul>
 *    <li><code>tweenEnd</code>: Dispatched when the tween effect ends. </li>
 *  
 *    <li><code>tweenUpdate</code>: Dispatched every time a TweenEffect 
 *      class calculates a new value.</li> 
 *  </ul>
 *  
 *  <p>The event object passed to the event listener for these events is of type TweenEvent. 
 *  The TweenEvent class defines the property <code>value</code>, which contains 
 *  the tween value calculated by the effect. 
 *  For the Fade effect, 
 *  the <code>TweenEvent.value</code> property contains a Number between the values of the 
 *  <code>Fade.alphaFrom</code> and <code>Fade.alphaTo</code> properties.</p>
 *
 *  @see mx.effects.Fade
 *  @see mx.events.TweenEvent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */  
public class FadeInstance extends TweenEffectInstance
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
	public function FadeInstance(target:Object)
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
	 *  The original transparency level.
	 */
	private var origAlpha:Number = NaN;
	
	/** 
	 *  @private
	 */
	private var restoreAlpha:Boolean;

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  alphaFrom
	//----------------------------------

	/** 
	 *  Initial transparency level between 0.0 and 1.0, 
	 *  where 0.0 means transparent and 1.0 means fully opaque. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var alphaFrom:Number;
	
	//----------------------------------
	//  alphaFrom
	//----------------------------------

	/** 
	 *  Final transparency level between 0.0 and 1.0, 
	 *  where 0.0 means transparent and 1.0 means fully opaque.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var alphaTo:Number;
	
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
		
		switch (event.type)
		{	
			case "childrenCreationComplete":
			case FlexEvent.CREATION_COMPLETE:
			case FlexEvent.SHOW:
			case Event.ADDED:
			case "resizeEnd":
			{
				if (isNaN(alphaFrom))
					alphaFrom = 0;
				if (isNaN(alphaTo))
					alphaTo = target.alpha;
				break;
			}
		
			case FlexEvent.HIDE:
			case Event.REMOVED:
			case "resizeStart":
			{
				restoreAlpha = true;
				if (isNaN(alphaFrom))
					alphaFrom = target.alpha;
				if (isNaN(alphaTo))
					alphaTo = 0;
				break;
			}
		}
	}
	
	/**
	 *  @private
	 */
	override public function play():void
	{
		// Dispatch an effectStart event from the target.
		super.play();

		// Try to cache the target as a bitmap.
		//EffectManager.startBitmapEffect(target);

		// Remember the original value of the target object's alpha
		origAlpha = target.alpha;

		var values:PropertyChanges = propertyChanges;
		
		// If nobody assigned a value, make this a "show" effect.
		if (isNaN(alphaFrom) && isNaN(alphaTo))
		{	
			if (values && values.end["alpha"] !== undefined)
			{
				alphaFrom = origAlpha;
				alphaTo = values.end["alpha"];
			}
			else if (values && values.end["visible"] !== undefined)
			{
				alphaFrom = values.start["visible"] ? origAlpha : 0;
				alphaTo = values.end["visible"] ? origAlpha : 0;
			}
			else
			{
				alphaFrom = 0;
				alphaTo = origAlpha;
			}
		}
		else if (isNaN(alphaFrom))
		{
			alphaFrom = (alphaTo == 0) ? origAlpha : 0;
		}
		else if (isNaN(alphaTo))
		{
			if (values && values.end["alpha"] !== undefined)
			{
				alphaTo = values.end["alpha"];
			}
			else
			{
				alphaTo = (alphaFrom == 0) ? origAlpha : 0;	
			}
		}		
		
		tween = createTween(this, alphaFrom, alphaTo, duration);
		target.alpha = tween.getCurrentValue(0)
	}

	/**
	 *  @private
	 */
	override public function onTweenUpdate(value:Object):void
	{
		target.alpha = value;
	}

	/**
	 *  @private
	 */
	override public function onTweenEnd(value:Object):void
	{
		// Call super function first so we don't clobber resetting the alpha.
		super.onTweenEnd(value);	
			
		if (hideOnEffectEnd || restoreAlpha)
		{
			target.alpha = origAlpha;
		}
	}
}

}
