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
public class BinaryExpressionNode extends Node
{
	public Node lhs;
	public Node rhs;
	public int op;
	public Slot slot;
    public TypeInfo lhstype;
    public TypeInfo rhstype;
    public NumberUsage numberUsage;

	public BinaryExpressionNode(int op, Node lhs, Node rhs)
	{
		this.op = op;
		slot = null;
		this.lhs = lhs;
		this.rhs = rhs;
		lhstype = null;
        rhstype = null;
		void_result = false;
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

	public boolean isBooleanExpression()
	{
		return
			op == NOTEQUALS_TOKEN ? true :
			op == STRICTNOTEQUALS_TOKEN ? true :
			op == LOGICALAND_TOKEN ? true :
			op == LOGICALXOR_TOKEN ? true :
			op == LOGICALXORASSIGN_TOKEN ? true :
			op == LOGICALOR_TOKEN ? true :
			op == LESSTHAN_TOKEN ? true :
			op == LESSTHANOREQUALS_TOKEN ? true :
			op == EQUALS_TOKEN ? true :
			op == STRICTEQUALS_TOKEN ? true :
			op == GREATERTHAN_TOKEN ? true :
			op == GREATERTHANOREQUALS_TOKEN ? true : false;
	}

	public String toString()
	{
		return "BinaryExpression";
	}

	public boolean void_result;

	public void voidResult()
	{
		void_result = true;
	}
}
