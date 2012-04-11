/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flash.util;

/**
 * Caching data structure that uses a Least Recently Used (LRU)
 * algorithm.  This cache has a max size associated with it that is
 * used to determine when objects should be purged from the cache.
 * Once the max size is reached, the least recently used element will
 * be purged.
 * <p>
 * This class is thread-safe.
 *
 * @author Spike Washburn
 * @author Peter Farland (Updated to be thread-safe)
 */
public abstract class IntMapLRUCache
{
    private IntMap map;
    private ListEntry head;//the MRU element
    private ListEntry tail;//the LRU element
    private int maxSize; //the max size of this cache. If this size is exceeded, LRU elements will be purged to free cache space.
    private int purgeSize = 1;//number of objects to purge when the max size is reached.

    /**
     * Create a new LRU cache.
     *
     * @param initialSize the initial size of the IntMap
     * @param maxSize     the maximum number of elements this cache can hold before purging LRU elements.
     */
    public IntMapLRUCache(int initialSize, int maxSize)
    {
        this(initialSize, maxSize, 1);
    }

    /**
     * Create a new LRU cache.
     * This constructor takes a purgeSize parameter that is used to increase the number of LRU
     * elements to when the cache exceeds its max size. Increasing the purge size can reduce the
     * overhead of using the cache if the cache size is maxed out frequently.
     *
     * @param initialSize the initial size of the IntMap
     * @param maxSize     the maximum number of elements this cache can hold before purging LRU elements.
     * @param purgeSize   the number of LRU elements to purge once the max size is exceeded.
     */
    public IntMapLRUCache(int initialSize, int maxSize, int purgeSize)
    {
        super();
        this.maxSize = maxSize;
        this.purgeSize = purgeSize;
	    if (initialSize < 1) initialSize = 1;
        map = new IntMap(initialSize);
    }

    /**
     * Retrieve an object from the cache using the specified key.
     * Use of this method will make the retrieved object the
     * most recently used object.
     */
    public Object get(int key)
    {
        Object value = null;

        synchronized (this)
        {
            //use a fast compare to see if this key matches the head object.
            //This trick improves performance drastically in situations where
            //the same object is looked up consecutively. This trick is especially
            //effective on quoted string keys because the vm optimizes them to use the
            //same memory location and therefore the == operator returns true.
            if (head != null && key == head.key)
            {
                return head.value;
            }

            ListEntry entry = (ListEntry)map.get(key);

            if (entry != null /* && (value = entry.value) != null */)
            {
                //move this key to the front of the use list
                setMostRecentlyUsed(entry);
                return entry.value;
            }
            // else not in cache, go fetch it
        }

        try
        {
            // don't hold the lock while fetching
            value = fetch(key);

            synchronized (this)
            {
                ListEntry entry = new ListEntry();
                entry.key = key;
                entry.value = value;

                map.put(key, entry);
            }
        }
        catch (UnsupportedOperationException ex)
        {
        }

        return value;
    }

    public int firstKey()
    {
        synchronized (this)
        {
            if (head != null)
                return head.key;
            else
                return 0;
        }
    }

    /**
     * Insert an object into the cache.
     */
    public Object put(int key, Object value)
    {
        //create a new list entry
        ListEntry entry = new ListEntry();

        //set the entry's value to be the new key.
        entry.value = value;
        entry.key = key;

        synchronized (this)
        {
            //insert the entry into the table
            map.put(key, entry);

            //move the new entry to the front of the list
            setMostRecentlyUsed(entry);
            if (tail == null)
            {
                tail = entry;
            }

            //purge condition
            if (size() > maxSize)
            {
                //purge the LRU elements to free up space for more elements.
                purgeLRUElements();
            }
        }

        return value;
    }

    /**
     * Remove an object from the cache.
     */
    public void remove(int key)
    {
        synchronized (this)
        {
            ListEntry entry = (ListEntry)map.remove(key);
            if (entry != null)
            {
                if (entry == head)
                {
                    head = entry.next;
                }
                if (entry == tail)
                {
                    tail = entry.prev;
                }
                if (entry.prev != null)
                {
                    entry.prev.next = entry.next;
                }
                if (entry.next != null)
                {
                    entry.next.prev = entry.prev;
                }
            }
        }
    }

    public void setSize(int size)
    {
//HashMap grows independently, can not control?
    }

    /**
     * Returns the number of elements currently in the cache.
     */
    public int size()
    {
        return map.size();
    }

    /**
     * Returns the number of elements that this cache can hold.
     * Once more than this number of elements is added to the cache,
     * the least recently used element will automatically be removed.
     */
    public int getMaxSize()
    {
        return maxSize;
    }

    /**
     * Returns the number of LRU elements to purge when the max size is reached.
     */
    public int getPurgeSize()
    {
        return purgeSize;
    }

    /**
     * Handler hook to signal subclasses that the LRU element has been purged from the cache.
     * This method is triggered when the cache's max size has been exceeded and the LRU
     * element must be removed from the cache. This method is invoked after the LRU element
     * has been removed from the cache.
     *
     * @param key   the insertion key that was originally used to add value to the cache.
     * @param value the value element bound to the key.
     */
    protected void handleLRUElementPurged(int key, Object value)
    {
    }

    /*
     * Remove the least recently used elements to make space for another element.
     * This purge will dump
     */
    private void purgeLRUElements()
    {
        //purge the number of LRU elements specified by the purgeSize.
        for (int i = 0; i < purgeSize && tail != null; i++)
        {
            int key = tail.key;
            Object value = tail.value;
            remove(tail.key);

            //signal the subclass that the LRU element has been purged.
            handleLRUElementPurged(key, value);
        }
    }


    /*
     * Set the specified entry as the most recently used entry.
     */
    private void setMostRecentlyUsed(ListEntry entry)
    {

        //replace the current position of the entry with its next entry
        if (entry.prev != null)
        {
            entry.prev.next = entry.next;
            if (entry == tail)
            {
                tail = entry.prev;
                tail.next = null;
            }
        }

        if (entry.next != null)
        {
            entry.next.prev = entry.prev;
        }

        //set the entry as the head
        entry.prev = null;
        entry.next = head;
        if (head != null)
        {
            head.prev = entry;
        }
        head = entry;
    }

    public abstract Object fetch(int key);
}


/**
 * Linked list element for the LRU list.
 */
class ListEntry extends Object
{
    ListEntry next;
    ListEntry prev;
    Object value;
    int key;

    public String toString()
    {
        return key + "=" + value;
    }
}

