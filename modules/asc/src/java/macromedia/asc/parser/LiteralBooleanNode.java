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
public class LiteralBooleanNode extends Node
{
	public boolean value;
	public boolean void_result;

    public LiteralBooleanNode(boolean value)
	{
		this.value = value;
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

    public boolean isLiteral()
    {
        return true;
    }

	public void voidResult()
	{
		void_result = true;
	}

	public boolean isBooleanExpression()
	{
		return true;
	}

	public String toString()
	{
		return "LiteralBoolean";
	}
}
