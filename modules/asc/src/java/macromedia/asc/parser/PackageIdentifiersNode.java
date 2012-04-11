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
public class PackageIdentifiersNode extends Node
{
	private static final int IS_DEFINITION_FLAG = 1;
	
	public ObjectList<IdentifierNode> list = new ObjectList<IdentifierNode>(5);
	public String pkg_part;
	public String def_part;

	public PackageIdentifiersNode(IdentifierNode item, int pos, boolean isDefinition)
	{
		super(pos);
		list.add(item);
		if (isDefinition)
		{
			flags |= IS_DEFINITION_FLAG;
		}
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

	int size()
	{
		return this.list.size();
	}

	public int pos()
	{
		return list.size() != 0 ? list.last().pos() : 0;
	}

	// Used externally by SyntaxTreeDumper
	public boolean isDefinition()
	{
		return (flags & IS_DEFINITION_FLAG) != 0;
	}

	public String toString()
	{
		return "PackageIdentifiers";
	}

    void clearIdentifierString()
    {
        if (pkg_part != null )
        {
            pkg_part = null;
        }
        if (def_part != null)
        {
            def_part = null;
        }
    }

    private static final String ASTERISK = "*".intern();

    public String toIdentifierString()
    {
        if( pkg_part == null )
        {
            StringBuilder buf = new StringBuilder();
            //ListIterator<IdentifierNode> it = list.listIterator();            
            //while( it.hasNext() )
			int len = list.size();
			for(int x=0; x < len; x++)
            {
				IdentifierNode item = list.get(x);
				if (x == len - 1 && isDefinition())
				{
					def_part = "";
					if (ASTERISK != item.name)
						def_part = item.name;
				}
				else
				{
					if( buf.length() > 0 )
					{
						buf.append(".");
					}
					buf.append(item.toIdentifierString());
				}
            }
            pkg_part = buf.toString();
        }

        return pkg_part;
    }
}
