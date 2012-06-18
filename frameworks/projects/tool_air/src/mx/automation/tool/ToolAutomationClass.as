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

package mx.automation.tool
{
import mx.automation.AutomationClass;
import mx.automation.IAutomationPropertyDescriptor;
import mx.utils.ObjectUtil;

/**
 * Provides serializable class information for external automation tools.
 * Some classes are represented as the same AutomationClass (HSlider and VSlider, forinstance).
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 4
 */

public class ToolAutomationClass extends AutomationClass 
		implements IToolAutomationClass
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    public function ToolAutomationClass(name:String, superClassName:String = null)
    {
		super(name, superClassName);
    }

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

    /**
	 *  @private
	 *  QTP is case insensitive. QTP has been found to change property names
	 *  at certain instance to complete lower case names. Hence we use a map
	 *  built on lower case property name to find the descriptor.
	 */
	private var propertyCaseMap:Object = {};
    

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
 
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

    /**
	 *  Add a descriptor of a property to the class.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
    override public function addPropertyDescriptor(p:IAutomationPropertyDescriptor):void
    {
		super.addPropertyDescriptor(p);	            	
	    propertyCaseMap[p.name.toLowerCase()] = p;
    }

    /**
     * @private
     * Getter for the map of lower case property name and descriptor.
     */
    public function get propertyLowerCaseMap():Object
    {
    	return propertyCaseMap;
    }
}

}
