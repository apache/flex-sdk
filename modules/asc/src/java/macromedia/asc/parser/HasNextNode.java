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
 * @author Gary Grossman
 */
public class HasNextNode extends Node
{
	public RegisterNode objectRegister;
	public RegisterNode indexRegister;

	public HasNextNode(RegisterNode objectRegister,
					   RegisterNode indexRegister)
	{
		this.objectRegister = objectRegister;
		this.indexRegister = indexRegister;		
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
		return "HasNext";
	}
}
