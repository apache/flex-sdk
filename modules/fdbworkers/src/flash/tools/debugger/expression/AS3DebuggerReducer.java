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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Vector;

import com.adobe.flash.abc3.ABCConstants;
import com.adobe.flash.compiler.constants.IASLanguageConstants;
import com.adobe.flash.compiler.definitions.IDefinition;
import com.adobe.flash.compiler.definitions.ITypeDefinition;
import com.adobe.flash.compiler.internal.definitions.NamespaceDefinition;
import com.adobe.flash.compiler.internal.semantics.AS3SemanticUtils;
import com.adobe.flash.compiler.internal.tree.as.IdentifierNode;
import com.adobe.flash.compiler.internal.tree.as.MemberAccessExpressionNode;
import com.adobe.flash.compiler.internal.tree.as.NumericLiteralNode;
import com.adobe.flash.compiler.internal.tree.as.RegExpLiteralNode;
import com.adobe.flash.compiler.projects.ICompilerProject;
import com.adobe.flash.compiler.tree.ASTNodeID;
import com.adobe.flash.compiler.tree.INumericValue;
import com.adobe.flash.compiler.tree.as.IASNode;
import com.adobe.flash.compiler.tree.as.IExpressionNode;
import com.adobe.flash.compiler.tree.as.IIdentifierNode;

import flash.tools.debugger.IsolateSession;
import flash.tools.debugger.PlayerDebugException;
import flash.tools.debugger.Session;
import flash.tools.debugger.Variable;
import flash.tools.debugger.VariableType;
import flash.tools.debugger.concrete.DValue;

/**
 * Reducer for the debugger - equivalent to the old DebuggerEvaluator
 */
public class AS3DebuggerReducer {

	private final ContextStack contextStack;
	private final ICompilerProject project;

	public static class ContextStack {

		private final List<Context> ctxStckInternal;

		public ContextStack(Context context) {
			ctxStckInternal = new ArrayList<Context>();
			pushScope(context);
		}

		public Context scope(int i) {
			return ctxStckInternal.get(i);
		}

		public void pushScope(Context scope) {
			ctxStckInternal.add(scope);
		}

		public void popScope() {
			assert (!ctxStckInternal.isEmpty());
			ctxStckInternal.remove(ctxStckInternal.size() - 1);
		}

		public Context scope() {
			return ctxStckInternal.get(ctxStckInternal.size() - 1);
		}

	}

	public AS3DebuggerReducer(Context context, ICompilerProject project) {
		super();
		this.contextStack = new ContextStack(context);
		this.project = project;
	}

	static final int ERROR_TRAP = 268435456;

	private Object callFunction(Context cx, boolean isConstructor,
			Object function, Object[] args) throws PlayerDebugException {
		Session session = cx.getSession();

		flash.tools.debugger.Value thisObject = cx.toValue();
		if (thisObject == null)
			thisObject = DValue.forPrimitive(null, cx.getIsolateId());

		flash.tools.debugger.Value[] valueArgs = new flash.tools.debugger.Value[args.length];
		for (int i = 0; i < args.length; ++i) {
			/**
			 * context.toValue() may return null while
			 * PlayerSession::buildCallFunctionMessage expects the Value to be a
			 * value that depicts null. For example,
			 * xmlVar.childNode[nonexistentornullvar] will run into this case.
			 * (Came to notice via bug FB-25660)
			 */
			flash.tools.debugger.Value tempValue = cx.toValue(args[i]);
			if (tempValue == null) {
				tempValue = DValue.forPrimitive(null, cx.getIsolateId());
			}
			valueArgs[i] = tempValue;
		}

		String functionName;
		if (function instanceof Variable) {
			// Sometimes, the function will show up as a Variable. This happens,
			// for example, if the user wrote "MyClass.myFunction = function() {
			// ... }";
			// String.fromCharCode(), for example, is defined that way.
			functionName = ((Variable) function).getQualifiedName();
		} else {
			functionName = function.toString();
		}
		IsolateSession workerSession = session.getWorkerSession(cx
				.getIsolateId());
		if (isConstructor) {
			return workerSession.callConstructor(functionName, valueArgs);
		} else {
			return workerSession.callFunction(thisObject, functionName,
					valueArgs);
		}
	}

	Object compoundBinaryAssignmentBracketExpr(IASNode iNode, Object stem,
			Object index, Object r, int opcode) {
		Object leftVariable = reduce_arrayIndexExpr(iNode, stem, false, index);
		DebuggerValue operationValue = (DebuggerValue) binaryOp(iNode,
				leftVariable, r, opcode);
		return reduce_assignToBracketExpr_to_expression(iNode, stem, index,
				operationValue, false);
	}

	Object compoundBinaryAssignmentMemberExpr(IASNode iNode, Object stem,
			Object member, Object r, int opcode) {
		Object leftVariable = reduce_memberAccessExpr(iNode, stem, member, -1);
		DebuggerValue operationValue = (DebuggerValue) binaryOp(iNode,
				leftVariable, r, opcode);
		return reduce_assignToMemberExpr_to_expression(iNode, stem, member,
				operationValue);
	}

	Object compoundBinaryAssignmentNameExpr(IASNode iNode, Object l, Object r,
			int opcode) {
		Object leftVariable = transform_name_to_expression(iNode, l);
		DebuggerValue operationValue = (DebuggerValue) binaryOp(iNode,
				leftVariable, r, opcode);
		return reduce_assignToNameExpr_to_expression(iNode, l, operationValue);
	}

	/**
	 * Generate a binary operator.
	 * 
	 * @param l
	 *            - the left-hand operand.
	 * @param r
	 *            - the right-hand operand.
	 * @param opcode
	 *            - the operator's opcode.
	 * @return the combined instruction sequence with the operator appended.
	 */
	Object binaryOp(IASNode iNode, Object l, Object r, int opcode) {
		// REFER : ASC : public Value evaluate(macromedia.asc.util.Context cx,
		// BinaryExpressionNode node)
		switch (opcode) {
		case ABCConstants.OP_add:
			break;
		}

		DebuggerValue lhs = (DebuggerValue) l;
		DebuggerValue rhs = (DebuggerValue) r;

		Context eeContext = contextStack.scope();
		Session session = eeContext.getSession();
		switch (opcode) {
		case ABCConstants.OP_multiply: {
			// ECMA 11.5
			double d1 = ECMA.toNumber(session,
					eeContext.toValue(lhs.debuggerValue));
			double d2 = ECMA.toNumber(session,
					eeContext.toValue(rhs.debuggerValue));
			return new DebuggerValue(new Double(d1 * d2));
		}
		case ABCConstants.OP_divide: {
			// ECMA 11.5
			double d1 = ECMA.toNumber(session,
					eeContext.toValue(lhs.debuggerValue));
			double d2 = ECMA.toNumber(session,
					eeContext.toValue(rhs.debuggerValue));
			return new DebuggerValue(new Double(d1 / d2));
		}
		case ABCConstants.OP_modulo: {
			// ECMA 11.5
			double d1 = ECMA.toNumber(session,
					eeContext.toValue(lhs.debuggerValue));
			double d2 = ECMA.toNumber(session,
					eeContext.toValue(rhs.debuggerValue));
			return new DebuggerValue(new Double(d1 % d2));
		}
		case ABCConstants.OP_add: {
			// E4X 11.4.1 and ECMA 11.6.1
			flash.tools.debugger.Value v1 = eeContext
					.toValue(lhs.debuggerValue);
			flash.tools.debugger.Value v2 = eeContext
					.toValue(rhs.debuggerValue);

			boolean isXMLConcat = false;

			if (v1.getType() == VariableType.OBJECT
					&& v2.getType() == VariableType.OBJECT) {
				String type1 = v1.getTypeName();
				String type2 = v2.getTypeName();
				int at;
				at = type1.indexOf('@');
				if (at != -1)
					type1 = type1.substring(0, at);
				at = type2.indexOf('@');
				if (at != -1)
					type2 = type2.substring(0, at);

				if (type1.equals("XML") || type1.equals("XMLList")) //$NON-NLS-1$ //$NON-NLS-2$
					if (type2.equals("XML") || type2.equals("XMLList")) //$NON-NLS-1$ //$NON-NLS-2$
						isXMLConcat = true;
			}

			if (isXMLConcat) {
				try {
					IsolateSession workerSession = session.getWorkerSession(v1
							.getIsolateId());
					flash.tools.debugger.Value xml1 = workerSession
							.callFunction(
									v1,
									"toXMLString", new flash.tools.debugger.Value[0]); //$NON-NLS-1$
					flash.tools.debugger.Value xml2 = session.getWorkerSession(
							v2.getIsolateId()).callFunction(v2,
							"toXMLString", new flash.tools.debugger.Value[0]); //$NON-NLS-1$
					String allXML = xml1.getValueAsString()
							+ xml2.getValueAsString();
					flash.tools.debugger.Value allXMLValue = DValue
							.forPrimitive(allXML, v1.getIsolateId());
					flash.tools.debugger.Value retval = workerSession
							.callConstructor(
									"XMLList", new flash.tools.debugger.Value[] { allXMLValue }); //$NON-NLS-1$
					return new DebuggerValue(retval);
				} catch (PlayerDebugException e) {
					throw new ExpressionEvaluatorException(e);
				}
			} else {
				v1 = ECMA.toPrimitive(session, v1, null,
						eeContext.getIsolateId());
				v2 = ECMA.toPrimitive(session, v2, null,
						eeContext.getIsolateId());
				if (v1.getType() == VariableType.STRING
						|| v2.getType() == VariableType.STRING) {
					return new DebuggerValue(ECMA.toString(session, v1)
							+ ECMA.toString(session, v2));
				} else {
					return new DebuggerValue(new Double(ECMA.toNumber(session,
							v1) + ECMA.toNumber(session, v2)));
				}
			}
		}
		case ABCConstants.OP_subtract: {
			// ECMA 11.6.2
			double d1 = ECMA.toNumber(session,
					eeContext.toValue(lhs.debuggerValue));
			double d2 = ECMA.toNumber(session,
					eeContext.toValue(rhs.debuggerValue));
			return new DebuggerValue(new Double(d1 - d2));
		}
		case ABCConstants.OP_lshift: {
			// ECMA 11.7.1
			int n1 = ECMA
					.toInt32(session, eeContext.toValue(lhs.debuggerValue));
			int n2 = (int) (ECMA.toUint32(session,
					eeContext.toValue(rhs.debuggerValue)) & 0x1F);
			return new DebuggerValue(new Double(n1 << n2));
		}
		case ABCConstants.OP_rshift: {
			// ECMA 11.7.1
			int n1 = ECMA
					.toInt32(session, eeContext.toValue(lhs.debuggerValue));
			int n2 = (int) (ECMA.toUint32(session,
					eeContext.toValue(rhs.debuggerValue)) & 0x1F);
			return new DebuggerValue(new Double(n1 >> n2));
		}
		case ABCConstants.OP_urshift: {
			// ECMA 11.7.1
			long n1 = ECMA.toUint32(session,
					eeContext.toValue(lhs.debuggerValue));
			long n2 = (ECMA.toUint32(session,
					eeContext.toValue(rhs.debuggerValue)) & 0x1F);
			return new DebuggerValue(new Double(n1 >>> n2));
		}
		case ABCConstants.OP_lessthan: {
			// ECMA 11.8.1
			flash.tools.debugger.Value lessThan = ECMA.lessThan(session,
					eeContext.toValue(lhs.debuggerValue),
					eeContext.toValue(rhs.debuggerValue));
			boolean result;
			if (lessThan.getType() == VariableType.UNDEFINED) {
				result = false;
			} else {
				result = ECMA.toBoolean(lessThan);
			}
			return new DebuggerValue(result);
		}
		case ABCConstants.OP_greaterthan: {
			// ECMA 11.8.2
			flash.tools.debugger.Value greaterThan = ECMA.lessThan(session,
					eeContext.toValue(rhs.debuggerValue),
					eeContext.toValue(lhs.debuggerValue));
			boolean result;
			if (greaterThan.getType() == VariableType.UNDEFINED) {
				result = false;
			} else {
				result = ECMA.toBoolean(greaterThan);
			}
			return new DebuggerValue(result);
		}
		case ABCConstants.OP_lessequals: {
			// ECMA 11.8.3
			flash.tools.debugger.Value lessThan = ECMA.lessThan(session,
					eeContext.toValue(rhs.debuggerValue),
					eeContext.toValue(lhs.debuggerValue));
			boolean result;
			if (lessThan.getType() == VariableType.UNDEFINED) {
				result = false;
			} else {
				result = !ECMA.toBoolean(lessThan);
			}
			return new DebuggerValue(result);
		}
		case ABCConstants.OP_greaterequals: {
			// ECMA 11.8.4
			flash.tools.debugger.Value lessThan = ECMA.lessThan(session,
					eeContext.toValue(lhs.debuggerValue),
					eeContext.toValue(rhs.debuggerValue));
			boolean result;
			if (lessThan.getType() == VariableType.UNDEFINED) {
				result = false;
			} else {
				result = !ECMA.toBoolean(lessThan);
			}
			return new DebuggerValue(result);
		}
		case ABCConstants.OP_instanceof: {
			try {
				return new DebuggerValue(session.getWorkerSession(
						eeContext.getIsolateId()).evalInstanceof(
						eeContext.toValue(lhs.debuggerValue),
						eeContext.toValue(rhs.debuggerValue)));
			} catch (PlayerDebugException e) {
				throw new ExpressionEvaluatorException(e);
			} catch (PlayerFaultException e) {
				throw new ExpressionEvaluatorException(e);
			}
		}
		case ABCConstants.OP_in: {
			try {
				return new DebuggerValue(session.getWorkerSession(
						eeContext.getIsolateId()).evalIn(
						eeContext.toValue(lhs.debuggerValue),
						eeContext.toValue(rhs.debuggerValue)));
			} catch (PlayerDebugException e) {
				throw new ExpressionEvaluatorException(e);
			} catch (PlayerFaultException e) {
				throw new ExpressionEvaluatorException(e);
			}
		}
		case ABCConstants.OP_istypelate: {
			try {
				return new DebuggerValue(session.getWorkerSession(
						eeContext.getIsolateId()).evalIs(
						eeContext.toValue(lhs.debuggerValue),
						eeContext.toValue(rhs.debuggerValue)));
			} catch (PlayerDebugException e) {
				throw new ExpressionEvaluatorException(e);
			} catch (PlayerFaultException e) {
				throw new ExpressionEvaluatorException(e);
			}
		}
		case ABCConstants.OP_astypelate: {
			try {
				return new DebuggerValue(session.getWorkerSession(
						eeContext.getIsolateId()).evalAs(
						eeContext.toValue(lhs.debuggerValue),
						eeContext.toValue(rhs.debuggerValue)));
			} catch (PlayerDebugException e) {
				throw new ExpressionEvaluatorException(e);
			} catch (PlayerFaultException e) {
				throw new ExpressionEvaluatorException(e);
			}
		}
		case ABCConstants.OP_equals: {
			// ECMA 11.9.1
			return new DebuggerValue(new Boolean(ECMA.equals(session,
					eeContext.toValue(lhs.debuggerValue),
					eeContext.toValue(rhs.debuggerValue))));
		}
		// ASC3 notequals is a sepearate reducer nequals
		// case ABCConstants.op_Tokens.NOTEQUALS_TOKEN:
		// {
		// // ECMA 11.9.2
		// return new DebuggerValue(new Boolean(!ECMA.equals(session,
		// eeContext.toValue(lhs.debuggerValue), eeContext
		// .toValue(rhs.debuggerValue))));
		// }
		case ABCConstants.OP_strictequals: {
			// ECMA 11.9.4
			return new DebuggerValue(new Boolean(ECMA.strictEquals(
					eeContext.toValue(lhs.debuggerValue),
					eeContext.toValue(rhs.debuggerValue))));
		}
		// ASC3 notequals is a sepearate reducer nequals
		/*
		 * case Tokens.STRICTNOTEQUALS_TOKEN: { // ECMA 11.9.5 return new
		 * DebuggerValue(new
		 * Boolean(!ECMA.strictEquals(eeContext.toValue(lhs.debuggerValue),
		 * eeContext .toValue(rhs.debuggerValue)))); }
		 */
		case ABCConstants.OP_bitand: {
			// ECMA 11.10
			return new DebuggerValue(new Double(ECMA.toInt32(session,
					eeContext.toValue(lhs.debuggerValue))
					& ECMA.toInt32(session,
							eeContext.toValue(rhs.debuggerValue))));
		}
		case ABCConstants.OP_bitxor: {
			// ECMA 11.10
			return new DebuggerValue(new Double(ECMA.toInt32(session,
					eeContext.toValue(lhs.debuggerValue))
					^ ECMA.toInt32(session,
							eeContext.toValue(rhs.debuggerValue))));
		}
		case ABCConstants.OP_bitor: {
			// ECMA 11.10
			return new DebuggerValue(new Double(ECMA.toInt32(session,
					eeContext.toValue(lhs.debuggerValue))
					| ECMA.toInt32(session,
							eeContext.toValue(rhs.debuggerValue))));
		}
		/*
		 * ASC3 reduce_logicalAndExpr & reduce_logicalOrExpr sepearate reducers
		 * case Tokens.LOGICALAND_TOKEN: { // ECMA 11.11
		 * flash.tools.debugger.Value result =
		 * eeContext.toValue(lhs.debuggerValue); if (ECMA.toBoolean(result)) {
		 * rhs = (DebuggerValue) node.rhs.evaluate(cx, this); result =
		 * eeContext.toValue(rhs.debuggerValue); } return new
		 * DebuggerValue(result); } case Tokens.LOGICALOR_TOKEN: { // ECMA 11.11
		 * flash.tools.debugger.Value result =
		 * eeContext.toValue(lhs.debuggerValue); if (!ECMA.toBoolean(result)) {
		 * rhs = (DebuggerValue) node.rhs.evaluate(cx, this); result =
		 * eeContext.toValue(rhs.debuggerValue); } return new
		 * DebuggerValue(result); }
		 */
		// case Tokens.EMPTY_TOKEN:
		// // do nothing, already been folded
		// return new DebuggerValue(null);
		default:
			//cx.internalError(ASTBuilder.getLocalizationManager().getLocalizedTextString("unrecognizedBinaryOperator")); //$NON-NLS-1$
			return new DebuggerValue(null);
		}
	}

	/**
	 * Resolve a dotted name, e.g., foo.bar.baz
	 */
	Object dottedName(IASNode iNode, String qualifiers, String base_name) {
		return qualifiers + "." + base_name;
	}

	/**
	 * Error trap.
	 */
	public Object error_namespaceAccess(IASNode iNode, IASNode raw_qualifier,
			Object qualified_name) {
		return null;
	}

	/**
	 * Error trap.
	 */
	public Object error_reduce_Op_AssignId(IASNode iNode, Object non_lvalue,
			Object rvalue) {
		return null;
	}

	/**
	 * @return the double content of a numeric literal.
	 * @param iNode
	 *            - the literal node.
	 */
	Double getDoubleContent(IASNode iNode) {
		return AS3SemanticUtils.getDoubleContent(iNode, project);
	}

	/**
	 * @return the double content of a numeric literal.
	 * @param iNode
	 *            - the literal node.
	 */
	Float getFloatContent(IASNode iNode) {
		return AS3SemanticUtils.getFloatContent(iNode, project);
	}

	/**
	 * @return the name of an identifier.
	 * @param iNode
	 *            - the IIdentifier node.
	 */
	String getIdentifierContent(IASNode iNode) {
		return AS3SemanticUtils.getIdentifierContent(iNode);
	}

	/**
	 * @return the int content of a numeric literal.
	 * @param iNode
	 *            - the literal node.
	 */
	Integer getIntegerContent(IASNode iNode) {
		return AS3SemanticUtils.getIntegerContent(iNode, project);
	}

	/**
	 * @return always zero.
	 * @param iNode
	 *            - the literal node.
	 */
	Integer getIntegerZeroContent(IASNode iNode) {
		return 0;
	}

	/**
	 * @return always zero.
	 * @param iNode
	 *            - the literal node.
	 */
	Long getIntegerZeroContentAsLong(IASNode iNode) {
		return 0L;
	}

	/**
	 * @return the string content of a literal.
	 * @param iNode
	 *            - the literal node.
	 */
	String getStringLiteralContent(IASNode iNode) {
		return AS3SemanticUtils.getStringLiteralContent(iNode);
	}

	/**
	 * @return the uint content of a numeric literal.
	 * @param iNode
	 *            - the literal node.
	 */
	Long getUintContent(IASNode iNode) {
		return AS3SemanticUtils.getUintContent(iNode, project);
	}

	/*
	 * *******************************
	 * ** Cost/Decision Functions ** *******************************
	 */

	public int isIntLiteral(IASNode iNode) {
		if (iNode.getNodeID() == ASTNodeID.LiteralNumberID) {
			INumericValue numericVal = ((NumericLiteralNode) iNode)
					.getNumericValue(project);

			if (numericVal.getAssumedType() == IASLanguageConstants.BuiltinType.INT) {
				return 1;
			}
		}
		return Integer.MAX_VALUE;
	}

	public int isUintLiteral(IASNode iNode) {
		if (iNode.getNodeID() == ASTNodeID.LiteralNumberID) {
			INumericValue numericVal = ((NumericLiteralNode) iNode)
					.getNumericValue(project);

			if (numericVal.getAssumedType() == IASLanguageConstants.BuiltinType.UINT) {
				return 1;
			}
		}
		return Integer.MAX_VALUE;
	}

	public int isDoubleLiteral(IASNode iNode) {
		if (iNode.getNodeID() == ASTNodeID.LiteralNumberID) {
			return 2;
		}
		return Integer.MAX_VALUE;
	}

	public int isFloatLiteral(IASNode iNode) {
		if (iNode.getNodeID() == ASTNodeID.LiteralNumberID) {
			INumericValue numericVal = ((NumericLiteralNode) iNode)
					.getNumericValue(project);

			if (numericVal.getAssumedType() == IASLanguageConstants.BuiltinType.FLOAT) {
				return 1;
			}
			return Integer.MAX_VALUE;
		}
		return Integer.MAX_VALUE;
	}

	/**
	 * Explore a MemberAccessNode and decide if its stem is a reference to a
	 * package. This method will always return a result greater than what
	 * isPackageName will return, as package name must "win" over dotted name.
	 */
	int isDottedName(IASNode n) {
		int result = Integer.MAX_VALUE;

		if (n instanceof MemberAccessExpressionNode) {
			MemberAccessExpressionNode ma = (MemberAccessExpressionNode) n;

			if (ma.stemIsPackage())
				// This needs to be greater than the value returned from
				// isPackageName,
				// so that isPackageName wins
				result = 2;
		}

		return result;
	}

	/**
	 * Explore a MemberAccessNode and decide if it is a reference to a package.
	 * This method will always return a result less than what isDottedName will
	 * return, as package name must "win" over dotted name.
	 */
	int isPackageName(IASNode n) {
		int result = Integer.MAX_VALUE;

		if (n instanceof MemberAccessExpressionNode) {
			MemberAccessExpressionNode ma = (MemberAccessExpressionNode) n;

			if (ma.isPackageReference())
				// This needs to be less than the value returned from
				// isDottedName,
				// so that isPackageName wins
				result = 1;
		}

		return result;
	}

	/**
	 * Get the definition associated with a node's qualifier and decide if the
	 * qualifier is a compile-time constant.
	 * 
	 * @param iNode
	 *            - the node to check.
	 * @pre - the node has an IdentifierNode 0th child.
	 * @return an attractive cost if the child has a known namespace, i.e., it's
	 *         a compile-time constant qualifier.
	 */
	int qualifierIsCompileTimeConstant(IASNode iNode) {
		IdentifierNode qualifier = (IdentifierNode) AS3SemanticUtils
				.getNthChild(iNode, 0);
		IDefinition def = qualifier.resolve(project);

		int result = def instanceof NamespaceDefinition ? 1 : Integer.MAX_VALUE;
		return result;
	}

	/**
	 * @return a feasible cost if a node has a compile-time constant defintion.
	 */
	int isCompileTimeConstant(IASNode iNode) {
		if (AS3SemanticUtils.transformNameToConstantValue(iNode, project) != null)
			return 1;
		else
			return Integer.MAX_VALUE;
	}

	/**
	 * @return a feasible cost if a node has a compile-time constant defintion.
	 */
	int isCompileTimeConstantFunction(IASNode iNode) {
		if (AS3SemanticUtils.isConstantFunction(project, iNode))
			return 1;
		else
			return Integer.MAX_VALUE;
	}

	/**
	 * @return a feasible cost if the parameterized type's base and parameter
	 *         types are compile-time constants, ERROR_TRAP if not.
	 */
	int parameterTypeIsConstant(IASNode iNode) {
		return Math.max(isKnownType(AS3SemanticUtils.getNthChild(iNode, 0)),
				isKnownType(AS3SemanticUtils.getNthChild(iNode, 1)));
	}

	/**
	 * @return a feasible cost if the given node is a known type, ERROR_TRAP
	 *         otherwise.
	 */
	int isKnownType(IASNode iNode) {
		boolean isConstant = false;
		if (iNode instanceof IExpressionNode) {
			isConstant = ((IExpressionNode) iNode).resolve(project) instanceof ITypeDefinition;
		}

		return isConstant ? 1 : ERROR_TRAP;
	}

	/**
	 * Reduce a function call to a constant value. This is only possible for a
	 * limited set of function calls, and you should call
	 * isCompileTimeConstantFunction first to make sure this is possible.
	 * 
	 * @param iNode
	 *            the IFunctionCallNode
	 * @param method
	 *            the Object of the method to call
	 * @param constant_args
	 *            the constant_values used as arguments to the function call
	 * @return A constant value that that would be the result of calling the
	 *         function at runtime with the specified arguments
	 */
	public Object transform_constant_function_to_value(IASNode iNode,
			Object method, Vector<Object> constant_args) {
		return null;
	}

	/**
	 * @return a feasible cost if the node is a BinaryExpression, and the type
	 *         of the left or right side of the expressions resolves to "float"
	 */
	int isFloatBinOp(IASNode iNode) {
		return 0;
	}

	/**
	 * @return a feasible cost (1) if the node is for 'new Array()'
	 */
	int isEmptyArrayConstructor(IASNode iNode) {
		IIdentifierNode identifierNode = (IIdentifierNode) AS3SemanticUtils
				.getNthChild(iNode, 1);
		if (identifierNode.resolve(project) == project
				.getBuiltinType(IASLanguageConstants.BuiltinType.ARRAY))
			return 1;

		return Integer.MAX_VALUE;
	}

	/**
	 * @return a feasible cost (1) if the node is for 'new Object()'
	 */
	int isEmptyObjectConstructor(IASNode iNode) {
		IIdentifierNode identifierNode = (IIdentifierNode) AS3SemanticUtils
				.getNthChild(iNode, 1);
		if (identifierNode.resolve(project) == project
				.getBuiltinType(IASLanguageConstants.BuiltinType.OBJECT))
			return 1;

		return Integer.MAX_VALUE;
	}

	/*
	 * *************************
	 * ** Reduction actions ** *************************
	 */

	public Object reduce_arrayIndexExpr(IASNode iNode, Object stem,
			boolean is_super, Object index) {
		return reduce_memberAccessExpr(iNode, stem, index, -1);
	}

	public Object reduce_arrayLiteral(IASNode iNode, Vector<Object> elements) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_assignToBracketExpr_to_expression(IASNode iNode,
			Object stem, Object index, Object r, boolean is_super) {
		Context eeContext = contextStack.scope();
		Context newContext = eeContext
				.createContext(((DebuggerValue) stem).debuggerValue);
		contextStack.pushScope(newContext);
		try {
			return reduce_assignToNameExpr_to_expression(iNode, index, r);
		} finally {
			contextStack.popScope();
		}
	}

	public Object reduce_assignToMemberExpr_to_expression(IASNode iNode,
			Object stem, Object member, Object r) {
		Context eeContext = contextStack.scope();
		Context newContext = eeContext
				.createContext(((DebuggerValue) stem).debuggerValue);
		contextStack.pushScope(newContext);
		try {
			return reduce_assignToNameExpr_to_expression(iNode, member, r);
		} finally {
			contextStack.popScope();
		}
	}

	public Object reduce_assignToDescendantsExpr(IASNode iNode, Object stem,
			Object member, Object r, boolean need_value) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_assignToNameExpr_to_expression(IASNode iNode,
			Object lvalue, Object r) {

		// ASC : Refer : evaluate(macromedia.asc.util.Context cx,
		// SetExpressionNode node)
		Context eeContext = contextStack.scope();
		DebuggerValue lhs = (DebuggerValue) lvalue;
		Object variableToAssignTo;
		// if (node.getMode() == Tokens.LEFTBRACKET_TOKEN || node.getMode() ==
		// Tokens.EMPTY_TOKEN)
		{
			variableToAssignTo = ECMA.toString(eeContext.getSession(),
					eeContext.toValue(lhs.debuggerValue));
		}
		// else
		// {
		// variableToAssignTo = rhs.debuggerValue;
		// }

		DebuggerValue newValue = (DebuggerValue) r;

		try {
			eeContext.assign(variableToAssignTo,
					eeContext.toValue(newValue.debuggerValue));
		} catch (NoSuchVariableException e) {
			throw new ExpressionEvaluatorException(e);
		} catch (PlayerFaultException e) {
			throw new ExpressionEvaluatorException(e);
		}
		return newValue;
	}

	// Not supported :: //throw error
	public Object reduce_assignToQualifiedMemberExpr(IASNode iNode,
			Object stem, Object qualifier, Object member, Object rhs,
			boolean need_value) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	// Not supported :: //throw error
	public Object reduce_assignToQualifiedRuntimeMemberExpr(IASNode iNode,
			Object stem, Object qualifier, Object runtime_member_selector,
			Object rhs, boolean need_value) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	// Not supported :: //throw error
	public Object reduce_assignToQualifiedAttributeExpr(IASNode iNode,
			Object stem, Object qualifier, Object member, Object rhs,
			boolean need_value) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_assignToRuntimeNameExpr(IASNode iNode, Object lval,
			Object r, final boolean need_value) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_assignToUnqualifiedRuntimeAttributeExpr(IASNode iNode,
			Object stem, Object rt_attr, Object rhs, boolean need_value) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$;
	}

	public Object reduce_attributeName(IASNode iNode, Object attr_name) {
		return new DebuggerValue("@"
				+ ((DebuggerValue) attr_name).debuggerValue);
	}

	public Boolean reduce_booleanLiteral(IASNode iNode) {
		return AS3SemanticUtils.getBooleanContent(iNode);
	}

	public String reduce_by_concatenation(IASNode iNode, String first,
			String second) {
		return first + "." + second;
	}

	public Object reduce_commaExpr(IASNode iNode, Object payload_expr,
			Vector<Object> exprs) {
		Object result = null;
		return result;
	}

	/**
	 * Reduce expression like:<br>
	 * {@code delete o[p]}
	 * 
	 * @param iNode
	 *            Tree node for the {@code delete} statement.
	 * @param stem
	 *            Instructions for creating a {@code DynamicAccessNode}.
	 * @param index
	 *            Instructions for initializing the index expression.
	 * @return Instructions for executing a {@code delete} statement.
	 */
	public Object reduce_deleteBracketExpr(IASNode iNode, Object stem,
			Object index) {
		throw new ExpressionEvaluatorException(keywordNotAllowed("delete")); //$NON-NLS-1$
	}

	/**
	 * Reduce E4X expression like:<br>
	 * {@code delete x.@[foo]}
	 * 
	 * @param iNode
	 *            Tree node for the {@code delete} statement.
	 * @param stem
	 *            Instructions for creating a {@code MemberAccessExpressionNode}
	 *            .
	 * @param index
	 *            Instructions for initializing the array index expression.
	 * @return Instructions for executing a {@code delete} statement.
	 */
	public Object reduce_deleteAtBracketExpr(IASNode iNode, Object stem,
			Object index) {
		throw new ExpressionEvaluatorException(keywordNotAllowed("delete")); //$NON-NLS-1$
	}

	public Object reduce_deleteDescendantsExpr(IASNode iNode, Object stem,
			Object field) {
		throw new ExpressionEvaluatorException(keywordNotAllowed("delete")); //$NON-NLS-1$
	}

	public Object reduce_deleteExprExprExpr(IASNode iNode, Object expr) {
		throw new ExpressionEvaluatorException(keywordNotAllowed("delete")); //$NON-NLS-1$
	}

	public Object reduce_deleteMemberExpr(IASNode iNode, Object stem,
			Object field) {
		throw new ExpressionEvaluatorException(keywordNotAllowed("delete")); //$NON-NLS-1$
	}

	public Object reduce_deleteRuntimeNameExpr(IASNode iNode, Object stem,
			Object rt_name) {
		throw new ExpressionEvaluatorException(keywordNotAllowed("delete")); //$NON-NLS-1$
	}

	public Object reduce_deleteNameExpr(IASNode iNode, Object n) {
		throw new ExpressionEvaluatorException(keywordNotAllowed("delete")); //$NON-NLS-1$
	}

	public Object reduce_e4xFilter(IASNode iNode, Object stem, Object filter) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_embed(IASNode iNode) {
		Object result = null;
		return result;
	}

	/**
	 * Reduce expression like:<br>
	 * {@code a[i]()}
	 * 
	 * @param iNode
	 *            Tree node for the function call.
	 * @param stem
	 *            Instructions for creating a {@code DynamicAccessNode}.
	 * @param index
	 *            Instructions for initializing the index expression.
	 * @return Instructions for executing a {@code function call} statement.
	 */
	public Object reduce_functionAsBracketExpr(IASNode iNode, Object stem,
			Object index, Vector<Object> args) {
		Object result = null;
		return result;
	}

	public Object reduce_functionAsMemberExpr(IASNode iNode, Object stem,
			Object method_name, Vector<Object> args) {
		try {
			Context context = contextStack.scope();
			DebuggerValue lhs = (DebuggerValue) stem;
			Context newContext = context.createContext(lhs.debuggerValue);
			contextStack.pushScope(newContext);
			return reduce_functionCall_common(iNode, method_name, args, true,
					false);
		} finally {
			contextStack.popScope();
		}
	}

	public Object reduce_functionAsRandomExpr(IASNode iNode,
			Object random_expr, Vector<Object> args) {
		return reduce_functionCall_common(iNode, random_expr, args, true, false);
	}

	public Object reduce_functionCallExpr_to_expression(IASNode iNode,
			Object method_name, Vector<Object> args) {
		return reduce_functionCall_common(iNode, method_name, args, true, false);
	}

	private Object reduce_functionCall_common(IASNode iNode,
			Object method_name, Vector<Object> args, boolean need_result,
			boolean isConstructor) {

		Context context = contextStack.scope();
		DebuggerValue func = (DebuggerValue) method_name;
		try {
			Object[] argValues = new Object[args.size()];
			for (int i = 0; i < args.size(); i++) {
				DebuggerValue dv = (DebuggerValue) args.get(i);
				argValues[i] = dv.debuggerValue;
			}
			return new DebuggerValue(callFunction(context, isConstructor,
					func.debuggerValue, argValues));
		} catch (PlayerDebugException e) {
			throw new ExpressionEvaluatorException(e);
		}
	}

	public Object reduce_functionCallOfSuperclassMethod_to_expression(
			IASNode iNode, Object stem, Object method_name, Vector<Object> args) {
		throw new ExpressionEvaluatorException(keywordNotAllowed("super")); //$NON-NLS-1$
	}

	public Object reduce_logicalAndExpr(IASNode iNode, Object l, Object r) {
		// REFER : ASC : public Value evaluate(macromedia.asc.util.Context cx,
		// BinaryExpressionNode node)
		// ECMA 11.11
		Context eeContext = contextStack.scope();
		DebuggerValue lhs = (DebuggerValue) l;
		flash.tools.debugger.Value result = eeContext
				.toValue(lhs.debuggerValue);

		if (ECMA.toBoolean(result)) {
			DebuggerValue rhs = null;
			if (r instanceof DebuggerValue) {
				rhs = (DebuggerValue) r;
			} else {
				rhs = ((UnEvaluatedDebugExpression) r).evaluate(eeContext);
			}

			result = eeContext.toValue(rhs.debuggerValue);
		}
		return new DebuggerValue(result);
	}

	public Object reduce_logicalNotExpr(IASNode iNode, Object expr) {
		Context eeContext = contextStack.scope();
		DebuggerValue arg = (DebuggerValue) expr;
		// ECMA 11.4.9
		return new DebuggerValue(new Boolean(!ECMA.toBoolean(eeContext
				.toValue(arg.debuggerValue))));
	}

	public Object reduce_logicalOrExpr(IASNode iNode, Object l, Object r) {
		// REFER : ASC : public Value evaluate(macromedia.asc.util.Context cx,
		// BinaryExpressionNode node)
		// ECMA 11.11
		Context eeContext = contextStack.scope();
		DebuggerValue lhs = (DebuggerValue) l;
		flash.tools.debugger.Value result = eeContext
				.toValue(lhs.debuggerValue);

		if (!ECMA.toBoolean(result)) {
			DebuggerValue rhs = null;
			if (rhs instanceof DebuggerValue) {
				rhs = (DebuggerValue) r;
			} else {
				rhs = ((UnEvaluatedDebugExpression) r).evaluate(eeContext);
			}
			result = eeContext.toValue(rhs.debuggerValue);
		}
		return new DebuggerValue(result);
	}

	/**
	 * reduce a MemberAccessExpression. This example just concats the stem and
	 * member together
	 */
	public Object reduce_memberAccessExpr(IASNode iNode, Object stem,
			Object member, int opcode) {
		DebuggerValue lhs = (DebuggerValue) stem;
		Context context = contextStack.scope();
		boolean pushedScope = false;
		if (lhs != null) {
			flash.tools.debugger.Value lhsValue = context
					.toValue(lhs.debuggerValue);
			if (ECMA.equals(context.getSession(), lhsValue,
					context.toValue(null)))
				throw new ExpressionEvaluatorException(ASTBuilder
						.getLocalizationManager().getLocalizedTextString(
								"nullPointerException")); //$NON-NLS-1$

			Context newContext = context.createContext(lhs.debuggerValue);
			contextStack.pushScope(newContext);
			pushedScope = true;
		}

		try {
			DebuggerValue rhs = (DebuggerValue) transform_name_to_expression(
					iNode, member);

			return rhs;// node.selector.evaluate(cx, this);
		} finally {
			if (pushedScope)
				contextStack.popScope();
		}
		// return stem + "." + member;
	}

	public Object reduce_qualifiedMemberAccessExpr(IASNode iNode, Object stem,
			Object qualifier, Object member, int opcode) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_qualifiedAttributeRuntimeMemberExpr(IASNode iNode,
			Object stem, Object qualifier, Object runtime_member_selector,
			int opcode) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_qualifiedMemberRuntimeNameExpr(IASNode iNode,
			Object stem, Object qualifier, Object runtime_member_selector) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$;
	}

	public Object reduce_qualifiedAttributeExpr(IASNode iNode, Object stem,
			Object qualifier, Object member, int opcode) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_unqualifiedAttributeExpr(IASNode iNode, Object stem,
			Object rt_attr, int opcode) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$	}
	}

	/**
	 * Reduce runtime attribute expression, such as {@code @[exp]}.
	 * 
	 * @param iNode
	 *            Node for {@code @[...]}. It is a
	 *            {@code ArrayIndexExpressionID(Op_AtID, ...)}.
	 * @param rt_attr
	 *            Instructions generated for the runtime name expression.
	 * @return Instructions to get the value of an attribute described with a
	 *         runtime name.
	 */
	public Object reduce_runtimeAttributeExp(IASNode iNode, Object rt_attr) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_namespaceAccess(IASNode iNode, IASNode qualifier,
			Object qualified_name) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_namespaceAsName_to_expression(IASNode iNode) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_namespaceAsName_to_multinameL(IASNode iNode,
			final boolean is_attribute) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_namespaceAsName_to_name(IASNode iNode) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_namespaceMultinameL(IASNode iNode,
			IASNode qualifier_node, Object expr) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_namespaceRTQName(IASNode iNode, Object qualifier,
			Object qualified_name) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_namespaceRTQNameL(IASNode iNode, Object qualifier,
			Object expr) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_neqExpr(IASNode iNode, Object l, Object r) {
		Object result = null;
		return result;
	}

	public Object reduce_nameToTypeName(Object name, boolean check_name) {
		return name;
	}

	public Object reduce_newMemberProperty(IASNode iNode, Object stem,
			Object member, Vector<Object> args) {
		Object result = null;
		return result;
	}

	public Object reduce_newAsRandomExpr(IASNode iNode, Object random_expr,
			Vector<Object> args) {
		Object result = null;
		return result;
	}

	public Object reduce_newEmptyArray(IASNode iNode) {
		Object result = null;
		return result;
	}

	public Object reduce_newEmptyObject(IASNode iNode) {
		Object result = null;
		return result;
	}

	public Object reduce_newExpr(IASNode iNode, Object class_Object,
			Vector<Object> args) {

		return reduce_functionCall_common(iNode, class_Object, args, true, true);
	}

	public Object reduce_newVectorLiteral(IASNode iNode, Object literal) {
		return literal;
	}

	public Object reduce_nilExpr_to_expression(IASNode iNode) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_nullLiteral_to_constant_value(IASNode iNode) {
		return new DebuggerValue(null);
	}

	public Object reduce_nullLiteral_to_object_literal(IASNode iNode) {
		return new DebuggerValue(null);
	}

	public Object reduce_objectLiteral(IASNode iNode, Vector<Object> elements) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_objectLiteralElement(IASNode iNode, Object id,
			Object value) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_parameterizedTypeName(IASNode iNode, Object base,
			Object param) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_parameterizedTypeExpression(IASNode iNode,
			Object base, Object param) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_postDecBracketExpr(IASNode iNode, Object stem,
			Object index, boolean need_result) {

		return reduce_postDecMemberExpr(iNode, stem, index, need_result);
	}

	public Object reduce_postDecMemberExpr(IASNode iNode, Object stem,
			Object field, boolean need_result) {
		try {
			DebuggerValue lhs = (DebuggerValue) stem;
			Context context = contextStack.scope();
			Context newContext = context.createContext(lhs.debuggerValue);
			contextStack.pushScope(newContext);
			return reduce_prePostIncDecExpr(iNode, field, true, false);
		} finally {
			contextStack.popScope();
		}
	}

	public Object reduce_postDecNameExpr(IASNode iNode, Object unary,
			boolean need_result) {
		return reduce_prePostIncDecExpr(iNode, unary, true, false);
	}

	public Object reduce_postIncBracketExpr(IASNode iNode, Object stem,
			Object index, boolean need_result) {
		return reduce_postIncMemberExpr(iNode, stem, index, need_result);
	}

	public Object reduce_postIncMemberExpr(IASNode iNode, Object stem,
			Object field, boolean need_result) {
		try {
			DebuggerValue lhs = (DebuggerValue) stem;
			Context context = contextStack.scope();
			Context newContext = context.createContext(lhs.debuggerValue);
			contextStack.pushScope(newContext);
			return reduce_prePostIncDecExpr(iNode, field, true, true);
		} finally {
			contextStack.popScope();
		}
	}

	public Object reduce_postIncNameExpr(IASNode iNode, Object unary,
			boolean need_result) {
		return reduce_prePostIncDecExpr(iNode, unary, true, true);
	}

	public Object reduce_preDecBracketExpr(IASNode iNode, Object stem,
			Object index, boolean need_result) {
		return reduce_preDecMemberExpr(iNode, stem, index, need_result);
	}

	public Object reduce_preDecMemberExpr(IASNode iNode, Object stem,
			Object field, boolean need_result) {
		try {
			DebuggerValue lhs = (DebuggerValue) stem;
			Context context = contextStack.scope();
			Context newContext = context.createContext(lhs.debuggerValue);
			contextStack.pushScope(newContext);
			return reduce_prePostIncDecExpr(iNode, field, false, false);
		} finally {
			contextStack.popScope();
		}
	}

	public Object reduce_preDecNameExpr(IASNode iNode, Object unary,
			boolean need_result) {
		return reduce_prePostIncDecExpr(iNode, unary, false, false);
	}

	public Object reduce_preIncBracketExpr(IASNode iNode, Object stem,
			Object index, boolean need_result) {
		return reduce_preIncMemberExpr(iNode, stem, index, need_result);
	}

	public Object reduce_preIncMemberExpr(IASNode iNode, Object stem,
			Object field, boolean need_result) {
		try {
			DebuggerValue lhs = (DebuggerValue) stem;
			Context context = contextStack.scope();
			Context newContext = context.createContext(lhs.debuggerValue);
			contextStack.pushScope(newContext);
			return reduce_prePostIncDecExpr(iNode, field, false, true);
		} finally {
			contextStack.popScope();
		}
	}

	public Object reduce_preIncNameExpr(IASNode iNode, Object unary,
			boolean need_result) {
		return reduce_prePostIncDecExpr(iNode, unary, false, true);
	}

	public Object reduce_prePostIncDecExpr(IASNode iNode, Object unary,
			boolean isPostFix, boolean isIncrement) {
		try {
			DebuggerValue expr = (DebuggerValue) unary;
			Context debuggerContext = contextStack.scope();
			String memberName = ECMA.toString(debuggerContext.getSession(),
					debuggerContext.toValue(expr.debuggerValue));

			Object lookupResult = debuggerContext.lookup(memberName);

			double before = ECMA.toNumber(debuggerContext.getSession(),
					debuggerContext.toValue(lookupResult));
			double after;
			if (isIncrement) {
				after = before + 1;
			} else {
				after = before - 1;
			}
			debuggerContext.assign(memberName,
					debuggerContext.toValue(new Double(after)));

			Object result;
			if (isPostFix) {
				result = new Double(before);
			} else {
				result = new Double(after);
			}

			return new DebuggerValue(result);
		} catch (NoSuchVariableException e) {
			throw new ExpressionEvaluatorException(e);
		} catch (PlayerFaultException e) {
			throw new ExpressionEvaluatorException(e);
		}
	}

	public Object reduce_regexLiteral(IASNode iNode) {
		if (iNode instanceof RegExpLiteralNode) {
			RegExpLiteralNode rgXNode = (RegExpLiteralNode) iNode;
			String val = rgXNode.getValue(true);
			String flags;
			String re;
			if (val.length() > 0 && val.charAt(0) == '/') {
				int lastSlash = val.lastIndexOf('/');
				re = val.substring(1, lastSlash);
				flags = val.substring(lastSlash + 1);
			} else {
				re = val;
				flags = ""; //$NON-NLS-1$
			}
			Context eeContext = contextStack.scope();
			try {
				return new DebuggerValue(callFunction(eeContext, true,
						"RegExp", new Object[] { re, flags })); //$NON-NLS-1$
			} catch (PlayerDebugException e) {
				throw new ExpressionEvaluatorException(e);
			}
		}
		throw new ExpressionEvaluatorException("Unable to resolve regex");
	}

	public Object reduce_runtimeNameExpression(IASNode iNode, Object expr) {
		return expr;
	}

	/**
	 * Reduce an identifier node This just returns the name of the name
	 * currently.
	 */
	public Object reduce_simpleName(IASNode iNode) {
		return new DebuggerValue(((IdentifierNode) iNode).getName());
	}

	public Object reduce_declName(IASNode iNode) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_strictneqExpr(IASNode iNode, Object l, Object r) {
		Context eeContext = contextStack.scope();
		DebuggerValue lhs = (DebuggerValue) l;
		DebuggerValue rhs = (DebuggerValue) r;
		// ECMA 11.9.5
		return new DebuggerValue(new Boolean(!ECMA.strictEquals(
				eeContext.toValue(lhs.debuggerValue),
				eeContext.toValue(rhs.debuggerValue))));
	}

	public Object reduce_superAccess(IASNode iNode, Object qualified_name) {
		throw new ExpressionEvaluatorException(keywordNotAllowed("super")); //$NON-NLS-1$
	}

	public Object reduce_ternaryExpr(IASNode iNode, Object test,
			Object when_true, Object when_false) {
		DebuggerValue condition = (DebuggerValue) test;
		Context eeContext = contextStack.scope();
		boolean b = ECMA.toBoolean(eeContext.toValue(condition.debuggerValue));
		if (b) {
			return when_true;
		} else {
			return when_false;
		}
	}

	public Object reduce_typedVariableExpression(IASNode iNode,
			Object var_name, Object var_type) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	// transform_name_to_expression
	public Object reduce_typeof_expr(IASNode iNode, Object operand) {
		// ECMA 11.4.3
		Context eeContext = contextStack.scope();
		DebuggerValue arg = (DebuggerValue) operand;
		flash.tools.debugger.Value value = eeContext.toValue(arg.debuggerValue);
		switch (value.getType()) {
		case VariableType.UNDEFINED:
			return new DebuggerValue("undefined"); //$NON-NLS-1$
		case VariableType.NULL:
			return new DebuggerValue("object"); //$NON-NLS-1$
		case VariableType.BOOLEAN:
			return new DebuggerValue("boolean"); //$NON-NLS-1$
		case VariableType.NUMBER:
			return new DebuggerValue("number"); //$NON-NLS-1$
		case VariableType.STRING:
			return new DebuggerValue("string"); //$NON-NLS-1$
		case VariableType.OBJECT: {
			String typeName = value.getTypeName();
			int at = typeName.indexOf('@');
			if (at != -1)
				typeName = typeName.substring(0, at);
			if (typeName.equals("XML") || typeName.equals("XMLList")) //$NON-NLS-1$ //$NON-NLS-2$
				return new DebuggerValue("xml"); //$NON-NLS-1$
		}
		default:
			return new DebuggerValue("object"); //$NON-NLS-1$
		}
	}

	public Object reduce_typeof_name(IASNode iNode, Object object) {
		Object exprObject = transform_name_to_expression(iNode, object);
		return reduce_typeof_expr(iNode, exprObject);
	}

	public Object reduce_typeNameParameterAsType(IASNode iNode,
			Object type_param) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_vectorLiteral(IASNode iNode, Object type_param,
			Vector<Object> elements) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_voidExpr_to_type_name(IASNode node) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_void0Literal_to_constant_value(IASNode iNode) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_void0Literal_to_object_literal(IASNode iNode) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_void0Operator(IASNode iNode) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_voidOperator_to_constant_value(IASNode iNode,
			Object constant_value) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object reduce_voidOperator_to_expression(IASNode iNode, Object expr) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	/**
	 * The enumeration of states that the code generator finds interesting in an
	 * XML literal. There are states here than the reducer, below, doesn't
	 * consider especially interesting; see computeXMLContentStateMatrix() for
	 * their usage.
	 */
	@SuppressWarnings("unused")
	private enum XMLContentState {
	};

	public Object reduce_XMLContent(IASNode iNode, Vector<Object> exprs) {
		Object result = null;
		return result;
	}

	public Object reduce_XMLList(IASNode iNode, Vector<Object> exprs) {
		Object result = null;
		return result;
	}

	public Object reduce_XMLListConst(IASNode iNode, Vector<String> elements) {
		Object result = null;
		return result;
	}

	/*
	 * ******************************
	 * ** Transformation routines ** ******************************
	 */

	public Object transform_boolean_constant(IASNode iNode,
			Boolean boolean_constant) {
		Object result = new DebuggerValue(boolean_constant);
		return result;
	}

	public Object transform_double_constant(IASNode iNode,
			Double double_constant) {
		Object result = new DebuggerValue(double_constant);
		return result;
	}

	public Object transform_numeric_constant(IASNode iNode,
			Number numeric_constant) {
		Object result = new DebuggerValue(numeric_constant);
		;
		return result;
	}

	/**
	 * Transform any constant_value into an expression, so we can constant fold
	 * all sorts of expressions.
	 * 
	 * @param iNode
	 *            the node that generated the constant_value
	 * @param constant_value
	 *            the constant value
	 * @return an Object that contains instructions to push the constant_value
	 *         onto the stack.
	 */
	public Object transform_constant_value(IASNode iNode, Object constant_value) {
		return constant_value;
	}

	public Object transform_float_constant(IASNode iNode, Float float_constant) {
		Object result = new DebuggerValue(float_constant);
		return result;
	}

	/**
	 * transform a string_constant to a constant_value - essentially a no-op,
	 * but need a reduction so we can assign it a cost
	 */
	public Object transform_string_constant_to_constant(IASNode iNode,
			String string_constant) {
		return string_constant;
	}

	/**
	 * transform a boolean_constant to a constant_value - essentially a no-op,
	 * but need a reduction so we can assign it a cost
	 */
	public Object transform_boolean_constant_to_constant(IASNode iNode,
			Boolean boolean_constant) {
		return boolean_constant;
	}

	/**
	 * transform a numeric_constant to a constant_value - essentially a no-op,
	 * but need a reduction so we can assign it a cost
	 */
	public Object transform_numeric_constant_to_constant(IASNode iNode,
			Number numeric_constant) {
		if (numeric_constant instanceof Float) {
			return new DebuggerValue(new Double((Float) numeric_constant));
		} else {
			return new DebuggerValue(new Double((Double) numeric_constant));
		}

	}

	public Object transform_expression_to_constant_value(IASNode iNode,
			Object expression) {
		// return null - something higher up will report any appropriate
		// diagnostics.
		return null;
	}

	public Object transform_integer_constant(IASNode iNode,
			Integer integer_constant) {
		DebuggerValue result = new DebuggerValue(new Double(integer_constant));
		return result;
	}

	public Object transform_name_to_constant_value(IASNode iNode) {
		Object result = null;
		return result;
	}

	/**
	 * Transform a name into an expression. In the Code generator this generates
	 * code to get the name and put it on the stack, but for the debugger we
	 * probably just want to return the name.
	 */
	public Object transform_name_to_expression(IASNode iNode, Object name) {

		// ASC REFER : public Value evaluate(macromedia.asc.util.Context cx,
		// GetExpressionNode node)
		DebuggerValue identifier = (DebuggerValue) name;
		Context eeContext = contextStack.scope();
		String nameStr = ECMA.toString(eeContext.getSession(),
				eeContext.toValue(identifier.debuggerValue));
		flash.tools.debugger.Value contextValue = eeContext.toValue();
		/**
		 * When contextValue is XMLList and a child node has been accessed, the
		 * context used to resolve variables within [] operator will be a
		 * FlashValueContext while rhs.debuggerValue will be a
		 * FlexLocalVariable. The fix for FB-25660 makes sure
		 * FlashValueContext.toValue(o) checks this case and returns
		 * getFlashVariable().getValue(). We still need to check if this Value
		 * is of type Number so that the if check below behaves correctly.
		 */
		if (contextValue != null && isXMLType(contextValue)
				&& !isNumericIndex(iNode, identifier.debuggerValue, eeContext)) {
			String function;
			Object arg;

			if (nameStr.length() > 0 && nameStr.charAt(0) == '@') {
				// expression is node.@attr, so we call node.attribute("attr")
				function = "attribute"; //$NON-NLS-1$
				arg = nameStr.substring(1);
			} else {
				arg = identifier.debuggerValue;
				boolean isDecendentsOpr = (iNode.getNodeID() == ASTNodeID.Op_DescendantsID);
				if (isDecendentsOpr) {// node.getMode() ==
										// Tokens.DOUBLEDOT_TOKEN) {
					// expression is node..tag, so we call
					// node.descendants("tag")
					function = "descendants"; //$NON-NLS-1$
				} else {
					// expression is node.tag, so we call node.child("tag")
					function = "child"; //$NON-NLS-1$
				}
			}

			try {
				return new DebuggerValue(callFunction(eeContext, false,
						function, new Object[] { arg }));
			} catch (PlayerDebugException e) {
				throw new ExpressionEvaluatorException(e);
			}
		} else if (contextValue != null
				&& contextValue.getType() == VariableType.STRING
				&& ((DebuggerValue) name).debuggerValue.equals("length")) //$NON-NLS-1$
		{
			String valuestr = contextValue.getValueAsString();
			return new DebuggerValue(new Double(valuestr.length()));
		} else {
			Object lookupResult;
			try {
				lookupResult = eeContext.lookup(ECMA.toString(
						eeContext.getSession(),
						eeContext.toValue(identifier.debuggerValue)));
			} catch (NoSuchVariableException e) {
				throw new ExpressionEvaluatorException(e);
			} catch (PlayerFaultException e) {
				throw new ExpressionEvaluatorException(e);
			}
			return new DebuggerValue(lookupResult);
		}
	}

	public Object transform_non_resolving_identifier(IASNode iNode,
			String non_resolving_identifier) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object transform_runtime_name_expression(IASNode iNode,
			Object runtime_name_expression) {
		throw new ExpressionEvaluatorException(ASTBuilder
				.getLocalizationManager().getLocalizedTextString(
						"unsupportedExpression")); //$NON-NLS-1$
	}

	public Object transform_string_constant(IASNode iNode,
			String string_constant) {
		return new DebuggerValue(string_constant);
	}

	public Object transform_uint_constant(IASNode iNode, Long uint_constant) {
		Object result = new DebuggerValue(uint_constant);
		return result;
	}

	/**
	 * Generate a unary operator.
	 * 
	 * @param operand
	 *            - the operand expression.
	 * @param opcode
	 *            - the operator's opcode.
	 * @return an Object that applies the operator to the operand.
	 */
	Object unaryOp(IASNode iNode, Object operand, int opcode) {
		// REFER ASC public Value evaluate(macromedia.asc.util.Context cx,
		// UnaryExpressionNode node)
		DebuggerValue arg = (DebuggerValue) operand;
		Context eeContext = contextStack.scope();
		switch (opcode) {
		case ABCConstants.OP_returnvoid:
			// ECMA 11.4.2
			eeContext.toValue(arg.debuggerValue);
			return new DebuggerValue(flash.tools.debugger.Value.UNDEFINED);
		case ABCConstants.OP_typeof: {
			return reduce_typeof_expr(iNode, operand);
		}
		case ABCConstants.OP_convert_d:
		case ABCConstants.OP_unplus: {
			// ECMA 11.4.6
			return new DebuggerValue(new Double(ECMA.toNumber(
					eeContext.getSession(),
					eeContext.toValue(arg.debuggerValue))));
		}
		case ABCConstants.OP_negate: {
			// ECMA 11.4.7
			return new DebuggerValue(new Double(-ECMA.toNumber(
					eeContext.getSession(),
					eeContext.toValue(arg.debuggerValue))));
		}
		case ABCConstants.OP_bitnot: {
			// ECMA 11.4.8
			return new DebuggerValue(new Double(~ECMA.toInt32(
					eeContext.getSession(),
					eeContext.toValue(arg.debuggerValue))));
		}
		case ABCConstants.OP_not: {
			// ECMA 11.4.9
			return new DebuggerValue(new Boolean(!ECMA.toBoolean(eeContext
					.toValue(arg.debuggerValue))));
		}
		default:
			throw new UnsupportedOperationException();
		}
	}

	Object errorPackageName(IASNode iNode, String qualifiers, String base_name) {
		return null;
	}

	// myxml[3] or myxml["3"] is handled differently from myxml["childtag"].
	// This function takes the part in the brackets, and returns true if it
	// is a number or a string that can be converted to a number.
	private boolean isNumericIndex(IASNode node, Object index, Context context) {
		// if (node.getMode() != Tokens.LEFTBRACKET_TOKEN)
		if (node.getNodeID() != ASTNodeID.ArrayIndexExpressionID)
			return false; // it is node.member or node..member or whatever, but
							// not node[member]

		if (index instanceof Double) {
			return true; // it is node[number]
		} else if (index instanceof String) {
			String s = (String) index;

			if (s.length() == 0) {
				return false;
			} else {
				try {
					Double.parseDouble(s);
					return true; // it is node["number"]
				} catch (NumberFormatException e) {
					return false;
				}
			}
		} else if (context != null && index != null) {
			// Resolve the Value to see if it is a Number
			flash.tools.debugger.Value value = context.toValue(index);
			if (value != null && value.getType() == VariableType.NUMBER) {
				return true;
			}
			return false;
		} else {
			return false;
		}
	}

	private boolean isXMLType(flash.tools.debugger.Value value) {
		String typename = value.getTypeName();
		int at = typename.indexOf('@');
		if (at != -1)
			typename = typename.substring(0, at);
		return typename.equals("XML") || typename.equals("XMLList"); //$NON-NLS-1$ //$NON-NLS-2$
	}

	private String keywordNotAllowed(String keyword) {
		Map<String, String> parameters = new HashMap<String, String>();
		parameters.put("keyword", keyword); //$NON-NLS-1$
		return ASTBuilder.getLocalizationManager().getLocalizedTextString(
				"keywordNotAllowed", parameters); //$NON-NLS-1$
	}

	/**
	 * @param expressionNode
	 * @param expression
	 * @return
	 */
	public Object reduceLazyExpression(final IASNode expressionNode) {

		UnEvaluatedDebugExpression delayedEvaluator = new UnEvaluatedDebugExpression() {

			@Override
			public DebuggerValue evaluate(Context eeContext) {
				try {
					IExpressionEvaluator evalutor = new DebuggerExpressionEvaluator(
							project);

					return evalutor.evaluate(eeContext, expressionNode);
				} catch (Exception e) {
					throw new ExpressionEvaluatorException(e);
				}
			}
		};

		return delayedEvaluator;
	}

	private static abstract class UnEvaluatedDebugExpression {

		public abstract DebuggerValue evaluate(Context eeContext);
	}

}
