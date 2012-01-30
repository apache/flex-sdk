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

import mx.effects.effectClasses.IrisInstance;

/**
 *  The Iris effect animates the effect target by expanding or contracting
 *  a rectangular mask centered on the target.
 *  The effect can either enlarge the mask from the center of the target
 *  to expose the target, or contract the mask toward the center
 *  to obscure the target.
 *
 *  @mxml
 *
 *  <p>The <code>&lt;mx:Iris&gt;</code> tag
 *  inherits all of the tag attributes of its superclass, 
 *  and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;mx:Iris
 *    id="ID"
 *  /&gt;
 *  </pre>
 *  
 *  @see mx.effects.effectClasses.IrisInstance
 * 
 *  @includeExample examples/IrisEffectExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class Iris extends MaskEffect
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
	public function Iris(target:Object = null)
	{
		super(target);

		instanceClass = IrisInstance;
	}
}

}
