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
public class PackageNameNode extends Node
{
	public LiteralStringNode url;
	public PackageIdentifiersNode id;

	public PackageNameNode(LiteralStringNode url, int pos)
	{
		super(pos);
		this.url = url;
		this.id = null;
	}

	public PackageNameNode(PackageIdentifiersNode id, int pos)
	{
		super(pos);
		this.url = null;
		this.id = id;
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
		return "PackageName";
	}
}
