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

package mx.core
{

import flash.utils.getQualifiedClassName;

/**
 *  A class factory that provides a system manager
 *  as a context of where the class should be created.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class ContextualClassFactory extends ClassFactory
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
	 *  @param generator The Class that the <code>newInstance()</code> method
	 *  uses to generate objects from this factory object.
	 *
	 *  @param systemManager The system manager context in which the object
	 *  should be created.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function ContextualClassFactory(
							generator:Class = null,
							moduleFactory:IFlexModuleFactory = null)
	{
		super(generator);

		this.moduleFactory = moduleFactory;
	}
 
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	/**
	 *  The context in which an object should be created.
	 *
	 *  <p>This is used to solve using the embedded fonts in an application SWF
	 *  when the framework is loaded as an RSL
	 *  (the RSL has its own SWF context).
	 *  Embedded fonts may only be accessed from the SWF file context
	 *  in which they were created.
	 *  By using the <code>systemManager</code> of the application SWF,
	 *  the RSL can create objects in the application SWF context
	 *  that will have access to the application's embedded fonts.
	 *  <code>moduleFactory</code> will call <code>create()</code> to create
	 *  an object in the context of the <code>moduleFactory</code>.</p>
	 *
	 *  @default null
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var moduleFactory:IFlexModuleFactory;

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Creates a new instance of the <code>generator</code> class,
	 *  with the properties specified by <code>properties</code>.
	 *
	 *  <p>This method implements the <code>newInstance()</code> method
	 *  of the IFactory interface.</p>
	 *
	 *  @return The new instance that was created.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	override public function newInstance():*
	{
		var instance:Object = null;
		
		if (moduleFactory)
			instance = moduleFactory.create(getQualifiedClassName(generator));
		
		if (!instance)
			instance = super.newInstance();			

		if (properties)
		{
			for (var p:String in properties)
			{
        		instance[p] = properties[p];
			}
		}

		return instance;
	}

}

}
