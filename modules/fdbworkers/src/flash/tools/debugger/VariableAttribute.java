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

/**
 * Specific attributes which further qualify a Variable. The values in the low
 * 16 bits correspond to the enumeration fields defined in the player's
 * "splay.h" file, e.g. <code>kDontEnumerate</code> etc. The values from the
 * high 16 bits correspond to <code>enum InVariableFlags</code> from
 * playerdebugger.h, e.g. <code>kIsArgument</code> etc.
 */
public interface VariableAttribute
{
	/**
	 * Indicates that this member is invisible to an enumeration
	 * of its parent.
	 */
	public static final int DONT_ENUMERATE			= 0x00000001;

	/**
	 * Indicates that a variable is read-only.
	 */
	public static final int READ_ONLY				= 0x00000004;

	/**
	 * Indicates that a variable is a local.
	 */
	public static final int IS_LOCAL 				= 0x00000020;

	/**
	 * Indicates that a variable is an argument to a function.
	 */
	public static final int IS_ARGUMENT				= 0x00010000;

	/**
	 * Indicates that a variable is "dynamic" -- that is, whether it
	 * is a dynamic property of a class declared with keyword "dynamic".
	 * Note, this attribute only works with AS3 and above.
	 */
	public static final int IS_DYNAMIC				= 0x00020000;

	// 0x00040000 is reserved for IS_EXCEPTION, which is now part of
	// ValueAttribute rather than VariableAttribute.

	/**
	 * Indicates that a variable has a getter.
	 */
	public static final int HAS_GETTER				= 0x00080000;

	/**
	 * Indicates that a variable has a setter.
	 */
	public static final int HAS_SETTER				= 0x00100000;

	/**
	 * Indicates that a variable is a static member of its parent.
	 */
	public static final int IS_STATIC				= 0x00200000;

	/**
	 * Indicates that a variable was declared "const". READ_ONLY, on the other
	 * hand, applies both to "const" variables and also to various other types
	 * of objects. IS_CONST implies READ_ONLY; READ_ONLY does not imply
	 * IS_CONST.
	 */
	public static final int IS_CONST				= 0x00400000;

	/**
	 * Indicates that a variable is a public member of its parent.
	 *
	 * Note: the scope attributes are not bitfields.  To determine the scope
	 * of a variable, use variable.getScope() and compare the result to the
	 * various *_SCOPE values using ==.  For example:
	 *
	 * <pre>
	 * 		if (myVar.getScope() == VariableAttribute.PUBLIC_SCOPE) ...
	 * </pre>
	 */
	public static final int PUBLIC_SCOPE			= 0x00000000;

	/**
	 * Indicates that a variable is a private member of its parent.
	 *
	 * Note: the scope attributes are not bitfields.  To determine the scope
	 * of a variable, use variable.getScope() and compare the result to the
	 * various *_SCOPE values using ==.  For example:
	 *
	 * <pre>
	 * 		if (myVar.getScope() == VariableAttribute.PRIVATE_SCOPE) ...
	 * </pre>
	 */
	public static final int PRIVATE_SCOPE			= 0x00800000;

	/**
	 * Indicates that a variable is a protected member of its parent.
	 *
	 * Note: the scope attributes are not bitfields.  To determine the scope
	 * of a variable, use variable.getScope() and compare the result to the
	 * various *_SCOPE values using ==.  For example:
	 *
	 * <pre>
	 * 		if (myVar.getScope() == VariableAttribute.PROTECTED_SCOPE) ...
	 * </pre>
	 */
	public static final int PROTECTED_SCOPE			= 0x01000000;

	/**
	 * Indicates that a variable is an internal member of its parent.
	 * Internally scoped variables are visible to all classes that
	 * are in the same package.
	 *
	 * Note: the scope attributes are not bitfields.  To determine the scope
	 * of a variable, use variable.getScope() and compare the result to the
	 * various *_SCOPE values using ==.  For example:
	 *
	 * <pre>
	 * 		if (myVar.getScope() == VariableAttribute.INTERNAL_SCOPE) ...
	 * </pre>
	 */
	public static final int INTERNAL_SCOPE			= 0x01800000;

	/**
	 * Indicates that a variable is scoped by a namespace.  For
	 * example, it may have been declared as:
	 * <code>my_namespace var x;</code>
	 *
	 * Note: the scope attributes are not bitfields.  To determine the scope
	 * of a variable, use variable.getScope() and compare the result to the
	 * various *_SCOPE values using ==.  For example:
	 *
	 * <pre>
	 * 		if (myVar.getScope() == VariableAttribute.NAMESPACE_SCOPE) ...
	 * </pre>
	 */
	public static final int NAMESPACE_SCOPE			= 0x02000000;

	/**
	 * A mask which can be used to get back only the scope-related
	 * attributes.
	 *
	 * Note: the scope attributes are not bitfields.  To determine the scope
	 * of a variable, use variable.getScope() and compare the result to the
	 * various *_SCOPE values using ==.  For example:
	 *
	 * <pre>
	 * 		if (myVar.getScope() == VariableAttribute.PRIVATE_SCOPE) ...
	 * </pre>
	 */
	public static final int SCOPE_MASK				= PUBLIC_SCOPE|PRIVATE_SCOPE|PROTECTED_SCOPE|INTERNAL_SCOPE|NAMESPACE_SCOPE;

	// 0x04000000 is reserved for IS_CLASS, which is now part of
	// ValueAttribute rather than VariableAttribute.
}
