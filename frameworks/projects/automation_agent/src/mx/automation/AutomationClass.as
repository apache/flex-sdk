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
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.system.ApplicationDomain;
import flash.utils.describeType;
import flash.utils.getQualifiedClassName;

import mx.core.mx_internal;
import mx.managers.ISystemManager;
import mx.managers.SystemManagerProxy;
import mx.utils.ObjectUtil;

use namespace mx_internal;

/**
 * Provides serializable class information for external automation tools.
 * Some classes are represented as the same AutomationClass (HSlider and VSlider, forinstance).
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */

public class AutomationClass implements IAutomationClass2
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    public function AutomationClass(name:String, superClassName:String = null)
    {
		super();

        _name = name;
        _superClassName = superClassName;
    }

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

    /**
	 *  @private
	 */
    private var _implementationClassNames:Array = [];
    
    /**
	 *  @private
	 */
	private var _properties:Array = [];
	
    /**
	 *  @private
	 */
	private var _verificationProperties:Array = [];
	
    /**
	 *  @private
	 */
	private var _descriptionProperties:Array = [];
	
    /**
	 *  @private
	 */
	private var _event2descriptor:Object = {};
    
    /**
	 *  @private
	 */
	private var _method2descriptor:Object = {};
    
    /**
	 *  @private
	 */
	private var _propertyASTypesInitialized:Boolean = false;
	
	
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
	 * the class name
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
	//  superClassName
	//----------------------------------

    /**
	 *  @private
	 */
    private var _superClassName:String;

    /**
	 * The name of the class's superclass.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
    public function get superClassName():String
    {
        return _superClassName;
    }
    
    //----------------------------------
	// previousVersionClassNames
	//----------------------------------
    
    /**
	 *  @private
	 */
	private var _previousVersionClassNames:Array = [];
	
	/**
     * An array of names of the classes that are compatible with current class.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    public function get previousVersionClassNames():Array
    {
    	return _previousVersionClassNames;
    }
    
    /**
     *  @private
     */
    public function set previousVersionClassNames(value:Array):void
    {
    	_previousVersionClassNames = value;
    } 
    
    /**
	 *  @private
	 */
	private var _implementationVersion:int = 0;
	
	/**
     * @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    public function get implementationVersion():int
    {
    	return _implementationVersion;
    }
    
    /**
     *  @private
     */
    public function set implementationVersion(value:int):void
    {
    	_implementationVersion = value;
    } 
    
    /**
	 *  @private
	 *  A map of property name to property descriptor.
	 *  Useful in getting the descriptor based on property names.
	 */
	private var _propertyNameMap:Object = {};
 
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

    /**
	 * Add Flex class names which match this class description.
	 *
	 * @param className the name of the Flex class
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
    public function addImplementationClassName(className:String):void
    {
        _implementationClassNames.push(className);
    }

    /**
	 * @private
	 * Add a property descriptor to the class object
	 */
    public function addPropertyDescriptor(p:IAutomationPropertyDescriptor):void
    {
        _properties.push(p);
        if (p.forVerification)
	        _verificationProperties.push(p);
	    
	    if (p.forDescription)
	      	_descriptionProperties.push(p);
	            	
	    _propertyNameMap[p.name] = p;
    }

    /**
	 * @inheritDoc
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
    public function getPropertyDescriptors(objForInitialization:Object = null,
                                           forVerification:Boolean = true,
                                           forDescription:Boolean = true):Array
    {
        // This is for nested app support. Since a component may not be loaded
        // until the sub-app is loaded, we need to delay accessing any
        // Class or describeType info until we have an instance who's loaderInfo
        // we can use. This assumes that objForInitialization is the type we need
        if (!_propertyASTypesInitialized && objForInitialization != null)
        {
            _propertyASTypesInitialized = true;
            
            var dt:XML = describeType(objForInitialization);
            
            //dt shouldn't be null when it gets here
            fillInASTypesFromProperties(dt, _properties);
		}
		
		var result:Array = [];
        if (forVerification && forDescription)
        	result = _properties;
        else if (forVerification)
        	result = _verificationProperties;
        else if (forDescription)
        	result = _descriptionProperties;
        	
       	return result;
    }
    
    /**
	 * @private
	 */
	public function addMethod(m:IAutomationMethodDescriptor):void
    {
        var hash:String = m.name;
                            
        _method2descriptor[hash] = m;
    }

    /**
	 * @private
	 */
	public function addEvent(m:IAutomationEventDescriptor):void
    {
        var hash:String = hash(m.eventClassName, m.eventType);
                            
        _event2descriptor[hash] = m;
    }

    /**
     *  Translates between component event and Automation method descriptor
     *
     *  @param event The event object for which a method descrptor is required.
	 *
     *  @return The method descriptor for the event passed if one is available. 
     *          Otherwise null.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getDescriptorForEvent(
						event:Event):IAutomationEventDescriptor
    {
        var eventType:String = event.type;
        if (event is KeyboardEvent)
            eventType = "keyPress";
        var eventClassName:String = getClassName(event);
        var hash:String = hash(eventClassName, eventType);
        return hash in _event2descriptor ? _event2descriptor[hash] : null;
    }

     /**
      * Returns a full methodDescriptor from its name
      *
      *  @param methodName The method name for which the descriptor is required.
      *
      *  @return The method descriptor for the name passed if one is available. 
      *          Otherwise null.
      *  
      *  @langversion 3.0
      *  @playerversion Flash 9
      *  @playerversion AIR 1.1
      *  @productversion Flex 3
      */
    public function getDescriptorForMethodByName(
						methodName:String):IAutomationMethodDescriptor
    {
        for (var i:Object in _method2descriptor)
        {
            if (_method2descriptor[i].name == methodName)
                return _method2descriptor[i];
        }

        return null;
    }

    public function getDescriptorForEventByName(
						eventName:String):IAutomationEventDescriptor
    {
        for (var i:Object in _event2descriptor)
        {
            if (_event2descriptor[i].name == eventName)
                return _event2descriptor[i];
        }

        return null;
    }
    
    /**
	 * Returns the fully qualified name of the class to which the object belongs.
	 *  
	 * @param obj The object whose class name is desired
	 * 
	 * @return Fully qualified name of the class
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
    public static function getClassName(obj:Object):String
    {
    	return getQualifiedClassName(obj).replace("::", ".");
    }
    
    /**
     * Returns the major from current version number
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    public static function getMajorVersion():String
    {
    	return AutomationManager.VERSION.charAt(0);
    }  

	private static function getRootForThePopupObject(obj:DisplayObject):ISystemManager
	{
		var requiredSystemManager:ISystemManager = null;
		
		if(obj)
		{
			var objFound:Boolean = false;
		 	while((!objFound) && (obj.parent))
	    	{
	    		if(obj.parent is SystemManagerProxy)
	    		{
	    			requiredSystemManager = obj.parent.hasOwnProperty("systemManager")?obj.parent["systemManager"]:null;
	    			objFound = true;
	    		}
	    		obj = obj.parent;
	    	}
  		}
    	return requiredSystemManager;
	}
	
    /**
     *  Utility function that returns the class definition from the domain of a
     *  object instance
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function getDefinitionFromObjectDomain(obj:Object, className:String):Class
    {
		var eventClass:Class ;
		try
		{
			var dispObj:DisplayObject = obj as DisplayObject;
			
			// if the object is related to Popup's we need to get the application domain
			// from where the object is created. the root of the object here will corresponds to
			// the main application hence we getting the defintion from the main appl will not be correct
			var systemmanager:ISystemManager = getRootForThePopupObject(dispObj);
			
			if(systemmanager != null)
				eventClass = Class(systemmanager.loaderInfo.applicationDomain.getDefinition(className));
			else
				eventClass = Class(dispObj.root.loaderInfo.applicationDomain.getDefinition(className));
		}
		catch(e:Error)
		{
			// we can get a reference or security exception
			// in which case we try to access the objects own domain
			try
			{
				eventClass = Class(ApplicationDomain.currentDomain.getDefinition(className));
			}
			catch(e:Error)
			{
				// we can get a reference or security exception

				// In this case we assume that the class definition is not available
				// as the class has not been referenced in the app and it has 
				// not been linked in.
			}
		}

		return eventClass;		
    }

    /**
     *  Fills in the AS types for the provided propertyDescriptors based
     *  on the information provided in the describeType XML.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function fillInASTypesFromProperties(
								dtForClass:XML, 
                                propertyDescriptors:Array):void
    {
		// If DT was on a Class, we need to go to the factory node instead
		var isFactory:Boolean = dtForClass.hasOwnProperty("factory");
		var dtListForClass:XML = isFactory ? dtForClass.factory[0] : dtForClass;

        for (var propNo:int = 0; propNo < propertyDescriptors.length; ++propNo)
        {
		    // First try a property.
		    var propASTypeXML:XMLList = 
                dtListForClass.variable.(@name == propertyDescriptors[propNo].name);
		    
		    // If not there try an accessor.
		    if (propASTypeXML.length() == 0)
			    propASTypeXML = dtListForClass.accessor.
								(@name == propertyDescriptors[propNo].name);
    		
		    propertyDescriptors[propNo].asType = propASTypeXML.length() > 0 ?
												 propASTypeXML[0].@type.toString() :
												 null;
        }
    }

    /**
     *  Fills in the AS types for the provided propertyDescriptors based
     *  on the information provided in the describeType XML.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function fillInASTypesFromMethods(dtForClass:XML, 
                                                    methodName:String,
                                                    argDescriptors:Array):void
    {
		// If DT was on a Class, we need to go to the factory node instead
		var isFactory:Boolean = dtForClass.hasOwnProperty("factory");
		var dtListForClass:XML = isFactory ? dtForClass.factory[0] : dtForClass;

		var propMethodXML:XMLList = 
            dtListForClass.method.(@name == methodName);

        if (propMethodXML != null)
        {
            for (var argNo:int = 0; argNo < argDescriptors.length; ++argNo)
			{
		        argDescriptors[argNo].asType =
					propMethodXML[0].parameter[argNo].@type.toString(); 
			}
        }
    }

    /**
	 *  @private
	 */
	private static function getASTypeForMethodArgument(dtForClass:XML,
                                                       methodName:String,
                                                       argName:String):String
    {
        var propASType:String = null;
        
		// If DT was done a class, we need to go to the factory node instead.
		var isFactory:Boolean = dtForClass.hasOwnProperty("factory");
		var dtListForClass:XML = isFactory ? dtForClass.factory[0] : dtForClass;
		var propASTypeXML:XMLList =  dtListForClass.variable.(@name==argName);
		if (propASTypeXML.length() == 0)
			propASTypeXML = dtListForClass.accessor.(@name==argName);
		
		propASType = propASTypeXML.length() > 0 ?
					 propASTypeXML[0].@type.toString() :
					 null;
    		
		return propASType;
    }

    /**
     *  Puts an event in string form for hashing
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private static function hash(eventClassName:String, eventType:String):String
    {
        return eventClassName.replace("::", ".") + "|" + eventType;
    }
    
    /**
     * private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get propertyNameMap():Object
    {
    	return _propertyNameMap;
    }

    /**
     *  @return name, superClassName, and event/method mappings.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function toString():String
    {
        return "name: " + _name + "\n" +
               "superClassName: " + _superClassName + "\n" +
               "event2descriptor: " + ObjectUtil.toString(_event2descriptor);
    }
}

}
