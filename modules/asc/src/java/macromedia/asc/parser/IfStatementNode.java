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
public class IfStatementNode extends Node
{
	public Node condition;
	public Node thenactions;
	public Node elseactions;
	public boolean is_true;
	public boolean is_false;
	
	public IfStatementNode(Node condition, Node thenactions, Node elseactions)
	{
	    is_true = false;
	    is_false = false;
	    
		this.condition = condition;
		this.thenactions = thenactions;
		this.elseactions = elseactions;
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
		return (thenactions != null ? thenactions.countVars() : 0) + (elseactions != null ? elseactions.countVars() : 0);
	}

	public String toString()
	{
		return "IfStatement";
	}

	public boolean isBranch()
	{
		return true;
	}
}
