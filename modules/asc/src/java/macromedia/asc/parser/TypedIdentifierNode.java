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
public class TypedIdentifierNode extends Node
{
	public IdentifierNode identifier;
	// public IdentifierNode type;
	public Node type;
	//public Slot slot;
    public boolean no_anno;

	public TypedIdentifierNode(Node identifier, Node type, int pos)
	{
		super(pos);
		this.identifier = (IdentifierNode) identifier;
		// C: In ascap.exe, type could be MemberExpressionNode!
		// this.type = (IdentifierNode) type;
		this.type = type;
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

	public String toString()
	{
		return "TypedIdentifier";
	}
}
