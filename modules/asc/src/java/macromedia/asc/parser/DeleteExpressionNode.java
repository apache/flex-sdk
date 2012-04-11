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
public class DeleteExpressionNode extends SelectorNode
{
	public int op;
	public Slot slot;

	public DeleteExpressionNode(int op, Node expr)
	{
		super();
		this.op    = op;
		this.expr  = expr;
		ref = null;
		void_result = false;
		slot = null;
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
		//expr.voidResult();
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

	public String toString()
	{
		return "DeleteExpression";
	}
	public boolean isDeleteExpression()
	{
		return true;
	}
}
