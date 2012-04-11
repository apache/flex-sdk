/*
 * Written by Jeff Dyer
 * Copyright (c) 1998-2003 Mountain View Compiler Company
 * All rights reserved.
 */

package macromedia.asc.parser;

import macromedia.asc.semantics.*;
import macromedia.asc.util.*;

import static macromedia.asc.parser.Tokens.*;

/**
 * Node
 *
 * @author Jeff Dyer
 */
public class UnaryExpressionNode extends Node
{
	public Node expr;
	public int op;
	public ReferenceValue ref;
	public Slot slot;
    public NumberUsage numberUsage;

	public UnaryExpressionNode(int op, Node expr)
	{
		this.op = op;
		this.expr = expr;
		void_result = false;
		slot = null;
		numberUsage = null;
	}

	public Value evaluate(Context cx, Evaluator evaluator)
	{
		if (evaluator.checkFeature(cx, this))
		{
			return evaluator.evaluate(cx, this);
		}
		else
		{
			return null;
		}
	}

	public boolean void_result;

	public void voidResult()
	{
		void_result = true;
		//expr.voidResult();
	}

	boolean isbooleaneanExpression()
	{
		return op == NOT_TOKEN ? true : false;
	}

	public String toString()
	{
		return "UnaryExpression";
	}
}
