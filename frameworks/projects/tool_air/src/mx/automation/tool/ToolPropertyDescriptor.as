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

import mx.automation.AutomationPropertyDescriptor;

/**
 * Describes a property of a test object.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 4
 */
public class ToolPropertyDescriptor extends AutomationPropertyDescriptor implements IToolPropertyDescriptor
{
	/**
	 * @private
	 */
    private var _type:String;

	/**
	 * @private
	 */
    private var _codecName:String;

    /**
     *  Constructor
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    public function ToolPropertyDescriptor(name:String,
                                                 forDescription:Boolean,
                                                 forVerification:Boolean,
                                                 type:String,
                                                 codecName:String,
                                                 defaultValue:String = null)
    {
        super(name, forDescription, forVerification, defaultValue);
        _type = type;
        _codecName = codecName;
    }

	/**
	 * @private
	 */
    public function get Tooltype():String
    {
        return _type;
    }

	/**
	 * @private
	 */
    public function get codecName():String
    {
        return _codecName;
    }

	/**
	 * @private
	 */
/*    public function set MyAsType(v:String):void
    {
    	_asType = v;
    }
*/
	/**
	 * @private
	 */
/*    public function get MyAsType():String
    {
    	return _asType ;
    }
*/

}

}
