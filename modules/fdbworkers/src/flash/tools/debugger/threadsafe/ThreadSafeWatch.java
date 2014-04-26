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

import flash.tools.debugger.Watch;

/**
 * Thread-safe wrapper for flash.tools.debugger.Watch
 * @author Mike Morearty
 */
public class ThreadSafeWatch extends ThreadSafeDebuggerObject implements Watch {
	
	private Watch fWatch;
	
	private ThreadSafeWatch(Object syncObj, Watch watch) {
		super(syncObj);
		fWatch = watch;
	}

	/**
	 * Wraps a Watch inside a ThreadSafeWatch.  If the passed-in Watch
	 * is null, then this function returns null.
	 */
	public static ThreadSafeWatch wrap(Object syncObj, Watch watch) {
		if (watch != null)
			return new ThreadSafeWatch(syncObj, watch);
		else
			return null;
	}

	/**
	 * Wraps an array of Watches inside an array of ThreadSafeWatches.
	 */
	public static ThreadSafeWatch[] wrapArray(Object syncObj, Watch[] watchs) {
		ThreadSafeWatch[] threadSafeWatches = new ThreadSafeWatch[watchs.length];
		for (int i=0; i<watchs.length; ++i) {
			threadSafeWatches[i] = wrap(syncObj, watchs[i]);
		}
		return threadSafeWatches;
	}

	/**
	 * Returns the raw Watch underlying a ThreadSafeWatch.
	 */
	public static Watch getRaw(Watch w) {
		if (w instanceof ThreadSafeWatch)
			return ((ThreadSafeWatch)w).fWatch;
		else
			return w;
	}

	public static Object getSyncObject(Watch w) {
		return ((ThreadSafeWatch)w).getSyncObject();
	}

	public int getKind() {
		synchronized (getSyncObject()) {
			return fWatch.getKind();
		}
	}

	public String getMemberName() {
		synchronized (getSyncObject()) {
			return fWatch.getMemberName();
		}
	}

	public long getValueId() {
		synchronized (getSyncObject()) {
			return fWatch.getValueId();
		}
	}

	@Override
	public int getIsolateId() {
		synchronized (getSyncObject()) {
			return fWatch.getIsolateId();
		}
	}
}
