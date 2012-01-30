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

import flash.display.DisplayObject;
import flash.utils.getQualifiedClassName;

import mx.automation.IAutomationMouseSimulator;
import mx.automation.IAutomationObjectHelper;
import mx.core.IUIComponent;
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
    mx_internal static var delegateClassMap:Object;

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

    /**
     * @private
     */
    public static function set automationManager(manager:IAutomationManager):void
    {
        _automationManager = manager;
        _automationObjectHelper = manager as IAutomationObjectHelper;
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
    public static function registerDelegateClass(compClass:Class, delegateClass:Class):void
    {
        if (!delegateClassMap)
            delegateClassMap = {};

        var className:String = getQualifiedClassName(compClass);
        delegateClassMap[className] = delegateClass;
    }
}

}
