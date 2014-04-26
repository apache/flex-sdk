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

/**
 * Thread-safe wrapper for flash.tools.debugger.Value
 * @author Mike Morearty
 */
public class ThreadSafeValue extends ThreadSafeDebuggerObject implements Value {

	private Value fVal;

	private ThreadSafeValue(Object syncObj, Value val) {
		super(syncObj);
		fVal = val;
	}

	/**
	 * Wraps a Value inside a ThreadSafeValue.  If the passed-in Value
	 * is null, then this function returns null.
	 */
	public static ThreadSafeValue wrap(Object syncObj, Value val) {
		if (val != null)
			return new ThreadSafeValue(syncObj, val);
		else
			return null;
	}

	/**
	 * Wraps an array of Values inside an array of ThreadSafeValues.
	 */
	public static ThreadSafeValue[] wrapArray(Object syncObj, Value[] values) {
		ThreadSafeValue[] threadSafeValues = new ThreadSafeValue[values.length];
		for (int i=0; i<values.length; ++i) {
			threadSafeValues[i] = wrap(syncObj, values[i]);
		}
		return threadSafeValues;
	}

	/**
	 * Returns the raw Value underlying a ThreadSafeValue.
	 */
	public static Value getRaw(Value v) {
		if (v instanceof ThreadSafeValue)
			return ((ThreadSafeValue)v).fVal;
		else
			return v;
	}

	public static Object getSyncObject(Value v) {
		return ((ThreadSafeValue)v).getSyncObject();
	}
	
	@Override
	public boolean equals(Object other) {
		if (other instanceof Value)
			return fVal.equals(getRaw((Value)other));
		else
			return false;
	}

	public int getAttributes() {
		synchronized (getSyncObject()) { return fVal.getAttributes(); }
	}

	public String getClassName() {
		synchronized (getSyncObject()) { return fVal.getClassName(); }
	}

	public long getId() {
		synchronized (getSyncObject()) { return fVal.getId(); }
	}

	public int getMemberCount(Session s) throws NotSuspendedException, NoResponseException, NotConnectedException {
		synchronized (getSyncObject()) { return fVal.getMemberCount(ThreadSafeSession.getRaw(s)); }
	}

	public Variable getMemberNamed(Session s, String name) throws NotSuspendedException, NoResponseException, NotConnectedException {
		synchronized (getSyncObject()) {
			return ThreadSafeVariable.wrap(getSyncObject(), fVal.getMemberNamed(ThreadSafeSession.getRaw(s), name));
		}
	}

	public Variable[] getMembers(Session s) throws NotSuspendedException, NoResponseException, NotConnectedException {
		synchronized (getSyncObject()) {
			return ThreadSafeVariable.wrapArray(getSyncObject(), fVal.getMembers(ThreadSafeSession.getRaw(s)));
		}
	}

	public int getType() {
		synchronized (getSyncObject()) { return fVal.getType(); }
	}

	public String getTypeName() {
		synchronized (getSyncObject()) { return fVal.getTypeName(); }
	}

	public Object getValueAsObject() {
		synchronized (getSyncObject()) { return fVal.getValueAsObject(); }
	}

	public String getValueAsString() {
		synchronized (getSyncObject()) { return fVal.getValueAsString(); }
	}

	public boolean isAttributeSet(int variableAttribute) {
		synchronized (getSyncObject()) { return fVal.isAttributeSet(variableAttribute); }
	}

	public String[] getClassHierarchy(boolean allLevels) {
		synchronized (getSyncObject()) { return fVal.getClassHierarchy(allLevels); }
	}

	@Override
	public String toString() {
		synchronized (getSyncObject()) { return fVal.toString(); }
	}

	public Variable[] getPrivateInheritedMembers() {
		synchronized (getSyncObject()) {
			return ThreadSafeVariable.wrapArray(getSyncObject(), fVal.getPrivateInheritedMembers());
		}
	}

	public Variable[] getPrivateInheritedMemberNamed(String name) {
		synchronized (getSyncObject()) {
			return ThreadSafeVariable.wrapArray(getSyncObject(), fVal.getPrivateInheritedMemberNamed(name));
		}
	}

	@Override
	public int getIsolateId() {
		synchronized (getSyncObject()) {
			return fVal.getIsolateId();
		}
	}
}
