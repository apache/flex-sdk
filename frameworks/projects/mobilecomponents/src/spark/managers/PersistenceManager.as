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
import flash.net.SharedObject;
    
/**
 *  The PersistenceManager class is a basic persistence manager that 
 *  is backed by a local shared object named FxAppCache.  
 *  When initialized, it loads a local shared object that matches its id.  
 *  If a local shared object is not found, it is created.
 * 
 *  <p>When storing values using the manager, it is important that all
 *  values can be properly be written to a shared object.  
 *  Complex objects that store classes or non-standard flash primitives 
 *  must implement flash.net.IExternalizable interface to work properly.
 *  Saving incompatible objects does not cause an RTE, but creates
 *  undefined behavior when the data is read back.</p>
 *
 *  @see flash.utils.IExternalizable
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class PersistenceManager implements IPersistenceManager
{
    //--------------------------------------------------------------------------
    //
    //  Constants
    //
    //--------------------------------------------------------------------------
    
    private static const SHARED_OBJECT_NAME:String = "FXAppCache";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function PersistenceManager()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Returns whether the persistence manager has been initialized.
     */ 
    private var initialized:Boolean = false;
    
    /**
     *  @private
     *  The shared object used by the persistence manager.
     */ 
    private var so:SharedObject;
    
    //--------------------------------------------------------------------------
    //
    //  IPersistenceManager Methods
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function load():Boolean
    {
        if (initialized)
            return true;
        
        try
        {
            so = SharedObject.getLocal(SHARED_OBJECT_NAME);
            initialized = true;
        }
        catch (e:Error)
        {
            // Fail silently
        }
        
        return initialized;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function setProperty(key:String, value:Object):void
    {
        // If the persistence manager hasn't been initialized, do so now
        if (!initialized)
            load();
        
        // Make sure the shared object is valid since initialization fails silently
        if (so != null)
            so.data[key] = value;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function getProperty(key:String):Object
    {
        // If the persistence manager hasn't been initialized, do so now
        if (!initialized)
            load();
        
        // Make sure the shared object is valid since initialization fails silently
        if (so != null)
            return so.data[key];
        
        return null;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function clear():void
    {
        // If the persistence manager hasn't been initialized, do so now
        if (!initialized)
            load();
        
        // Make sure the shared object is valid since initialization fails silently
        if (so != null)
            so.clear();
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function save():Boolean
    {
        try
        {
            // We assume the flush suceeded and don't check the flush status
            so.flush();
        }
        catch (e:Error)
        {
            // Fail silently
            return false;
        }
        
        return true;
    }
}
}