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
public class DoStatementNode extends Node
{
	public Node statements;
	public Node expr;
	
	public DoStatementNode(Node statements, Node expr)
	{
		loop_index = 0;
        this.statements = statements;
		this.expr = expr;
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

	public int countVars()
	{
		return statements.countVars();
	}

	public int loop_index;

	boolean isBranch()
	{
		return true;
	}

	public String toString()
	{
		return "DoStatement";
	}
}
