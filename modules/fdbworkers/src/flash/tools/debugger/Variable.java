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

import flash.tools.debugger.events.FaultEvent;

/**
 * A Variable is any ActionScript variable, such as a String, Number, etc.
 * It encapsulates the concept of a type and a value.
 */
public interface Variable
{
	/**
	 * The name of the variable.
	 */
	public String		getName();

	/**
	 * The fully qualified name of the variable, i.e. "namespace::name"
	 * if there is a namespace, or just "name" if not.
	 */
	public String		getQualifiedName();

	/**
	 * The namespace of the variable.  This is everything before the
	 * "::".  For example:
	 * 
	 * <ul>
	 * <li> If a variable was declared "private var x", then the
	 *      namespace is "ClassName$3", where "3" might be
	 *      any number. </li>
	 * <li> If a variable was declared within a namespace, e.g.
	 *      "mynamespace var x", then the namespace might be
	 *      "http://blahblah::x", where "http://blahblah" is the URL
	 *      of the namespace.
	 * <li> If a variable was declared neither public nor private
	 *      (and is therefore "internal"), and it is inside of a
	 *      package, then the namespace might be
	 *      "packagename". </li>
	 * </ul>
	 * 
	 * @return namespace or "", never <code>null</code>
	 */
	public String		getNamespace();

	/**
	 * Returns just the scope bits of the attributes. The scope values from
	 * VariableAttribute (PUBLIC_SCOPE etc.) are NOT bitfields, so the returned
	 * value can be compared directly to VariableAttribute.PUBLIC_SCOPE, etc.
	 * using "==".
	 * 
	 * @see VariableAttribute
	 */
	public int			getScope();

	/**
	 * For a member variable of an instance of some class, its "level" indicates
	 * how far up the class hierarchy it is from the actual class of the instance.
	 * For example, suppose you have this code:
	 * 
	 * <pre>
	 *    class A           { int a }
	 *    class B extends A { int b }
	 *    class C extends B { int c }
	 *    var myObject: C
	 * </pre>
	 * 
	 * In this case, for <code>myObject</code>, the "level" of variable <code>c</code>
	 * is 0; the level of <code>b</code> is 1; and the level of <code>a</code> is 2.
	 */
	public int			getLevel();

	/**
	 * The class in which this member was actually defined.  For example, if class
	 * B extends class A, and class A has member variable V, then for variable
	 * V, the defining class is always "A", even though the parent variable might
	 * be an instance of class B.
	 */
	public String		getDefiningClass();

	/**
	 * Variable attributes define further information 
	 * regarding the variable.  They are bitfields identified
	 * as VariableAttribute.xxx
	 * 
	 * @see VariableAttribute
	 */
	public int			getAttributes();

	/**
	 * @see VariableAttribute
	 */
	public boolean		isAttributeSet(int variableAttribute);

	/**
	 * Returns the value of the variable.
	 */
	public Value		getValue();

	/**
	 * Returns whether the value of the variable has changed since the last
	 * time the program was suspended.  If the previous value of the
	 * variable is unknown, this function will return <code>false</code>.
	 */
	public boolean		hasValueChanged(Session s);

	/**
	 * Changes the value of a variable. New members cannot be added to a Variable,
	 * only the value of existing scalar members can be modified.
	 * 
	 * @param type
	 *            the type of the member which is being set. Use
	 *            VariableType.UNDEFINED in order to set the variable to an
	 *            undefined state; the contents of 'value' will be ignored.
	 * @param value
	 *            the string value of the member. May be 'true' or 'false' for
	 *            Boolean types or any valid number for Number types.
	 * @return null, if set was successful; or a FaultEvent if a setter was
	 *         invoked and the setter threw an exception. In that case, look at
	 *         FaultEvent.information to see the error text of the exception
	 *         that occurred.
	 * @throws NoResponseException
	 *             if times out
	 * @throws NotSuspendedException
	 *             if Player is running
	 * @throws NotConnectedException
	 *             if Player is disconnected from Session
	 */
	public FaultEvent setValue(Session s, int type, String value) throws NotSuspendedException, NoResponseException, NotConnectedException;

	/**
	 * @return True if this variable has a getter, and the getter has not yet been invoked.
	 */
	public boolean needsToInvokeGetter();

	/**
	 * Executes the getter for this variable, and changes its value accordingly.  Note that
	 * the <code>HAS_GETTER</code> flag is not affected by this call -- even after this
	 * call, <code>HAS_GETTER</code> will still be true.  If you want to test whether the
	 * getter has already been executed, call <code>needsToInvokeGetter()</code>.
	 * <p>
	 * Has no effect if <code>needsToInvokeGetter()</code> is false.
	 * 
	 * @throws NotSuspendedException
	 * @throws NoResponseException
	 * @throws NotConnectedException
	 */
	public void invokeGetter(Session s) throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * Get the worker id of the isolate to which this value belongs.
	 */
	public int getIsolateId();
}
