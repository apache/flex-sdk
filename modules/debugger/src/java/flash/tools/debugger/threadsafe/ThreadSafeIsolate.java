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

import flash.tools.debugger.Isolate;

/**
 * Thread-safe wrapper for flash.tools.debugger.Isolate
 * @author Anirudh Sasikumar
 */
public class ThreadSafeIsolate extends ThreadSafeDebuggerObject implements Isolate {

	private Isolate fIsolate;
	
	private ThreadSafeIsolate(Object syncObj, Isolate isolate) {
		super(syncObj);
		fIsolate = isolate;
	}

	/**
	 * Wraps a Watch inside a ThreadSafeWatch.  If the passed-in Watch
	 * is null, then this function returns null.
	 */
	public static ThreadSafeIsolate wrap(Object syncObj, Isolate isolate) {
		if (isolate != null)
			return new ThreadSafeIsolate(syncObj, isolate);
		else
			return null;
	}
	
	/**
	 * Wraps an array of Locations inside an array of ThreadSafeLocations.
	 */
	public static ThreadSafeIsolate[] wrapArray(Object syncObj, Isolate[] isolates) {
		ThreadSafeIsolate[] threadSafeIsolates = new ThreadSafeIsolate[isolates.length];
		for (int i=0; i<isolates.length; ++i) {
			threadSafeIsolates[i] = wrap(syncObj, isolates[i]);
		}
		return threadSafeIsolates;
	}

	public int getId() {
		synchronized (getSyncObject()) {
			return fIsolate.getId();
		}
	}

}
