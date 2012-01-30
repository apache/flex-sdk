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
 *  The IrisInstance class implements the instance class for the Iris effect.
 *  Flex creates an instance of this class when it plays an Iris effect;
 *  you do not create one yourself.
 *
 *  @see mx.effects.Iris
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */  
public class IrisInstance extends MaskEffectInstance
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
	public function IrisInstance(target:Object)
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

		var targetWidth:Number = target is SWFLoader && target.content ? 
								 SWFLoader(target).contentWidth : 
								 targetVisualBounds.width / Math.abs(target.scaleX); 
		
		if (showTarget)
		{
			scaleXFrom = 0;
			scaleYFrom = 0;
			scaleXTo = 1;
			scaleYTo = 1;
			
			xFrom = targetWidth / 2 + targetVisualBounds.x;
			yFrom = targetHeight / 2 + targetVisualBounds.y;
			xTo = targetVisualBounds.x;
			yTo = targetVisualBounds.y;
		}
		else
		{
			scaleXFrom = 1;
			scaleYFrom = 1;
			scaleXTo = 0;
			scaleYTo = 0;
			
			xFrom = targetVisualBounds.x;
			yFrom = targetVisualBounds.y;
			xTo = targetWidth / 2 + targetVisualBounds.x;
			yTo = targetHeight / 2 + targetVisualBounds.y;
		}
	}
}

}
