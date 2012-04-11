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

import java.io.Serializable;

/**
 * Subclasses of AbstractCache implement various cache policies.
 * <p>
 * Users of these subclasses should override fetch() or fetchSerial()
 * to provide the logic for retreiving entries that are not in cache.
 * <p>
 * If you override fetchSerial(), only one thread will enter fetch()
 * at the same time.
 *
 * @author Edwin Smith
 */
public abstract class AbstractCache implements Serializable
{
	private static class Lock {}
	private Lock lock = new Lock();
	private Thread busyThread;

	/**
	 * subclasses override fetch() to fetch values that are not in
	 * cache.
	 *
	 * The default implementation uses a semaphore to serialize
	 * access to the fetchSerial method.
	 *
	 * @return the value to cache.  null's are okay.
	 */
	protected Object fetch(Object key)
	{
		synchronized(lock)
		{
			Thread currentThread = Thread.currentThread();
			if (busyThread == currentThread)
			{
				throw new IllegalStateException("AbstractCache.fetch is not re-entrant");
			}

			while (busyThread != null)
			{
				try
				{
					lock.wait();
				}
				catch (InterruptedException e)
				{
				}
			}

			busyThread = currentThread;
		}

		try
		{
			return fetchSerial(key);
		}
		finally
		{
			synchronized (lock)
			{
				busyThread = null;
				lock.notify();
			}
		}
	}

	/**
	 * users can override this hook to add logic for fetching
	 * values that is automatically serialized by the base class.
	 */
	protected Object fetchSerial(Object key)
	{
		return null;
	}

	/**
	 * retreive a value from the cache, invoking fetch() if the value is
	 * not there.  this method is final -- implementations should
	 * override fetch().
	 *
	 * Note: null values can be stored in the cache.  This is useful
	 * for resource caches that fail-fast, when a resource doesn't
	 * exist.  fetch() will return null, and null will be stored in the
	 * cache under the given key, like any other value.
	 */
	public abstract Object get(Object key);

	abstract public void remove(Object key);

	abstract public void put(Object key, Object value);

	abstract public void setSize(int size);

	abstract public void clear();

	// statistics
	long hits;
	long misses;
	long missPenalty;

	static public boolean verbose = false;

	final void report()
	{
		if (verbose)
		{
			double tries = misses+hits;
			double penalty = missPenalty/(double)misses;

			System.out.println(this + " hit rate: " + (hits*100)/tries
							   + " " + hits + "/" + misses
							   + " penalty " + penalty);
		}
	}
}