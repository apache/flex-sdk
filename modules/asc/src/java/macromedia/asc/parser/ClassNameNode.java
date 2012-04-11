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
public class ClassNameNode extends Node
{
	public PackageNameNode pkgname;
	public IdentifierNode  ident;

    public boolean non_nullable = false;

	public ClassNameNode(PackageNameNode pkgname, IdentifierNode ident, int pos)
	{
		super(pos);
		this.pkgname = pkgname;
		this.ident = ident;
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
		return "ClassName";
	}
}
