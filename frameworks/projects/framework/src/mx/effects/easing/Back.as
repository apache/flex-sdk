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

package mx.effects.easing
{

/**
 *  The Back class defines three easing functions to implement 
 *  motion with Flex effect classes. 
 *
 *  For more information, see http://www.robertpenner.com/profmx.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */  
public class Back
{
	include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------
	
    /**
     *  The <code>easeIn()</code> method starts 
     *  the motion by backtracking, 
     *  then reversing direction and moving toward the target.
	 *
     *  @param t Specifies time.
	 *
     *  @param b Specifies the initial position of a component.
	 *
     *  @param c Specifies the total change in position of the component.
	 *
     *  @param d Specifies the duration of the effect, in milliseconds.
	 *
	 *  @param s Specifies the amount of overshoot, where the higher the value, 
	 *  the greater the overshoot.
     *
     *  @return Number corresponding to the position of the component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */  
	public static function easeIn(t:Number, b:Number, c:Number,
								  d:Number, s:Number = 0):Number
	{
		if (!s)
			s = 1.70158;
		
		return c * (t /= d) * t * ((s + 1) * t - s) + b;
	}

    /**
     *  The <code>easeOut()</code> method starts the motion by
     *  moving towards the target, overshooting it slightly, 
     *  and then reversing direction back toward the target.
	 *
     *  @param t Specifies time.
	 *
     *  @param b Specifies the initial position of a component.
	 *
     *  @param c Specifies the total change in position of the component.
	 *
     *  @param d Specifies the duration of the effect, in milliseconds.
	 *
	 *  @param s Specifies the amount of overshoot, where the higher the value, 
	 *  the greater the overshoot.
     *
     *  @return Number corresponding to the position of the component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */  
	public static function easeOut(t:Number, b:Number, c:Number,
								   d:Number, s:Number = 0):Number
	{
		if (!s)
			s = 1.70158;
		
		return c * ((t = t / d - 1) * t * ((s + 1) * t + s) + 1) + b;
	}

    /**
     *  The <code>easeInOut()</code> method combines the motion
	 *  of the <code>easeIn()</code> and <code>easeOut()</code> methods
	 *  to start the motion by backtracking, then reversing direction and 
	 *  moving toward target, overshooting target slightly, reversing direction again, and 
	 *  then moving back toward the target.
	 *
     *  @param t Specifies time.
	 *
     *  @param b Specifies the initial position of a component.
	 *
     *  @param c Specifies the total change in position of the component.
	 *
     *  @param d Specifies the duration of the effect, in milliseconds.
	 *
	 *  @param s Specifies the amount of overshoot, where the higher the value, 
	 *  the greater the overshoot.
     *
     *  @return Number corresponding to the position of the component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */  
	public static function easeInOut(t:Number, b:Number, c:Number,
									 d:Number, s:Number = 0):Number
	{
		if (!s)
			s = 1.70158; 
		
		if ((t /= d / 2) < 1)
			return c / 2 * (t * t * (((s *= (1.525)) + 1) * t - s)) + b;
		
		return c / 2 * ((t -= 2) * t * (((s *= (1.525)) + 1) * t + s) + 2) + b;
	}
}

}
