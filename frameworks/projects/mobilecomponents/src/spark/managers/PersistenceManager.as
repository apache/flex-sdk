////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

// TODO (chiedozi): Should this be a singleton
package spark.core.managers
{
import flash.net.SharedObject;
    
/**
 *  The PersistenceManager class is a basic persistence manager that 
 *  is backed by a shared object.  When initialized, it will load a
 *  shared object that matches its id.  If one is not found, one will
 *  be created.
 * 
 *  <p>When storing values in the manager, it is important that all
 *  values can be properly be written to a shared object.  Complex
 *  objects that store classes or non-standard flash primitives will
 *  need to implement flash.net.IExternalizable to work properly.
 *  Saving incompatible objects will not cause an RTE, but will create
 *  undefined behavior when read from disk.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class PersistenceManager implements IPersistenceManager
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
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
     */ 
    private var enabled:Boolean = false;
    
    /**
     *  @private
     *  Returns whether the persistence manager has been initialized.
     * 
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function initialize():void
    {
        try
        {
            so = SharedObject.getLocal("FXAppCache");
            initialized = (so != null);
			enabled = (so != null);
        }
        catch (e:Error)
        {
            // TODO (chiedozi): Dispatch an error event for this.  Maybe a persistence_CREATE_FAIL
            enabled = false;
            initialized = false;
        }
    }
    
    // TODO (chiedozi): Add a try/catch for all operations for custom RTE i throw
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function setProperty(key:String, value:Object):void
    {
        if (!initialized)
            initialize();
        
        // TODO (chiedozi): Don't call flush now
        if (enabled)
        {
            so.data[key] = value;
            so.flush();
        }
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function getProperty(key:String):Object
    {
        if (!initialized)
            initialize();
        
        if (enabled)
            return so.data[key];
        
        return null;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function clear():void
    {
        if (!initialized)
            initialize();
        
		if (enabled)
		{
            so.clear();
            so.flush();
		}
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function flush():void
    {
		if (enabled)
        	so.flush();
    }
}
}