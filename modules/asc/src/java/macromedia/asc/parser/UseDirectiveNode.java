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
public class UseDirectiveNode extends DefinitionNode
{
	public Node expr;
	public ReferenceValue ref;

	public UseDirectiveNode(PackageDefinitionNode pkgdef, AttributeListNode attrs, Node expr)
	{
        super(pkgdef,attrs,-1);
        this.expr = expr;
		ref = null;
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

	public Node initializerStatement(Context cx)    
	{
		return cx.getNodeFactory().emptyStatement();
	}

	public String toString()
	{
		return "UseDirective";
	}
}
