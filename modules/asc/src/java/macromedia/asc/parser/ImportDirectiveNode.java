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
public class ImportDirectiveNode extends DefinitionNode
{
	public AttributeListNode attrs;
	public PackageNameNode name;
	public PackageDefinitionNode pkg_node;
	public ReferenceValue ref;
	public boolean package_retrieved;
	public Context cx;

	public ImportDirectiveNode(PackageDefinitionNode pkgdef, AttributeListNode attrs, PackageNameNode name, PackageDefinitionNode pkg_node, Context cx)
	{
		super(pkgdef, attrs, -1);
		ref = null;
		this.attrs = attrs;
		this.name = name;
		this.pkg_node = pkg_node;
		package_retrieved = false;
		this.cx = cx;
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

	public boolean isConst()
	{
		return true;
	}

	public Node initializerStatement(Context cx)
	{
		return cx.getNodeFactory().emptyStatement();
	}

	public String toString()
	{
		return "importdirective";
	}
}
