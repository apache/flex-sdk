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

import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.utils.describeType;
import mx.automation.Automation;
import mx.automation.AutomationClass;
import mx.automation.IAutomationManager;
import mx.automation.IAutomationMethodDescriptor;
import mx.automation.IAutomationObject;
import mx.core.mx_internal;
import mx.automation.tool.IToolCodecHelper;
import mx.automation.AutomationMethodDescriptor;

use namespace mx_internal;

/**
 * Basic method descriptor class. Generates descriptor from event parameters, if necessary
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class ToolMethodDescriptor extends AutomationMethodDescriptor
	   implements IToolMethodDescriptor
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
     * 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function ToolMethodDescriptor(name:String,
                                                      asMethodName:String,
                                                      returnType:String,
                                                      codecName:String,
                                                      args:Array)
    {
        super(name, asMethodName, returnType, args);
        _codecName = codecName;
    }

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  codecName
	//----------------------------------

    /**
     *  @private
     */
    private var _codecName:String;

    /**
     *  @private
     */
    public function get codecName():String
    {
        return _codecName;
    }

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

    /**
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function record(target:IAutomationObject, event:Event):Array
    {
        // Unsupported to record a method.
        throw new Error();
        return null;
    }

    /**
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function replay(target:IAutomationObject, args:Array):Object
    {
    	var delegate:IAutomationObject = target;
        var argDescriptors:Array = getArgDescriptors(delegate);
        var asArgs:Object = {};

		var helper:IToolCodecHelper = ToolAdapter.getCodecHelper();
        helper.decodeProperties(asArgs, args, argDescriptors, delegate);

		// Convert args into an ordered array.
		var asArgsOrdered:Array = [];
		for (var argNo:int = 0; argNo < argDescriptors.length; ++argNo)
			asArgsOrdered.push(asArgs[argDescriptors[argNo].name]);
			
		var retVal:Object = super.replay(target, asArgsOrdered);

        return helper.encodeValue(retVal, returnType, _codecName, delegate);
    }

}

}
