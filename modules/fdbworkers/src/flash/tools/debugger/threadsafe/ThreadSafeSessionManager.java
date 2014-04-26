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

import java.io.IOException;

import flash.tools.debugger.AIRLaunchInfo;
import flash.tools.debugger.IDebuggerCallbacks;
import flash.tools.debugger.ILaunchNotification;
import flash.tools.debugger.ILauncher;
import flash.tools.debugger.IProgress;
import flash.tools.debugger.Player;
import flash.tools.debugger.Session;
import flash.tools.debugger.SessionManager;
import flash.tools.debugger.SessionManager2;

/**
 * Thread-safe wrapper for flash.tools.debugger.SessionManager
 * @author Mike Morearty
 */
public class ThreadSafeSessionManager extends ThreadSafeDebuggerObject implements SessionManager2 {

	private SessionManager fSessionManager;
	
	private ThreadSafeSessionManager(SessionManager sessionManager) {
		super(new Object());
		fSessionManager = sessionManager;
	}

	/**
	 * Wraps a SessionManager inside a ThreadSafeSessionManager.  If the passed-in SessionManager
	 * is null, then this function returns null.
	 */
	public static ThreadSafeSessionManager wrap(SessionManager sessionManager) {
		if (sessionManager != null)
			return new ThreadSafeSessionManager(sessionManager);
		else
			return null;
	}

	public static Object getSyncObject(SessionManager sm) {
		return ((ThreadSafeSessionManager)sm).getSyncObject();
	}

	public Session accept(IProgress waitReporter) throws IOException {
		// WARNING: This function is not thread-safe.
		//
		// accept() can take a very long time -- e.g. if there is something wrong,
		// then it might hang for two minutes while waiting for the Flash player.
		// So, it is not acceptable to put this in a "synchronized" block.
		return ThreadSafeSession.wrap(getSyncObject(), fSessionManager.accept(waitReporter));
	}

	public int getPreference(String pref) throws NullPointerException {
		synchronized (getSyncObject()) {
			return fSessionManager.getPreference(pref);
		}
	}

	public boolean isListening() {
		synchronized (getSyncObject()) {
			return fSessionManager.isListening();
		}
	}

	public Session launch(String uri, AIRLaunchInfo airLaunchInfo, boolean forDebugging, IProgress waitReporter, ILaunchNotification launchNotification) throws IOException {
		// WARNING: This function is not thread-safe.
		//
		// launch() can take a very long time -- e.g. if there is something wrong,
		// then it might hang for two minutes while waiting for the Flash player.
		// So, it is not acceptable to put this in a "synchronized" block.
		return ThreadSafeSession.wrap(getSyncObject(), fSessionManager.launch(uri, airLaunchInfo, forDebugging, waitReporter,launchNotification));
	}

	public Player playerForUri(String uri, AIRLaunchInfo airLaunchInfo) {
		synchronized (getSyncObject()) {
			return ThreadSafePlayer.wrap(getSyncObject(), fSessionManager.playerForUri(uri, airLaunchInfo));
		}
	}

	public boolean supportsLaunch()
	{
		synchronized (getSyncObject()) {
			return fSessionManager.supportsLaunch();
		}
	}

	public void setPreference(String pref, int value) {
		synchronized (getSyncObject()) {
			fSessionManager.setPreference(pref, value);
		}
	}

	public void setPreference(String pref, String value) {
		synchronized (getSyncObject()) {
			fSessionManager.setPreference(pref, value);
		}
	}

	public void startListening() throws IOException {
		synchronized (getSyncObject()) {
			fSessionManager.startListening();
		}
	}

	public void stopListening() throws IOException {
		synchronized (getSyncObject()) {
			fSessionManager.stopListening();
		}
	}

	public void setDebuggerCallbacks(IDebuggerCallbacks debuggerCallbacks) {
		synchronized (getSyncObject()) {
			fSessionManager.setDebuggerCallbacks(debuggerCallbacks);
		}
	}

	/* (non-Javadoc)
	 * @see flash.tools.debugger.SessionManager#connect(int, flash.tools.debugger.IProgress)
	 */
	public Session connect(int port, IProgress waitReporter) throws IOException {
		// WARNING: This function is not thread-safe.
		//
		// connect() can take a very long time -- e.g. if there is something wrong,
		// then it might hang for two minutes while waiting for the Flash player.
		// So, it is not acceptable to put this in a "synchronized" block.
		return ThreadSafeSession.wrap(getSyncObject(), fSessionManager.connect(port, waitReporter));		
	}
	
	public void stopConnecting() throws IOException {
		synchronized (getSyncObject()) {
			fSessionManager.stopConnecting();
		}
	}
	
	public boolean isConnecting() {
		synchronized (getSyncObject()) {
			return fSessionManager.isConnecting();
		}
	}

	@Override
	public Process launchForRun(String uri, AIRLaunchInfo airLaunchInfo,
			IProgress waitReporter, ILaunchNotification launchNotification)
			throws IOException {
		/*
		 * launch used to return null when the session was null.
		 * The session will be null in this case because this is invoked for run launches.
		 * We just return the process to be consistent with PlayerSessionManager. 
		 */
		assert fSessionManager instanceof SessionManager2;
		
		Process process = ((SessionManager2) fSessionManager).launchForRun(uri, airLaunchInfo, waitReporter, launchNotification);
			
		return process;	
	}

	@Override
	public Process launchForRun(String uri, AIRLaunchInfo airLaunchInfo,
			IProgress waitReporter, ILaunchNotification launchNotification,
			ILauncher launcher) throws IOException {
		/*
		 * launch used to return null when the session was null.
		 * The session will be null in this case because this is invoked for run launches.
		 * We just return the process to be consistent with PlayerSessionManager. 
		 */
		assert fSessionManager instanceof SessionManager2;
		
		Process process = ((SessionManager2) fSessionManager).launchForRun(uri, airLaunchInfo, waitReporter, launchNotification,launcher);
			
		return process;	
	}

	@Override
	public Session launch(String uri, AIRLaunchInfo airLaunchInfo,
			boolean forDebugging, IProgress waitReporter,
			ILaunchNotification launchNotification, ILauncher launcher)
			throws IOException {
		// WARNING: This function is not thread-safe.
				//
				// launch() can take a very long time -- e.g. if there is something wrong,
				// then it might hang for two minutes while waiting for the Flash player.
				// So, it is not acceptable to put this in a "synchronized" block.
				assert fSessionManager instanceof SessionManager2;
				
				return ThreadSafeSession.wrap(getSyncObject(), ((SessionManager2) fSessionManager).launch(uri, airLaunchInfo, forDebugging, waitReporter,launchNotification,launcher));
	}
}
