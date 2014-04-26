/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package flash.tools.debugger.threadsafe;

import flash.tools.debugger.Location;
import flash.tools.debugger.SourceFile;

/**
 * Thread-safe wrapper for flash.tools.debugger.Location
 * @author Mike Morearty
 */
public class ThreadSafeLocation extends ThreadSafeDebuggerObject implements Location {

	private Location fLocation;
	
	private ThreadSafeLocation(Object syncObj, Location location) {
		super(syncObj);
		fLocation = location;
	}

	/**
	 * Wraps a Location inside a ThreadSafeLocation.  If the passed-in Location
	 * is null, then this function returns null.
	 */
	public static ThreadSafeLocation wrap(Object syncObj, Location location) {
		if (location != null)
			return new ThreadSafeLocation(syncObj, location);
		else
			return null;
	}

	/**
	 * Wraps an array of Locations inside an array of ThreadSafeLocations.
	 */
	public static ThreadSafeLocation[] wrapArray(Object syncObj, Location[] locations) {
		ThreadSafeLocation[] threadSafeLocations = new ThreadSafeLocation[locations.length];
		for (int i=0; i<locations.length; ++i) {
			threadSafeLocations[i] = wrap(syncObj, locations[i]);
		}
		return threadSafeLocations;
	}

	/**
	 * Returns the raw Location underlying a ThreadSafeLocation.
	 */
	public static Location getRaw(Location l) {
		if (l instanceof ThreadSafeLocation)
			return ((ThreadSafeLocation)l).fLocation;
		else
			return l;
	}

	public static Object getSyncObject(Location l) {
		return ((ThreadSafeLocation)l).getSyncObject();
	}

	public SourceFile getFile() {
		synchronized (getSyncObject()) {
			return ThreadSafeSourceFile.wrap(getSyncObject(), fLocation.getFile());
		}
	}
	
	public int getLine() {
		synchronized (getSyncObject()) {
			return fLocation.getLine();
		}
	}

	@Override
	public int getIsolateId() {
		synchronized (getSyncObject()) {
			return fLocation.getIsolateId();
		}
	}
}
