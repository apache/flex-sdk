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
public class InterfaceDefinitionNode extends ClassDefinitionNode
{
	public InterfaceDefinitionNode(Context cx, PackageDefinitionNode pkgdef, AttributeListNode attrs, IdentifierNode name, ListNode interfaces, StatementListNode statements)
	{
		super(cx, pkgdef, attrs, name, null, interfaces, statements);
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
	
	public boolean isInterface() 
	{
		return true;
	}

	public String toString()
	{
		return "InterfaceDefinition";
	}
}
