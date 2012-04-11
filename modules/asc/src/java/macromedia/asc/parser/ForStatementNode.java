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
public class ForStatementNode extends Node
{
	public Node initialize;
	public Node test;
	public Node increment;
	public Node statement;
	public boolean is_forin;

    public ForStatementNode(Node initialize, Node test, Node increment, Node statement, boolean is_forin)
	{
		loop_index = 0;
		this.initialize = initialize;
		this.test = test;
		this.increment = increment;
		this.statement = statement;
        this.is_forin = is_forin;
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

	public void expectedType(TypeValue type)
	{
		statement.expectedType(type);
	}

	public int loop_index;

	public boolean isBranch()
	{
		return true;
	}

	public boolean isDefinition()
	{
		return initialize != null ? initialize.isDefinition() : false;
	}

	public int countVars()
	{
		return (initialize != null ? initialize.countVars() : 0) + (statement != null ? statement.countVars() : 0);
	}

	public String toString()
	{
		return "ForStatement";
	}
}
