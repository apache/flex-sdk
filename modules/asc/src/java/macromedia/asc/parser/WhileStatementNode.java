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
public class WhileStatementNode extends Node
{
	public Node expr;
	public Node statement;
	
	public WhileStatementNode(Node expr, Node statement)
	{
		loop_index = 0;
		this.expr = expr;
		this.statement = statement;
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

	public int countVars()
	{
		return statement != null ? statement.countVars() : 0;
	}

	public int loop_index;

	public BitSet getGenBits()
	{
		return statement != null ? statement.getGenBits() : null;
	}

	public BitSet getKillBits()
	{
		return statement != null ? statement.getKillBits() : null;
	}

	public String toString()
	{
		return "WhileStatement";
	}
}
