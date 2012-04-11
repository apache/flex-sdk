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
public class InvokeNode extends SelectorNode
{
	public String name;
	public ArgumentListNode args;
	public int index;

	public InvokeNode(String name, ArgumentListNode args)
	{
		this.name = name.intern();
		this.args = args;
		ref = null;
		index = 0;
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

	public String toString()
	{
		return "Invoke";
	}
}
