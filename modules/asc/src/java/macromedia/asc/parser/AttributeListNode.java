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

/**
 * Node
 *
 * @author Jeff Dyer
 */
public class AttributeListNode extends Node
{
	public ObjectList<Node> items = new ObjectList<Node>(1);
	public boolean hasIntrinsic;
	public boolean hasStatic;
	public boolean hasFinal;
	public boolean hasVirtual;
	public boolean hasOverride;
	public boolean hasDynamic;
    public boolean hasNative;
    public boolean hasPrivate;
    public boolean hasProtected;
    public boolean hasPublic;
    public boolean hasInternal;
    public boolean hasConst;
    public boolean hasFalse;
    public boolean hasPrototype;
    public boolean compileDefinition;
 
    public Namespaces namespaces = new Namespaces(3);
    public ObjectList<String> namespace_ids = new ObjectList<String>(3);

    private ObjectValue userNamespace;
    
	public AttributeListNode(Node item, int pos)
	{
		super(pos);
		items.add(item);
		hasIntrinsic = false;
		hasStatic = false;
		hasFinal = false;
		hasVirtual = false;
		hasOverride = false;
		hasDynamic = false;
		hasNative = false;
        hasPrivate = false;
        hasProtected = false;
        hasPublic = false;
        hasInternal = false;
        hasConst = false;
        hasFalse = false;
        hasPrototype = false;
        compileDefinition = true; // Compile everything by default
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
		return items.size();
	}

	public int pos()
	{
		return items.size() != 0 ? items.last().pos() : 0;
	}

	public String toString()
	{
      if(Node.useDebugToStrings)
         return "AttributeList@" + pos();
      else
         return "AttributeList";
	}

	public boolean isAttribute()
	{
		for (Node n : items)
		{
			if (n.isAttribute())
			{
				return false;
			}
		}
		return true;
	}

	public boolean hasAttribute(String name)
	{
		for (Node n : items)
		{
			if (n.hasAttribute(name))
			{
				return true;
			}
		}
		return false;
	}

	public boolean isLabel()
	{
		if (items.size() == 1 && items.last().isLabel())
		{
			return true;
		}
		return false;
	}
	
	public ObjectValue getUserNamespace()
	{
		return userNamespace;
	}
	
	public void setUserNamespace(ObjectValue userNamespace)
	{
		this.userNamespace = userNamespace;
	}
	
	public boolean hasUserNamespace()
	{
		return userNamespace != null;
	}
}

