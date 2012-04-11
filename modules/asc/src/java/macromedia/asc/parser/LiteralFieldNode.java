/*
 * Written by Jeff Dyer
 * Copyright (c) 1998-2003 Mountain View Compiler Company
 * All rights reserved.
 */

package macromedia.asc.parser;

import macromedia.asc.semantics.*;
import macromedia.asc.util.*;

/**
 * Node
 *
 * @author Jeff Dyer
 */
public class LiteralFieldNode extends Node
{
	public Node name;
	public Node value;
	public ReferenceValue ref;

	public LiteralFieldNode(Node name, Node value)
	{
		ref = null;
		this.name = name;
		this.value = value;
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
    
	public String toString()
	{
		return "LiteralField";
	}
}
