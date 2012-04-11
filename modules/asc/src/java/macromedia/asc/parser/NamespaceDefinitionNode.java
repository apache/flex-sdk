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
public class NamespaceDefinitionNode extends DefinitionNode
{
	public IdentifierNode name;
	public Node value;
	public ReferenceValue ref;
	public String debug_name;
	public QName qualifiedname;
	public boolean needs_init;
	public BitSet gen_bits;

	public NamespaceDefinitionNode(PackageDefinitionNode pkgdef, AttributeListNode attrs, IdentifierNode name, Node value)
	{
		super(pkgdef, attrs, -1);
		this.name = name;
		this.value = value;
		ref = null;
		qualifiedname = null;
		gen_bits = null;
		needs_init = false;
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

	public boolean isConst()
	{
		return true;
	}

	public ReferenceValue getRef(Context cx)    
	{
		return ref;
	}
	
	public Node initializerStatement(Context cx)
	{
	    needs_init = true;
	    return this;
	}

	public BitSet getGenBits()
	{
		return gen_bits;
	}

	public BitSet getKillBits()
	{
		if (ref != null && ref.slot != null)
		{
			if (ref.slot.getDefBits() != null)
			{
				return xor(ref.slot.getDefBits(), gen_bits);
			}
			else
			{
				return gen_bits;
			}
		}
		else
		{
			return null;
		}
	}
	public String toString()
	{
		return "NamespaceDefinition";
	}
}
