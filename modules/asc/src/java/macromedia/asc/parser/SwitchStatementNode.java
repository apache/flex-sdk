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
public class SwitchStatementNode extends Node
{
	public Node expr;
	public StatementListNode statements;
	public int loop_index;

	public SwitchStatementNode(Node expr, StatementListNode statements)
	{
		loop_index = 0;
		this.expr = expr;
		this.statements = statements;
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

	public boolean isBranch()
	{
		return true;
	}

	public String toString()
	{
		return "SwitchStatement";
	}
}
