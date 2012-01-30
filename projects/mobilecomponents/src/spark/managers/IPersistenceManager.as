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