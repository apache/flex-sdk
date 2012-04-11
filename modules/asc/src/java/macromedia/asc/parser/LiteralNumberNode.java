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
public class LiteralNumberNode extends Node
{
	public TypeValue type;
	public String value;
    public NumberConstant numericValue;
    public NumberUsage numberUsage;

	public LiteralNumberNode(String value)
	{
		type = null;
		void_result = false;
		this.value = value.intern();
		numberUsage = null;
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

	public boolean void_result;

	public void voidResult()
	{
		void_result = true;
	}

    public boolean isLiteral()
    {
        return true;    
    }

	public boolean isLiteralNumber()
	{
		return true;
	}

	public boolean isLiteralInteger()
	{
		return false;
	}

	public int intValue()
	{
		return Integer.parseInt(value);
	}

	public void negate()
	{
		if (value.charAt(0) == '-') {
			value = value.substring(1);
		}
		else {
			value = "-" + value;
		}

		value = value.intern();
	}

	public String toString()
	{
		return "LiteralNumber";
	}
}
