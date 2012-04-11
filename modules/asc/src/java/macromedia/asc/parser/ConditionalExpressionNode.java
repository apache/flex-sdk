/*
 * Written by Jeff Dyer
 * Copyright (c) 1998-2003 Mountain View Compiler Company
 * All rights reserved.
 */

package macromedia.asc.parser;

import macromedia.asc.util.*;
import macromedia.asc.semantics.*;

/**
 * Node
 *
 * @author Jeff Dyer
 */
public class ConditionalExpressionNode extends Node
{
	public Node condition;
	public Node thenexpr;
	public Node elseexpr;

    public Value thenvalue;
    public Value elsevalue;

	public ConditionalExpressionNode(Node condition, Node thenexpr, Node elseexpr)
	{
		this.condition = condition;
		this.thenexpr = thenexpr;
		this.elseexpr = elseexpr;
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
	
	public void voidResult()
	{
		this.thenexpr.voidResult();
		this.elseexpr.voidResult();
	}

	public String toString()
	{
		return "ConditionalExpression";
	}
}
