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
public class ParameterNode extends Node
{
	public int kind;
	public IdentifierNode identifier;
	public Node type;
	public Node init;
	public ReferenceValue ref;
	public ReferenceValue typeref;
	public AttributeListNode attrs;
    public boolean no_anno;

	public ParameterNode(int kind, IdentifierNode identifier, Node type, Node init)
	{
		this.kind = kind;
		this.identifier = identifier;
		this.type = type;
		this.init = init;
		ref = null;
		typeref = null;
		attrs = null;
        no_anno = false;
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

	public int size()
	{
		return 1;
	}
	
	public String toString()
	{
		return "Parameter";
	}
}
