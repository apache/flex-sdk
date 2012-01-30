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

package spark.managers
{
    
/**
 *  IPersistenceManager defines the interface that all persistence
 *  managers must implement.  
 *  These objects are responsible for
 *  persisting data between application sessions.
 * 
 *  @see spark.managers.PersistenceManager
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
public interface IPersistenceManager
{
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Clears all the data that is being stored by the persistence
     *  manager.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    function clear():void;
    
    /**
     *  Flushes the data being managed by the persistence manager to
     *  disk, or to another external storage file.
     *
     *  @return <code>true</code> if the operation is successful.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    function save():Boolean;
    
    /**
     *  Initializes the persistence manager.
     *
     *  @return <code>true</code> if the operation is successful.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    function load():Boolean;
    
    /**
     *  Returns the value of a property stored in the persistence manager.
     *  Properties are saved as key:value pairs.
     *  
     *  @param key The property key.
     *
     *  @return The value of a property stored in the persistence manager.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    function getProperty(key:String):Object;
    
    /**
     *  Stores a value in the persistence manager.
     *  Properties are saved as key:value pairs.
     * 
     *  @param key The key to use to store the value.
     *
     *  @param value The value object to store.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    function setProperty(key:String, value:Object):void;
}
}