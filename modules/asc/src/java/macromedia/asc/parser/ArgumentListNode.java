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
public class ArgumentListNode extends Node
{
	public ObjectList<Node> items = new ObjectList<Node>(1);
	public ObjectList<TypeInfo> expected_types; // declared argument types
	public ByteList   decl_styles;      // for function calls, a vector of PARAM_REQUIRED, PARAM_Optional, or PARAM_Rest
    public boolean is_bracket_selector = false;  //  a[x,y,z] is a comma operator, all values but the last have void result


	public ArgumentListNode(Node item, int pos)
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

	public int size()
	{
		return items.size();
	}

	public int pos()
	{
		return items.size() != 0 ? items.last().pos() : 0;
	}

	public boolean isLiteralInteger()
	{
		if (items.size() == 1 && items.first().isLiteralInteger())
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	public String toString()
	{
		return "ArgumentList";
	}
	
	public void addType(TypeInfo type)
	{
		if (expected_types == null)
			expected_types = new ObjectList<TypeInfo>(2);
		expected_types.push_back(type);
	}
	
	public void addDeclStyle(int style)
	{
		if (decl_styles == null)
			decl_styles = new ByteList(2);
		decl_styles.push_back((byte)style);
	}

    public boolean hasSideEffect()
    {
        for( Node n : items )
        {
            if( n.hasSideEffect() )
            {
                return true;
            }
        }
        return false;
    }
}
