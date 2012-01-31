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

import mx.controls.SWFLoader;

/**
 *  The WipeRightInstance class implements the instance class
 *  for the WipeRight effect.
 *  Flex creates an instance of this class when it plays a WipeRight effect;
 *  you do not create one 
 *  yourself.
 *
 *  @see mx.effects.WipeRight
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */  
public class WipeRightInstance extends MaskEffectInstance
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
	public function WipeRightInstance(target:Object)
	{
		super(target);
	}

 	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override protected function initMaskEffect():void
	{
		super.initMaskEffect();
			
		var targetWidth:Number = target is SWFLoader && target.content ?
								 SWFLoader(target).contentWidth :
								 targetVisualBounds.width / Math.abs(target.scaleX);

		if (target.rotation != 0)
		{
			// The target.width and target.height are expressed in terms of
			// rotated coordinates, but we need to get the object's height 
			// in terms of unrotated coordinates.

			var angle:Number = target.rotation * Math.PI / 180;
			targetWidth = Math.abs(targetVisualBounds.width * Math.cos(angle) -	
								   targetVisualBounds.height * Math.sin(angle));
		}
		
		if (showTarget)
		{
			xFrom = -effectMask.width + targetVisualBounds.x;
			yFrom = targetVisualBounds.y;
			// Line up the right edges of the mask and target
			xTo = effectMask.width <= targetWidth ?
				  targetWidth - effectMask.width + targetVisualBounds.x:
				  targetVisualBounds.x;
			yTo = targetVisualBounds.y;
		}
		else
		{
			// Line up the right edges of the mask and target if mask is wider than target
			xFrom = effectMask.width <= targetWidth ?
					targetVisualBounds.x :
					targetWidth - effectMask.width + targetVisualBounds.x;
			yFrom = targetVisualBounds.y;
			xTo = targetWidth + targetVisualBounds.x;
			yTo = targetVisualBounds.y;
		}
	}
}

}
