/*
 * Written by Jeff Dyer
 * Copyright (c) 1998-2003 Mountain View Compiler Company
 * All rights reserved.
 */

package macromedia.asc.parser;

import macromedia.asc.semantics.*;
import macromedia.asc.util.*;

/**
 * Node
 *
 * @author Jeff Dyer
 */
public class BoxNode extends Node
{
	public Node expr;
	public TypeValue actual;

	public BoxNode(Node expr, TypeValue actual)
	{
		this.expr = expr;
		this.actual = actual;
		void_result = false;
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

	public boolean isLiteralInteger()
	{
		return expr.isLiteralInteger();
	}


	public boolean void_result;

	public void voidResult()
	{
		void_result = true;
		expr.voidResult();
	}
}
