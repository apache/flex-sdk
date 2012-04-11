/*
 * Written by Jeff Dyer
 * Copyright (c) 1998-2003 Mountain View Compiler Company
 * All rights reserved.
 */

package macromedia.asc.parser;

import macromedia.asc.util.*;
import macromedia.asc.semantics.*;
import static macromedia.asc.util.BitSet.*;

/**
 * Node
 *
 * @author Jeff Dyer
 */
public class ListNode extends Node
{
	public ObjectList<Node> items = new ObjectList<Node>(1);
	public ObjectList<Value> values = new ObjectList<Value>(1);

	public ListNode(ListNode list, Node item, int pos)
	{
		super(pos);
		items.add(item);
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

	public boolean isList()
	{
		return true;
	}

	public int size()
	{
		return items.size();
	}

	public int pos()
	{
		return (items.size() != 0) ? items.last().pos() : 0;
	}

	public BitSet getGenBits()
	{
		BitSet genbits = null;

		for (Node n : items)
			genbits = reset_set(genbits, n.getKillBits(), n.getGenBits());

		return genbits;
	}

	public BitSet getKillBits()
	{
		BitSet killbits = null;

		for (Node n : items)
			killbits = reset_set(killbits, n.getGenBits(), n.getKillBits());

		return killbits;
	}

	public void voidResult()
	{
		items.last().voidResult();
	}

	public String toString()
	{
      if(Node.useDebugToStrings)
         return "List@" + pos();
      else
         return "List";
	}

	public boolean isAttribute()
	{
		for (Node n : items)
		{
			if (!n.isAttribute())
			{
				return false;
			}
		}

		return true;
	}

	public boolean isLabel()
	{
		if (items.size() == 1 && items.last().isLabel())
		{
			return true;
		}
		return false;
	}

	public boolean hasAttribute(String name)
	{
		for (int i = 0, size = items.size(); i < size; i++)
		{
			Node n = items.get(i);
			if (n.hasAttribute(name))
			{
				return true;
			}
		}
		return false;
	}
	
	public boolean isLValue()
	{
		return items.size() == 1 && items.at(0).isLValue();
	}
	
	public boolean isConfigurationName()
	{
		return items.size() == 1 && items.at(0).isConfigurationName();
	}
}
