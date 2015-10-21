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
package flash.tools.debugger;

import flash.tools.debugger.expression.PlayerFaultException;

/**
 * Worker specific debug session commands. These are a subset of Session that
 * can be individually routed to a specific worker (including the main worker if
 * the player does not support concurrency). This is implemented by
 * PlayerSession and used by the getWorkerSession() api.
 * 
 * @see flash.tools.debugger.IsolateSession,
 *      flash.tools.debugger.Session#getWorkerSession(int)
 */
public interface IsolateController {
	
	/**
	 * @see flash.tools.debugger.Session#resume()
	 */
	void resumeWorker(int isolateId) throws NotSuspendedException, NotConnectedException, NoResponseException;

	/**
	 * @see flash.tools.debugger.Session#suspend()
	 */
	void suspendWorker(int isolateId) throws SuspendedException, NotConnectedException, NoResponseException;
	
	/**
	 * @see flash.tools.debugger.Session#isSuspended()
	 */
	boolean isWorkerSuspended(int isolateId) throws NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#isSuspended()
	 */
	int suspendReasonWorker(int isolateId) throws NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#getFrames()
	 */
	Frame[] getFramesWorker(int isolateId) throws NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#stepInto()
	 */
	void stepIntoWorker(int isolateId) throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#stepOut()
	 */
	void stepOutWorker(int isolateId)  throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#stepOver()
	 */
	void stepOverWorker(int isolateId) throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#stepContinue()
	 */
	void stepContinueWorker(int isolateId) throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#getSwfs()
	 */
	SwfInfo[] getSwfsWorker(int isolateId) throws NoResponseException;
	
	/**
	 * @see flash.tools.debugger.Session#setBreakpoint(int, int)
	 */
	Location setBreakpointWorker(int fileId, int lineNum, int isolateId) throws NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#getWatchList()
	 */
	Watch[] getWatchListWorker(int isolateId) throws NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#getVariableList()
	 */
	Variable[] getVariableListWorker(int isolateId) throws NotSuspendedException, NoResponseException, NotConnectedException, VersionException;
	
	/**
	 * @see flash.tools.debugger.Session#getValue(long)
	 */
	Value getValueWorker(long valueId, int isolateId) throws NotSuspendedException, NoResponseException, NotConnectedException;

	/**
	 * @see flash.tools.debugger.Session#getGlobal(String)
	 */
	Value getGlobalWorker(String name, int isolateId) throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#evalIs(Value, Value)
	 */
	boolean evalIsWorker(Value value, Value type, int isolateId) throws PlayerDebugException, PlayerFaultException;

	/**
	 * @see flash.tools.debugger.Session#evalIs(Value, String)
	 */
	boolean evalIsWorker(Value value, String type, int isolateId) throws PlayerDebugException, PlayerFaultException;

	/**
	 * @see flash.tools.debugger.Session#evalInstanceof(Value, Value)
	 */
	boolean evalInstanceofWorker(Value value, Value type, int isolateId) throws PlayerDebugException, PlayerFaultException;

	/**
	 * @see flash.tools.debugger.Session#evalInstanceof(Value, String)
	 */
	boolean evalInstanceofWorker(Value value, String type, int isolateId) throws PlayerDebugException, PlayerFaultException;

	/**
	 * @see flash.tools.debugger.Session#evalIn(Value, Value)
	 */
	boolean evalInWorker(Value property, Value object, int isolateId) throws PlayerDebugException, PlayerFaultException;

	/**
	 * @see flash.tools.debugger.Session#evalAs(Value, Value)
	 */
	Value evalAsWorker(Value value, Value type, int isolateId) throws PlayerDebugException, PlayerFaultException;
	
	/**
	 * @see flash.tools.debugger.Session#callFunction(Value, String, Value[])
	 */
	Value callFunctionWorker(Value thisObject, String functionName, Value[] args, int isolateId) throws PlayerDebugException;
	
	/**
	 * @see flash.tools.debugger.Session#callConstructor(String, Value[])
	 */
	Value callConstructorWorker(String classname, Value[] args, int isolateId) throws PlayerDebugException;

	/**
	 * @see flash.tools.debugger.Session#setExceptionBreakpoint(String)
	 */
	boolean setExceptionBreakpointWorker(String exceptionClass, int isolateId) throws NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#clearExceptionBreakpoint(String)
	 */
	boolean clearExceptionBreakpointWorker(String exceptionClass, int isolateId) throws NoResponseException, NotConnectedException;

	/**
	 * @see flash.tools.debugger.Session#breakOnCaughtExceptions(boolean)
	 */
	void breakOnCaughtExceptions(boolean b, int isolateId) throws NotSupportedException, NoResponseException;
	
	/**
	 * @see flash.tools.debugger.Session#supportsWatchpoints()
	 */
	boolean supportsWatchpoints(int isolateId);
	
	/**
	 * @see flash.tools.debugger.Session#playerCanBreakOnAllExceptions()
	 */
	boolean playerCanBreakOnAllExceptions(int isolateId);
	
	/**
	 * @see flash.tools.debugger.Session#supportsWideLineNumbers()
	 */
	boolean supportsWideLineNumbers(int isolateId);
	
	/**
	 * @see flash.tools.debugger.Session#playerCanCallFunctions(String)
	 */
	boolean playerCanCallFunctions(int isolateId);
	
}
