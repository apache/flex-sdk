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

import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.utils.describeType;
import mx.automation.Automation;
import mx.automation.AutomationClass;
import mx.automation.IAutomationManager;
import mx.automation.IAutomationMethodDescriptor;
import mx.automation.IAutomationObject;
import mx.core.mx_internal;

use namespace mx_internal;

/**
 * Basic method descriptor class. Generates descriptor from event parameters, if necessary
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class AutomationMethodDescriptor
	   implements IAutomationMethodDescriptor
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
    public function AutomationMethodDescriptor(name:String,
                                                      asMethodName:String,
                                                      returnType:String,
                                                      args:Array)
    {
        super();

        _name = name;
        _asMethodName = asMethodName;
        _returnType = returnType;
        _args = args;
    }

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var _asMethodName:String;
    
    /**
     *  @private
     */
	private var _args:Array;
    
    /**
     *  @private
     */
	private var _eventArgASTypesInitialized:Boolean = false;

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  name
	//----------------------------------

    /**
     *  @private
     */
    private var _name:String;

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get name():String
    {
        return _name;
    }

	//----------------------------------
	//  returnType
	//----------------------------------

    /**
     *  @private
     */
    private var _returnType:String;

    /**
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get returnType():String
    {
        return _returnType;
    }

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function record(target:IAutomationObject, event:Event):Array
    {
        // Unsupported to record a method.
        throw new Error();
        return null;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function replay(target:IAutomationObject, args:Array):Object
    {
        var retVal:Object;
        var f:Function 

    	var comp:Object = target ;
        if (comp.hasOwnProperty(_asMethodName))
        {
        	f = comp[_asMethodName];
        	retVal = f.apply(target, args);
        }
        else
        {
            var delegate:Object = target.automationDelegate;
            f = delegate[_asMethodName];
        	retVal = f.apply(target, args);
        }
        	
		return retVal;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
   public function getArgDescriptors(obj:IAutomationObject):Array
    {
        if (!_eventArgASTypesInitialized && obj != null)
        {
            // This could be optimized by getting this info when
            // the properties for the object are initialized since
            // it's the same DT object.
            _eventArgASTypesInitialized = true;
            var comp:Object = obj ;
            // if the property not found in the object, get the delegate
            if (!(comp.hasOwnProperty(_asMethodName)))
            {
               comp = obj.automationDelegate;    
            }
        	
            var dt:XML = describeType(comp);
            AutomationClass.fillInASTypesFromMethods(dt, _asMethodName, _args);
        }

        return _args;
    }
}

}
