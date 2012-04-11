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
public class FinallyClauseNode extends Node
{
	public StatementListNode statements;

    public CatchClauseNode default_catch;

	public FinallyClauseNode(StatementListNode statements, CatchClauseNode default_catch)
	{
		this.statements = statements;
        this.default_catch = default_catch;
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

	public String toString()
	{
		return "FinallyClause";
	}
}
