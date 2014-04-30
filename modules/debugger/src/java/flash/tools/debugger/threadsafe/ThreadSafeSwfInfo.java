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

import flash.tools.debugger.InProgressException;
import flash.tools.debugger.Session;
import flash.tools.debugger.SourceFile;
import flash.tools.debugger.SwfInfo;

/**
 * Thread-safe wrapper for flash.tools.debugger.SwfInfo
 * @author Mike Morearty
 */
public class ThreadSafeSwfInfo extends ThreadSafeDebuggerObject implements SwfInfo {
	
	private SwfInfo fSwfInfo;
	
	private ThreadSafeSwfInfo(Object syncObj, SwfInfo swfInfo) {
		super(syncObj);
		fSwfInfo = swfInfo;
	}

	/**
	 * Wraps a SwfInfo inside a ThreadSafeSwfInfo.  If the passed-in SwfInfo
	 * is null, then this function returns null.
	 */
	public static ThreadSafeSwfInfo wrap(Object syncObj, SwfInfo swfInfo) {
		if (swfInfo != null)
			return new ThreadSafeSwfInfo(syncObj, swfInfo);
		else
			return null;
	}

	/**
	 * Wraps an array of SwfInfos inside an array of ThreadSafeSwfInfos.
	 */
	public static ThreadSafeSwfInfo[] wrapArray(Object syncObj, SwfInfo[] swfinfos) {
		ThreadSafeSwfInfo[] threadSafeSwfInfos = new ThreadSafeSwfInfo[swfinfos.length];
		for (int i=0; i<swfinfos.length; ++i) {
			threadSafeSwfInfos[i] = wrap(syncObj, swfinfos[i]);
		}
		return threadSafeSwfInfos;
	}

	public static Object getSyncObject(SwfInfo swfInfo) {
		return ((ThreadSafeSwfInfo)swfInfo).getSyncObject();
	}

	public boolean containsSource(SourceFile f) {
		synchronized (getSyncObject()) {
			return fSwfInfo.containsSource(ThreadSafeSourceFile.getRaw(f));
		}
	}

	public String getPath() {
		synchronized (getSyncObject()) {
			return fSwfInfo.getPath();
		}
	}

	public int getSourceCount(Session s) throws InProgressException {
		synchronized (getSyncObject()) {
			return fSwfInfo.getSourceCount(ThreadSafeSession.getRaw(s));
		}
	}

	public SourceFile[] getSourceList(Session s) throws InProgressException {
		synchronized (getSyncObject()) {
			return ThreadSafeSourceFile.wrapArray(getSyncObject(), fSwfInfo.getSourceList(ThreadSafeSession.getRaw(s)));
		}
	}

	public int getSwdSize(Session s) throws InProgressException {
		synchronized (getSyncObject()) {
			return fSwfInfo.getSwdSize(ThreadSafeSession.getRaw(s));
		}
	}

	public int getSwfSize() {
		synchronized (getSyncObject()) {
			return fSwfInfo.getSwfSize();
		}
	}

	public String getUrl() {
		synchronized (getSyncObject()) {
			return fSwfInfo.getUrl();
		}
	}

	public boolean isProcessingComplete() {
		synchronized (getSyncObject()) {
			return fSwfInfo.isProcessingComplete();
		}
	}

	public boolean isUnloaded() {
		synchronized (getSyncObject()) {
			return fSwfInfo.isUnloaded();
		}
	}

	@Override
	public int getIsolateId() {
		synchronized (getSyncObject()) {
			return fSwfInfo.getIsolateId();
		}
	}
}
