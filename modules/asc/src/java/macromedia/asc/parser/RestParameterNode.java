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
public class RestParameterNode extends ParameterNode
{
	public Node parameter;

	public RestParameterNode(ParameterNode parameter)
	{
		super(parameter.kind, parameter.identifier, parameter.type, parameter.init);
		this.parameter = parameter;
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
		return 0;
	}
	
	public String toString()
	{
		return "RestParameter";
	}
}
