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
 * @author anirudhs
 */
public interface IsolateSession {
	
	/**
	 * @see flash.tools.debugger.Session#resume()
	 */
	public void resume() throws NotSuspendedException, NotConnectedException, NoResponseException;
	
	/**
	 * @see flash.tools.debugger.Session#suspend()
	 */
	public void suspend() throws SuspendedException, NotConnectedException, NoResponseException;
	
	/**
	 * @see flash.tools.debugger.Session#isSuspended()
	 */
	public boolean isSuspended() throws NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#isSuspended()
	 */
	public int suspendReason() throws NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#getFrames()
	 */
	public Frame[] getFrames() throws NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#stepInto()
	 */
	public void stepInto() throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#stepOut()
	 */
	public void stepOut()  throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#stepOver()
	 */
	public void stepOver() throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#stepContinue()
	 */
	public void stepContinue() throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#getSwfs()
	 */
	public SwfInfo[] getSwfs() throws NoResponseException;
	
	/**
	 * @see flash.tools.debugger.Session#setBreakpoint(int, int)
	 */
	public Location setBreakpoint(int fileId, int lineNum) throws NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#getWatchList()
	 */
	public Watch[] getWatchList() throws NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#getVariableList()
	 */
	public Variable[] getVariableList() throws NotSuspendedException, NoResponseException, NotConnectedException, VersionException;
	
	/**
	 * @see flash.tools.debugger.Session#getValue(long)
	 */
	public Value getValue(long valueId) throws NotSuspendedException, NoResponseException, NotConnectedException;

	/**
	 * @see flash.tools.debugger.Session#getGlobal(String)
	 */
	public Value getGlobal(String name) throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#evalIs(Value, Value)
	 */
	public boolean evalIs(Value value, Value type) throws PlayerDebugException, PlayerFaultException;

	/**
	 * @see flash.tools.debugger.Session#evalIs(Value, String)
	 */
	public boolean evalIs(Value value, String type) throws PlayerDebugException, PlayerFaultException;

	/**
	 * @see flash.tools.debugger.Session#evalInstanceof(Value, Value)
	 */
	public boolean evalInstanceof(Value value, Value type) throws PlayerDebugException, PlayerFaultException;

	/**
	 * @see flash.tools.debugger.Session#evalInstanceof(Value, String)
	 */
	public boolean evalInstanceof(Value value, String type) throws PlayerDebugException, PlayerFaultException;

	/**
	 * @see flash.tools.debugger.Session#evalIn(Value, Value)
	 */
	public boolean evalIn(Value property, Value object) throws PlayerDebugException, PlayerFaultException;

	/**
	 * @see flash.tools.debugger.Session#evalAs(Value, Value)
	 */
	public Value evalAs(Value value, Value type) throws PlayerDebugException, PlayerFaultException;
	
	/**
	 * @see flash.tools.debugger.Session#resume()
	 */
	public Value callFunction(Value thisObject, String functionName, Value[] args) throws PlayerDebugException;
	
	/**
	 * @see flash.tools.debugger.Session#callFunction(Value, String, Value[])
	 */
	public Value callConstructor(String classname, Value[] args) throws PlayerDebugException;
	
	/**
	 * @see flash.tools.debugger.Session#setExceptionBreakpoint(String)
	 */
	public boolean setExceptionBreakpoint(String exceptionClass) throws NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#clearExceptionBreakpoint(String)
	 */
	public boolean clearExceptionBreakpoint(String exceptionClass) throws NoResponseException, NotConnectedException;
	
	/**
	 * @see flash.tools.debugger.Session#breakOnCaughtExceptions(boolean)
	 */
	public void breakOnCaughtExceptions(boolean b) throws NotSupportedException, NoResponseException;

	/**
	 * @see flash.tools.debugger.Session#supportsWatchpoints()
	 */
	public boolean supportsWatchpoints();
	
	/**
	 * @see flash.tools.debugger.Session#playerCanBreakOnAllExceptions()
	 */
	public boolean playerCanBreakOnAllExceptions();
	
	/**
	 * @see flash.tools.debugger.Session#supportsWideLineNumbers()
	 */
	public boolean supportsWideLineNumbers();
	
	/**
	 * @see flash.tools.debugger.Session#playerCanCallFunctions()
	 */
	public boolean playerCanCallFunctions();
}
