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

import flash.tools.debugger.Frame;
import flash.tools.debugger.ILauncher;
import flash.tools.debugger.Isolate;
import flash.tools.debugger.IsolateSession;
import flash.tools.debugger.Location;
import flash.tools.debugger.NoResponseException;
import flash.tools.debugger.NotConnectedException;
import flash.tools.debugger.NotSupportedException;
import flash.tools.debugger.NotSuspendedException;
import flash.tools.debugger.PlayerDebugException;
import flash.tools.debugger.Session;
import flash.tools.debugger.SourceLocator;
import flash.tools.debugger.SuspendedException;
import flash.tools.debugger.SwfInfo;
import flash.tools.debugger.Value;
import flash.tools.debugger.Variable;
import flash.tools.debugger.VersionException;
import flash.tools.debugger.Watch;
import flash.tools.debugger.events.DebugEvent;
import flash.tools.debugger.expression.PlayerFaultException;

/**
 * Thread-safe wrapper for flash.tools.debugger.Session
 * @author Mike Morearty
 */
public class ThreadSafeSession extends ThreadSafeDebuggerObject implements Session {

	private Session fSession;

	private ThreadSafeSession(Object syncObj, Session session) {
		super(syncObj);
		fSession = session;
	}

	/**
	 * Wraps a Session inside a ThreadSafeSession.  If the passed-in Session
	 * is null, then this function returns null.
	 */
	public static ThreadSafeSession wrap(Object syncObj, Session session) {
		if (session != null)
			return new ThreadSafeSession(syncObj, session);
		else
			return null;
	}

	/**
	 * Returns the raw Session underlying a ThreadSafeSession.
	 */
	public static Session getRaw(Session s) {
		if (s instanceof ThreadSafeSession)
			return ((ThreadSafeSession)s).fSession;
		else
			return s;
	}

	public static Object getSyncObject(Session s) {
		return ((ThreadSafeSession)s).getSyncObject();
	}

	public boolean bind() throws VersionException {
		synchronized (getSyncObject()) {
			return fSession.bind();
		}
	}

	public Location clearBreakpoint(Location location)
			throws NoResponseException, NotConnectedException {
		synchronized (getSyncObject()) {
			return ThreadSafeLocation.wrap(getSyncObject(), fSession.clearBreakpoint(ThreadSafeLocation.getRaw(location)));
		}
	}

	public Watch clearWatch(Watch watch) throws NoResponseException,
			NotConnectedException {
		synchronized (getSyncObject()) {
			return ThreadSafeWatch.wrap(getSyncObject(), fSession.clearWatch(ThreadSafeWatch.getRaw(watch)));
		}
	}

	public Location[] getBreakpointList() throws NoResponseException,
			NotConnectedException {
		synchronized (getSyncObject()) {
			return ThreadSafeLocation.wrapArray(getSyncObject(), fSession.getBreakpointList());
		}
	}

	public int getEventCount() {
		// Session.getEventCount() is guaranteed to be thread-safe, so we
		// don't have to do a "synchronized" block around this call.
		return fSession.getEventCount();
	}

	public Frame[] getFrames() throws NotConnectedException {
		synchronized (getSyncObject()) {
			return ThreadSafeFrame.wrapArray(getSyncObject(), fSession.getFrames());
		}
	}

	public Process getLaunchProcess() {
		synchronized (getSyncObject()) {
			return fSession.getLaunchProcess();
		}
	}

	public int getPreference(String pref) throws NullPointerException {
		synchronized (getSyncObject()) {
			return fSession.getPreference(pref);
		}
	}

	public SwfInfo[] getSwfs() throws NoResponseException {
		synchronized (getSyncObject()) {
			return ThreadSafeSwfInfo.wrapArray(getSyncObject(), fSession.getSwfs());
		}
	}

	public String getURI() {
		synchronized (getSyncObject()) {
			return fSession.getURI();
		}
	}

	public Value getValue(long valueId) throws NotSuspendedException,
			NoResponseException, NotConnectedException
	{
		synchronized (getSyncObject()) {
			return ThreadSafeValue.wrap(getSyncObject(), fSession.getValue(valueId));
		}
	}

	/** @deprecated */
	public Variable[] getVariableList() throws NotSuspendedException,
			NoResponseException, NotConnectedException, VersionException {
		synchronized (getSyncObject()) {
			return ThreadSafeVariable.wrapArray(getSyncObject(), fSession.getVariableList());
		}
	}

	public Watch[] getWatchList() throws NoResponseException,
			NotConnectedException {
		synchronized (getSyncObject()) {
			return ThreadSafeWatch.wrapArray(getSyncObject(), fSession.getWatchList());
		}
	}

	public boolean isConnected() {
		// Session.isConnected() is guaranteed to be thread-safe, so we
		// don't have to do a "synchronized" block around this call.
		return fSession.isConnected();
	}

	public boolean isSuspended() throws NotConnectedException {
		// Session.isSuspended() is guaranteed to be thread-safe, so we
		// don't have to do a "synchronized" block around this call.
		return fSession.isSuspended();
	}

	public DebugEvent nextEvent() {
		synchronized (getSyncObject()) {
			return fSession.nextEvent();
		}
	}

	public void resume() throws NotSuspendedException, NotConnectedException,
			NoResponseException {
		synchronized (getSyncObject()) {
			fSession.resume();
		}
	}

	public Location setBreakpoint(int fileId, int lineNum)
			throws NoResponseException, NotConnectedException {
		synchronized (getSyncObject()) {
			return ThreadSafeLocation.wrap(getSyncObject(), fSession.setBreakpoint(fileId, lineNum));
		}
	}

	public void setPreference(String pref, int value) {
		synchronized (getSyncObject()) {
			fSession.setPreference(pref, value);
		}
	}

	public Watch setWatch(Value v, String memberName, int kind)
			throws NoResponseException, NotConnectedException, NotSupportedException {
		synchronized (getSyncObject()) {
			return ThreadSafeWatch.wrap(getSyncObject(), fSession.setWatch(ThreadSafeValue.getRaw(v), memberName, kind));
		}
	}

	public Watch setWatch(Watch watch) throws NoResponseException,
			NotConnectedException, NotSupportedException {
		synchronized (getSyncObject()) {
			return ThreadSafeWatch.wrap(getSyncObject(), fSession.setWatch(ThreadSafeWatch.getRaw(watch)));
		}
	}

	public void stepContinue() throws NotSuspendedException,
			NoResponseException, NotConnectedException {
		synchronized (getSyncObject()) {
			fSession.stepContinue();
		}
	}

	public void stepInto() throws NotSuspendedException, NoResponseException,
			NotConnectedException {
		synchronized (getSyncObject()) {
			fSession.stepInto();
		}
	}

	public void stepOut() throws NotSuspendedException, NoResponseException,
			NotConnectedException {
		synchronized (getSyncObject()) {
			fSession.stepOut();
		}
	}

	public void stepOver() throws NotSuspendedException, NoResponseException,
			NotConnectedException {
		synchronized (getSyncObject()) {
			fSession.stepOver();
		}
	}

	public void suspend() throws SuspendedException, NotConnectedException,
			NoResponseException {
		synchronized (getSyncObject()) {
			fSession.suspend();
		}
	}

	public int suspendReason() throws NotConnectedException {
		synchronized (getSyncObject()) {
			return fSession.suspendReason();
		}
	}

	public void terminate() {
		synchronized (getSyncObject()) {
			fSession.terminate();
		}
	}

	public void unbind() {
		synchronized (getSyncObject()) {
			fSession.unbind();
		}
	}

	public void waitForEvent() throws NotConnectedException, InterruptedException {
		synchronized (getSyncObject()) {
			fSession.waitForEvent();
		}
	}

	public SourceLocator getSourceLocator()
	{
		synchronized (getSyncObject()) {
			return ThreadSafeSourceLocator.wrap(getSyncObject(), fSession.getSourceLocator());
		}
	}

	public void setSourceLocator(SourceLocator sourceLocator)
	{
		synchronized (getSyncObject()) {
			fSession.setSourceLocator(sourceLocator);
		}
	}

	public Value callConstructor(String classname, Value[] args)
			throws PlayerDebugException {
		synchronized (getSyncObject()) {
			return ThreadSafeValue.wrap(getSyncObject(), fSession.callConstructor(classname, args));
		}
	}

	public Value callFunction(Value thisObject, String functionName, Value[] args)
			throws PlayerDebugException {
		synchronized (getSyncObject()) {
			return ThreadSafeValue.wrap(getSyncObject(), fSession.callFunction(thisObject, functionName, args));
		}
	}

	public Value getGlobal(String name) throws NotSuspendedException, NoResponseException, NotConnectedException
	{
		synchronized (getSyncObject())
		{
			return ThreadSafeValue.wrap(getSyncObject(), fSession.getGlobal(name));
		}
	}

	public void breakOnCaughtExceptions(boolean b) throws NotSupportedException, NoResponseException {
		synchronized (getSyncObject())	{
			fSession.breakOnCaughtExceptions(b);
		}
	}

	public boolean evalIs(Value value, Value type) throws PlayerDebugException, PlayerFaultException {
		synchronized (getSyncObject()) {
			return fSession.evalIs(value, type);
		}
	}

	public boolean evalIs(Value value, String type) throws PlayerDebugException, PlayerFaultException {
		synchronized (getSyncObject()) {
			return fSession.evalIs(value, type);
		}
	}

	public boolean evalInstanceof(Value value, Value type) throws PlayerDebugException, PlayerFaultException {
		synchronized (getSyncObject()) {
			return fSession.evalInstanceof(value, type);
		}
	}

	public boolean evalInstanceof(Value value, String type) throws PlayerDebugException, PlayerFaultException {
		synchronized (getSyncObject()) {
			return fSession.evalInstanceof(value, type);
		}
	}

	public boolean evalIn(Value property, Value object) throws PlayerDebugException, PlayerFaultException {
		synchronized (getSyncObject()) {
			return fSession.evalIn(property, object);
		}
	}

	public Value evalAs(Value value, Value type) throws PlayerDebugException, PlayerFaultException {
		synchronized (getSyncObject()) {
			return ThreadSafeValue.wrap(getSyncObject(), fSession.evalAs(value, type));
		}
	}

	public boolean supportsWatchpoints() {
		synchronized (getSyncObject()) {
			return fSession.supportsWatchpoints();
		}
	}
	
	public boolean supportsConcurrency() {
		synchronized (getSyncObject()) {
			return fSession.supportsConcurrency();
		}
	}

	/* (non-Javadoc)
	 * @see flash.tools.debugger.Session#getDisconnectCause()
	 */
	public Exception getDisconnectCause() {
		synchronized (getSyncObject()) {
			return fSession.getDisconnectCause();
		}
	}

	/* (non-Javadoc)
	 * @see flash.tools.debugger.Session#refreshWorkers()
	 */
	@Override
	public Isolate[] refreshWorkers() throws NotSupportedException,
			NotSuspendedException, NoResponseException, NotConnectedException {
		synchronized (getSyncObject()) {
			return ThreadSafeIsolate.wrapArray(getSyncObject(), fSession.getWorkers());
		}
	}

	/* (non-Javadoc)
	 * @see flash.tools.debugger.Session#getWorkers()
	 */
	@Override
	public Isolate[] getWorkers() {
		synchronized (getSyncObject()) {
			return fSession.getWorkers();
		}
	}

	/* (non-Javadoc)
	 * @see flash.tools.debugger.Session#getWorkerSession(int)
	 */
	@Override
	public IsolateSession getWorkerSession(int isolateId) {
		synchronized (getSyncObject()) {
			return ThreadSafeIsolateSession.wrap(getSyncObject(), fSession.getWorkerSession(isolateId));
		}
	}

	/* (non-Javadoc)
	 * @see flash.tools.debugger.Session#setExceptionBreakpoint(String)
	 */
	@Override
	public boolean setExceptionBreakpoint(String exceptionClass)
			throws NoResponseException, NotConnectedException {
		synchronized (getSyncObject()) {
			return fSession.setExceptionBreakpoint(exceptionClass);
		}
	}

	/* (non-Javadoc)
	 * @see flash.tools.debugger.Session#clearExceptionBreakpoint(String)
	 */
	@Override
	public boolean clearExceptionBreakpoint(String exceptionClass)
			throws NoResponseException, NotConnectedException {
		synchronized (getSyncObject()) {
			return fSession.clearExceptionBreakpoint(exceptionClass);
		}
	}

	@Override
	public void setLauncher(ILauncher launcher) {
		synchronized (getSyncObject()) {
			fSession.setLauncher(launcher);
		}
	}

}
