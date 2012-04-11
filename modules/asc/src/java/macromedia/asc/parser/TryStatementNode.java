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
public class TryStatementNode extends Node
{
	public StatementListNode tryblock;
	public StatementListNode catchlist;
	public FinallyClauseNode finallyblock;
	public boolean finallyInserted;
	public int loop_index;
	
	public TryStatementNode(StatementListNode tryblock, StatementListNode catchlist, FinallyClauseNode finallyblock)
	{
		this.tryblock = tryblock;
		this.catchlist = catchlist;
		this.finallyblock = finallyblock;
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

	public int countVars()
	{
		return (tryblock != null ? tryblock.countVars() : 0) +
			(catchlist != null ? catchlist.countVars() : 0) +
			(finallyblock != null ? finallyblock.countVars() : 0);
	}

	public boolean isBranch()
	{
		return true;
	}

	public String toString()
	{
		return "TryStatement";
	}
	private boolean skip = false;
	public void skipNode(boolean b)
	{
		skip = b;
	}

	public boolean skip()
	{
		return skip;
	}
}
