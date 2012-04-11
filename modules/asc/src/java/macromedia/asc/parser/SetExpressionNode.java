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
public class SetExpressionNode extends SelectorNode
{
	public ArgumentListNode args;
	public TypeInfo value_type;
    public boolean is_constinit;
    public boolean is_initializer;
    
    public ReferenceValue getRef(Context cx)
	{
		return ref;
	}

	public BitSet gen_bits;

	public SetExpressionNode(Node expr, ArgumentListNode args)
	{
		this.expr  = expr;
		this.args  = args;
		ref = null;
		gen_bits = null;
		void_result = false;
        is_constinit = false;
        is_initializer = false;
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
		expr.voidResult();
	}

	public boolean isSetExpression()
	{
		return true;
	}

    public boolean isQualified()
    {
        QualifiedIdentifierNode qin = expr instanceof QualifiedIdentifierNode ? (QualifiedIdentifierNode) expr : null;
        return qin!=null?qin.qualifier!=null:false;
    }
    
    public boolean isAttributeIdentifier()
    {
    	return expr instanceof IdentifierNode ? ((IdentifierNode)expr).isAttr() : false;
    }
    
    public boolean isAny()
    {
    	return expr instanceof IdentifierNode ? ((IdentifierNode)expr).isAny() : false;
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
		return "SetExpression";
	}

    public boolean hasSideEffect() 
    {
        return true;
    }
}
