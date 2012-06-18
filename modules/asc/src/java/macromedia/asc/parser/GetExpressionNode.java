/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
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
