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

import flash.tools.debugger.PlayerDebugException;

/**
 * All objects in the abstract syntax tree must provide 
 * this interface.  It allows the tree to resolve down
 * to a single value.
 * 
 * The tree nodes are terminal and non-terminal.  Terminals
 * are constants or variables, non-terminals are everything 
 * else.  Each non-terminal is an operation which takes 
 * its left hand child and right hand child as input
 * and produces a result.  Performing evaluate() at the root of 
 * the tree results in a single Object being returned.
 */
public interface ValueExp
{
	/**
	 * Evaluates the expression. For example, if this node is a "+" node, with a
	 * 2 left child and a 2 right child, then the return value will be a long
	 * (that is, a java.lang.Long) with the value 4.
	 * 
	 * @param context
	 *            the context in which the expression should be evaluated;
	 *            primarily used for looking up variables. For example, when
	 *            evaluating the expression "myvar", the context looks at
	 *            locals, members of "this", etc.; when evaluating "myfield"
	 *            node of the expression "myvar.myfield", the context looks at
	 *            members of the variable "myvar".
	 * @return the value of the expression. This might be a literal Java
	 *         constant (e.g. a Boolean, Integer, String, etc.); or it might be
	 *         an UndefinedExp, representing the value 'undefined'; or it might
	 *         be a Value; or it might be a Variable.
	 * 
	 * @see Context#lookup(Object)
	 */
	public Object evaluate(Context context) throws NumberFormatException, NoSuchVariableException,
			PlayerFaultException, PlayerDebugException;

	/**
	 * Returns whether the expression contains any assignments (= or ++ or --).
	 * Note, there are other kinds of expressions that can have side effects as
	 * well, such as function calls, or even simple expressions like "foo" if
	 * foo is a getter.
	 */
	public boolean containsAssignment();

	/**
	 * Returns whether <code>evaluate()</code> will return an object that
	 * explicitly shows the values of all members of the expression. For
	 * example, in fdb, if the user writes "print myvar", then isLookupMembers
	 * will be false, and the debugger will show just the value of
	 * <code>myvar</code>, but not the values of its members; but if the user
	 * writes "print myvar." (with a "." at the end), then the debugger will
	 * show the values of all of the members of <code>myvar</code>.
	 * 
	 * @see ASTBuilder#ASTBuilder(boolean)
	 * @see ASTBuilder#isIndirectionOperatorAllowed()
	 */
	public boolean isLookupMembers();
}
