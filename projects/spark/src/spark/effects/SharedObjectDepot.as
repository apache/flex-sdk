////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.effects
{
import flash.utils.Dictionary;

/**
 * This internal class is a utility used by AnimateTransform to 
 * store, retrieve, and remove shared objects. The class uses a 
 * Dictionary of Dictionaries internally to store the shared 
 * objects and keeps a reference count for the entries to know
 * when it is okay to remove the top level dictionary entry.
 * 
 * The reason this is needed by AnimateTransform is that we want
 * to share transform instances per top-level Parallel effect.
 * But rather than keep the Dictionary-of-Dictionaries at that level,
 * we keep it in this utility class. We add the reference count
 * to the upper-level dictionary to know when we can delete it
 * (Dictionary lacks any useful isEmpty() capability).
 * 
 * The top level Dictionary elements are stored in sharedObjectMaps
 * by the mapKey passed into storeSharedObject(). The items in 
 * sharedObjectMaps are Dictionaries using the target argument passed
 * into storeSharedObject() to store their entries. 
 */ 
internal class SharedObjectDepot
{
    /**
     * The upper level Dictionary object. This will store our
     * lower level Dictionaries that we create on the fly
     */
    private var sharedObjectMaps:Dictionary = new Dictionary(true);
    
    /**
     * The refcount per key in sharedObjectMaps. When the refcount
     * for any map dips to zero, we delete it from sharedObjectMaps.
     */
    private var sharedObjectRefcounts:Dictionary = new Dictionary(true);
    
    public function SharedObjectDepot()
    {
    }
    
    /**
     * Returns a shared object if it exists. The top level map is
     * searched to see if there is an entry (another map) for the key
     * 'mapKey'. If that exists, that map is searched to see if there
     * is an entry with the key 'target'. mapKey must be non-null.
     * 
     * @return Object the shared object, if it exists, or null otherwise.
     */
    public function getSharedObject(mapKey:Object, target:Object):Object
    {
        if (mapKey != null)
        {
            var sharedObjectMap:Dictionary = 
                Dictionary(sharedObjectMaps[mapKey]);
            if (sharedObjectMap != null)
                return sharedObjectMap[target];
        }
        return null;
    }

    /**
     * Stores a new entry in the shared object map. First, the
     * top level map is searched to see if there is an existing
     * map entry (also a map) with the key 'mapKey'. If not, a
     * new map is created and stored with this key in the top level
     * map. Then the lower level map is queried to see if there
     * is an entry with the key 'target'. If not, the refcount for
     * mapKey is incremented. Finally, an entry is stored in the lower 
     * level map with the key 'target'. mapKey must be non-null.
     * 
     */
    public function storeSharedObject(mapKey:Object, target:Object,
        instance:Object):void
    {
        if (mapKey != null)
        {
            var sharedObjectMap:Dictionary = sharedObjectMaps[mapKey];
            if (!sharedObjectMap)
            {
                sharedObjectMap = new Dictionary();
                sharedObjectMaps[mapKey] = sharedObjectMap;
            }
            if (!sharedObjectMap[target])
            {
                if (!sharedObjectRefcounts[mapKey])
                    sharedObjectRefcounts[mapKey] = 1;
                else
                    sharedObjectRefcounts[mapKey] += 1;
            }                
            sharedObjectMap[target] = instance;
        }
    }
    
    /**
     * Removes the entry accessed with the upper level key of mapKey and
     * lower level key of target. If the refcount for mapKey reaches zero,
     * that entry is deleted from the upper level map. mapKey must be
     * non-null
     */
    public function removeSharedObject(mapKey:Object, target:Object):void
    {
        if (mapKey != null)
        {
            var sharedObjectMap:Dictionary = sharedObjectMaps[mapKey];
            if (!sharedObjectMap)
                return;
            if (sharedObjectMap[target])
            {
                delete sharedObjectMap[target];
                sharedObjectRefcounts[mapKey] -= 1;
                if (sharedObjectRefcounts[mapKey] <= 0)
                {
                    delete sharedObjectMaps[mapKey];
                    delete sharedObjectRefcounts[mapKey];
                }
            }
        }
    }
}
}