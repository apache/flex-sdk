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
public class UntypedVariableBindingNode extends Node
{
	public IdentifierNode identifier;
	public Node initializer;
	public ReferenceValue ref;

	public UntypedVariableBindingNode(IdentifierNode identifier, Node initializer)
	{
		ref = null;
		this.identifier = identifier;
		this.initializer = initializer;
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

	public int pos()
	{
		return identifier.pos();
	}

	public String toString()
	{
		return "VariableBinding";
	}
}
