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
import flash.tools.debugger.IsolateSession;
import flash.tools.debugger.Location;
import flash.tools.debugger.NoResponseException;
import flash.tools.debugger.NotConnectedException;
import flash.tools.debugger.NotSupportedException;
import flash.tools.debugger.NotSuspendedException;
import flash.tools.debugger.PlayerDebugException;
import flash.tools.debugger.SuspendedException;
import flash.tools.debugger.SwfInfo;
import flash.tools.debugger.Value;
import flash.tools.debugger.Variable;
import flash.tools.debugger.VersionException;
import flash.tools.debugger.Watch;
import flash.tools.debugger.expression.PlayerFaultException;

/**
 * Thread-safe wrapper for flash.tools.debugger.IsolateSession
 * @author Anirudh Sasikumar
 */
public class ThreadSafeIsolateSession extends ThreadSafeDebuggerObject
		implements IsolateSession {

	private IsolateSession fSession;
	
	private ThreadSafeIsolateSession(Object syncObj, IsolateSession session) {
		super(syncObj);
		fSession = session;
	}
	
	/**
	 * Wraps a Value inside a ThreadSafeValue.  If the passed-in Value
	 * is null, then this function returns null.
	 */
	public static ThreadSafeIsolateSession wrap(Object syncObj, IsolateSession session) {
		if (session != null)
			return new ThreadSafeIsolateSession(syncObj, session);
		else
			return null;
	}

	@Override
	public void resume() throws NotSuspendedException, NotConnectedException,
			NoResponseException {
		synchronized (getSyncObject()) {
			fSession.resume();
		}		
	}

	@Override
	public void suspend() throws SuspendedException, NotConnectedException,
			NoResponseException {
		synchronized (getSyncObject()) {
			fSession.suspend();
		}
		
	}

	@Override
	public boolean isSuspended() throws NotConnectedException {
		synchronized (getSyncObject()) {
			return fSession.isSuspended();
		}
	}

	@Override
	public int suspendReason() throws NotConnectedException {
		synchronized (getSyncObject()) {
			return fSession.suspendReason();
		}
	}

	public void stepOver() throws NotSuspendedException, NoResponseException,
	NotConnectedException {
		synchronized (getSyncObject()) {
			fSession.stepOver();
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

	@Override
	public Frame[] getFrames() throws NotConnectedException {
		synchronized (getSyncObject()) {
			return ThreadSafeFrame.wrapArray(getSyncObject(), fSession.getFrames());
		}
	}
	
	@Override
	public boolean evalIs(Value value, Value type)
			throws PlayerDebugException, PlayerFaultException {
		synchronized (getSyncObject()) {
			return fSession.evalIs(value, type);
		}
	}

	@Override
	public boolean evalIs(Value value, String type)
			throws PlayerDebugException, PlayerFaultException {
		synchronized (getSyncObject()) {
			return fSession.evalIs(value, type);
		}
	}

	@Override
	public boolean evalInstanceof(Value value, Value type)
			throws PlayerDebugException, PlayerFaultException {
		synchronized (getSyncObject()) {
			return fSession.evalInstanceof(value, type);
		}
	}

	@Override
	public boolean evalInstanceof(Value value, String type)
			throws PlayerDebugException, PlayerFaultException {
		synchronized (getSyncObject()) {
			return fSession.evalInstanceof(value, type);
		}
	}

	@Override
	public boolean evalIn(Value property, Value object)
			throws PlayerDebugException, PlayerFaultException {
		synchronized (getSyncObject()) {
			return fSession.evalIn(property, object);
		}
	}

	@Override
	public Value evalAs(Value value, Value type)
			throws PlayerDebugException, PlayerFaultException {
		synchronized (getSyncObject()) {
			return ThreadSafeValue.wrap(getSyncObject(), fSession.evalAs(value, type));
		}
	}

	@Override
	public Value callConstructor(String classname, Value[] args) 
				throws PlayerDebugException {
		synchronized (getSyncObject()) {
			return ThreadSafeValue.wrap(getSyncObject(), fSession.callConstructor(classname, args));
		}
	}

	@Override
	public Watch[] getWatchList()
			throws NoResponseException, NotConnectedException {
		synchronized (getSyncObject()) {
			return ThreadSafeWatch.wrapArray(getSyncObject(), fSession.getWatchList());
		}
	}
	
	/** @deprecated */
	public Variable[] getVariableList() throws NotSuspendedException,
			NoResponseException, NotConnectedException, VersionException {
		synchronized (getSyncObject()) {
			return ThreadSafeVariable.wrapArray(getSyncObject(), fSession.getVariableList());
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
	
	public SwfInfo[] getSwfs() throws NoResponseException {
		synchronized (getSyncObject()) {
			return ThreadSafeSwfInfo.wrapArray(getSyncObject(), fSession.getSwfs());
		}
	}

	public Value getValue(long valueId) throws NotSuspendedException,
	NoResponseException, NotConnectedException
	{
		synchronized (getSyncObject()) {
			return ThreadSafeValue.wrap(getSyncObject(), fSession.getValue(valueId));
		}
	}

	public Location setBreakpoint(int fileId, int lineNum)
	throws NoResponseException, NotConnectedException {
		synchronized (getSyncObject()) {
			return ThreadSafeLocation.wrap(getSyncObject(), fSession.setBreakpoint(fileId, lineNum));
		}
	}

	@Override
	public boolean setExceptionBreakpoint(String exceptionClass)
			throws NoResponseException, NotConnectedException {
		synchronized (getSyncObject()) {
			return fSession.setExceptionBreakpoint(exceptionClass); 
		}
	}

	@Override
	public boolean clearExceptionBreakpoint(String exceptionClass)
			throws NoResponseException, NotConnectedException {
		synchronized (getSyncObject()) {
			return fSession.clearExceptionBreakpoint(exceptionClass); 
		}
	}

	@Override
	public void breakOnCaughtExceptions(boolean b)
			throws NotSupportedException, NoResponseException {
		synchronized (getSyncObject()) {
			fSession.breakOnCaughtExceptions(b); 
		}
	}

	@Override
	public boolean supportsWatchpoints() {
		synchronized (getSyncObject()) {
			return fSession.supportsWatchpoints(); 
		}
	}

	@Override
	public boolean playerCanBreakOnAllExceptions() {
		synchronized (getSyncObject()) {
			return fSession.playerCanBreakOnAllExceptions(); 
		}
	}

	@Override
	public boolean supportsWideLineNumbers() {
		synchronized (getSyncObject()) {
			return fSession.supportsWideLineNumbers();
		}
	}

	@Override
	public boolean playerCanCallFunctions() {
		synchronized (getSyncObject()) {
			return fSession.playerCanCallFunctions();
		}
	}
}
