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

