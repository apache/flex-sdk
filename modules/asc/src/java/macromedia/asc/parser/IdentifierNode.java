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
public class IdentifierNode extends Node
{
	private static final String ASTERISK = "*".intern();

	public String name;
    public ReferenceValue ref;

	public IdentifierNode(String name, int pos)
	{
        this(name, true, pos);
	}

	/**
	 * This constructor is used by Flex direct AST generation.
	 *
	 * @param intern Controls whether value will be interned.  If
	 *				 <code>name</code> is an interned constant,
	 *				 <code>intern</code> should be false.  Otherwise,
	 *				 it should be true.
	 */
	public IdentifierNode(String name, boolean intern, int pos)
	{
		super(pos);

		if (intern)
		{
            this.name = name.intern();
		}
		else
		{
            assert name.intern() == name;
			this.name = name;
		}

		// It's safe to use == here, because name is interned above
		// and ASTERISK is interned.
		if (name == ASTERISK)
		{
			setAny(true);
		}
	}

	int authOrigTypeToken = -1;
	
	public void setOrigTypeToken(int token){
		authOrigTypeToken = token;
	}
	public int getOrigTypeToken(){
		return authOrigTypeToken;
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

    public boolean isAttribute()
    {
        return true;
    }
    
    public boolean isIdentifier()
	{
		return true;
	}

	public boolean hasAttribute(String name)
	{
		assert name.intern() == name;
		if (this.name == name)
		{
			return true;
		}
		return false;
	}

    public String toString()
    {
      if(Node.useDebugToStrings)
         return "Identifier@" + pos() + (name != null ? ": " + name.toString() : "");
      else
         return "Identifier";
    }

    public String toIdentifierString()
    {
        return name;
    }

	public void setAttr(boolean is_attr)
	{
		flags = is_attr ? (flags|IS_ATTR_FLAG) : (flags&~IS_ATTR_FLAG);
	}

	public boolean isAttr()
	{
		return (flags&IS_ATTR_FLAG)!=0;
	}

	public void setAny(boolean is_any)
	{
		flags = is_any ? (flags|IS_ANY_FLAG) : (flags&~IS_ANY_FLAG);
	}

	public boolean isAny()
	{
		return (flags&IS_ANY_FLAG)!=0;
	}
	
	public boolean isLValue()
	{
		return true;
	}
}
