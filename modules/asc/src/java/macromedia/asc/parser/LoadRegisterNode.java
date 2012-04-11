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
public class LoadRegisterNode extends Node
{
	public RegisterNode reg;
	public TypeValue type;
	public boolean void_result;

	public LoadRegisterNode(RegisterNode reg, TypeValue type)
	{
		this.reg = reg;
		this.type = type;
		void_result = false;
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

	public void voidResult()
	{   // do nothing, never true
	}

	public String toString()
	{
		return "LoadRegister";
	}
}
