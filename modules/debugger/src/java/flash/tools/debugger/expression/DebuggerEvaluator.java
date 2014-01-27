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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import macromedia.asc.parser.*;
import macromedia.asc.semantics.ObjectValue;
import macromedia.asc.semantics.Value;
import flash.tools.debugger.PlayerDebugException;
import flash.tools.debugger.Session;
import flash.tools.debugger.Variable;
import flash.tools.debugger.VariableType;
import flash.tools.debugger.concrete.DValue;

/**
 * A visitor that evaluates a debugger expression.
 * 
 * One thing that is very confusing about this code is that unfortunately, the
 * debugger code and the compiler code declare several classes and interfaces
 * that have the same names, but in different packages. So whenever you see a
 * "Value", be careful, it might be either a macromedia.asc.semantics.Value or a
 * flash.tools.debugger.Value; and whenever you see a "Context", it might be
 * either a macromedia.asc.util.Context or a
 * flash.tools.debugger.expression.Context.
 * 
 * @see DebuggerExpression
 * @author Mike Morearty
 */
class DebuggerEvaluator implements Evaluator
{

	/**
	 * Instances of this class are returned from most of the evaluate()
	 * functions of DebuggerEvaluator.
	 */
	public static class DebuggerValue extends Value
	{
		public Object debuggerValue;

		public DebuggerValue(Object v)
		{
			debuggerValue = v;
		}
	}

	/**
	 * Instances of this class are passed to cx.pushScope().
	 */
	public static class ExpressionEvaluatorScope extends ObjectValue
	{
		public ExpressionEvaluatorScope(Context expressionEvaluatorContext)
		{
			this.expressionEvaluatorContext = expressionEvaluatorContext;
		}

		public Context expressionEvaluatorContext;
	}

	private Context eeContext(macromedia.asc.util.Context cx)
	{
		return ((ExpressionEvaluatorScope) cx.scope()).expressionEvaluatorContext;
	}

	public boolean checkFeature(macromedia.asc.util.Context cx, Node node)
	{
		return true;
	}

	public Value evaluate(macromedia.asc.util.Context cx, Node node)
	{
		return null;
	}

	public Value evaluate(macromedia.asc.util.Context cx, IncrementNode node)
	{
		try
		{
			Context debuggerContext = eeContext(cx);
			DebuggerValue expr = (DebuggerValue) getOrSet(cx, node);
			String memberName = ECMA
					.toString(debuggerContext.getSession(), debuggerContext.toValue(expr.debuggerValue));

			Object lookupResult = debuggerContext.lookup(memberName);

			double before = ECMA.toNumber(debuggerContext.getSession(), debuggerContext.toValue(lookupResult));
			double after;

			assert node.op == Tokens.MINUSMINUS_TOKEN || node.op == Tokens.PLUSPLUS_TOKEN;
			if (node.op == Tokens.MINUSMINUS_TOKEN)
			{
				after = before - 1;
			}
			else
			{
				after = before + 1;
			}

			debuggerContext.assign(memberName, debuggerContext.toValue(new Double(after)));

			Object result;
			if (node.isPostfix)
			{
				result = new Double(before);
			}
			else
			{
				result = new Double(after);
			}

			return new DebuggerValue(result);
		}
		catch (NoSuchVariableException e)
		{
			throw new ExpressionEvaluatorException(e);
		}
		catch (PlayerFaultException e)
		{
			throw new ExpressionEvaluatorException(e);
		}
	}

	public Value evaluate(macromedia.asc.util.Context cx, DeleteExpressionNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("delete")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, IdentifierNode node)
	{
		String name;
		if (node.isAttr())
			name = "@" + node.name; //$NON-NLS-1$
		else
			name = node.name;
		return new DebuggerValue(name);
	}

	// InvokeNode is used with E4X and for...in.
	public Value evaluate(macromedia.asc.util.Context cx, InvokeNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("expressionNotSupported")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, ThisExpressionNode node)
	{
		try
		{
			return new DebuggerValue(eeContext(cx).lookup("this")); //$NON-NLS-1$
		}
		catch (NoSuchVariableException e)
		{
			throw new ExpressionEvaluatorException(e);
		}
		catch (PlayerFaultException e)
		{
			throw new ExpressionEvaluatorException(e);
		}
	}

	public Value evaluate(macromedia.asc.util.Context cx, QualifiedIdentifierNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, QualifiedExpressionNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, LiteralBooleanNode node)
	{
		return new DebuggerValue(new Boolean(node.value));
	}

	public Value evaluate(macromedia.asc.util.Context cx, LiteralNumberNode node)
	{
		//anirudhs - Fix for FB-25692. Append p0 so that Double(s) works for hex.
		//p stands for binary exponent.
		String numberStr = node.value;
		if ( numberStr != null && 
                     (numberStr.startsWith("0x") || numberStr.startsWith("0X")) ) { //$NON-NLS-1$ //$NON-NLS-2$
			numberStr += "p0"; //$NON-NLS-1$
		}
		return new DebuggerValue(new Double(numberStr));
	}

	public Value evaluate(macromedia.asc.util.Context cx, LiteralStringNode node)
	{
		return new DebuggerValue(node.value);
	}

	public Value evaluate(macromedia.asc.util.Context cx, LiteralNullNode node)
	{
		return new DebuggerValue(null);
	}

	public Value evaluate(macromedia.asc.util.Context cx, LiteralRegExpNode node)
	{
		String re, flags;
		if (node.value.length() > 0 && node.value.charAt(0) == '/')
		{
			int lastSlash = node.value.lastIndexOf('/');
			re = node.value.substring(1, lastSlash);
			flags = node.value.substring(lastSlash + 1);
		}
		else
		{
			re = node.value;
			flags = ""; //$NON-NLS-1$
		}

		try
		{
			return new DebuggerValue(callFunction(eeContext(cx), true, "RegExp", new Object[] { re, flags })); //$NON-NLS-1$
		}
		catch (PlayerDebugException e)
		{
			throw new ExpressionEvaluatorException(e);
		}
	}

	public Value evaluate(macromedia.asc.util.Context cx, LiteralXMLNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("xmlLiteralsNotSupported")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, FunctionCommonNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("functionDefinitionNotAllowed")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, ParenExpressionNode node)
	{
		return node.expr.evaluate(cx, this);
	}

	public Value evaluate(macromedia.asc.util.Context cx, ParenListExpressionNode node)
	{
		return node.expr.evaluate(cx, this);
	}

	public Value evaluate(macromedia.asc.util.Context cx, LiteralObjectNode node)
	{
		// e.g. "var v = { foo:3 }"
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("literalObjectsNotSupported")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, LiteralFieldNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("literalObjectsNotSupported")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, LiteralArrayNode node)
	{
		List<Object> arrayElements = new ArrayList<Object>();
		if (node.elementlist != null && node.elementlist.items != null)
		{
			for (Node arrayEntry : node.elementlist.items)
			{
				DebuggerValue dv = (DebuggerValue) arrayEntry.evaluate(cx, this);
				arrayElements.add(dv.debuggerValue);
			}
		}

		try
		{
			Context eeContext = eeContext(cx);
			Object array = callFunction(eeContext, true, "Array", new Object[0]); //$NON-NLS-1$
			return new DebuggerValue(callFunction(eeContext.createContext(array), false,
					"concat", arrayElements.toArray())); //$NON-NLS-1$
		}
		catch (PlayerDebugException e)
		{
			throw new ExpressionEvaluatorException(e);
		}
	}

	public Value evaluate(macromedia.asc.util.Context cx, LiteralVectorNode node)
	{
		/*
		List<Object> arrayElements = new ArrayList<Object>();

		if (node.elementlist != null && node.elementlist.items != null)
		{
			for (Node arrayEntry : node.elementlist.items)
			{
				DebuggerValue dv = (DebuggerValue) arrayEntry.evaluate(cx, this);
				arrayElements.add(dv.debuggerValue);
			}
		}

		try
		{
			Context eeContext = eeContext(cx);
			Object vector = ... what?  Need to call applytype here, but that's not implemented.
			return new DebuggerValue(callFunction(eeContext.createContext(array), false,
					"concat", arrayElements.toArray())); //$NON-NLS-1$
		}
		catch (PlayerDebugException e)
		{
			throw new ExpressionEvaluatorException(e);
		}
		*/
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, SuperExpressionNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("super")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, SuperStatementNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("super")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, MemberExpressionNode node)
	{
		DebuggerValue lhs = (node.base != null) ? (DebuggerValue) node.base.evaluate(cx, this) : null;
		Context context = eeContext(cx);
		boolean pushedScope = false;
		if (lhs != null)
		{
			flash.tools.debugger.Value lhsValue = context.toValue(lhs.debuggerValue);
			if (ECMA.equals(context.getSession(), lhsValue, context.toValue(null)))
				throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("nullPointerException")); //$NON-NLS-1$

			Context newContext = context.createContext(lhs.debuggerValue);
			cx.pushScope(new ExpressionEvaluatorScope(newContext));
			pushedScope = true;
		}

		try
		{
			return node.selector.evaluate(cx, this);
		}
		finally
		{
			if (pushedScope)
				cx.popScope();
		}
	}

	public Value evaluate(macromedia.asc.util.Context cx, CallExpressionNode node)
	{
		assert (node.getMode() == Tokens.LEFTBRACKET_TOKEN || // base[expr]
				node.getMode() == Tokens.LEFTPAREN_TOKEN || // base.(expr)
				node.getMode() == Tokens.DOUBLEDOT_TOKEN || // base..expr
				node.getMode() == Tokens.EMPTY_TOKEN || // expr
				node.getMode() == Tokens.DOT_TOKEN); // base.expr

		DebuggerValue func = null;
		Context context = eeContext(cx);
		func = (DebuggerValue) node.expr.evaluate(cx, this);

		int argcount = (node.args != null) ? node.args.items.size() : 0;
		List<Object> args = new ArrayList<Object>(argcount);
		if (argcount > 0)
		{
			boolean temporarilyRemoveTopScope = (node.getMode() == Tokens.DOT_TOKEN);
			ObjectValue topScope = null;

			if (temporarilyRemoveTopScope)
			{
				topScope = cx.scope();
				cx.popScope();
			}

			try
			{
				for (Node argNode : node.args.items)
				{
					DebuggerValue argValue = (DebuggerValue) argNode.evaluate(cx, this);
					args.add(argValue.debuggerValue);
				}
			}
			finally
			{
				if (temporarilyRemoveTopScope)
				{
					cx.pushScope(topScope);
				}
			}
		}

		try
		{
			return new DebuggerValue(callFunction(context, node.is_new, func.debuggerValue, args.toArray()));
		}
		catch (PlayerDebugException e)
		{
			throw new ExpressionEvaluatorException(e);
		}
	}

	private Object callFunction(Context cx, boolean isConstructor, Object function, Object[] args)
			throws PlayerDebugException
	{
		Session session = cx.getSession();

		flash.tools.debugger.Value thisObject = cx.toValue();
		if (thisObject == null)
			thisObject = DValue.forPrimitive(null);

		flash.tools.debugger.Value[] valueArgs = new flash.tools.debugger.Value[args.length];
		for (int i = 0; i < args.length; ++i) {
			/**
			 * context.toValue() may return null while PlayerSession::buildCallFunctionMessage
			 * expects the Value to be a value that depicts null. For example,
			 * xmlVar.childNode[nonexistentornullvar] will run into this case.
			 * (Came to notice via bug FB-25660)
			 */
			flash.tools.debugger.Value tempValue = cx.toValue(args[i]);
			if ( tempValue == null ) {
				tempValue = DValue.forPrimitive(null);
			}
			valueArgs[i] = tempValue;	
		}			


		String functionName;
		if (function instanceof Variable)
		{
			// Sometimes, the function will show up as a Variable. This happens,
			// for example, if the user wrote "MyClass.myFunction = function() {
			// ... }";
			// String.fromCharCode(), for example, is defined that way.
			functionName = ((Variable) function).getQualifiedName();
		}
		else
		{
			functionName = function.toString();
		}

		if (isConstructor)
		{
			return session.callConstructor(functionName, valueArgs);
		}
		else
		{
			return session.callFunction(thisObject, functionName, valueArgs);
		}
	}

	private boolean isXMLType(flash.tools.debugger.Value value)
	{
		String typename = value.getTypeName();
		int at = typename.indexOf('@');
		if (at != -1)
			typename = typename.substring(0, at);
		return typename.equals("XML") || typename.equals("XMLList"); //$NON-NLS-1$ //$NON-NLS-2$
	}

	// myxml[3] or myxml["3"] is handled differently from myxml["childtag"].
	// This function takes the part in the brackets, and returns true if it
	// is a number or a string that can be converted to a number.
	private boolean isNumericIndex(GetExpressionNode node, Object index, Context context) {
		if (node.getMode() != Tokens.LEFTBRACKET_TOKEN)
			return false; // it is node.member or node..member or whatever, but not node[member]

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
			//Resolve the Value to see if it is a Number
			flash.tools.debugger.Value value = context.toValue(index);
			if (value != null && value.getType() == VariableType.NUMBER) {
				return true;
			}
			return false;
		}		
		else {
			return false;
		}
	}

	public Value evaluate(macromedia.asc.util.Context cx, GetExpressionNode node)
	{
		DebuggerValue rhs = (DebuggerValue) getOrSet(cx, node);
		Context context = eeContext(cx);
		String name = ECMA.toString(context.getSession(), context.toValue(rhs.debuggerValue));
		flash.tools.debugger.Value contextValue = context.toValue();
		/**
		 * When contextValue is XMLList and a child node has been accessed, 
		 * the context used to resolve variables within [] operator will 
		 * be a FlashValueContext while rhs.debuggerValue will be a FlexLocalVariable.
		 * The fix for FB-25660 makes sure FlashValueContext.toValue(o) checks this
		 * case and returns getFlashVariable().getValue(). We still need to check if
		 * this Value is of type Number so that the if check below behaves correctly.
		 */
		if (contextValue != null && isXMLType(contextValue) && !isNumericIndex(node, rhs.debuggerValue, context))
		{
			String function;
			Object arg;

			if (name.length() > 0 && name.charAt(0) == '@')
			{
				// expression is node.@attr, so we call node.attribute("attr")
				function = "attribute"; //$NON-NLS-1$
				arg = name.substring(1);
			}
			else
			{
				arg = rhs.debuggerValue;
				if (node.getMode() == Tokens.DOUBLEDOT_TOKEN)
				{
					// expression is node..tag, so we call node.descendants("tag")
					function = "descendants"; //$NON-NLS-1$
				}
				else
				{
					// expression is node.tag, so we call node.child("tag")
					function = "child"; //$NON-NLS-1$
				}
			}

			try
			{
				return new DebuggerValue(callFunction(context, false, function, new Object[] { arg }));
			}
			catch (PlayerDebugException e)
			{
				throw new ExpressionEvaluatorException(e);
			}
		}
		else if (contextValue != null && contextValue.getType() == VariableType.STRING && name.equals("length")) //$NON-NLS-1$
		{
			String valuestr = contextValue.getValueAsString();
			return new DebuggerValue(new Double(valuestr.length()));
		}
		else
		{
			Object lookupResult;
			try
			{
				lookupResult = context.lookup(ECMA.toString(eeContext(cx).getSession(), eeContext(cx).toValue(
						rhs.debuggerValue)));
			}
			catch (NoSuchVariableException e)
			{
				throw new ExpressionEvaluatorException(e);
			}
			catch (PlayerFaultException e)
			{
				throw new ExpressionEvaluatorException(e);
			}
			return new DebuggerValue(lookupResult);
		}
	}

	public Value getOrSet(macromedia.asc.util.Context cx, SelectorNode node)
	{
		assert (node.getMode() == Tokens.LEFTBRACKET_TOKEN || // base[expr]
				node.getMode() == Tokens.LEFTPAREN_TOKEN || // base.(expr)
				node.getMode() == Tokens.DOUBLEDOT_TOKEN || // base..expr
				node.getMode() == Tokens.EMPTY_TOKEN || // expr
				node.getMode() == Tokens.DOT_TOKEN); // base.expr

		cx.pushScope(cx.scope(0));
		try
		{
			return node.expr.evaluate(cx, this);
		}
		finally
		{
			cx.popScope();
		}
	}

	public Value evaluate(macromedia.asc.util.Context cx, SetExpressionNode node)
	{
		Context eeContext = eeContext(cx);
		DebuggerValue rhs = (DebuggerValue) getOrSet(cx, node);
		Object variableToAssignTo;
		if (node.getMode() == Tokens.LEFTBRACKET_TOKEN || node.getMode() == Tokens.EMPTY_TOKEN)
		{
			variableToAssignTo = ECMA.toString(eeContext.getSession(), eeContext.toValue(rhs.debuggerValue));
		}
		else
		{
			variableToAssignTo = rhs.debuggerValue;
		}

		DebuggerValue newValue = null;
		cx.pushScope(cx.scope(0)); // global scope
		try
		{
			newValue = (DebuggerValue) node.args.evaluate(cx, this);
		}
		finally
		{
			cx.popScope();
		}

		try
		{
			eeContext.assign(variableToAssignTo, eeContext.toValue(newValue.debuggerValue));
		}
		catch (NoSuchVariableException e)
		{
			throw new ExpressionEvaluatorException(e);
		}
		catch (PlayerFaultException e)
		{
			throw new ExpressionEvaluatorException(e);
		}
		return newValue;
	}

	public Value evaluate(macromedia.asc.util.Context cx, UnaryExpressionNode node)
	{
		DebuggerValue arg = (DebuggerValue) node.expr.evaluate(cx, this);
		switch (node.op)
		{
		case Tokens.VOID_TOKEN:
			// ECMA 11.4.2
			eeContext(cx).toValue(arg.debuggerValue);
			return new DebuggerValue(flash.tools.debugger.Value.UNDEFINED);
		case Tokens.TYPEOF_TOKEN:
		{
			// ECMA 11.4.3
			flash.tools.debugger.Value value = eeContext(cx).toValue(arg.debuggerValue);
			switch (value.getType())
			{
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
			case VariableType.OBJECT:
			{
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
		case Tokens.PLUS_TOKEN:
		{
			// ECMA 11.4.6
			return new DebuggerValue(new Double(ECMA.toNumber(eeContext(cx).getSession(), eeContext(cx).toValue(
					arg.debuggerValue))));
		}
		case Tokens.MINUS_TOKEN:
		{
			// ECMA 11.4.7
			return new DebuggerValue(new Double(-ECMA.toNumber(eeContext(cx).getSession(), eeContext(cx).toValue(
					arg.debuggerValue))));
		}
		case Tokens.BITWISENOT_TOKEN:
		{
			// ECMA 11.4.8
			return new DebuggerValue(new Double(~ECMA.toInt32(eeContext(cx).getSession(), eeContext(cx).toValue(
					arg.debuggerValue))));
		}
		case Tokens.NOT_TOKEN:
		{
			// ECMA 11.4.9
			return new DebuggerValue(new Boolean(!ECMA.toBoolean(eeContext(cx).toValue(arg.debuggerValue))));
		}
		default:
			cx.internalError(ASTBuilder.getLocalizationManager().getLocalizedTextString("unrecognizedUnaryOperator")); //$NON-NLS-1$
			return null;
		}
	}

	public Value evaluate(macromedia.asc.util.Context cx, BinaryExpressionNode node)
	{
		DebuggerValue lhs = (DebuggerValue) node.lhs.evaluate(cx, this);
		DebuggerValue rhs = null;

		// for the logical ops, we must not evaluate the right side yet
		if (node.op != Tokens.LOGICALAND_TOKEN && node.op != Tokens.LOGICALOR_TOKEN)
		{
			rhs = (DebuggerValue) node.rhs.evaluate(cx, this);
		}

		Context eeContext = eeContext(cx);
		Session session = eeContext.getSession();
		switch (node.op)
		{
		case Tokens.MULT_TOKEN:
		{
			// ECMA 11.5
			double d1 = ECMA.toNumber(session, eeContext.toValue(lhs.debuggerValue));
			double d2 = ECMA.toNumber(session, eeContext.toValue(rhs.debuggerValue));
			return new DebuggerValue(new Double(d1 * d2));
		}
		case Tokens.DIV_TOKEN:
		{
			// ECMA 11.5
			double d1 = ECMA.toNumber(session, eeContext.toValue(lhs.debuggerValue));
			double d2 = ECMA.toNumber(session, eeContext.toValue(rhs.debuggerValue));
			return new DebuggerValue(new Double(d1 / d2));
		}
		case Tokens.MODULUS_TOKEN:
		{
			// ECMA 11.5
			double d1 = ECMA.toNumber(session, eeContext.toValue(lhs.debuggerValue));
			double d2 = ECMA.toNumber(session, eeContext.toValue(rhs.debuggerValue));
			return new DebuggerValue(new Double(d1 % d2));
		}
		case Tokens.PLUS_TOKEN:
		{
			// E4X 11.4.1 and ECMA 11.6.1
			flash.tools.debugger.Value v1 = eeContext.toValue(lhs.debuggerValue);
			flash.tools.debugger.Value v2 = eeContext.toValue(rhs.debuggerValue);

			boolean isXMLConcat = false;
			
			if (v1.getType() == VariableType.OBJECT && v2.getType() == VariableType.OBJECT)
			{
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

			if (isXMLConcat)
			{
				try
				{
					flash.tools.debugger.Value xml1 = session.callFunction(v1, "toXMLString", new flash.tools.debugger.Value[0]); //$NON-NLS-1$
					flash.tools.debugger.Value xml2 = session.callFunction(v2, "toXMLString", new flash.tools.debugger.Value[0]); //$NON-NLS-1$
					String allXML = xml1.getValueAsString() + xml2.getValueAsString();
					flash.tools.debugger.Value allXMLValue = DValue.forPrimitive(allXML);
					flash.tools.debugger.Value retval = session.callConstructor("XMLList", new flash.tools.debugger.Value[] { allXMLValue }); //$NON-NLS-1$
					return new DebuggerValue(retval);
				}
				catch (PlayerDebugException e)
				{
					throw new ExpressionEvaluatorException(e);
				}
			}
			else
			{
				v1 = ECMA.toPrimitive(session, v1, null);
				v2 = ECMA.toPrimitive(session, v2, null);
				if (v1.getType() == VariableType.STRING || v2.getType() == VariableType.STRING)
				{
					return new DebuggerValue(ECMA.toString(session, v1) + ECMA.toString(session, v2));
				}
				else
				{
					return new DebuggerValue(new Double(ECMA.toNumber(session, v1) + ECMA.toNumber(session, v2)));
				}
			}
		}
		case Tokens.MINUS_TOKEN:
		{
			// ECMA 11.6.2
			double d1 = ECMA.toNumber(session, eeContext.toValue(lhs.debuggerValue));
			double d2 = ECMA.toNumber(session, eeContext.toValue(rhs.debuggerValue));
			return new DebuggerValue(new Double(d1 - d2));
		}
		case Tokens.LEFTSHIFT_TOKEN:
		{
			// ECMA 11.7.1
			int n1 = ECMA.toInt32(session, eeContext.toValue(lhs.debuggerValue));
			int n2 = (int) (ECMA.toUint32(session, eeContext.toValue(rhs.debuggerValue)) & 0x1F);
			return new DebuggerValue(new Double(n1 << n2));
		}
		case Tokens.RIGHTSHIFT_TOKEN:
		{
			// ECMA 11.7.1
			int n1 = ECMA.toInt32(session, eeContext.toValue(lhs.debuggerValue));
			int n2 = (int) (ECMA.toUint32(session, eeContext.toValue(rhs.debuggerValue)) & 0x1F);
			return new DebuggerValue(new Double(n1 >> n2));
		}
		case Tokens.UNSIGNEDRIGHTSHIFT_TOKEN:
		{
			// ECMA 11.7.1
			long n1 = ECMA.toUint32(session, eeContext.toValue(lhs.debuggerValue));
			long n2 = (ECMA.toUint32(session, eeContext.toValue(rhs.debuggerValue)) & 0x1F);
			return new DebuggerValue(new Double(n1 >>> n2));
		}
		case Tokens.LESSTHAN_TOKEN:
		{
			// ECMA 11.8.1
			flash.tools.debugger.Value lessThan = ECMA.lessThan(session, eeContext.toValue(lhs.debuggerValue), eeContext
					.toValue(rhs.debuggerValue));
			boolean result;
			if (lessThan.getType() == VariableType.UNDEFINED)
			{
				result = false;
			}
			else
			{
				result = ECMA.toBoolean(lessThan);
			}
			return new DebuggerValue(result);
		}
		case Tokens.GREATERTHAN_TOKEN:
		{
			// ECMA 11.8.2
			flash.tools.debugger.Value greaterThan = ECMA.lessThan(session, eeContext.toValue(rhs.debuggerValue), eeContext
					.toValue(lhs.debuggerValue));
			boolean result;
			if (greaterThan.getType() == VariableType.UNDEFINED)
			{
				result = false;
			}
			else
			{
				result = ECMA.toBoolean(greaterThan);
			}
			return new DebuggerValue(result);
		}
		case Tokens.LESSTHANOREQUALS_TOKEN:
		{
			// ECMA 11.8.3
			flash.tools.debugger.Value lessThan = ECMA.lessThan(session, eeContext.toValue(rhs.debuggerValue), eeContext
					.toValue(lhs.debuggerValue));
			boolean result;
			if (lessThan.getType() == VariableType.UNDEFINED)
			{
				result = false;
			}
			else
			{
				result = !ECMA.toBoolean(lessThan);
			}
			return new DebuggerValue(result);
		}
		case Tokens.GREATERTHANOREQUALS_TOKEN:
		{
			// ECMA 11.8.4
			flash.tools.debugger.Value lessThan = ECMA.lessThan(session, eeContext.toValue(lhs.debuggerValue), eeContext
					.toValue(rhs.debuggerValue));
			boolean result;
			if (lessThan.getType() == VariableType.UNDEFINED)
			{
				result = false;
			}
			else
			{
				result = !ECMA.toBoolean(lessThan);
			}
			return new DebuggerValue(result);
		}
		case Tokens.INSTANCEOF_TOKEN:
		{
			try {
				return new DebuggerValue(session.evalInstanceof(eeContext.toValue(lhs.debuggerValue), eeContext.toValue(rhs.debuggerValue)));
			} catch (PlayerDebugException e) {
				throw new ExpressionEvaluatorException(e);
			} catch (PlayerFaultException e) {
				throw new ExpressionEvaluatorException(e);
			}
		}
		case Tokens.IN_TOKEN:
		{
			try {
				return new DebuggerValue(session.evalIn(eeContext.toValue(lhs.debuggerValue), eeContext.toValue(rhs.debuggerValue)));
			} catch (PlayerDebugException e) {
				throw new ExpressionEvaluatorException(e);
			} catch (PlayerFaultException e) {
				throw new ExpressionEvaluatorException(e);
			}
		}
		case Tokens.IS_TOKEN:
		{
			try {
				return new DebuggerValue(session.evalIs(eeContext.toValue(lhs.debuggerValue), eeContext.toValue(rhs.debuggerValue)));
			} catch (PlayerDebugException e) {
				throw new ExpressionEvaluatorException(e);
			} catch (PlayerFaultException e) {
				throw new ExpressionEvaluatorException(e);
			}
		}
		case Tokens.AS_TOKEN:
		{
			try {
				return new DebuggerValue(session.evalAs(eeContext.toValue(lhs.debuggerValue), eeContext.toValue(rhs.debuggerValue)));
			} catch (PlayerDebugException e) {
				throw new ExpressionEvaluatorException(e);
			} catch (PlayerFaultException e) {
				throw new ExpressionEvaluatorException(e);
			}
		}
		case Tokens.EQUALS_TOKEN:
		{
			// ECMA 11.9.1
			return new DebuggerValue(new Boolean(ECMA.equals(session, eeContext.toValue(lhs.debuggerValue), eeContext
					.toValue(rhs.debuggerValue))));
		}
		case Tokens.NOTEQUALS_TOKEN:
		{
			// ECMA 11.9.2
			return new DebuggerValue(new Boolean(!ECMA.equals(session, eeContext.toValue(lhs.debuggerValue), eeContext
					.toValue(rhs.debuggerValue))));
		}
		case Tokens.STRICTEQUALS_TOKEN:
		{
			// ECMA 11.9.4
			return new DebuggerValue(new Boolean(ECMA.strictEquals(eeContext.toValue(lhs.debuggerValue), eeContext
					.toValue(rhs.debuggerValue))));
		}
		case Tokens.STRICTNOTEQUALS_TOKEN:
		{
			// ECMA 11.9.5
			return new DebuggerValue(new Boolean(!ECMA.strictEquals(eeContext.toValue(lhs.debuggerValue), eeContext
					.toValue(rhs.debuggerValue))));
		}
		case Tokens.BITWISEAND_TOKEN:
		{
			// ECMA 11.10
			return new DebuggerValue(new Double(ECMA.toInt32(session, eeContext.toValue(lhs.debuggerValue))
					& ECMA.toInt32(session, eeContext.toValue(rhs.debuggerValue))));
		}
		case Tokens.BITWISEXOR_TOKEN:
		{
			// ECMA 11.10
			return new DebuggerValue(new Double(ECMA.toInt32(session, eeContext.toValue(lhs.debuggerValue))
					^ ECMA.toInt32(session, eeContext.toValue(rhs.debuggerValue))));
		}
		case Tokens.BITWISEOR_TOKEN:
		{
			// ECMA 11.10
			return new DebuggerValue(new Double(ECMA.toInt32(session, eeContext.toValue(lhs.debuggerValue))
					| ECMA.toInt32(session, eeContext.toValue(rhs.debuggerValue))));
		}
		case Tokens.LOGICALAND_TOKEN:
		{
			// ECMA 11.11
			flash.tools.debugger.Value result = eeContext.toValue(lhs.debuggerValue);
			if (ECMA.toBoolean(result))
			{
				rhs = (DebuggerValue) node.rhs.evaluate(cx, this);
				result = eeContext.toValue(rhs.debuggerValue);
			}
			return new DebuggerValue(result);
		}
		case Tokens.LOGICALOR_TOKEN:
		{
			// ECMA 11.11
			flash.tools.debugger.Value result = eeContext.toValue(lhs.debuggerValue);
			if (!ECMA.toBoolean(result))
			{
				rhs = (DebuggerValue) node.rhs.evaluate(cx, this);
				result = eeContext.toValue(rhs.debuggerValue);
			}
			return new DebuggerValue(result);
		}
		case Tokens.EMPTY_TOKEN:
			// do nothing, already been folded
			return new DebuggerValue(null);
		default:
			cx.internalError(ASTBuilder.getLocalizationManager().getLocalizedTextString("unrecognizedBinaryOperator")); //$NON-NLS-1$
			return new DebuggerValue(null);
		}
	}

	public Value evaluate(macromedia.asc.util.Context cx, ConditionalExpressionNode node)
	{
		DebuggerValue condition = (DebuggerValue) node.condition.evaluate(cx, this);
		boolean b = ECMA.toBoolean(eeContext(cx).toValue(condition.debuggerValue));
		Node nodeToEval;
		if (b)
		{
			nodeToEval = node.thenexpr;
		}
		else
		{
			nodeToEval = node.elseexpr;
		}
		return nodeToEval.evaluate(cx, this);
	}

	public Value evaluate(macromedia.asc.util.Context cx, ArgumentListNode node)
	{
		// e.g. for "foo(3,4)", ArgumentListNode.items would contain a
		// LiteralNumberNode for 3, followed by a LiteralNumberNode for 4.
		// Also, for "x[3]", the "3" is represented as an ArgumentListNode.
		Value retval = null;
		for (Node n : node.items)
			retval = n.evaluate(cx, this);
		return retval;
	}

	public Value evaluate(macromedia.asc.util.Context cx, ListNode node)
	{
		Value retval = null;
		for (Node item : node.items)
		{
			retval = item.evaluate(cx, this);
		}
		return retval;
	}

	public Value evaluate(macromedia.asc.util.Context cx, StatementListNode node)
	{
		switch (node.items.size())
		{
		case 0:
			return null;
		case 1:
			return node.items.get(0).evaluate(cx, this);
		default:
			throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("StatementListNodeWIthMoreThanOneItem")); //$NON-NLS-1$
		}
	}

	/**
	 * Not sure what an EmptyElementNode really is, but you can get one with
	 * this odd line: "var x = [,3]"
	 */
	public Value evaluate(macromedia.asc.util.Context cx, EmptyElementNode node)
	{
		return null;
	}

	public Value evaluate(macromedia.asc.util.Context cx, EmptyStatementNode node)
	{
		return null;
	}

	public Value evaluate(macromedia.asc.util.Context cx, ExpressionStatementNode node)
	{
		return node.expr.evaluate(cx, this);
	}

	public Value evaluate(macromedia.asc.util.Context cx, LabeledStatementNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("labelsNotAllowed")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, IfStatementNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("if")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, SwitchStatementNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("switch")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, CaseLabelNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("case")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, DoStatementNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("do")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, WhileStatementNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("while")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, ForStatementNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("for")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, WithStatementNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("with")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, ContinueStatementNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("continue")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, BreakStatementNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("break")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, ReturnStatementNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("return")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, ThrowStatementNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("throw")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, TryStatementNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("try")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, CatchClauseNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("catch")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, FinallyClauseNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("finally")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, UseDirectiveNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("use")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, IncludeDirectiveNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("include")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, ImportNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("import")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, MetaDataNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("whatIsMetaDataNode")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, DocCommentNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("whatIsDocCommentNode")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, ImportDirectiveNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("import")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, AttributeListNode node)
	{
		return null;
	}

	public Value evaluate(macromedia.asc.util.Context cx, VariableDefinitionNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("var")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, VariableBindingNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("var")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, UntypedVariableBindingNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("var")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, TypedIdentifierNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("var")); //$NON-NLS-1$
	}

	/**
	 * A type, like "int" or "int!" or "int?"
	 */
	public Value evaluate(macromedia.asc.util.Context cx, TypeExpressionNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("typeNotExpected")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, FunctionDefinitionNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("functionDefinitionNotAllowed")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, BinaryFunctionDefinitionNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("functionDefinitionNotAllowed")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, FunctionNameNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("functionDefinitionNotAllowed")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, FunctionSignatureNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("functionDefinitionNotAllowed")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, ParameterNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, ParameterListNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, RestExpressionNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("functionDefinitionNotAllowed")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, RestParameterNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("functionDefinitionNotAllowed")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, InterfaceDefinitionNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("interfaceDefinitionNotAllowed")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, ClassDefinitionNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("classDefinitionNotAllowed")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, BinaryClassDefNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("classDefinitionNotAllowed")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, BinaryInterfaceDefinitionNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("interfaceDefinitionNotAllowed")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, ClassNameNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, InheritanceNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("classDefinitionNotAllowed")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, NamespaceDefinitionNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, ConfigNamespaceDefinitionNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, PackageDefinitionNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, PackageIdentifiersNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, PackageNameNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, ProgramNode node)
	{
		// Parser adds several special nodes. The last node is the one that
		// contains the expression that was actually parsed.
		Node st = node.statements.items.get(node.statements.items.size() - 1);
		return st.evaluate(cx, this);
	}

	public Value evaluate(macromedia.asc.util.Context cx, BinaryProgramNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("binaryProgramNodeUnexpected")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, ErrorNode node)
	{
		throw new ExpressionEvaluatorException(node.errorArg);
	}

	public Value evaluate(macromedia.asc.util.Context cx, ToObjectNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, LoadRegisterNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, StoreRegisterNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, RegisterNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, HasNextNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, BoxNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, CoerceNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, PragmaNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, PragmaExpressionNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, DefaultXMLNamespaceNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("default xml namespace")); //$NON-NLS-1$
	}

	// "use precision"
	public Value evaluate(macromedia.asc.util.Context cx, UsePrecisionNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("use")); //$NON-NLS-1$
	}

	// "use decimal", "use double", "use int", "use uint", "use Number"
	public Value evaluate(macromedia.asc.util.Context cx, UseNumericNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("use")); //$NON-NLS-1$
	}

	// "use rounding"
	public Value evaluate(macromedia.asc.util.Context cx, UseRoundingNode node)
	{
		throw new ExpressionEvaluatorException(keywordNotAllowed("use")); //$NON-NLS-1$
	}

	public Value evaluate(macromedia.asc.util.Context cx, ApplyTypeExprNode node)
	{
		throw new ExpressionEvaluatorException(ASTBuilder.getLocalizationManager().getLocalizedTextString("unsupportedExpression")); //$NON-NLS-1$
	}

	private String keywordNotAllowed(String keyword)
	{
		Map<String,String> parameters = new HashMap<String,String>();
		parameters.put("keyword", keyword); //$NON-NLS-1$
		return ASTBuilder.getLocalizationManager().getLocalizedTextString(
				"keywordNotAllowed", parameters); //$NON-NLS-1$
	}
}
