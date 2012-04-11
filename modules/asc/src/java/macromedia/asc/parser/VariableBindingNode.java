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
public class VariableBindingNode extends Node
{
	public TypedIdentifierNode variable;
	public Node initializer;
	public ReferenceValue ref;
	public ReferenceValue typeref;
	public AttributeListNode attrs;
	public String debug_name;
	public int kind;
	
	protected static final int PACKAGE_FLAG = 1;	

	public VariableBindingNode(PackageDefinitionNode pkgdef, AttributeListNode attrs, int kind, TypedIdentifierNode variable, Node initializer)
	{
		ref = null;
		typeref = null;
		this.attrs = attrs;
		this.variable = variable;
		this.initializer = initializer;
		this.kind = kind;
		
		if (pkgdef != null)
		{
			flags |= PACKAGE_FLAG;
		}
	}

	public boolean inPackage()
	{
		return (flags & PACKAGE_FLAG) != 0;
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
		return variable.identifier.pos();
	}

	public String toString()
	{
		return "VariableBinding";
	}
}
