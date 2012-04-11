/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */
package flash.tools.debugger.expression;

import macromedia.asc.parser.ProgramNode;
import macromedia.asc.parser.SetExpressionNode;
import flash.swf.tools.as3.EvaluatorAdapter;
import flash.tools.debugger.PlayerDebugException;
import flash.tools.debugger.expression.DebuggerEvaluator.DebuggerValue;
import flash.tools.debugger.expression.DebuggerEvaluator.ExpressionEvaluatorScope;

/**
 * A wrapper around an abstract syntax tree (AST) that was provided by
 * the ActionScript Compiler (ASC), suitable for use by the debugger.
 * 
 * When {@link #evaluate(Context)} is called, this will walk the AST
 * and return a value.  But please note that this class's implementation
 * of expression evaluation should not be taken as a model of 100%
 * perfect ActionScript evaluation.  While this implementation handles
 * all the cases the debugger is likely to run into, there are many
 * edge cases that this class can't handle.  For most cases where you
 * need an on-the-fly expression evaluator, you would be better off
 * using the code from the "esc" project.
 * 
 * @author Mike Morearty
 */
class DebuggerExpression implements ValueExp {

	/**
	 * The AST representing the expression.
	 */
	private ProgramNode m_programNode;

	/**
	 * @see #isLookupMembers()
	 */
	private boolean m_lookupMembers = false;

	private macromedia.asc.util.Context m_cx;

	/**
	 * @return the AST representing the expression.
	 */
	public ProgramNode getProgramNode() {
		return m_programNode;
	}

	/**
	 * Sets the AST representing the expression.
	 */
	public void setProgramNode(ProgramNode programNode) {
		m_programNode = programNode;
	}

	/*
	 * @see flash.tools.debugger.expression.ValueExp#isLookupMembers()
	 */
	public boolean isLookupMembers() {
		return m_lookupMembers;
	}

	/**
	 * @see #isLookupMembers()
	 */
	public void setLookupMembers(boolean value) {
		m_lookupMembers = value;
	}

	public void setContext(macromedia.asc.util.Context cx)
	{
		m_cx = cx;
	}

	/*
	 * @see flash.tools.debugger.expression.ValueExp#containsAssignment()
	 */
	public boolean containsAssignment() {
		final boolean[] hasAssignment = new boolean[] { false };
		m_programNode.evaluate(m_cx, new EvaluatorAdapter() {
			public macromedia.asc.semantics.Value evaluate(macromedia.asc.util.Context cx, SetExpressionNode node)
			{
				hasAssignment[0] = true;
				return super.evaluate(cx, node);
			}
		});
		return hasAssignment[0];
	}

	/*
	 * @see flash.tools.debugger.expression.ValueExp#evaluate(flash.tools.debugger.expression.Context)
	 */
	public Object evaluate(Context context) throws NumberFormatException,
			NoSuchVariableException, PlayerFaultException, PlayerDebugException {
		assert m_cx.getScopeDepth() == 0;
		m_cx.pushScope(new ExpressionEvaluatorScope(context));
		try {
			DebuggerValue value = (DebuggerValue) m_programNode.evaluate(m_cx, new DebuggerEvaluator());
			if (isLookupMembers()) {
				return context.lookupMembers(value.debuggerValue);
			} else {
				return value.debuggerValue;
			}
		} catch (ExpressionEvaluatorException e) {
			if (e.getCause() instanceof NumberFormatException) {
				throw (NumberFormatException) e.getCause();
			} else if (e.getCause() instanceof NoSuchVariableException) {
				throw (NoSuchVariableException) e.getCause();
			} else if (e.getCause() instanceof PlayerFaultException) {
				throw (PlayerFaultException) e.getCause();
			} else if (e.getCause() instanceof PlayerDebugException) {
				throw (PlayerDebugException) e.getCause();
			} else {
				throw new PlayerDebugException(e.getLocalizedMessage());
			}
		} finally {
			m_cx.popScope();
		}
	}

}
