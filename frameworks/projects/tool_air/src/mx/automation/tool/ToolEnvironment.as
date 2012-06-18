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
import mx.automation.IAutomationClass;
import mx.automation.IAutomationClass2;
import mx.automation.IAutomationEnvironment;
import mx.automation.IAutomationEventDescriptor;
import mx.automation.IAutomationMethodDescriptor;
import mx.automation.IAutomationObject;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

[ResourceBundle("automation_agent")]

/**
 *  @private
 */
public class ToolEnvironment implements IAutomationEnvironment
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
	 */
	public function ToolEnvironment(source:XML)
    {
		super();

        for (var i:Object in source.ClassInfo)
        {
            // populate the class/automationClass map
            var classInfoXML:XML = source.ClassInfo[i];
            var automationClassName:String = classInfoXML.@Name.toString();
            var superClassName:String = 
                classInfoXML.@Extends && classInfoXML.@Extends.length != 0 ?
				classInfoXML.@Extends.toString() :
				null;
            var automationClass:ToolAutomationClass =
				new ToolAutomationClass(automationClassName, superClassName);
            automationClassName2automationClass[automationClassName] =
				automationClass;
            
            for (var j:Object in classInfoXML.Implementation)
            {
                var implementationXML:XML = classInfoXML.Implementation[j];
                var realClassName:String =
					implementationXML.@Class.toString().replace("::", ".");
				var versionObj:Object = implementationXML.@Version;
				var versionNum:String = versionObj.toString();
				if(versionNum!= "")
				{
					realClassName = realClassName+"_"+versionNum;
					automationClass.implementationVersion = int(versionNum);
				}
				else
				{
					automationClass.implementationVersion = 0;
				}				
                className2automationClass[realClassName] = automationClass;
                automationClass.addImplementationClassName(realClassName);
            }

            // for each method
            for (var k:Object in classInfoXML.TypeInfo.Operation)
            {
                var operationXML:XML = classInfoXML.TypeInfo.Operation[k];
			
                var automationMethodName:String = operationXML.@Name.toString();
                var eventClassName:String =
					operationXML.Implementation.@Class.toString();
                eventClassName = eventClassName.replace("::", ".");
                var eventType:String =
					operationXML.Implementation.@Type.toString();

                if (eventType)
                {
                    var args:Array = [];
                    for (var m:Object in operationXML.Argument)
                    {
                        var argXML:XML = operationXML.Argument[m];
                        var argName:String = argXML.@Name.toString();
                        var argType:String =
							argXML.Type.@VariantType.toString().toLowerCase();
                        var argCodec:String = argXML.Type.@Codec.toString();
                        var defaultValue:String = 
                            argXML.@DefaultValue.length() > 0 ?
							argXML.@DefaultValue.toString() :
							null;
                        var pd:ToolPropertyDescriptor = 
                            new ToolPropertyDescriptor(
								argName, true, true, argType,
                                (argCodec == null || argCodec.length == 0 ?
								"object" :
								argCodec), defaultValue);
                        args.push(pd);
                    }
                    
                    var returnType:String =
						operationXML.ReturnValueType.Type.@VariantType.toString();

                    var codecName:String =
						operationXML.ReturnValueType.Type.@Codec.toString();

					if(eventClassName)
					{
						var ed:IAutomationEventDescriptor = new ToolEventDescriptor(
								automationMethodName, eventClassName,
                                eventType, args);
                        automationClass.addEvent(ed);
     				}
                    else
					{
						var md:IAutomationMethodDescriptor = new ToolMethodDescriptor(
								automationMethodName, eventType, returnType,
                                codecName, args);
		                automationClass.addMethod(md);
                	}

                }
            }

            for (var p:Object in classInfoXML.Properties.Property)
            {
                var propertyXML:XML = classInfoXML.Properties.Property[p];
				var propName:String = propertyXML.@Name.toString();
				var propType:String =
					propertyXML.Type.@VariantType.toString().toLowerCase();
                var propCodec:String = propertyXML.Type.@Codec.toString();
                var pd1:ToolPropertyDescriptor = 
					new ToolPropertyDescriptor(
						propName,
                        propertyXML.@ForDescription.toString() == "true",
                        propertyXML.@ForVerification.toString() == "true",
                        propType,
                        (propCodec == null || propCodec.length == 0 ?
						"object" :
						propCodec));
                automationClass.addPropertyDescriptor(pd1);
            }
        }
    }

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

    /**
	 *  @private
	 */
    private var className2automationClass:Object = {};
    
    /**
	 *  @private
	 */
	private var automationClassName2automationClass:Object = {};

	/**
	 *  @private
	 *  Used for accessing localized Error messages.
	 */
	private var resourceManager:IResourceManager =
									ResourceManager.getInstance();

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
	 */
    public function getAutomationClassByInstance(
						obj:IAutomationObject):IAutomationClass
    {
        var result:IAutomationClass = findClosestAncestor(obj);
        if (! result)
		{
			var message:String = resourceManager.getString(
				"automation_agent", "autClassNotFound",
				[AutomationClass.getClassName(obj), obj]);
            throw new Error(message);
		}
        return result; 
    }

    /**
     *  @private
	 */
    public function getAutomationClassByName(
						automationClass:String):IAutomationClass
    {
        return ToolAutomationClass(
			automationClassName2automationClass[automationClass]);
    }

    /**
     *  Finds the closest ancestor to this object about which information was 
     *  passed in the environment XML.
     *  @private
     */
    private function findClosestAncestor(obj:Object):IAutomationClass
    {   	
        var className:String = AutomationClass.getClassName(obj).concat('_').concat(AutomationClass.getMajorVersion());
        var version:int = int(className.substr(className.length-1));
        className = className.substring(0, className.length - 2);
        for(var i:int = version; i > 0; i--){
        	var classNameWithVersion:String = className.concat('_').concat(i);
        	if (classNameWithVersion in className2automationClass)
        		return className2automationClass[classNameWithVersion];
        }
        
        if (className in className2automationClass)
            return className2automationClass[className];
		
        var ancestors:Array = findAllAncestors(obj);
        if (ancestors.length != 0)
        {
            className2automationClass[className] = getClosestVersionAncestor(ancestors);
            return className2automationClass[className];
        }
        else
		{
            return null;
		}
    }
    
    /**
     *  @private
     */
    private function getClosestVersionAncestor(ancestors:Array):IAutomationClass
    {
    	//There can be many ancestors of same class but with different versions
    	//We need to find the ancestor which is closer in version to current version 
    	var closeAncestors:Array = [];
       	closeAncestors.push(ancestors[0]);
       	var n:int = ancestors.length;
       	var isAncestor:Boolean = false;
       	
       	for( var i:int = 1; i < n; i++ )
       	{
       		var firstSuperClass:String = ancestors[0].superClassName;
       		var secondAncestor:IAutomationClass = ancestors[i];
       		
       		while( firstSuperClass )
       		{
       			if( firstSuperClass == secondAncestor.name )
       			{
       				isAncestor = true;
       				break;
       			}
       			else
       			{
       				firstSuperClass = getAutomationClassByName(firstSuperClass).superClassName;
       			}
       		}
       		if( !isAncestor )
       		{
       			var temp:Array = [];
       			temp.push(ancestors[i]);
       			closeAncestors = temp.concat(closeAncestors);
       		}
       		else
       		{
       			break;
       		}
       	}
       	
       	var currentVersion:int = int(AutomationClass.getMajorVersion());
       	var closestAncestor:IAutomationClass = closeAncestors[0];
       	
       	if(closeAncestors[0] is IAutomationClass2)
       	{
       		var currentAncestorVersion:int = IAutomationClass2(closeAncestors[0]).implementationVersion;
       		n = closeAncestors.length;
       		for (i = 1; i < n; i++)
       		{
       			var nextAncestorVersion:int = IAutomationClass2(closeAncestors[i]).implementationVersion;
       			if( currentAncestorVersion > currentVersion )
       				currentAncestorVersion = nextAncestorVersion; 
       			if( nextAncestorVersion <= currentVersion && nextAncestorVersion >= currentAncestorVersion )
       			{
       				closestAncestor = closeAncestors[i];
       				currentAncestorVersion = nextAncestorVersion;
       			}
       		}
       	}
       	return closestAncestor;
    }  

    /**
	 *  @private
	 */
    private function findAllAncestors(obj:Object):Array
    {
       var result:Array = [];
        
		for (var i:String in className2automationClass)
        {
        	var temp:String = i;
        	if(temp.indexOf("_") != -1)
        		temp = temp.substring(0, i.lastIndexOf("_"));
		    var realClass:Class = 
                          AutomationClass.getDefinitionFromObjectDomain(obj,temp);
            if (realClass && obj is realClass)
                result.push(className2automationClass[i]);
        }
        
		result.sort(sortAncestors);
        
		return result;
    }
    
    /**
	 *  @private
	 */
    private function sortAncestors(a:IAutomationClass, b:IAutomationClass):int
    {
        var superClass:IAutomationClass;
        var x:String = a.superClassName;
        while (x)
        {
            if (x == b.name)
                return -1;
            superClass = getAutomationClassByName(x);
            x = superClass.superClassName;
        }
        
		x = b.superClassName;
        while (x)
        {
            if (x == a.name)
                return 1;
            superClass = getAutomationClassByName(x);
            x = superClass.superClassName;
        }
        
		// Bad things will happen if we return 0... maybe throw an error?
        return 0;
    }
}

}
