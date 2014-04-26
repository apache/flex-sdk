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

package flash.tools.debugger.expression;

import flash.tools.debugger.Session;
import flash.tools.debugger.Value;

/**
 * An object which returns a value given a name and
 * appropriate context information.
 */
public interface Context
{
	/**
	 * Looks for an object of the given name in this context -- for example, a member variable.
	 *
	 * The returned Object can be of any type at all.  For example, it could be:
	 *
	 * <ul>
	 * <li> a <code>flash.tools.debugger.Variable</code> </li>
	 * <li> your own wrapper around <code>Variable</code> </li>
	 * <li> a <code>flash.tools.debugger.Value</code> </li>
	 * <li> any built-in Java primitive such as <code>Long</code>, <code>Integer</code>,
	 *      <code>Double</code>, <code>Boolean</code>, or <code>String</code> </li>
	 * <li> any other type you want which has a good <code>toString()</code>; see below </li>
	 * </ul>
	 *
	 * Since the return type is just Object, the returned value is only meaningful when
	 * passed to other functions this interface.  For example, the returned Object can be
	 * passed to createContext(), assign(), or toValue().
	 * 
	 * @param o the object to look up; most commonly a string representing the name of
	 * a member variable.
	 */
	public Object lookup(Object o) throws NoSuchVariableException, PlayerFaultException;

	/**
	 * Looks for the members of an object.
	 * 
	 * @param o
	 *            A variable whose members we want to look up
	 * @return Some object which represents the members; could even be just a
	 *         string. See lookup() for more information about the returned
	 *         type.
	 * @see #lookup(Object)
	 */
	public Object lookupMembers(Object o) throws NoSuchVariableException;

	/**
	 * Creates a new context object by combining the current one and o.
	 * For example, if the user typed "myVariable.myMember", then this function
	 * will get called with o equal to the object which represents "myVariable".
	 * This function should return a new context which, when called with
	 * lookup("myMember"), will return an object for that member.
	 *
	 * @param o any object which may have been returned by this class's lookup() function
	 */
	public Context createContext(Object o);

	/**
	 * Assign the object o, the value v.
	 * 
	 * @param o
	 *            a variable to assign to -- this should be some value returned
	 *            by an earlier call to lookup().
	 * @param v
	 *            a value, such as a Boolean, Long, String, etc.
	 */
	public void assign(Object o, Value v) throws NoSuchVariableException, PlayerFaultException;

	/**
	 * Enables/disables the creation of variables during lookup calls.
	 * This is ONLY used by AssignmentExp for creating a assigning a value 
	 * to a property which currently does not exist.
	 */
	public void createPseudoVariables(boolean oui);

	/**
	 * Converts the object to a Value.
	 * 
	 * @param o
	 *            Either object that was returned by an earlier call to
	 *            <code>lookup()</code>, or one of the raw types that can be
	 *            returned by <code>Value.getValueAsObject()</code>.
	 * @return the corresponding Value, or <code>null</code>.
	 * @see Value#getValueAsObject()
	 */
	public Value toValue(Object o);

	/**
	 * Converts the context to a Value. Very similar to
	 * <code>toValue(Object o)</code>, except that the object being converted
	 * is the object that was used to initialize this context.
	 * 
	 * @return the corresponding Value, or <code>null</code>.
	 */
	public Value toValue();

	/**
	 * Returns the session associated with this context, or null.
	 * This can legitimately be null; for example, in fdb, you are
	 * allowed to do things like "set $columnwidth = 120" before
	 * beginning a debugging session.
	 */
	public Session getSession();
	
	/**
	 * The worker id to which this context object belongs. 
	 */
	public int getIsolateId();
}
