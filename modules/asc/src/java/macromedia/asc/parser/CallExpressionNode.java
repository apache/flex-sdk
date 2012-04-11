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
public class CallExpressionNode extends SelectorNode
{
    public ArgumentListNode args;
	public boolean is_new;

	public CallExpressionNode(Node expr, ArgumentListNode args)
	{
		this.expr  = expr;
		this.args  = args;
		ref = null;
		is_new = false;
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

	public boolean void_result;

	public void voidResult()
	{
		void_result = true;
		//expr->voidResult();
	}

	public boolean isCallExpression()
	{
		return true;
	}

	public boolean isRvalue()
	{
		return isRValue();
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
      if(Node.useDebugToStrings)
         return "CallExpression@" + pos();
      else
         return "CallExpression";
	}
}
