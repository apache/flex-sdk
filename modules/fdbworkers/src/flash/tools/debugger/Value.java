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

import flash.tools.debugger.concrete.DVariable;

/**
 * An ActionScript value, for example, the value of a variable or constant.
 * 
 * @author mmorearty
 */
public interface Value
{
	/**
	 * A special object representing ActionScript's "undefined" value.
	 */
	public static final Object UNDEFINED = new Object() {
		@Override
		public String toString() {
			return "undefined";  //$NON-NLS-1$
		}
	};

	/**
	 * The value returned if somone calls getId() for a Variable
	 * which stores a variable of simple type such as String or
	 * integer, rather than an Object or MovieClip.
	 * @see getId()
	 */
	public static final long UNKNOWN_ID							= -1;

	/**
	 * The special ID for pseudo-variable "_global".  (Note, this only
	 * exists in AS2, not AS3.)
	 * @see getId()
	 */
	public static final long GLOBAL_ID							= -2;

	/**
	 * The special ID for pseudo-variable "this".
	 * @see getId()
	 */
	public static final long THIS_ID							= -3;

	/**
	 * The special ID for pseudo-variable "_root".  (Note, this only
	 * exists in AS2, not AS3.)
	 * @see getId()
	 */
	public static final long ROOT_ID							= -4;

	/**
	 * The special ID for the top frame of the stack.  Locals and
	 * arguments are "members" of this pseudo-variable.
	 * 
	 * All the stack frames have IDs counting down from here.  For example,
	 * the top stack frame has ID <code>BASE_ID</code>; the next
	 * stack frame has ID <code>BASE_ID - 1</code>; and so on.
	 * 
	 * @see getId()
	 */
	public static final long BASE_ID							= -100;

	/**
	 * _level0 == LEVEL_ID, _level1 == LEVEL_ID-1, ...
	 * 
	 * all IDs below this line are dynamic.
	 */
	public static final long LEVEL_ID							= -300;

	/**
	 * The return value of getTypeName() if this value represents the traits of a class.
	 */
	public static final String TRAITS_TYPE_NAME					= "traits"; //$NON-NLS-1$

	/**
	 * Variable type can be one of VariableType.OBJECT,
	 * VariableType.FUNCTION, VariableType.NUMBER, VariableType.STRING,
	 * VariableType.UNDEFINED, VariableType.NULL.
	 */
	public int			getType();

	/**
	 * The type name of the value:
	 * 
	 * <ul>
	 * <li> <code>"Number"</code> </li>
	 * <li> <code>"Boolean"</code> </li>
	 * <li> <code>"String"</code> </li>
	 * <li> <code>"null"</code> </li>
	 * <li> <code>"undefined"</code> </li>
	 * <li> <code>Value.TRAITS_TYPE_NAME</code> if this value represents the
	 * traits of a class </li>
	 * <li> <code>"[package::]Classname@hexaddr"</code> if this value
	 * represents an instance of a non-primitive object. For example, if this is
	 * an instance of mx.core.Application, the type name might be
	 * "mx.core::Application@1234abcd". </li>
	 * </ul>
	 */
	public String		getTypeName();

	/**
	 * The class name of the value. This isn't actually very useful, and should
	 * probably go away; it had more relevant in ActionScript 2, when the return
	 * value from this function could have been any one of the strings returned
	 * by {@link DVariable#classNameFor(long, boolean)}.
	 * 
	 * In the AS3 world, the only possible return values from this function are:
	 * 
	 * <ul>
	 * <li> <code>"Object"</code> for instances of non-primitive classes such
	 * as Object, Array, etc. </li>
	 * <li> <code>""</code> all primitive values (Number, Boolean, String,
	 * null, undefined), or the traits of a class. </li>
	 * </ul>
	 */
	public String		getClassName();

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
	 * Returns a unique ID for the object referred to by this variable.
	 * If two variables point to the same underlying object, their
	 * getId() functions will return the same value.
	 * 
	 * This is only meaningful for variables that store an Object or
	 * MovieClip.  For other types of variables (e.g. integers and
	 * strings), this returns <code>UNKNOWN_ID</code>.
	 */
	public long			getId();

	/**
	 * Returns the value of the variable, as an Object.  The return
	 * value will always be one of the following:
	 * 
	 * <ul>
	 * <li> <code>null</code> </li>
	 * <li> <code>Value.UNDEFINED</code> </li>
	 * <li> a <code>Boolean</code> </li>
	 * <li> a <code>Double</code> (careful, it might be <code>Double.NaN</code>) </li>
	 * <li> a <code>String</code> </li>
	 * <li> a <code>Long</code> if this value represents a non-primitive
	 * type, such as an Object.  If it is a Long, then it is the id of
	 * the Value (the same value returned by <code>getId()</code>).
	 * </ul>
	 */
	public Object		getValueAsObject();

	/**
	 * Returns the value of the variable, converted to a string.  Strings
	 * are returned as the exact value of the string itself, with no
	 * extra quotation marks and no escaping of characters within the
	 * string.
	 */
	public String		getValueAsString();

	/**
	 * Returns all child members of this variable.  Can only be called for
	 * variables of type Object or MovieClip.
	 * @throws NotConnectedException 
	 * @throws NoResponseException 
	 * @throws NotSuspendedException 
	 */
	public Variable[]	getMembers(Session s) throws NotSuspendedException, NoResponseException, NotConnectedException;

	/**
	 * Returns a specific child member of this variable.  Can only be called for
	 * variables of type <code>Object<code> or <code>MovieClip<code>.
	 * @param s the session
	 * @param name just a varname name, without its namespace (see <code>getName()</code>)
	 * @return the specified child member, or null if there is no such child.
	 * @throws NotConnectedException 
	 * @throws NoResponseException 
	 * @throws NotSuspendedException 
	 */
	public Variable     getMemberNamed(Session s, String name) throws NotSuspendedException, NoResponseException, NotConnectedException;

	/**
	 * Returns the number of child members of this variable.  If called for
	 * a variable which has a simple type such as integer or string,
	 * returns zero.
	 * @throws NotConnectedException 
	 * @throws NoResponseException 
	 * @throws NotSuspendedException 
	 */
	public int			getMemberCount(Session s) throws NotSuspendedException, NoResponseException, NotConnectedException;

	/**
	 * Returns the list of classes that contributed members to this object, from
	 * the class itself all the way down to <code>Object</code> (or, if
	 * allLevels == false, down to the lowest-level class that actually
	 * contributed members).
	 * 
	 * @param allLevels
	 *            if <code>true</code>, the caller wants the entire class
	 *            hierarchy. If <code>false</code>, the caller wants only
	 *            that portion of the class hierarchy that actually contributed
	 *            member variables to the object. For example,
	 *            <code>Object</code> has no members, so if the caller passes
	 *            <code>true</code> then the returned array of strings will
	 *            always end with <code>Object</code>, but if the caller
	 *            passes <code>false</code> then the returned array of strings
	 *            will <em>never</em> end with <code>Object</code>.
	 * @return an array of fully qualified class names.
	 */
	public String[]		getClassHierarchy(boolean allLevels);
	
	/**
	 * Returns all child members of this variable that are private and are present 
	 * in its inheritance chain. Only relevant after a call to getMembers().
	 * 
	 * Warning: This may contain variables with the same name (when there is more
	 * than two level inheritance).
	 */
	public Variable[]	getPrivateInheritedMembers();
	
	/**
	 * Get all the private variables with the given name. Usually one, but more
	 * may be present if the inheritance chain is long.
	 * @param name Variable name.
	 */
	public Variable[] getPrivateInheritedMemberNamed(String name);
	
	/**
	 * Get the worker id of the isolate to which this value belongs.
	 */
	public int getIsolateId();
}
