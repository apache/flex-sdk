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
public class LiteralXMLNode extends Node
{
	public ListNode list;
	public boolean is_xmllist;

	public LiteralXMLNode(ListNode list, boolean is_xmllist)
	{
		void_result = false;
		this.list = list;
		this.is_xmllist = is_xmllist;
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

    public boolean isLiteral()
    {
        return true;
    }

	public boolean void_result;

	public void voidResult()
	{
		void_result = true;
	}

	public String toString()
	{
		return "LiteralXML";
	}
}
