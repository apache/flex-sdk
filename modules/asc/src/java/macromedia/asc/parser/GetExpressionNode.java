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
public class GetExpressionNode extends SelectorNode
{

	// ISSUE: ident is referenced from ident and expr to distinguish between
	// references and dynamic references. Unsafe! Redesign.

    public boolean isAttribute()
    {
        return true;
    }

	public GetExpressionNode(IdentifierNode ident)
	{
		this.expr  = ident;
		ref = null;
	}

	public GetExpressionNode(Node expr)
	{
        this.expr = expr;
		ref = null;
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
		if(Node.useDebugToStrings)
	         return "GetExpression@" + pos();
	      else
	         return "GetExpression";
	}

	public boolean isGetExpression()
	{
		return true;
	}

	public boolean hasAttribute(String name)
	{
		if (((IdentifierNode)expr).hasAttribute(name))
		{
			return true;
		}
		return false;
	}

    public boolean isQualified()
    {
        QualifiedIdentifierNode qin = expr instanceof QualifiedIdentifierNode ? (QualifiedIdentifierNode) expr : null;
        return qin!=null?qin.qualifier!=null:false;
    }
    
    public boolean isAttributeIdentifier()
    {
    	return expr instanceof IdentifierNode ? ((IdentifierNode)expr).isAttr() : isAttr();  // if ident then use ident.is_attr, otherwise use selector is_attr
    }
    
    public boolean isAny()
    {
    	return expr instanceof IdentifierNode ? ((IdentifierNode)expr).isAny() : false;
    }

	public void voidResult()
	{
		super.voidResult();
		expr.voidResult();
	}
	
	public boolean isLValue()
	{
		return true;
	}
	
	public boolean isConfigurationName()
	{
		return this.expr.isConfigurationName();
	}
}
