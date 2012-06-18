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

package mx.automation
{

/**
 * Describes a property of a test object.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class AutomationPropertyDescriptor implements IAutomationPropertyDescriptor
{

    private var _name:String;
    private var _forDescription:Boolean;
    private var _forVerification:Boolean;
    private var _defaultValue:String;
    private var _asType:String;

    /**
     *  Constructor
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function AutomationPropertyDescriptor(name:String,
                                                 forDescription:Boolean,
                                                 forVerification:Boolean,
                                                 defaultValue:String = null)
    {
        super();
        _name = name;
        _forDescription = forDescription;
        _forVerification = forVerification;
        _defaultValue = defaultValue;
    }

	/**
	 * @private
	 */
    public function get name():String
    {
        return _name;
    }
    
	/**
	 * @private
	 */
    public function get forDescription():Boolean
    {
        return _forDescription;
    }

	/**
	 * @private
	 */
    public function get forVerification():Boolean
    {
        return _forVerification;
    }

	/**
	 * @private
	 */
    public function get defaultValue():String
    {
        return _defaultValue;
    }
    
	/**
	 * @private
	 */
    public function set asType(v:String):void
    {
    	_asType = v;
    }

	/**
	 * @private
	 */
    public function get asType():String
    {
    	return _asType ;
    }
}

}
