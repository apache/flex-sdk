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
 * Used to issue commands to a particular worker (isolate).
 * @see Session
 */
public interface IsolateSession {
	
	/**
	 * @see flash.tools.debugger.Session#resume()
	 */
	void resume() throws NotSuspendedException, NotConnectedException, NoResponseException;
	
	/**
	 * @see flash.tools.debugger.Session#suspend()
	 */
	void suspend() throws SuspendedException, NotConnectedException, NoResponseException;
	
	/**
	 * @see flash.tools.debugger.Session#isSuspended()
	 */
	boolean isSuspended() throws NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#isSuspended()
	 */
	int suspendReason() throws NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#getFrames()
	 */
	Frame[] getFrames() throws NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#stepInto()
	 */
	void stepInto() throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#stepOut()
	 */
	void stepOut()  throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#stepOver()
	 */
	void stepOver() throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#stepContinue()
	 */
	void stepContinue() throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#getSwfs()
	 */
	SwfInfo[] getSwfs() throws NoResponseException;
	
	/**
	 * @see flash.tools.debugger.Session#setBreakpoint(int, int)
	 */
	Location setBreakpoint(int fileId, int lineNum) throws NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#getWatchList()
	 */
	Watch[] getWatchList() throws NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#getVariableList()
	 */
	Variable[] getVariableList() throws NotSuspendedException, NoResponseException, NotConnectedException, VersionException;
	
	/**
	 * @see flash.tools.debugger.Session#getValue(long)
	 */
	Value getValue(long valueId) throws NotSuspendedException, NoResponseException, NotConnectedException;

	/**
	 * @see flash.tools.debugger.Session#getGlobal(String)
	 */
	Value getGlobal(String name) throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#evalIs(Value, Value)
	 */
	boolean evalIs(Value value, Value type) throws PlayerDebugException, PlayerFaultException;

	/**
	 * @see flash.tools.debugger.Session#evalIs(Value, String)
	 */
	boolean evalIs(Value value, String type) throws PlayerDebugException, PlayerFaultException;

	/**
	 * @see flash.tools.debugger.Session#evalInstanceof(Value, Value)
	 */
	boolean evalInstanceof(Value value, Value type) throws PlayerDebugException, PlayerFaultException;

	/**
	 * @see flash.tools.debugger.Session#evalInstanceof(Value, String)
	 */
	boolean evalInstanceof(Value value, String type) throws PlayerDebugException, PlayerFaultException;

	/**
	 * @see flash.tools.debugger.Session#evalIn(Value, Value)
	 */
	boolean evalIn(Value property, Value object) throws PlayerDebugException, PlayerFaultException;

	/**
	 * @see flash.tools.debugger.Session#evalAs(Value, Value)
	 */
	Value evalAs(Value value, Value type) throws PlayerDebugException, PlayerFaultException;
	
	/**
	 * @see flash.tools.debugger.Session#resume()
	 */
	Value callFunction(Value thisObject, String functionName, Value[] args) throws PlayerDebugException;
	
	/**
	 * @see flash.tools.debugger.Session#callFunction(Value, String, Value[])
	 */
	Value callConstructor(String classname, Value[] args) throws PlayerDebugException;
	
	/**
	 * @see flash.tools.debugger.Session#setExceptionBreakpoint(String)
	 */
	boolean setExceptionBreakpoint(String exceptionClass) throws NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#clearExceptionBreakpoint(String)
	 */
	boolean clearExceptionBreakpoint(String exceptionClass) throws NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#breakOnCaughtExceptions(boolean)
	 */
	void breakOnCaughtExceptions(boolean b) throws NotSupportedException, NoResponseException;

	/**
	 * @see flash.tools.debugger.Session#supportsWatchpoints()
	 */
	boolean supportsWatchpoints();
	
	/**
	 * @see flash.tools.debugger.Session#playerCanBreakOnAllExceptions()
	 */
	boolean playerCanBreakOnAllExceptions();
	
	/**
	 * @see flash.tools.debugger.Session#supportsWideLineNumbers()
	 */
	boolean supportsWideLineNumbers();
	
	/**
	 * @see flash.tools.debugger.Session#playerCanCallFunctions()
	 */
	boolean playerCanCallFunctions();
}
