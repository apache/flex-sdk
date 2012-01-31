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
 *  The WipeDownInstance class implements the instance class
 *  for the WipeDown effect.
 *  Flex creates an instance of this class when it plays a WipeDown effect;
 *  you do not create one yourself.
 *
 *  @see mx.effects.WipeDown
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */  
public class WipeDownInstance extends MaskEffectInstance
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
	public function WipeDownInstance(target:Object)
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
			
		var targetHeight:Number = target is SWFLoader && target.content ?
								  SWFLoader(target).contentHeight :
								  targetVisualBounds.height / Math.abs(target.scaleY)

		if (target.rotation != 0)
		{
			// The target.width and target.height are expressed in terms of
			// rotated coordinates, but we need to get the object's height 
			// in terms of unrotated coordinates.

			var angle:Number = target.rotation * Math.PI / 180;
			targetHeight = Math.abs(targetVisualBounds.width * Math.sin(angle) +
						   		    targetVisualBounds.height * Math.cos(angle));
		}
		
		if (showTarget)
		{
			xFrom = targetVisualBounds.x;
			yFrom = -effectMask.height + targetVisualBounds.y;
			xTo = targetVisualBounds.x;
			// Line up bottoms of the mask and target
			yTo = effectMask.height <= targetHeight ? targetHeight - effectMask.height + targetVisualBounds.y : targetVisualBounds.y;
		}
		else
		{
			xFrom = targetVisualBounds.x;
			// Line up bottoms of the mask and target
			yFrom = effectMask.height <= targetHeight ? targetVisualBounds.y : targetHeight - effectMask.height + targetVisualBounds.y;
			xTo = targetVisualBounds.x;
			yTo = targetHeight + targetVisualBounds.y;
		}
	}
}

}
