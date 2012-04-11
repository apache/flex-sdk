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
public class StoreRegisterNode extends Node
{
	public RegisterNode reg;
	public Node expr;
	public TypeValue type;
	public boolean void_result;

	public StoreRegisterNode(RegisterNode reg, Node expr, TypeValue type)
	{
		this.reg = reg;
		this.expr = expr;
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
	{
		void_result = true;
	}

	public String toString()
	{
		return "StoreRegister";
	}
	
	public boolean isLValue()
	{
		return true;
	}
}
