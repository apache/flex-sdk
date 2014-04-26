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

import flash.tools.debugger.NoResponseException;
import flash.tools.debugger.NotConnectedException;
import flash.tools.debugger.NotSuspendedException;
import flash.tools.debugger.Session;
import flash.tools.debugger.Value;
import flash.tools.debugger.Variable;
import flash.tools.debugger.events.FaultEvent;

/**
 * Thread-safe wrapper for flash.tools.debugger.Variable
 * @author Mike Morearty
 */
public class ThreadSafeVariable extends ThreadSafeDebuggerObject implements Variable {

	private Variable fVar;

	private ThreadSafeVariable(Object syncObj, Variable var) {
		super(syncObj);
		fVar = var;
	}

	/**
	 * Wraps a Variable inside a ThreadSafeVariable.  If the passed-in Variable
	 * is null, then this function returns null.
	 */
	public static ThreadSafeVariable wrap(Object syncObj, Variable variable) {
		if (variable != null)
			return new ThreadSafeVariable(syncObj, variable);
		else
			return null;
	}

	/**
	 * Wraps an array of Variables inside an array of ThreadSafeVariables.
	 */
	public static ThreadSafeVariable[] wrapArray(Object syncObj, Variable[] variables) {
		ThreadSafeVariable[] threadSafeVariables = new ThreadSafeVariable[variables.length];
		for (int i=0; i<variables.length; ++i) {
			threadSafeVariables[i] = wrap(syncObj, variables[i]);
		}
		return threadSafeVariables;
	}

	/**
	 * Returns the raw Variable underlying a ThreadSafeVariable.
	 */
	public static Variable getRaw(Variable v) {
		if (v instanceof ThreadSafeVariable)
			return ((ThreadSafeVariable)v).fVar;
		else
			return v;
	}

	public static Object getSyncObject(Variable v) {
		return ((ThreadSafeVariable)v).getSyncObject();
	}

	public String getName() {
		synchronized (getSyncObject()) { return fVar.getName(); }
	}

	public int getAttributes() {
		synchronized (getSyncObject()) { return fVar.getAttributes(); }
	}

	public boolean isAttributeSet(int variableAttribute) {
		synchronized (getSyncObject()) { return fVar.isAttributeSet(variableAttribute); }
	}

	public Value getValue() {
		synchronized (getSyncObject()) {
			return ThreadSafeValue.wrap(getSyncObject(), fVar.getValue());
		}
	}

	public boolean hasValueChanged(Session s) {
		synchronized (getSyncObject()) {
			return fVar.hasValueChanged(ThreadSafeSession.getRaw(s));
		}
	}

	public boolean needsToInvokeGetter() {
		synchronized (getSyncObject()) { return fVar.needsToInvokeGetter(); }
	}

	public void invokeGetter(Session s) throws NotSuspendedException, NoResponseException, NotConnectedException {
		synchronized (getSyncObject()) { fVar.invokeGetter(ThreadSafeSession.getRaw(s)); }
	}

	public String getQualifiedName() {
		synchronized (getSyncObject()) { return fVar.getQualifiedName(); }
	}

	public String getNamespace() {
		synchronized (getSyncObject()) { return fVar.getNamespace(); }
	}
	
	public int getScope() {
		synchronized (getSyncObject()) { return fVar.getScope(); }
	}

	public FaultEvent setValue(Session s, int type, String value) throws NotSuspendedException, NoResponseException, NotConnectedException {
		synchronized (getSyncObject()) { return fVar.setValue(ThreadSafeSession.getRaw(s), type, value); }
	}

	public String getDefiningClass() {
		synchronized (getSyncObject()) { return fVar.getDefiningClass(); }
	}

	public int getLevel() {
		synchronized (getSyncObject()) { return fVar.getLevel(); }
	}

	@Override
	public String toString() {
		synchronized (getSyncObject()) { return fVar.toString(); }
	}

	@Override
	public int getIsolateId() {
		synchronized (getSyncObject()) { return fVar.getIsolateId(); }
	}
}
