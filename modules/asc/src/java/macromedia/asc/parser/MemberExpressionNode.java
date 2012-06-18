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

import macromedia.asc.util.*;
import macromedia.asc.semantics.*;

import static macromedia.asc.parser.Tokens.*;

/**
 * Node
 *
 * @author Jeff Dyer
 */
public class MemberExpressionNode extends Node
{
    public Node base;
    public SelectorNode selector;
    public ReferenceValue ref;  // don't delete, alias for selector ref
    
	int authOrigToken = -1;
	
	public void setOrigToken(int token){
		authOrigToken = token;
	}
	public int getOrigToken(){
		return authOrigToken;
	}
	
    public MemberExpressionNode(Node base, SelectorNode selector, int pos)
    {
        super(pos);
        ref = null;
        this.base = base;
        this.selector = selector;
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

    public void voidResult()
    {
        selector.voidResult();
    }

    public boolean isMemberExpression()
    {
        return true;
    }

    public boolean isIndexedMemberExpression()
    {
        return selector.getMode() == LEFTBRACKET_TOKEN;
    }

    public BitSet getGenBits()
    {
        return selector.getGenBits();
    }

    public BitSet getKillBits()
    {
        return selector.getKillBits();
    }

    public String toString()
    {
        if(Node.useDebugToStrings)
        {
            return "MemberExpression@" + pos();
        }
        else
        {
            return "MemberExpression";
        }
    }

    public boolean isAttribute()
    {
        return selector.isAttribute();
    }

    public boolean isLabel()
    {
        if (this.base == null &&
            this.selector.isGetExpression() &&
            !(this.selector.expr instanceof QualifiedIdentifierNode))
        {
            return true;
        }
        return false;
    }

    public boolean isAny() { return selector.isAny(); }

    public boolean hasAttribute(String name)
    {
        if (this.base == null &&
            this.selector.hasAttribute(name))
        {
            return true;
        }
        return false;
    }

    public StringBuilder toCanonicalString(Context cx, StringBuilder buf)
    {
        buf.append(DocCommentNode.getRefName(cx, ref));
        return buf;
    }

    public boolean hasSideEffect()
    {
        return selector.hasSideEffect();
    }

    public boolean isLValue()
    {
        return this.selector.isLValue();
    }
 
    public boolean isConfigurationName()
    {
    	return this.selector.isConfigurationName();
    }
}
