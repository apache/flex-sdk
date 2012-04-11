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
public class QualifiedIdentifierNode extends IdentifierNode
{
	public Node qualifier;
	public boolean is_config_name;

	public QualifiedIdentifierNode(Node qualifier, String name, int pos)
	{
		super(name != null ? name : "", pos);
		if (name != null)
		{
			assert name.intern() == name;
		}
		this.qualifier = qualifier;
		this.is_config_name =false;
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
      if(Node.useDebugToStrings)
         return "QualifiedIdentifier@" + pos() + ": " + (name != null ? name : "");
      else
         return "QualifiedIdentifier";
	}

	public boolean isConfigurationName()
	{
		return this.is_config_name;
	}
}
