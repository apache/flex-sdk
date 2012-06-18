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

import flash.utils.Dictionary;

import mx.core.Application;
import mx.core.FlexGlobals;
import mx.core.mx_internal;

use namespace mx_internal;

/**
 * The Automation class defines the entry point for the Flex Automation framework.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */

public class Automation
{
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Component class to Delegate class map
     */
    mx_internal static var delegateDictionary:Dictionary;
	
	mx_internal static var priotityDictionary:Dictionary;
	
	mx_internal static var DEFAULT_REGISTRATION_PRIORITY:int = 0;

    //--------------------------------------------------------------------------
    //
    //  Class properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  automationManager
    //----------------------------------

    /**
     *  @private
     */
    private static var _automationManager:IAutomationManager;
	// For ApacheFlex there are no licenscing restrictions for FlashBuilder.
    private static const _restrictionNeeded:Boolean = false;  
    private static var _recordedLinesCount:Number = 0;
    private static var _errorShown:Boolean = false;  
    
    /**
     *  @private
     */
    public static var recordReplayLimit:Number = 30;  
    /**
     * The IAutomationManager instance.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function get automationManager():IAutomationManager
    {
        return _automationManager;
    }
      public static function get automationManager2():IAutomationManager2
    {
        return _automationManager as IAutomationManager2;
    }
    /**
     *  @private
     */
    public static function get recordedLinesCount():Number
    {
        return _recordedLinesCount;
    }
    
    /**
     *  @private
     */
    public static function set recordedLinesCount(count:Number):void
    {
         _recordedLinesCount=count;
    }

    /**
     *  @private
     */
    public static function set restrictionNeeded(restrictionStatus:Boolean):void
    {
		// For ApacheFlex there are no licenscing restrictions for FlashBuilder.
		//_restrictionNeeded = restrictionStatus;
    }
    
    /**
     *  @private
     */
    public static function incrementRecordedLinesCount():Number
    {
        return (++_recordedLinesCount); 
    }
    /**
     *  @private
     */
    public static function decrementRecordedLinesCount():Number
    {
        // this method is needed, because in some scenearios eventhough
        // the recordAutomatable method is called, it will not get recorded
        // so to  reduce the count, this method is used.
        if(_recordedLinesCount > 0)
        {
            _recordedLinesCount--;
        }
        return (_recordedLinesCount); 
    }
    /**
     *  @private
     */
    public static function isLicensePresent():Boolean
    {
        return !(_restrictionNeeded);
    }
    
    /**
     *  @private
     */
    public static function get errorShown():Boolean
    {
        return _errorShown;
    }
      
    /**
     *  @private
     */
    public static function set errorShown(errorShownNewVal:Boolean):void
    {
         _errorShown = errorShownNewVal;
    }
	
	//----------------------------------
	//  automationDebugTracer
	//----------------------------------
	
	/**
	 *  @private
	 */
	private static var _automationDebugTracer:IAutomationDebugTracer;
	
	/**
	 * The available IAutomationDebugTracer instance.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	public static function get automationDebugTracer():IAutomationDebugTracer
	{
		return _automationDebugTracer;
	}
      
    /**
     * @private
     */
    public static function set automationManager(manager:IAutomationManager):void
    {
        _automationManager = manager;
        _automationObjectHelper = manager as IAutomationObjectHelper;
		_automationDebugTracer = manager as IAutomationDebugTracer;
    }

    //----------------------------------
    //  automationObjectHelper
    //----------------------------------

    /**
     *  @private
     */
    private static var _automationObjectHelper:IAutomationObjectHelper;
    
    /**
     * The available IAutomationObjectHelper instance.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function get automationObjectHelper():IAutomationObjectHelper
    {
        return _automationObjectHelper;
    }

    //----------------------------------
    //  initialized
    //----------------------------------

    /**
     * Contains <code>true</code> if the automation module has been initialized.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function get initialized():Boolean
    {
        return _automationManager != null;
    }

    //----------------------------------
    //  mouseSimulator
    //----------------------------------

    /**
     *  @private
     */
    private static var _mouseSimulator:IAutomationMouseSimulator;
        
    /**
     * The currently active mouse simulator.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function get mouseSimulator():IAutomationMouseSimulator
    {
        return _mouseSimulator;
    }

    /**
     * @private
     */
    public static function set mouseSimulator(ms:IAutomationMouseSimulator):void
    {
        _mouseSimulator = ms;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Registers the component class and delegate class association with Automation.
     * 
     *  @param compClass The component class. 
     * 
     *  @param delegateClass The delegate class associated with the component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function registerDelegateClass(compClass:Class, delegateClass:Class, priority:int=0):void
    {          
        if (!delegateDictionary)
            delegateDictionary = new Dictionary(true);
				
		if(!priotityDictionary)
			priotityDictionary = new Dictionary(true);
		
		priotityDictionary[delegateClass] = priority;
		
		// check whether we have a delegate for this class alaredy
		var canBeReplaced:Boolean = true;
		var existingDelegateClass:Class =  delegateDictionary[compClass];
		if(existingDelegateClass)
		{
			// get the priority of the existing delegate class
			var existingPriority:int = priotityDictionary[existingDelegateClass];
			if(existingPriority > priority)
				canBeReplaced = false;
		}
		
		if(canBeReplaced)
        	delegateDictionary[compClass] = delegateClass;
    }
    
    public static function getMainApplication():Object
	{
		/*
		var obj:Object = FlexGlobals.topLevelApplication as mx.core.Application;
		if(obj)
			return obj;
		else
			obj:Object = FlexGlobals.topLevelApplication as mx.spark.Application;
		return obj;
		*/
		return FlexGlobals.topLevelApplication;
	}
}

}
