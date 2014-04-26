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

import java.util.HashSet;

import com.adobe.flash.compiler.internal.projects.ASCProject;
import com.adobe.flash.compiler.internal.tree.as.BinaryOperatorLogicalAndNode;
import com.adobe.flash.compiler.internal.tree.as.ExpressionNodeBase;
import com.adobe.flash.compiler.internal.workspaces.Workspace;
import com.adobe.flash.compiler.projects.ICompilerProject;
import com.adobe.flash.compiler.tree.ASTNodeID;
import com.adobe.flash.compiler.tree.as.IASNode;
import com.adobe.flash.compiler.tree.as.IExpressionNode;
import com.adobe.flash.compiler.workspaces.IWorkspace;

import flash.tools.debugger.PlayerDebugException;

/**
 * A wrapper around an abstract syntax tree (AST) that was provided by the
 * ActionScript Compiler (ASC), suitable for use by the debugger.
 * 
 * When {@link #evaluate(Context)} is called, this will walk the AST and return
 * a value. But please note that this class's implementation of expression
 * evaluation should not be taken as a model of 100% perfect ActionScript
 * evaluation. While this implementation handles all the cases the debugger is
 * likely to run into, there are many edge cases that this class can't handle.
 * For most cases where you need an on-the-fly expression evaluator, you would
 * be better off using the code from the "esc" project.
 * 
 * @author Mike Morearty
 */
class DebuggerExpression implements ValueExp {

	private final static HashSet<ASTNodeID> ASSIGN_OPRATORS = new HashSet<ASTNodeID>();
	static {
		ASSIGN_OPRATORS.add(ASTNodeID.Op_AssignId);
		ASSIGN_OPRATORS.add(ASTNodeID.Op_LeftShiftAssignID);
		ASSIGN_OPRATORS.add(ASTNodeID.Op_RightShiftAssignID);
		ASSIGN_OPRATORS.add(ASTNodeID.Op_UnsignedRightShiftAssignID);
		ASSIGN_OPRATORS.add(ASTNodeID.Op_MultiplyAssignID);
		ASSIGN_OPRATORS.add(ASTNodeID.Op_DivideAssignID);
		ASSIGN_OPRATORS.add(ASTNodeID.Op_ModuloAssignID);
		ASSIGN_OPRATORS.add(ASTNodeID.Op_BitwiseAndAssignID);
		ASSIGN_OPRATORS.add(ASTNodeID.Op_BitwiseXorAssignID);
		ASSIGN_OPRATORS.add(ASTNodeID.Op_BitwiseOrAssignID);
		ASSIGN_OPRATORS.add(ASTNodeID.Op_AddAssignID);
		ASSIGN_OPRATORS.add(ASTNodeID.Op_SubtractAssignID);
		ASSIGN_OPRATORS.add(ASTNodeID.Op_LogicalAndAssignID);
		ASSIGN_OPRATORS.add(ASTNodeID.Op_LogicalOrAssignID);
	}
	/**
	 * The AST representing the expression.
	 */
	private IASNode m_programNode;

	/**
	 * @see #isLookupMembers()
	 */
	private boolean m_lookupMembers = false;

	/**
	 * @return the AST representing the expression.
	 */
	public IASNode getProgramNode() {
		return m_programNode;
	}

	/**
	 * Sets the AST representing the expression.
	 */
	public void setProgramNode(IASNode programNode) {
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

	/*
	 * @see flash.tools.debugger.expression.ValueExp#containsAssignment()
	 */
	public boolean containsAssignment() {
		return containsAssignment(m_programNode);
	}

	/**
	 * @param containsAssignment
	 */
	private boolean containsAssignment(IASNode node) {
		if (ASSIGN_OPRATORS.contains(node.getNodeID())) {
			return true;
		}
		for (int i = 0; i < node.getChildCount(); i++) {
			if (containsAssignment(node.getChild(i))) {
				return true;
			}
		}
		return false;
	}

	/*
	 * @see
	 * flash.tools.debugger.expression.ValueExp#evaluate(flash.tools.debugger
	 * .expression.Context)
	 */
	public Object evaluate(Context context) throws NumberFormatException,
			NoSuchVariableException, PlayerFaultException, PlayerDebugException {
		// assert m_cx.getScopeDepth() == 0;
		// m_cx.pushScope(new ExpressionEvaluatorScope(context));
		try {
			IExpressionEvaluator eval = new DebuggerExpressionEvaluator();
			DebuggerValue value = eval.evaluate(context, m_programNode);

			if (isLookupMembers()) {
				return context.lookupMembers(value.debuggerValue);
			} else {
				return value.debuggerValue;
			}
		} catch (Exception e) {
			// e.printStackTrace();//TODO : ASC3 : remove
			if (e.getCause() instanceof NumberFormatException) {
				throw (NumberFormatException) e.getCause();
			} else if (e.getCause() instanceof NoSuchVariableException) {
				throw (NoSuchVariableException) e.getCause();
			} else if (e.getCause() instanceof PlayerFaultException) {
				throw (PlayerFaultException) e.getCause();
			} else if (e.getCause() instanceof PlayerDebugException) {
				throw (PlayerDebugException) e.getCause();
			} else {
				e.printStackTrace();
				throw new PlayerDebugException(e.getLocalizedMessage());
			}
		} finally {
			// m_cx.popScope();
		}
	}

}
