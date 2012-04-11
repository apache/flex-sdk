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
public class ContinueStatementNode extends Node
{
	public IdentifierNode id;
	public int loop_index;

	public ContinueStatementNode(IdentifierNode id)
	{
		loop_index = 0;
		this.id = id;
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

	boolean isBranch()
	{
		return true;
	}

	public String toString()
	{
		return "ContinueStatement";
	}
}
