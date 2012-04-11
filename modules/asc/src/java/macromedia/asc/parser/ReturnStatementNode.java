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
public class ReturnStatementNode extends Node
{
	public Node expr;
	public boolean finallyInserted;
	
	public ReturnStatementNode(Node expr)
	{
		this.expr = expr;
		this.finallyInserted = false;
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

	public boolean isBranch()
	{
		return true;
	}

	public boolean isFinallyInserted()
	{
		return finallyInserted;
	}

	public void setFinallyInserted()
	{
		finallyInserted = true;
	}
	
	public String toString()
	{
		return "ReturnStatement";
	}
}
