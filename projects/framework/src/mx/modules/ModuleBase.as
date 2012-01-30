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

package mx.modules
{

import flash.events.EventDispatcher;

[Frame(factoryClass="mx.core.FlexModuleFactory")]

/**
 *  The base class for ActionScript-based dynamically-loadable modules.
 *  If you write an ActionScript-only module, you should extend this class.
 *  If you write an MXML-based module by using the <code>&lt;mx:Module&gt;</code> 
 *  tag in an MXML file, you instead extend the Module class.
 *  
 *  @see mx.modules.Module
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class ModuleBase extends EventDispatcher implements IModule
{
    include "../core/Version.as";
}

}
