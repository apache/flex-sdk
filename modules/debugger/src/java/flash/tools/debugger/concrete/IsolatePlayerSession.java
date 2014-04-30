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
package flash.tools.debugger.concrete;

import flash.tools.debugger.Frame;
import flash.tools.debugger.IsolateController;
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
 * Concrete implementation of IsolateSession. Re-routes
 * calls to the *worker() method equivalents.
 * @author anirudhs
 *
 */
public class IsolatePlayerSession implements IsolateSession {

	private IsolateController fSession;
	private int fIsolateId;
	
	public IsolatePlayerSession(int isolateId, IsolateController mainSession) {
		fIsolateId = isolateId;
		fSession = mainSession;
	}
	
	@Override
	public void resume() throws NotSuspendedException, NotConnectedException,
			NoResponseException {
		fSession.resumeWorker(fIsolateId);
	}

	@Override
	public void suspend() throws SuspendedException, NotConnectedException,
			NoResponseException {
		fSession.suspendWorker(fIsolateId);
	}

	@Override
	public boolean isSuspended() throws NotConnectedException {
		return fSession.isWorkerSuspended(fIsolateId);
	}

	@Override
	public int suspendReason() throws NotConnectedException {
		return fSession.suspendReasonWorker(fIsolateId);
	}

	@Override
	public Frame[] getFrames() throws NotConnectedException {
		return fSession.getFramesWorker(fIsolateId);
	}

	@Override
	public void stepInto() throws NotSuspendedException, NoResponseException,
			NotConnectedException {
		fSession.stepIntoWorker(fIsolateId);
	}

	@Override
	public void stepOut() throws NotSuspendedException, NoResponseException,
			NotConnectedException {
		fSession.stepOutWorker(fIsolateId);
	}

	@Override
	public void stepOver() throws NotSuspendedException, NoResponseException,
			NotConnectedException {
		fSession.stepOverWorker(fIsolateId);
	}

	@Override
	public void stepContinue() throws NotSuspendedException,
			NoResponseException, NotConnectedException {
		fSession.stepContinueWorker(fIsolateId);
	}

	@Override
	public SwfInfo[] getSwfs() throws NoResponseException {
		return fSession.getSwfsWorker(fIsolateId);
	}

	@Override
	public Location setBreakpoint(int fileId, int lineNum)
			throws NoResponseException, NotConnectedException {
		return fSession.setBreakpointWorker(fileId, lineNum, fIsolateId);
	}

	@Override
	public Watch[] getWatchList() throws NoResponseException,
			NotConnectedException {
		return fSession.getWatchListWorker(fIsolateId);
	}

	@Override
	public Variable[] getVariableList() throws NotSuspendedException,
			NoResponseException, NotConnectedException, VersionException {
		return fSession.getVariableListWorker(fIsolateId);
	}

	@Override
	public Value getValue(long valueId) throws NotSuspendedException,
			NoResponseException, NotConnectedException {
		return fSession.getValueWorker(valueId, fIsolateId);
	}

	@Override
	public Value getGlobal(String name) throws NotSuspendedException,
			NoResponseException, NotConnectedException {
		return fSession.getGlobalWorker(name, fIsolateId);
	}

	@Override
	public boolean evalIs(Value value, Value type) throws PlayerDebugException,
			PlayerFaultException {
		return fSession.evalIsWorker(value, type, fIsolateId);
	}

	@Override
	public boolean evalIs(Value value, String type)
			throws PlayerDebugException, PlayerFaultException {
		return fSession.evalIsWorker(value, type, fIsolateId);
	}

	@Override
	public boolean evalInstanceof(Value value, Value type)
			throws PlayerDebugException, PlayerFaultException {
		return fSession.evalInstanceofWorker(value, type, fIsolateId);
	}

	@Override
	public boolean evalInstanceof(Value value, String type)
			throws PlayerDebugException, PlayerFaultException {
		return fSession.evalInstanceofWorker(value, type, fIsolateId);
	}

	@Override
	public boolean evalIn(Value property, Value object)
			throws PlayerDebugException, PlayerFaultException {
		return fSession.evalInWorker(property, object, fIsolateId);
	}

	@Override
	public Value evalAs(Value value, Value type) throws PlayerDebugException,
			PlayerFaultException {
		return fSession.evalAsWorker(value, type, fIsolateId);
	}

	@Override
	public Value callFunction(Value thisObject, String functionName,
			Value[] args) throws PlayerDebugException {
		return fSession.callFunctionWorker(thisObject, functionName, args, fIsolateId);
	}

	@Override
	public Value callConstructor(String classname, Value[] args)
			throws PlayerDebugException {
		return fSession.callConstructorWorker(classname, args, fIsolateId);
	}
	
	@Override
	public boolean setExceptionBreakpoint(String exceptionClass) throws NoResponseException, NotConnectedException {
		return fSession.setExceptionBreakpointWorker(exceptionClass, fIsolateId);
	}

	@Override
	public boolean clearExceptionBreakpoint(String exceptionClass) throws NoResponseException, NotConnectedException {
		return fSession.clearExceptionBreakpointWorker(exceptionClass, fIsolateId);
	}

	@Override
	public void breakOnCaughtExceptions(boolean b) throws NotSupportedException, NoResponseException {
		fSession.breakOnCaughtExceptions(b, fIsolateId);
	}

	@Override
	public boolean supportsWatchpoints() {
		return fSession.supportsWatchpoints(fIsolateId);
	}

	@Override
	public boolean playerCanBreakOnAllExceptions() {
		return fSession.playerCanBreakOnAllExceptions(fIsolateId);
	}

	@Override
	public boolean supportsWideLineNumbers() {
		return fSession.supportsWideLineNumbers(fIsolateId);
	}

	@Override
	public boolean playerCanCallFunctions() {
		return fSession.playerCanCallFunctions(fIsolateId);
	}

}
